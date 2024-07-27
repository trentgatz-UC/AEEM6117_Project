function [cost] = cost_function(fis, target, sim_system)
% cost_function - generalized cost function.
% - script which calls this should have a "sim_system" function in its
% workspace

tf = 20; % simulation is to run for 20 seconds
[tout, yout] = sim_system(fis);

obj = [yout(:, 1) yout(:, 3)];
dist = sqrt(sum(sum(((obj-target).^2),2))); % distance between object and target @ each time step
cost = dist*10 + 500*(tf - tout(end));
if sum(abs(yout(:,1))) + sum(abs(yout(:,3))) < 1e-10
    cost = cost + 100;
end
end