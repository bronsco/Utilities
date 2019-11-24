function [hplot,plotAxis] = plotPartition(obj, zDimToPlot, constDimValue, options)
% PLOTPARTITION Plots the validity function values of the
% premise input space (z-regressors) of the neuro-fuzzy model (1- or
% 2-dimensional plot only).
%
%       plotPartition(obj, zDimToPlot, constDimValue, options)
%
%
% 	plotPartition inputs:
%
%       zDimToPlot    - (1 x [1,2]) Vector of dimensions to be plotted,
%                                   e.g. dimensions = [2 5] (optional).
%
%       constDimValue - (1 x nz)    (optional) Vector containing the constant
%                   or (1 x 1)  value(s) of input dimensions that are NOT
%                               plotted. If constDimValue is empty, the
%                               inputs are set to the mean value.
%
%       options:        (struct)    (optional) User defined plot options.
%
%
% 	plotPartition options:
%
%       options.plotMethod - (string) 'surf' or 'contour'. (Default: 'contour')
%
%       options.resolution - (1 x 1)  Grid resolution, otherwise use default value 30.
%                                     Equal for all axes.
%
%       options.plotAxis   - (1 x 1)  Select figure axis handle which is used for the illustration
%                                     of the partitioning. Needed for GUI application.
% 
%
%   See also plotModel, plotLossFunction, plotCorrelation, plotModelCentered.
%
%
%   LMNtool - Local Model Network Toolbox
%   Benjamin Hartmann, 07-November-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% 2013/01/18:   help updated (Benjamin Hartmann)
% 2011/12/09:   verschoben in einzelne Klasse (TE)


% Get constants
dimension     = size(obj.zRegressor,2);    % Input space dimensionality
lower         = min(obj.zRegressor);   % Upper and lower input bounds
upper         = max(obj.zRegressor);

if dimension < 1
    warning('globalModel:plotPartition','There is no premise input space. No partition was done!')
    return
end

%% Check options
if nargin>=4 && isfield(options,'resolution')
    resolution = options.resolution;
else
    resolution    = [];
end

if nargin>=4 && isfield(options,'plotAxis')
    plotAxis = options.plotAxis;
else
    plotAxis = gca;
end

if nargin>=4 && isfield(options,'plotMethod')
    plotMethod = options.plotMethod;
else
    plotMethod = 'contour';
end
plotLMnumbers = true;
if nargin>=4 && isfield(options,'plotLMnumbers')
    plotLMnumbers = options.plotLMnumbers;
end

%% Check inputs for plot routine
if ~exist('zDimToPlot','var') || isempty(zDimToPlot)
    if dimension <= 2
        zDimToPlot = 1:dimension;
    else
        warning('globalModel:plotPartition','Please select a subset of input dimensions to plot (zDimToPlot).')
        return
    end
end

%% Plausibility check
if ~isempty(zDimToPlot) && any(zDimToPlot > dimension)
    % Test for wrong dimensions
    error(['Dimension(s) possible: ' num2str(1:dimension) ', Dimension(s) you want to plot: ' num2str(zDimToPlot)])
end

%% Plot partitioning

% models to plot
modelIdx = find(obj.leafModels);

% find out which type of global model is present
s = superclasses(obj);

% set how to plot
if any(strcmp(s,'gaussianOrthoGlobalModel')) && strcmp(plotMethod,'contour')
    % switch to special plot for orthogonal gaussians
    if length(zDimToPlot) == 1
        howToPlot = 'plotGaussianPartition1D';
    elseif length(zDimToPlot) == 2
        howToPlot = 'plotGaussianPartition2D';
    elseif length(zDimToPlot) == 3
        howToPlot = 'plotGaussianPartition3D';
    else
        howToPlot = []; % this will produce an error
    end
else
    % do nothing special for sigmoids or to plot normalized gaussians
    howToPlot = length(zDimToPlot);
end

schrift = 18;

