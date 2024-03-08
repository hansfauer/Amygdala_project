#download bigbrain volume and subcortical segmentations from xiao 2019
#set up work environment and register bigbrain into histological space
registrations_v1.sh
registrations_v2.sh

#crop amygdala volumes from BIGBRAIN on each respective side of brain, then resample mask to fit with cropped volumes, then binarize mask
#input /host/percy/local_raid/hans/amyg/hist/volumes/full8_${resHisto}um_optbal.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/segmentations/ICBM2009b_sym-SubCorSeg-${resHisto}um_bigbrain.nii.gz
#output /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um_mask-bin-clean_ero5.nii.gz
### or for 200um just do last section here and skip to puradiomics stuff
1.geany create_amyg_masks.sh

#binarize mask
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um_mask-bin-clean_ero5.nii.gz
#output /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um_mask-bin-vF_ero5.nii.gz
2.binarize_mask.m

#get features of amygdala at all moments and kernel sizes
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um_mask-bin-vF_ero5.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um.nii.gz
#output /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umfeatures_${side}/original_firstorder_${moments}_${kernelsize}_ero5_1sd.nii.gz
3.test_radiomics.ipynb

#resample all pyradiomics outputs to have same dimensions as input
#input /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umfeatures_${side}/original_firstorder_${moments}_${kernelsize}_ero5_1sd.nii.gz
#output /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umfeatures_${side}/original_firstorder_${moments}_${kernelsize}_reshape_ero5_1sd.nii.gz
4.merger_amyg.sh

#make figures of feature bank matrix and image plots
5.build_fig.m
6.place_fig.m

#make a featurebank with subsampling from mask made in preprocess_mask.m
#save a dataframe of all the moments (featurebank) as a pickle file
#input /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umfeatures_${side}/original_firstorder_${moments}_${kernelsize}_reshape.nii.gz
#output /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umfeatures_${side}/'cropped_featurebank.csv'
7.crop_featurebank.ipynb

#get julich probability map as target for UMAP projections
#input /host/percy/local_raid/hans/amyg/hist/segmentations/juelich_nlin2icbm2009casym.nii
#input /host/percy/local_raid/hans/amyg/hist/segmentations/mni_icbm152_t1_tal_nlin_asym_09c.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/volumes/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c.nii
#input /host/percy/local_raid/hans/amyg/hist/volumes/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_brain.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/volumes/mni_icbm152_nlin_sym_09b/mni_icbm152_t1_tal_nlin_sym_09b.nii
#input /host/percy/local_raid/hans/amyg/hist/volumes/mni_icbm152_nlin_sym_09b/mni_icbm152_t1_tal_nlin_sym_09b_brain.nii.gz
#output /host/percy/local_raid/hans/amyg/hist/prob_maps/tpl-bigbrain_desc-${subregion}_${side}_histological_100um_resample.nii.gz
8.register_juelichAtlas_BB.sh
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um_mask-bin-vF_ero5.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/prob_maps/tpl-bigbrain_desc-${subregion}_${side}_histological_100um_resample.nii.gz
#output /host/percy/local_raid/hans/amyg/hist/outputs/${res}um_mpm_${side}_rescale.nii.gz'
9.make_amygdala_mpm.m
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um_mask-bin-vF_ero5.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/prob_maps/tpl-bigbrain_desc-${subregion}_${side}_histological_100um_resample.nii.gz
#output /host/percy/local_raid/hans/amyg/hist/outputs/${res}um_mpm_${side}_um_prob_prctile_all_overlap.nii.gz
#output /host/percy/local_raid/hans/amyg/hist/outputs/${res}um_mpm_${side}_um_prob_prctile_probs${subregion}.nii.gz
10.juelich_thresh_probmaps.m

#With featurebank get UMAP projection and save all embeddings as .csv
#also load julich prob maps to add to Umap projections
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um_mask-bin-vF_ero5.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umfeatures_${side}/'cropped_featurebank.csv'
#output /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umUMAPembeddings_${side}_amyg_ero5_1sd.csv
#output /host/percy/local_raid/hans/amyg/hist/outputs/${res}um_mpm_${side}_um_prob_prctile_all_overlap.csv
11.Umap_.ipynb

#validate umap with juelich prob maps plots umap with the 3 amygdala subregions
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um_mask-bin-vF_ero5.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umUMAPembeddings_${side}_amyg_ero5_1sd.csv
#input /host/percy/local_raid/hans/amyg/hist/outputs/${res}um_mpm_${side}_um_prob_prctile_probs${subregion}.nii.gz
12.UMAP_heatmap.ipynb

#make umap projection with color spectrum over all the data points
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um_mask-bin-vF_ero5.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umUMAPembeddings_${side}_amyg_ero5_1sd.csv
#output /host/percy/local_raid/hans/amyg/hist/outputs/2Dclrbar_UMAP_"+side+"_"+res+"um_ero5_1sd"
12.5.Umap_2Dclrbar.ipynb

#make matrices of the whole feature bank, also when ordered by U1 and U2 values
# will output 3 png files of matrices to place in figure 1
#input /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umUMAPembeddings_${side}_amyg_ero5_1sd.csv
#input /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umfeatures_${side}/'cropped_featurebank.csv'
13.make_matrices.m

#show U1 and U2 of UMAP as a 3D amyg (also make plot of the the colorspectrum from umap space pasted onto the amygdala coordinates)
#will output the maps of U1 and U2 in their respective amygdala coordinates 
#input /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umUMAPembeddings_${side}_amyg_ero5_1sd.csv
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${resHisto}um_mask-bin-vF_ero5.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/outputs/2Dclrbar_UMAP_"+side+"_"+res+"um_ero5_1sd"
#output /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${res}um_${u1/u2}_ero5_1sd.nii.gz
14.U1U2amygMap.m

#matlab script that makes plots and graphs of U1 and U2 data
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${res}um_${u1/u2}_ero5_1sd.nii.gz
# output 3d histogram plots of U1 and U2 values along all 3 axes of amygdala and their correlation values
15.U1U2_plots.m

#matlab script to create a table to create an easy input for ridge_plot.R script
#input /host/percy/local_raid/hans/amyg/hist/outputs/${resHisto}umUMAPembeddings_${side}_amyg_ero5_1sd.csv
#input /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${res}um_${u1/u2}_ero5_1sd.nii.gz
#input /host/percy/local_raid/hans/amyg/hist/outputs/${res}um_mpm_${side}_um_prob_prctile${subregion}.nii.gz
#output /host/percy/local_raid/hans/amyg/hist/outputs/amyg_${side}_${res}seg_table.csv
16.make_R_table.m

#make ridge plots of U1 and U2 data in all 3 amygdala subdivisions
# will output a ridge plot figure for L and R amygdala /host/percy/local_raid/hans/amyg/hist/figures/ridge_plots.png
17.ridge_plot.R

#do variogram matching test to account for spatialauto correlation
18.Variograms.ipynb

#bring bigbrain to MNI152 space
19.RegisterBigBrain_to_MNI152.sh

#continue to in vivo structure analysis:
/host/percy/local_raid/hans/amyg/struct/scripts/everything_7T.sh
