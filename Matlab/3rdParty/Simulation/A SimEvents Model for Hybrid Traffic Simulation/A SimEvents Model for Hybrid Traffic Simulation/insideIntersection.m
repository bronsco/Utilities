function [p, v, u] = insideIntersection(pos, speed, acc)
% driving behaviour control inside the merging zone under traffic light
% control
step_size = 0.01;
if speed == 10
    v = 10;
    u = 0;
else
    v = speed + step_size * acc;
    u = acc;
end
p = pos + step_size * v;
end