%% Compare models: VoC %%
% Kate Nussenbaum - katenuss@nyu.edu

%clear
clear

%determine name of comparison set
data_name = 'all_16_models_100iter';

% determine names for data saving
aic_filename = ['output/aics_', data_name, '.csv'];
bic_filename = ['output/bics_', data_name, '.csv'];

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

%% Extract AICs and BICs for each model %%

%initialize
model_aics = [];
model_bics = [];

for model = 1:length(model_fits)
    model_aics = [model_aics, model_fits(model).results.AIC];
    model_bics = [model_bics, model_fits(model).results.BIC];
end

% make table
aic_table = array2table(model_aics, 'VariableNames', model_name);
aic_table = addvars(aic_table, subID, 'Before', 1);
bic_table = array2table(model_bics, 'VariableNames', model_name);
bic_table = addvars(bic_table, subID, 'Before', 1);

%write csvs to save AICs
writetable(aic_table, aic_filename);
writetable(bic_table, bic_filename);











