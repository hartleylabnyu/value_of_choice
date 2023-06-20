%% Model recovery %%
% KN - 6/6/23

clear all;

%% Load data %%
load('sim_model_fits/all_model_fits_spaced.mat');

%% Extract AICs for each data set and each model %%

%initialize
best_models_aic = [];
best_models_bic = [];

for dataset = 1:size(all_model_fits, 1)
    dataset_aics = [];
    dataset_bics = [];
    for model = 1:size(all_model_fits, 2)
        dataset_aics = [dataset_aics, all_model_fits(dataset, model).results.AIC];
        [x, dataset_aic_index] = min(dataset_aics, [], 2);
        dataset_bics = [dataset_bics, all_model_fits(dataset, model).results.BIC];
        [x, dataset_bic_index] = min(dataset_bics, [], 2);
    end
    best_models_aic = [best_models_aic, dataset_aic_index];
    best_models_bic = [best_models_bic, dataset_bic_index];
end


%% Plot proportion of times simulated and recovered match
% first, get model names
for dataset = 1:size(all_model_fits, 2)
    model_name{dataset} = all_model_fits(dataset, 1).sim_model(5:end);
end

%% AIC heatmap

% Determine frequencies
% For each dataset (column), determine the proportion of each model
for m = 1:8
    aic_sums(m, :) = sum(best_models_aic == m);
    aic_props = aic_sums ./ 1000;
    bic_sums(m, :) = sum(best_models_bic == m);
    bic_props = bic_sums ./ 1000;
end


 aic_table = array2table(aic_props, 'VariableNames', model_name);
 aic_table.RecoveredModel = model_name';
 bic_table = array2table(bic_props, 'VariableNames', model_name);
 bic_table.RecoveredModel = model_name';     
 

figure;
subplot(2,2,1)
h = heatmap(round(aic_props, 2));
h.YDisplayLabels = model_name;
h.XDisplayLabels = model_name;
title('Confusion Matrix: AIC');
set(gca,'FontSize',14)
colorbar off

subplot(2,2,2)
h = heatmap(round(bic_props, 2));
h.YDisplayLabels = model_name;
h.XDisplayLabels = model_name;
title('Confusion Matrix: BIC');
set(gca,'FontSize',14)
colorbar off

%% Inversion Matrix Plot %%

%Determine p(sim_model | recovered_model)
inversion_aic_row_sums = sum(aic_sums, 2);
inversion_bic_row_sums = sum(bic_sums, 2);

inversion_aic = aic_sums ./ inversion_aic_row_sums;
inversion_bic = bic_sums ./ inversion_bic_row_sums;


subplot(2,2,3);
h = heatmap(round(inversion_aic, 2));
h.YDisplayLabels = model_name;
h.XDisplayLabels = model_name;
title('Inversion Matrix: AIC');
set(gca,'FontSize',14)
colorbar off

subplot(2,2,4)
h = heatmap(round(inversion_bic, 2));
h.YDisplayLabels = model_name;
h.XDisplayLabels = model_name;
title('Inversion Matrix: BIC');
set(gca,'FontSize',14)
colorbar off
colorbar off;

%% export bics
writetable(bic_table, '../output/bic_recovery.csv');
writetable(aic_table, '../output/aic_recovery.csv');
