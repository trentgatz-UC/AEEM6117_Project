function mydisplay(robots, obj, targ, time, verify)
% display - plot instantaneous state of simulation
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