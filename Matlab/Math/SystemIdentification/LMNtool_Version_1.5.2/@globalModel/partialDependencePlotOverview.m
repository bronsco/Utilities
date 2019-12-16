function [ah,fh] = partialDependencePlotOverview(obj,inputsToPlot,...
    outputToPlot,meanOrMedian,plotdim,plotOptionObject,scaleuncertainty,equalAxisScaling)
%% partialDependencePlotOverview draws multiple partial dependence plots into one (or more) figure(s)
%
%
%       [ah,fh] = partialDependencePlotOverview(obj,inputsToPlot,outputToPlot,plotdim,plotOptionObject)
%
%
% 	partialDependencePlotOverview inputs:
%
%       inputToPlot      - (1 x [1,2]) Vector of dimensions to be plotted,
%                                      e.g. dimensions = [2 5] (optional).
%       outputToPlot     - (scalar)    Output dimension to plot.
%       meanOrMedian     - (string)    Determines if the 'mean' or 'median'
%                                      values should be visualized.
%       plotDim          - (1 x 2)     First entry defines the number of
%                                      rows, second the number of columns for 
%                                      each figure
%       plotOptionObject - (object)    plotOptions object containing
%                                      information for the visualization
%       
%
%
%   See also plotPartialDependenceModel, calculatePartialDependenceOutput.
%
%
%   LMNtool - Local Model Network Toolbox
%   Julian Belz, 20-Nov-2014
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2014 by Prof. Dr.-Ing. Oliver Nelles



%% Set default options, if no parameters are passed to this funtion
if nargin < 1
    error('Too few input arguments. You have to pass one trained local model network at least.');
end
if nargin < 2 || isempty(inputsToPlot)
    inputsToPlot = 1:obj.info.numberOfInputs;
end
if nargin < 3  || isempty(outputToPlot)
    outputToPlot = 1;
end
if nargin < 4  || isempty(meanOrMedian)
    meanOrMedian = 'mean';
end
if nargin < 5  || isempty(plotdim)
    plotdim = [3,3];
end
if nargin < 6  || isempty(plotOptionObject)
    scrsize = get(0,'ScreenSize');
    plotOptionObject = plotOptions(0.8*scrsize(3),0.8*scrsize(4));
end
if nargin < 7 || isempty(scaleuncertainty)
    scaleuncertainty = true;
end
if nargin < 8 || isempty(equalAxisScaling)
    equalAxisScaling = true;
end


%% check if chosen options are possible
if size(inputsToPlot,2)>obj.info.numberOfInputs
    error('More inputs chosen than available!')
end

if any(inputsToPlot>obj.info.numberOfInputs)
    error('At leasst one of your demanded inputs does not exist!')
end


%% draw the partial dependence plots
% number of figures required
numberoffigures = ceil( size(inputsToPlot,2) / (plotdim(1)*plotdim(2)) );

% Vector containing all figure handles
fh = cell(1,numberoffigures);

% Vector containing all axes handles
ah = NaN(numberoffigures,plotdim(1),plotdim(2));

axisYminimum = inf;
axisYmaximum = -inf;

% axisXminimum = inf;
% axisXmaximum = -inf;

% plotPartialDependenceModel(obj,[1],[1], options);
% ii: index for figures
% jj: index for lines on figure. reset after figure change
% kk: index for columns on figure. reset after figure change
% counter: laufende Nummer fuer subplot-Position, reset nach jedem Figure-Wechsel

m=0;
for ii=1:numberoffigures
    
    % create figure
    fh{ii} = figure('Position',plotOptionObject.position);
    
%     
%     counter = 0;
    
    % zeilen
    for jj=1:plotdim(1)
        
        % spalten
        for kk=1:plotdim(2)
            
            % l: current position in subplot figure
            % l=l+1;
            counter = plotdim(1)*(kk-1)+jj;
            
            % check, if actual index is an input that should be drawn
            if counter+(ii-1)*plotdim(1)*plotdim(2) <= size(inputsToPlot,2)
                
                % define subplot(x,y)
                ah(ii,jj,kk) = subplot(plotdim(1),plotdim(2),counter);
                
                % legend on/off
                if jj == 1 && kk == 1
                    showLegend = true;
                else
                    showLegend = false;
                end
                
                % draw the partial dependence plot
                plotPartialDependenceModel(obj,inputsToPlot(counter+(ii-1)*plotdim(1)*plotdim(2)),outputToPlot,...
                    'axis',ah(ii,jj,kk),...
                    'showLegend',showLegend,...
                    'show',meanOrMedian,...
                    'scaleuncertainty',scaleuncertainty);
                
                % To be able to scale all axes to the same output range,
                % the minimum and maximum values are over all loops are
                % stored
                axesYlim = get(ah(ii,jj,kk),'YLim');
                if axesYlim(1) < axisYminimum
                    axisYminimum = axesYlim(1);
                end
                if axesYlim(2) > axisYmaximum
                    axisYmaximum = axesYlim(2);
                end
                
            end
        end
        
    end
    
end

% Make sure all axis are set to the same output range
ah(isnan(ah)) = [];
if equalAxisScaling
    set([ah(:)],'YLim',[axisYminimum axisYmaximum]);
end

end