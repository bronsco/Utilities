function plotModel(obj, inputToPlot, outputToPlot, constDimValue, options)
%% PLOTMODEL plots the model output
%
%
%       plotModel(obj, inputToPlot, outputToPlot, constDimValue, options)
%
%
% 	plotModel inputs:
%
%       inputToPlot    - (1 x [1,2]) Vector of dimensions to be plotted,
%                                    e.g. dimensions = [2 5] (optional).
%       outputToPlot   - (scalar) Output dimension to plot.
%       constDimValue  - (vector) Set values of inputs that have to be hold constant for plotting.
%       options        - (struct) Structure containing plot options. The following options can be
%                                 used:
%                                       options.resolution     - (scalar) Grid resolution per axis for 2D plots
%                                                                (default: 30).
%                                       options.plotAxis       - If the plot is assigned to a specific
%                                                                axis handle. Used in e.g. GUIvisualized
%                                                                (default: gca).
%                                       options.plotDataMethod - Style of lines and markers:
%                                                                [ {'crosses'} | 'interpolated' | 'circles']
%
%
%   See also plotPartition, plotLossFunction, plotCorrelation, plotModelCentered.
%
%
%   LMNtool - Local Model Network Toolbox
%   Benjamin Hartmann, 07-November-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Get constants
dimension     = obj.info.numberOfInputs;
lower         = min(obj.unscaledInput);   % Upper and lower input bounds
upper         = max(obj.unscaledInput);

% Set plot options
if exist('options','var') && isfield(options,'resolution')
    resolution = options.resolution;
else
    resolution    = [];
end
if exist('options','var') && isfield(options,'plotAxis')
    plotAxis = options.plotAxis;
else
    plotAxis = gca;
end
if exist('options','var') && isfield(options,'plotDataMethod')
    plotDataMethod = options.plotDataMethod;
else
    plotDataMethod = {'crosses'};
end

% specify output to plot
if (~exist('outputToPlot','var') || isempty(outputToPlot)) && obj.info.numberOfOutputs == 1
    outputToPlot = 1;
elseif ~exist('outputToPlot','var') && obj.info.numberOfOutputs > 1
    warning('plotGlobalModel:plotModel','You have to specify an output to plot!')
    return
elseif ~isscalar(outputToPlot)
    warning('plotGlobalModel:plotModel','The output to plot must be given as a scalar')
    return
end

% test if dynamic model
if (~isempty(obj.xInputDelay) && any(cellfun(@(d) ~isempty(d) && any(d>0),obj.xInputDelay))) ...
        || (~isempty(obj.zInputDelay) && any(cellfun(@(d) ~isempty(d) && any(d>0),obj.zInputDelay))) ...
        || (~isempty(obj.xOutputDelay) && any(cellfun(@(d) ~isempty(d) && any(d>0),obj.xOutputDelay))) ...
        || (~isempty(obj.zOutputDelay) && any(cellfun(@(d) ~isempty(d) && any(d>0),obj.zOutputDelay)))
    
    howToPlot = 'dynamic1D';
    
else % Static model
    if exist('inputToPlot','var') && ~isempty(inputToPlot) && any(inputToPlot > dimension)
        % test for wring dims
        error(['Dimension(s) possible: ' num2str(1:dimension) ', Dimension(s) you want to plot: ' num2str(inputToPlot)])
        
    elseif ~exist('inputToPlot','var') || isempty(inputToPlot)
        % if there is no dimToPlot given
        if dimension == 1
            inputToPlot = 1;
            howToPlot =1;
        elseif dimension == 2
            inputToPlot = [1 2];
            howToPlot = 2;
        else
            warning('Please speacify an input dimension to plot. Input 1 and 2 will be used')
            return
        end
        
    else
        % if there are inputs given
        howToPlot = length(inputToPlot);
    end
    
end

