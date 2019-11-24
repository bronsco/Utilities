%% hilomotDemo2 Demo 2: Static process with 2 inputs and 1 output.
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Benjamin Hartmann, 04-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Initialize new hilomot object as local model network (LMN)
LMN = hilomot;
LMN = LMN.convert2CenteredLocalModels;

% Set inputs and output for training
[u1g, u2g] = meshgrid(linspace(0,1,50), linspace(0,1,50));
u1 = u1g(:);
u2 = u2g(:);
y = 0.1./(0.1+(1-u1)/2+(1-u2)/2);
LMN.input = [u1 u2];
rng(42,'twister');
y = y + 0.00*randn(size(y));
LMN.output = y;

% Train hilomot object
LMN.maxNumberOfLM = 10;
LMN = LMN.train;

% Visualization
figure
LMN.plotModel
figure
LMN.plotPartition

% Generalization
[u1G, u2G] = meshgrid(linspace(0,1,30), linspace(0,1,30));
u1G = u1G(:);
u2G = u2G(:);
yG = 0.1./(0.1+(1-u1G)/2+(1-u2G)/2);

% Calculate model output and global loss function
yGModel = calculateModelOutput(LMN, [u1G u2G], yG);
JG = calcGlobalLossFunction(LMN ,yG, yGModel);

% Quick calculation of model output, if only one single point is queried, i.e. during optimization.
yGModelQuick = calculateModelOutputQuick(LMN, [u1G(23,:) u2G(23,:)]);