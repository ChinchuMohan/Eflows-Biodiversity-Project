
% Script for EFE violation - biodiversity analysis (both lower and upper
% bound violation) and for prepapring data for plotting in ArcGIS
% 

clc
close all
clear all

cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData'

load EFE_state_violationfreq_50.mat
load EFE_state_violationsever_50.mat
load('basin_hist.mat')

load Q_hist_annual.mat

cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare'
% % % load TissauiData
% % % load Richdata_joined_table_new % fish and amphi rich data not normalised
% % % load catchment_flow_regime_class
load Q_monthly_1976_2005.mat

% median of EFE_violations
% freq
EFE_violation_f(:,:,1)=violation_annual_h08_1976_2005.EFE_violation_all;
EFE_violation_f(:,:,2)=violation_annual_lpjml_1976_2005.EFE_violation_all;
EFE_violation_f(:,:,3)=violation_annual_pcr_globwb_1976_2005.EFE_violation_all;
EFE_violation_f(:,:,4)=violation_annual_watergap2_1976_2005.EFE_violation_all;
EFE_violation_f(:,:,5)=median(EFE_violation_f(:,:,1:4),3,'omitnan');% median
% filtering catchments
% excluding catchments with mean annual Q < 10 m3/s
% % % EFE_violation_f(Q_low_flter,:)=NaN;

EFE_f_median_all=EFE_violation_f(:,:,5);

% severity
% severity recalculation combining lower and upper
% % % EFE_violation_s1(:,:,1)=abs(violation_annual_s_h08_1976_2005.EFE_violation_s_lower)...
% % %     +violation_annual_s_h08_1976_2005.EFE_violation_s_upper;
% % % EFE_violation_s(:,:,2)=violation_annual_s_lpjml_1976_2005.EFE_violation_s_all;
% % % EFE_violation_s(:,:,3)=violation_annual_s_pcr_globwb_1976_2005.EFE_violation_s_all;
% % % EFE_violation_s(:,:,4)=violation_annual_s_watergap2_1976_2005.EFE_violation_s_all;

EFE_violation_s(:,:,1)=violation_annual_s_h08_1976_2005.EFE_violation_s_lower;
EFE_violation_s(:,:,2)=violation_annual_s_lpjml_1976_2005.EFE_violation_s_lower;
EFE_violation_s(:,:,3)=violation_annual_s_pcr_globwb_1976_2005.EFE_violation_s_lower;
EFE_violation_s(:,:,4)=violation_annual_s_watergap2_1976_2005.EFE_violation_s_lower;
EFE_violation_s(:,:,5)=median(EFE_violation_s(:,:,1:4),3,'omitnan');% median
% filtering catchments
% excluding catchments with mean annual Q < 10 m3/s
% % % % % EFE_violation_s(Q_low_flter,:)=NaN;
EFE_s_median_all=EFE_violation_s(:,:,5);

%% Calculate P.shift and P.stay
% use R studio for it

% Data preperation
% STEP 1: Run Script_HMMDataprep
% STEP 2: Run Hmm_script.R in Rstudio
% STEP 3: the Rstudio run results will be stores in
% Prob_final_annul_new.xlsx

%% Figure 2: Maps of 4 violation indicators

% the mapping is done using ArcGIS

% STEP 1: preparing violation dataset for mapping in arcgis
cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_paper_revision\Upper_Lower\HMM'
load Probfinalannualnew % output from Rstudio in mat format

% normalise S and F
X=nanmean(EFE_f_median_all,2); % F
f_all_normal= (X - min(X)) /( max(X) - min(X) );
X=abs(nanmean(EFE_s_median_all,2));% S
s_all_normal= (X - min(X)) /( max(X) - min(X) );

EFF_viol_all(:,1)=basin_hist(:,1); % basin list
EFF_viol_all(:,2)=f_all_normal;% F
EFF_viol_all(:,3)= s_all_normal; % S
EFF_viol_all(:,4)=table2array(Probfinalannualnew(:,4)); % P.shift
EFF_viol_all(:,5)=table2array(Probfinalannualnew(:,3)); % P.stay


% % filter for excluding catchmnets with annual q<10m3/s
Q_nanmean=[nanmean(Qhist_h08_annual,3),nanmean(Qhist_lpjml_annual,3),...
    nanmean(Qhist_pcr_globwb_annual,3),nanmean(Qhist_watergap2_annual,3)];
Q_hist_annual_median=median(Q_nanmean,2,'omitnan');

Q_low_flter=Q_hist_annual_median<10;
Q_hist_annual_median(Q_low_flter,:)=-999;

% removing low flow basins
EFF_viol_all(Q_low_flter,:)=-999;
EFF_viol_all(:,1)=basin_hist(:,1); % basin list

% create a table for convinence
EFF_viol_all_table = table(EFF_viol_all(:,1),EFF_viol_all(:,2),EFF_viol_all(:,3),...
    EFF_viol_all(:,4),EFF_viol_all(:,5),Q_hist_annual_median, 'VariableNames',{'basin_id','F','S','P.shift','P.stay','Q_hist_cm_s'});

% saving
cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_paper_revision\Upper_Lower\Data'
save('EFF_viol_all_table.mat','EFF_viol_all_table');

% STEP 2: Save EFF_viol_all_table as .xls format for ArcGIS
% here it is dataViolation1.xls

% STEP 3: join data in arcgis basin id and plot
% D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\ArcGIS\Mapping50percentileNew.mxd

%% Figure 3 Streamflow vs Violation indices
% plot is created in excel
% MOST LIKELY WILL BE REMOVED FROM MANUSCRIPT



%% Stats for paper

xx=table2array(EFF_viol_all_table(:,2));
filter=xx>=0.25;
Perce_f=(nansum(filter)./nansum(xx~=-999)).*100;

xx=table2array(EFF_viol_all_table(:,3));
filter=xx>=0.25;
Perce_s=(nansum(filter)./nansum(xx~=-999)).*100;

xx=table2array(EFF_viol_all_table(:,4));
filter=xx>=0.5;
Perce_shift=(nansum(filter)./nansum(xx~=-999)).*100;