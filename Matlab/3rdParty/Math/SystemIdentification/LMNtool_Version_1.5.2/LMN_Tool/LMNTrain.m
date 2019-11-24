function [LMNBest, AllLMN] = LMNTrain(data, validationData, testData, varargin)
%% LMNTRAIN Trains a static local model network.
%
%   LMNTrain performs the training for several local model networks of increasing complexity with
%   different algorithms on the DATA. For each approach the best model is selected. A brief overview
%   on their performance is displayed. With LMNBest the best overall model is returned. In the cell
%   AllLMN all trained local model networks are stored.
%
%   The second and third argument are optional. The following alternatives are
%   available:
%
%   1)  No other argument: The models are evaluated on the training data
%       with a complexity penalty using the AICc criterion.
%
%   2)  DATA and VALIDATIONDATA is given: The models are evaluated on a
%       validation data set given by VALIDATIONDATA which is different from
%       DATA.
%
%   3)  TESTDATA (optionally): The model is evaluated on test data which is
%       NOT used for training.
%
%
%       [LMNBest AllLMN] = LMNTrain(data, validationData, testData)
%
%
%   LMNTRAIN inputs:
%
%       data           - (N x p+1)      Training data (first p columns contain inputs, the last one contains the target variable).
%       validationData - (N_val x p+1)  Validation data used for model complexity selection.
%       testData       - (N_test x p+1) Test data is only used for test error evaluation.
%
%
%   LMNTRAIN ouputs:
%
%       LMNBest - (object) Best LMN object eihter on AICc or on validation data.
%       AllLMN  - (cell)   Cell containing all trained LMNs.
%
%
%   See also lolimot, hilomot.
%
%
%   LMNTool - Nonlinear System Identification Toolbox
%   Institute of Mechanics & Automatic Control
%   University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles et. al.

% Version: 16-January-2013
% Update 27-08-2015: Extension for MIMO systems



% Loop over all optional inputs
idx = 1;
outputweighting = [];
while idx <= nargin-3
    
    % If the current input is a string, compare it to
    % all possible properties and take idx+1 as value to
    % set the corresponding property
    if ischar(varargin{idx})
        switch lower(varargin{idx})
            case 'outputidx'
                outputIdx = varargin{idx+1};
            case 'inputidx'
                inputIdx = varargin{idx+1};
            case 'showresults'
                makeFigure = varargin{idx+1};
            case 'outputweighting'
                outputweighting = varargin{idx+1};
            case 'debugmode'
                debugMode = varargin{idx+1};
        end
        
    end
    
    % Increase index
    idx = idx + 1;
    
end

% Set default values, if necessary information is missing
if ~exist('outputIdx','var') || isempty(outputIdx)
    % By default, the last column is treated as target value
    outputIdx = size(data,2);
end
if ~exist('inputIdx','var') || isempty(outputIdx)
    % All columns that are no outputs are automatically set as inputs
    inputIdx = setxor(1:size(data,2),outputIdx);
end
if ~exist('debugMode','var') || isempty(debugMode)
    % All columns that are no outputs are automatically set as inputs
    debugMode = false;
end

% Check for errors
if size(data(:,inputIdx),2) > size(data(:,inputIdx),1)
    % check if data has more input dimesions than data samples
    error('LMNTrain:CheckData',...
        'The data seems to have %1d input dimensions, but only %2d data samples. You may have transposed the data matrix',...
        size(data(:,inputIdx),2),size(data(:,inputIdx),1))
end
if exist('validationData','var') && ~isempty(validationData)
    % check if training and validation data has the same number of input
    % dimensions
    if size(data(:,inputIdx),2) ~= size(validationData(:,inputIdx),2)
        error('LMNTrain:CheckData',...
            'The validation data has %1d input dimensions, but the training data has %2d input dimensions. Both must posses the same number of input dimensions!',...
            size(validationData(:,inputIdx),2),size(data(:,inputIdx),2))
    end
end
if exist('testData','var') && ~isempty(testData)
    % check if training and test data has the same number of input
    % dimensions
    if size(data(:,inputIdx),2) ~= size(testData(:,inputIdx),2)
        error('LMNTrain:CheckData',...
            'The test data has %1d input dimensions, but the training data has %2d input dimensions. Both must posses the same number of input dimensions!',...
            size(testData(:,inputIdx),2),size(data(:,inputIdx),2))
    end
else
    testData = [];
end

