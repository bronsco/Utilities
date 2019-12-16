%% lolimotDemo6 Demo 6: Estimate a model given an initial structure
%
%
%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 20-October-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Initialise object
LMN = lolimot;                   % Generate an empty net and data set structure

% Create trainig data
[u1g, u2g] = meshgrid(linspace(0,1,25), linspace(0,1,25));
u1 = u1g(:);
u2 = u2g(:);
y = 1./(0.1+u1) + (2*u2).^2;

% Assign training data
LMN.input = [u1 u2];
LMN.output = y;

% Define initial structure
LMN.leafModels = true(1,6);
lowerLeftCorner = [0 0; 0.0625 0; 0.125 0; 0.25 0; 0.5 0.5; 0.5 0];
upperRightCorner = [0.0625 1; 0.125 1; 0.25 1; 0.5 1; 1 1; 1 0.5];
for k = 1:size(lowerLeftCorner,1)
    LMN.localModels = [LMN.localModels gaussianOrthoLocalModel(lowerLeftCorner(k,:),upperRightCorner(k,:),LMN.smoothness)];
end

LMN.maxNumberOfLM = 15;         % Termination criterion for maximal number of LLMs
LMN.minError = 0.05;            % Termination criterion for minimal error
LMN.kStepPrediction = 0;        % Static model
LMN.history.displayMode = true;	% display information

% Train net
LMN = LMN.train;

% Generalization
[u1g, u2g] = meshgrid(linspace(0,1,30), linspace(0,1,30));
u1G = u1g(:);
u2G = u2g(:);
yG = 1./(0.1+u1G) + (2*u2G).^2;
uG = [u1G u2G];

% Simulate net
yGModel = calculateModelOutput(LMN, uG, yG);
JG = calcGlobalLossFunction(LMN ,yG, yGModel);

figure
LMN.plotModel

figure
LMN.plotPartition

figure
LMN.plotMSFValue