switch howToPlot
    
    case 1 % 1D plot
        
        % Display
        fprintf('Plot partitioning for dimension %d.\n', zDimToPlot);
        
        % Set default resolution, if not given
        if isempty(resolution); resolution = 1000; end
        
        % build zRegressor for plot
        XI = linspace(lower(zDimToPlot),upper(zDimToPlot),resolution);
        if dimension == 1
            zRegToPlot = XI(:);
        else
            if exist('constDimValue','var') && ~isempty(constDimValue)
                zRegToPlot = bsxfun(@times, ones(length(XI(:)),dimension), constDimValue); %ones(length(XI(:)),dimension) .* constDimValue;
            else
                zRegToPlot = ones(length(XI(:)),1) * mean([upper;lower]);
            end
            zRegToPlot(:,zDimToPlot) = XI(:);
        end
        
        % Calculate Phi / normalized Gaussians
        %if any(strcmp(s,'gaussianOrthoGlobalModel'))
        %    % calculation for gaussians
        %    MSFValue = arrayfun(@(loc) loc.calculateMSF(zRegToPlot),obj.localModels(obj.leafModels),'UniformOutput',false);
        %    validitys = cell2mat(obj.calculateVFV(MSFValue));
        %elseif any(strcmp(s,'sigmoidGlobalModel'))
        %    % calculation for sigoids
            validitys = calculateValidity(obj, zRegToPlot, obj.leafModels);
        %end
        
        
        % Plot validity functions
        hplot = plot(plotAxis,XI,validitys,'k');
        
        % Axes labels
        xlabel(plotAxis,obj.info.inputDescription{zDimToPlot},'fontsize',schrift,'fontName','Times New Roman')
        ylabel(plotAxis,'\Phi value','fontsize',schrift,'fontName','Times New Roman')
        %         title(plotAxis,obj.info.dataSetDescription)
        for k = 1:size(validitys,2)
            fh = get(plotAxis, 'parent');
            set(fh, 'currentAxes',plotAxis);
            if plotLMnumbers
                text(obj.localModels(modelIdx(k)).center(1,zDimToPlot),...
                    0.5,['$\Phi_',num2str(modelIdx(k)),'$'],'fontsize',schrift,...
                    'fontName','Times New Roman','interpreter','latex');
            end
            %text(obj.localModels(modelIdx(k)).center(1,zDimToPlot),0.5,num2str(sum(sum(obj.localModels(modelIdx(k)).parameter~=0))),'fontsize',schrift,'fontName','Times New Roman')
            %set(hplot(k),'LineColor','k')
        end
    case 2
        
        
        
        
        % Display
        fprintf('Plot partitioning for dimensions %d and %d.\n', zDimToPlot(1), zDimToPlot(2));
        
        % Set default resolution, if not given
        if isempty(resolution); resolution = 30; end
        
        % build zRegressor for plot
        [XI,YI] = meshgrid(linspace(lower(zDimToPlot(1)),upper(zDimToPlot(1)),resolution),...
            linspace(lower(zDimToPlot(2)),upper(zDimToPlot(2)),resolution));
        if dimension == 2
            zRegToPlot = [XI(:) YI(:)];
        else
            if exist('constDimValue','var') && ~isempty(constDimValue)
                zRegToPlot = ones(length(XI(:)),1) * constDimValue;
            else
                zRegToPlot = ones(length(XI(:)),1) * mean([upper;lower]);
            end
            zRegToPlot(:,zDimToPlot) = [XI(:) YI(:)];
        end
        
        % Calculate validitys
        validitys = calculateValidity(obj, zRegToPlot, obj.leafModels);
        % idxLeafModels = find(obj.leafModels);
        
        % Plot validity functions
        for k = 1:size(validitys,2)
            phiPlot =  reshape(validitys(:,k),resolution,resolution);
            switch plotMethod
                case 'surf'
                    hplot(k) = surf(plotAxis,XI,YI,phiPlot);
                case 'contour'
                    [~, hplot(k)] = contour(plotAxis,XI,YI,phiPlot,[0.5 0.5],'LineWidth',1.2);
                    fh = get(plotAxis, 'parent');
                    set(fh, 'currentAxes',plotAxis);
                    if plotLMnumbers
                        text(...
                            obj.localModels(modelIdx(k)).center(1,zDimToPlot(1)),...
                            obj.localModels(modelIdx(k)).center(1,zDimToPlot(2)),...
                            num2str(modelIdx(k)),'FontSize',schrift)
                    end
                    %                     text(obj.localModels(modelIdx(k)).center(1,zDimToPlot(1)),obj.localModels(modelIdx(k)).center(1,zDimToPlot(2)),num2str(sum(sum(obj.localModels(modelIdx(k)).parameter~=0))),'fontsize',schrift,'fontName','Times New Roman')
                    % text(obj.localModels(modelIdx(k)).center(1,zDimToPlot(1)).*0.9,obj.localModels(modelIdx(k)).center(1,zDimToPlot(2)).*0.9,num2str(obj.accurateNumberOfLMParameters(modelIdx(k))),'fontsize',schrift,'fontName','Times New Roman')
                    % text(obj.localModels(modelIdx(k)).center(1,zDimToPlot(1)),obj.localModels(modelIdx(k)).center(1,zDimToPlot(2)),num2str(sum(obj.phi(:,idxLeafModels(k)))),'FontSize',22)
                    set(hplot(k),'LineColor','k')
            end
            hold(plotAxis,'on')
        end
        hold(plotAxis,'off')
        
        % make adjustments to plot
        switch plotMethod
            case 'surf'
                % Light settings
                subplot(plotAxis)
                h1 = camlight('left');
                camlight(h1,'left');
                lighting(plotAxis,'phong')
            case 'contour'
                % set some adjustments
                % make rectangle around model
                line([lower(zDimToPlot(1))...
                    upper(zDimToPlot(1))...
                    upper(zDimToPlot(1))...
                    lower(zDimToPlot(1))...
                    lower(zDimToPlot(1))], ...
                    [lower(zDimToPlot(2))...
                    lower(zDimToPlot(2))...
                    upper(zDimToPlot(2))...
                    upper(zDimToPlot(2))...
                    lower(zDimToPlot(2))],'Color','k')
                % reshape outer axis nicely
                delta = (upper - lower)/20;
                axis([lower(zDimToPlot(1))-delta(zDimToPlot(1))...
                    upper(zDimToPlot(1))+delta(zDimToPlot(1))...
                    lower(zDimToPlot(2))-delta(zDimToPlot(2))...
                    upper(zDimToPlot(2))+delta(zDimToPlot(2))])
        end
        
        % Axes labels
        %         xlabel(plotAxis,obj.info.inputDescription{zDimToPlot(1)})
        %         ylabel(plotAxis,obj.info.inputDescription{zDimToPlot(2)})
        xlabel(plotAxis,['$u_' num2str(zDimToPlot(1)) '$'],'fontsize',schrift,'fontName','Times New Roman','interpreter','latex')
        ylabel(plotAxis,['$u_' num2str(zDimToPlot(2)) '$'],'fontsize',schrift,'fontName','Times New Roman','interpreter','latex')
        zlabel(plotAxis,'\Phi value','fontsize',schrift,'fontName','Times New Roman')
        
        %title(plotAxis,obj.info.dataSetDescription)
        
    case 'plotGaussianPartition1D'
        hplot = plotGaussianPartition1D(obj,zDimToPlot,plotAxis);
        
    case 'plotGaussianPartition2D'
        hplot = plotGaussianPartition2D(obj,zDimToPlot,plotAxis);
        
    case 'plotGaussianPartition3D'
        hplot = plotGaussianPartition3D(obj,zDimToPlot,plotAxis);
        
    otherwise
        
        warning('globalModel:plotPartition',...
            'Only 1- or 2-dimensional plots possible! Please select a subset of 1 or 2 dimensions to be plotted.')
        
