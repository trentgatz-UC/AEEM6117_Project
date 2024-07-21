%% Centralized Controller
%{
Train a fis to simultaneously control all 3 robots so that the object
reaches the target position
%}
clear all; close all; clc;
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
targets = Utils.generate_training_targets(20, robots);

nMFs =3;
nvars = 99; % 3 inputs * 3 params * 3 mfs + 2 ouputs * 3 params * 3 mfs + 27 *2 rules
fis = FIS_setup_centralized;
options = gaoptimset('Generations',50,'PopulationSize',20,'StallGenLimit',50,'TolFun',1e-12,'Display','iter', 'PlotFcn', @gaplotbestf, 'UseParallel',false); % setting the options in GA.
fitnessfcn = @(vec) cost_function_centralized(vec, fis, targets, robots, k, m, l0);

PopRange = [-1*ones(1,9) -10*ones(1,9) -10*ones(1,9) -10*ones(1,9) -10*ones(1,9) ones(1,27*2);...
    ones(1,9) 10*ones(1,9) 10*ones(1,9) 10*ones(1,9) 10*ones(1,9) nMFs*ones(1,27*2)];

[bestfis,fit] = ga(fitnessfcn,nvars,[],[],[],[],PopRange(1,:),PopRange(2,:),[],46:nvars,options);  % Optimising using GA. Check the syntax of GA to understand each element.
save('centralized_controller');

fis = gen_fis_centralized(fis, bestfis);

 fcn = @(t,x) odefcn_centralized(t,x,robots,k, m, l0,fis,target);
tspan = [0 20]; % simulation is to run for 20 seconds
y0 = zeros(1,4); % object starts at home position each time
[tout, yout] = ode45(fcn, tspan, y0, options);

vid_framerate = 24; % video frame rate (frames / second)
vid_name = '..\Output\milestone1';

vid = make_video(vid_name, tout, yout, vid_framerate, robots, target);