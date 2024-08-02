function [] = distance_plot(target, yout, tout, suffix)
% distance_plot - create distance vs time plot

% distance vs time plot
obj = [yout(:,1) yout(:,3)];
dist = sqrt(sum(((obj-target).^2),2));

figure
plot(tout, dist)

title(['Distance vs Time - ' suffix])
xlabel('Time [s]')
ylabel('Distance [m]')
grid on
end