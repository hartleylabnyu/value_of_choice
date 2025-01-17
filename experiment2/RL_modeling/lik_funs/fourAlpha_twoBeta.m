
function [lik, latents] = fourAlpha_twoBeta(banditChoice, outcome, agency, offer, leftBandit, rightBandit, x, priors)

%parameters to fit
alpha_choice_pos = x(1);
alpha_choice_neg = x(2);
alpha_comp_pos = x(3);
alpha_comp_neg = x(4);
beta_agency = x(5);
beta_bandit = x(6);

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
    choice_prob = exp(beta_agency .* agencyQs(agency_resp)) ./ (sum(exp(beta_agency .* agencyQs)));
    
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
        choice_prob = exp(beta_bandit .* trial_banditQs(banditResp)) ./ (sum(exp(beta_bandit .* trial_banditQs)));
        lik = lik + log(choice_prob);
    end
    
    % Update Q value
    RPE = outcome(t) - Qbandit(selectedBandit); 
    
    if RPE > 0 
        if agency(t) == 1
            alpha = alpha_choice_pos;
        else
            alpha = alpha_comp_pos;
        end
    else
        if agency(t) == 1
            alpha = alpha_choice_neg;
        else
            alpha = alpha_comp_neg;
        end
    end
    
    Qbandit(selectedBandit) = Qbandit(selectedBandit) + alpha * RPE;
    
    % save latent variables
    latents.banditQs(t, :) = trial_banditQs;
    latents.estEVChoice(t) = estEVchoice;
    latents.estEVComp(t) = estEVcomp;
    latents.RPE(t) = RPE;
     
end

% Put priors on parameters
if (priors)
    lik = lik + log(betapdf(alpha_choice_pos, 1.1, 1.1));
    lik = lik + log(betapdf(alpha_choice_neg, 1.1, 1.1));
    lik = lik + log(betapdf(alpha_comp_pos, 1.1, 1.1));
    lik = lik + log(betapdf(alpha_comp_neg, 1.1, 1.1));
    lik = lik + log(gampdf(beta_agency, 2 , 3));
    lik = lik + log(gampdf(beta_bandit, 2 , 3));
end


%flip sign of loglikelihood (which is negative, and we want it to be as close to 0 as possible; i.e. as high as possible) so we can enter it into fmincon, which searches for minimum, rather than maximum values
lik = -lik;
end

