 % analysis for the experiment

%Experiment: Subjects performed a visual discrimination task while providing confidence ratings 
%TMS: Subjects received TMS to one of the three sites on each block - S1 (control), DLPFC or aPFC 
%Analyses: Comparison of mean confidence and mratio (metacognition) between
%the three TMS conditions

clear
clc
close all

compute_metacognition = 0;
save_metacognition_data = 0;

% Subjects
subject_id = [1 2 3 5 6 7 9 10 11 15 16 17 19 20 22 24 26 27];
%subject_id = [1];
subjects = 1:length(subject_id);

% Add helper functions
addpath(genpath(fullfile(pwd, 'helperFunctions')));

% Loop over all subjects
for subject=subjects
    
    %% Load the data
    clear stim resp correct conf rt
    
    nratings = 4;
    
    % Load the data
    file_name = ['Data/results_s' num2str(subject_id(subject))];
    eval(['load ' file_name '']);
    
    % Loop over all blocks except TMS test blocks
    main_blocks = [4:12,16:24];
    block_length = length(p.data{main_blocks(1)}.stimulus);
    num_blocks = length(main_blocks);
    
    totalTrials = 0;
    for block=1:length(main_blocks)
        trials = totalTrials + [1:block_length];
        totalTrials = totalTrials + block_length;
        stim(trials) = p.data{main_blocks(block)}.stimulus; %1: left, 2: right
        resp(trials) = p.data{main_blocks(block)}.response;%1: left, 2: right
        correct(trials) = p.data{main_blocks(block)}.correct; %0: error, 1: correct
        conf(trials) = p.data{main_blocks(block)}.confidence; %1-4
        rt(trials) = p.data{main_blocks(block)}.rt; %RT
        tmsSite(trials) = p.tmsSiteOrder(main_blocks(block))*ones([block_length,1]);
        half(trials) = 1; half(trials(block_length/2+1:end)) = 2;
    end
    
    %Transform stim and resp into binary responses
    stim_temp = stim; stim(stim_temp==1)=0; stim(stim_temp==2)=1;
    resp_temp = resp; resp(resp_temp==1)=0; resp(resp_temp==2)=1;
    
    %Change tmsSite indexing (1-S1, 2-DLPFC, 3-aPFC)
    temp=tmsSite; tmsSite(temp==1)=3; tmsSite(temp==3)=1;
    
    %Compute average confidence, mratio, mratio for halves, rt,
    %accuracy,dprime
    for condition = 1:3
        confidence(subject,condition) = mean(conf(tmsSite==condition));
        if compute_metacognition
            meta_MLE = type2_SDT_MLE(stim(tmsSite==condition),resp(tmsSite==condition),conf(tmsSite==condition),nratings, [], 1);
            mratio(subject,condition) = meta_MLE.M_ratio;
            metadprime(subject,condition) = meta_MLE.meta_da;
            meta_MLE1 = type2_SDT_MLE(stim(tmsSite==condition & half == 1),resp(tmsSite==condition & half == 1),conf(tmsSite==condition & half == 1),nratings, [], 1);
            mratio_half1(subject,condition) = meta_MLE1.M_ratio;
            metadprime_half1(subject,condition) = meta_MLE1.meta_da;
            meta_MLE2 = type2_SDT_MLE(stim(tmsSite==condition & half == 2),resp(tmsSite==condition & half == 2),conf(tmsSite==condition & half == 2),nratings, [], 1);
            mratio_half2(subject,condition) = meta_MLE2.M_ratio;
            metadprime_half2(subject,condition) = meta_MLE2.meta_da;         
        else
            load('Metacognition_data')
        end
       
        accuracy(subject,condition) = mean(correct(tmsSite==condition));
        dprime(subject,condition) = data_analysis_resp(stim(tmsSite==condition), resp(tmsSite==condition));
        rt_mean(subject,condition) = mean(rt(tmsSite==condition));
                      
        %Half block measures for confidence and dprime
        for halfBlock = 1:2
            confidence_half(subject,condition, halfBlock) = mean(conf(tmsSite==condition & half == halfBlock));
            dprime_half(subject,condition, halfBlock) =  data_analysis_resp(stim(tmsSite==condition & half==halfBlock), resp(tmsSite==condition & half==halfBlock));
        end
        
        if save_metacognition_data
            save('Metacognition_data','mratio','mratio_half1','mratio_half2','metadprime_half1','metadprime_half2')
        end
    end
    dprime_all(subject) = data_analysis_resp(stim, resp);
end

%% Confidence analysis

% One-way repeated measures ANOVA for effect of TMS location on confidence
onewayRepmeasuresANOVA(confidence)

% Pairwaise comparisons between sites 
pval = betweenSitesComparisons(confidence,'Difference_in_meanConf');

% Plot mean confidence
%Within subject SE
diff(:,1) = confidence(:,1) - confidence(:,2); diff(:,2) = confidence(:,1) - confidence(:,3);
ws_sem(1) = std(diff(:,1))/sqrt(length(diff)); 
ws_sem(2) = std(diff(:,1))/sqrt(length(diff)); 
ws_sem(3) = std(diff(:,2))/sqrt(length(diff));

