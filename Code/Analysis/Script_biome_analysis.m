% Script for biome based analysis

% G200 data: WWF’s Global 200 project analyzed global patterns of
% biodiversity to identify a set of the Earth's terrestrial, freshwater, 
% and marine ecoregions that harbor exceptional biodiversity and are 
% representative of its ecosystems.
% Source:
%   https://www.worldwildlife.org/publications/global-200
% Ref:
%   Olson, D. M., Dinerstein, E. 2002. The Global 200: Priority ecoregions 
%   for global conservation. Annals of the Missouri Botanical Garden 89(2):
%   199-224.
% we use G200 freshwater data - total 53 groups mostly mega basins

% The EF violation and Bio data are categorised based on G200-fw using
% arcgis 
% C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE
% data\ArcGIS\Paper_analysis\Percentile-50\biome\BiomeAnalysis
% and is compiled in G200_30_yeardata.xlsx

% <load  G200_30_yeardata.xlsx>
% <save data> 
% save G200_extractData


clc
clear all
close all

cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_paper_revision\Upper_Lower\Data'
load EFF_viol_all_table

cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\Biomes'
load G200_extractData
load Fishdata_ecoregion_joined_table
load Unique_MHT_ID_fw
% source ecoregion:C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\ArcGIS\FreshwaterEcoRegions_WWF

%% Replacing old violation values with new values
%lower + upper bound violation
Fishdata_ecoregion_joined_table(:,4)=EFF_viol_all_table(:,3);
Fishdata_ecoregion_joined_table(:,5)=EFF_viol_all_table(:,2);
Fishdata_ecoregion_joined_table(:,6)=EFF_viol_all_table(:,4);
Fishdata_ecoregion_joined_table(:,7)=EFF_viol_all_table(:,5);
%% G200
% 30 year mean data

% excluding unwanted col and renaming
G_200_30mean_extract_table=[G200_30mean(:,3),G200_30mean(:,5:22)];
G_200_30mean_extract=table2array(G_200_30mean_extract_table);

% classifing based on MHID
% Unique MHT_ID 
[C,ia] = unique(G200_30mean.MHT_ID);
Unique_MHT_ID = G200_30mean(ia,4:5);

% Unique MHT classes
% {'Large Lake',15;'Large River',16;'Large River Delta',17;
% 'Large River Headwaters',18;'Small Lake',19;'Small River Basin',20;
% 'Xeric Basin',21}
MHT_ID_uni=table2array(Unique_MHT_ID(:,2));

for i=1:size(MHT_ID_uni,1)
MHT_filter=G_200_30mean_extract(:,2)==MHT_ID_uni(i,1);
MHT_ID_uni(i,2)=sum(MHT_filter);
G_200_30mean_MHTID=G_200_30mean_extract(MHT_filter,:);

% bio data
 VarB={'TR','FR','PR','TD','FD','PD','FiR',};

B=[G_200_30mean_MHTID(:,12:17),G_200_30mean_MHTID(:,19)];

% EF vio data
A=[G_200_30mean_MHTID(:,7:10)];
VarA={'F','S','P.shift','P.stay'};

 A(A==-999)=NaN;
  B(B==-999)=NaN;

% % % cd('C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare')
% % % 
% % % alpha1=0.05;
% % % alpha2=0.01;
% % % [Rho P] = fcnMatrixPlots2grp(A, VarA, B, VarB, alpha1, alpha2);
% for additional plots
cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare\mycorrplot')

 [Rvals, Pvals]= mycorrplot_2(B, A,VarB,VarA);
sgtitle(sprintf('%s',Unique_MHT_ID.MHT(i))) 

cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\Biomes\CustomMap')
 % plotting heat map
 figure()
 h = heatmap(VarA,VarB,Rvals,'CellLabelColor','none','fontsize',16);
% % h.GridVisible = 'off';
hHeatmap = struct(h).Heatmap;
hHeatmap.GridLineStyle = ':';
hHeatmap.FontWeight = 'bold';

