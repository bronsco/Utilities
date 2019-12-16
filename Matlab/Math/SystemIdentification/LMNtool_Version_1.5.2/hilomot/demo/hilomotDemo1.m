%% hilomotDemo1 Demo 1: Static process with 1 input and 1 output.
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Benjamin Hartmann, 04-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Initialize new hilomot object as local model network (LMN)
LMN = hilomot;

% Example process
N = 40;
u = [linspace(0,0.3,20) linspace(0.5,1,20)]';
sigmoide = 1./(1+exp((-0.65+u)/60));
y1 = 1+sin(4*pi*u-pi/8);
y2 = 0.1./(0.1+u);
y = y1.*sigmoide + y2.*(1-sigmoide);

% Set input and output for training
LMN.input  = u; rng(1);
LMN.output = y + 0.05*randn(N,1);

% Set local models to polynomial order of 2
LMN.xRegressorDegree = 2;

% Train hilomot object
LMN = LMN.train;

% Generalization
uG = linspace(-0.2,1.2,100)';
yG = 1 ./ (0.1 + uG);

% Calculate model output and global loss function
yGModel = calculateModelOutput(LMN, uG, yG);
JG = calcGlobalLossFunction(LMN, yG, yGModel);

% Calculate errorbar or confidence intervals, respectively
alpha = 0.05; % Level of confidence for errorbar.
errorbar = calcErrorbar(LMN, uG, [], alpha);

% Visualization
figure
LMN.plotModel
hold on
plot(uG,yGModel+errorbar,'r')
legend('model output','data','model +/- errorbar')
plot(uG,yGModel-errorbar,'r')
axis([-0.2 1.2 -1 2])