% Give warnings for bad data
if size(data(:,inputIdx),2)^2 > size(data(:,inputIdx),1)
    warning('LMNTrain:CheckData',...
        'The data has %1d input dimensions, but only %2d data samples. You should use more data samples to get a good model',...
        size(data(:,inputIdx),2),size(data(:,inputIdx),1))
end
if exist('validationData','var') && ~isempty(validationData)
    if size(validationData,1) < (size(data,1) * 0.15)
        warning('LMNTrain:CheckData','The number of validation data samples is less than 15%% of training data samples.')
    end
end

% Flag to activate plots
if ~exist('makeFigure','var') || isempty(makeFigure)
    makeFigure = 1;
end

if exist('validationData','var') && ~isempty(validationData)
    numberOfPlots = 6;
else
    numberOfPlots = 4;
    validationData = [];
end

% Check, if NaNs in the data
data = deleteNaNs(data);

% Select training algorithms
methods = {'lolimot','lolimotSparseQuad','lolimotQuad','hilomot','hilomotSparseQuad','hilomotQuad'};

% Initialize AllLMN cell
AllLMN = cell(1,length(methods));
lmnMethod = cell(1,length(methods));

parfor idxMethod = 1:length(methods)
    
    switch methods{idxMethod}
        case 'globalPolynom'
            LMN = globalPolynom;
        case 'lolimot'
            LMN = lolimot;
        case 'lolimotQuad'
            LMN = lolimot;
            LMN.xRegressorDegree = 2;
        case 'lolimotSparseQuad'
            LMN = lolimot;
            LMN.xRegressorDegree = 2;
            LMN.xRegressorType = 'sparsePolynomial';
        case 'hilomot'
            LMN = hilomot;
            LMN.reoptimizeNewKappa = false;
            LMN.demandedMembershipValue = 0.7;
        case 'hilomotQuad'
            LMN = hilomot;
            LMN.xRegressorDegree = 2;
            LMN.reoptimizeNewKappa = false;
            LMN.demandedMembershipValue = 0.7;
        case 'hilomotSparseQuad'
            LMN = hilomot;
            LMN.xRegressorDegree = 2;
            LMN.xRegressorType = 'sparsePolynomial';
            LMN.reoptimizeNewKappa = false;
            LMN.demandedMembershipValue = 0.7;
        otherwise
            error('LMNTrain:unknownMethod','Method "%s" is unknown.',methods{idxMethod})
    end
    LMN.LOOCV = true;
    
    LMN.outputWeighting = outputweighting;

    % Generate training data and store in hilomot object
    LMN.input  = data(:,inputIdx);
    LMN.output = data(:,outputIdx);
    
    % Add validation data if there are any
    if ~isempty(validationData)
        LMN.validationInput  = validationData(:,inputIdx);
        LMN.validationOutput = validationData(:,outputIdx);
        LMN.lossFunctionTermination = 'validationDataLossFunction';
    end
    
    % Add test data if there are any
    if ~isempty(testData)
        LMN.testInput  = testData(:,inputIdx);
        LMN.testOutput = testData(:,outputIdx);
    end
    
    % Maximal training time per algorithm in minutes
    LMN.maxTrainTime = inf;
    LMN.lossFunctionGlobal = 'NRMSE';
    LMN.smoothness = 1.25;
    LMN.history.displayMode = false;
    LMN.estimationProcedure = 'RIDGE';
    LMN.lambda = 1e-4;
    
    if debugMode
        LMN.maxNumberOfLM = 2;
    end
    
    % Display
    fprintf(['\nCurrent training method: ',methods{idxMethod},'\n'])
    
    % Perform training
    LMN = LMN.train;
    
    LMN.info.dataSetDescription = methods{idxMethod};
    
    % Storage LMN and methods name in variable
    lmnMethod{idxMethod} = methods{idxMethod};
    AllLMN{idxMethod} = LMN;
    
    % Clearing LMN
    % clear LMN
    
end

AllLMN = {lmnMethod{:};AllLMN{:}};

% Find LMN with best expected generalization performance, either based on
% the validation error or on the AICc
maxError = inf;
methodSelection = 1;
complexitySelection = [];
if exist('validationData','var') && ~isempty(validationData)
    
    % Use validation error to find best model
    for idxMethod = 1:length(methods) % loop over all methods
        LMN = AllLMN{2,idxMethod};
        if maxError > min(LMN.history.validationDataLossFunction)
            % if AIC error of current method is lower...
            [maxError, complexitySelection] = min(LMN.history.validationDataLossFunction);
            methodSelection = idxMethod;
        end
    end
