function x_dot = odefcn_kinematics(t, x, u)
% odefcn
% t - time
% x object position and velocity
%   [x(1) spooled cable length; x(2) rate of change of spooled cable length
% u - FIS input (voltage @ each robot)
%{
x(1) = cable length of robot
x(2) = cable velocity of robot
%}

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

%% Controller Dynamics
%{
Calculate change in spooled cable based on input voltage by solving the
state space equation
%}

x_dot = A*x + B*u;

end