%% lolimotDemo1 Demo 1: Static process with 1 input and 1 output
%
%
%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 20-October-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Training
LMN = lolimot;                   % Generate an empty net and data set structure

% Create training data
u = linspace(0,1,15)';
y = 1 ./ (0.1 + u);

% Assign training data
LMN.input = u;
LMN.output = y;

LMN.xRegressorDegree = 1;       % use 1st order polynoms for local models (default: 1)
LMN.maxNumberOfLM = 15;         % Termination criterion for maximal number of LLMs
LMN.minError = 0.05;            % Termination criterion for minimal error
LMN.kStepPrediction = 0;        % Static model
LMN.smoothness = 1;             % Less overlap between the validity functions
LMN.history.displayMode = true; % display information

% LMN.xRegressorDegree = 2;


% Train net
LMN = LMN.train;

% Generalization
uG = linspace(-0.05,1.2,270)';
yG = 1 ./ (0.1 + uG);

% Simulate net
yGModel = calculateModelOutput(LMN, uG, yG);
JG = calcGlobalLossFunction(LMN ,yG, yGModel);

figure
LMN.plotModel

figure
LMN.plotPartition