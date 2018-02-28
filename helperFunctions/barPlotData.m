function [ output_args ] = barPlotData(y,ylab,pval,ylimits,sem1,sem2)

%Used for making a bar plot of the data along with the significance lines
%specified by pval

%y is a matrix of values from all the three TMS conditions
%TColumns - TMS site - col1 - S1;  col2 - DLPFC;  col3 - aPFC;  
%Rows - Subjects

%Other nputs
%ylab = Y axis label, pval - pvalue of the comparisons, ylimits - limits of the y-axis
%sem1 = standard error 1 (important for comparisons corresponding to the p-values),
%sem2 = standard error 2 (less important/unimportant for statistical comparison) 

pval(pval>.05)=NaN;
figure
axes('box','off','tickdir','out','LineWidth',1.25,'FontSize',16); hold on;
hold on
for condition = 1:3
    h = bar(condition,nanmean(y(:,condition)),'BarWidth',0.5,'LineWidth',1.25); hold on;
    if condition == 1
        set(h,'FaceColor',[.2 .2 .2]);
    elseif condition == 2
        set(h,'FaceColor',[.6 .6 .6]);
    else
        set(h,'FaceColor',[.9 .9 .9]);
    end
end
alpha(0.6)
xt = get(gca,'XTick');
set(gca,'XTick',1:3,'FontSize',16,'XTickLabel',{'S1 (control)','DLPFC','aPFC'})

ylim(ylimits);
errorbar(1.1:1:3.1,mean(y),sem2,'.k','LineWidth',0.75,'Markersize',10)
errorbar(0.9:1:2.9,mean(y),sem1,'.k','LineWidth',1.75,'Markersize',10)
ylabel({'';ylab;''})
xlabel({'TMS Site';''},'FontSize',20)
sigstar({[2 3],[1 2],[1,3]},[pval(3), pval(1), pval(2)])
hold off

end

