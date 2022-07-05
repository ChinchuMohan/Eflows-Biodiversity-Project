% Script for comparing the freshwater fish biodiversity facets with 
% EFE violation indicators

% Data source
% Su et al. 2021
% link to paper
%   https://science.sciencemag.org/content/371/6531/835
% link to data repository
%   https://figshare.com/articles/online_resource/Scripts_and_files_for_Human_Impacts_on_Global_Freshwater_Fish_Biodiversity_/13383170?file=25872060

% Abbreviations DI = Diversity index of fish
%               TR = Taxonomic richness
%               FR = Functional richness
%               PR = Phylogenetic richness
%               TD = Taxonomic dissimilarity
%               FD = Functional dissimilarity
%               PD = Phylogenetic dissimilarity
%               CCBF = Cyumilative change in biodversity facets

clc
clear all
close all

cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_paper_revision\Upper_Lower\Data'
load EFF_viol_all_table % new Ef viol estimates with upper and lower bounds

cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare'

load Fish_facets_Su_etal
 load Data_compare_rich
load TissauiData
load Richdata_joined_table_new % fish and amphi rich data not normalised
load catchment_flow_regime_class
% source folder C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\HydrographCheck
% catchment_class=1  highly variable flow regimes; 2 intermediate variable flow regimes 
% 3  low variable flow regimes; 4 stable
load hybasfishecoregion
% source: C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\ArcGIS\FreshwaterEcoRegions_WWF

[C,ia] = unique(hybasfishecoregion.MHT_NO);
Unique_MHT_ID = hybasfishecoregion(ia,6:7);


%% normalising Violation factors

Vio_s_norm= table2array(EFF_viol_all_table(:,2));
Vio_s_norm(Vio_s_norm==-999)=NaN;

Vio_f_norm= table2array(EFF_viol_all_table(:,3));
Vio_f_norm(Vio_f_norm==-999)=NaN;


x=table2array(EFF_viol_all_table(:,5));
x(x==-999)=NaN;
Vio_prob_stay_norm= (x - nanmin(x)) /...
    ( nanmax(x) - nanmin(x) );

x=table2array(EFF_viol_all_table(:,4));
x(x==-999)=NaN;
x(x==-1)=1;
Vio_prob_shift_norm= (x - nanmin(x)) /...
    (nanmax(x) - nanmin(x) );
basin_hist=table2array(EFF_viol_all_table(:,1));

%% normalising Fish facets
% joining Su et al data to freshwater ecosystem
hybas_eco_table=table(hybasfishecoregion.PFAF_ID,hybasfishecoregion.MHT_NO,...
'VariableNames',{'PFAF_ID' 'MHT_NO'});
Fish_facets_Su1 = join(Fish_facets_Su_etal,hybas_eco_table);
% table to array
Fish_facets_Su=table2array(Fish_facets_Su1);

% scale facets to unit zero mean and unit variance
ii=1;
for i=2:2:14
DI(:,ii)=Fish_facets_Su(:,i);
DI_scale(:,ii)=(DI(:,ii)-mean(DI(:,ii),'omitnan'))./std(DI(:,ii),'omitnan');
% col 1:TR; 2:FR; 3:PR; 4:TD; 5:FD; 6:PD 7:CCBF
ii=ii+1;
end
basin_Su=Fish_facets_Su(:,1);

Richdata_joined_new=table2array(Richdata_joined_table_new);
%% matching the EFE, MSA and Fish facets based on basin number
Tleft = table(basin_hist(:,1),catchment_class,mean(fhy_annual_median,2,'omitnan')...
    ,Vio_f_norm,Vio_s_norm,Vio_prob_shift_norm,Vio_prob_stay_norm,Richdata_joined_new(:,7),...
    Richdata_joined_new(:,8),'VariableNames',{'basin' 'cat_class' 'MSA_median' 'EFE_f' 'EFE_s' 'EFE_prob_shift'...
     'EFE_prob_stay' 'Rich_amphi' 'Rich_fish'});

 
 %% matching the EFE, MSA and Fish facets based on basin number
