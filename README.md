# GW-Biodiversity-Project

This repository contains the workflow of Mohan et al. 2022 (in review in HESS). **Poor correlation between large-scale environmental flows violations and global freshwater biodiversity: implications for water resource management and the water planetary boundary**.  Click [here](https://hess.copernicus.org/preprints/hess-2022-87/) for pre print 

The repository will be organised into two folders: 1) EF_violation_estimation, 2) Analysis To access all details of the data used, visit README-Data.md. To access all the final outputs from this project, visit [add dataverse link]

Details of each folder in Code folder is as below

## Preprocessing


## EF_violation_estimation
- **_Script_EFE_state.m_** : Matlab script for extracting EFE_state and calculation violation frequency and severity
- **_importfile.m_** : Matlab function to import numeric data from a text file as a matrix.
- **_importfile2.m_** : Matlab function to import numeric data from a text file as a matrix.
- **_violationEFE.m_** : Matlab function  for calculating the percentage of months with EFE state violation (violation frequency and severity)
- **_R_Script_HMMAnnual_** : R studio script for calculating Probability to shift and Probability to stay

## Analysis
- **_Script_data_Prep.m_** : Matlab script for EFE violation - biodiversity analysis (both lower and upper bound violation) and for prepapring data for plotting in ArcGIS
- **_Script_compare_bio_Su.m_** : Matlab script for comparing the freshwater fish biodiversity facets with EFE violation indicators
- **_fcnMatrixPlots2grp.m_** : This function produces matrix scatterplots of 2 sets of variables (A & B) [modified from John W. Chow's (jchow@mmrcrehab.org) code]
- **_mycorrplot_2.m and mycorrplot_1.m_**: Matlab function to visualize the result of correlation. Detailed Documentation
  https://github.com/weitingwlin/matlabutility/tree/master/documents

    <details><summary> Associated functions of mycorrplot.m </summary> 
  <p>
    
  - plot_circle.m : eazier way to make a circle
  - mycolor.m : function, pick color from a color plates, used in many plotting functions.
  - nancorr.m : calculate correlation coefficient, ignore NaN in each pair
  - tnames.m : show names of variable in a table
    
  </p>
</details>

- **_Script_biome_analysis.m_** : Matlab script for biome based analysis
- **_month_to_annual.m_**: Matlab function to convert from monthly data to annual data
- **_Script_Multi_regr.m_** : Marlab script for conducting multi regression

Note : All file paths in the matlab scripts need to be modified to match the local working directory, when downloaded and used in a local system

# Project description
In this study, the relationship between Environmental Flows violation and freshwater biodiversity is evaluated at the three different spatial scales (level 5 HydroBASIN, ecoregion, global), using four Environmental Flows violation indices (frequency, severity, probability to move to a violated state, and probability to stay violated) and nine freshwater biodiversity indicators describing taxonomic, functional, and phylogenetic dimensions of the biodiversity.

# Authors
Chinchu Mohan, Tom Gleeson, James S Famiglietti, Vili Virkki, Matti Kummu, Miina Porkka, Lan Wang-Erlandsson, Xander Huggins, Dieter Gerten, Sonja C Jähnig

# How to cite 
Mohan, C., Gleeson, T., Famiglietti, J. S., Virkki, V., Kummu, M., Porkka, M., Wang-Erlandsson, L., Huggins, X., Gerten, D., and Jähnig, S. C.: Poor correlation between large-scale environmental flow violations and freshwater biodiversity: implications for water resource management and water planetary boundary, Hydrol. Earth Syst. Sci. Discuss. [preprint], https://doi.org/10.5194/hess-2022-87, in review, 2022.

# Contact
If there are any queries, please contact Chinchu Mohan chinchu.mohan@usask.ca

# Last update
July-05-2022
