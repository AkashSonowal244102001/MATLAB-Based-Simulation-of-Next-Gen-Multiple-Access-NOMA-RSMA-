clear; 
clc;
close all;

%% 1. Simulation Parameters

numTrials = 1e5;            % Number of Monte-Carlo runs
Ps_dB = 0:5:30;             % Range of BS transmit power in dB
Ps_lin = 10.^(Ps_dB/10);

% Noise power (normalized)
N0 = 1;

% Uplink user powers
Puf = 5;    % uplink far user
Pun = 10;   % uplink near user

% NOMA power allocation
a_f = 0.8;  % fraction allocated to far user
a_n = 0.2;  % fraction allocated to near user

% Thresholds for decoding
gamma_th_f = 2;  % threshold for decoding x_f
gamma_th_n = 2;  % threshold for decoding x_n

% Channel gain means (Rayleigh)
beta_sDn = 1;  % E[|h_{sDn}|^2]
beta_fn  = 1;  
beta_nn  = 1;  
beta_sDf = 1;  % E[|h_{sDf}|^2]
beta_ff  = 1;  
beta_nf  = 1;  

%% 2. Pre-allocate arrays
OP_near_ana = zeros(size(Ps_lin));   % Analytical OP (near user)
OP_near_sim = zeros(size(Ps_lin));   % Simulated OP (near user)
OP_far_ana  = zeros(size(Ps_lin));   % Analytical OP (far user)
OP_far_sim  = zeros(size(Ps_lin));   % Simulated OP (far user)

%% 3. Loop over BS Transmit Power
for idx = 1:length(Ps_lin)
    
    Ps  = Ps_lin(idx);        % BS Tx power (linear)
    gamma_s = Ps / N0;        % normalized downlink SNR
    gamma_uf = Puf / N0;      % normalized uplink far user power
    gamma_un = Pun / N0;      % normalized uplink near user power
    
    %%  Part A: Analytical OP for Near User 
    denom_f = a_f - gamma_th_f*a_n;
    if denom_f <= 0
        OP_near_ana(idx) = 1; % can't decode x_f => always outage
    else
        Theta_f = gamma_th_f / (denom_f * gamma_s);
        Theta_n = gamma_th_n / (a_n * gamma_s);
        Theta   = max(Theta_f, Theta_n);
        
        % Closed-form expression for success, then OP = 1 - success
        expoTerm = exp(-Theta / beta_sDn);
        denom1   = beta_sDn + Theta*gamma_uf*beta_fn;
        denom2   = beta_sDn + Theta*gamma_un*beta_nn;
        
        P_success_dn = expoTerm * (beta_sDn^2 / (denom1 * denom2));
        OP_near_ana(idx) = 1 - P_success_dn;
    end
    
    %% Part B: Analytical OP for Far User 
    denom_f2 = a_f - gamma_th_f*a_n;
    if denom_f2 <= 0
        OP_far_ana(idx) = 1;
    else
        Theta_f2 = gamma_th_f / (denom_f2 * gamma_s);
        
        expoTerm2 = exp(-Theta_f2 / beta_sDf);
        denom3    = beta_sDf + Theta_f2*gamma_uf*beta_ff;
        denom4    = beta_sDf + Theta_f2*gamma_un*beta_nf;
        
        P_success_df = expoTerm2 * (beta_sDf^2 / (denom3 * denom4));
        OP_far_ana(idx) = 1 - P_success_df;
    end
    
    %% Part C: Monte-Carlo Simulations 
    
    % (i) Generate channels for near user
    h_sDn = sqrt(beta_sDn/2)*(randn(numTrials,1)+1i*randn(numTrials,1));
    h_fn  = sqrt(beta_fn/2) *(randn(numTrials,1)+1i*randn(numTrials,1));
    h_nn  = sqrt(beta_nn/2) *(randn(numTrials,1)+1i*randn(numTrials,1));
    
    % (ii) Generate channels for far user
    h_sDf = sqrt(beta_sDf/2)*(randn(numTrials,1)+1i*randn(numTrials,1));
    h_ff  = sqrt(beta_ff/2) *(randn(numTrials,1)+1i*randn(numTrials,1));
    h_nf  = sqrt(beta_nf/2) *(randn(numTrials,1)+1i*randn(numTrials,1));
    
    % (iii) Magnitudes
    X_n = abs(h_sDn).^2;  
    Y_n = abs(h_fn).^2;   
    Z_n = abs(h_nn).^2;   
    
    X_f = abs(h_sDf).^2;  
    Y_f = abs(h_ff).^2;   
    Z_f = abs(h_nf).^2;   
    
    % (iv) Near user SINRs
    Gamma_xf_dn = (a_f*Ps .* X_n) ./ (a_n*Ps.*X_n + Puf.*Y_n + Pun.*Z_n + N0);
    Gamma_xn_dn = (a_n*Ps .* X_n) ./ (          Puf.*Y_n + Pun.*Z_n + N0);
    
    % Outage event for near user
    outage_dn = (Gamma_xf_dn < gamma_th_f) | (Gamma_xn_dn < gamma_th_n);
    OP_near_sim(idx) = mean(outage_dn);
    
    % (v) Far user SINR
    Gamma_xf_df = (a_f*Ps .* X_f) ./ (a_n*Ps.*X_f + Puf.*Y_f + Pun.*Z_f + N0);
    
    % Outage event for far user
    outage_df = (Gamma_xf_df < gamma_th_f);
    OP_far_sim(idx) = mean(outage_df);
end

%% 4. Plotting Results with distinct colors

figure; 
% Near user
semilogy(Ps_dB, OP_near_ana, 'r-o','LineWidth',1.5); hold on;  % Red
semilogy(Ps_dB, OP_near_sim, 'b--*','LineWidth',1.5);          % Blue

% Far user
semilogy(Ps_dB, OP_far_ana,  'g-s','LineWidth',1.5);           % Green
semilogy(Ps_dB, OP_far_sim,  'm--^','LineWidth',1.5);          % Magenta

grid on;
xlabel('BS Transmit Power (dB)');
ylabel('Outage Probability (log scale)');
title('Outage Probability for Near (Dn) and Far (Df) Users');
legend('Dn Analytical','Dn Simulation','Df Analytical','Df Simulation','Location','best');