% % % Tleft = table(basin_hist(:,1),mean(fhy_annual_median,2,'omitnan')...
% % %     ,Vio_f_lower_median_mean,Vio_s_lower_median_mean,Data_prob_HMM(:,4),Data_prob_HMM(:,3),...
% % %     'VariableNames',{'basin' 'MSA_median' 'EFE_f' 'EFE_s' 'EFE_prob_shift'...
% % %      'EFE_prob_stay'});
Tright = table(basin_Su,DI(:,1),DI(:,2),DI(:,3),DI(:,4),DI(:,5),DI(:,6),DI(:,7),Fish_facets_Su1.MHT_NO,...
    'VariableNames',{'basin' 'TR' 'FR' 'PR' 'TD' 'FD' 'PD' 'CCBF' 'MHT_NO'});

% % % Tright = table(basin_Su,DI_scale(:,1),DI_scale(:,2),DI_scale(:,3),DI_scale(:,4),DI_scale(:,5),DI_scale(:,6),...
% % %     'VariableNames',{'basin' 'TR' 'FR' 'PR' 'TD' 'FD' 'PD'});
Fishdata_joined_table = join(Tleft,Tright);
FishData_joined=table2array(Fishdata_joined_table);

% filter MAF<10 cu.m/s
FishData_joined_new(Q_low_flter,:)=NaN;
FishData_joined(Q_low_flter,:)=NaN;

% joining Tissaui data
Tissauidata_joined_table = join(Tleft,TissauiData);
Tissauidata_joined=table2array(Tissauidata_joined_table);
% filter MAF<10 cu.m/s
Tissauidata_joined(Q_low_flter,:)=NaN;
%% Weighting violation based on AmphiRich

% % % % xx=FishData_joined(:,i);
% % % % FishWt= (xx - min(xx)) /...
% % % %     ( max(xx) - min(xx) );
% % % % Viol_FishWT=FishData_joined(:,3:6).*FishWt;
Vio_combined=sqrt(FishData_joined(:,4).^2+FishData_joined(:,5).^2+...
    FishData_joined(:,6).^2+FishData_joined(:,7).^2);
% % AmphiRichData_bioWt(:,5)=Vio_combined.*RichData_joined(:,7);
% col 1=f,2=s, 3=shift, 4=stay, 5=combined

%% bar plot of percentage of richness affected
var1={'TR','FR','PR','TD','FD','PD' 'CCBF'};
j=1;
for i=1:6 % loop for each fish facet
rich_data=DI(:,i);
% % rich_data=FishData_joined(:,2);%msa
rich_data(Q_low_flter,:)=NaN;

Tot_rich=max(rich_data,[],1,'omitnan');
% % Tot_rich=mean(rich_data,'omitnan');
% % Tot_rich=nansum(RichData_joined_new(:,8));
viol_data=FishData_joined(:,4:7); % f,s,shift,stay
% % % viol_data=Viol_FishWT;
viol_data(:,5)=Vio_combined; % combined
viol_data(Q_low_flter,:)=NaN;
var=char(var1(j));
Rich_perc_fish=richBarplot(Tot_rich, rich_data, viol_data,var);
j=j+1;
end

%% Cross correlation scatter plots

% % A=[FishData_joined(:,3),FishData_joined(:,8:15)];
% rearrange 
FishFacets=FishData_joined(:,10:15);
FishFacets(FishFacets>=300)=0;

% B=[FishFacets,FishData_joined(:,8:9)]; 
B=[FishFacets,FishData_joined(:,9)]; % removing AmR

% % A=[FishData_joined(:,7:12)];
 B(B==0)=NaN;
% % A(A>=1)=NaN;
% % % for i=1:6
% % % A_boxcox(:,i) = boxcox(A(:,i));
% % % end
%  VarB={'TR','FR','PR','TD','FD','PD','AmR','FiR'};
  VarB={'TR','FR','PR','TD','FD','PD','FiR'};% removing AmR
  
% % VarA={'TR','FR','PR','TD','FD','PD'};
A=viol_data(:,1:4);

VarA={'F','S','P.shift','P.stay'};
alpha1=0.05;
alpha2=0.01;
cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare'

