%% Set paths
projectDir = '/host/percy/local_raid/hans/amyg/hist/';
outDir = [projectDir, '/outputs'];
volDir = [projectDir, '/volumes'];
probDir = '/host/percy/local_raid/hans/amyg/hist/prob_maps/';

addpath('/data_/mica1/03_projects/hans/BIGBRAIN/NifTitoolbox');

%% Load data
side='L';
res='100';
%%% Volume
% Load nifti file
amyg = load_nii([outDir, '/amyg_',side,'_',res,'um.nii.gz']);
mask = load_nii([outDir, '/amyg_',side,'_',res,'um_mask-bin-vF_ero5.nii.gz']);

%%% Probabilistic maps
subregions = {"CM"; "LB"; "SF"};
probMaps = {};
for ii = 1:size(subregions,1)
    probMaps{ii} = load_nii(sprintf([probDir, '/tpl-bigbrain_desc-%s_',side,'_histological_',res,'um_resample.nii.gz'], subregions{ii}));
end

% view 
slice = 80;
tmpVol = squeeze(amyg.img(:,slice,:));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(gray)

slice = 80;
tmpVol = squeeze(probMaps{1}.img(:,slice,:));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(parula)


%% Make MPM

mpm = zeros(size(amyg.img));
for ii = 1:size(amyg.img,1)
    ii;
    for jj = 1:size(amyg.img,2)
        for kk = 1:size(amyg.img,3)
            
            voxel = zeros(1,size(subregions,1));
            for map = 1:size(subregions,1)
                voxel(1,map) = probMaps{map}.img(ii,jj,kk);
            end
            
            idxMax = find(voxel == max(voxel));
            if length(idxMax) > 1
                mpm(ii,jj,kk) = 0;
            else
                mpm(ii,jj,kk) = idxMax;
            end
        end
    end
end

slice = 80;
tmpVol = squeeze(mpm(:,slice,:));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)

% crop to mask
mpmCrop = mpm .* double(mask.img);
slice = 80;
tmpVol = squeeze(mpmCrop(:,slice,:));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)

% export cropped mpm
tmp = amyg;
tmp.img = mpmCrop;
tmp.fileprefix = [outDir,'/',res, 'um_mpm_',side,'_rescale'];
save_nii(tmp, [outDir,'/',res,'um_mpm_',side,'_rescale.nii.gz']);
