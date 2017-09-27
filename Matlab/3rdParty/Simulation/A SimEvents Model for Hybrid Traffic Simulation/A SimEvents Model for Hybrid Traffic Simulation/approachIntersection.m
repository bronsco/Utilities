function [p, v, u] = approachIntersection(pos, speed, location, light)
% driving behaviour control approaching the merging zone under traffic light
% control
step_size = 0.01;
vehicle_length = 5;
if light == 1 % RED
    if speed == 0
        p = 400 - vehicle_length * (location - 1); v = 0; u = 0;
    else
        u =  - speed^2 / (2 * (400 - pos)); % Deceleration
        v = speed + step_size * u;
        p = pos + step_size * v;
        if p >= 400 - vehicle_length * (location - 1)
            p = 400 - vehicle_length * (location - 1);
            v = 0;
            u = 0; % vehicle stops at the red light
        end
    end
else % GREEN
    
    u = (100 - speed^2) / (2*(410-pos));
    v = speed + step_size * u;
    p = pos + step_size * v;
    
end

end