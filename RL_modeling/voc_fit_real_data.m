%%%%%% VoC Fit Models %%%%%
% Fit RL models to real data
% Kate Nussenbaum and Hanxiao Lu, March 2023
% katenuss@gmail.com

%%
% clear everything
clear;

% load path to likelihood functions
addpath('lik_funs/');

% load data
dataFolder = 'data/';
subIDs = dir([dataFolder '/*.mat']);
subIDs = {subIDs.name};

%get number of subjects
n_subjects = length(subIDs);

%% DETERMINE MODELS TO FIT %%
% save filename
filename = 'output/all_model_fits';

% Determine number of iterations
niter = 10;

% models to fit
models = {'oneAlpha_oneBeta', 'oneAlpha_twoBeta', 'twoAlpha_oneBeta', 'twoAlpha_twoBeta', ...
    'oneAlpha_oneBeta_agencyBonus', 'oneAlpha_twoBeta_agencyBonus', 'twoAlpha_oneBeta_agencyBonus', 'twoAlpha_twoBeta_agencyBonus'};

%preallocate structure
model_fits(length(models)) = struct();

%% FIT MODELS TO DATA %%
%----------------------------------%
% Loop through models and subjects %
%----------------------------------%

for m = 1:length(models)
    model_to_fit = models{m};
    
    %print message about which subject is being fit
    fprintf('Fitting model %d out of %d...\n', m, length(models))
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Model-specific info %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Baseline models
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
    
    
    % convert function name to function
    model_filename = ['output/model_fits/fit_', model_to_fit];
    fh = str2func(model_to_fit);
    
    % generate matrices to save data
    [logpost, negloglik, AIC, BIC] = deal(nan(n_subjects, 1));
    [params] = nan(n_subjects, n_params);
    
    %determine csv filename for model results
    csv_filename = ['output/model_fits/', model_to_fit, '.csv'];
    
    %loop through subjects
    parfor s = 1:n_subjects
        
        %print message about which subject is being fit
        fprintf('Fitting subject %d out of %d...\n', s, n_subjects)
        
        %get subject
        subID = subIDs{s};
        subject = subID(1:end-4);
        
        %determine filename for latents
        latents_filename{s} = ['output/model_fits/latents/latents_', model_to_fit, '_', subject, '.csv'];
        
        % load subject data file
        sub_data = load(strcat(dataFolder, filesep, subIDs{s}));
        
        % get trial information
        outcome = [sub_data.subjStruct.banditTask.reward]';
        agency = [sub_data.subjStruct.banditTask.agency]';
        agencyChoiceVec = [sub_data.subjStruct.banditTask.agencyResp]';
        banditChoiceVec = [sub_data.subjStruct.banditTask.banditResp]';
        leftBandit = {sub_data.subjStruct.banditTask.leftBandit}';
        rightBandit = {sub_data.subjStruct.banditTask.rightBandit}';
        offer = [sub_data.subjStruct.banditTask.tokenOffer]';
        
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
                age_group{s} = subject(end);
                sub{s} = subject;

                %write latents CSV for each participant
                dlmwrite(latents_filename{s}, [latents(s).banditQs(:,1), latents(s).banditQs(:,2), latents(s).estEVChoice', latents(s).estEVComp', latents(s).RPE']);
            end
            
        end
        
    end
    results.sub = sub;
    results.logpost = logpost;
    results.params = params;
    results.negloglik = negloglik;
    results.AIC = AIC;
    results.BIC = BIC;
    
    %write csv of results for each model
    dlmwrite(csv_filename, [results.negloglik, results.logpost, results.AIC, results.BIC, results.params]);
    
    %save structure for each model
    model_fits(m).results = results;
    model_fits(m).fit_model = model_to_fit;
    
    model_fit = model_fits(m);
    
    %Save fitting results
    save(model_filename, 'model_fit');
    
end

%Save fitting results
save(filename, 'model_fits');

