% Sobol' function
% see Sobol', I.M., 2003. Theorems and examples on high dimensional model 
%   representation. Reliability Engineering & System Safety 79 (2), 187–193
function g = TestModel(x,p)

g = prod((abs(4*x - 2) + p)./(1 + p)); 