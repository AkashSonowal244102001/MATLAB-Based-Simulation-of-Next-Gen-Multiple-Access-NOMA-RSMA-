function rsma_siso_montecarlo()
% RSMA_SISO_MONTECARLO
% This script simulates a 2-user SISO RSMA system with:


    clc; 
    close all;

    %% 1. Simulation parameters
    numTrials = 1e5;              % Monte-Carlo trials
    Ps_dB = 0 : 5 : 30;           % BS transmit power range in dB
    Ps_lin = 10.^(Ps_dB / 10);    % Linear scale for power
    N0 = 1;                       % Noise power
    % Power fractions for (common, private-1, private-2)
    alpha_c = 0.5;                % fraction for common stream
    alpha_1 = 0.3;                % fraction for user-1 private stream
    alpha_2 = 0.2;                % fraction for user-2 private stream

    % Thresholds
    gamma_th_c = 0.9;             % threshold for common stream
    gamma_th_p = 0.5;             % threshold for private streams

    %% 2. Pre-allocate results
    % We will store:
    %  - Outage Probability: P_out1, P_out2
    %  - Ergodic (average) rates: R1_avg, R2_avg
    P_out1 = zeros(size(Ps_lin));
    P_out2 = zeros(size(Ps_lin));
    R1_avg = zeros(size(Ps_lin));
    R2_avg = zeros(size(Ps_lin));

    %% 3. Loop over transmit power values
    for idx = 1 : length(Ps_lin)

        P = Ps_lin(idx);          % linear scale transmit power
        % Arrays to accumulate rates for ergodic calculation
        R1_accum = 0;
        R2_accum = 0;

        % Counters for outage
        outageCount1 = 0;
        outageCount2 = 0;

        % 3a. Monte-Carlo Trials
        for n = 1 : numTrials
            % Generate Rayleigh channels
            h1 = sqrt(1/2)*(randn + 1i*randn);       % CN(0,1) => mean(|h1|^2)=1
            h2 = sqrt(1.5/2)*(randn + 1i*randn);     % CN(0,1.5)=>mean(|h2|^2)=1.5

            % Magnitudes
            X = abs(h1)^2;     % user-1 channel power
            Y = abs(h2)^2;     % user-2 channel power

            %% Compute SINRs

            % ---- Common stream sc ----
            % sc has alpha_c * P power, private streams have alpha_1*P and alpha_2*P
            % Each user decodes sc treating (sp1 + sp2) as noise
           
            gamma_c1 = (X * alpha_c * P) / (X * (alpha_1 + alpha_2) * P + N0);
            gamma_c2 = (Y * alpha_c * P) / (Y * (alpha_1 + alpha_2) * P + N0);

            % ---- Private streams sp1, sp2 ----
            % user-1: decode sp1, treat sp2 as noise
           
            gamma_p1_1 = (X * alpha_1 * P) / (X * (alpha_2 * P) + N0);
            % user-2: decode sp2, treat sp1 as noise
           
            gamma_p2_2 = (Y * alpha_2 * P) / (Y * (alpha_1 * P) + N0);

            %% 3b. Outage Condition
            % user-1 is out if (gamma_c1 < 0.9) or (gamma_p1_1 < 0.5)
            if (gamma_c1 < gamma_th_c) || (gamma_p1_1 < gamma_th_p)
                outageCount1 = outageCount1 + 1;
            end
            % user-2 is out if (gamma_c2 < 0.9) or (gamma_p2_2 < 0.5)
            if (gamma_c2 < gamma_th_c) || (gamma_p2_2 < gamma_th_p)
                outageCount2 = outageCount2 + 1;
            end

            %% 3c. Rates for the no-outage scenario (Ergodic Rate)
            % If a user's stream is decodable, then that user gets a certain rate.
            %
            % Common Stream Rate: R_c = log2(1 + min(gamma_c1, gamma_c2))
            %   => Then we can "split" R_c among user-1 and user-2 however we like 
            %   (For simplicity, let's do half: R_c/2 each, or do alpha-based splitting.)
            %
            % Private rates:
            %   R1_p = log2(1 + gamma_p1_1)
            %   R2_p = log2(1 + gamma_p2_2)

            R_c = log2(1 + min(gamma_c1, gamma_c2));
            % Let's split the common rate equally for demonstration:
            R_c1 = 0.5 * R_c;   % portion to user-1
            R_c2 = 0.5 * R_c;   % portion to user-2

            R1_private = log2(1 + gamma_p1_1);
            R2_private = log2(1 + gamma_p2_2);

            % total rates:
            R1_total = R_c1 + R1_private;
            R2_total = R_c2 + R2_private;

            R1_accum = R1_accum + R1_total;
            R2_accum = R2_accum + R2_total;
        end

        % 3d. Empirical Outage Probability
        P_out1(idx) = outageCount1 / numTrials;
        P_out2(idx) = outageCount2 / numTrials;

        % 3e. Ergodic (average) Rate
        R1_avg(idx) = R1_accum / numTrials;
        R2_avg(idx) = R2_accum / numTrials;
    end

    %% 4. Plot: Ergodic Rates
    figure; 
    plot(Ps_dB, R1_avg, 'r-o','LineWidth',1.5); hold on;
    plot(Ps_dB, R2_avg, 'b-*','LineWidth',1.5);
    xlabel('BS Transmit Power (dB)');
    ylabel('Ergodic Rate (bits/s/Hz)');
    legend('User 1','User 2','Location','best');
    grid on;
    title('Ergodic Rates vs. Transmit Power for Two-User SISO RSMA');

    %% 5. Plot: Outage Probabilities
    figure;
    semilogy(Ps_dB, P_out1, 'r-o','LineWidth',1.5); hold on;
    semilogy(Ps_dB, P_out2, 'b-*','LineWidth',1.5);
    xlabel('BS Transmit Power (dB)');
    ylabel('Outage Probability');
    legend('User 1','User 2','Location','best');
    grid on;
    title('Outage Probabilities vs. Transmit Power for Two-User SISO RSMA');

end
