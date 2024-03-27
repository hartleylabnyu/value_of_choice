%% Export sub IDs

%load data
clear all;
load('output/all_16_models_100iter');

%get list of subjects
sub_IDs = model_fits(16).results(1).sub;

%save to csv
T = cell2table(sub_IDs', 'VariableNames', {'subID'});
writetable(T,'output/subIDs.csv')