%% lolimotDemo2 Demo 2: Static process with 2 inputs and 1 output
%
%
%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 20-October-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Training
LMN = lolimot;                   % initialize lolimot object

LMN.estimationProcedure = 'RIDGE';
% Create training data
[u1g, u2g] = meshgrid(linspace(0,1,15), linspace(0,1,15));
u1 = u1g(:);
u2 = u2g(:);
y = 1./(0.1+u1) + (2*u2).^2;

% assign the training data as input and output of the model
LMN.input = [u1 u2];
LMN.output = y;

% Train the local model network object
LMN = LMN.train;

% Simulate net
[u1G, u2G] = meshgrid(linspace(0,1,30), linspace(0,1,30));
u1G = u1G(:);
u2G = u2G(:);
yG = 1./(0.1+u1G) + (2*u2G).^2;
yGModel = calculateModelOutput(LMN, [u1G u2G], yG);

% calculate the loss function value
JG = calcGlobalLossFunction(LMN ,yG, yGModel);

% plot model output 
figure
LMN.plotModel

% plot partition of the z-space
figure
LMN.plotPartition
