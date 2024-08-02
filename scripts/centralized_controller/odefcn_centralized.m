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
