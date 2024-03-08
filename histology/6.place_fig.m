%% Set some parameters
% Left indent, height, width/height ratio

spacing = [0 0.18 0.36 0.54 0.72 0.9];
spacingB = [0.01 0.09 0.19];
height = [0.8 0.6 0.4 0.2];
heightB = [0.45 0.37];
ratio = 0.18;
%romaF = flipud(roma);

%% Figure 1

f = figure,
f.Position(3:4) = [700 525];
iter=1;
for i = 1:4
    for j = 1:5
        matrix = rot90(fliplr(squeeze(FilterBank{i,j}(60:220,85,10:180))),3);
        %matrix = rot90((squeeze(FilterBank{i,j}(140,12:160,17:183))),1);
        % conn matrix
        a(iter) = axes('position', [spacing(j) height(i) 0.17 ratio]);
        imagesc(matrix)
        yticks([])
        xticks([])
%        axis('square')
        if j == 5
%             c = colorbar;
%             c.AxisLocation = 'out';
%             c.Location = 'west';
            if i == 4
                
                %c.Label.String = 'Voxel Intensity';
                %c.Label.Position = [0 0 4];
            end
            %c.FontSize = 7;
            %c.Position = [0.92 height(i)+.03 0.02 0.1];
        end
        colormap(gca); 
        caxis([-3.5 3.5]);
%         if i == 1
%             caxis([-80 30]);
%         end
%         if i == 2
%             caxis([0 1500]);%[3000 9000]);
%         end
%         if i == 3
%             caxis([-2,1.5]);%[.01 .1]);
%         end
%         if i == 4
%             caxis([1,10]);%[.001 .01]);
%         end
    end
end
c = colorbar;
c.AxisLocation = 'out';
c.Location = 'west';
c.FontSize = 10;
c.Position = [0.905 height(i)+.045 0.05 0.7];
c.LineWidth = 1.5;

%% Save figure
fname = strcat('~/Desktop/','featuremaps_amyg_',res,'um');
exportfigbo(f, char(fname),'png', 8); % this function is here: /data_/mica1/03_projects/hans/micaopen/surfstat/surfstat_addons/exportfigbo.m

