%% hilomotDemo5 Demo 5: Static process: Global estimation and ridge regression after training.
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Benjamin Hartmann, 25-January-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% Initialize new hilomot object as local model network (LMN)
LMN = hilomot;

% Example process
N = 50;
u = linspace(0,1,N)';
sigmoide = 1./(1+exp((-0.65+u)/60));
y1 = 1+sin(4*pi*u-pi/8);
y2 = 0.1./(0.1+u);
y = y1.*sigmoide + y2.*(1-sigmoide);

% Set input and output for training
LMN.input  = u;
LMN.output = y + 0.1*randn(N,1);

% Set local models to polynomial order of 2
LMN.xRegressorDegree = 2;

% Train hilomot object
LMN = LMN.train;

% Visualization
figure(1)
clf
LMN.plotModel
title('least squares local estimation')

% Perform global parameter estimation
figure(2)
clf
LMNglob = LMN;
LMNglob = LMNglob.estimateParametersGlobal('LS');
LMNglob.plotModel
title('least squares global estimation')


% Perform global estimation regularized with ridge regression
figure(3)
clf
LMNridge = LMN;
LMNridge = LMNridge.estimateParametersGlobal('RIDGE');
LMNridge.plotModel
title('least squares global estimation & ridge regression')
