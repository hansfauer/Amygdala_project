### Set up BigBrainWarp environment

bbwRepo=/data_/mica1/03_projects/hans/BigBrainWarp/
bash ${bbwRepo}/scripts/init.sh
source ${bbwRepo}/scripts/init.sh
export mnc2Path=/data_/mica1/01_programs/minc2/ # path to your path to minc2 installation

### Define directories

# BB volumes
volDir=/host/percy/local_raid/hans/amyg/hist/volumes/
segDir=/host/percy/local_raid/hans/amyg/hist/segmentations/
outDir=/host/percy/local_raid/hans/amyg/hist/outputs/
xfmDir=/host/percy/local_raid/hans/amyg/hist/xfm/
resHisto=100
resSeg=500

### Use BigBrainWarp to bring segmentation in bigbrain histo space

# Registration
bash ${bbwRepo}/scripts/icbm_to_bigbrain.sh ${segDir}/ICBM2009b_sym-SubCorSeg-${resSeg}um.nii histological nearest ${segDir}


# Resample resolution of segmentation to 100 microns
flirt -in ${segDir}/ICBM2009b_sym-SubCorSeg-${resSeg}um_bigbrain.nii \
-ref ${segDir}/ICBM2009b_sym-SubCorSeg-${resSeg}um_bigbrain.nii \
-omat ${xfmDir}/test.mat \
-applyisoxfm 0.1 \
-v \
-interp nearestneighbour \
-datatype int \
-out ${segDir}/ICBM2009b_sym-SubCorSeg-${resHisto}um_bigbrain.nii.gz