end
end

%% ------------------------------------------------------------------------
% subfunctions to plot the partition of gaussian orthogonal global models
% -------------------------------------------------------------------------


function hp = plotGaussianPartition1D(obj,zDimToPlot,ah)
% plot the partition of gaussian orthogonal global models in 1D

% For an easier change of the font size
SizeFont = 14;

% check all local model obejcts
hp = cell(1,size(obj.localModels,2));
for LM = 1:size(obj.localModels,2)
    
    % only consider the leaf models
    if any(find(obj.leafModels) == LM)
        
        % plot the edges of all Gaussian for each leaf model
        for Gaussians = 1:size(obj.localModels(LM).center,1)
            hp{1,LM} = line([obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot)...
                obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot)...
                obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot)...
                obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot)...
                obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot)], ...
                [0 0 1 1 0]);
            
            % plot LM number
            % text(obj.localModels(LM).center(Gaussians,zDimToPlot),0.5,num2str(LM))
            
            % plot sum of parameters of each local model
            text(obj.localModels(LM).center(Gaussians,zDimToPlot),0.5,num2str(sum(sum(obj.localModels(LM).parameter ~= 0))),'fontsize',SizeFont,'fontName','Times New Roman')
            
        end
    end
end
% set some adjustments
delta = (obj.localModels(1).zUpperBound - obj.localModels(1).zLowerBound)/20;
axis([obj.localModels(1).zLowerBound(zDimToPlot)-delta(zDimToPlot) obj.localModels(1).zUpperBound(zDimToPlot)+delta(zDimToPlot) -0.05 1.05])
xlabel(['Dimension ' num2str(zDimToPlot)])
title('Partitioning of Scaled Input Space')

end


function hp = plotGaussianPartition2D(obj,zDimToPlot,ah)
% plot the partition of gaussian orthogonal global models in 2D

% For an easier change of the font size
SizeFont = 14;

hp = cell(1,size(obj.localModels,2));

