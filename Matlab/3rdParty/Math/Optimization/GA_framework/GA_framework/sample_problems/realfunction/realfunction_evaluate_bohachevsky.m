function [ fx ] = realfunction_evaluate_bohachevsky( x )
%BOHACHEVSKY Função

n = size(x,2);
fx = 0;
for i=1:(n-1)
    fx = fx + (x(i)^2 + 2*x(i+1)^2 - 0.3*cos(3*pi*x(i)) - 0.4*cos(4*pi*x(i+1)) + 0.7);
end

end

