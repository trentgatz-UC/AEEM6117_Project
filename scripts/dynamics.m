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
y0(1) = .1;
y0(3) = -.1;
% % pos_ic = [robots(1,1) robots(1,2)] / 15; % moved directly toward a different robot
% % y0(1) = pos_ic(1);
% % y0(3) = pos_ic(2);

fcn = @(t,x) odefcn(t,x,robots,k,m,l0);
tspan = [0 tf];
options = odeset('RelTol', 1e-5);
[t, y] = ode45(fcn, tspan,y0, options);
vid = make_video(vid_name, t, y, vid_framerate, robots, targ);

%% Functions
function vid = make_video(vid_name, t,y, vid_framerate, robots, targ)
for i = 1:size(y,1)
    time = t(i);
    if i == 1
        frame = 1;
    elseif time < (t_prev+1/vid_framerate)
        continue
    end
    display(robots, [y(i,1) y(i,3)], targ, time)
    drawnow
    vid(frame) = getframe(gcf);
    t_prev = time;
    frame = frame+1;
end
vidfile = VideoWriter(vid_name, 'MPEG-4');
vidfile.FrameRate = vid_framerate;
open(vidfile)
writeVideo(vidfile,vid)
close(vidfile)
end

function d2ydt2 = odefcn(t, x, robots, k, m, l0)
% odefch
% t - time
% x object position and velocity
%   [x pos; x vel; y pos; y vel]
% robots - static robot positions
% k - spring constant
% m - object mass
% l0 - minimum cable length



obj = [x(1) x(3)];
N = size(robots,1); % number of robots
rbi = robots - obj; %  vectors from robots to objects
rbi_hat = unitvect(rbi); %unit vectors from robots to object

d2ydt2 = zeros(4,1);

d2ydt2(1) = x(2);
d2ydt2(2) = k/m*l0*(sum(rbi_hat(:,1))) - N*x(1);
d2ydt2(3) = x(4);
d2ydt2(4) = k/m*l0*(sum(rbi_hat(:,2))) - N*x(3);
end

function [uv] = unitvect(vect)
uv = vect ./ vecnorm(vect,2,2);
end

function display(robots, obj, targ, time, verify)
arguments
    robots
    obj
    targ
    time
    verify = false
end
hold off
plot([robots(:,1); robots(1,1)], [robots(:,2); robots(1,2)]) % Outline
hold on
plot(0,0, 'go') % Home Position
plot(targ(1), targ(2), 'ro') % Target Position
plot(obj(1), obj(2),'m*') % Obj Position

for cable = 1:size(robots,1)
    plot([obj(1) robots(cable,1)], [obj(2) robots(cable,2)], 'k--')
end

if verify % show lines from robots to origin
    % used for verification of ode setup
    plot([0 robots(1,1)], [0 robots(1,2)]) 
    plot([0 robots(2,1)], [0 robots(2,2)]) 
    plot([0 robots(3,1)], [0 robots(3,2)]) 
end
title('Robot Dynamics')
grid on
XL = xlim;
YL = ylim;
text(XL(1), YL(2)*.95, ['Time: ' num2str(time,'%.2f') ' seconds'])
end

function [state] = isvalidtarget(target, robots)
% isvalidtarget - true if target within robot workspace

state = false;

% Right half eqn
eqn1 = (robots(3,2) - robots(2,2)) / (robots(3,1) - robots(2,1)) + robots(2,1);

% Left Half Eqn
eqn2 = (robots(1,2) - robots(2,2)) / (robots(1,1) - robots(2,1)) + robots(1,1);

% Bottom
eqn = robots(1,2);

end