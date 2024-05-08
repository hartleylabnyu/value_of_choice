# Sensitivity to the instrumental value of choice increases across development
Tasks, anonymized data, and analysis code for: Nussenbaum, K.+, Katzman, P.L.+, Lu, H., Zorowitz, S., & Hartley, C.A. (in press). [*Sensitivity to the instrumental value of choice increases across development*](https://osf.io/preprints/psyarxiv/exps6). *Psychological Science.*

Please contact katenuss@gmail.com with questions.

## Experiment 1

### Task
We collected data from 92 participants on a probabilistic reinforcement-learning task across contexts in which the instrumental value of choice varied. The task can be run via Psychtoolbox-3 in Matlab Version 2019. Compatability with other Matlab versions has not been tested.

### Data and analysis code
Raw and processed data is located within the 'data' folder. Data were analyzed in R (version 4.3.1) using the R markdown analysis scripts found in the analysis_scripts folder. The analysis scripts are designed to be run from within an R project located within the main 'Experiment 1' folder. To reproduce the results reported in the manuscript from the raw data:

1. Run 1_voc_process_data.Rmd. This will import and concatenate participants' raw task data, perform a few simple processing steps, and save three csv files with all participants' data from the three parts of the task (reinforcement learning, reward sensitivity, explicit knowledge). 

2. Run 2_voc_regression_analyses.Rmd. This will use the processed csv files from step 1 to implement all of the analyses described in the manuscript (main text and supplement) that do not rely on the fitted reinforcement-learning models. 

3. The remainder of the R markdown scripts rely on output from computational model-fitting, which was performed in Matlab (version 2020b). Model-fitting output (i.e., model fits and parameter estimates) are saved within the repository so these scripts can be run without re-doing the computational model-fitting. However, we have also included all necessary code and data (within the RL_modeling folder) to perform the modeling analyses beginning with the raw data. To perform model-fitting:
+ Run 'voc_fit_real_data.m'. This script was written for Matlab 2020b, though it likely is compatible with other versions of Matlab as well (but has not been tested with them). The script relies on the fmincon function within the optimization toolbox. This will: import the raw data saved in matfiles (in the data folder), and fit each participant's data with the 16 tested models. For each participant, it will perform 100 iterations of model-fitting and save the best result across them (though the number of iterations can easily be changed). It will save a matfile and csv file of model fits for each of the 16 models (in the output folder).
+ Run 'model_comparison.m'. This will export a single csv file containing the AIC values for all tested models.
+ The 'recoverability' folder contains all the scripts needed to reproduce the model and parameter recoverability analyses, as well as to conduct posterior predictive checks. These analyses are computationally demanding and cannot be run within a reasonable timeframe on a single, personal computer. They were originally run on a high-performance computing cluster. There are two simulation scripts: simulated_choice_data_spacedParams, which generates simulations with random parameters (with constraints reported in the manuscript), and simulate_choice_data_subParams, which generates simulations with the specific parameters that best-captured individual participants' choices. The former is used for model and parameter recovery analyses, while the latter is used for posterior predictive checks. 'Fit_simulated_data_spaced' will fit the simulations generated from all 16 models with all 16 models (e.g., 16 x 16 fits per simulation number, which is why this takes a long time). The model_recovery and parameter_recovery scripts will export csv files with the necessary information about model fits and fitted parameters for subsequent analyses in R. 

4. After model-fitting has been conducted, the R markdown file 3_voc_RL.Rmd can be run, which reproduces the reinforcement-learning modeling results reported in the manuscript.

5. Finally, analysis scripts 4 and 5 will reproduce the recoverability analyses and posterior predictive checks.

#### Demographics and raw survey data
Raw survey data and detailed demographic data is not included in the repository to protect participant confidentiality. 

## Experiment 2

### Task
We collected data from 150 participants on an online version of the same probabilistic reinforcement-learning task as in Experiment 1. The task was coded in jsPsych (version 6.1.0) and hosted online via Pavlovia. 

### Data and analysis code
Raw and processed data is located within the 'data' folder. Data were analyzed in R (version 4.3.1) using the R markdown analysis scripts found in the analysis_scripts folder. The analysis scripts are designed to be run from within an R project located within the main 'Experiment 2' folder. To reproduce the results reported in the manuscript from the raw data:

1. Run e2_1_voc_process_data.Rmd. This will import and concatenate participants' raw task data, perform a few simple processing steps, and save three csv files with all participants' data from the two parts of the task (reinforcement learning, explicit knowledge) as well as a csv file with formatted data for the RL model-fitting. 

2. Run e2_2_voc_regression_analyses.Rmd. This will use the processed csv files from step 1 to implement all of the analyses described in the manuscript (main text and supplement) that do not rely on the fitted reinforcement-learning models. 

3. The third and final R markdown script relies on output from computational model-fitting, which was performed in Matlab (version 2020b). Model-fitting output (i.e., model fits and parameter estimates) are saved within the repository so these scripts can be run without re-doing the computational model-fitting. However, as we did for Experiment 1, we have also included all necessary code and data (within the RL_modeling folder) to perform the modeling analyses beginning with the raw data. To perform model-fitting:
+ Run 'voc_e2_fit_real_data.m'.  The script relies on the fmincon function within the optimization toolbox. This will: import the rl_data csv file that was created in step 1 and fit each participant's data with the 16 tested models. For each participant, it will perform 100 iterations of model-fitting and save the best result across them (though the number of iterations can easily be changed). It will save a matfile and csv file of model fits for each of the 16 models (in the output folder).
+ Run 'e2_model_comparison.m'. This will export a single csv file containing the AIC values for all tested models.

4. After model-fitting has been conducted, the R markdown file e2_3_voc_RL.Rmd can be run, which reproduces the reinforcement-learning modeling results reported in the manuscript.

5. Finally, in the supplement, we report analyses on both the full set of participants (as was preregistered) and also on a filtered dataset, in which participants who made more than 300 of the same first-stage choices were excluded. The repository contains versions of the regression and RL analysis markdown files that applies this exclusion.

#### Demographics 
Detailed demographic data is not included in the repository to protect participant confidentiality. 
