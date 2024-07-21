function [theta] = vector_angle(p1, p2)
% returns angle in radians

rise = p2(2) - p1(2);
run = p2(1) - p1(1);
theta = atan(rise / run);
end


