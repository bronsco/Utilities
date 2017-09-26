function [p, v, u] = dynamics(coe, pos, speed, flag)

% NOTICE: modify the model name to reflect the current simulatino time

t = get_param('SingleIntersection', 'SimulationTime');
if flag == 0
    % flag: 1 (cruise); 0 (control)
    p = 1 / 6 * coe(1) * t ^ 3 + 1 / 2 * coe(2) * t^2 + coe(3) * t + coe(4);
    v = 1 / 2 * coe(1) * t ^ 2 + coe(2) * t + coe(3);
    u = coe(1) * t + coe(2);
else
    p = pos + speed * 0.01;
    v = speed;
    u = 0;
end