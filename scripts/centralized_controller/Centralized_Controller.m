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

function d2ydt2 = odefcn_centralized(t, x, robots, k, m, l0, fis, target)
% odefcn
% t - time
% x object position and velocity
%   [x pos; x vel; y pos; y vel]
% robots - static robot positions
% k - spring constant
% m - object mass
% l0 - minimum cable length

%{
x(1) = x_position of object
x(2) = x_velocity of object
x(3) = y_position of object
x(4) = y_velocity of object

x(5) = cable length of robot 1
x(6) = cable velocity of robot 1
x(7) = cable length of robot 2
x(8) = cable velocity of robot 2
x(9) = cable length of robot 3
x(10) = cable velocity of robot 3
%}

obj = [x(1) x(3)];
Utils.isValidCableLength(robots, obj);
N = size(robots,1);         % number of robots
rbi = robots - obj;         % vectors from robots to objects
rbi_hat = Utils.unitvect(rbi);    % unit vectors from robots to object

%% Define State Space Equations Matrices for the Motor (Constants)
%{
Defines transfer function from input voltage to the change in spooled
cable.
These state space matrices are based on the following assumptions:
1. Gear ratio = 0
2. Spool Inertia = 1
3. Spool Damping = 0
4. Resistance = 1
5. Inductance = 1
6. Ke = 1
7. r_spool = 1
%}
A = [0 -1/2; 1 0];
B = [1;0];
C = [0 1/2];
D = [0];

%% Controller Calculation of Input Voltage
%{
Determine input voltages based on current system state
%}
warning('off', 'all');
x_error = obj(1) - target(1);
y_error = obj(2) - target(2);
fis_input =[x_error y_error];
voltage_input = evalfis(fis ,fis_input);

%% Controller Dynamics
%{
Calculate change in spooled cable based on input voltage by solving the
state space equation
%}
dxdy_motor = nan(1,6);
p = nan(1,3);
for i = 1:N
    x_motor = x(3+2*i:4+2*i); % Individual Motor state vector
    u = voltage_input(i); % Individual Motor input voltage

    dxdy_motor((2*i)-1:2*i) = A*x_motor + B*u; %State vector of all motors

    p(i) = C*x_motor + D*u; % cable position & velocity
end

p = p + 2-0.866; %p above is delta spool, add initially spooled length

%% Combined System Dynamics
%{
Calculate object position based on change in spooled cable lengths
- Ensure y0 (initial cable length) is set properly in inputs to system
%}
d2ydt2 = zeros(10,1);
d2ydt2(1) = x(2);
d2ydt2(2) = k/m*(p-l0)*(rbi_hat(:,1)) - N*x(1)/m; % should this last term be divided by m ?, make system stiffer
d2ydt2(3) = x(4);
d2ydt2(4) = k/m*(p-l0)*(rbi_hat(:,2)) - N*x(3)/m;

d2ydt2(5:10) = dxdy_motor;
end


