function plotConvergence(obj,criterion,options)

% PLOTCONVERGENCE plots the convergence behaviour of the global training
% error over a defined vlaue <criterion>.
%
%       plotConvergence(obj, criterion)
%
%
% 	plotConvergence inputs:
%
%       obj                 (object)    global model object containing all relevant
%                                       net and data set information and variables
%
%       criterion:          (string)    Defines the 
%       
%       options:            (struct)    (optional) User defined plot options.
%
%   plotConvergence options:
%
%       options.plotMethod -    (string) 'surf' or 'contour'. (Default: 'contour')
%
%       options.color -         (1 x 1)  Defines the color of the lines and
%                                        markers.
%       options.marker -        (1 x 1)  Defines the marker type.
%
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fischer, 04-November-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

fontSize = 14;
lineWidth = 2;
markerSize = 10;

if nargin<2
    criterion = 'LMN';
end

if nargin>=3 && isfield(options,'color')
    color = options.color;
else
    color = 'k';
end

if nargin>=3 && isfield(options,'marker')
    marker = options.marker;
else
    marker = 'o';
end

if nargin>=3 && isfield(options,'line')
    line = options.line;
else
    line = '-';
end

switch criterion
    case 'LMN'
        plot(obj.currentNumberOfLMs,obj.globalLossFunction,[color marker line],'LineWidth',lineWidth,'MarkerSize',markerSize)
        set(gca,'FontSize',fontSize)%,'LineWidth',lineWidth)
    case 'Points'
        plot(obj.currentNumberOfParameters,obj.globalLossFunction,[color marker line],'LineWidth',lineWidth,'MarkerSize',markerSize)
        set(gca,'FontSize',fontSize,'LineWidth',lineWidth)
end
