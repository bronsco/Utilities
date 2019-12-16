function plotLossFunction(obj, options)
%% PLOTLOSSFUNCTION plots the global and penalty loss function of a given model.
%
%
%       plotLossFunction(options)
%
%
% 	plotLossFunction input:
%       options - (struct) Options for plotting.
%
%
%   See also plotModel, plotPartition, plotCorrelation, plotModelCentered.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 12-December-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


warning('this plot function is not finished and subject to change')

%% check options
if exist('options','var') && isfield(options,'plotAxis')
    plotAxis = options.plotAxis;
else
    plotAxis = gca;
end


%% Plausibility check
if isempty(obj.history)
    warning('history is empty, nothing will be plotted')
    return
end

if ~iscell(obj.history.leafModelIter)
    warning('leafModelIter is not a cellarray. No plot will be generated')
    return
end

%% plot all iterations

% get number of local models
if isa(obj,'hilomotPlus') || isa(obj,'lolimotPlus')
    nLM = obj.history.currentNumberOfParameters;
    xlabelDescription = 'number of parameters';
else
    nLM = cellfun(@(x) sum(x),obj.history.leafModelIter);
    xlabelDescription = 'number of local models';
end

lossfunctionsToPlot{1} = 'termination loss function';
lossfunctionsToPlot{2} = 'global loss function';
if ~isempty(obj.history.simulationLossFunction)
    lossfunctionsToPlot{end+1} = 'simulation loss function';
end

ymin = min([...
    obj.history.globalLossFunction,...
    obj.history.globalLossFunctionUnscaled,...
    obj.history.penaltyLossFunction,...
    obj.history.normalizedBICc,...
    obj.history.simulationLossFunction,...
    obj.history.simulationLossFunctionValidationData,...
    obj.history.simulationLossFunctionTestData,...
    obj.history.validationDataLossFunction,...
    obj.history.validationDataLossFunctionUnscaled,...
    obj.history.testDataLossFunction,...
    obj.history.testDataLossFunctionUnscaled]);

ymax = max([...
    obj.history.globalLossFunction,...
    obj.history.globalLossFunctionUnscaled,...
    obj.history.penaltyLossFunction,...
    obj.history.normalizedBICc,...
    obj.history.simulationLossFunction,...
    obj.history.simulationLossFunctionValidationData,...
    obj.history.simulationLossFunctionTestData,...
    obj.history.validationDataLossFunction,...
    obj.history.validationDataLossFunctionUnscaled,...
    obj.history.testDataLossFunction,...
    obj.history.testDataLossFunctionUnscaled]);

% loop over all possible plots
for plotIdx = 1:length(lossfunctionsToPlot)
    
    % get a subplot
    subplot(1,length(lossfunctionsToPlot),plotIdx)
    
    switch lossfunctionsToPlot{plotIdx}
        
        case 'termination loss function'
            terminationLegendString = {};
            htermination = [];
            
            if ~isempty(obj.history.penaltyLossFunction)
                htermination(end+1) = plot(nLM,obj.history.penaltyLossFunction);
                hold on
                terminationLegendString{end+1} = 'normalized AICc';
                set(htermination(end),'Marker','o')
            end
            
            if ~isempty(obj.history.normalizedBICc)
                htermination(end+1) = plot(nLM,obj.history.normalizedBICc);
                hold on
                terminationLegendString{end+1} = 'normalized BICc';
                set(htermination(end),'Marker','o')
            end
            
            htermination(end+1) = plot(nLM,obj.history.terminationLossFunction);
            hold on
            terminationLegendString{end+1} = 'termination loss function';
            set(htermination(end),'Marker','o')
            
            
            ylabel(obj.lossFunctionTermination)
            legend(htermination,terminationLegendString)
            
            
        case 'global loss function'
            GLFLegendString = {[]};
            hGLF = plot(nLM,obj.history.globalLossFunction);
            GLFLegendString{1} = 'training data';
            set(hGLF(end),'Marker','o')
            
            if ~isempty(obj.history.globalLossFunctionUnscaled)
                hold all
                hGLF(end+1) = plot(nLM,obj.history.globalLossFunctionUnscaled);
                GLFLegendString{end+1} = 'training data (unscaled)';
                set(hGLF(end),'Marker','o')
            end
            
            if ~isempty(obj.history.validationDataLossFunction)
                % plot validation data
                hold all
                hGLF(end+1) = plot(nLM,obj.history.validationDataLossFunction);
                set(hGLF(end),'Marker','o')
                GLFLegendString{end+1} = 'validation data';
                
                if ~isempty(obj.history.validationDataLossFunctionUnscaled)
                    hold all
                    hGLF(end+1) = plot(nLM,obj.history.validationDataLossFunctionUnscaled);
                    set(hGLF(end),'Marker','o')
                    GLFLegendString{end+1} = 'validation data (unscaled)';
                end
            end
            
            if ~isempty(obj.history.testDataLossFunction)
                % plot test data
                hold all
                hGLF(end+1) = plot(nLM,obj.history.testDataLossFunction);
                set(hGLF(end),'Marker','o')
                GLFLegendString{end+1} = 'test data';
                
                if ~isempty(obj.history.testDataLossFunctionUnscaled)
                    hold all
                    hGLF(end+1) = plot(nLM,obj.history.testDataLossFunctionUnscaled);
                    set(hGLF(end),'Marker','o')
                    GLFLegendString{end+1} = 'test data (unscaled)';
                end
            end
            
            ylabel(obj.lossFunctionGlobal)
            title('global loss function')
            legend(hGLF,GLFLegendString)
            
            
        case 'simulation loss function'
            simLegendString = {[]};
            hsim = plot(nLM,obj.history.simulationLossFunction);
            simLegendString{1} = 'Training data';
            set(hsim,'Marker','o')
            
            if ~isempty(obj.history.simulationLossFunctionValidationData)
                hold all
                hsim(end+1) = plot(nLM,obj.history.simulationLossFunctionValidationData);
                simLegendString{end+1} = 'Validation data';
                set(hsim(end),'Marker','o')
            end
            
            if ~isempty(obj.history.simulationLossFunctionTestData)
                hold all
                hsim(end+1) = plot(nLM,obj.history.simulationLossFunctionTestData);
                simLegendString{end+1} = 'Test data';
                set(hsim(end),'Marker','o')
            end
            
            legend(hsim,simLegendString)
            ylabel(obj.lossFunctionGlobal)
            title('simulation loss function')
            
    end
    
    xlabel(xlabelDescription)
    ylim([ymin-0.05*(ymax-ymin) ymax+0.05*(ymax-ymin)])
    hold off
    
    if (ymax - ymin) > 100
        set(gca,'YScale','log')
    end
    
    
end

end