[Rho P] = fcnMatrixPlots2grp(B, VarB, A, VarA, alpha1, alpha2);
set(findobj(gcf,'type','axes'),'FontSize',16,'FontWeight','Bold');
set(gca, 'color', 'none');


% for additional plots
cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare\mycorrplot')

 [Rvals, Pvals]= mycorrplot_2(B, A,VarB,VarA);


cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\Biomes\CustomMap')
 % plotting heat map
 figure()
 h = heatmap(VarA,VarB,Rvals,'CellLabelColor','none','fontsize',16);
% % h.GridVisible = 'off';
hHeatmap = struct(h).Heatmap;
hHeatmap.GridLineStyle = ':';
hHeatmap.FontWeight = 'bold';

% % % % % marking grids with significant relation
% % % % col = (find(Pvals<0.05,2)');    
% % % % row = (find(Pvals<0.05,1)');
% % % % S = struct(h); % Undocumented
% % % % ax = S.Axes;    % Undocumented
% % % % xline(ax, [col-.5, col+.5], 'k-'); % see footnotes [1,2]
% % % % yline(ax, [row-.5, row+.5], 'k-'); % see footnotes [1,2]

mycolormap = customcolormap(linspace(0,1,11), flip({'#860454','#c51b7c','#dc75ab','#f0b7da','#ffdeef','#f8f7f7','#e5f4d9','#b9e084','#7fbc42','#4d921e','#276418'}));
h.Colormap = mycolormap;
caxis([-0.6 0.6])

cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare')

%% Fish Weighted violation
kk=1;
pp=1;
for i=10:15
xx=FishData_joined(:,i);
 xx(xx>1)=1;
% % xx(xx==0)=NaN;
FishWt= ((0--1)*(xx - min(xx)) /...
(max(xx) - min(xx)))-1;
FishWt=-FishWt;

IncreaseIndex(:,pp)=xx>1;
pp=pp+1;
for j=1:5
Viol_FishWT(:,kk)=viol_data(:,j).*FishWt;
% col 1=f,2=s, 3=shift, 4=stay, 5=combined
kk=kk+1;
end
end
% % % j=1;
% % % xx=viol_data(:,j);
% % % VioWt= (xx - min(xx)) /...
% % % ( max(xx) - min(xx) );
% % % 
% % % figure()
% % % scatter(VioWt,FishWt(:,2))
%% plots based on flow reime classes <OPEN WHEN NECESSARY START>

% % % % % % % % Cross correlation scatter plots 
% % % % % % % % 
% % % % % % % Cat_class={'Highly variable flow', 'Intermediate variable flow','Low variable flow','Stable'};
% % % % % % % for k=1:4
% % % % % % %     filter_flow_reg=FishData_joined(:,2)==k;
% % % % % % % A=[FishData_joined(filter_flow_reg,3),FishData_joined(filter_flow_reg,8:15)];
% % % % % % % % % A=[FishData_joined(:,7:12)];
% % % % % % %  A(A==0)=NaN;
% % % % % % % % % A(A>=1)=NaN;
% % % % % % % % % % for i=1:6
% % % % % % % % % % A_boxcox(:,i) = boxcox(A(:,i));
% % % % % % % % % % end
% % % % % % %  VarA={'MSA', 'AR','FiR','TR','FR','PR','TD','FD','PD'};
% % % % % % % % % VarA={'TR','FR','PR','TD','FD','PD'};
% % % % % % % B=viol_data(filter_flow_reg,:);
% % % % % % % VarB={'F','S','P.shift','P.stay','Combined'};
% % % % % % % alpha1=0.05;
% % % % % % % alpha2=0.01;
% % % % % % % % % % [Rho P] = fcnMatrixPlots2grp(A, VarA, B, VarB, alpha1, alpha2);
% % % % % % % % % % sgtitle(Cat_class(k)) ;
% % % % % % % % for additional plots
% % % % % % % cd('C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare\mycorrplot')
% % % % % % % 
% % % % % % % mycorrplot_2(A, B,VarA,VarB)
% % % % % % % sgtitle(Cat_class(k)) ;
% % % % % % % 
% % % % % % % cd('C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare')
% % % % % % % end
% <OPEN WHEN NECESSARY END>


