function OptimalFuelConsumption = optimizeFuelConsumption(coe, initial, final)
step_size = 0.01;
b = [0.1569, 0.02450,-0.0007415,0.00005975];
c = [0.07224, 0.09681,0.001075];
sum = 0;
t = initial;
while t < final
    v = 1 / 2 * coe(1) * t ^ 2 + coe(2) * t + coe(3);
    u = coe(1) * t + coe(2);
    %     if u > 0
    sum = sum + step_size * (u * (c(1) + c(2)*v + c(3)*v^2) +(b(1) + b(2)*v + b(3)*v^2 + b(4)*v^3));
    %     end
    t = t + step_size;
end
OptimalFuelConsumption = sum;
