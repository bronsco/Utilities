%% lolimotDemo3 Demo 3: Static process with 2 inputs and 2 outputs
%
%
%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 20-October-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Training
LMN = lolimot;                   % initialize lolimot object

% Generate training data
[u1g u2g] = meshgrid(linspace(0,1,25), linspace(0,1,25));
u1 = u1g(:);
u2 = u2g(:);
y1 = 1./(0.1+u1) + (2*u2).^2;
y2 = u1.*u2;
y2 = y2 + 0.2*randn(size(y2))*(max(y2)-min(y2));
LMN.input = [u1 u2];
LMN.output = [y1, y2];

LMN.maxNumberOfLM = 15;           % Termination criterion for maximal number of LLMs (default: inf)
LMN.minError = 0.05;              % Termination criterion for minimal error (default: 0)
LMN.kStepPrediction = 0;          % Static model (default: 0)
LMN.history.displayMode = true;   % display information (default: true)
LMN.xRegressorDegree = 1;         % use 1st order polynoms for local models (default: 1)
tic
% Train net object
LMN = LMN.train;
toc
% Generalization
[u1G u2G] = meshgrid(linspace(0,1,30), linspace(0,1,30));
u1G = u1G(:);
u2G = u2G(:);
y1G = 1./(0.1+u1G) + (2*u2G).^2;
y2G = u1G.*u2G;

% Simulate net
yGModel = calculateModelOutput(LMN, [u1G u2G], [y1G y2G]);

% Calculate loss function value
JG = calcGlobalLossFunction(LMN, [y1G y2G], yGModel);

% plot model output for first output
figure
LMN.plotModel([1 2],1)

% plot model output for second output
figure
LMN.plotModel([1 2],2)

% plot partition of the input space
figure
LMN.plotPartition