function [cost] = cost_function_centralized(vec, fis, targets, robots, k, m, l0)
    % cost function for the centralized case

    fis = gen_fis_centralized_2(fis, vec);
    
cost = 0;
event_fcn = @(t,y) myevent_fcn(t,y,robots);
for iterator = 1:size(targets,1)
    target = targets(iterator,:);
    options = odeset('RelTol', 1e-3, 'Events', event_fcn);
    fcn = @(t,x) odefcn_centralized(t,x,robots,k, m, l0,fis,target);
    tspan = [0 20]; % simulation is to run for 20 seconds
    y0 = zeros(1,4); % object starts at home position each time
    [tout, yout] = ode45(fcn, tspan, y0, options);
    
    obj = [yout(:, 1) yout(:, 3)];
    dist = sqrt(sum(sum(((obj-target).^2),2))); % distance between object and target @ each time step
    cost = cost + dist + 50*(tspan(end) - tout(end));
    if sum(yout(:,1)) + sum(yout(:,3)) == 0
        cost = cost + 10;
    end
end
end