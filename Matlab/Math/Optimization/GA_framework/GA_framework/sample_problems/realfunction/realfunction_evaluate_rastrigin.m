function [ fx ] = realfunction_evaluate_rastrigin( x )
%RASTRIGIN avalia x na função rastrigin

n = size(x,2);
sum = 0;
for i=1:n
    sum = sum + (x(i).^2 - 10*cos(2* pi * x(i)));
end

fx = 10*n + sum;

% Penalidade 1
for i=1:n
    fx = fx + 100 * max(sin(2 * pi * x(i)) + 0.5, 0)^2;
end

% Penalidade 2
for i=1:n
    fx = fx + 100 * (cos(2 * pi * x(i)) + 0.5)^2;
end

end