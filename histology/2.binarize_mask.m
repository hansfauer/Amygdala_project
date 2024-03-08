%binarize mask to just 1s and 0s
%% Set paths
projectDir = '/host/percy/local_raid/hans/amyg/hist/';
dataDir = [projectDir, '/outputs/'];
workDir = [projectDir, '/saveData/'];
outDir = [projectDir, '/outputs/'];
%to have required packages for matlab
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/NifTitoolbox');
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/outputs/tmp/');
%input variables here
side='L';
res= '100';
%% Binarize mask into 1s and 0s
% Load nifti file
mask = load_nii([projectDir, 'outputs/amyg_',side,'_',res,'um_mask-bin-clean_ero5.nii.gz']);
%make sure mask if in correct datatype
mask.hdr.dime.bitpix=32;
mask.hdr.dime.datatype=16;
mask.hdr.dime.xyzt_units=10;

tmp = mask.img;
% binarize the mask
tmp(tmp > 0) = 1;
tmp(tmp ~= 1) = 0;
mask.img=tmp;
save_nii(mask, [projectDir, 'outputs/amyg_',side,'_',res,'um_mask-bin-vF_ero5.nii.gz']);

%% make amygdala volume have NaNs outside of the mask

im = load_nii([projectDir, 'outputs/amyg_',side,'_',res,'um.nii.gz']);
amyg_im=im.img;
tmp=int32(tmp);

new_im = amyg_im.*tmp;
new_im(new_im == 0) = NaN;
im.img=new_im;
save_nii(im, [projectDir, 'outputs/amyg_',side,'_',res,'um_NaN.nii.gz']);

