%% define path variables
projectDir = '/host/percy/local_raid/hans/amyg/hist/';
dataDir = [projectDir, '/outputs/'];
outDir = [projectDir, '/outputs/'];

workDir2=outDir;
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/NifTitoolbox');
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/outputs/tmp/');
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/scripts/');

side='R';
res='100';

%% have array for all subregions in binary
mask = load_nii([outDir, 'amyg_',side,'_',res,'um_u1_ero5_1sd.nii.gz']);
SF = load_nii([workDir2, side,'_',res,'um_prob_prctileSF.nii.gz']);
CM = load_nii([workDir2, side,'_',res,'um_prob_prctileCM.nii.gz']);
LB = load_nii([workDir2, side,'_',res,'um_prob_prctileLB.nii.gz']);
SF=SF.img;
CM=CM.img;
LB=LB.img;
map=mask.img;
cm=zeros(nnz(map),1);
sf=zeros(nnz(map),1);
lb=zeros(nnz(map),1);
num=1;
for i = 1:size(map,1)
    for j = 1:size(map,2)
        for k = 1:size(map,3)
            if map(i,j,k) ~= 0 
                cm(num,1)=CM(i,j,k);
                sf(num,1)=SF(i,j,k);
                lb(num,1)=LB(i,j,k);
                num=num+1;
            end
        end
    end
end
cm=cm(1:nnz(map),1);
sf=sf(1:nnz(map),1);
lb=lb(1:nnz(map),1);
mask.img=map;
%% make table
target_file = 'prob_prctile_all_overlap_ero11';

embed = csvread([outDir, res,'umUMAPembeddings_',side,'_amyg_ero5_1sd.csv']);
u1 = embed(:,1);
u2 = embed(:,2);

seg_table=table(u1,u2,cm,sf,lb);
file_name= [outDir, 'amyg_',side,'_',res,'seg_table_ero5.csv'];
writetable(seg_table, file_name);


%% make test table
target_file = 'prob_prctile_all_overlap';
tmp_seg = load_nii([workDir2, target_file]);
