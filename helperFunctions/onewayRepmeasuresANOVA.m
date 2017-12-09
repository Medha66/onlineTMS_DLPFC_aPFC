function [] = onewayRepmeasuresANOVA(y)
%This function performs a one-way repeated measures ANOVA on y 
%Factor - TMS site (3 levels; S1, DLPFC, aPFC)

%y is a matrix of values from all the three TMS conditions
%Columns - TMS site - col1 - S1;  col2 - DLPFC;  col3 - aPFC;  
%Rows - Subjects

% One-way repeated measures ANOVA
y = reshape(y,[],1);
subjects = [1:length(y)/3 1:length(y)/3 1:length(y)/3];
subjects = reshape(subjects,[],1);
conditions(1:length(y)/3) = {'aPFC'}; conditions(length(y)/3+1:2*length(y)/3) = {'DLPFC'}; conditions(2*length(y)/3+1:length(y)) = {'S1'};
p = anovan(y,{conditions; subjects},'random',2,'varnames',{'TMS site';'Subjects'});

end

