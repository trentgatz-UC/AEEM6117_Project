%% Final
clear; close all; clc;
addpath(genpath(pwd))


%% Setup
nMFs = 5;
%% Load & Manipulate Data

data = '..\data\forestfires.csv';
data = readtable(data);
% Convert String inputs to numbers
for i = 1:size(data,1) 
    data.month{i} = GeneValidation.convert_month(data.month{i});
    data.day{i} = GeneValidation.convert_day(data.day{i});
end
data.month = cell2mat(data.month);
data.day = cell2mat(data.day);
for i = 1:size(data,2)
    if min(data.(i)) < 0
        data.(i) = data.(i) - min(data.(i));
    end
    data.(i) = data.(i) / max(data.(i))*nMFs;
end

% % % data(:, 1:4) = [];
% % % nVars = size(data,2)-1;
%% Test / Train Data Split
% % idx = randperm(numel(data(:,1)),round(numel(data(:,1))*80/100));
% % train_values = data(idx,:);
% % 
% % nums = 1:size(data,1);
% % idx2 = setdiff(find(nums),idx);
% % validate_values = data(idx2,:);
train_values = data;
validate_values = data;
%% Setup & Run GA
nInpts = size(data,2)-1;
len_gene = GeneDefinition.calc_gene_length(nMFs);

PROBLEM.fitnessfcn = @(x) cost_fcn(x, nMFs, train_values);
PROBLEM.nvars = (nInpts-1)*len_gene;
PROBLEM.lb = zeros(1, PROBLEM.nvars);
PROBLEM.ub = ones(1, PROBLEM.nvars)*nMFs;
PROBLEM.options = optimoptions('ga', 'PlotFcn', {@gaplotbestf, @gaplotrange}, 'UseParallel', true, 'PopulationSize', 10000); % don't think I need this level of depth at first
[x,fval,exitflag,output,population,scores] = ga(PROBLEM);
best_FIS = x;
% save('final_out_pop10k_5MF_8VAR_v2')
save('testout.mat')
%% Validation Data Set
area.true = validate_values.area;
area.est = hFIS(validate_values, best_FIS, nMFs);
x = 1:length(area.est);
figure;
plot(x, area.true, x, area.est)
legend('Area','Estimate')
title('Testing Set','Interpreter','none')
xlabel 'Cases'
ylabel 'Burned Area'
disp('validation set')
confusion_matrix


% same plot but with the training set
area.true = train_values.area;
area.est = hFIS(train_values, best_FIS, nMFs);
x = 1:length(area.est);
figure;
plot(x, area.true, x, area.est)
legend('Area','Estimate')
title('Training Set','Interpreter','none')

xlabel 'Cases'
ylabel 'Burned Area'

disp('training set')
confusion_matrix