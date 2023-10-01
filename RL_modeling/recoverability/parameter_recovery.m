%% Parameter recovery %%
clear all;
%% Load data %%

%simulated data
load('all_sim_data_spaced.mat');

%model fits
load('all_model_fits_spaced.mat');

%determine model num
model_num = 16;

%% Get simulated and recovered parameters from best model (model_num)

sim_params = zeros(size(all_model_fits(model_num, model_num).results.params));
fit_params = zeros(size(all_model_fits(model_num, model_num).results.params));

for s = 1:length(all_sim_data(model_num).sub_data)
    sim_params(s, :) = all_sim_data(model_num).sub_data(s).params;
    fit_params(s, :) = all_model_fits(model_num, model_num).results.params(s, :);
end
%% Plot
figure;
n_params = all_sim_data(model_num).n_params;
param_names = all_sim_data(model_num).param_names;

for p = 1:n_params
    subplot(1, n_params, p); %new subplot for each parameter
    scatter(sim_params(:, p), fit_params(:, p), 10, 'MarkerFaceColor', [102 102 255]./255, 'MarkerEdgeColor', 'k');
    P = polyfit(sim_params(:, p), fit_params(:, p), 1);
    yfit = P(1)*sim_params(:, p)+P(2);
    hold on;
    plot(sim_params(:, p),yfit,'k-.', 'LineWidth', 3);
    title([param_names(p), round(P(1), 2)], 'Interpreter', 'none');
    set(gca, 'FontSize', 12);
end

%% save sim_params and fit_params
sim_params_table = array2table(sim_params, 'VariableNames', param_names);
fit_params_table = array2table(fit_params, 'VariableNames', param_names);


writetable(sim_params_table, '../output/fourAlpha_twoBeta_agencyBonus_sim_params.csv');
writetable(fit_params_table, '../output/fourAlpha_twoBeta_agencyBonus_fit_params.csv')

