%% VoC Parameter recovery %%
% Analyze parameter recoverability for best-fitting VoC model 
% (model 8: twoAlpha_twoBeta_agencyBonus)
% Kate Nussenbaum - katenuss@gmail.com
% June 2023

%% Load data %%
clear all;

%simulated data
load('sim_data/all_sim_data_spaced.mat');

%model fits
load('sim_model_fits/all_model_fits_spaced.mat');

%% Get simulated and recovered parameters from best model (8)

sim_params = zeros(size(all_model_fits(8,8).results.params));
fit_params = zeros(size(all_model_fits(8,8).results.params));

for s = 1:length(all_sim_data(8).sub_data)
    sim_params(s, :) = all_sim_data(8).sub_data(s).params;
    fit_params(s, :) = all_model_fits(8, 8).results.params(s, :);
end
%% Plot
figure;
n_params = all_sim_data(8).n_params;
param_names = all_sim_data(8).param_names;

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


writetable(sim_params_table, '../output/twoAlpha_twoBeta_agencyBonus_sim_params.csv');
writetable(fit_params_table, '../output/twoAlpha_twoBeta_agencyBonus_fit_params.csv')

