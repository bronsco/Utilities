function plotCorrelation(obj)
%% PLOTLOSSFUNCTION plots the correlation between model output vs. training output.
%
%
%       plotCorrelation
%
%
%   See also plotModel, plotPartition, plotCorrelation, plotModelCentered.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 12-December-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

schrift = 15;
plotAxis = gca;

hCorrPlot = [];
hCorrLegend = {};

% plot y over yhat
trainingOutputModel = obj.calculateModelOutput(obj.unscaledInput,obj.unscaledOutput);
hCorrPlot(end+1) = plot(obj.unscaledOutput,trainingOutputModel,'k.','markersize',12);
hCorrLegend{end+1} = 'Training data';
hold all

minAx = min(min(obj.unscaledOutput),min(trainingOutputModel));
maxAx = max(max(obj.unscaledOutput),max(trainingOutputModel));

% plot validation Data
if ~isempty(obj.validationInput) && ~isempty(obj.validationOutput)
    validationOutputModel = obj.calculateModelOutput(obj.validationInput);
    hCorrPlot(end+1) = plot(obj.validationOutput,validationOutputModel,'g.','markersize',12);
    hCorrLegend{end+1} = 'Validation data';
end

% plot test data
if ~isempty(obj.testInput) && ~isempty(obj.testOutput)
    testOutputModel = obj.calculateModelOutput(obj.testInput);
    hCorrPlot(end+1) = plot(obj.testOutput,testOutputModel,...
        'Marker','.','Color',[255 102 0]/255,'markersize',12,...
        'LineStyle','none');
    hCorrLegend{end+1} = 'Test data';
end

legend(hCorrPlot,hCorrLegend,'Location','NorthWest','fontsize',schrift,'fontName','Arial')

% plot 45° line
line([minAx maxAx],[minAx maxAx],'color','k','LineStyle','--')

axis([minAx maxAx minAx maxAx])
title('correlation plot of model','fontsize',schrift,'fontName','Arial')
%set(hPlot,'fontsize',schrift,'fontName','Times New Roman'); %zlabel('y','fontsize',schrift,'fontName','Times New Roman')

xlabel('Measured output','fontsize',schrift,'fontName','Arial'); 
ylabel('Model output','fontsize',schrift,'fontName','Arial')
set(plotAxis,'FontName','Arial','FontSize',schrift);

end