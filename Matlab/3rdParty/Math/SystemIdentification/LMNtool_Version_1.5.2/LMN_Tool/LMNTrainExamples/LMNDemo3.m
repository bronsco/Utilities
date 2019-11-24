% LMNTool demo 3. static process with 2 input and 1 output

% LMNTool - Nonlinear System Identification Toolbox
% Institute of Mechanics & Automatic Control 
% University of Siegen, Germany 
% Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles et. al.


% generate input data on a grid
[u1g u2g] = meshgrid(linspace(0,1,10), linspace(0,1,10));
u1 = u1g(:);
u2 = u2g(:);
input = [u1 u2];

% define some constants
[N n]   = size(input);  % catch number of data samples and dimensions
c       = zeros(1,n);   % Centers for Gaussian
sigma   = 0.25;         % Standard deviation (equally for all inputs)
hheight = 1;            % Maximum height of the Gaussian function
gheight = 0.75;         % Maximum height of the hyperbola function

% calculate the hyperbola
den = 0.1;
for i = 1:n
    den = den+(1-input(:,i))./n;
end
hyperbel = 0.1./den;

% calculate the Gaussian
x = zeros(N,1);
for i = 1:2
    x = x + ((input(:,i)-c(i))/sigma).^2;
end
gauss = exp(-0.5.*x);

% combine both functions
output = hheight.*hyperbel + (gheight-hyperbel).*gauss;


% add some noise
output = output + 0.01*randn(size(output))*(max(output)-min(output));

% start training
[LMNBest AllLMN] = LMNTrain([input output]);