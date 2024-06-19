clc;
clear;
close all;

%% Problem Definition

problem.CostFunction = @(x) Sphere(x);
problem.nVar = 5;
problem.VarMin = [-10 -10 -5 -1 5];
problem.VarMax = [ 10  10  5  1 8];

%% GA Parameters

params.MaxIt = 100;
params.nPop = 1000;

params.beta = 1;
params.pC = 1;
params.gamma = 0.1;
params.mu = 0.02;
params.sigma = 0.1;

%% Run GA

out = RunGA(problem, params);


%% Results

figure;
% plot(out.bestcost, 'LineWidth', 2);
semilogy(out.bestcost, 'LineWidth', 2);
xlabel('Iterations');
ylabel('Best Cost');
grid on;



