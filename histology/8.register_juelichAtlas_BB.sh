### Set up BigBrainWarp environment
bbwRepo=/data_/mica1/03_projects/hans/BigBrainWarp/
bash ${bbwRepo}/scripts/init.sh
source ${bbwRepo}/scripts/init.sh
export mnc2Path=/data_/mica1/01_programs/minc2/ # path to minc2 installation

### Files and directories
segDir=/host/percy/local_raid/hans/amyg/hist/segmentations/
volDir=/host/percy/local_raid/hans/amyg/hist/volumes/
xfmDir=/host/percy/local_raid/hans/amyg/hist/xfm/

juAtlas=${segDir}/juelich_nlin2icbm2009casym.nii # Juelich atlas in 2009c asym
mniBrain=${segDir}/mni_icbm152_t1_tal_nlin_asym_09c.nii.gz # 2009c asym template

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### Template registrations
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

# Files
asym09c=${volDir}/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c.nii
asym09c_brain=${volDir}/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_brain.nii.gz
sym09b=${volDir}/mni_icbm152_nlin_sym_09b/mni_icbm152_t1_tal_nlin_sym_09b_hires.nii
sym09b_brain=${volDir}/mni_icbm152_nlin_sym_09b/mni_icbm152_t1_tal_nlin_sym_09b_hires_brain.nii.gz

# BET
bet "$asym09c" "$asym09c_brain" -B -f 0.25 -v
bet "$sym09b" "$sym09b_brain" -B -f 0.25 -v

# ANTs SyN registration: Register ICBM2009c asym to ICBM2009b sym
xfmDirTmp=/host/percy/local_raid/hans/amyg/hist/volumes/reg/
xfmStr=${xfmDirTmp}/xfm_from_asym09c_to_sym09b_
antsRegistrationSyN.sh -d 3 -m "$asym09c_brain" -f "$sym09b_brain" -o "$xfmStr" -t s -n 6 -p d
antsApplyTransforms -d 3 -e 3 -i "$asym09c" \
    -r "$sym09b" \
    -t ${xfmStr}1Warp.nii.gz -t ${xfmStr}0GenericAffine.mat \
    -o "${xfmDirTmp}/asym09c_in_sym09b.nii.gz" \
    -v -u int

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### Full Juelich atlas
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

# Apply transform to Juelich atlas
antsApplyTransforms -d 3 -e 3 -i "$juAtlas" \
    -r "$sym09b" \
    -n GenericLabel \
    -t ${xfmStr}1Warp.nii.gz -t ${xfmStr}0GenericAffine.mat \
    -o "${segDir}/juelichAtlas_in_sym09b.nii.gz" \
    -v -u int

# Warp Juelich atlas (2009b sym) to bigbrain histological
bigbrainwarp --in_vol "${segDir}/juelichAtlas_in_sym09b.nii" \
    --in_space icbm \
    --interp nearest \
    --out_space bigbrain \
    --desc juelichAtlas \
    --wd ${segDir}
gzip "${segDir}/tpl-bigbrain_desc-juelichAtlas_histological.nii"

# Change resolution of warped segmentation to 100 microns
in="${segDir}/tpl-bigbrain_desc-juelichAtlas_histological.nii.gz"
flirt -in ${in} \
    -ref ${in} \
    -omat ${xfmDir}/test.mat \
    -applyisoxfm 0.1 \
    -v \
    -interp nearestneighbour \
    -datatype int \
    -out ${segDir}/juelich_atlas_bigbrain_100um.nii.gz



########LEFT SIDE#########
##########################
# crop the segmentation to amygdala ROI
outCrop="${segDir}/juelich_atlas_bigbrain_100um_L_crop.nii.gz"
fslroi ${segDir}/juelich_atlas_bigbrain_100um.nii.gz \
    ${outCrop} \
    368 286 749 185 304 197
    
# Resample the prob map so it's the same as amygdala ROI
outRample="${segDir}/juelich_atlas_bigbrain_100um_L_resample.nii.gz"
outDir=/host/percy/local_raid/hans/amyg/hist/outputs/
flirt -in ${outCrop} \
    -ref ${outDir}/amyg_L_100um.nii.gz \
    -out ${outRample} \
    -applyxfm \
    -usesqform \
    -interp nearestneighbour \
    -datatype int \
    -v

mrview ${outDir}/amyg_L_100um.nii.gz \
    -mode 2 \
    -overlay.load ${outRample}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### Probabilistic maps
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

# Register prob maps to BB histo space
probDir=/host/percy/local_raid/hans/amyg/hist/prob_maps/
suffix=l_N10_nlin2ICBM152asym2009c.nii.gz
areas='CM LB SF'
for subregion in ${areas}; do
    file="${probDir}/${subregion}_${suffix}"
    
    # register to ICBM2009b sym template
    antsApplyTransforms -d 3 -e 3 -i "$file" \
        -r "$sym09b" \
        -n Linear \
        -t ${xfmStr}1Warp.nii.gz -t ${xfmStr}0GenericAffine.mat \
        -o "${probDir}/${subregion}_L_in_sym09b.nii" \
        -v -u float
    
    # warp to histo space
    bigbrainwarp --in_vol "${probDir}/${subregion}_L_in_sym09b.nii" \
        --in_space icbm \
        --interp nearest \
        --out_space bigbrain \
        --desc ${subregion}_L \
        --wd ${probDir}
    
    gzip "${probDir}/${subregion}_L_in_sym09b.nii"
    gzip "${probDir}/tpl-bigbrain_desc-${subregion}_L_histological.nii"
done 


# Resample to 100 microns and crop
outDir=/host/percy/local_raid/hans/amyg/hist/outputs/
probDir=/host/percy/local_raid/hans/amyg/hist/prob_maps/
suffix=l_N10_nlin2ICBM152asym2009c.nii.gz
areas='CM LB SF'

