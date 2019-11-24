%% lolimotDemo4 Demo 4: Dynamic process of second order with 1 input and 1 output
%
%
%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 20-October-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Training
LMN = lolimot;                                   % initialize lolimot object

load hammersteinT.mat                                      % Data for training

% The training data was created with the input signal stored in
% inputSequence1.mat which contains steps and an amplitude-modulated pseudo
% random binary signal covering the complete operating range. The process
% to be modeled has the following dynamics: y(k) = 0.1044*atan(u(k-1)) +
% 0.0883*atan(u(k-2)) + 1.4138*y(k-1) - 0.6065*y(k-2);

% Assign the training data
LMN.input = data(:,1);
LMN.output = data(:,2);
clear data

% Generalization
load hammersteinG.mat                                      % Data for generalization

% Assign the test data
LMN.testInput = data(:,1);
LMN.testOutput = data(:,2);
clear data

LMN.xInputDelay{1} = [1 2];                                % Second order dynamic system
LMN.xOutputDelay{1} = [1 2];                               % Second order dynamic system
LMN.zInputDelay{1} = [1 2];                                % Second order dynamic system
LMN.zOutputDelay{1} = [1 2];                               % Second order dynamic system

% Try also the following cases:
% - Premise input space is only of first order
% LMN.xInputDelay{1} = [1 2];
% LMN.xOutputDelay{1} = [1 2];
% LMN.zInputDelay{1} = [1];
% LMN.zOutputDelay{1} = [1];

% - Premise input space does only contain the physical inputs (this reflects the Hammerstein structure)
% LMN.xInputDelay{1} = [1 2];
% LMN.xOutputDelay{1} = [1 2];
% LMN.zInputDelay{1} = [1 2];
% LMN.zOutputDelay{1} = [];

% - Local finite impulse response (FIR) models (no feedback is involved which requires high feedforward order)
% LMN.xInputDelay{1} = [1:30];
% LMN.xOutputDelay{1} = [];
% LMN.zInputDelay{1} = [1 2];
% LMN.zOutputDelay{1} = [];


LMN.maxNumberOfLM = 10;                           % Termination criterion for maximal number of LLMs (default: inf)
LMN.minError = 0.02;                              % Termination criterion for minimal error (default: 0)
LMN.kStepPrediction = inf;                        % Simulation, not one-step-ahead prediction
LMN.history.displayMode = true;                   % display information about the training

% Train net
LMN = LMN.train;

% Generalization
load hammersteinG.mat                                      % Data for generalization

% The generalization data was generated with the input signal stored in inputSequence2.mat.
uG = data(:,1);
yG = data(:,2);
clear data

% Simulate net
yGModel = calculateModelOutput(LMN, uG, yG);
JG = calcGlobalLossFunction(LMN ,yG, yGModel);

% plot model output
figure
LMN.plotModel
