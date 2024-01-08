%% Compare models: VoC E2 %%
% Kate Nussenbaum - katenuss@nyu.edu

%clear
clear

%determine name of comparison set
data_name = 'all_16_models_100iter';

% determine names for data saving
aic_filename = ['output/aics_', data_name, '.csv'];

% Load model fits
load(['output/', data_name]);

%Determine number of models
num_models = length(model_fits);

%% Get model names
for m = 1: length(model_fits)
    model_name{m} = model_fits(m).fit_model;
end

%% Get subject IDs
subID = model_fits(1).results.sub';

%% Extract AICs for each model %%

%initialize
model_aics = [];

for model = 1:length(model_fits)
    model_aics = [model_aics, model_fits(model).results.AIC];
end

% make table
aic_table = array2table(model_aics, 'VariableNames', model_name);
aic_table = addvars(aic_table, subID, 'Before', 1);

%write csvs to save AICs and BICs
writetable(aic_table, aic_filename);