% % % % marking grids with significant relation
% % % col = (find(Pvals<0.05,2)');    
% % % row = (find(Pvals<0.05,1)');
% % % S = struct(h); % Undocumented
% % % ax = S.Axes;    % Undocumented
% % % xline(ax, [col-.5, col+.5], 'k-'); % see footnotes [1,2]
% % % yline(ax, [row-.5, row+.5], 'k-'); % see footnotes [1,2]

mycolormap = customcolormap(linspace(0,1,11), flip({'#860454','#c51b7c','#dc75ab','#f0b7da','#ffdeef','#f8f7f7','#e5f4d9','#b9e084','#7fbc42','#4d921e','#276418'}));
h.Colormap = mycolormap;
caxis([-0.6 0.6])

% % cd 'C:\Users\chm594\OneDrive - University of Saskatchewan\GW_EF\Analysis\crameri_v1.08\crameri'
% % crameri -broc

sgtitle(sprintf('%s',Unique_MHT_ID.MHT(i))) 

cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\Biomes')
end

%% temporal analysis - large basin wise
S_data_table=G200_yearly(:,7:36);
MSA_data_table=G200_yearly(:,38:67);
F_data_table=G200_yearly(:,69:98);
G_200_ID_table=G200_yearly(:,3);
G_200_ID=table2array(G_200_ID_table);

% classifing based on MHID
% Unique MHT_ID 
[C,ia] = unique(G200_yearly.G200_ID);
Unique_G200_ID = G200_yearly(ia,2:3);
G200_ID_uni=table2array(Unique_G200_ID(:,2));

for i=1:size(G200_ID_uni,1)
G200_filter=G_200_ID==G200_ID_uni(i,1);
G200_ID_uni(i,2)=sum(G200_filter);
% extraction using G200 filter
S_extract=table2array(S_data_table(G200_filter,:)); % col year; row subbasin
F_extract=table2array(F_data_table(G200_filter,:)); % col year; row subbasin
MSA_extract=table2array(MSA_data_table(G200_filter,:)); % col year; row subbasin


 [Slope_s_cv(i,1), Slope_f_cv(i,1),Slope_s_mean(i,1),Slope_f_mean(i,1),...
     R_val_f_mean(i,1),R_val_s_mean(i,1),pval_f_mean(i,1),pval_s_mean(i,1)]=...
     modelFit(S_extract,F_extract,MSA_extract);
 
 % median plot
S_extract_med=nanmedian(S_extract)';
F_extract_med=nanmedian(F_extract)'; 
MSA_extract_med=nanmedian(MSA_extract)';

% % figure()
% % scatter(S_extract_med,MSA_extract_med)
% % hold on
% % scatter(F_extract_med,MSA_extract_med)

end


%   close all

%% Freshwater ecoregion full (MHT)
% % % % % % FWER_30mean_extract_table=Fishdata_ecoregion_joined_table;
% % % % % % FWER_30mean_extract=table2array(FWER_30mean_extract_table);
% % % % % % 
% % % % % % % Unique MHT classes
% % % % % % % {'large lakes',1;'large river deltas',2;'montane freshwaters',3;
% % % % % % % 'xeric freshwaters and endorheic (closed) basins',4;
% % % % % % % 'temperate coastal rivers',5;'temperate upland rivers',6;
% % % % % % % 'temperate floodplain rivers and wetlands',7;
% % % % % % % 'tropical and subtropical coastal rivers',8;'tropical and subtropical upland rivers',9;
% % % % % % % 'tropical and subtropical floodplain rivers and wetland complexes',10;
% % % % % % % 'polar freshwaters',11;'oceanic islands',12}
% % % % % % 
% % % % % % MHT_ID_uni_fw=table2array(Unique_MHT_ID_fw(:,2));
% % % % % % 
% % % % % % 
% % % % % % for i=1:size(MHT_ID_uni_fw,1)
% % % % % % MHT_filter=FWER_30mean_extract(:,17)==MHT_ID_uni_fw(i,1);
% % % % % % MHT_ID_uni_fw(i,2)=sum(MHT_filter);
% % % % % % 
% % % % % % if MHT_ID_uni_fw(i,2)>0
% % % % % % FWER_30mean_MHTID=FWER_30mean_extract(MHT_filter,:);
% % % % % % 
% % % % % % % bio data
% % % % % %  VarB={'TR','FR','PR','TD','FD','PD','FiR'};
% % % % % % 
% % % % % % B=[FWER_30mean_MHTID(:,10:15),FWER_30mean_MHTID(:,9)];
% % % % % % 
% % % % % % % EF vio data
% % % % % % A=[FWER_30mean_MHTID(:,4:7)];
% % % % % % VarA={'F','S','P.shift','P.stay'};
% % % % % % 
% % % % % %  A(A==-999)=NaN;
% % % % % %   B(B==-999)=NaN;
% % % % % % 
% % % % % % % % % cd('C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare')
% % % % % % % % % 
% % % % % % % % % alpha1=0.05;
% % % % % % % % % alpha2=0.01;
% % % % % % % % % [Rho P] = fcnMatrixPlots2grp(A, VarA, B, VarB, alpha1, alpha2);
% % % % % % % for additional plots
% % % % % % cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare\mycorrplot')
% % % % % % B(1,:)=NaN;
% % % % % % A(1,:)=NaN;
% % % % % %  [Rvals, Pvals]= mycorrplot_2(B, A,VarB,VarA);
% % % % % % sgtitle(sprintf('%s',Unique_MHT_ID_fw.MHT_TXT(i))) 
% % % % % % 
% % % % % % cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\Biomes\CustomMap')
% % % % % %  % plotting heat map
% % % % % %  figure()
% % % % % %  h = heatmap(VarA,VarB,Rvals,'fontsize',16,'CellLabelColor','none');
% % % % % % % % h.GridVisible = 'off';
% % % % % % h.ColorbarVisible = 'off';
% % % % % %  h.CellLabelFormat = '%.2f';
% % % % % % 
% % % % % % hHeatmap = struct(h).Heatmap;
% % % % % % hHeatmap.GridLineStyle = ':';
% % % % % % % % hHeatmap.FontWeight = 'bold';
% % % % % % 
% % % % % % % % % % % marking grids with significant relation
% % % % % % % % % % col = (find(Pvals<0.05,2)');    
% % % % % % % % % % row = (find(Pvals<0.05,1)');
% % % % % % % % % % S = struct(h); % Undocumented
% % % % % % % % % % ax = S.Axes;    % Undocumented
% % % % % % % % % % xline(ax, [col-.5, col+.5], 'k-'); % see footnotes [1,2]
% % % % % % % % % % yline(ax, [row-.5, row+.5], 'k-'); % see footnotes [1,2]
% % % % % % 
% % % % % % mycolormap = customcolormap(linspace(0,1,11), flip({'#860454','#c51b7c','#dc75ab','#f0b7da','#ffdeef','#f8f7f7','#e5f4d9','#b9e084','#7fbc42','#4d921e','#276418'}));
% % % % % % h.Colormap = mycolormap;
% % % % % % caxis([-0.8 0.8])
% % % % % % 
% % % % % % 
% % % % % % sgtitle(sprintf('%s',Unique_MHT_ID_fw.MHT_TXT(i))) 
% % % % % % 
% % % % % % cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\Biomes')
% % % % % % end
% % % % % % 
% % % % % % end
