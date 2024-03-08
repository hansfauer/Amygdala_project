%% Set paths
projectDir = '/host/percy/local_raid/hans/amyg/hist/';
outDir = [projectDir, '/outputs'];
volDir = [projectDir, '/volumes'];
probDir = [projectDir, '/prob_maps'];

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
slice = 130;
tmpVol = squeeze(probMaps{1}.img(:,slice,:));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)

% smoothing
probMapsSm = {};
for ii = 1:size(subregions,1)
    probMapsSm{ii} = smooth3(probMaps{ii}.img, 'box', 11);
end

% view
slice = 130;
tmpVol = squeeze(probMapsSm{1}(:,slice,:));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)


%% Threshold probability maps for each subregion

probMapT = zeros([size(amyg.img),length(subregions)]);
T = 0.25;
for reg = 1:length(subregions)
    disp(subregions{reg})
    %this_reg = probMaps{reg}.img;
    this_reg = probMapsSm{reg};
    this_regT = zeros(size(this_reg));
    regMask = this_reg>T; 
    this_regT(regMask) = 1;
    probMapT(:,:,:,reg) = this_regT;
end

% view
slice = 120;
tmpVol = squeeze(probMapT(:,slice,:,2));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)

% crop to mask
probMapCropT = probMapT .* mask.img;

% view
slice = 120;
tmpVol = squeeze(probMapCropT(:,slice,:,2));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)

% export cropped thresholded maps
tmp = amyg;
for reg = 1:length(subregions)
    tmp.img = squeeze(probMapCropT(:,:,:,reg));
    tmp.fileprefix = [outDir, '/',side,'_',res,'um_prob', char(subregions{reg})];
    save_nii(tmp, [outDir, '/',side,'_',res,'um_prob', char(subregions{reg}), '.nii.gz']);
end


%% Subregion-specific threshold (keep x% highest values)

probMapRT = zeros([size(amyg.img),length(subregions)]);
T = 95; 
for reg = 1:length(subregions)
    disp(subregions{reg})
    %this_reg = probMaps{reg}.img;
    this_reg = probMapsSm{reg};
    this_regV = this_reg(:);
    this_regV(this_regV == 0) = NaN;
    
    thisT = prctile(this_regV,T);
    this_regTV = zeros(size(this_regV));
    this_regTV(this_regV > thisT) = 1;
    
    this_regT = reshape(this_regTV,[size(this_reg)]);
    probMapRT(:,:,:,reg) = this_regT;
end

% view
slice = 120;
tmpVol = squeeze(probMapRT(:,slice,:,2));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)

% crop to mask
probMapCropRT = probMapRT .* mask.img;

% view
slice = 120;
tmpVol = squeeze(probMapCropRT(:,slice,:,3));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)

% export cropped thresholded maps
tmp = amyg;
for reg = 1:length(subregions)
    tmp.img = squeeze(probMapCropRT(:,:,:,reg));
    tmp.fileprefix = [outDir, '/',side,'_',res,'um_prob_prctile', char(subregions{reg})];
    save_nii(tmp, [outDir, '/',side,'_',res,'um_prob_prctile', char(subregions{reg}), '.nii.gz']);
end

% export cropped thresholded maps with probabilities
tmp = probMaps{1};
for reg = 1:length(subregions)
    probs = logical(squeeze(probMapCropRT(:,:,:,reg))) .* probMapsSm{reg};
    tmp.img = probs;
    tmp.fileprefix = [outDir, '/',side,'_',res,'um_prob_prctile_probs', char(subregions{reg})];
    save_nii(tmp, [outDir, '/',side,'_',res,'um_prob_prctile_probs', char(subregions{reg}), '.nii.gz']);
end



%% Export single map with unique value for each voxel

% Overlapping labels are attributed a 0
probMapUnique = zeros(size(probMapCropRT,1),size(probMapCropRT,2),size(probMapCropRT,3));
for ii = 1:size(probMapCropRT,1)
    ii
    for jj = 1:size(probMapCropRT,2)
        for kk = 1:size(probMapCropRT,3)
            values = squeeze(probMapCropRT(ii,jj,kk,:));
            uVal = unique(values);
            if sum(values) == 0
                probMapUnique(ii,jj,kk) = 0;
            elseif sum(values) == 1
                probMapUnique(ii,jj,kk) = find(values==1);
            else
                probMapUnique(ii,jj,kk) = 0;
            end
        end
    end
end

% view
slice = 120;
tmpVol = squeeze(probMapUnique(:,slice,:));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)

% export
tmp = amyg;
tmp.img = probMapUnique;
tmp.fileprefix = [outDir, '/',side,'_',res,'um_prob_prctile_all'];
save_nii(tmp, [outDir, '/',side,'_',res,'um_prob_prctile_all.nii.gz']);



% Overlapping labels are attributed a 4 (common "overlap" label)
probMapUnique = zeros(size(probMapCropRT,1),size(probMapCropRT,2),size(probMapCropRT,3));
for ii = 1:size(probMapCropRT,1)
    ii
    for jj = 1:size(probMapCropRT,2)
        for kk = 1:size(probMapCropRT,3)
            values = squeeze(probMapCropRT(ii,jj,kk,:));
            uVal = unique(values);
            if sum(values) == 0
                probMapUnique(ii,jj,kk) = 0;
            elseif sum(values) == 1
                probMapUnique(ii,jj,kk) = find(values==1);
            else
                probMapUnique(ii,jj,kk) = length(values)+1;
            end
        end
    end
end

% view
slice = 120;
tmpVol = squeeze(probMapUnique(:,slice,:));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)

% export
tmp = amyg;
tmp.img = probMapUnique;
tmp.fileprefix = [outDir, '/',side,'_',res,'um_prob_prctile_all_overlap'];
save_nii(tmp, [outDir, '/',side,'_',res,'um_prob_prctile_all_overlap.nii.gz']);



% Overlapping labels are attributed a specific label depending on which labels overlap
probMapUnique = zeros(size(probMapCropRT,1),size(probMapCropRT,2),size(probMapCropRT,3));
for ii = 1:size(probMapCropRT,1)
    ii
    for jj = 1:size(probMapCropRT,2)
        for kk = 1:size(probMapCropRT,3)
            values = squeeze(probMapCropRT(ii,jj,kk,:));
            uVal = unique(values);
            if sum(values) == 0
                probMapUnique(ii,jj,kk) = 0;
            elseif sum(values) == 1
                probMapUnique(ii,jj,kk) = find(values==1);
            elseif sum(values) == 2
                whichlabel = find(values==1);
                switch sum(whichlabel)
                    case 3
                        probMapUnique(ii,jj,kk) = 4;
                    case 4
                        probMapUnique(ii,jj,kk) = 5;
                    case 5
                        probMapUnique(ii,jj,kk) = 6;
                end
            else
                probMapUnique(ii,jj,kk) = 7;
            end
        end
    end
end

% view
slice = 120;
tmpVol = squeeze(probMapUnique(:,slice,:));
figure, imagesc(rot90(fliplr(tmpVol),-1)); colormap(viridis)

% export
tmp = amyg;
tmp.img = probMapUnique;
tmp.fileprefix = [outDir, '/',side,'_',res,'um_prob_prctile_unique_overlap'];
save_nii(tmp, [outDir, '/',side,'_',res,'um_prob_prctile_unique_overlap.nii.gz']);
