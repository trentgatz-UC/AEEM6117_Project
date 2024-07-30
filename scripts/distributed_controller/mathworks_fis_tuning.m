%% Mathworks Built in FIS Tuning Methods
% Distributed Controller
clear; close all; clc;

root = matlab.project.rootProject().RootFolder;
%% Givens
k = 95.54; % N/m - spring stiffness
m = 0.01; % kg - mass
l0 = 1; % m - minimum length
a = 0.866; % m - distance between robots
tf = 20; % sec - maximum simulation time

%% Robot Positions
r1 = [-a/2 -a*tand(30)/2];  % bottom left
r2 = [0 a/(2*cosd(30))];    % top
r3 = [a/2 -a*tand(30)/2];   % bottom right
robots = [r1; r2; r3];
target = [-.05 -.05];

% fis = readfis("RobotController.fis");
fis = FIS_setup(5);

[in, out, rule] = getTunableSettings(fis);
for i = 1:numel(rule)
    rule(i).Antecedent.Free = false;
    rule(i).Consequent.AllowNot = false;
end

fis.DisableStructuralChecks = true;

fis_options = tunefisOptions('Method', 'ga',...
    'OptimizationType', 'tuning',...
    'Display', 'tuningonly',...
    'UseParallel', false);

% Setting GA optiosn
fis_options.MethodOptions.FunctionTolerance = 1e-3;
fis_options.MethodOptions.ConstraintTolerance = 1e-3;
fis_options.MethodOptions.FitnessLimit = 1;
fis_options.MethodOptions.PopulationSize = 5;
fis_options.MethodOptions.MaxGenerations = 2;
fis_options.MethodOptions.UseParallel = false;
fis_options.MethodOptions.MaxStallGenerations = 65;

stalltime = 2 * 3600; % 1 hour stall for testing
fis_options.MethodOptions.MaxStallTime = stalltime;

w = warning('off', 'all');
fis_trained = tunefis(fis, [in;out;rule], ...
    @(this_fis)cost_function_mw(this_fis, target, robots, k, m, l0), fis_options);

writeFIS(fis_trained, fullfile(root,"distributed_FIS_trained_point2.fis"))

%% rerun & make video

fcn = @(t,x) odefcn(t,x,robots,k, m, l0,fis_trained,target);
tspan = [0:.001:20]; % simulation is to run for 20 seconds
y0 = zeros(1,10); % object starts at home position each time
event_fcn = @(t,y) myevent_fcn(t,y,robots);
options = odeset('RelTol', 1e-3, 'Events', event_fcn);
[tout, yout] = ode45(fcn, tspan, y0, options);

vid_framerate = 24; % video frame rate (frames / second)
root = matlab.project.rootProject().RootFolder();
vid_name = fullfile(root,'milestone2_distributed_control_point2');
figure
vid = make_video(vid_name, tout, yout, vid_framerate, robots, target);
save(fullfile(root,"distributed_control_test_point2.mat"))

function [cost] = cost_function_mw(fis, target, robots, k, m, l0)
% cost function for the centralized case
event_fcn = @(t,y) myevent_fcn(t,y,robots);

options = odeset('RelTol', 1e-3, 'Events', event_fcn);
fcn = @(t,x) odefcn(t,x,robots,k, m, l0,fis,target);
tspan = [0:.001:20]; % simulation is to run for 20 seconds
y0 = zeros(1,10); % object starts at home position each time
[tout, yout] = ode45(fcn, tspan, y0, options);         % trying with 15s to see if problem is too stiff

obj = [yout(:, 1) yout(:, 3)];
dist = sqrt(sum(sum(((obj-target).^2),2))); % distance between object and target @ each time step
cost = dist*10 + 500*(tspan(end) - tout(end));
if sum(yout(:,1)) + sum(yout(:,3)) == 0
    cost = cost + 100;
end
end


