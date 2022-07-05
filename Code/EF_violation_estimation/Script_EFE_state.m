% Script for extracting EFE_state and calculation violation frequency and
% severity


% Script for extracting EFE data
% Definition of EFE_state: Comparison between historical discharge and EFEs defined by the pi
%   period. EFE state given for each month 1976-2005. Values below 0 indicate
%   EFE violation of lower bound, values above 100 indicate EFE violation of
%   upper bound, and values in [0, 100] indicate that discharge is within EFE
% 
% Data Details:
%       Temporal scale: monthly
%       Spatial scale: level 5 hydrobasin
%       Temporal range:
%           historical: 1976-2005
%
% Data includes medians for each GHM computed over all GCMs
% GHMs used: H08, LPJmL, PCR GLOBWB, WaterGAP2
% GCMs used: GFDL-ESM2M, HadGEM2-ES, IPSL-CM5A-LR, MICROC5

% Data source: Matti Kummu's Lab group

% Related publication
% Virkki, Vili, Elina Alanärä, Miina Porkka, Lauri Ahopelto, Tom Gleeson, 
% Chinchu Mohan, Lan Wang-Erlandsson et al. "Globally widespread and increasing 
% violations of environmental flow envelopes." Hydrology and Earth System Sciences 
% 26, no. 12 (2022): 3315-3336.
% 
% Code written by: Chinchu Mohan
% contact: chinchu.mohan@usask.ca

%%

clear all
close all
clc

% h08
EFE_state_h08_1976_2005(:,:)=importfile...
    ('h08_EFE_state_monthly.csv',2, 4377); 

EFE_state_lpjml_1976_2005(:,:)=importfile...
    ('lpjml_EFE_state_monthly.csv',2, 4377); 

EFE_state_pcr_globwb_1976_2005(:,:)=importfile...
    ('pcr_globwb_EFE_state_monthly.csv',2, 4377); 

EFE_state_watergap2_1976_2005(:,:)=importfile...
    ('watergap2_EFE_state_monthly.csv',2, 4377); 

% Basin variable consists of the basin codes in col1, 
% outletX in col2, outletY in col3

basin_hist = importfile2('watergap2_EFE_state_monthly.csv',2,4377);

% saving a copy of original EFE stste data
cd('D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData');
save('EFE_state_original.mat');
% % cd('C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\HMM_RStudio')
% % save('EFE_state_original.mat');

cd('C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\csv\hist\EFE_state');

% calc percentage annual violation
EFE_state=EFE_state_h08_1976_2005;
[violation_annual_h08_1976_2005, violation_annual_s_h08_1976_2005] = violationEFE (EFE_state);


EFE_state=EFE_state_lpjml_1976_2005;
[violation_annual_lpjml_1976_2005,violation_annual_s_lpjml_1976_2005] = violationEFE (EFE_state);

EFE_state=EFE_state_pcr_globwb_1976_2005;
[violation_annual_pcr_globwb_1976_2005,violation_annual_s_pcr_globwb_1976_2005] = violationEFE (EFE_state);

EFE_state=EFE_state_watergap2_1976_2005;
[violation_annual_watergap2_1976_2005,violation_annual_s_watergap2_1976_2005] = violationEFE (EFE_state);

% EFE_state_violation_freq
cd('C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData');
save('EFE_state_violationfreq.mat', 'violation_annual_h08_1976_2005','violation_annual_lpjml_1976_2005',...
    'violation_annual_pcr_globwb_1976_2005','violation_annual_watergap2_1976_2005');
save('EFE_state_violationsever.mat', 'violation_annual_s_h08_1976_2005','violation_annual_s_lpjml_1976_2005',...
    'violation_annual_s_pcr_globwb_1976_2005','violation_annual_s_watergap2_1976_2005');

clear EFE_state;

cd('C:\Dropbox\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData');
save ('EFE_state_violation_1976_2005.mat');

