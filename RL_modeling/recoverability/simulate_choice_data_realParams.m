%% Simulate choices %%
% Simulate data based on subjects' best-fitting parameters
% KN - 6/9/23

clear all;
clc;

%add randomization
rng('shuffle');

%add paths
addpath('sim_funs');

% set up the right path to load the real data
dataFolder = 'real_data';
subIDs = dir([dataFolder '/*.mat']);
subIDs = {subIDs.name};

%determine num subs
num_subs = length(subIDs);

%determine number of times to repeat each subject
num_reps = 50;

% determine how to save the simulated data
save_filename = 'sim_data/sim_data_realParams_16models';

%determine models to simulate
models = {'oneAlpha_oneBeta', 'oneAlpha_twoBeta', 'twoAlpha_oneBeta', 'twoAlpha_twoBeta', ...
        'twoAlphaValenced_oneBeta', 'twoAlphaValenced_twoBeta', 'fourAlpha_oneBeta', 'fourAlpha_twoBeta', ...
    'oneAlpha_oneBeta_agencyBonus', 'oneAlpha_twoBeta_agencyBonus', 'twoAlpha_oneBeta_agencyBonus', 'twoAlpha_twoBeta_agencyBonus', ...
    'twoAlphaValenced_oneBeta_agencyBonus', 'twoAlphaValenced_twoBeta_agencyBonus', 'fourAlpha_oneBeta_agencyBonus', 'fourAlpha_twoBeta_agencyBonus' };

%% initialize structure to store simulation results
sim_data(length(models)) = struct();

%% Task structure
%determine task structure
task_struct.QbanditOrder = { 'bandit50a', 'bandit50b'; ...
    'bandit70', 'bandit30'; ...
    'bandit90', 'bandit10'};

%% Load model fits
model_fits = load(['../output/all_16_models']);

%% Loop through models
for m = 1:length(models)
    model_to_simulate = models{m};
    model_params = model_fits.model_fits(m).results.params;
    
    clear model_data;
    model_data(num_subs * num_reps) = struct();
    
    %print message about which model is being fit
    fprintf('Simulating model %d out of %d...\n', m, length(models));
    
    % determine simulation function
    function_name = ['sim_', model_to_simulate];
    fh = str2func(function_name);
    
    
    %% Loop through subjects
    for r = 1:num_reps
         
        %print message about which repetition is being fit
        fprintf('On repetition %d out of %d...\n', r, num_reps);
    
        for s = 1:num_subs
            subject = subIDs{s};
            
            % load subject data file
            load(strcat(dataFolder, filesep, subject));
            
            % get trial information
            task_struct.leftBandit = {subjStruct.banditTask.leftBandit}';
            task_struct.rightBandit = {subjStruct.banditTask.rightBandit}';
            task_struct.offer = [subjStruct.banditTask.tokenOffer]';
            
            % get subject parameters
            sub_params = model_params(s, :);
            
            %simulate data
            [banditChoiceVec, agencyChoiceVec, outcomeVec, latents] = fh(task_struct, sub_params);
            model_data(s + (r-1)*num_subs).params = sub_params;
            model_data(s + (r-1)*num_subs).banditChoiceVec = banditChoiceVec;
            model_data(s + (r-1)*num_subs).agencyChoiceVec = agencyChoiceVec;
            model_data(s + (r-1)*num_subs).leftBandit = task_struct.leftBandit;
            model_data(s + (r-1)*num_subs).rightBandit = task_struct.rightBandit;
            model_data(s + (r-1)*num_subs).offer = task_struct.offer;
            model_data(s + (r-1)*num_subs).outcome = outcomeVec;
            model_data(s + (r-1)*num_subs).latents = latents;
            model_data(s + (r-1)*num_subs).subID = subject;
        end
    end
    

    sim_data(m).sub_data = model_data;
    sim_data(m).function = function_name;
    sim_data(m).n_params = size(sub_params, 2);
    %sim_data(m).param_names = param_names;
    
end


save(save_filename, 'sim_data', '-v7.3');