else
    % Use AIC to find best model
    for idxMethod = 1:length(methods) % loop over all methods
        LMN = AllLMN{2,idxMethod};
        if maxError > LMN.history.penaltyLossFunction(LMN.suggestedNet)
            % if AIC error of current method is lower...
            maxError = LMN.history.penaltyLossFunction(LMN.suggestedNet);
            methodSelection = idxMethod;
            complexitySelection = LMN.suggestedNet;
        end
    end
end

% Choose best model as model to use
LMNBest = AllLMN{2,methodSelection};
LMNBest.outputModel = LMNBest.calculateModelOutput(LMNBest.unscaledInput);


% Display
fprintf(['\nSuggested model: ',methods{methodSelection},'\n'])



if makeFigure && (numberOfPlots==4) % plots without validation data
    % define fonzize
    schrift = 15;
    
    scrsz = get(0,'ScreenSize');
    hfig = figure;
    set(hfig,'Position',[scrsz(3)/4 scrsz(4)/2 0.9*min(scrsz(3:4)) 0.9*min(scrsz(3:4))],'name','LMN Toolbox')
    
    % plot convergence behavior of AIC error
    hPenPlot = subplot(2,2,1);
    plot_convergence_AIC(hPenPlot, AllLMN,methods, methodSelection, complexitySelection, schrift)
    
    % plot convergence behavior of training error
    hErrPlot = subplot(2,2,2);
    plot_convergence_training(hErrPlot, AllLMN,methods, methodSelection, complexitySelection, schrift)
    
    % plot histogramm
    hHistPlot = subplot(2,2,3);
    plot_histogramm(hHistPlot,LMNBest,schrift)
    
    % plot correlation of training and test data
    hCorrTrainPlot = subplot(2,2,4);
    plot_correlation_training_test(hCorrTrainPlot,LMNBest,schrift)    
end

if makeFigure && (numberOfPlots==6) % plots WITH validation data
    % define fonzize
    schrift = 15;
    
    scrsz = get(0,'ScreenSize');
    if 0.9*min(scrsz(3:4))*1.5 < scrsz(3) % 14.4:9 screen
        figHeight = 0.9*min(scrsz(3:4));
        figWidth = 0.9*1.5*min(scrsz(3:4));
    else
        figHeight = 0.9*0.75*min(scrsz(3:4));
        figWidth = 0.9*min(scrsz(3:4));
    end
    spaceLeft = (scrsz(3)-figWidth)/2;
    spaceBottom = (scrsz(4)-figHeight)/2;
    
    hfig = figure;
    set(hfig,'Position',[spaceLeft spaceBottom figWidth figHeight],'name','LMN Toolbox')
    
    % plot convergence behavior of AIC error
    hPenPlot = subplot(2,3,1);
    plot_convergence_AIC(hPenPlot, AllLMN,methods, methodSelection, complexitySelection, schrift)
    
    % plot convergence behavior of training error
    hErrPlot = subplot(2,3,2);
    plot_convergence_training(hErrPlot, AllLMN,methods, methodSelection, complexitySelection, schrift)
    
    % plot convergence behavior of validation error
    hValPlot = subplot(2,3,3);
    plot_convergence_validation(hValPlot, AllLMN,methods, methodSelection, complexitySelection, schrift)
    
    % plot histogramm
    hHistPlot = subplot(2,3,4);
    plot_histogramm(hHistPlot,LMNBest,schrift)
    
    % plot correlation of training and test data
    hCorrTrainPlot = subplot(2,3,5);
    plot_correlation_training_test(hCorrTrainPlot,LMNBest,schrift)
    
    % plot correlation of validation data
    hCorrValPlot = subplot(2,3,6);
    plot_correlation_validation(hCorrValPlot,LMNBest,schrift)
    
end
end


%% plot HISTOGRAMM
function plot_histogramm(hPlot,LMNBest,schrift)

% calculate difference between model output and data output
histError = LMNBest.unscaledOutput-LMNBest.outputModel;

if size(LMNBest.output,1)>30
    [Nhist, Xhist] = hist(histError,30);
    hist(histError,30)
else
    [Nhist, Xhist] = hist(histError);
    hist(histError)
end

% hpatch = findobj(gca,'Type','patch');
% 
% set(hpatch,'FaceColor','w','EdgeColor','k')

%annotation('rectangle',get(hPlot,'Position'),'EdgeColor','k');