% make plots
switch howToPlot
    
    case 1
        %% ----------------------------------------------------------------
        % 1D plot
        % -----------------------------------------------------------------
        
        % Display
        fprintf('Plot model for dimension %d.\n', inputToPlot);
        
        % Set default resolution, if not given
        if isempty(resolution); resolution = 500; end
        
        % build input matrix for plot
        XI = linspace(lower(inputToPlot),upper(inputToPlot),resolution);
        if dimension == 1
            plotInput = XI(:);
        else
            if exist('constDimValue','var') && ~isempty(constDimValue)
                plotInput = ones(length(XI(:)),1) * constDimValue;
            else
                plotInput = ones(length(XI(:)),1) * mean([upper;lower]);
            end
            plotInput(:,inputToPlot) = XI(:);
        end
        % calculate mode output
        plotOutput = obj.calculateModelOutput(plotInput);
        
        if any(strcmp(plotDataMethod, 'interpolated'))
            % plot data (interpolated)
            hold(plotAxis,'on')
            % find unique data inputs
            [~, uniqueIdx, repetitions] = unique(obj.unscaledInput(:,inputToPlot));
            % get unique data inputs
            dataPlotInput = obj.unscaledInput(uniqueIdx,inputToPlot);
            for k = unique(repetitions)'
                % get correponding data outputs
                dataPlotOutput(k) = mean(obj.unscaledOutput(repetitions==k,outputToPlot));
            end
            outputInterp = interp1(dataPlotInput,dataPlotOutput,XI,'linear');
            
            hinterp = plot(plotAxis,XI,outputInterp,'marker','none','markersize',13,'color',[0.9 0.9 0.9],'linestyle','-','linewidth',1.5);
            hold(plotAxis,'off')
        end
        if any(strcmp(plotDataMethod, 'circles'))
            % plot data as circles
            hold(plotAxis,'on')
            hdata = plot(plotAxis,obj.unscaledInput(:,inputToPlot),obj.unscaledOutput(:,outputToPlot),'or');
            hold(plotAxis,'off')
        end
        if any(strcmp(plotDataMethod, 'crosses'))
            % plot data as circles
            hold(plotAxis,'on')
            hdata = plot(plotAxis,obj.unscaledInput(:,inputToPlot),obj.unscaledOutput(:,outputToPlot),'kx','markersize',12);
            hold(plotAxis,'off')
        end
        
        
        % plot model
        hold(plotAxis,'on')
        hmodel = plot(plotAxis,XI,plotOutput(:,outputToPlot),'k','linewidth',1);
        hold(plotAxis,'off')
        
        %legend(plotAxis,[hmodel, hinterp], 'model', 'process')
        %legend(plotAxis,[hmodel, hinterp, hdata], 'model output', 'data interpolation', 'data')
        legend(plotAxis,[hmodel, hdata], 'model output', 'data')
        xlabel(obj.info.inputDescription{inputToPlot})
        ylabel(obj.info.outputDescription{outputToPlot})
        %title(obj.info.dataSetDescription)
        set(gca,'Box','on')
        
    case 2
        %% ----------------------------------------------------------------
        % 2D plot
        % -----------------------------------------------------------------
        
        schrift = 14;
        
        % Display
        fprintf('Plot model for dimensions %d and %d.\n', inputToPlot(1), inputToPlot(2));
        
        % Set default resolution, if not given
        if isempty(resolution); resolution = 30; end
        
        % build input matrix for plot
        [XI,YI] = meshgrid(linspace(lower(inputToPlot(1)),upper(inputToPlot(1)),resolution),...
            linspace(lower(inputToPlot(2)),upper(inputToPlot(2)),resolution));
        if dimension == 2
            plotInput = [XI(:) YI(:)];
        else
            if exist('constDimValue','var') && ~isempty(constDimValue)
                plotInput = ones(length(XI(:)),1) * constDimValue;
            else
                plotInput = ones(length(XI(:)),1) * mean([upper;lower]);
            end
            plotInput(:,inputToPlot) = [XI(:) YI(:)];
        end
        
        % calculate model output
        plotOutput = obj.calculateModelOutput(plotInput);
        % reshape model output for surf plot
        Zmodel = full(reshape(plotOutput(:,outputToPlot),resolution,resolution));
        
        % plot model
        surf(plotAxis,XI,YI,Zmodel);
        
        if any(strcmp(plotDataMethod, 'interpolated'))
            % plot data (interpolated)
            hold(plotAxis,'on')
            F = TriScatteredInterp(obj.unscaledInput(:,inputToPlot(1)),obj.unscaledInput(:,inputToPlot(2)),obj.unscaledOutput(:,outputToPlot));
            outputInterp = F(XI,YI);
            
            hdata = mesh(plotAxis,XI,YI,outputInterp);
            % make faces invisibel
            %set(hdata(1),'FaceAlpha',0)
            set(hdata(1),'FaceColor','None','EdgeColor',[0 0 0])
            hold(plotAxis,'off')
        end
        if any(strcmp(plotDataMethod, 'circles'))
            % plot data points
            hold(plotAxis,'on')
            hdata = plot3(plotAxis,obj.unscaledInput(:,inputToPlot(1)),obj.unscaledInput(:,inputToPlot(2)),obj.unscaledOutput(:,outputToPlot),'or');
            hold(plotAxis,'off')
        end
        if any(strcmp(plotDataMethod, 'crosses'))
            % plot data as circles
            hold(plotAxis,'on')
            hdata = plot3(plotAxis,obj.unscaledInput(:,inputToPlot(1)),obj.unscaledInput(:,inputToPlot(2)),obj.unscaledOutput(:,outputToPlot),'kx','MarkerSize',12,'LineWidth',1.5);
            hold(plotAxis,'off')
        end
        
        camlight left; lighting phong
%         xlabel(obj.info.inputDescription{inputToPlot(1)})
%         ylabel(obj.info.inputDescription{inputToPlot(2)})
%         zlabel(obj.info.outputDescription{outputToPlot})
%         title(obj.info.dataSetDescription)

        xlabel('$u_1$','fontsize',schrift,'fontName','Times New Roman','interpreter','latex')
        ylabel('$u_2$','fontsize',schrift,'fontName','Times New Roman','interpreter','latex')
        zlabel('$y_1$','FontSize',schrift,'FontName','Time New Roman','Interpreter','latex')
        set(gca,'fontsize',schrift,'fontName','Times New Roman','XTick',[0 0.5 1],'YTick',[0 0.5 1],'LineWidth',1.5)
        
        
%         if isempty(obj.scaleInput)
%             title('Partitioning of Input Space')
%         else
%             title('Partitioning of Scaled Input Space')
%         end
        
        
    case 'dynamic1D'
        %% ----------------------------------------------------------------
        % dynamic 1D plot
        % -----------------------------------------------------------------
        maxDelay = obj.getMaxDelay();
        if ~isempty(obj.input) && ~isempty(obj.output)
            outputModel = obj.calculateModelOutput(obj.unscaledInput,obj.unscaledOutput);
            hold(plotAxis,'on')
            hdata = plot(obj.unscaledOutput(maxDelay+1:end,outputToPlot),'r');
            hmodel = plot(plotAxis,outputModel(:,outputToPlot));
            hold(plotAxis,'off')
        end
        
        legend(plotAxis,[hmodel,hdata],'model','training data')
        xlabel('time')
        ylabel(obj.info.outputDescription{outputToPlot})
        title(obj.info.dataSetDescription)
        
end



end