for subregion in ${areas}; do
    in="${probDir}/tpl-bigbrain_desc-${subregion}_L_histological.nii.gz"
    out="${probDir}/tpl-bigbrain_desc-${subregion}_L_histological_100um.nii.gz"
    
    # resample to 100 microns
    flirt -in ${in} \
        -ref ${in} \
        -omat ${xfmDir}/test.mat \
        -applyisoxfm 0.1 \
        -v \
        -interp nearestneighbour \
        -datatype float \
        -out ${out}
    
    # crop the prob map
    outCrop=${probDir}/tpl-bigbrain_desc-${subregion}_L_histological_100um_crop.nii.gz
    fslroi ${out} \
        ${outCrop} \
        368 286 749 185 304 197
        
    # Resample the prob map so it's the same as amygdala ROI
    outRample=${probDir}/tpl-bigbrain_desc-${subregion}_L_histological_100um_resample.nii.gz
    flirt -in ${outCrop} \
		-ref ${outDir}/amyg_L_100um.nii.gz \
        -out ${outRample} \
        -applyxfm \
        -usesqform \
        -interp nearestneighbour \
        -datatype float \
        -v
done

mrview ${outDir}/amyg_L_100um.nii.gz \
    -mode 2 \
    -overlay.load ${probDir}/tpl-bigbrain_desc-CM_L_histological_100um_resample.nii.gz \
    -overlay.load ${probDir}/tpl-bigbrain_desc-LB_L_histological_100um_resample.nii.gz \
    -overlay.load ${probDir}/tpl-bigbrain_desc-SF_L_histological_100um_resample.nii.gz




#######RIGHT SIDE#########
##########################
# crop the segmentation to amygdala ROI
outCrop="${segDir}/juelich_atlas_bigbrain_100um_R_crop.nii.gz"
fslroi ${segDir}/juelich_atlas_bigbrain_100um.nii.gz \
    ${outCrop} \
    760 320 730 250 340 200
    
# Resample the prob map so it's the same as amygdala ROI
outRample="${segDir}/juelich_atlas_bigbrain_100um_R_resample.nii.gz"
outDir=/host/percy/local_raid/hans/amyg/hist/outputs/
flirt -in ${outCrop} \
    -ref ${outDir}/amyg_R_100um.nii.gz \
    -out ${outRample} \
    -applyxfm \
    -usesqform \
    -interp nearestneighbour \
    -datatype int \
    -v

mrview ${outDir}/amyg_R_100um.nii.gz \
    -mode 2 \
    -overlay.load ${outRample}

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
### Probabilistic maps
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

# Register prob maps to BB histo space
probDir=/host/percy/local_raid/hans/amyg/hist/prob_maps/
suffix=r_N10_nlin2ICBM152asym2009c.nii.gz
areas='CM LB SF'
for subregion in ${areas}; do
    file="${probDir}/${subregion}_${suffix}"
    
    # register to ICBM2009b sym template
    antsApplyTransforms -d 3 -e 3 -i "$file" \
        -r "$sym09b" \
        -n Linear \
        -t ${xfmStr}1Warp.nii.gz -t ${xfmStr}0GenericAffine.mat \
        -o "${probDir}/${subregion}_R_in_sym09b.nii" \
        -v -u float
    
    # warp to histo space
    bigbrainwarp --in_vol "${probDir}/${subregion}_R_in_sym09b.nii" \
        --in_space icbm \
        --interp nearest \
        --out_space bigbrain \
        --desc ${subregion}_R \
        --wd ${probDir}
    
    gzip "${probDir}/${subregion}_R_in_sym09b.nii"
    gzip "${probDir}/tpl-bigbrain_desc-${subregion}_R_histological.nii"
done 


# Resample to 100 microns and crop
outDir=/host/percy/local_raid/hans/amyg/hist/outputs/
probDir=/host/percy/local_raid/hans/amyg/hist/prob_maps/
suffix=r_N10_nlin2ICBM152asym2009c.nii.gz
areas='CM LB SF'

for subregion in ${areas}; do
    in="${probDir}/tpl-bigbrain_desc-${subregion}_R_histological.nii.gz"
    out="${probDir}/tpl-bigbrain_desc-${subregion}_R_histological_100um.nii.gz"
    
    # resample to 100 microns
    flirt -in ${in} \
        -ref ${in} \
        -omat ${xfmDir}/test.mat \
        -applyisoxfm 0.1 \
        -v \
        -interp nearestneighbour \
        -datatype float \
        -out ${out}
    
    # crop the prob map
    outCrop=${probDir}/tpl-bigbrain_desc-${subregion}_R_histological_100um_crop.nii.gz
    fslroi ${out} \
        ${outCrop} \
        760 320 730 250 340 200
        
    # Resample the prob map so it's the same as amygdala ROI
    outRample=${probDir}/tpl-bigbrain_desc-${subregion}_R_histological_100um_resample.nii.gz
    flirt -in ${outCrop} \
        -ref ${outDir}/amygR_image.nii.gz \
        -out ${outRample} \
        -applyxfm \
        -usesqform \
        -interp nearestneighbour \
        -datatype float \
        -v
done

mrview ${outDir}/amyg_R_100um.nii.gz \
    -mode 2 \
    -overlay.load ${probDir}/tpl-bigbrain_desc-CM_R_histological_100um_resample.nii.gz \
    -overlay.load ${probDir}/tpl-bigbrain_desc-LB_R_histological_100um_resample.nii.gz \
    -overlay.load ${probDir}/tpl-bigbrain_desc-SF_R_histological_100um_resample.nii.gz


