% Fit RL models to simulated data
% Kate Nussenbaum and Hanxiao Lu
% June 2023

function [model_fits] = fit_simulated_data_spaced(sim_num)

% Clear everything that's loaded

%add randomization
RandStream.setGlobalStream(RandStream('mlfg6331_64','Seed', sim_num));

%add likelihood functions
addpath('lik_funs/');

% Model-fitting settings
niter = 20; %Number of iterations per participant

% Load the simulated data
load(['sim_data/sim_data_spacedParams_sim', int2str(sim_num), '.mat'], 'sim_data');

%set 1 simulated subject
n_subjects = 1;

% models to fit
models = {'oneAlpha_oneBeta', 'oneAlpha_twoBeta', 'twoAlpha_oneBeta', 'twoAlpha_twoBeta', ...
    'oneAlpha_oneBeta_agencyBonus', 'oneAlpha_twoBeta_agencyBonus', 'twoAlpha_oneBeta_agencyBonus', 'twoAlpha_twoBeta_agencyBonus'};

%preallocate structure
model_fits(length(models)) = struct();


%% Initialize model_fits structure
num_sim_datasets = size(sim_data, 2);
num_models_to_fit = length(models);
model_fits(num_sim_datasets, num_models_to_fit) = struct();
model_fits(1).results = [];
model_fits(1).fit_model = 'fit_model';
model_fits(1).sim_model = 'sim_model';

%% Fit models
for d = 1:num_sim_datasets %loop through simulated datasets
    sim_model_data = sim_data(d).sub_data;
    
    for m = 1:num_models_to_fit % loop through models to be fit
        model_to_fit = models{m};
        
        %print message about which model is being fit
        fprintf('Fitting model %d out of %d for dataset %d out of %d...\n', m, length(models), d, num_sim_datasets)
        
        %%%%%%%%%%%%%%%%%
        % MODELS TO FIT %
        %%%%%%%%%%%%%%%%%
        if strcmp(model_to_fit, 'oneAlpha_oneBeta')
            n_params = 2; %alpha, beta
            lb = [1e-6, 1e-6];
            ub = [1, 30];
        elseif strcmp(model_to_fit, 'oneAlpha_twoBeta')
            n_params = 3; %alpha, beta
            lb = [1e-6, 1e-6, 1e-6];
            ub = [1, 30, 30];
        elseif strcmp(model_to_fit, 'twoAlpha_oneBeta')
            n_params = 3; %alpha, beta
            lb = [1e-6, 1e-6, 1e-6];
            ub = [1, 1, 30];
        elseif strcmp(model_to_fit, 'twoAlpha_twoBeta')
            n_params = 4; %alpha, beta
            lb = [1e-6, 1e-6, 1e-6, 1e-6];
            ub = [1, 1, 30, 30];
        elseif strcmp(model_to_fit, 'oneAlpha_oneBeta_agencyBonus')
            n_params = 3; %alpha, beta
            lb = [1e-6, 1e-6, -5];
            ub = [1, 30, 5];
        elseif strcmp(model_to_fit, 'oneAlpha_twoBeta_agencyBonus')
            n_params = 4; %alpha, beta
            lb = [1e-6, 1e-6, 1e-6, -5];
            ub = [1, 30, 30, 5];
        elseif strcmp(model_to_fit, 'twoAlpha_oneBeta_agencyBonus')
            n_params = 4; %alpha, beta
            lb = [1e-6, 1e-6,1e-6, -5];
            ub = [1, 1, 30, 5];
        elseif strcmp(model_to_fit, 'twoAlpha_twoBeta_agencyBonus')
            n_params = 5; %alpha, beta
            lb = [1e-6, 1e-6, 1e-6, 1e-6, -5];
            ub = [1, 1, 30, 30, 5];
        end
    
        % determine function
        function_name = model_to_fit;
        fh = str2func(function_name);
        
        % preallocate
        [logpost, negloglik, AIC, BIC] = deal(nan(n_subjects, 1));
        [params] = nan(n_subjects, n_params);
        
        %determine csv filename for model results
       % csv_filename = ['output/simulations/', 'sim_', model_to_fit, '.csv'];

        %initialize results structure
        results(1) = struct();
        results.logpost = logpost;
        results.params = params;
        results.negloglik = negloglik;
        results.AIC = AIC;
        results.BIC = BIC;
        
        %loop through subjects
            s = 1;
            sub_data = sim_model_data(s);
            
            fprintf('Fitting subject %d out of %d...\n', s, n_subjects) %print message saying which subject is being fit
         
            %determine filename for latents
            %latents_filename{s} = ['output/simulations/latents/latents_', 'sim_',model_to_fit, '_', subject, '.csv'];
            
            % get trial information and simulated choices 
            outcome = [sub_data.outcome];
            agency = [sub_data.agencyChoiceVec - 1];
            agencyChoiceVec = [sub_data.agencyChoiceVec];
            banditChoiceVec = [sub_data.banditChoiceVec];
            leftBandit = [sub_data.leftBandit];
            rightBandit = [sub_data.rightBandit]';
            offer = [sub_data.offer]';
            
            QbanditOrder = { 'bandit50a', 'bandit50b'; ...
                'bandit70', 'bandit30'; ...
                'bandit90', 'bandit10'};
            
            for iter = 1:niter  % run niter times from random initial conditions, to get best fit
                
                % choose a random number between the lower and upper bounds to initialize each of the parameters
                starting_points = rand(1,length(lb)).* (ub - lb) + lb; % random initialization
                
                % Run fmincon 
                [res, nlp] = ...
                    fmincon(@(x) fh(QbanditOrder, agencyChoiceVec, banditChoiceVec, outcome, agency, offer, leftBandit, rightBandit, x, 1),...
                    starting_points,[],[],[],[],lb, ub,[],...
                    optimset('maxfunevals',10000,'maxiter',2000, 'Display', 'off'));
                
                %flip sign to get log posterior (if priors are in models, if no priors, this will be the log likelihood)
                logp = -1 * nlp;
                
                %store results if minimum is found
                if iter == 1 || logpost(s) < logp
                    logpost(s) = logp;
                    params(s, :) = res;
                    [negloglik(s), latents(s)] = fh(QbanditOrder, agencyChoiceVec, banditChoiceVec, outcome, agency, offer, leftBandit, rightBandit, res, 0); %fit model w/ 'winning' parameters w/o priors to get the negative log likelihood
                    AIC(s) = 2*negloglik(s) + 2*length(res);
                    num_bandit_choices = length(find(agencyChoiceVec == 2));
                    BIC(s) = 2*negloglik(s) + length(res)*log(length(agencyChoiceVec) + num_bandit_choices); 
                    %age_group{s} = subject(end);
                    sub{s} = s;

                end
                
            end
            
            

        results.sub = sub;
        results.logpost = logpost;
        results.params = params;
        results.negloglik = negloglik;
        results.AIC = AIC;
        results.BIC = BIC;

        %save for each model
        model_fits(d, m).results = results;
        model_fits(d, m).fit_model = model_to_fit;
        model_fits(d, m).sim_model = sim_data(d).function;
        
        %clear results structure for next model
        clear results;
        
    end
end

%%
%Save fitting results
filename = ['output/model_fits/all_model_fits_spaced_sim', int2str(sim_num)];
save(filename, 'model_fits');
end



