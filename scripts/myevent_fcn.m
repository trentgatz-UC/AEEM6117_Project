function [value, isterminal, direction]  = myevent_fcn(t,y, robots)
% myevent_fcn -- terminate simulation if cable length invalid
obj = [y(1) y(3)];

value = ~Utils.isValidCableLength(robots, obj);
isterminal = true;
direction = 0;
end