%% hilomotDemo3 Demo 3: Static process with 2 inputs and 2 outputs.
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Benjamin Hartmann, 04-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Initialize new hilomot object as local model network (LMN)
LMN = hilomot;

% Set inputs and outputs for training
[u1g, u2g] = meshgrid(linspace(0,1,25), linspace(0,1,25));
u1 = u1g(:);
u2 = u2g(:);
y1 = (1./(0.1+u1) + (2*u2).^2)/14;
y2 = 0.1./(0.1+(1-u1)/2+(1-u2)/2);
y2 = y2 + 0.05*randn(size(y2))*(max(y2)-min(y2));
LMN.input = [u1 u2];
LMN.output = [y1, y2];
figure
surf(u1g,u2g,reshape(y1,25,25))
figure
surf(u1g,u2g,reshape(y2,25,25))

% Store dataset description into the object
LMN.info.dataSetDescription = 'demonstration example';
LMN.info.inputDescription   = {'input 1', 'input 2'};
LMN.info.outputDescription  = {'output 1', 'output 2'};

% Set minimum training error as termination criterion
LMN.minError = 0.05;

% Train LMN object
LMN = LMN.train;

% Visualization
figure
LMN.plotModel([1 2],1)
figure
LMN.plotModel([1 2],2)
figure
LMN.plotPartition

% Generalization
[u1G, u2G] = meshgrid(linspace(0,1,30), linspace(0,1,30));
u1G = u1G(:);
u2G = u2G(:);
y1G = (1./(0.1+u1G) + (2*u2G).^2)/14;
y2G = 0.1./(0.1+(1-u1G)/2+(1-u2G)/2);

% Calculate model output and global loss function
yGModel = calculateModelOutput(LMN, [u1G u2G], [y1G y2G]);
JG = calcGlobalLossFunction(LMN, [y1G y2G], yGModel);

% Quick calculation of model output, if only one single point is queried, i.e. during optimization.
yGModelQuick = calculateModelOutputQuick(LMN, [u1G(23,:) u2G(23,:)]);