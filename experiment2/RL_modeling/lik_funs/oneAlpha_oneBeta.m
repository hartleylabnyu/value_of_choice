
function [lik, latents] = oneAlpha_oneBeta(banditChoice, outcome, agency, offer, leftBandit, rightBandit, x, priors)

%parameters to fit
alpha = x(1);
beta = x(2);

%initialize log likelihood and bandit q values
lik = 0;
Qbandit = .5 * ones(6, 1); 

% Loop through trials
for t = 1:length(outcome)
    
    % estimate EVcomp
    estEVcomp = .5*Qbandit(leftBandit(t)) + .5*Qbandit(rightBandit(t)) + offer(t)/10;
    
    % estimate EVchoice
    estEVchoice = max([Qbandit(leftBandit(t)), Qbandit(rightBandit(t))]);
    
    %combine both Q value estimates into a vector
    agencyQs = [estEVcomp, estEVchoice];
    
    %compute agency choice probability
    agency_resp = agency(t) + 1;
    choice_prob = exp(beta .* agencyQs(agency_resp)) ./ (sum(exp(beta .* agencyQs)));
    
    %update log likelihood 
    lik = lik + log(choice_prob);
    
    % bandit choice
    trial_banditQs = [Qbandit(leftBandit(t)), Qbandit(rightBandit(t))];
    
    if banditChoice(t) == 1
        banditResp = 1;
        selectedBandit = leftBandit(t);
    else
        banditResp = 2;
        selectedBandit = rightBandit(t);
    end
    
    % compute choice probability and update log likelihood on agency trials
    if agency(t) == 1
        choice_prob = exp(beta .* trial_banditQs(banditResp)) ./ (sum(exp(beta .* trial_banditQs)));
        lik = lik + log(choice_prob);
    end
    
    % Update Q value
    RPE = outcome(t) - Qbandit(selectedBandit); 
    Qbandit(selectedBandit) = Qbandit(selectedBandit) + alpha * RPE;
    
    % save latent variables
    latents.banditQs(t, :) = trial_banditQs;
    latents.estEVChoice(t) = estEVchoice;
    latents.estEVComp(t) = estEVcomp;
    latents.RPE(t) = RPE;
     
end

% Put priors on parameters
if (priors)
    lik = lik + log(betapdf(alpha, 1.1, 1.1));
    lik = lik + log(gampdf(beta, 2 , 3));
end


%flip sign of loglikelihood (which is negative, and we want it to be as close to 0 as possible; i.e. as high as possible) so we can enter it into fmincon, which searches for minimum, rather than maximum values
lik = -lik;
end