%Between subject SE
bs_sem = nanstd(confidence)./sqrt(length(confidence)); 

barPlotData(confidence,'Confidence',pval,[2.2 2.85],ws_sem,bs_sem)
saveFigure('Figure3')
%% Metacognition analysis 

% One-way repeated measures ANOVA for effect of TMS location on mratio
onewayRepmeasuresANOVA(mratio)

% Metacognition analysis on half blocks
%Two-way repeated measures ANOVA for effect of TMS location and time on mratio
twowayRepmeasuresANOVA(mratio_half1,mratio_half2)

%Post hoc tests
%Comparison within sites
[pval_wsite] = withinSitesComparisons(mratio_half1,mratio_half2,'mean_DeltaMratio');
%Comparion of change in mratio between sites
[pval_bsite] = betweenSitesComparisons(mratio_half1-mratio_half2,'Difference_in_DeltaMratio');

%Plot difference in mratio 
delta_mratio = mratio_half2-mratio_half1;
num_subjects = length(subjects);

%Within site error bars
wsite_sem(:,1) = std(delta_mratio(:,1))./sqrt(num_subjects);
wsite_sem(:,2) = std(delta_mratio(:,2))./sqrt(num_subjects);
wsite_sem(:,3) = std(delta_mratio(:,3))./sqrt(num_subjects);

%Between site error bars
bsite_sem(:,1) = std(delta_mratio(:,1)-delta_mratio(:,3))./sqrt(num_subjects);
bsite_sem(:,2) = std(delta_mratio(:,1)-delta_mratio(:,3))./sqrt(num_subjects);
bsite_sem(:,3) = std(delta_mratio(:,2)-delta_mratio(:,3))./sqrt(num_subjects);

barPlotData(delta_mratio,'\DeltaM_{ratio}',pval_bsite,[-0.3 0.55],bsite_sem,wsite_sem)
saveFigure('Figure4')

%% (Control) ANOVA on RT and accuracy  
% One-way repeated measures ANOVA on RT
onewayRepmeasuresANOVA(rt_mean)

% One-way repeated measures ANOVA on accuracy
onewayRepmeasuresANOVA(accuracy)

%2-way repeated measures ANOVA on confidence, meta-d' and d'
twowayRepmeasuresANOVA(mratio_half1,mratio_half2)

%% (Control) Two-way repeated measures ANOVA on confidence
twowayRepmeasuresANOVA(confidence_half(:,:,1),confidence_half(:,:,2))

%Post hoc tests
%Comparison within sites
[pval_wsite] = withinSitesComparisons(confidence_half(:,:,1),confidence_half(:,:,2),'mean_Delta_Conf');
%Comparion of change in mratio between sites
[pval_bsite] = betweenSitesComparisons(confidence_half(:,:,2)-confidence_half(:,:,1),'Difference_in_DeltaConf');


%% (Control) Two-way repeated measures ANOVA on dprime

%Two-way repeated measures ANOVA on dprime
twowayRepmeasuresANOVA(dprime_half(:,:,1),dprime_half(:,:,2))

%Post hoc tests
%Comparison within sites
[pval_wsite] = withinSitesComparisons(dprime_half(:,:,1),dprime_half(:,:,2),'mean_DeltaDprime');
%Comparion of change in mratio between sites
[pval_bsite] = betweenSitesComparisons(dprime_half(:,:,2)-dprime_half(:,:,1),'Difference_in_DeltaDprime');

%% (Control) Two-way repeated measures ANOVA on meta-dprime

% Two-way repeated measures ANOVA on meta-dprime
twowayRepmeasuresANOVA(metadprime_half1,metadprime_half2)

%Post hoc tests
%Comparison within sites
[pval_wsite] = withinSitesComparisons(metadprime_half1,metadprime_half2,'mean_DeltaMetadprime');
%Comparion of change in mratio between sites
[pval_bsite] = betweenSitesComparisons(metadprime_half2-metadprime_half1,'Difference_in_DeltaMetadprime');

%% (Control) Mratio variance analysis 

%Check for normality of samples (P > 0.05 indicates that samples are
%normally distributed)
disp('----------- Lilliefors test of normality  -----------')
disp('----------- Mratio from whole blocks across all TMS conditions -----------')
[~,P] = lillietest(reshape(mratio,1,[]))
disp('----------- Mratio from first half of blocks across all TMS conditions -----------')
[~,P] = lillietest(reshape(mratio_half1,1,[]))
disp('----------- Mratio from second half blocks across all TMS conditions -----------')
[~,P] = lillietest(reshape(mratio_half2,1,[]))

%2-sample variance test
disp('----------- Two sample F test for equal variances  -----------')
disp('----------- Between first and second halves -----------')
[~,P,~,stats] = vartest2(reshape(mratio_half1,1,[]),reshape(mratio_half2,1,[]));
F = stats.fstat
P
disp('----------- Between whole blocks and half blocks -----------')
[~,P,~,stats] = vartest2(reshape(mratio,1,[]),reshape([mratio_half2, mratio_half1],1,[]));
F = stats.fstat
P

%% Save dprime values for modelling
dprime_mean = mean(dprime_all);
save('DataforModelling','dprime_mean')