title('error histogram for suggested model','fontsize',schrift,'fontName','Times New Roman')
axis(1.2*[-max(max(abs(Xhist))) max(max(abs(Xhist))) 0 max(max(Nhist))])
set(hPlot,'fontsize',schrift,'fontName','Times New Roman'); %ylabel('y','fontsize',schrift,'fontName','Times New Roman')
xlabel('training output - model output','fontsize',schrift,'fontName','Times New Roman'); %ylabel('u_2','fontsize',schrift,'fontName','Times New Roman')
if size(histError,2) > 1
    legendCell = cell(1,size(histError,2));
    for ii=1:size(histError,2)
        legendCell{ii} = LMNBest.info.outputDescription{ii};
    end
    legend(legendCell,'fontsize',schrift,'fontName','Times New Roman');
end

end


%% plot CORRELATION of TRAINING data and TEST data
function plot_correlation_training_test(hPlot,LMNBest,schrift)

hCorrPlot = [];
hCorrLegend = {};

minAx = min(min(min(LMNBest.unscaledOutput)),min(min(LMNBest.outputModel)));
maxAx = max(max(max(LMNBest.unscaledOutput)),max(max(LMNBest.outputModel)));


% plot y over yhat
for ii=1:size(LMNBest.unscaledOutput,2)
    hCorrPlot(end+1) = plot(LMNBest.unscaledOutput(:,ii),LMNBest.outputModel(:,ii),'k.','markersize',12);
    if ii==1
        hCorrLegend{end+1} = 'Training Data';
    end
    hold all
    
    % plot validation Data
    if ~isempty(LMNBest.validationInput) && ~isempty(LMNBest.validationOutput)
        validationOutputModel = LMNBest.calculateModelOutput(LMNBest.validationInput);
        hCorrPlot(end+1) = plot(LMNBest.validationOutput(:,ii),validationOutputModel(:,ii),'g.','markersize',12);
        if ii==1
            hCorrLegend{end+1} = 'Validation Data';
        end
    end
    
    % plot test data
    if ~isempty(LMNBest.testInput) && ~isempty(LMNBest.testOutput)
        testOutputModel = LMNBest.calculateModelOutput(LMNBest.testInput);
        hCorrPlot(end+1) = plot(LMNBest.testOutput(:,ii),testOutputModel(:,ii),'r.','markersize',12);
        if ii==1
            hCorrLegend{end+1} = 'Test Data';
        end
    end
end

legend(hCorrPlot,hCorrLegend,'Location','best')

% plot 45° line
line([minAx maxAx],[minAx maxAx],'color','k','LineStyle','--')

axis([minAx maxAx minAx maxAx])
title('correlation plot for suggested model','fontsize',schrift,'fontName','Times New Roman')
set(hPlot,'fontsize',schrift,'fontName','Times New Roman'); %zlabel('y','fontsize',schrift,'fontName','Times New Roman')
xlabel('data output','fontsize',schrift,'fontName','Times New Roman'); ylabel('model output','fontsize',schrift,'fontName','Times New Roman')

end


%% plot CORRELATION of VALIDATION data
function plot_correlation_validation(hPlot,LMNBest,schrift)

hCorrPlot = [];
hCorrLegend = {};

minAx = min(min(LMNBest.unscaledOutput(:)),min(LMNBest.outputModel(:)));
maxAx = max(max(LMNBest.unscaledOutput(:)),max(LMNBest.outputModel(:)));

% plot validation Data
validationOutputModel = LMNBest.calculateModelOutput(LMNBest.validationInput);
for ii=1:size(validationOutputModel,2)
    hCorrPlot(end+1) = plot(LMNBest.validationOutput(:,ii),validationOutputModel(:,ii),'.','markersize',12);
    if ii==1
        hold all;
    end
    hCorrLegend{end+1} = ['Validation output ',num2str(ii)];
end
hCorrLegend{end+1} = 'Validation Data';


legend(hCorrPlot,hCorrLegend,'Location','NorthWest')

% plot 45° line
line([minAx maxAx],[minAx maxAx],'color','k','LineStyle','--')

axis([minAx maxAx minAx maxAx])
title('correlation plot for suggested model','fontsize',schrift,'fontName','Times New Roman')
set(hPlot,'fontsize',schrift,'fontName','Times New Roman'); %zlabel('y','fontsize',schrift,'fontName','Times New Roman')
xlabel('data output','fontsize',schrift,'fontName','Times New Roman'); ylabel('model output','fontsize',schrift,'fontName','Times New Roman')

