###bring BigBrain to MNI152

### Set up BigBrainWarp environment

bbwRepo=/data_/mica1/03_projects/hans/BigBrainWarp
source ${bbwRepo}/scripts/init.sh
export mnc2Path=/data_/mica1/01_programs/minc2/ # path to your path to minc2 installation

### Define directories

# BB volumes
volDir=/host/percy/local_raid/hans/amyg/hist/volumes/
segDir=/host/percy/local_raid/hans/amyg/hist/segmentations/
outDir=/host/percy/local_raid/hans/amyg/hist/outputs/
xfmDir=/host/percy/local_raid/hans/amyg/hist/xfm/
### Use BigBrainWarp to bring segmentation in bigbrain histo spac

# Registration
side='L'
gunzip ${outDir}amyg_${side}_100um_u2_ero5_1sd.nii.gz
gunzip ${outDir}amyg_${side}_100um_u1_ero5_1sd.nii.gz
bigbrainwarp --in_vol ${outDir}amyg_${side}_100um_u2_ero5_1sd.nii --in_space bigbrain --interp trilinear --out_space icbm --out_res 1 --desc ${side}_U2_ero5_1sd --wd ${outDir}
bigbrainwarp --in_vol ${outDir}amyg_${side}_100um_u1_ero5_1sd.nii --in_space bigbrain --interp trilinear --out_space icbm --out_res 1 --desc ${side}_U1_ero5_1sd --wd ${outDir}


####not sur eif neccessary
# Resample resolution of segmentation to 100 microns
flirt -in ${segDir}/ICBM2009b_sym-SubCorSeg-${resSeg}um_bigbrain.nii \
-ref ${segDir}/ICBM2009b_sym-SubCorSeg-${resSeg}um_bigbrain.nii \
-omat ${xfmDir}/test.mat \
-applyisoxfm 0.1 \
-v \
-interp nearestneighbour \
-datatype int \
-out ${segDir}/ICBM2009b_sym-SubCorSeg-${resHisto}um_bigbrain.nii.gz
