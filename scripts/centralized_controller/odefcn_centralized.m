function d2ydt2 = odefcn_centralized(t, x, robots, k, m, l0, fis, target)
% odefcn
% t - time
% x object position and velocity
%   [x pos; x vel; y pos; y vel]
% robots - static robot positions
% k - spring constant
% m - object mass
% l0 - minimum cable length

% Setup Vectors
obj = [x(1) x(3)];
obj_vel = [x(2) x(4)];
% % state = Utils.isValidCableLength(robots, obj);


N = size(robots,1);         % number of robots
rbi = robots - obj;         % vectors from robots to objects
% % rti = robots - target;      % vectors from robots to target; [not used
% for centralized controller
rbi_hat = Utils.unitvect(rbi);    % unit vectors from robots to object

%{
RUN THE CONTROLLER
==========================
For the centralized control case, it is assumed that the control outputs a
velocity to be applied directly to the object.

This differs from the distributed control case as in distributed control,
each robot can only apply a force along the vector between itself and the
object. A centralized controller would be able to coordinate all 3 robots
to apply any arbitrary forcing vector.
%}
distance = sqrt(sum((obj - target).^2)); % distance between object and target
fis_input = [distance, obj_vel(1), obj_vel(2)];
F_control = evalfis(fis, fis_input)*1000;

% Setup differential equations for solving
d2ydt2 = zeros(4,1);
d2ydt2(1) = x(2);
d2ydt2(2) = k/m*l0*(sum(rbi_hat(:,1))) - N*x(1) + F_control(1);
d2ydt2(3) = x(4);
d2ydt2(4) = k/m*l0*(sum(rbi_hat(:,2))) - N*x(3) + F_control(2);
end