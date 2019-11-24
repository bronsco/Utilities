function [valueHandle,uncertaintyHandles,axisHandle,axesDescriptionHandles,legendHandle,titleHandle,percentileLines] = ...
    plotPartialDependenceModel(obj, inputToPlot, outputToPlot, varargin)
%% plotPartialDependenceModel visualizes a partial dependence plot of a given input variable.
%
%
%       [valueHandles,uncertaintyHandles,axisHandle,axesDescriptionHandles] = plotPartialDpendenceModel(obj, inputToPlot, outputToPlot, varargin)
%
%
% 	plotPartialDpendenceModel inputs:
%
%       inputToPlot    - (1 x [1,2]) Vector of dimensions to be plotted,
%                                    e.g. dimensions = [2 5] (optional).
%       outputToPlot   - (scalar) Output dimension to plot.
%       varargin       - String followed by corresponding value.
% 
%       List of possible strings with corresponding valid values for
%       varargin:
%
%       String          -       Value
%
%       'show'          -       'mean' or 'median'
%       'showLegend'    -       true or false
%       'resolution'    -       Integer value (determines at which input
%                               values the corresponding partial dependence
%                               values are calculated)
%       'axis'          -       Axis handle
%       'plotoptions'   -       plotOptions object
%       'percentiles'   _       Vector containing percentile levels to be visualized
%       'scaleuncertainty' -    Boolean (true or false) to determine, if
%                               the uncertainty should be scaled or not
%       
%
%
%   See also plotPartition, plotLossFunction, plotCorrelation, plotModelCentered.
%
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fischer, 22-July-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles
%
%   Update 18-Nov-2014: Calculation of partial dependence values now in
%   extern function. Options structure replaced by varargin. Determination
%   of outer appearances of lines depend on plotOptions objects.


% Get constants
dimension     = obj.info.numberOfInputs;  % number of inputs
lowerBounds   = min(obj.unscaledInput);   % Upper and lower input bound for each dim
upperBounds   = max(obj.unscaledInput);

% Set default options, which may be overwritten later...
resolution = 30;
options.legend = 1;
showValue = 'mean';
percentiles = 10:10:90;
scaleuncertainty = true;

% set plot options
% 1.: Check if there is an options struct (if not => default value)
% 2.: Check if the field exists in the struct (if not => default value)
if nargin > 3
    
    idx = 1;
    
    % Loop over all passed inputs
    while idx <= nargin - 3
        
        % If the current input is a string, compare to it to
        % all possible properties and take idx+1 as value to
        % set the corresponding property
        if ischar(varargin{idx})
            switch lower(varargin{idx})
                case 'show'
                    if strcmpi(varargin{idx+1},'median')
                        % Decide whether the median or the mean value
                        % should be visualized
                        showValue = 'median';
                    else
                        % If there is a misspelling, the mean will be
                        % displayed
                        showValue = 'mean';
                    end
                case 'showlegend'
                    if varargin{idx+1}
                        options.legend = true;
                    else
                        options.legend = false;
                    end
                case 'resolution'
                    resolution = varargin{idx+1};
                case 'axis'
                    plotAxis = varargin{idx+1};
                case 'plotoptions'
                    PO = varargin{idx+1};
                case 'percentiles'
                    percentiles = varargin{idx+1};
                case 'scaleuncertainty'
                    scaleuncertainty = varargin{idx+1};
            end
            
        end
        
        % Increase index
        idx = idx + 1;
        
    end
    
end

if ~exist('PO','var')
    % If no plotOptions object has been passed by the user, create one with
    % two different line specifications (median/mean and
    % percentiles/standard deviations)
    PO = plotOptions([],[],'differentlines',3);
    
    % Set default outer appearances of the three different lines
    % Mean or median line
    PO.lineSpec(1).linestyle = '-';
    PO.lineSpec(1).linewidth = 2;
    PO.lineSpec(1).marker = 'none';
    PO.lineSpec(1).markersize = 10;
    PO.lineSpec(1).color = [0 0 0];
    
    % Uncertainty measures
    PO.lineSpec(3).linestyle = '--';
    PO.lineSpec(3).linewidth = 2;
    PO.lineSpec(3).marker = 'none';
    PO.lineSpec(3).markersize = 10;
    PO.lineSpec(3).color = [255 102 0]/255;
    
    % Percentile visualization
    PO.lineSpec(2).linestyle = ':';
    PO.lineSpec(2).linewidth = 1;
    PO.lineSpec(2).marker = 'none';
    PO.lineSpec(2).markersize = 10;
    PO.lineSpec(2).color = [51 51 153]/255;
