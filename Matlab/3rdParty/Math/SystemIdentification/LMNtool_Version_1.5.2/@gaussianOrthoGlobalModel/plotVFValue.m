function plotVFValue(obj,dimToPlot)
%% PLOTMSFVALUE plots the membership function values of the given local
% model object.
%
%
%       plotMSFValue(obj,dimToPlot)
%
%
%   plotMSFValue inputs:
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
%   Tobias Ebert, 20-October-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% get the dimension of the physical input space
dimension = obj.info.numberOfInputs;

% check if the optinal input is given correctly and which dimension should be plotted
if exist('dimToPlot','var') && ~isempty(dimToPlot) && any(dimToPlot > dimension)
    error(['Dimension(s) possible: ' num2str(1:dimension) ', Dimension(s) you want to plot: ' num2str(dimToPlot)])
elseif ~exist('dimToPlot','var') || isempty(dimToPlot) % if there is a dim to plot
    if dimension == 1
        dimToPlot = 1;
    elseif dimension == 2
        dimToPlot = [1 2];
    else
        warning('No dimensions to plot where given, dimensions 1 and 2 will be used')
        dimToPlot = [1 2];
    end
end

% start plot
if length(dimToPlot)==1
    plotVF1D(obj,dimToPlot,dimension);
else
    plotVF2D(obj,dimToPlot,dimension);
end



end

%% 1D
function [hplot] = plotVF1D(obj,dimToPlot,dimension)

resolution = 500;

% get the boundaries
upper = obj.unscaleData(obj.localModels(1).zUpperBound,obj.scaleParaInput);
lower = obj.unscaleData(obj.localModels(1).zLowerBound,obj.scaleParaInput);

% create an input
XI = linspace(lower(dimToPlot),upper(dimToPlot),resolution);
if dimension == 1
    plotInput = XI(:);
else
    plotInput = ones(length(XI(:)),1) * mean([upper;lower]);
    plotInput(:,dimToPlot) = XI(:);
end

% Calculate the z regressor values
zRegressor = obj.data2zRegressor(plotInput);

% Calculate the validity value of all leaf models
[validity,~] = calculateValidity(obj,zRegressor,obj.leafModels);

% plot of the gaussian membership functions
plot(XI,validity)

xlabel(obj.info.inputDescription{dimToPlot})
ylabel('VF Value')
title(obj.info.dataSetDescription)
end

%% 2D
function hsurf = plotVF2D(obj,dimToPlot,dimension)

resolution = 50;

% If input should be scaled
upper = obj.scaleData(obj.localModels(1).zUpperBound,obj.scaleParaInput);
lower = obj.scaleData(obj.localModels(1).zLowerBound,obj.scaleParaInput);

% create an input
[XI,YI] = meshgrid(linspace(lower(dimToPlot(1)),upper(dimToPlot(1)),resolution),linspace(lower(dimToPlot(2)),upper(dimToPlot(2)),resolution));
if dimension == 2
    plotInput = [XI(:) YI(:)];
else
    plotInput = ones(length(XI(:)),1) * mean([upper;lower]);
    plotInput(:,dimToPlot) = [XI(:) YI(:)];
end

% Calculate the z regressor values
zRegressor = obj.data2zRegressor(plotInput);

% Calculate the validity value of all leaf models
MSFValueLeafModels = arrayfun(@(loc) loc.calculateMSF(zRegressor),obj.localModels,'UniformOutput',false);
validity = calculateVFV(obj,MSFValueLeafModels,obj.leafModels);

% initialize handle
hsurf = [];

% plot of the gaussian membership functions
for k = 1:size(validity,2)
        VFValueReshape =  reshape(validity(:,k),resolution,resolution);
        hsurf(end+1) = surf(XI,YI,VFValueReshape);
        hold on
end
hold off

camlight left; lighting phong
xlabel(obj.info.inputDescription{dimToPlot(1)})
ylabel(obj.info.inputDescription{dimToPlot(2)})
zlabel('VF Value')
title(obj.info.dataSetDescription)



end

