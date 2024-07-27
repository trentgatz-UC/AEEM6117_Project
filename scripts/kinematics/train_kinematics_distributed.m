%% Distributed Controller for Kinematics Model
clear; close all; clc;

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
target = [0.1 0.2];

fis = FIS_setup(3);

[in, out, rule] = getTunableSettings(fis);
for i = 1:numel(rule)
    rule(i).Antecedent.Free = false;
    rule(i).Consequent.AllowNot = false;
end

fis.DisableStructuralChecks = true;

fis_options = tunefisOptions('Method', 'ga',...
    'OptimizationType', 'tuning',...
    'Display', 'tuningonly',...
    'UseParallel', true);

% Setting GA optiosn
fis_options.MethodOptions.FunctionTolerance = 1e-6;
fis_options.MethodOptions.ConstraintTolerance = 1e-3;
fis_options.MethodOptions.FitnessLimit = 1;
fis_options.MethodOptions.PopulationSize = 200;
fis_options.MethodOptions.MaxGenerations = 300;
fis_options.MethodOptions.UseParallel = true;
fis_options.MethodOptions.MaxStallGenerations = 65;

stalltime = 2 * 3600; % 2 hour stall for testing
fis_options.MethodOptions.MaxStallTime = stalltime;

w = warning('off', 'all');
fis_trained = tunefis(fis, [in;out;rule], ...
    @(this_fis)cost_function_mw(this_fis, target, robots, k, m, l0), fis_options);

writeFIS(fis_trained, "kinematics_distributed_trained.fis")

%% rerun & make video
% % % fcn = @(t,x) odefcn(t,x,robots,k, m, l0,fis_trained,target);
% % % tspan = [0:.04:20]; % simulation is to run for 20 seconds
% % % y0 = zeros(1,10); % object starts at home position each time
% % % event_fcn = @(t,y) myevent_fcn(t,y,robots);
% % % options = odeset('RelTol', 1e-3, 'Events', event_fcn);
% % % [tout, yout] = ode45(fcn, tspan, y0, options);

[tout, yout] = system_kinematics(fis_trained, robots, target);


vid_framerate = 24; % video frame rate (frames / second)
root = matlab.project.rootProject().RootFolder();
vid_name = fullfile(root,'milestone2_distributed_control');
figure
vid = make_video(vid_name, tout, yout, vid_framerate, robots, target);

function [cost] = cost_function_mw(fis, target, robots)
[tout, yout] = system_kinematics(fis, robots, target);

obj = [yout(:, 1) yout(:, 3)];
dist = sqrt(sum(sum(((obj-target).^2),2))); % distance between object and target @ each time step
cost = dist*10 + 500*(tspan(end) - tout(end));
if sum(yout(:,1)) + sum(yout(:,3)) == 0
    cost = cost + 100;
end
end


