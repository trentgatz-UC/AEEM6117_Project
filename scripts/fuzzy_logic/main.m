%% Midterm 1 -- Trent Gatz
clear all; close all; clc;
addpath(genpath(pwd));

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
nMFs = 5;
for i = 1:size(data,2)
    data.(i) = data.(i) / max(data.(i)) * nMFs;
end

%% GA Test / Validate
% 80 / 20 Split of Test vs Train Data
idx = randperm(numel(data(:,1)),round(numel(data(:,1))*80/100));
train_values = data(idx,:);

nums = 1:size(data,1);
idx2 = setdiff(find(nums),idx);
validate_values = data(idx2,:);

%% GA Setup
%Problem Struct


nInpts = size(data,2)-1;

len_gene = GeneDefinition.calc_gene_length(nMFs);
problem.nVar = nInpts*len_gene;
problem.CostFunction = @(x) cost_fcn(x,nMFs, train_values);
problem.Validate = @(x) GeneValidation.validate(x, nMFs);

% for 3 membership functions, each FIS will have 18 chromosomes
    % total length should be 216

%default min/max from [1 nMFs^2] to initialize all rule sets
%   intermediate FIS's are normalized about nMFs^2 so that input membership
%   functions make sense
problem.VarMin = zeros(1, problem.nVar);
problem.VarMax = nMFs * ones(1, problem.nVar);
% Set specific values that mattter

% % % %Input 1
% % % problem.VarMin(1:nMFs) = 0;
% % % problem.VarMax(1:nMFs) = 10;
% % % 
% % % %Input 2
% % % problem.VarMin(nMFs+1 : 2*nMFs) = 0;
% % % problem.VarMax(nMFs+1 : 2*nMFs) = 10;
% % % 
% % % %Input 3 - Month
% % % i = 1;
% % % problem.VarMin(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 1;
% % % problem.VarMax(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 12;
% % % 
% % % %Input 4 - Day of Week
% % % i = 2;
% % % problem.VarMin(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 1;
% % % problem.VarMax(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 7;
% % % 
% % % %Input 5 - FFMC
% % % i = 3;
% % % problem.VarMin(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 0;
% % % problem.VarMax(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 100;
% % % 
% % % %Input 6 - DMC
% % % i = 4;
% % % problem.VarMin(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 0;
% % % problem.VarMax(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 300;
% % % 
% % % %Input 7 - DC
% % % i = 5;
% % % problem.VarMin(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 0;
% % % problem.VarMax(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 1000;
% % % 
% % % %Input 8 - ISI
% % % i = 6;
% % % problem.VarMin(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 0;
% % % problem.VarMax(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 100;
% % % 
% % % %Input 9 - Temperature
% % % i = 7;
% % % problem.VarMin(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 0;
% % % problem.VarMax(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 40;
% % % 
% % % %Input 10 - RH
% % % i = 8;
% % % problem.VarMin(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 0;
% % % problem.VarMax(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 100;
% % % 
% % % %Input 11 - Wind
% % % i = 9;
% % % problem.VarMin(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 0;
% % % problem.VarMax(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 10;
% % % 
% % % %Input 12 - Rain
% % % i = 10;
% % % problem.VarMin(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 0;
% % % problem.VarMax(len_gene*i +nMFs+1 : len_gene*i+2*nMFs) = 6.4;


% Rules Placed Inbetween variables (gene makes more sense this way)


%problem.VarMin = [0*ones(1, 3*nMFs) 0*ones(1, 3*nMFs) ones(1, nMFs^2) 1*ones(1, 3*nMFs) ones(1, nMFs^2) 1*ones(1, 3*nMFs) ones(1, nMFs^2) 0*ones(1, 3*nMFs) ones(1, nMFs^2) 0*ones(1, 3*nMFs) ones(1, nMFs^2) 0*ones(1, 3*nMFs) ones(1, nMFs^2) 0*ones(1, 3*nMFs) ones(1, nMFs^2) 0*ones(1, 3*nMFs) ones(1, nMFs^2) 15*ones(1, 3*nMFs) ones(1, nMFs^2) 0*ones(1, 3*nMFs) ones(1, nMFs^2) 0*ones(1, 3*nMFs) ones(1, nMFs^2)];
%problem.VarMax = [10*ones(1, 3*nMFs) 10*ones(1, 3*nMFs) ones(1, nMFs^2) 12*ones(1, 3*nMFs) ones(1, nMFs^2) 7*ones(1, 3*nMFs) ones(1, nMFs^2) 100*ones(1, 3*nMFs) ones(1, nMFs^2) 300*ones(1, 3*nMFs) ones(1, nMFs^2) 1000*ones(1, 3*nMFs) ones(1, nMFs^2) 70*ones(1, 3*nMFs) ones(1, nMFs^2) 35*ones(1, 3*nMFs) ones(1, nMFs^2) 100*ones(1, 3*nMFs) ones(1, nMFs^2) 10*ones(1, 3*nMFs) ones(1, nMFs^2) 10*ones(1, 3*nMFs) ones(1, nMFs^2)];
% make sure min / max values make sene
%esp for DMC, DC, ISI


%Params Struct
% best set for midterm
params.MaxIt = 2000;
params.nPop = 1000;
params.beta = 0.8; %corss over related
params.pC = 1;
params.gamma = 0.35; % related to crossover
params.mu = 0.15; %mutation rate
params.sigma = 0.8; %much much values can mutate byt



%% Train via GA
delete(gcp('nocreate')) % ensure no parallel pool is running
parpool('Threads');
out = RunGA(problem, params, nMFs);
delete(gcp('nocreate')) % ensure no parallel pool is running
best_FIS = out.bestsol.Position;
save('output')

%% Validate
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
% saveas(gcf, 'cost_per_it.png')
% close gcf

%% Cost Comparison - Train vs Validate
% cost_train = cost_fcn(best_FIS, nMFs, train_values);
% cost_val = cost_fcn(best_FIS, nMFs, validate_values);
% cost_train_norm = cost_train / length(train_values);
% cost_val_norm = cost_val / length(validate_values);
% 
% fprintf('Cost of training: %.02f; Normalized Cost of training: %.04f\n', cost_train, cost_train_norm)
% fprintf('Cost of validation: %.02f; Normalized Cost of validation: %.04f\n', cost_val, cost_val_norm)

%% Save Rulebase for report
% best_MF = array_to_MF(best_FIS, nMFs);
% csvwrite('rulebase.csv', best_MF.Rules)
