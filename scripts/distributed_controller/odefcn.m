function d2ydt2 = odefcn(t, x, robots, k, m, l0, fis, target)
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
rti = robots - target;      % vectors from robots to target;
rbi_hat = Utils.unitvect(rbi);    % unit vectors from robots to object

% Run FIS to determine force
x_velocity = x(2);
y_velocity = x(4);

% Determine Angles between robots & object for forcing directions
theta = nan(1,3);
for i = 1:3
    theta(i) = Utils.vector_angle(robots(i,:), obj);
end

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
voltage_input = nan(3,1);
warning('off', 'all');
for i = 1:3
    distance = sqrt( (robots(i,1)-obj(1))^2 + (robots(i,2)-obj(2))^2) - ...
        sqrt( (robots(i,1) - target(1))^2 + (robots(i,2)-target(2))^2);
    % fis_input = [distance, x_velocity, y_velocity];
    fis_input = distance;
    voltage_input(i) = evalfis(fis, fis_input);
end

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

    y = C*x_motor + D*voltage_input; % cable position & velocity
    p(i) = y(1);
end

p = p + 2-0.866; %p above is delta spool, add initially spooled length

%% Combined System Dynamics
%{
Calculate object position based on change in spooled cable lengths
- Ensure y0 (initial cable length) is set properly in inputs to system
%}
d2ydt2 = zeros(7,1);
d2ydt2(1) = x(2);
d2ydt2(2) = k/m*(p-l0)*(rbi_hat(:,1)) - N*x(1)/m; % should this last term be divided by m ?, make system stiffer
d2ydt2(3) = x(4);
d2ydt2(4) = k/m*(p-l0)*(rbi_hat(:,2)) - N*x(3)/m;

d2ydt2(5:10) = dxdy_motor;
end