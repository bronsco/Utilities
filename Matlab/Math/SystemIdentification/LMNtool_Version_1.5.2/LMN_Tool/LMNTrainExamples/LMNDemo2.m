% LMNTool demo 2. static process with 2 input and 1 output

% LMNTool - Nonlinear System Identification Toolbox
% Institute of Mechanics & Automatic Control 
% University of Siegen, Germany 
% Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles et. al.


% generate input data on a grid
[u1g u2g] = meshgrid(linspace(0,1,10), linspace(0,1,10));
u1 = u1g(:);
u2 = u2g(:);
input = [u1 u2];

% transformation for a good input space
u1f = u1*15-5;
u2f = u2*15;

% Branin function
output = (u2f-(5.1/(4*pi^2))*u1f.^2 + 5*u1f/pi-6).^2 + 10*(1-1/(8*pi))*cos(u1f)+10;

% add some noise
output = output + 0.1*randn(size(output))*(max(output)-min(output));

% start training
[LMNBest AllLMN] = LMNTrain([input output]);