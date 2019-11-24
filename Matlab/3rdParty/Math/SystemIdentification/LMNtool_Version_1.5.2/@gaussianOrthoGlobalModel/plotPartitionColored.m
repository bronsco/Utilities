function [hPatches,ah] = plotPartitionColored(obj,zDimToPlot,ah)
% PLOTPARTITIONCOLORED plots the partitioning of the premise input space of
% the neuro-fuzzy model (1-, 2-, or 3-dimensional plot only).
%
%
%       plotPartition(obj,dimToPlot)
%
%
%   plotPartitionColored inputs:
%
%       obj       - (object)   Local model network object containing all relevant net
%                              and data set information and variables.
%
%       dimToPlot - (optional) Vector of dimensions you want to plot.
%
%
%   SYMBOLS AND ABBREVIATIONS:
%
%       LM:  Local model
%
%       p:   Number of inputs (physical inputs)
%       q:   Number of outputs
%       N:   Number of data samples
%       M:   Number of LMs
%       nx:  Number of regressors (x)
%       nz:  Number of regressors (z)
%
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fischer, 15-November-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

if nargin < 3 || isempty(ah)
    ah = gca;
end

% get the dimension of the physical input space
dimension = obj.info.numberOfInputs;

% check which dimension should be plotted
if ~exist('dimToPlot','var')
    if dimension <= 3
        zDimToPlot = 1:dimension;
    else
        warning('gaussianOrthoGlobalModel:plotPartition','No dimensions to plot where given')
    end
end

% check if prohibited dimensions for plotting are given
if ~isempty(zDimToPlot) && any(zDimToPlot > dimension)
    % test for wrong dimensions
    error(['Dimension(s) possible: ' num2str(1:dimension) ', Dimension(s) you want to plot: ' num2str(zDimToPlot)])
end

% % Set random number generation to a fix start
% rng('default')
% rng(1)
% CMR = rand(numel(obj.leafModels),1); % one fix color for each local model
% rng(2)
% CMG = rand(numel(obj.leafModels),1); % one fix color for each local model
% rng(3)
% CMB = rand(numel(obj.leafModels),1); % one fix color for each local model
% CM = [CMR CMG CMB];

CM = colormap(jet(sum(obj.leafModels)));
% CM = colormap(hsv(sum(obj.leafModels)));
% CM = colormap(gray(sum(obj.leafModels)));

% start plot
if length(zDimToPlot)==1
    plotPartitionColored1D(obj,zDimToPlot,CM,ah);
elseif length(zDimToPlot)==2
    hPatches = plotPartitionColored2D(obj,zDimToPlot,CM,ah);
else
    plotPartitionColored3D(obj,zDimToPlot,CM,ah);
end

end

%% 1D
function [hmodel,hdata] = plotPartitionColored1D(obj,zDimToPlot,CM,ah)

% Set user demanded axis as current axis
axes(ah);

% check all local model obejcts
for LM = find(obj.leafModels)
    
    % initialize the complete surface matrix
    X = []; Y = [];
    
    % get the surfaces of all Gaussians of one local model object
    for Gaussians = 1:size(obj.localModels(LM).center,1)
        X_neu = [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))]';
        Y_neu = [0 0 1 1]';
        
        % superposition all surfaces of one local model object
        X = [X X_neu];
        Y = [Y Y_neu];
    end
    hold on
    % do patches for the current leaf model
    patch(X,Y,CM(find(obj.leafModels) == LM,:));
end
end

%% 2D
function hPatches = plotPartitionColored2D(obj,zDimToPlot,CM,ah)
% plot the partition of gaussian orthogonal global models in 2D

% Set user demanded axis as current axis
axes(ah);

schrift = 14;

hPatches = cell(1,sum(obj.leafModels));
helpMeCount = 1;
% check all local model obejcts
for LM = find(obj.leafModels)
    
    % initialize the complete surface matrix
    X = []; Y = [];
    
    % get the surfaces of all Gaussians of one local model object
    for Gaussians = 1:size(obj.localModels(LM).center,1)
        X_neu = [...
            obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))...
            obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1))...
            obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1))...
            obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))]';
        Y_neu = [...
            obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))...
            obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))...
            obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2))...
            obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2))]';
        
        % superposition all surfaces of one local model object
        X = [X X_neu];
        Y = [Y Y_neu];
    end
    hold on
    % do patches for the current leaf model
%     patch(X,Y,CM(LM,:));
    hPatches{helpMeCount} = patch(X,Y,CM(find(obj.leafModels) == LM,:));
    helpMeCount = helpMeCount + 1;
end

% set some adjustments
delta = (obj.localModels(1).zUpperBound - obj.localModels(1).zLowerBound)/20;
axis([obj.localModels(1).zLowerBound(zDimToPlot(1))-delta(zDimToPlot(1))...
    obj.localModels(1).zUpperBound(zDimToPlot(1))+delta(zDimToPlot(1))...
    obj.localModels(1).zLowerBound(zDimToPlot(2))-delta(zDimToPlot(2))...
    obj.localModels(1).zUpperBound(zDimToPlot(2))+delta(zDimToPlot(2))])
xlabel(['$u_' num2str(zDimToPlot(1)) '$'],'fontsize',schrift,'fontName','Times New Roman','interpreter','latex')
ylabel(['$u_' num2str(zDimToPlot(2)) '$'],'fontsize',schrift,'fontName','Times New Roman','interpreter','latex','Rotation',0,'Position',[-0.15 0.49 1])
set(gca,'Box','on','fontsize',schrift,'fontName','Times New Roman','XTick',[0 0.5 1],'YTick',[0 0.5 1])

title('Partitioning of Input Space')

end

function [hmodel,hdata] = plotPartitionColored3D(obj,zDimToPlot,CM,ah)

% Set user demanded axis as current axis
axes(ah);

% check all local model obejcts
for LM = find(obj.leafModels)
    
    % initialize the complete surface matrix
    X = []; Y = []; Z = [];
    
    % get the surfaces of all Gaussians of one local model object
    for Gaussians = 1:size(obj.localModels(LM).center,1)
        
        X_neu =[[obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))]' ...
            [obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1))]'  ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))]' ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))]' ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))]' ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))]'];
        Y_neu =[[obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))]' ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))]'  ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))]' ...
            [obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2))]' ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2))]' ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2))]'];
        Z_neu =[[obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3))]' ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3))]'  ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3))]' ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3))]' ...
            [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3))]' ...
            [obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3))]'];
        
        % superposition all surfaces of one local model object
        X = [X X_neu];
        Y = [Y Y_neu];
        Z = [Z Z_neu];
    end
    hold on
    % do patches for the current leaf model
    patch(X,Y,Z,CM(LM,:));
end
view(3)
end