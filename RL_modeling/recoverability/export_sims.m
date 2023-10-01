%% Export simulations %%
% Export simulated data for plotting posterior predictive checks in R
% KN - 6/9/23

clear all;
clc;

%% Load simulated data %%
sim_data = load('sim_data/sim_data_realParams_16models');
sim_data = sim_data.sim_data;

%% Export each model as csv file %%

for m = 1:size(sim_data, 2)
    model_name = sim_data(m).function(5:end);
    for rep = 1:50*92
        model_data = sim_data(m).sub_data(rep);
        subID = repelem({model_data.subID}, length(model_data.leftBandit))';
        simID = rep .* ones(length(model_data.leftBandit), 1);
        leftBandit = model_data.leftBandit;
        rightBandit = model_data.rightBandit;
        offer = model_data.offer;
        agencyChoice = model_data.agencyChoiceVec;
        banditChoice = model_data.banditChoiceVec;
        outcome = model_data.outcome;
        model_data_table = table(subID, simID, leftBandit, rightBandit, offer, agencyChoice, banditChoice, outcome);
        if rep == 1
           big_table = model_data_table;
        else
           big_table = [big_table; model_data_table];
        end
    end
    writetable(big_table, ['../output/posterior_predictive/simData_subParams_', model_name, '.csv']);
    clear big_table;
    clear model_data_table;
end
    
    
    
    