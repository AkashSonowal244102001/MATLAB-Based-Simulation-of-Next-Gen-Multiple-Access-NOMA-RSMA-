%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Monte-Carlo Simulation vs. Analytical Outage Probability for Near User (Dn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; 
clc; 
close all;

% 1) Simulation parameters
numTrials = 1e5;      % number of Monte-Carlo runs
Ps_dB = 0:5:30;       % range of BS transmit power in dB
Ps_lin = 10.^(Ps_dB/10);

% System-level constants
N0 = 1;               % noise power (normalized to 1 for example)
Puf = 5;              % uplink far user power
Pun = 10;             % uplink near user power
a_f = 0.8;            % far user power allocation
a_n = 0.2;            % near user power allocation
gamma_th_f = 2;       % threshold for decoding x_f
gamma_th_n = 2;       % threshold for decoding x_n

% Channel gain means for Rayleigh fading
beta_sDn = 1;         % mean of |h_{sDn}|^2
beta_fn  = 1;         % mean of |h_{fn}|^2
beta_nn  = 1;         % mean of |h_{nn}|^2

% Preallocate arrays
OP_near_ana = zeros(size(Ps_lin));    % Analytical OP
OP_near_sim = zeros(size(Ps_lin));    % Simulated OP

for idx = 1:length(Ps_lin)
    
    Ps = Ps_lin(idx);             % current BS transmit power (linear scale)
    gamma_s = Ps / N0;            % normalized BS power
    gamma_u_f = Puf / N0;         % normalized uplink far user power
    gamma_u_n = Pun / N0;         % normalized uplink near user power
    
  
    %% (A) Analytical Outage Probability for Near User
   
 
    
    denom_f = a_f - gamma_th_f*a_n;
    if denom_f <= 0
        % If this is <= 0, decoding x_f first isn't feasible with these thresholds/powers
        OP_near_ana(idx) = 1;
    else
        Theta_f = gamma_th_f / (denom_f * gamma_s);
        Theta_n = gamma_th_n / (a_n * gamma_s);
        Theta   = max(Theta_f, Theta_n);

        % The standard final expression might look like:
        %   P_success = exp(-Theta/beta_sDn)* (beta_sDn^2 / [(beta_sDn+Theta*gamma_u_f*beta_fn)*(beta_sDn+Theta*gamma_u_n*beta_nn)])
        %   P_out = 1 - P_success

        termExp = exp(-Theta / beta_sDn);
        denom1  = (beta_sDn + Theta*gamma_u_f*beta_fn);
        denom2  = (beta_sDn + Theta*gamma_u_n*beta_nn);
        P_success = termExp * ( beta_sDn^2 / (denom1 * denom2) );
        
        OP_near_ana(idx) = 1 - P_success;
    end
   
    %% (B) Monte-Carlo Simulation for Near User
  
    % (i) Generate random channels for near user
    h_sDn = sqrt(beta_sDn/2)*(randn(numTrials,1) + 1i*randn(numTrials,1));
    h_fn  = sqrt(beta_fn/2) *(randn(numTrials,1) + 1i*randn(numTrials,1));
    h_nn  = sqrt(beta_nn/2) *(randn(numTrials,1) + 1i*randn(numTrials,1));
    
    % (ii) Channel power magnitudes
    X = abs(h_sDn).^2;  % |h_{sDn}|^2
    Y = abs(h_fn)  .^2; % |h_{fn}|^2
    Z = abs(h_nn)  .^2; % |h_{nn}|^2
    
    % (iii) Compute instantaneous SINRs
    Gamma_xf = (a_f*Ps .* X) ./ (a_n*Ps.*X + Puf.*Y + Pun.*Z + N0);
    Gamma_xn = (a_n*Ps .* X) ./ (          Puf.*Y + Pun.*Z + N0);
    
    % (iv) Outage condition: fails if either Gamma_xf < gamma_th_f OR Gamma_xn < gamma_th_n
    outageEvents = (Gamma_xf < gamma_th_f) | (Gamma_xn < gamma_th_n);
    OP_near_sim(idx) = mean(outageEvents);
    
end

%% 4) Plot Simulation vs. Analytical
figure;
semilogy(Ps_dB, OP_near_ana, 'ro-','LineWidth',1.5); hold on;
semilogy(Ps_dB, OP_near_sim, 'b*-','LineWidth',1.5);
grid on; 
xlabel('BS Transmit Power (dB)');
ylabel('Outage Probability');
title('Near User Outage Probability: Simulation vs Analytical');
legend('Analytical','Simulation','Location','best');
