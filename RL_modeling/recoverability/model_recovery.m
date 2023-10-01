%% Model recovery %%
% KN - 6/6/23

clear all;

%% Load data %%
load('all_model_fits_spaced.mat');
num_models = 16;

%% Extract AICs for each data set and each model %%

%initialize
best_models_aic = [];
best_models_bic = [];
mean_AICs = [];
mean_BICs = [];

for dataset = 1:size(all_model_fits, 1)
    dataset_aics = [];
    dataset_bics = [];
    for model = 1:size(all_model_fits, 2)

        %get AICs and BICs for each model
        dataset_aics = [dataset_aics, all_model_fits(dataset, model).results.AIC];
        dataset_bics = [dataset_bics, all_model_fits(dataset, model).results.BIC];
        
    end
    
    %determine best model for each dataset
    [x, dataset_aic_index] = min(dataset_aics, [], 2); %determine min AIC in each row
    [x, dataset_bic_index] = min(dataset_bics, [], 2); %determine min BIC in each row
    best_models_aic = [best_models_aic, dataset_aic_index];
    best_models_bic = [best_models_bic, dataset_bic_index];
    
    %determine mean AIC and BIC for each model for each dataset
    mean_dataset_AICs = mean(dataset_aics)';
    mean_dataset_BICs = mean(dataset_bics)';
    mean_AICs = [mean_AICs, mean_dataset_AICs];
    mean_BICs = [mean_BICs, mean_dataset_BICs];
    
end


%% Plot proportion of times simulated and recovered match
% first, get model names
for dataset = 1:size(all_model_fits, 2)
    model_name{dataset} = all_model_fits(dataset, 1).sim_model(5:end);
end

%% AIC heatmap

% Determine frequencies
% For each dataset (column), determine the proportion of each model
for m = 1:num_models
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
subplot(1,3,1)
h = heatmap(round(aic_props, 2));
h.YDisplayLabels = model_name;
h.XDisplayLabels = model_name;
title('Confusion Matrix: AIC');
set(gca,'FontSize', 8)
colorbar off

subplot(1,3,3)
h = heatmap(round(mean_AICs, 0));
h.YDisplayLabels = model_name;
h.XDisplayLabels = model_name;
h.ColorScaling = 'scaledcolumns';
title('Mean AIC');
set(gca,'FontSize', 8)
colorbar off

% subplot(2,2,2)
% h = heatmap(round(bic_props, 2));
% h.YDisplayLabels = model_name;
% h.XDisplayLabels = model_name;
% title('Confusion Matrix: BIC');
% set(gca,'FontSize',14)
% colorbar off

% Inversion Matrix Plot %

%Determine p(sim_model | recovered_model)
inversion_aic_row_sums = sum(aic_sums, 2);
inversion_bic_row_sums = sum(bic_sums, 2);

inversion_aic = aic_sums ./ inversion_aic_row_sums;
inversion_bic = bic_sums ./ inversion_bic_row_sums;


subplot(1,3,2);
h = heatmap(round(inversion_aic, 2));
h.YDisplayLabels = model_name;
h.XDisplayLabels = model_name;
title('Inversion Matrix: AIC');
set(gca,'FontSize', 8)
colorbar off

% subplot(2,2,4)
% h = heatmap(round(inversion_bic, 2));
% h.YDisplayLabels = model_name;
% h.XDisplayLabels = model_name;
% title('Inversion Matrix: BIC');
% set(gca,'FontSize',14)
% colorbar off
% colorbar off;

%% export a
writetable(bic_table, '../output/bic_recovery_16models.csv');
writetable(aic_table, '../output/aic_recovery_16models.csv');
