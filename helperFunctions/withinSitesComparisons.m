function [pval] = withinSitesComparisons(y1,y2,varName)

%Compares each corresponding column of y1 and y2 with
%pairwise t-tests
%Each y is a matrix of values from all the three TMS conditions
%TColumns - TMS site - col1 - S1;  col2 - DLPFC;  col3 - aPFC;  
%Rows - Subjects
%y1 - values for first half of blocks, y2 - values for second half of
%blocks
%varName is a string containing the name of the measure

%Pairwise comparisons between sites
[~,pval(1,1),~,stats1] = ttest(y1(:,1),y2(:,1)); %S1
[~,pval(2,1),~,stats2] = ttest(y1(:,2),y2(:,2)); %DLPFC
[~,pval(3,1),~,stats3] = ttest(y1(:,3),y2(:,3)); %aPFC

Conditions = {'S1';'DLPFC';'aPFC'};
Mean_difference = round(mean(y2 - y1),3)';
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