end


%% plot CONVERGENCE of AIC error
function plot_convergence_AIC(hPlot, AllLMN,methods, methodSelection, complexitySelection, schrift)

hAIC = [];

for idxMethod = 1:length(methods) % loop over all methods
    hAIC(end+1) = plot(AllLMN{2,idxMethod}.history.currentNumberOfParameters,...
        AllLMN{2,idxMethod}.history.penaltyLossFunction+eps,...
        '-','linewidth',2,'MarkerSize',15);
    hold all
end

legend(hAIC,methods)

plot(AllLMN{2,methodSelection}.history.currentNumberOfParameters(complexitySelection),...
    AllLMN{2,methodSelection}.history.penaltyLossFunction(complexitySelection)+eps,'x',...
    'linewidth',2,'markersize',12,'MarkerEdgeColor','k')

title(['penalty loss function - suggested model: \bf{',methods(methodSelection),'}'],'fontsize',schrift,'fontName','Times New Roman')
set(hPlot,'fontsize',schrift,'fontName','Times New Roman','YScale','linear')
ylabel('J(AIC_c)','fontsize',schrift,'fontName','Times New Roman')
xlabel('model complexity - no. of parameters','fontsize',schrift,'fontName','Times New Roman')



end

%% plot CONVERGENCE for VALIDATION error
function plot_convergence_validation(hPlot, AllLMN,methods, methodSelection, complexitySelection, schrift)

hErr = [];

for idxMethod = 1:length(methods) % loop over all methods
    hErr(end+1) = plot(AllLMN{2,idxMethod}.history.currentNumberOfParameters,...
        AllLMN{2,idxMethod}.history.validationDataLossFunction+eps,...
        '-','linewidth',2,'MarkerSize',15);
    hold all
end

% Highlight LMN with best penalty error value and set figure style
% options

legend(hErr,methods)

plot(AllLMN{2,methodSelection}.history.currentNumberOfParameters(complexitySelection),...
    AllLMN{2,methodSelection}.history.validationDataLossFunction(complexitySelection)+eps,'x',...
    'linewidth',2,'markersize',12,'MarkerEdgeColor','k')

set(hPlot,'fontsize',schrift,'fontName','Times New Roman','YScale','linear')
title('validation error','fontsize',schrift,'fontName','Times New Roman')
ylabel(num2str(AllLMN{2,methodSelection}.lossFunctionGlobal),'fontsize',schrift,'fontName','Times New Roman')
xlabel('model complexity - no. of parameters','fontsize',schrift,'fontName','Times New Roman')

end


%% plot CONVERGENCE of TRAINING error
function plot_convergence_training(hPlot, AllLMN,methods, methodSelection, complexitySelection, schrift)

hErr = [];

for idxMethod = 1:length(methods) % loop over all methods
    hErr(end+1) = plot(AllLMN{2,idxMethod}.history.currentNumberOfParameters,...
        AllLMN{2,idxMethod}.history.globalLossFunction+eps,...
        '-','linewidth',2,'MarkerSize',15);
    hold all
end

% Highlight LMN with best penalty error value and set figure style
% options

legend(hErr,methods)

plot(AllLMN{2,methodSelection}.history.currentNumberOfParameters(complexitySelection),...
    AllLMN{2,methodSelection}.history.globalLossFunction(complexitySelection)+eps,'x',...
    'linewidth',2,'markersize',12,'MarkerEdgeColor','k')

set(hPlot,'fontsize',schrift,'fontName','Times New Roman','YScale','linear')
title('training error','fontsize',schrift,'fontName','Times New Roman')
ylabel(num2str(AllLMN{2,methodSelection}.lossFunctionGlobal),'fontsize',schrift,'fontName','Times New Roman')
xlabel('model complexity - no. of parameters','fontsize',schrift,'fontName','Times New Roman')

end


%% Delete NaN rows in data set
function [dataClean, numberOfDeletedRows] = deleteNaNs(data,NaNCols)

dataClean = data;
if ~exist('NaNCols','var') || isempty(NaNCols)
    idxNaN    = isnan(dataClean);
    NaNCols   = find(sum(idxNaN,1)~=0);
end
for k = NaNCols
    idxNotNaN = ~isnan(dataClean(:,k));
    dataClean = dataClean(idxNotNaN,:);
end
numberOfDeletedRows = size(data,1)-size(dataClean,1);
end
