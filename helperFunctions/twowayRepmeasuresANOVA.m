function [] = twowayRepmeasuresANOVA(y1,y2)
%This function is used to perform a 2-way repeated measures ANOVA on the measure
%Factor 1 = TMS condition - 3 levels (S1, DLPFC, aPFC), Factor 2 =
%Time - 2 levels (first half of blocks, second half of blocks)
 
% Each y is a matrix of values from all the three TMS conditions
%y1 - first half of blocks; y2 - second half of blocks
%Columns of y - TMS site - col1 - S1;  col2 - DLPFC;  col3 - aPFC;  
%Rows of y - Subjects

y1 = reshape(y1,[],1); y2 = reshape(y2,[],1);
y = [y1;y2];
time(1:length(y1)) = 1; time(length(y1)+1:2*length(y1)) = 2;
conditions2(1:length(y1)/3) = {'S1'}; conditions2(length(y1)/3+1:2*length(y1)/3) = {'DLPFC'}; conditions2(2*length(y1)/3+1:length(y1)) = {'aPFC'};
conditions2(length(y1)+1:length(y1)+length(y1)/3) = {'S1'}; conditions2(length(y1)+length(y1)/3+1:length(y1)+2*length(y1)/3) = {'DLPFC'}; conditions2(length(y1)+2*length(y1)/3+1:2*length(y1)) = {'aPFC'};
subjects = [1:length(y1)/3 1:length(y1)/3 1:length(y1)/3 1:length(y1)/3 1:length(y1)/3 1:length(y1)/3 ]';
p = anovan(y,{conditions2; subjects; time},'random',2,'varnames',{'TMS site';'Subjects';'Time'},'model','interaction');



end

