%simulate_model

%Simulates the TMS effects on the three sites in a hierarchical confidence
%generation model.

%Perceptual variables
%Object level - stimulus (value 0 or 1) gets corrupted by sensory noise
%(sigma) to give the sensory response (rsens)
%Meta level - sensory response gets further corrupted by metacognitive
%noise (metaNoise) to give the metacognitive response (rmeta)

%Decision crieria
%Object level - decision criteria (c) is set at 0.
% For rsens <0 - response is 0 and rsens >0 response is 1
%Meta level - Confidence is given on a scale from 1 to 4 by comparing rmeta
%to confCriterion values 
%Eg: for confCriteria(1)<rmeta<confCriteria(2), confidence = 1
%    for confCriteria(2)<rmeta<confCriteria(3), confidence = 2, etc.

%TMS effects
%S1 - no effect
%DLPFC - TMS decreases rsens at the meta level by the amount delta_rsens
%aPFC - for second half of trials, TMS decreases metaNoise by the amount
%delta_metaNoise


clear
clc
close all

save_results = 0;
simulate = 0;

% Add helper functions
currentDir = pwd;
parts = strsplit(currentDir, '/');
addpath(genpath(fullfile(currentDir(1:end-length(parts{end})), 'helperFunctions')));

%Load data
load('DataforModelling.mat')

% Define parameters of the conditions
N = 1000000;
mu = dprime_mean;
sigma = 1; %Sensory noise
c = 0; %Bias
metaNoise = 0.6; %Meta noise
delta_metaNoise = 0.5; %Change in meta noise
delta_metaNoise_base = 0.15; %Baseline decrease in meta noise for second half
delta_rsens = 0.072; %Change in sensory response at meta level
confCriteria = [0 0.45 0.95 1.45 inf];

response = NaN([N,3]);
confidence = NaN([N,3]);

if simulate
    for condition = 1:3
        
        %Generate actual stimulus values - 0 or 1
        stimulus(:,condition) = [zeros(1,N/2), ones(1,N/2)];
        
        %Each stimulus class has a normal sensory response distribution
        %centered on the mean for that stimulus class
        %mean for stimulus = 0: -mu/2, mean for stimulus = 1: mu/2
        muStim = [-mu/2*ones(1,N/2), mu/2*ones(1,N/2)];
        
        %Generate the sensory response values for each stimulus
        rsens = normrnd(muStim, sigma, 1, N);
        
        if condition == 1        %S1
            rmeta(1:N/2) = normrnd(rsens(1:N/2), metaNoise);
            rmeta(N/2+1:N) = normrnd(rsens(N/2+1:N), metaNoise+delta_metaNoise_base); %Decrease in metacognitive vigilance with time
            
        elseif condition == 2 %DLPFC
            %TMS to DLPFC decreases the sensory response by amount delta_rsens
            transformed_r_sens = abs(rsens)-delta_rsens;
            %For values of rsens < delta_rsens, set rsens to 0 (abs(rsens) - delta_rsens should be >= 0)
            transformed_r_sens(transformed_r_sens<0) = 0;
            %Retain the sign of rsens to make the decision response
            transformed_r_sens = transformed_r_sens .* sign(rsens);
            
            rmeta(1:N/2) = normrnd(transformed_r_sens(1:N/2), metaNoise);
            rmeta(N/2+1:N) = normrnd(transformed_r_sens(N/2+1:N), metaNoise+delta_metaNoise_base);
            
        elseif condition == 3 %aPFC
            rmeta(1:N/2) = normrnd(rsens(1:N/2), metaNoise);
            %TMS to aPFC decreases meta noise by amount delta_metaNoise
            rmeta(N/2+1:N) = normrnd(rsens(N/2+1:N), metaNoise-delta_metaNoise);
        end
        
        %Decision responses
        response(:,condition) = rsens > c; % 1 - right & 0 - left
        
        %Confidence response
        conf = NaN([1, N]);
        for criteria = 1:4
            conf(1,sign(rsens) ~= sign(rmeta)) = 1;
            conf(1,(sign(rmeta) == sign(rsens)) & (abs(rmeta)>abs(confCriteria(criteria))) & (abs(rmeta)<=abs(confCriteria(criteria+1)))) = criteria;
        end
        confidence(:,condition) = conf;
        correct(:,condition) = stimulus(:,condition) == response(:,condition);
        
        %Dprime and Mratio
        meta_MLE = type2_SDT_MLE(stimulus(:,condition),response(:,condition),confidence(:,condition),4,[],1);
        M_ratio(condition) = meta_MLE.M_ratio;
        M_diff(condition) = meta_MLE.M_diff;
        dprime(condition) = meta_MLE.da;
        
        % Calculate mratio for first and second half of the blocks separately
        for half = 1:2
            meta_MLE = type2_SDT_MLE(stimulus(N/2*(half-1)+1:half*N/2,condition),response(N/2*(half-1)+1:half*N/2,condition)...
                ,confidence(N/2*(half-1)+1:half*N/2,condition),4,[],1);
            half_M_ratio(condition,half) = meta_MLE.M_ratio;
            half_M_diff(condition,half) = meta_MLE.M_diff;
            half_dprime(condition,half) = meta_MLE.da;
        end
        
    end
else
    load('ModelSimulationResults')
end

if save_results
    save('ModelSimulationResults')
end


%  Plot confidence
barPlotModel(confidence,'Confidence',[2.2 2.75])
saveFigure('Figure5B')

% Plot change in mratio
delta_mratio = half_M_ratio(:,2)'- half_M_ratio(:,1)';
barPlotModel(delta_mratio,'\DeltaM_{ratio}',[-0.3 0.3])
saveFigure('Figure5C')
