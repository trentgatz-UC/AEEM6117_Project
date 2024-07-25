%% Centralized Controller
%{
Train a fis to simultaneously control all 3 robots so that the object
reaches the target position
%}
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

nMFs =3;

nvars = nMFs*6 + 27*3; % 3*3 inputs, 3*3 outputs, 3*27 rules
PopRange = [-1*ones(1,3) -10*ones(1,3*5) zeros(1,27*3);...
    ones(1,3) 10*ones(1,3*5) nMFs*ones(1,27*3)];
fis = readfis('RobotController_centralized.fis');
fis.DisableStructuralChecks = true; % speed up FIS updates

options = optimoptions('ga', 'FunctionTolerance', 1e-3, 'ConstraintTolerance', 1e-3, 'FitnessLimit', 9,...
    'PlotFcn', {@gaplotbestf, @gaplotrange}, 'UseParallel', true, 'PopulationSize', 10); 
fitnessfcn = @(vec) cost_function_centralized(vec, fis, target, robots, k, m, l0);

%46:nvars if not using shrunk definition of MFs
% % % delete(gcp('nocreate'))
% % % parpool('Processes');

[bestfis,fit] = ga(fitnessfcn,nvars,[],[],[],[],PopRange(1,:),PopRange(2,:),[],19:nvars,options);  % Optimising using GA. Check the syntax of GA to understand each element.
save('centralized_controller');

fis = gen_fis_centralized_2(fis, bestfis);
event_fcn = @(t,y) myevent_fcn(t,y,robots);
fcn = @(t,x) odefcn_centralized(t,x,robots,k, m, l0,fis,target);
tspan = [0 20]; % simulation is to run for 20 seconds
y0 = zeros(1,4); % object starts at home position each time
options = odeset('RelTol', 1e-3, 'Events', event_fcn, Stats='on');
[tout, yout] = ode45(fcn, tspan, y0, options);

vid_framerate = 24; % video frame rate (frames / second)
root = matlab.project.rootProject().RootFolder();
vid_name = fullfile(root,'milestone2_centralized_control');
figure
vid = make_video(vid_name, tout, yout, vid_framerate, robots, target);