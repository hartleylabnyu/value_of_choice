# Sensitivity to the instrumental value of control increases across development
Tasks, anonymized data, and analysis code for: *Sensitivity to the instrumental value of control increases across development*

## Task
We collected data from 92 participants on a probabilistic reinforcement-learning task across contexts in which the instrumental value of control varied.The task can be run via Psychtoolbox-3 in Matlab Version 2019. Compatability with other Matlab versions has not been tested.

## Data
Cleaned data used for regression analyses and scored survey data can be found in the data folder.
Raw data used for the reinforcement-learning modeling (stored in mat files) can be found in the RL_modeling/data folder. 

## Analysis code
Processed data was analyzed in R using the R markdown analysis scripts found in the analysis_scripts folder. 
Some of the files used for the posterior predictive checks are not included in this repository due to file size limits, but they can be re-generated using simulation scripts included in the RL_modeling folder. 

## Computational modeling
Computational models were fit via the fmincon function in the optimizaiton toolbox in Matlab 2020b. 