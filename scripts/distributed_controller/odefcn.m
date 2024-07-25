function d2ydt2 = odefcn(t, x, robots, k, m, l0, fis, target)
% odefcn
% t - time
% x object position and velocity
%   [x pos; x vel; y pos; y vel]
% robots - static robot positions
% k - spring constant
% m - object mass
% l0 - minimum cable length

obj = [x(1) x(3)];
Utils.isValidCableLength(robots, obj);
N = size(robots,1);         % number of robots
rbi = robots - obj;         % vectors from robots to objects
rti = robots - target;      % vectors from robots to target;
rbi_hat = Utils.unitvect(rbi);    % unit vectors from robots to object

% Run FIS to determine force
x_velocity = x(2);
y_velocity = x(4);

F_control = nan(3,1);
for i = 1:3
    distance = sqrt( (robots(i,1)-obj(1))^2 + (robots(i,2)-obj(2))^2) - ...
        sqrt( (robots(i,1) - target(1))^2 + (robots(i,2)-target(2))^2);
    fis_input = [distance, x_velocity, y_velocity];
    F_control(i) = evalfis(fis, fis_input)*100;
end

% Determine Angles between robots & object for forcing directions
theta = nan(1,3);
for i = 1:3
    theta(i) = vector_angle(robots(i,:), obj);
end

d2ydt2 = zeros(4,1);
d2ydt2(1) = x(2);
d2ydt2(2) = k/m*l0*(sum(rbi_hat(:,1))) - N*x(1) + F_control(1)*cos(theta(1))...
    + F_control(2)*sin(theta(2)) + F_control(3)*cos(theta(3));
d2ydt2(3) = x(4);
d2ydt2(4) = k/m*l0*(sum(rbi_hat(:,2))) - N*x(3) + F_control(1)*sin(theta(1))...
    + F_control(2)*cos(theta(2)) + F_control(3)*sin(theta(3));
end