%% Final
clear; close all; clc;
addpath(genpath(pwd))
%% Setup
nMFs = 5;

%% Load Data
data = '..\data\forestfires.csv';
data = readtable(data);
% Convert String inputs to numbers
for i = 1:size(data,1) 
    data.month{i} = GeneValidation.convert_month(data.month{i});
    data.day{i} = GeneValidation.convert_day(data.day{i});
end
data.month = cell2mat(data.month);
data.day = cell2mat(data.day);

%Normalize Data to #MFs

for i = 1:size(data,2)
    data.(i) = data.(i) / max(data.(i)) * nMFs;
end

%% Test / Train Data Split
idx = randperm(numel(data(:,1)),round(numel(data(:,1))*80/100));
train_values = data(idx,:);

nums = 1:size(data,1);
idx2 = setdiff(find(nums),idx);
validate_values = data(idx2,:);

%% Setup & Run GA
nInpts = size(data,2)-1;
len_gene = GeneDefinition.calc_gene_length(nMFs);

PROBLEM.fitnessfcn = @(x) cost_fcn(x, nMFs, train_values);
PROBLEM.lb = 0;
PROBLEM.ub = nMFs;
PROBLEM.nvars = nInpts*len_gene;
PROBLEM.options = optimoptions('ga', 'PlotFcn', {@gaplotbestf, @gaplotrange}, 'UseParallel', true, 'PopulationSize', 100000); % don't think I need this level of depth at first
[x,fval,exitflag,output,population,scores] = ga(PROBLEM);
best_FIS = x;
save('matlab_ga_100k')

%% Validation Data Set
area.true = validate_values.area;
area.est = hFIS(validate_values, best_FIS, nMFs);
x = 1:length(area.est);
figure;
plot(x, area.true, x, area.est)
legend('Actual','Estimate')
title('Actual vs Estimated Area')
xlabel('case')
ylabel('area')

figure;
semilogy(out.bestcost, 'LineWidth', 2);
xlabel('Iterations');
ylabel('Best Cost');
grid on;
title('Cost over Iterations')

