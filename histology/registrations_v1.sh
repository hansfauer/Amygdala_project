### Define directories

# BB volumes
volDir=/host/percy/local_raid/hans/amyg/hist/volumes/
segDir=/host/percy/local_raid/hans/amyg/hist/segmentations/
outDir=/host/percy/local_raid/hans/amyg/hist/outputs/
xfmDir=/host/percy/local_raid/hans/amyg/hist/xfm/
res=100

### Bring segmenation in bigbrain histo space

# Convert bigbrain image file to .mnc (from .nii)
filename=full8_${res}um_2009b_sym
gzip -d ${volDir}/${filename}.nii
mv ${volDir}/${filename}.nii ${outDir}/

# Download 100um file directly from mnc
nii2mnc ${outDir}/${filename}.nii ${outDir}/${filename}.mnc

# Apply tranform to segmentation
nii2mnc ${segDir}/BigBrain-SubCorSeg-300um.nii ${outDir}/BigBrain-SubCorSeg-300um.mnc

#lin
/data_/mica1/01_programs/minc2/mincresample -clobber \
	-invert_transformation \
	-transformation ${xfmDir}/bigbrain_to_icbm2009b_lin.xfm \
	-tfm_input_sampling -like ${volDir}/full8_${res}um_optbal.mnc \
	-nearest_neighbour \
	${outDir}/BigBrain-SubCorSeg-300um.mnc ${outDir}/BigBrain-SubCorSeg-300um_histo_lin.mnc
mnc2nii ${outDir}/BigBrain-SubCorSeg-300um_histo_lin.mnc ${outDir}/BigBrain-SubCorSeg-300um_histo_lin.nii

# nl
/data_/mica1/01_programs/minc2/mincresample -clobber \
	-invert_transformation -transformation ${xfmDir}/bigbrain_to_icbm2009b_nl.xfm \
	-use_input_sampling \
	-nearest_neighbour \
	${outDir}/BigBrain-SubCorSeg-300um.mnc ${outDir}/BigBrain-SubCorSeg-300um_histo_nl.mnc
mnc2nii ${outDir}/BigBrain-SubCorSeg-300um_histo_nl.mnc ${outDir}/BigBrain-SubCorSeg-300um_histo_nl.nii
