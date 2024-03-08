# Resample feature map so it's the same as orig image
outDir=/host/percy/local_raid/hans/amyg/hist/
res='100'
side='R'
for ((i=2; i<=10; i+=2)); do
    flirt -in ${outDir}/outputs/${res}umfeatures_${side}/original_firstorder_Mean_"$i"_ero5_1sd.nii.gz \
        -ref ${outDir}/outputs/amyg_${side}_${res}um.nii.gz \
        -out ${outDir}/outputs/${res}umfeatures_${side}/original_firstorder_Mean_"$i"_reshape_ero5_1sd.nii.gz \
        -applyxfm \
        -usesqform \
        -interp nearestneighbour \
        -datatype float \
        -v
        
    flirt -in ${outDir}/outputs/${res}umfeatures_${side}/original_firstorder_Variance_"$i"_ero5_1sd.nii.gz \
        -ref ${outDir}/outputs/amyg_${side}_${res}um.nii.gz \
        -out ${outDir}/outputs/${res}umfeatures_${side}/original_firstorder_Variance_"$i"_reshape_ero5_1sd.nii.gz \
        -applyxfm \
        -usesqform \
        -interp nearestneighbour \
        -datatype float \
        -v
        
    flirt -in ${outDir}/outputs/${res}umfeatures_${side}/original_firstorder_Skewness_"$i"_ero5_1sd.nii.gz \
        -ref ${outDir}/outputs/amyg_${side}_${res}um.nii.gz \
        -out ${outDir}/outputs/${res}umfeatures_${side}/original_firstorder_Skewness_"$i"_reshape_ero5_1sd.nii.gz \
        -applyxfm \
        -usesqform \
        -interp nearestneighbour \
        -datatype float \
        -v

    flirt -in ${outDir}/outputs/${res}umfeatures_${side}/original_firstorder_Kurtosis_"$i"_ero5_1sd.nii.gz \
        -ref ${outDir}/outputs/amyg_${side}_${res}um.nii.gz \
        -out ${outDir}/outputs/${res}umfeatures_${side}/original_firstorder_Kurtosis_"$i"_reshape_ero5_1sd.nii.gz \
        -applyxfm \
        -usesqform \
        -interp nearestneighbour \
        -datatype float \
        -v
done
