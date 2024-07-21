%% Dynamics First Pass
clear; close all; clc;
%% Inputs
targ = [.5 .5];
vid_framerate = 24; % video frame rate (frames / second)
vid_name = '..\Output\milestone1';

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

%% Initialize ODE
% Begins at home conditions with no velocity

y0 = zeros(4,1);
% y0(1) = .1;
% y0(3) = -.1;

pos_ic = [robots(1,1) robots(1,2)] / 15; % moved directly toward a different robot
y0(1) = pos_ic(1);
y0(3) = pos_ic(2);


fcn = @(t,x) odefcn_unforced(t,x,robots,k,m,l0);
tspan = [0 tf];
options = odeset('RelTol', 1e-5);
[t, y] = ode45(fcn, tspan,y0, options);
vid = make_video(vid_name, t, y, vid_framerate, robots, targ);
plot_pos_vel(t, y, robots)

%% Dynamics Functions
function d2ydt2 = odefcn_unforced(t, x, robots, k, m, l0)
% odefch
% t - time
% x object position and velocity
%   [x pos; x vel; y pos; y vel]
% robots - static robot positions
% k - spring constant
% m - object mass
% l0 - minimum cable length

obj = [x(1) x(3)];
Utils.isValidCableLength(robots, obj);
N = size(robots,1); % number of robots
rbi = robots - obj; %  vectors from robots to objects
rbi_hat = Utils.unitvect(rbi); %unit vectors from robots to object

d2ydt2 = zeros(4,1);

d2ydt2(1) = x(2);
d2ydt2(2) = k/m*l0*(sum(rbi_hat(:,1))) - N*x(1);
d2ydt2(3) = x(4);
d2ydt2(4) = k/m*l0*(sum(rbi_hat(:,2))) - N*x(3);
end

%% Visualization Functions


function [f] = plot_pos_vel(time, y, robots)
x_pos = y(:,1);
x_vel = y(:,2);
y_pos = y(:,3);
y_vel = y(:,4);

obj = [x_pos y_pos];

cable_lengths = nan(length(obj), 3);
for i = 1:length(obj)
    cable_lengths(i,:) = Utils.get_cable_lengths(robots, obj(i,:));
end
cable_vels = diff(cable_lengths)./diff(time);

f = figure;
subplot(2,1,1)
title('Positions')
hold on
for i = 1:size(cable_lengths,2)
    plot(time, cable_lengths(:,i), 'DisplayName', ['Robot ' num2str(i)])
end
grid on; legend show;
ylabel('[m]')

subplot(2,1,2)
title('Velocities')
hold on;
for i = 1:size(cable_vels,2)
    plot(time(2:end), cable_vels(:,i), 'DisplayName', ['Robot ' num2str(i)])
end
grid on; legend show;
xlabel('Time [s]'); ylabel('[m/s]')
end

%% Misc.


%% Validation Functions
