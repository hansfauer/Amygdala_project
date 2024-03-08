%% define path variables
projectDir = '/host/percy/local_raid/hans/amyg/hist/';
dataDir = [projectDir, '/outputs/'];
workDir = [projectDir, '/saveData/'];
outDir = [projectDir, '/outputs/'];

figDir = '/data_/mica1/03_projects/hans/BIGBRAIN/figures/';
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/NifTitoolbox');
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/outputs/tmp/');
addpath('/data_/mica1/03_projects/hans/BIGBRAIN/scripts/');
addpath('/data_/mica1/03_projects/hans/micaopen/a_moment_of_change/scripts/')

side='R';
res='100';
%% Make plots representing the U1 and U2 spread across the different dimensions for scatter plots

%load U1 and U2 coordinate maps
U1map = load_nii([outDir, 'amyg_',side,'_',res,'um_u1_ero5_1sd.nii.gz']);
U2map = load_nii([outDir, 'amyg_',side,'_',res,'um_u2_ero5_1sd.nii.gz']);

%get x y and z values for every voxel containing u1 and u2
map1=U1map.img;
map2=U2map.img;

u1coord = zeros(sum(sum(sum(map1 ~= 0))),3);
u1Val = zeros(sum(sum(sum(map1 ~= 0))),1);
u2Val = zeros(sum(sum(sum(map1 ~= 0))),1);
cpt=0;
for ii = 1:size(map1,1)
    for jj = 1:size(map1,2)
        for kk = 1:size(map1,3)
            if map1(ii,jj,kk) ~= 0
                cpt=cpt+1;
                u1coord(cpt,:) = [ii,jj,kk];
                u1Val(cpt) = map1(ii,jj,kk);
                u2Val(cpt) = map2(ii,jj,kk);
            else
                continue
            end
        end
    end
end

X = u1coord(:,3);
Y= u1coord(:,2);
Z= u1coord(:,1);
path = [outDir,'u1coord.csv'];
%% make figure 3D histogram

%get colormap from micaopen
grays = [255,255,255;217,217,217;189,189,189;150,150,150;99,99,99;37,37,37]/255;
cmapGray = interp_colormap(grays,50);

%determin positions for plots in figure
spacing = [0.1 0.5];
height = [0.05 0.4 0.72];
ratio = [0.3 0.25];
x_label = ["Medial-Lateral", "Posterior-Anterior", "Inferior-Superior"];

fig = figure, 
for i = 1:3
    a(i) = axes('position', [spacing(1) height(i) ratio]);
    hist3([u1coord(:,i),u1Val], [25,25], 'FaceColor','texturemap', 'CdataMode','auto', 'EdgeColor', 'interp', 'LineWidth', 1); 
    yticks([])
    xticks([])
    xlabel(x_label(i))
    ylabel('U1')
    %xlim([-2 2])
    %ylim([0 1])
    colormap(cmapGray)
    caxis([0 5000]);
    colorbar
    view(2)
end
for i = 1:3
    a(i) = axes('position', [spacing(2) height(i) ratio]);
    hist3([u1coord(:,i),u2Val], [25,25], 'FaceColor','texturemap', 'CdataMode','auto', 'EdgeColor', 'interp', 'LineWidth', 1); 
    yticks([])
    xticks([])
    xlabel(x_label(i))
    ylabel('U2')
    %xlim([-2 2])
    %ylim([0 1])
    colormap(cmapGray)
    caxis([0 5000]);
    colorbar
    view(2)
end

%get correlation values of u1 and u2 to their 3 axes
for i = 1:3
    corr(u1coord(:,i),u1Val,'Type', 'spearman')
end
for i = 1:3
    corr(u1coord(:,i),u2Val,'Type', 'spearman')
end

fname = strcat(figDir, side,'_U1&2_coord_density2D_ero5.png');
exportfigbo(fig, fname,'png', 8);
