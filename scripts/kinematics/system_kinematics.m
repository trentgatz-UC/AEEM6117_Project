function [t, yout] = system_kinematics(fis, robots, target)
% system_kinematics - Distributed Control Case

% u - control input (volts) 

%% Givens
l0 = 1; % m - minimum length


% initial conditions & time vector
dt = .01;
t =[0:dt:20];
y0 = zeros(2,1); % initial conditions for voltage to spooled cable length
tspan = [0 dt];

% State Space Matrices
C = [0 1/2];
D = [0];

fcn = @(t,x) odefcn_kinematics(t,x,u);
%% Solving Loop
for k=1:size(t,2)
	%% Based on current position of object & target, use controller to find input voltages
    voltage_input = nan(1,3);
	for i = 1:3
		distance = sqrt( (robots(i,1)-obj(1))^2 + (robots(i,2)-obj(2))^2) - ...
			sqrt( (robots(i,1) - target(1))^2 + (robots(i,2)-target(2))^2);
		fis_input = distance;
		voltage_input(i) = evalfis(fis, fis_input);
	end
	%% Based on input voltages, determine change in spooled cable lenght
    p = nan(1,3);
	for i = 1:3 % each robot
        u = voltage_input(i);
		[~, yout] = ode45(fcn(u), tspan, y0); % voltage to spooled cable length

        y = C*yout(end,1) + D*u; % cable position & velocity
		p(i) = y;
	end
	p = p + (2-0.866); % adjust by initial condition to get absolute length of spooled cable

	%% Based on spooled cable length & kinematic equations, WHERE is the object
    x_kin(k)= <x_position kinematic equation>
    y_kin(k)= <x_position kinematic equation> 
	
    % # TODO, if we want to allow spool to keep moving
    % % % % update intial conditions for spooled cable length (to be fed into next time step as initial conditions
	% % % y0 = yout(end,:);
end
 
 
yout = nan(length(t), 4);
yout(:,1)=  x_kin;
yout(:,3)= y_kin;
end