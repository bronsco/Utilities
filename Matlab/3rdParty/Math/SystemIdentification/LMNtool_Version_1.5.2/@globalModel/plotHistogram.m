function plotHistogram(obj,absOrRel, n)
%% PLOTHISTOGRAMM plots the histogram between model output vs. training output.
%
%
%       plotHistogram
%
%
%   See also plotModel, plotPartition, plotCorrelation, plotModelCentered.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 13-May-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

schrift = 15;
plotAxis = gca;


if (nargin < 2) || isempty(absOrRel)
    absOrRel = 'abs' ;
end

% number of elemets acording to rule of Sturges
numberOfSamples = size(obj.output,1);
numberOfValidationSamples = size(obj.validationOutput,1);
numberOfTestSamples = size(obj.testOutput,1);

if (nargin < 3) || isempty(n)
    n = ceil(1 + log2(numberOfSamples));
end

numberOfOutputs = size(obj.output,2);

% calculate the model output of validatino and testdata
if ~isempty(obj.validationInput) && ~isempty(obj.validationOutput)
    validationOutputModel = obj.calculateModelOutput(obj.validationInput);
end
if ~isempty(obj.testInput) && ~isempty(obj.testOutput)
    testOutputModel = obj.calculateModelOutput(obj.testInput);
end

nVal = []; nTest = [];
for k = numberOfOutputs
    
    % get numbers and centers for the histogram
    [nTrain, hcenter] = hist(bsxfun(@minus, obj.outputModel(:,k), obj.output(:,k)), n);
    n = nTrain'/numberOfSamples;   
    histLegend{1} = 'Training data';
    
    if ~isempty(obj.validationInput) && ~isempty(obj.validationOutput)
        nVal = hist(bsxfun(@minus, validationOutputModel(:,k), obj.validationOutput(:,k)), hcenter);
        n(:,end+1) = nVal'/numberOfValidationSamples;
        histLegend{end+1} = 'Validation data';
    end
    if ~isempty(obj.testInput) && ~isempty(obj.testOutput)
        nTest = hist(bsxfun(@minus, testOutputModel(:,k), obj.testOutput(:,k)), hcenter);
        n(:,end+1) = nTest'/numberOfTestSamples;
        histLegend{end+1} = 'Test data';
    end
    
    switch absOrRel
        case 'abs'
            % histogram of absolut errors
            hbar = bar(plotAxis, hcenter,n*100);
            xlabel('$\hat{y}-y$','interpreter','latex','fontsize',schrift)
            set(plotAxis,'XTick',diff(hcenter)+hcenter(1:end-1))
            
        case 'rel'
            % histogram of relative errors
            %yStd = std(obj.output(:,k)-mean(obj.output(:,k)));
            yRange = range(obj.output(:,k));
            
            hbar = bar(plotAxis, hcenter/yRange,n*100);
            %xlabel('$\hat{y}-y / \sigma{(y)}$','interpreter','latex')
            
            xlabel('$(\hat{y}-y) / (y_{max}-y_{min})$','interpreter','latex','fontsize',schrift)
            set(plotAxis,'XTick',(diff(hcenter)+hcenter(1:end-1))/yRange)
            
        case 'std'
            yStd = std(obj.output(:,k)-mean(obj.output(:,k)));
             hbar = bar(plotAxis, hcenter/yStd,n*100);
             xlabel('$(\hat{y}-y) / \sigma(y)$','interpreter','latex','fontsize',schrift)
            set(plotAxis,'XTick',(diff(hcenter)+hcenter(1:end-1))/yStd)
            
    end
    
    ylabel('percent of samples','interpreter','latex','fontsize',schrift)
    legend(hbar,histLegend)
end

end