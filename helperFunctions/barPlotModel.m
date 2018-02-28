function [] = barPlotModel(y,ylab,ylimits)

%Used for making a bar plot of the simulated measures

%y is a matrix of values from all the three TMS conditions
%Columns - TMS effect - col1 - S1;  col2 - DLPFC;  col3 - aPFC;  
%Rows - trials

%Confidence

figure;
axes('box','off','tickdir','out','LineWidth',1.25,'FontSize',16); hold on;
hold on
for condition = 1:3
    h = bar(condition,mean(y(:,condition)),'BarWidth',0.5,'LineWidth',1.25); hold on;
    if condition == 1
        set(h,'FaceColor',[0.2 0.2 0.2]);
    elseif condition == 2
        set(h,'FaceColor',[.6 .6 .6]);
    else
        set(h,'FaceColor',[.9 .9 .9]);
    end
end
alpha(0.6)
xt = get(gca,'XTick');
set(gca,'XTick',1:3,'FontSize',16,'XTickLabel',{'None','Sensory readout','Meta noise'})
ylim(ylimits);
ylabel(ylab,'FontSize',24)
xlabel({'Parameter changed'},'FontSize',24)
hold off


end

