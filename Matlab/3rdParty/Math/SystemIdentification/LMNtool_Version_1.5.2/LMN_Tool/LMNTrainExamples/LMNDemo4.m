% LMNTool demo 4. static process with 2 inputs and 2 outputs

% LMNTool - Nonlinear System Identification Toolbox
% Institute of Mechanics & Automatic Control 
% University of Siegen, Germany 
% Copyright (c) 2015 by Prof. Dr.-Ing. Oliver Nelles et. al.

% generate input data on a grid
[u1g, u2g] = meshgrid(linspace(0,1,25), linspace(0,1,25));
u1 = u1g(:);
u2 = u2g(:);
input = [u1 u2];

% define two outputs (two different hyperbolas)
y1 = (1./(0.1+u1) + (2*u2).^2)/14;
y2 = 0.1./(0.1+(1-u1)/2+(1-u2)/2);

% add some noise
rng(42,'twister');
y1 = y1 + 0.05*randn(size(y1))*(max(y1)-min(y1));
y2 = y2 + 0.05*randn(size(y2))*(max(y2)-min(y2));
output = [y1 y2];


% start training
% note that even if neither validation nor test data is available, you have
% to pass empty vectors. Output indices refer to the columns of the first
% input argument of the LMNTrain function.
[LMNBest, AllLMN] = LMNTrain([input output],[],[],'outputidx',[3 4]);