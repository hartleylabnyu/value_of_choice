%% Simulate VoC choices (spaced parameters) %%
% Simulate data from VoC models while imposing constraints on parameter
% spacing
% June 2023
% Kate Nussenbaum - katenuss@gmail.com

%%
function [sim_data] = simulate_choice_data_spacedParams(sim_num)

%add randomization
RandStream.setGlobalStream(RandStream('mlfg6331_64','Seed', sim_num));

%add paths
addpath('sim_funs');

%determine the minimum spacing between alpha and beta parameters
beta_space = 3;
alpha_space = .3;
max_attempts = 1000;

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
save_filename = ['sim_data/sim_data_spacedParams_sim', int2str(sim_num)];

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
        beta_diff = abs(betaAgency - betaBandit);
        c = 0;
        while beta_diff < beta_space && c < max_attempts
            betaAgency = 10*rand(1, num_subs);
            betaBandit = 10*rand(1, num_subs);
            beta_diff = abs(betaAgency - betaBandit);
            c = c+1;
        end
        params = [alpha', betaAgency', betaBandit'];
        param_names = {'alpha', 'betaAgency','betaBandit'};
        
    elseif strcmp(model_to_simulate, 'twoAlpha_oneBeta')
        alphaChoice = rand(1, num_subs);
        alphaComp = rand(1, num_subs);
        alpha_diff = abs(alphaChoice - alphaComp);
        c = 0;
        while alpha_diff < alpha_space && c < max_attempts
            alphaChoice = rand(1, num_subs);
            alphaComp = rand(1, num_subs);
            alpha_diff = abs(alphaChoice - alphaComp);
            c = c+1;
        end
        beta = 10*rand(1, num_subs);
        params = [alphaChoice', alphaComp', beta'];
        param_names = {'alphaChoice', 'alphaComp', 'beta'};
        
    elseif strcmp(model_to_simulate, 'twoAlpha_twoBeta')
        alphaChoice = rand(1, num_subs);
        alphaComp = rand(1, num_subs);
        alpha_diff = abs(alphaChoice - alphaComp);
        c = 0;
        while alpha_diff < alpha_space && c < max_attempts
            alphaChoice = rand(1, num_subs);
            alphaComp = rand(1, num_subs);
            alpha_diff = abs(alphaChoice - alphaComp);
            c = c+1;
        end
        betaAgency = 10*rand(1, num_subs);
        betaBandit = 10*rand(1, num_subs);
        beta_diff = abs(betaAgency - betaBandit);
        c = 0;
        while beta_diff < beta_space && c < max_attempts
            betaAgency = 10*rand(1, num_subs);
            betaBandit = 10*rand(1, num_subs);
            beta_diff = abs(betaAgency - betaBandit);
            c = c+1;
        end
        params = [alphaChoice', alphaComp', betaAgency', betaBandit'];
        param_names = {'alphaChoice', 'alphaComp', 'betaAgency','betaBandit'};
        
    elseif strcmp(model_to_simulate, 'oneAlpha_oneBeta_agencyBonus')
        alpha = rand(1, num_subs);
        beta = 10*rand(1, num_subs);
        agencyBonus = -.5 + 1 .* rand(num_subs, 1);
	while abs(agencyBonus) < .1 && c < max_attempts
		agencyBonus = -.5 + 1 .* rand(num_subs, 1);
		c = c+1;
	end
        params = [alpha', beta', agencyBonus];
        param_names = {'alpha', 'beta','agencyBonus'};
        
    elseif strcmp(model_to_simulate, 'oneAlpha_twoBeta_agencyBonus')
        alpha = rand(1, num_subs);
        betaAgency = 10*rand(1, num_subs);
        betaBandit = 10*rand(1, num_subs);
        beta_diff = abs(betaAgency - betaBandit);
        c = 0;
        while beta_diff < beta_space && c < max_attempts
            betaAgency = 10*rand(1, num_subs);
            betaBandit = 10*rand(1, num_subs);
            beta_diff = abs(betaAgency - betaBandit);
            c = c+1;
        end
         agencyBonus = -.5 + 1 .* rand(num_subs, 1);
        while abs(agencyBonus) < .1 && c < max_attempts
                agencyBonus = -.5 + 1 .* rand(num_subs, 1);
                c = c+1;
        end
	params = [alpha', betaAgency', betaBandit', agencyBonus];
        param_names = {'alpha', 'betaAgency','betaBandit','agencyBonus'};
        
    elseif strcmp(model_to_simulate, 'twoAlpha_oneBeta_agencyBonus')
        alphaChoice = rand(1, num_subs);
        alphaComp = rand(1, num_subs);
        alpha_diff = abs(alphaChoice - alphaComp);
        c = 0;
        while alpha_diff < alpha_space && c < max_attempts
            alphaChoice = rand(1, num_subs);
            alphaComp = rand(1, num_subs);
            alpha_diff = abs(alphaChoice - alphaComp);
            c = c+1;
        end
        beta = 10*rand(1, num_subs);
         agencyBonus = -.5 + 1 .* rand(num_subs, 1);
        while abs(agencyBonus) < .1 && c < max_attempts
                agencyBonus = -.5 + 1 .* rand(num_subs, 1);
                c = c+1;
        end
	params = [alphaChoice', alphaComp', beta', agencyBonus];
        param_names = {'alphaChoice', 'alphaComp', 'beta','agencyBonus'};
        
    elseif strcmp(model_to_simulate, 'twoAlpha_twoBeta_agencyBonus')
        alphaChoice = rand(1, num_subs);
        alphaComp = rand(1, num_subs);
        alpha_diff = abs(alphaChoice - alphaComp);
        c = 0;
        while alpha_diff < alpha_space && c < max_attempts
            alphaChoice = rand(1, num_subs);
            alphaComp = rand(1, num_subs);
            alpha_diff = abs(alphaChoice - alphaComp);
            c = c+1;
        end
        betaAgency = 10*rand(1, num_subs);
        betaBandit = 10*rand(1, num_subs);
        beta_diff = abs(betaAgency - betaBandit);
        c = 0;
        while beta_diff < beta_space && c < max_attempts
            betaAgency = 10*rand(1, num_subs);
            betaBandit = 10*rand(1, num_subs);
            beta_diff = abs(betaAgency - betaBandit);
            c = c+1;
        end
         agencyBonus = -.5 + 1 .* rand(num_subs, 1);
        while abs(agencyBonus) < .1 && c < max_attempts
                agencyBonus = -.5 + 1 .* rand(num_subs, 1);
                c = c+1;
        end
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
