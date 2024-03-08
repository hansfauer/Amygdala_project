%% Set paths
projectDir = '/host/percy/local_raid/hans/amyg/hist/';
dataDir = [projectDir, '/outputs/'];
workDir = [projectDir, '/saveData/'];
outDir = [projectDir, '/outputs/'];
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/NifTitoolbox');
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/outputs/tmp/');
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/scripts/');
addpath('/data_/mica1/03_projects/hans/micaopen/a_moment_of_change/scripts/')
side='R';
res='100';

%% Create a map of the mask to help map U1 and U2 values to their respective coordinates
mask = load_nii([outDir, 'amyg_',side,'_100um_mask-bin-vF_ero5.nii.gz']);
map=mask.img;
num=0;
for i = 1:size(map,1)
    for j = 1:size(map,2)
        for k = 1:size(map,3)
            if map(i,j,k) ~= 0 
                num=num+1;
                map(i,j,k)=num;
            end
        end
    end
end

mask.img=map;

%% load umap embeddings and project onto map
embed = csvread([outDir, res,'umUMAPembeddings_',side,'_amyg_ero5_1sd.csv']);

%% Create a map of the mask to help map U1 values to their respective coordinates
U1map=load_nii([outDir, 'amyg_',side,'_',res,'um_mask-bin-vF_ero5.nii.gz']);
U1map.img=single(U1map.img);
map=U1map.img;
num=0;
coordTable= zeros(length(embed),5);
I = zeros(length(embed),1);
J = zeros(length(embed),1);
K = zeros(length(embed),1);
U1 = zeros(length(embed),1);
U2 = zeros(length(embed),1);
for i = 1:size(map,1)
    for j = 1:size(map,2)
        for k = 1:size(map,3)
            if map(i,j,k) ~= 0 
                num=num+1;
                map(i,j,k)=embed(num,1);
                I(num,1)=i;
                J(num,1)=j;
                K(num,1)=k;
                coordTable(num,1)=i;
                coordTable(num,2)=j;
                coordTable(num,3)=k;
                coordTable(num,4)=embed(num,1);
                coordTable(num,5)=embed(num,2);
            end
        end
    end
end
%map(map==0) = -inf;
U1map.img=map;
figure, imshow3Dfull(U1map.img)

save_nii(U1map,[outDir, 'amyg_',side,'_',res,'um_u1_ero5_1sd.nii.gz'])

%% Create a map of the mask to help map U2 values to their respective coordinates
U2map=load_nii([outDir, 'amyg_',side,'_',res,'um_mask-bin-vF_ero5.nii.gz']);
U2map.img=cast(U2map.img,'double');
map=U2map.img;
num=0;
for i = 1:size(map,1)
    for j = 1:size(map,2)
        for k = 1:size(map,3)
            if map(i,j,k) > 0 
                num=num+1;   
                map(i,j,k)=embed(num,2);
            end
        end
    end
end
%map(map==0) = -inf;
U2map.img=map;
figure, imshow3Dfull(U2map.img)
save_nii(U2map,[outDir, 'amyg_',side,'_',res,'um_u2_ero5_1sd.nii.gz'])

%% Create a figure of all U1 and U2 maps at all 3 angles


%get colormap from micaopen
grays = [237,237,237;217,217,217;189,189,189;150,150,150;99,99,99;37,37,37]/255;
cmapGray = interp_colormap(grays,50);

%determin positions for plots in figure
spacing = [0.1 0.5];
height = [0.05 0.4 0.72];
ratio = [0.3 0.3];
x_label = ["Medial-Lateral", "Posterior-Anterior", "Inferior-Superior"];

fig = figure,
for i = 1:3
    if i == 1
        matrix = squeeze(U1map.img(100,:,:));
    end
    if i == 2
        matrix = squeeze(U1map.img(:,100,:));
    end
    if i == 3
        matrix = squeeze(U1map.img(:,:,100));    
    end
    a(i) = axes('position', [spacing(1) height(i) ratio]);
    imagesc(matrix)
    yticks([])
    xticks([])
    colormap(gray); 

end
for i = 1:3
    if i == 1
        matrix = squeeze(U2map.img(100,:,:));
    end
    if i == 2
        matrix = squeeze(U2map.img(:,100,:));
    end
    if i == 3
        matrix = squeeze(U2map.img(:,:,100));    
    end
    a(i) = axes('position', [spacing(2) height(i) ratio]);
    imagesc(matrix)
    yticks([])
    xticks([])
    colormap(gray);
end

%% get image of 3D amygdala with colorspectrum rgb values
%clr_spec = csvread([outDir, res,'um_colorspectrum_PCA_',side,'_ero11.csv']);
clr_spec = csvread([outDir, res,'um_colorspectrum_',side,'_ero5_1sd.csv']);
mask = load_nii([outDir, 'amyg_',side,'_100um_mask-bin-vF_ero5.nii.gz']);
%mask = load_nii([outDir, 'amyg_',side,'_200um_mask-bin-vF.nii.gz']);
map=mask.img;
num=0;
for i = 1:size(map,1)
    for j = 1:size(map,2)
        for k = 1:size(map,3)
            if map(i,j,k) ~= 0 
                num=num+1;
                map(i,j,k)=num;
            end
        end
    end
end

mask.img=map;
slice = 120;
uVox = unique(map(:,85,:));
uVox(uVox == 0) = [];
tmpCmap = clr_spec(uVox,:);
figure, imagesc(rot90(flipud(squeeze(map(:,85,:))))), colormap([0,0,0; clr_spec]), caxis([1,length(embed)]);


figure, imshow3Dfull(map), colormap([0,0,0; clr_spec]), caxis([1,483874]);



