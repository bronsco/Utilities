%% hilomotDemo6 Demo 6: Dynamic process of second order with 1 input and 1 output.
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Tobias Ebert, 11-May-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Training
LMN = hilomot;                                   % initialize hilomot object

load hammersteinT.mat                                      % Data for training

% The training data was created with the input signal stored in inputSequence1.mat
% which contains steps and an amplitude-modulated pseudo random binary signal covering
% the complete operating range.
% The process to be modeled has the following dynamics:
% y(k) = 0.1044*atan(u(k-1)) + 0.0883*atan(u(k-2)) + 1.4138*y(k-1) - 0.6065*y(k-2);

LMN.input = data(:,1);
LMN.output = data(:,2);
clear data

% Set delays of input and output regressors
LMN.xInputDelay = cell(1,1);
LMN.xOutputDelay = cell(1,1);
LMN.zInputDelay = cell(1,1);
LMN.zOutputDelay = cell(1,1);
LMN.xInputDelay{1} = [1 2];                                % Second order dynamic system
LMN.xOutputDelay{1} = [1 2];                               % Second order dynamic system
LMN.zInputDelay{1} = [1 2];                                % Second order dynamic system
LMN.zOutputDelay{1} = [1 2];                               % Second order dynamic system

% Try also the following cases:

% - Premise input space is only of first order
% hilomotObject.xInputDelay{1} = [1 2];
% hilomotObject.xOutputDelay{1} = [1 2];
% hilomotObject.zInputDelay{1} = [1];
% hilomotObject.zOutputDelay{1} = [1];

% - Premise input space does only contain the physical inputs (this reflects the Hammerstein structure)
% hilomotObject.xInputDelay{1} = [1 2];
% hilomotObject.xOutputDelay{1} = [1 2];
% hilomotObject.zInputDelay{1} = [1 2];
% hilomotObject.zOutputDelay{1} = [];

% - Local finite impulse response (FIR) models (no feedback is involved which requires high feedforward order)
% hilomotObject.xInputDelay{1} = [1:30];
% hilomotObject.xOutputDelay{1} = [];
% hilomotObject.zInputDelay{1} = [1 2];
% hilomotObject.zOutputDelay{1} = [];

% Options for training
LMN.smoothness = 1;              % (default: 1) Option to adjust the transition steepness of the validity functions
LMN.maxNumberOfLM = 10;          % Termination criterion for maximal number of LLMs
LMN.minError = 0;                % Termination criterion for minimal error
LMN.kStepPrediction = inf;       % Simulation not one-step-ahead prediction
LMN.history.displayMode = true;  % display information
LMN.oblique = true;              % (default: true) Split direction is optimized - axes oblique splits are possible
% LMN.GradObj = true;            % Determines if the analytical gradient is used or not

% Train net
LMN = LMN.train;

% Generalization
load hammersteinG.mat

% The generalization data was generated with the input signal stored in inputSequence2.mat.
uG = data(:,1);
yG = data(:,2);
clear data

% Simulate net
yGModel = calculateModelOutput(LMN, uG, yG);
JG = calcGlobalLossFunction(LMN ,yG, yGModel);

% Visualization
figure
LMN.plotModel