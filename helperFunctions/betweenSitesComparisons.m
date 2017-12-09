function [pval] = betweenSitesComparisons(y,varName)

%Does pairwise comparisons of the three columns of y with paired t-tests

%y is a matrix of values from all the three TMS conditions
%TColumns - TMS site - col1 - S1;  col2 - DLPFC;  col3 - aPFC;  
%Rows - Subjects
%varName is a string containing the name of the measure

%Pairwise comparisons between sites
[~,pval(1,1),~,stats1] = ttest(y(:,1),y(:,2)); %S1 vs DLPFC
[~,pval(2,1),~,stats2] = ttest(y(:,1),y(:,3)); %S1 vs aPFC
[~,pval(3,1),~,stats3] = ttest(y(:,2),y(:,3)); %DLPFC vs aPFC

Conditions = {'S1 vs DLPFC';'S1 vs aPFC'; 'DLPFC vs aPFC'};
mean_y = mean(y);
Mean_difference = round([mean_y(1)-mean_y(2);mean_y(1)-mean_y(3);mean_y(2)-mean_y(3)],3);
tstat(1,1) = stats1.tstat; tstat(2,1) = stats2.tstat;tstat(3,1) = stats3.tstat; tstat = round(tstat,2);
pval = round(pval,3);

%Table to summarise the t-test
T = table(Mean_difference,tstat,pval,'VariableNames',{varName;'t';'P'},'RowNames',Conditions);
%Formatting the table
TString = evalc('disp(T)');
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
figure;
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0.15 0.8 .1 .1],'FontSize',20);


end

