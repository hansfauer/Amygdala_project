### Set up BigBrainWarp environment

bbwRepo=/data_/mica1/03_projects/jessica/BigBrainWarp/
bash ${bbwRepo}/scripts/init.sh
source ${bbwRepo}/scripts/init.sh
export mnc2Path=/data_/mica1/01_programs/minc2/ # path to your path to minc2 installation

### Define directories

# BB volumes
volDir=/host/percy/local_raid/hans/amyg/hist/volumes/
segDir=/host/percy/local_raid/hans/amyg/hist/segmentations/
outDir=/host/percy/local_raid/hans/amyg/hist/outputs/
xfmDir=/host/percy/local_raid/hans/amyg/hist/xfm/

#define the resolution of bigbrain being used
resHisto=100
BBvol=${volDir}/full8_${resHisto}um_optbal.nii.gz
seg=${segDir}/ICBM2009b_sym-SubCorSeg-${resHisto}um_bigbrain.nii.gz


# Extract ROI for each amygdala
# Volume
fslroi ${BBvol} ${outDir}/amyg_L_${resHisto}um.nii.gz 368 286 749 185 304 197
fslroi ${BBvol} ${outDir}/amyg_R_${resHisto}um.nii.gz 840 228 773 161 309 208

# Mask
fslroi ${seg} ${outDir}/amyg_L_${resHisto}um_mask.nii.gz 477 281 936 206 220 245
fslroi ${seg} ${outDir}/amyg_R_${resHisto}um_mask.nii.gz 936 266 945 185 192 286

mrview ${outDir}/amyg_L_${resHisto}um.nii.gz -mode 2 -overlay.load ${outDir}/amyg_L_${resHisto}um_mask.nii.gz
mrview ${outDir}/amyg_R_${resHisto}um.nii.gz -mode 2 -overlay.load ${outDir}/amyg_R_${resHisto}um_mask.nii.gz


# Resample the mask so it's the same as amygdala ROI
flirt -in ${outDir}/amyg_L_${resHisto}um_mask.nii.gz \
-ref ${outDir}/amyg_L_${resHisto}um.nii.gz \
-out ${outDir}/amyg_L_${resHisto}um_mask-resamp.nii.gz \
-applyxfm \
-usesqform \
-interp nearestneighbour \
-datatype int \
-v

flirt -in ${outDir}/amyg_R_${resHisto}um_mask.nii.gz \
-ref ${outDir}/amyg_R_${resHisto}um.nii.gz \
-out ${outDir}/amyg_R_${resHisto}um_mask-resamp.nii.gz \
-applyxfm \
-usesqform \
-interp nearestneighbour \
-datatype int \
-v

mrview ${outDir}/amyg_L_${resHisto}um.nii.gz -mode 2 -overlay.load ${outDir}/amyg_L_${resHisto}um_mask-resamp.nii.gz
mrview ${outDir}/amyg_R_${resHisto}um.nii.gz -mode 2 -overlay.load ${outDir}/amyg_R_${resHisto}um_mask-resamp.nii.gz


# Binarize left and right amygdala mask
fslmaths ${outDir}/amyg_L_${resHisto}um_mask-resamp.nii.gz -thr 21 ${outDir}/amyg_L_${resHisto}um_mask-bin.nii.gz
fslmaths ${outDir}/amyg_R_${resHisto}um_mask-resamp.nii.gz -thr 22 ${outDir}/amyg_R_${resHisto}um_mask-bin.nii.gz

mrview ${outDir}/amyg_L_${resHisto}um.nii.gz -mode 2 -overlay.load ${outDir}/amyg_L_${resHisto}um_mask-bin.nii.gz
mrview ${outDir}/amyg_R_${resHisto}um.nii.gz -mode 2 -overlay.load ${outDir}/amyg_R_${resHisto}um_mask-bin.nii.gz

