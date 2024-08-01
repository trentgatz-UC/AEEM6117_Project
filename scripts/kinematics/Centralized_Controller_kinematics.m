%% Centralized Controller - Kinematics Case
clear; close all; clc;
root = matlab.project.rootProject().RootFolder();
save_dir = fullfile(root, 'kinematics');
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
fis = readfis("RobotController_centralized_kin.fis");
[in, out, rule] = getTunableSettings(fis);
for i = 1:numel(rule)
    rule(i).Antecedent.Free = false;
    rule(i).Consequent.AllowNot = false;
end

parallel_state = true;
fis.DisableStructuralChecks = true;
fis_options = tunefisOptions('Method', 'ga',...
    'OptimizationType', 'tuning',...c
    'Display', 'tuningonly',...
    'UseParallel', parallel_state);

%% Setting GA Options
fis_options.MethodOptions.FunctionTolerance = 1e-3;
fis_options.MethodOptions.ConstraintTolerance = 1e-3;
fis_options.MethodOptions.FitnessLimit = 1;
fis_options.MethodOptions.PopulationSize = 450;
fis_options.MethodOptions.MaxGenerations = 150;
fis_options.MethodOptions.UseParallel = parallel_state;
fis_options.MethodOptions.MaxStallGenerations = 65;

stalltime = 5 * 3600; % 1 hour stall for testing
fis_options.MethodOptions.MaxStallTime = stalltime;


%% Train & Save
w = warning('off', 'all');

system_fcn = @(input1)system_kinematics(input1, robots, target);
fis_trained = tunefis(fis, [in;out;rule], ...
    @(this_fis)cost_function(this_fis, target, system_fcn), fis_options, system_fcn);

writeFIS(fis_trained, fullfile(save_dir, "kinematics_FIS_trained.fis"))
save(fullfile(save_dir, "kinematics_fis_output.mat"))

%% rerun & make video
[tout, yout] = system_fcn(fis_trained);

vid_framerate = 24; % video frame rate (frames / second)
vid_name = fullfile(save_dir,'milestone2_kinematics_control');
figure
vid = make_video(vid_name, tout, yout, vid_framerate, robots, target);

function [t, yout] = system_kinematics(fis, robots, target)
% system_kinematics - Distributed Control Case
w = warning('off', 'all');
% u - control input (volts)

%% Givens
l0 = 1; % m - minimum length
% initial conditions & time vector
dt = .01;
t =[0:dt:20];
y0 = zeros(2,1); % initial conditions for voltage to spooled cable length
% tspan = [0 dt];
tspan = t;
obj = [0 0];

% State Space Matrices
C = [0 1/2];
D = [0];

x_kin(1) = 0;
y_kin(1) = 0;


%% Solving Loop
for k=2:size(t,2)
    %% Based on current position of object & target, use controller to find input voltages
    fis_input = obj - target;
    voltage_input = evalfis(fis, fis_input);
    
    p = voltage_input; % without dynamics (and zero gain) p = voltage input
    p = p + (2-0.866); % adjust by initial condition to get absolute length of spooled cable
    %% Based on spooled cable length & kinematic equations, WHERE is the object
    rbi = robots - obj;
    rbi_hat = Utils.unitvect(rbi);    % unit vectors from robots to object

    rb = ((p(1)-l0)*(rbi_hat(1,:))+(p(2)-l0)*(rbi_hat(2,:))+(p(3)-l0)*(rbi_hat(3,:))) / 3;

    x_kin(k)= rb(1);
    y_kin(k)= rb(2);

    % obj = [obj(1)+x_kin(k), obj(2)+y_kin(k)];
    obj = [x_kin(end) y_kin(end)]; % not sure, i think this is right, don't know why we'd be adding
end

yout = nan(length(t), 4);
yout(:,1)= x_kin;
yout(:,3)= y_kin;
end


