
function [banditChoiceVec, agencyChoiceVec, outcomeVec, latents] = sim_twoAlpha_twoBeta_agencyBonus(task_struct, params)

%get task structure data
offer = task_struct.offer;
QbanditOrder = task_struct.QbanditOrder;
leftBandit = task_struct.leftBandit;
rightBandit = task_struct.rightBandit;

%determine number of trials
num_trials = length(task_struct.offer);

%get params
alphaChoice = params(1);
alphaComp = params(2);
betaAgency = params(3);
betaBandit= params(4);
agencyBonus = params(5);

%initialize choices
agencyChoiceVec = zeros(num_trials, 1);
banditChoiceVec = zeros(num_trials, 1);
outcomeVec = NaN(num_trials, 1);

%determine reward probabilities
bandit_reward_probs = [.5, .7, .9, .5, .3, .1];

%initialize Q values
Qbandit = .5 * ones(3, 2);

%loop through trials
for trial = 1:num_trials
    
    % get Q indices for left and right bandit
    leftBanditQidx = find(contains(QbanditOrder,leftBandit{trial}));
    rightBanditQidx = find(contains(QbanditOrder,rightBandit{trial}));
    
    % get offer
    thisTrial_offer = offer(trial);
    
    % estimate EVcomp
    estEVcomp = .5*Qbandit(leftBanditQidx) + .5*Qbandit(rightBanditQidx) + thisTrial_offer/10;
    
    % estimate EVchoice
    estEVchoice = max([Qbandit(leftBanditQidx), Qbandit(rightBanditQidx)]) + agencyBonus;
    
    %agency choice function
    numerator = exp(estEVchoice * betaAgency);
    denominator = sum(exp(([estEVcomp, estEVchoice])*betaAgency));
    
    % probability of selecting to choose
    prob_agency_choice = numerator/denominator;
    
    %make choice based on probability
    rand_choice = rand(1);
    if rand_choice < prob_agency_choice
        agency_choice = 2;
    else
        agency_choice = 1;
    end
    
    % bandit choice
    thisTrial_banditQs = [Qbandit(leftBanditQidx), Qbandit(rightBanditQidx)];
    
    if agency_choice == 2
        alpha = alphaChoice;
        numerator = exp(Qbandit(leftBanditQidx) * betaBandit );
        denominator = sum(exp((thisTrial_banditQs) * betaBandit));
        prob_left_choice = numerator/denominator;
    elseif agency_choice == 1
        alpha = alphaComp;
        prob_left_choice = .5;
    end
    
    %make choice based on probability
    rand_bandit_choice = rand(1);
    if rand_bandit_choice < prob_left_choice
        thisTrial_banditResp = 1;
        selectedBandit = leftBandit{trial};
        reward_prob = bandit_reward_probs(leftBanditQidx);
    else
        thisTrial_banditResp = 2;
        selectedBandit = rightBandit{trial};
        reward_prob = bandit_reward_probs(rightBanditQidx);
    end
    
    %determine outcome
    rand_outcome = rand(1);
    if rand_outcome < reward_prob
        outcome = 1;
    else
        outcome = 0;
    end
    
    % Update Q value
    RPE = outcome - thisTrial_banditQs(thisTrial_banditResp); % outcome minus expectation
    Qbandit(find(contains(QbanditOrder, selectedBandit))) = Qbandit(find(contains(QbanditOrder, selectedBandit))) + alpha * RPE;

    %save trial information
    banditChoiceVec(trial) = thisTrial_banditResp;
    agencyChoiceVec(trial) = agency_choice;
    outcomeVec(trial) = outcome;
    latents.RPE(trial) = RPE;
    latents.estEVchoice(trial) = estEVchoice;
    latents.estEVcomp(trial) = estEVcomp;
    
end
end