#clean resampled mask borders while overlayed on amygdala volume
#input /data_/mica1/03_projects/hans/BIGBRAIN/outputs/amyg_L_${resHisto}um_mask-bin.nii.gz
#output /data_/mica1/03_projects/hans/BIGBRAIN/outputs/amyg_L_${resHisto}um_mask-bin-clean.nii.gz
########
# Manual labor time... clean up the masks #use ITK snap with semi automated editing
ITKSNAP
########

#dilate/erode mask for pyradiomics to not get edge effects 
fslmaths ${outDir}/amyg_L_${resHisto}um_mask-bin-clean.nii.gz -kernel boxv 5 -ero ${outDir}amyg_L_${resHisto}um_mask-bin-clean_ero5.nii.gz
fslmaths ${outDir}/amyg_R_${resHisto}um_mask-bin-clean.nii.gz -kernel boxv 5 -ero ${outDir}amyg_R_${resHisto}um_mask-bin-clean_ero5.nii.gz






### might not be necessary
# Sample voxel intensities and coordinates
3dmaskdump -mask ${outDir}/amyg_L_${resHisto}um_mask-bin-clean.nii.gz -xyz -o ${outDir}/amyg_intensities_L.txt ${outDir}/amyg_L_${resHisto}um.nii.gz
3dmaskdump -mask ${outDir}/amyg_R_${resHisto}um_mask-bin-clean.nii.gz -xyz -o ${outDir}/amyg_intensities_R.txt ${outDir}/amyg_R_${resHisto}um.nii.gz

##if we want to also have the amygdala in 200micron resolution, otherwise ignore
###### make amygdala 200um resolution for new analysis which matches the hippocampus:
# BB volumes

volDir=/data_/mica1/03_projects/hans/BIGBRAIN/volumes/
segDir=/data_/mica1/03_projects/hans/BIGBRAIN/segmentations/
outDir=/data_/mica1/03_projects/hans/BIGBRAIN/outputs/
xfmDir=/data_/mica1/03_projects/hans/BIGBRAIN/xfm/
resHisto=200
resSeg=500

flirt -in ${outDir}amyg_L_100um_mask-bin-vF.nii.gz \
-ref ${outDir}amyg_L_100um_mask-bin-vF.nii.gz \
-omat ${xfmDir}/test.mat \
-applyisoxfm 0.2 \
-v \
-interp nearestneighbour \
-datatype int \
-out ${outDir}amyg_L_200um_mask-bin-vF.nii.gz

#dilate before pyradiomics
fslmaths ${outDir}amyg_L_200um_mask-bin-vF.nii.gz -kernel boxv 25 -dilM ${outDir}amyg_L_200um_mask-dilated.nii.gz

##after merger_amyg.sh bring back to inital mask
for ((i=2; i<=10; i+=2)); do
fslmaths ${outDir}200umfeatures_L/original_firstorder_Kurtosis_${i}_reshape.nii.gz -mul ${outDir}amyg_L_200um_mask-bin-vF.nii.gz \
${outDir}200umfeatures_L/original_firstorder_Kurtosis_${i}_vf.nii.gz
fslmaths ${outDir}200umfeatures_L/original_firstorder_Skewness_${i}_reshape.nii.gz -mul ${outDir}amyg_L_200um_mask-bin-vF.nii.gz \
${outDir}200umfeatures_L/original_firstorder_Skewness_${i}_vf.nii.gz
fslmaths ${outDir}200umfeatures_L/original_firstorder_Mean_${i}_reshape.nii.gz -mul ${outDir}amyg_L_200um_mask-bin-vF.nii.gz \
${outDir}200umfeatures_L/original_firstorder_Mean_${i}_vf.nii.gz
fslmaths ${outDir}200umfeatures_L/original_firstorder_Variance_${i}_reshape.nii.gz -mul ${outDir}amyg_L_200um_mask-bin-vF.nii.gz \
${outDir}200umfeatures_L/original_firstorder_Variance_${i}_vf.nii.gz
done























