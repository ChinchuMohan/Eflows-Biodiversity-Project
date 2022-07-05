
% Script for conducting multi regression as suggested by reviewer 2 (Jun
% 15, 2022)
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
 VarB={'TR','FR','PR','TD','FD','PD','FiR'};

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

for kk=1:7
% multi regression


Data_reg = table(A(:,1),A(:,2),A(:,3),A(:,4),...
    B(:,kk));

% mixed regression with no classification
mdl = fitlm(Data_reg);
Rvals(kk,i) = mdl.Rsquared.Adjusted;
Pvals(kk,i)= coefTest(mdl);

cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare\mycorrplot');


end
end

% % % All Data
% % C=G_200_30mean_extract;
% % D=[G_200_30mean_extract(:,12:17),G_200_30mean_extract(:,19)];
% % 
% % for kk=1:7
% % % multi regression
% % Data_reg = table(C(:,7),C(:,8),C(:,9),C(:,10),...
% %     D(:,kk));
% % 
% % % mixed regression with no classification
% % mdl = fitlm(Data_reg);
% % Rvals(kk,i+1) = mdl.Rsquared.Adjusted;
% % Pvals(kk,i+1)= coefTest(mdl);
% % 
% % cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare\mycorrplot');
% % % % xx(kk,i)=cov(A(:,1:4),B(:,kk));
% % % % vdt=mvregress(A(:,1:4),B(:,kk));
% % 
% % 
% % end
%%
% % % % % for additional plots
% % % % cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare\mycorrplot')
% % % % 
% % % %  [Rvals, Pvals]= mycorrplot_2(B, A,VarB,VarA);
% % % % sgtitle(sprintf('%s',Unique_MHT_ID.MHT(i))) 
% % % % 
% % % % cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\Biomes\CustomMap')
 
% plotting heat map
 VarAA={'Large Lake','Large River','Large River Delta','Large River Headwaters','Small Lake','Small River Basin','Xeric Basin'};
 figure()
 h = heatmap(VarAA,VarB,Rvals,'CellLabelColor','none','fontsize',16);
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
cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\Biomes\CustomMap')

sgtitle('Correlation coefficient (R^2)')
caxis([0 .4])
cd 'C:\Users\chm594\OneDrive - University of Saskatchewan\GW_EF\Analysis\crameri_v1.08\crameri'
crameri -davos

% plotting pval
filter_pval=Pvals< 0.01;


 figure()
 h = heatmap(VarAA,VarB,double(filter_pval),'CellLabelColor','none','fontsize',16);
% 1 is significant


sgtitle('P value (0.01)')

% % sgtitle(sprintf('%s',Unique_MHT_ID.MHT(i))) 

