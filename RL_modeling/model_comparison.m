%% Compare models: VoC %%
% March 2023
% Kate Nussenbaum
% % katenuss@gmail.com

%%
%clear
clear

% determine names for data saving
aic_filename = 'output/aics_all.csv';
bic_filename = 'output/bics_all.csv';

% Load model fits
load('output/all_model_fits');

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

% make tables
aic_table = array2table(model_aics, 'VariableNames', model_name);
aic_table = addvars(aic_table, subID, 'Before', 1);

bic_table = array2table(model_bics, 'VariableNames', model_name);
bic_table = addvars(bic_table, subID, 'Before', 1);

%write csvs to save AICs and BICs
writetable(aic_table, aic_filename);
writetable(bic_table, bic_filename);

%find best-fitting model
[~, best_model_aic] = min(model_aics, [], 2);
[~, best_model_bic] = min(model_bics, [], 2);


%% PLOT MEAN AND MEDIAN AIC AND BIC VALUES %%
%-------------------------------------------------------------------------------%
% STEP 1: Compute mean and median AIC and BIC values for each dataset and model %
%-------------------------------------------------------------------------------%

%initialize matrices
mean_aic = NaN(size(model_fits));
med_aic = NaN(size(model_fits));
mean_bic = NaN(size(model_fits));
med_bic = NaN(size(model_fits));

for model = 1:size(model_fits, 2)
    mean_aic(model) = mean(model_fits(model).results.AIC);
    med_aic(model) = median(model_fits(model).results.AIC);
    mean_bic(model) = mean(model_fits(model).results.BIC);
    med_bic(model) = median(model_fits(model).results.BIC);
end


%----------------------------------------------%
% STEP 2: % Plot mean and median AICs and BICs %
%----------------------------------------------%

figure;
subplot(2,2,1)
b = bar(mean_aic, 'EdgeColor','black', 'LineWidth', 1);
set(gca, 'xticklabel', model_name);
set(gca,'FontName','Helvetica','FontSize',16);
xlabel('Model','FontSize',18);
ylabel('Mean AIC', 'FontSize', 18);
ylim([min(mean_aic) - 5, max(mean_aic) + 5]);


subplot(2,2,2)
b = bar(med_aic, 'EdgeColor','black', 'LineWidth', 1);
set(gca, 'xticklabel', model_name);
set(gca,'FontName','Helvetica','FontSize',16);
xlabel('Model','FontSize',18);
ylabel('Median AIC', 'FontSize', 18);
ylim([min(med_aic) - 5, max(med_aic) + 5]);

subplot(2,2,3)
b = bar(mean_bic, 'EdgeColor','black', 'LineWidth', 1);
set(gca, 'xticklabel',model_name);
set(gca,'FontName','Helvetica','FontSize',16);
xlabel('Model','FontSize',18);
ylabel('Mean BIC', 'FontSize', 18);
ylim([min(mean_bic) - 5, max(mean_bic) + 5]);


subplot(2,2,4)
b = bar(med_bic, 'EdgeColor','black', 'LineWidth', 1);
set(gca, 'xticklabel',model_name);
set(gca,'FontName','Helvetica','FontSize',16);
xlabel('Model','FontSize',18);
ylabel('Median BIC', 'FontSize', 18);
ylim([min(med_bic) - 5, max(med_bic) + 5]);

