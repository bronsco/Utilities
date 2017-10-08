% Sobol' function
% see Sobol', I.M., 2003. Theorems and examples on high dimensional model 
%   representation. Reliability Engineering & System Safety 79 (2), 187–193
function g = TestModel(x,p)

N = size(x,1);

g = zeros(N,1);
for n = 1:N
	g(n) = prod((abs(4*x(n,:) - 2) + p)./(1 + p));
end