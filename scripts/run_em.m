clear; close all; clc
%% General Constants
% Givens
k = 95.54; % N/m - spring stiffness
m = 0.01; % kg - mass
l0 = 1; % m - minimum length
a = 0.866; % m - distance between robots
tspan = [0:.001:20];


%%Robot Positions
r1 = [-a/2 -a*tand(30)/2];  % bottom left
r2 = [0 a/(2*cosd(30))];    % top
r3 = [a/2 -a*tand(30)/2];   % bottom right
robots = [r1; r2; r3];
% target = [-.05 -.05];

tspan = [0:.001:20]; % simulation is to run for 20 seconds

%% Dynamics Distributed
event_fcn = @(t,y) myevent_fcn(t,y,robots);
options = odeset('RelTol', 1e-3, 'Events', event_fcn);
% dd_fcn = @(target,t,x) odefcn(t,x,robots,k,m,l0,dynamics_fis,target);
fis = readfis("DD_FIS_FINAL.fis");
y0 = zeros(1,10);
dd_fcn = @(target) ode45(@(t,x)odefcn(t,x,robots,k,m,l0,fis,target), tspan, y0, options);


dd_tbl = run_em_all(dd_fcn);

%% Dynamics Centralized

%% Kinematics Centralized



function [tbl] = run_em_all(sim_fcn)
% run all cases

% sim_fcn - function handle to create data points


%Import standardized set of testing targets
data = load("testing_targets.mat");
targets = data.targets;
tbl = table();
for i = 1:1%size(targets,1) %#todo uncomment this to run all 20 cases
    % target = targets(i,:);
    target = [-.05 -.05];
    % run simulation
    [tout, yout] = sim_fcn(target);

    obj = [yout(:,1) yout(:,3)];
    final_position = [yout(end,1) yout(end,3)];
    total_distance = sqrt(sum(sum(((obj-target).^2),2)));
    final_distance = sqrt(sum(sum(((final_position-target).^2),2)));
    temp = table(target, final_position, final_distance, total_distance, 'VariableNames', {'Target', 'Final Postion', 'Final Distance', 'Total Distance'});
    tbl = [tbl; temp];
end
end







