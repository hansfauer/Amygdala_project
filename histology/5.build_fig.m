%% Set paths
projectDir = '/host/percy/local_raid/hans/amyg/hist/';
workDir = [projectDir, '/saveData/'];
outDir = [projectDir, '/outputs/'];
%to have required packages for matlab
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/NifTitoolbox');
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/outputs/tmp/');
%input variables here
side='R';
res= '100';
dataDir = [outDir,res,'umfeatures_',side,'/'];
%% get Mask
% Load nifti file
amygVol = load_nii([outDir,'/amyg_',side,'_',res,'um.nii.gz']);
mask = load_nii([outDir,'/amyg_',side,'_',res,'um_mask-bin-vF_ero5.nii.gz']);
mask = mask.img;
mask(mask > 0) = 1; % binarize
mask(mask == 0) = -inf;


%% Load all nifty files
amygMean = {};
amygSd = {};
amygSkew = {};
amygKurto = {};

prefix = 'original_firstorder';

for sigma = 2:2:10
    amygMean{sigma} = load_nii([dataDir, prefix, '_Mean_', char(string(sigma)),'_reshape_ero5_1sd','.nii.gz']);
    amygSd{sigma} = load_nii([dataDir, prefix, '_Variance_', char(string(sigma)),'_reshape_ero5_1sd','.nii.gz']);
    amygSkew{sigma} = load_nii([dataDir, prefix, '_Skewness_', char(string(sigma)),'_reshape_ero5_1sd','.nii.gz']);
    amygKurto{sigma} = load_nii([dataDir, prefix, '_Kurtosis_', char(string(sigma)),'_reshape_ero5_1sd','.nii.gz']);
end
%% Build Filter bank

FilterBank = {};

for sigma = 2:2:10
    aa = zscore(amygMean{sigma}.img(mask==1));
    tmp = zeros(size(mask));
    tmp(mask==1) = aa;
    FilterBank{1,sigma/2} = tmp .* mask;
    
    aa = zscore(amygSd{sigma}.img(mask==1));
    tmp = zeros(size(mask));
    tmp(mask==1) = aa;
    FilterBank{2,sigma/2} = tmp.* mask;

    aa = zscore(amygSkew{sigma}.img(mask==1));
    tmp = zeros(size(mask));
    tmp(mask==1) = aa;
    FilterBank{3,sigma/2} = tmp.* mask;

    aa = zscore(amygKurto{sigma}.img(mask==1));
    tmp = zeros(size(mask));
    tmp(mask==1) = aa;
    FilterBank{4,sigma/2} = tmp.* mask;
end

figure, imshow3Dfull(FilterBank{1,1}); caxis([-1,3]); colormap(jet);

%%building the feature bank matrix for plotting
J={};
M=[];
c=1;
for i= 1:5
    for j=1:4
        M = FilterBank{j,i}(mask==1); 
        J{c}=M;
%        flatbank[c] = tmp;
%         for k= 1:832006
%             
%             flatbank[c,k]= tmp[1,k];
%         end
        c = c+1; 
    end
end
M = [J{:}];
f = figure, imagesc(M), colormap(parula), axis('square'), caxis([-3.5 3.5])

%fname = strcat('~/Desktop/','matrix.png');
%exportfigbo(f, char(fname),'png', 8); % this function is here: /data_/mica1/03_projects/hans/micaopen/surfstat/surfstat_addons/exportfigbo.m


