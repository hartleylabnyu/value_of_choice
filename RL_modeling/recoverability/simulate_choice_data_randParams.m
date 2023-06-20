%% Simulate VoC choices (random parameters) %%
% Simulate data from VoC models
% Kate Nussenbaum - katenuss@gmail.com
% June 2023

function [sim_data] = simulate_choice_data_randParams(sim_num)

%add randomization
RandStream.setGlobalStream(RandStream('mt19937ar','Seed', 'shuffle'));

%add path
addpath('sim_funs');

% set up the right path to load the real data
dataFolder = 'real_data';
subIDs = dir([dataFolder '/*.mat']);
subIDs = {subIDs.name};

%determine num subs
num_subs = 1;

%randomly select one subject and use their trial order
rand_sub = randsample(subIDs, 1);

% load subject data file
load(strcat(dataFolder, filesep, rand_sub{1}));

% get trial information
task_struct.leftBandit = {subjStruct.banditTask.leftBandit}';
task_struct.rightBandit = {subjStruct.banditTask.rightBandit}';
task_struct.offer = [subjStruct.banditTask.tokenOffer]';


% determine how to save the simulated data
save_filename = ['sim_data/sim_data_randParams_sim', int2str(sim_num)];

%determine models to simulate
models = {'oneAlpha_oneBeta', 'oneAlpha_twoBeta', 'twoAlpha_oneBeta', 'twoAlpha_twoBeta', ...
    'oneAlpha_oneBeta_agencyBonus', 'oneAlpha_twoBeta_agencyBonus', 'twoAlpha_oneBeta_agencyBonus', 'twoAlpha_twoBeta_agencyBonus'};


%% initialize structure to store simulation results
sim_data(length(models)) = struct();

%% Task structure
%determine task structure
task_struct.QbanditOrder = { 'bandit50a', 'bandit50b'; ...
    'bandit70', 'bandit30'; ...
    'bandit90', 'bandit10'};

%% Loop through models
for m = 1:length(models)
    model_to_simulate = models{m};
    
    clear model_data;
    model_data(num_subs) = struct();
    
    %print message about which subject is being fit
    fprintf('Simulating model %d out of %d...\n', m, length(models));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % MODELS TO SIMULATE %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %one alpha one beta model
    if strcmp(model_to_simulate, 'oneAlpha_oneBeta')
        alpha = rand(1, num_subs);
        beta = 10*rand(1, num_subs);
        params = [alpha', beta'];
        param_names = {'alpha', 'beta'};
        
    elseif strcmp(model_to_simulate, 'oneAlpha_twoBeta')
        alpha = rand(1, num_subs);
        betaAgency = 10*rand(1, num_subs);
        betaBandit = 10*rand(1, num_subs);
        params = [alpha', betaAgency', betaBandit'];
        param_names = {'alpha', 'betaAgency','betaBandit'};
        
    elseif strcmp(model_to_simulate, 'twoAlpha_oneBeta')
        alphaChoice = rand(1, num_subs);
        alphaComp = rand(1, num_subs);
        beta = 10*rand(1, num_subs);
        params = [alphaChoice', alphaComp', beta'];
        param_names = {'alphaChoice', 'alphaComp', 'beta'};
        
    elseif strcmp(model_to_simulate, 'twoAlpha_twoBeta')
        alphaChoice = rand(1, num_subs);
        alphaComp = rand(1, num_subs);
        betaAgency = 10*rand(1, num_subs);
        betaBandit = 10*rand(1, num_subs);
        params = [alphaChoice', alphaComp', betaAgency', betaBandit'];
        param_names = {'alphaChoice', 'alphaComp', 'betaAgency','betaBandit'};
        
    elseif strcmp(model_to_simulate, 'oneAlpha_oneBeta_agencyBonus')
        alpha = rand(1, num_subs);
        beta = 10*rand(1, num_subs);
        agencyBonus = -1 + 2 .* rand(num_subs,1);
        params = [alpha', beta', agencyBonus];
        param_names = {'alpha', 'beta','agencyBonus'};
        
    elseif strcmp(model_to_simulate, 'oneAlpha_twoBeta_agencyBonus')
        alpha = rand(1, num_subs);
        betaAgency = 10*rand(1, num_subs);
        betaBandit = 10*rand(1, num_subs);
        agencyBonus = -1 + 2 .* rand(num_subs,1);
        params = [alpha', betaAgency', betaBandit', agencyBonus];
        param_names = {'alpha', 'betaAgency','betaBandit','agencyBonus'};
        
    elseif strcmp(model_to_simulate, 'twoAlpha_oneBeta_agencyBonus')
        alphaChoice = rand(1, num_subs);
        alphaComp = rand(1, num_subs);
        beta = 10*rand(1, num_subs);
        agencyBonus = -1 + 2 .* rand(num_subs,1);
        params = [alphaChoice', alphaComp', beta', agencyBonus];
        param_names = {'alphaChoice', 'alphaComp', 'beta','agencyBonus'};
        
    elseif strcmp(model_to_simulate, 'twoAlpha_twoBeta_agencyBonus')
        alphaChoice = rand(1, num_subs);
        alphaComp = rand(1, num_subs);
        betaAgency = 10*rand(1, num_subs);
        betaBandit = 10*rand(1, num_subs);
        agencyBonus = -1 + 2 .* rand(num_subs,1);
        params = [alphaChoice', alphaComp', betaAgency', betaBandit', agencyBonus];
        param_names = {'alphaChoice', 'alphaComp', 'betaAgency','betaBandit','agencyBonus'};
    end
    
    
    % determine function
    function_name = ['sim_', model_to_simulate];
    fh = str2func(function_name);

    %simulate data
    [banditChoiceVec, agencyChoiceVec, outcomeVec, latents] = fh(task_struct, params);
    model_data.params = params;
    model_data.banditChoiceVec = banditChoiceVec;
    model_data.agencyChoiceVec = agencyChoiceVec;
    model_data.leftBandit = task_struct.leftBandit;
    model_data.rightBandit = task_struct.rightBandit;
    model_data.offer = task_struct.offer;
    model_data.outcome = outcomeVec;
    model_data.latents = latents;


sim_data(m).sub_data = model_data;
sim_data(m).function = function_name;
sim_data(m).n_params = size(params, 2);
sim_data(m).param_names = param_names;
end

save(save_filename, 'sim_data');
end