end
if ~exist('plotAxis','var')
    % If there is no axis specified in the passed inputs, create a new
    % one in a new figure.
    figure('Position',PO.position);
    plotAxis = axes;
end

% Specify output to plot
if (nargin < 3 || isempty(outputToPlot)) && obj.info.numberOfOutputs == 1
    outputToPlot = 1;
elseif nargin < 3 && obj.numberOfOutputs > 1
    error('plotGlobalModel:plotPartialDependencyModel','You have to specify an output to plot!')
elseif ~isscalar(outputToPlot)
    error('plotGlobalModel:plotPartialDependencyModel','The output to plot must be given as a scalar')
end


% test if dynamic model
if (~isempty(obj.xInputDelay) && any(cellfun(@(d) ~isempty(d) && any(d>0),obj.xInputDelay))) ...
        || (~isempty(obj.zInputDelay) && any(cellfun(@(d) ~isempty(d) && any(d>0),obj.zInputDelay))) ...
        || (~isempty(obj.xOutputDelay) && any(cellfun(@(d) ~isempty(d) && any(d>0),obj.xOutputDelay))) ...
        || (~isempty(obj.zOutputDelay) && any(cellfun(@(d) ~isempty(d) && any(d>0),obj.zOutputDelay)))
    
    howToPlot = 'dynamic1D';
    
else % Static model
    if nargin > 1 && ~isempty(inputToPlot)
        if any(inputToPlot > dimension)
            % test for missmatch
            error('plotGlobalModel:plotPartialDependencyModel',['Dimension(s) possible: ' num2str(1:dimension) ', Dimension(s) you want to plot: ' num2str(inputToPlot)])
        else
            if length(inputToPlot) == 1
                howToPlot ='static1D';
            elseif length(inputToPlot) == 2
                howToPlot = 'static2D';
            elseif length(inputToPlot) > 2
                error('plotGlobalModel:plotPartialDependencyModel','Too many inputs chosen.')
            end
        end
        
    else
        % if there are no input(s) to plot given
        error('globalModel:plotPartialDependencyModel','It is necessary to specify an input to plot for a partial dependency model plot.')
    end
end

% Pre-define handles, that will be given back by the function
valueHandle = [];
uncertaintyHandles = cell(1,2);
axisHandle = plotAxis;
axesDescriptionHandles = {};
legendDescription = {};
legendHandle = [];
titleHandle = [];
scalingFactor = 1;