% Check all local model obejcts
for LM = 1:size(obj.localModels,2)
    
    % only consider the leaf models
    if any(find(obj.leafModels) == LM)
        
        % Plot the edges of all Gaussian for each leaf model
        for Gaussians = 1:size(obj.localModels(LM).center,1)
            hp{1,LM} = line([obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))...
                obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1))...
                obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1))...
                obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))...
                obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))], ...
                [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))...
                obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))...
                obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2))...
                obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2))...
                obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))],'Color','k');
            
            % Plot LM number
            % text(obj.localModels(LM).center(Gaussians,zDimToPlot(1)),obj.localModels(LM).center(Gaussians,zDimToPlot(2)),-0.5,num2str(LM))
            
            % Plot the leaf number of the LM
%             text(obj.localModels(LM).center(Gaussians,zDimToPlot(1)),...
%                 obj.localModels(LM).center(Gaussians,zDimToPlot(2)),...
%                 num2str(find(find(obj.leafModels) == LM)),...
%                 'HorizontalAlignment','center')
            
            % Plot sum of parameters of each local model
%             text(obj.localModels(LM).center(Gaussians,zDimToPlot(1)),...
%                 obj.localModels(LM).center(Gaussians,zDimToPlot(2)),...
%                 num2str(sum(sum(obj.localModels(LM).parameter~=0))),...
%                 'fontsize',SizeFont,'fontName','Times New Roman',...
%                 'HorizontalAlignment','center')

        end
    end
end

% set some adjustments
delta = (obj.localModels(1).zUpperBound - obj.localModels(1).zLowerBound)/20;
axis([obj.localModels(1).zLowerBound(zDimToPlot(1))-delta(zDimToPlot(1))...
    obj.localModels(1).zUpperBound(zDimToPlot(1))+delta(zDimToPlot(1))...
    obj.localModels(1).zLowerBound(zDimToPlot(2))-delta(zDimToPlot(2))...
    obj.localModels(1).zUpperBound(zDimToPlot(2))+delta(zDimToPlot(2))])
xlabel(['$u_' num2str(zDimToPlot(1)) '$'],'fontsize',SizeFont,'fontName','Times New Roman','interpreter','latex')
ylabel(['$u_' num2str(zDimToPlot(2)) '$'],'fontsize',SizeFont,'fontName','Times New Roman','interpreter','latex','Rotation',0)
set(gca,'Box','on','fontsize',SizeFont,'fontName','Times New Roman')
title('Partitioning of Scaled Input Space')

end


function hp = plotGaussianPartition3D(obj,zDimToPlot,ah)
% plot the partition of gaussian orthogonal global models in 3D

hp = cell(6,size(obj.localModels,2));

% check all local model obejcts
for LM = 1:size(obj.localModels,2)
    
    % only consider the leaf models
    if any(find(obj.leafModels) == LM)
        
        % plot the edges of all Gaussian for each leaf model
        for Gaussians = 1:size(obj.localModels(LM).center,1)
            hp{1,LM} = line([obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))], ...
                [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))], ...
                [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3))]);
            
            hp{2,LM} = line([obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))], ...
                [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))], ...
                [obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3))]);
            
            hp{3,LM} = line([obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))], [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))], [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3))]);
            
            hp{4,LM} = line([obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(1))], [obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2))], [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3))]);
            
            hp{5,LM} = line([obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1))], [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(2))], [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3))]);
            
            hp{6,LM} = line([obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(1))], [obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(2))], [obj.localModels(LM).lowerLeftCorner(Gaussians,zDimToPlot(3)) obj.localModels(LM).upperRightCorner(Gaussians,zDimToPlot(3))]);
            
            text(obj.localModels(LM).center(Gaussians,zDimToPlot(1)),obj.localModels(LM).center(Gaussians,zDimToPlot(2)),obj.localModels(LM).center(Gaussians,zDimToPlot(3)),num2str(LM))
        end
    end
end

% set some adjustments
delta = (obj.localModels(1).zUpperBound - obj.localModels(1).zLowerBound)/20;
axis([obj.localModels(1).zLowerBound(zDimToPlot(1))-delta(zDimToPlot(1))...
    obj.localModels(1).zUpperBound(zDimToPlot(1))+delta(zDimToPlot(1))...
    obj.localModels(1).zLowerBound(zDimToPlot(2))-delta(zDimToPlot(2))...
    obj.localModels(1).zUpperBound(zDimToPlot(2))+delta(zDimToPlot(2))...
    obj.localModels(1).zLowerBound(zDimToPlot(3))-delta(zDimToPlot(3))...
    obj.localModels(1).zUpperBound(zDimToPlot(3))+delta(zDimToPlot(3))])
xlabel(['Dimension ' num2str(zDimToPlot(1))])
ylabel(['Dimension ' num2str(zDimToPlot(2))])
zlabel(['Dimension ' num2str(zDimToPlot(3))])
title('Partitioning of Scaled Input Space')


end


