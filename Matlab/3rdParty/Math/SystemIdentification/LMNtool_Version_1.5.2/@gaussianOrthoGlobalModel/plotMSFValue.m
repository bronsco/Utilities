function plotMSFValue(obj,dimToPlot)
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
    plotMSF1D(obj,dimToPlot,dimension);
else
    plotMSF2D(obj,dimToPlot,dimension);
end



end

%% 1D
function [hplot] = plotMSF1D(obj,dimToPlot,dimension)

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

% calculate the MSF values
zRegressor = obj.data2zRegressor(plotInput);
% calculate the MSF Value of all active models
if strcmp(version('-release'),'2010a')
    % workaround for R2010a
    idx = find(obj.leafModels);
    for k = 1:sum(obj.leafModels)
        MSFValue(:,k) = obj.localModels(idx(k)).calculateMSF(zRegressor);
    end    
else
    %  for R2010b and later
    MSFValue = arrayfun(@(loc) loc.calculateMSF(zRegressor),obj.localModels(obj.leafModels),'UniformOutput',false);
end

% plot of the gaussian membership functions
plot(XI,cell2mat(MSFValue))

xlabel(obj.info.inputDescription{dimToPlot})
ylabel('MSF Value')
title(obj.info.dataSetDescription)
end

%% 2D
function hsurf = plotMSF2D(obj,dimToPlot,dimension)

resolution = 50;

% get the scaled boundaries
upper = obj.unscaleData(obj.localModels(1).zUpperBound,obj.scaleParaInput);
lower = obj.unscaleData(obj.localModels(1).zLowerBound,obj.scaleParaInput);

% create an input
[XI,YI] = meshgrid(linspace(lower(dimToPlot(1)),upper(dimToPlot(1)),resolution),linspace(lower(dimToPlot(2)),upper(dimToPlot(2)),resolution));
if dimension == 2
    plotInput = [XI(:) YI(:)];
else
    plotInput = ones(length(XI(:)),1) * mean([upper;lower]);
    plotInput(:,dimToPlot) = [XI(:) YI(:)];
end

zRegressor = obj.data2zRegressor(plotInput);
% calculate the MSF Value of all active models
if strcmp(version('-release'),'2010a')
    % workaround for R2010a
    idx = find(obj.leafModels);
    for k = 1:sum(obj.leafModels)
        MSFValue(:,k) = obj.localModels(idx(k)).calculateMSF(zRegressor);
    end    
else
    %  for R2010b and later
    MSFValue = arrayfun(@(loc) loc.calculateMSF(zRegressor),obj.localModels(obj.leafModels),'UniformOutput',false);
end

% initialize handle
hsurf = [];

% plot of the gaussian membership functions
for k = 1:size(MSFValue,2)
    for l = 1:size(MSFValue{k},2)
        MSFValueReshape =  reshape(MSFValue{k}(:,l),resolution,resolution);
        hsurf(end+1) = surf(XI,YI,MSFValueReshape);
        hold on
    end
end
hold off

camlight left; lighting phong
xlabel(obj.info.inputDescription{dimToPlot(1)})
ylabel(obj.info.inputDescription{dimToPlot(2)})
zlabel('MSF Value')
title(obj.info.dataSetDescription)



end

