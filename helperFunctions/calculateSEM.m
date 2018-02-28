function [ wsite_sem, bsite_sem ] = calculateSEM(measure)
%Calculate within site and between sites error bars for looking at
%interactions
%Input measure should be the difference in measure between the two halves of the block 

num_subjects = size(measure,1);

%Within site error bars
wsite_sem(:,1) = std(measure(:,1))./sqrt(num_subjects);
wsite_sem(:,2) = std(measure(:,2))./sqrt(num_subjects);
wsite_sem(:,3) = std(measure(:,3))./sqrt(num_subjects);

%Between site error bars
bsite_sem(:,1) = std(measure(:,1)-measure(:,2))./sqrt(num_subjects);
bsite_sem(:,2) = std(measure(:,1)-measure(:,3))./sqrt(num_subjects);
bsite_sem(:,3) = std(measure(:,2)-measure(:,3))./sqrt(num_subjects);


end

