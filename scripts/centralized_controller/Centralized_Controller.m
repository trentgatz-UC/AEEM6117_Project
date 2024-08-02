%% Centralized Controller - Dynamics Case
clear; close all; clc;
root = matlab.project.rootProject().RootFolder();
save_dir = fullfile(root, 'centralized_controller');
%% Givens
k = 95.54; % N/m - spring stiffness
m = 0.01; % kg - mass
l0 = 1; % m - minimum length
a = 0.866; % m - distance between robots
tspan = [0:.001:20];


%% Robot Positions
r1 = [-a/2 -a*tand(30)/2];  % bottom left
r2 = [0 a/(2*cosd(30))];    % top
r3 = [a/2 -a*tand(30)/2];   % bottom right
robots = [r1; r2; r3];
target = [-.05 -.05];

%% Setting up FIS
fis = readfis("RobotController_centralized.fis");
[in, out, rule] = getTunableSettings(fis);
for i = 1:numel(rule)
    rule(i).Antecedent.Free = false;
    rule(i).Consequent.AllowNot = false;
end

fis.DisableStructuralChecks = true;

fis_options = tunefisOptions('Method', 'ga',...
    'OptimizationType', 'tuning',...c
    'Display', 'tuningonly',...
    'UseParallel', true);

%% Setting GA Options
fis_options.MethodOptions.FunctionTolerance = 1e-3;
fis_options.MethodOptions.ConstraintTolerance = 1e-3;
fis_options.MethodOptions.FitnessLimit = 1;
fis_options.MethodOptions.PopulationSize = 500;
fis_options.MethodOptions.MaxGenerations = 200;
fis_options.MethodOptions.UseParallel = true;
fis_options.MethodOptions.MaxStallGenerations = 65;

stalltime = 12 * 3600; % 1 hour stall for testing
fis_options.MethodOptions.MaxStallTime = stalltime;


%% Train & Save
w = warning('off', 'all');

system_fcn = @(input1)sim_system(tspan, target, robots,k,m,l0,input1);
fis_trained = tunefis(fis, [in;out;rule], ...
    @(this_fis)cost_function(this_fis, target, system_fcn), fis_options, system_fcn);

writeFIS(fis_trained, fullfile(save_dir, "centralized_FIS_trained.fis"))
save(fullfile(save_dir, "centralized_fis_output.mat"))

%% rerun & make video
[tout, yout] = system_fcn(fis_trained);

vid_framerate = 24; % video frame rate (frames / second)
vid_name = fullfile(save_dir,'milestone2_centralized_control');
figure
vid = make_video(vid_name, tout, yout, vid_framerate, robots, target);

function [tout, yout] = sim_system(tspan, target, robots, k, m, l0, fis)
event_fcn = @(t,y) myevent_fcn(t,y,robots);
ode_options = odeset('RelTol', 1e-3, 'Events', event_fcn);
fcn = @(t,x) odefcn_centralized(t,x,robots,k, m, l0,fis,target);
y0 = zeros(1,10); % object starts at home position each time
[tout, yout] = ode45(fcn, tspan, y0, ode_options);
end



