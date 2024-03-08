%% Set paths
projectDir = '/host/percy/local_raid/hans/amyg/hist/';
dataDir = [projectDir, '/outputs/'];
workDir = [projectDir, '/saveData/'];
outDir = [projectDir, '/outputs/'];
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/NifTitoolbox');
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/outputs/tmp/')

side='R';
res='100';


%% make a matrix but ordered on U1 and U2 of UMAP
embed_path = [outDir, res,'umUMAPembeddings_',side,'_amyg_ero5_1sd.csv'];
fbank = [outDir, res,'umfeatures_',side,'/cropped_featurebank_ero5_1sd.csv'];
embedding = csvread(embed_path);
featurematrix=csvread(fbank,0,0);

%zscore the matrix to have better presentation of plots
M = featurematrix;
Z = zscore(M);
f = figure, imagesc(Z), colormap(parula), axis('square'), caxis([-3.5 3.5])

fname = strcat('~/Desktop/',side,'_matrix_amyg_ero5_1sd.png');
exportfigbo(f, char(fname),'png', 8); % this function is here: /data_/mica1/03_projects/hans/micaopen/surfstat/surfstat_addons/exportfigbo.m


%matrix ordered by U1
vector=[embedding, Z];
SV=sortrows(vector,1);
SV(:,1:2)=[];

f = figure, imagesc(SV), colormap(parula), axis('square'), caxis([-3.5 3.5])

fname = strcat('~/Desktop/',side,'_matrix_u1_amyg_ero5_1sd.png');
exportfigbo(f, char(fname),'png', 8); % this function is here: /data_/mica1/03_projects/hans/micaopen/surfstat/surfstat_addons/exportfigbo.m

%matrix ordered by U2
vector=[embedding, Z];
SV=sortrows(vector,2);
SV(:,1:2)=[];
f = figure, imagesc(SV), colormap(parula), axis('square'), caxis([-3.5 3.5])


fname = strcat('~/Desktop/',side,'_matrix_u2_amyg_ero5_1sd.png');
exportfigbo(f, char(fname),'png', 8); % this function is here: /data_/mica1/03_projects/hans/micaopen/surfstat/surfstat_addons/exportfigbo.m