% make plots
switch howToPlot
    
    case 'static1D'
        %% ----------------------------------------------------------------
        % 1D plot
        % -----------------------------------------------------------------
        
        % Display
        fprintf('Plot model for dimension %d.\n', inputToPlot);
        
        % build input matrix for plot
        x = linspace(lowerBounds(inputToPlot),upperBounds(inputToPlot),resolution)';
        
        % Calculate partial dependence output
        [value,upperUncertainty,lowerUncertainty] = ...
            obj.calculatePartialDependenceOutput(x,inputToPlot,outputToPlot,showValue);
        
        % plot model
        hold(plotAxis,'on');
        
        
        % Plot median or mean value
        valueHandle = plot(plotAxis,x,value,...
            'Color',PO.lineSpec(1).color,...
            'linewidth',PO.lineSpec(1).linewidth,...
            'Marker',PO.lineSpec(1).marker,...
            'MarkerSize',PO.lineSpec(1).markersize,...
            'LineStyle',PO.lineSpec(1).linestyle);
        
        if scaleuncertainty
            % Save current y-axis limits
            uncertaintyLimits = [min(value) max(value)];
            valueRange = uncertaintyLimits(2) - uncertaintyLimits(1);
            uncertaintyLimits(1) = uncertaintyLimits(1) - 0.2*valueRange;
            uncertaintyLimits(2) = uncertaintyLimits(2) + 0.2*valueRange;
        end
        
        switch lower(showValue)
            case 'median'
                
                if scaleuncertainty
                    % Scale uncertainties if necessary
                    if any(lowerUncertainty < uncertaintyLimits(1))
                        % Minimum value of the lower uncertainties
                        [~,minIdx] = min(lowerUncertainty);
                        
                        % The scaling factor should scale the interval between
                        % the upper and lower uncertainty
                        scalingFactor = (value(minIdx) - uncertaintyLimits(1))/(value(minIdx)-lowerUncertainty(minIdx));
                    end
                    if any(upperUncertainty > uncertaintyLimits(2))
                        % Maximum value of the upper uncertainties
                        [~,maxIdx] = max(upperUncertainty);
                        
                        % The scaling factor should scale the interval between
                        % the upper and lower uncertainty
                        scalingFactorTmp = (uncertaintyLimits(2) - value(maxIdx))/(upperUncertainty(maxIdx)-value(maxIdx));
                        scalingFactor = min([scalingFactor scalingFactorTmp]);
                    end
                    
                end
                
                % Scale lower and upper uncertainties
                scaledLowerUncertainty = (1-scalingFactor)*value + scalingFactor*lowerUncertainty;
                scaledUpperUncertainty = (1-scalingFactor)*value + scalingFactor*upperUncertainty;
                
                % Plot 25th percentile
                uncertaintyHandles{1} = plot(plotAxis,x,scaledLowerUncertainty,...
                    'Color',PO.lineSpec(end).color,...
                    'linewidth',PO.lineSpec(end).linewidth,...
                    'Marker',PO.lineSpec(end).marker,...
                    'MarkerSize',PO.lineSpec(end).markersize,...
                    'LineStyle',PO.lineSpec(end).linestyle);
                
                
                % Plot 75th percentile
                uncertaintyHandles{2} = plot(plotAxis,x,scaledUpperUncertainty,...
                    'Color',PO.lineSpec(end).color,...
                    'linewidth',PO.lineSpec(end).linewidth,...
                    'Marker',PO.lineSpec(end).marker,...
                    'MarkerSize',PO.lineSpec(end).markersize,...
                    'LineStyle',PO.lineSpec(end).linestyle);
                
                % Define legend cell-string
                legendDescription{size(legendDescription,2)+1} = 'median';
                
                if scalingFactor ~= 1
                    lowerDescr = ['25 Percentil (scaling factor: ',num2str(scalingFactor,2),')'];
                    upperDescr = ['75 Percentil (scaling factor: ',num2str(scalingFactor,2),')'];
                else
                    lowerDescr = '25 Percentil';
                    upperDescr = '75 Percentil';
                end
                
                legendDescription{size(legendDescription,2)+1} = lowerDescr;
                legendDescription{size(legendDescription,2)+1} = upperDescr;
                    
                
            otherwise
                % Show mean values and standard deviations in case of a
                % misspelling
                
                % Get absolute values for the uncertainties (not depending
                % on the mean-values)
                upperUncertainty = value+upperUncertainty;
                lowerUncertainty = value-lowerUncertainty;
                
                if scaleuncertainty
                    % Scale uncertainties if necessary
                    if any(lowerUncertainty < uncertaintyLimits(1))
                        % Minimum value of the lower uncertainties
                        [~,minIdx] = min(lowerUncertainty);
                        
                        % The scaling factor should scale the interval between
                        % the upper and lower uncertainty
                        scalingFactor = (value(minIdx) - uncertaintyLimits(1))/(value(minIdx)-lowerUncertainty(minIdx));
                    end
                    if any(upperUncertainty > uncertaintyLimits(2))
                        % Maximum value of the upper uncertainties
                        [~,maxIdx] = max(upperUncertainty);
                        
                        % The scaling factor should scale the interval between
                        % the upper and lower uncertainty
                        scalingFactorTmp = (uncertaintyLimits(2) - value(maxIdx))/(upperUncertainty(maxIdx)-value(maxIdx));
                        scalingFactor = min([scalingFactor scalingFactorTmp]);
                    end
                end
                
                % Scale lower and upper uncertainties
                scaledLowerUncertainty = (1-scalingFactor)*value + scalingFactor*lowerUncertainty;
                scaledUpperUncertainty = (1-scalingFactor)*value + scalingFactor*upperUncertainty;
                
                % Plot standard deviation
                uncertaintyHandles{1} = plot(plotAxis,x,scaledUpperUncertainty,...
                    'Color',PO.lineSpec(end).color,...
                    'linewidth',PO.lineSpec(end).linewidth,...
                    'Marker',PO.lineSpec(end).marker,...
                    'MarkerSize',PO.lineSpec(end).markersize,...
                    'LineStyle',PO.lineSpec(end).linestyle);
                uncertaintyHandles{2} = plot(plotAxis,x,scaledLowerUncertainty,...
                    'Color',PO.lineSpec(end).color,...
                    'linewidth',PO.lineSpec(end).linewidth,...
                    'Marker',PO.lineSpec(end).marker,...
                    'MarkerSize',PO.lineSpec(end).markersize,...
                    'LineStyle',PO.lineSpec(end).linestyle);
                
                % Define legend cell-string
                legendDescription{size(legendDescription,2)+1} = 'mean';
                
                if scalingFactor ~= 1
                    descr = ['standard deviation (scaling factor: ',num2str(scalingFactor,2),')'];
                else
                    descr = 'standard deviation';
                end
                
                legendDescription{size(legendDescription,2)+1} = descr;
        end
        
        
        if options.legend==1
            legendHandle = legend(plotAxis,legendDescription,'FontSize',PO.fontsize,'FontName',PO.fontname);
        end
        
        hold(plotAxis,'off');
        
        axesDescriptionHandles{end+1} = xlabel(obj.info.inputDescription{inputToPlot},...
            'FontSize',PO.fontsize,'FontName',PO.fontname,'Interpreter','latex');
        axesDescriptionHandles{end+1} = ylabel(obj.info.outputDescription{outputToPlot},...
            'FontSize',PO.fontsize,'FontName',PO.fontname,'Interpreter','latex');

        set(plotAxis,'Box','on','FontSize',PO.fontsize,'FontName',PO.fontname,...
            'XTick',[lowerBounds(inputToPlot) (upperBounds(inputToPlot)+lowerBounds(inputToPlot))/2 upperBounds(inputToPlot)]);
        
        if ~isempty(percentiles)
            % Visualize the user-demanded percentiles of the data
            % distribution along the user-demanded axes
            percentileCoordinates = NaN(2,size(percentiles,2),size(inputToPlot,2));
            
            % Pre-define cell array for line handles
            percentileLines = cell(size(percentiles,2),size(inputToPlot,2));
            
            % Get minimum and maximum values of the y-axis
            oldAxisYlim = get(plotAxis,'YLIM');
            yminmax = [min(obj.unscaledOutput(:,outputToPlot)) max(obj.unscaledOutput(:,outputToPlot))];
            
            for kk=1:size(inputToPlot,2)
                for ll=1:size(percentiles,2)
                    % Calculate value of current percentile
                    percentileCoordinates(:,ll,kk) = prctile(obj.unscaledInput(:,inputToPlot(kk)),percentiles(ll));
                    
                    % Plot line at value
                    percentileLines{kk,ll} =line(percentileCoordinates(:,ll,kk),yminmax,...
                        'LineWidth',PO.lineSpec(end-1).linewidth,...
                        'LineStyle',PO.lineSpec(end-1).linestyle,...
                        'Color',PO.lineSpec(end-1).color,...
                        'Marker',PO.lineSpec(end-1).marker,...
                        'MarkerSize',PO.lineSpec(end-1).markersize);
                end
            end
            
            % set the limits of the y axis again
            set(plotAxis,'YLim',oldAxisYlim);
        end
        
    case 'static2D'
        %% ----------------------------------------------------------------
        % 2D plot
        % -----------------------------------------------------------------
        
        % Display
        fprintf('Plot model for dimensions %d and %d.\n', inputToPlot(1), inputToPlot(2));
        
        % build input matrix for plot
        [X1,X2] = meshgrid(linspace(lowerBounds(inputToPlot(1)),upperBounds(inputToPlot(1)),resolution),...
            linspace(lowerBounds(inputToPlot(2)),upperBounds(inputToPlot(2)),resolution));
        x = [X1(:) X2(:)];
        
        % Calculate partial dependence output
        [value,upperUncertainty,lowerUncertainty] = ...
            obj.calculatePartialDependenceOutput(x,inputToPlot,outputToPlot,showValue);
        
        
        % Plot mean or median value
        valueHandle = surf(plotAxis,X1,X2,reshape(value,resolution,resolution));
        
        hold(plotAxis,'on');
        
        switch lower(showValue)
            case 'median'
                % Plot percentiles
                uncertaintyHandles{1} = ...
                    surf(plotAxis,X1,X2,reshape(lowerUncertainty,resolution,resolution),'FaceColor','None');
                uncertaintyHandles{2} = ...
                    surf(plotAxis,X1,X2,reshape(upperUncertainty,resolution,resolution),'FaceColor','None');
            otherwise
                % Plot standard deviations
                uncertaintyHandles{1} = ...
                    surf(plotAxis,X1,X2,reshape(value+upperUncertainty,resolution,resolution),'FaceColor','None');
                uncertaintyHandles{2} = ...
                    surf(plotAxis,X1,X2,reshape(value-lowerUncertainty,resolution,resolution),'FaceColor','None');
        end
        
        axesDescriptionHandles{end+1} = xlabel(obj.info.inputDescription{inputToPlot(1)},...
            'FontSize',PO.fontsize,'FontName',PO.fontname);
        axesDescriptionHandles{end+1} = ylabel(obj.info.inputDescription{inputToPlot(2)},...
            'FontSize',PO.fontsize,'FontName',PO.fontname);
        axesDescriptionHandles{end+1} = zlabel('Output Mean','FontSize',PO.fontsize,'FontName',PO.fontname);

        grid(plotAxis,'on');
        
        set(plotAxis,'Box','off','FontSize',PO.fontsize,'FontName',PO.fontname,...
            'XTick',[lowerBounds(inputToPlot(1)) (upperBounds(inputToPlot(1))+lowerBounds(inputToPlot(1)))/2 upperBounds(inputToPlot(1))],...
            'YTick',[lowerBounds(inputToPlot(2)) (upperBounds(inputToPlot(2))+lowerBounds(inputToPlot(2)))/2 upperBounds(inputToPlot(2))])
        hold(plotAxis,'off')
        
        % Create title
        titleString = ['Output ',showValue];
        titleHandle = title(plotAxis,titleString,'FontSize',PO.fontsize,'FontName',PO.fontname);
        
    case 'dynamic1D'
        % Not implemented yet
        %         %% ----------------------------------------------------------------
        %         % dynamic 1D plot
        %         % -----------------------------------------------------------------
        %
        %         if ~isempty(obj.input) && ~isempty(obj.output)
        %             outputModel = obj.calculateModelOutput(obj.unscaledInput,obj.unscaledOutput);
        %             hold(plotAxis,'on')
        %             hdata = plot(obj.unscaledOutput(:,outputToPlot),'r');
        %             hmodel = plot(plotAxis,outputModel(:,outputToPlot));
        %             hold(plotAxis,'off')
        %         end
        %
        %         legend(plotAxis,[hmodel,hdata],'model','training data')
        %         xlabel('time')
        %         ylabel(obj.info.outputDescription{outputToPlot})
        %         title(obj.info.dataSetDescription)
        
end

end