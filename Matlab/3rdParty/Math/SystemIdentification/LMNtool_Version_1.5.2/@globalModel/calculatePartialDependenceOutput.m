function [value, upperUncertainty, lowerUncertainty] = calculatePartialDependenceOutput(obj,input,inputs2beVaried,outputToPlot,meanOrMedian)
%% CALCULATEPARTIALDEPENDENCEOUTPUT calculates the partial dependence output.
%
%       [value, upperUncertainty, lowerUncertainty] = calculatePartialDependenceOutput(obj,input,inputs2beVaried,outputToPlot,valueFlag)
%
%   calculateModelOutput outputs:
%       value             - (N x 1) Mean or median values for the given input values
%       upperUncertainty  - (N x 1) Upper uncertaintiy boundary (75th percentile or standard deviation)
%       lowerUncertainty  - (N x 1) Lower uncertaintiy boundary (25th percentile or standard deviation)
%
%   calculateModelOutput inputs:
%       obj              - (object) LMN object
%       input            - (N x np) Values for the dependent input(s).
%       inputs2beVaried  - (1 x np) Column index of the dependent variables.
%       outputToPlot     - (1 x 1)  Column index of the output, that should be visualized.
%       meanOrMedian     - (string) Determines if the 'mean' or 'median' values should be visualized.
%
%   SYMBOLS AND ABBREVIATIONS
%
%       LM:  Local model
%
%       p:   Number of inputs (physical inputs)
%       q:   Number of outputs
%       N:   Number of data samples
%       M:   Number of LMs
%       nx:  Number of regressors (x)
%       nz:  Number of regressors (z)
%       np:  Number of dependent variables.
%
%   See also plotPartialDependenceModel, partialDependencePlotOverview.
%
%
%   LMNtool - Local Model Network Toolbox
%   Julian Belz, 18-April-2014
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2014 by Prof. Dr.-Ing. Oliver Nelles


% build input matrix for plot
X = obj.unscaledInput;

% Initialize variables for plotting
plotOutputMean = zeros(size(input,1),1);
plotOutputMedian = zeros(size(input,1),1);
plotOutputStd = zeros(size(input,1),1);
plotOutput25Percentil = zeros(size(input,1),1);
plotOutput75Percentil = zeros(size(input,1),1);

for k = 1:length(input)
    
    for ii=1:size(inputs2beVaried,2)
        X(:,inputs2beVaried(ii)) = input(k,ii);
    end
    
    % calculate model output
    outputModel = obj.calculateModelOutput(X);
    % Calculate the mean of the query point
    plotOutputMean(k) = mean(outputModel(:,outputToPlot));
    % Calculate the media of the query point
    plotOutputMedian(k) = median(outputModel(:,outputToPlot));
    % Calculate the standard deviation of the query point
    plotOutputStd(k) = std(outputModel(:,outputToPlot));
    % Calculate the 25th percentile of the query point
    plotOutput25Percentil(k) = prctile(outputModel(:,outputToPlot),25);
    % Calculate the 75th percentile of the query point
    plotOutput75Percentil(k) = prctile(outputModel(:,outputToPlot),75);
    
end

% The variable valueFlag determines, which values will be given back from
% this function
if strcmpi(meanOrMedian,'median')
    value = plotOutputMedian;
    upperUncertainty = plotOutput75Percentil;
    lowerUncertainty = plotOutput25Percentil;
else
    value = plotOutputMean;
    upperUncertainty = plotOutputStd;
    lowerUncertainty = plotOutputStd;
end
