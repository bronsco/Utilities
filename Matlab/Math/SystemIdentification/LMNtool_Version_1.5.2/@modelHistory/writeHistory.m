function history = writeHistory(history,LMobj,tStart)
%% WRITEHISTORY updates a given history obj. Usually it is called after
% each iteration to write all necessary data into the history.
%
%   history = writeHistory(history,LMobj,tStart)
%
%
%   OUTPUTS:
%
%       history:                (object)    History object containing all
%                                           the relevant data per iteration.
%
%   INPUTS:
%
%       history:                (object)    History object containing all
%                                           the relevant data per iteration.
%       LMObj:                  (object)    Global model object of the
%                                           current iteration.
%       tStart:                 (1 x 1)     Scalar defining the starting
%                                           time of the training.
%
%
%   ATTENTION:  <history> is the history object! LMobj is the local model network!
%               Call the function WRITEHISTORY like this for the global model object:
%               obj.history = writeHistory(obj.history,obj,tStart);
%
%
% LMNtool - Local Model Network Toolbox
% Tobias Ebert, 24-April-2012
% Institute of Mechanics & Automatic Control, University of Siegen, Germany
% Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% increase iteration by one
iter = history.iteration+1;

% initialise iteration number
history.iteration = iter;

if nargin==3
    % a trainiong start time is given
    history.trainingStartTic = tStart;
end


%% set global loss function

%if numel(history.globalLossFunction) < iter
if any(strcmp('outputModel', properties(LMobj)))
    % check if model output needs to be calculated
    outputModel = LMobj.outputModel;
else
    error('modelHistory:writeHistory','To update the history object a output model must be given!')
end

% Store the training error
history.globalLossFunction(iter) = ...
    calcGlobalLossFunction(LMobj, LMobj.output, outputModel);

% Calculate unscaled output data
outputModelUnscaled = LMobj.unscaleData(outputModel,LMobj.scaleParaOutput);
% Calculate global loss function for unscaled output
history.globalLossFunctionUnscaled(iter) = ...
    calcGlobalLossFunction(LMobj, LMobj.unscaledOutput, outputModelUnscaled);


%end



%% set validation Data loss function
if ~isempty(LMobj.validationInput) &&  ~isempty(LMobj.validationOutput)
    
    validationOutputModel = LMobj.calculateModelOutput(LMobj.validationInput,LMobj.validationOutput);
    
    history.validationDataLossFunction(iter) = calcGlobalLossFunction(...
        LMobj, LMobj.validationOutput, validationOutputModel);
    
    %     if ~isempty(LMobj.scaleOutput)
    %         % calculate unscaled output data
    %         validationOutputModelUnscaled = LMobj.scaleOutput.unscale(validationOutputModel);
    %         % calculate validation Data loss function for unscaled output
    %         history.validationDataLossFunctionUnscaled(iter) = calcGlobalLossFunction(...
    %             LMobj, LMobj.unscaledValidationOutput, validationOutputModelUnscaled,[], LMobj.outputWeighting);
    %     end
end

%% set test Data loss function
if ~isempty(LMobj.testInput) &&  ~isempty(LMobj.testOutput)
    
    testOutputModel = LMobj.calculateModelOutput(LMobj.testInput,LMobj.testOutput);
    
    history.testDataLossFunction(iter) = calcGlobalLossFunction(...
        LMobj, LMobj.testOutput, testOutputModel);
    
    %     if ~isempty(LMobj.scaleOutput)
    %         % calculate unscaled output data
    %         testOutputModelUnscaled = LMobj.scaleOutput.unscale(testOutputModel);
    %         % calculate test Data loss function for unscaled output
    %         history.testDataLossFunctionUnscaled(iter) = calcGlobalLossFunction(...
    %             LMobj, LMobj.unscaledTestOutput, testOutputModelUnscaled, [], LMobj.outputWeighting);
    %     end
end

% penalty loss function and current number of parameters
[normalizedAICc, normalizedBICc, numberOfAllParameters, CVScore, nEff, AICc, BICc] = LMobj.calcPenaltyLossFunction;

history.penaltyLossFunction(iter) = normalizedAICc;
history.normalizedBICc(iter) = normalizedBICc;
history.AICc{iter} = AICc;
history.BICc{iter} = BICc;
history.currentNumberOfParameters(iter) = numberOfAllParameters;
if ~isempty(CVScore)
    history.CVLossFunction{iter} = CVScore;
end
if ~isempty(nEff)
    history.currentNumberOfEffParameters(iter) = nEff;
end

% store error of simulated output for dynamic systems if necessary
if LMobj.kStepPrediction > 0
    %any([LMobj.xInputDelay{:}]>0) || any([LMobj.zInputDelay{:}]>0) || any([LMobj.xOutputDelay{:}]>0) || any([LMobj.zOutputDelay{:}]>0)
    
    if ~isinf(LMobj.kStepPrediction)
        %history.simulationLossFunction(iter) = history.globalLossFunction(iter);
        %else
        
        % ensure simulation of the output
        LMobj.kStepPrediction = inf;
        % calculate the simulated output
        simulatedOutput = LMobj.calculateModelOutput(LMobj.unscaledInput,LMobj.unscaledOutput);
        % calculate the global lossfunction with the simulated output
        history.simulationLossFunction(iter) = calcGlobalLossFunction(...
            LMobj, LMobj.unscaledOutput, simulatedOutput);
        
        if ~isempty(LMobj.validationInput) &&  ~isempty(LMobj.validationOutput)
            validationOutputModelSimulated = LMobj.calculateModelOutput(LMobj.validationInput,LMobj.validationOutput);
            history.simulationLossFunctionValidationData(iter) = calcGlobalLossFunction(...
                LMobj, LMobj.validationOutput, validationOutputModelSimulated);
        end
        
        if ~isempty(LMobj.testInput) &&  ~isempty(LMobj.testOutput)
            testOutputModelSimulated = LMobj.calculateModelOutput(LMobj.testInput,LMobj.testOutput);
            history.simulationLossFunctionTestData(iter) = calcGlobalLossFunction(...
                LMobj, LMobj.testOutput, testOutputModelSimulated);
        end
        
    else
        % simulation errror is already calculated in the global loss
        % function
        if ~isempty(history.validationDataLossFunction)
            history.simulationLossFunctionValidationData(iter) = history.validationDataLossFunction(iter);
        else
            history.simulationLossFunction(iter) = history.globalLossFunctionUnscaled(iter);
        end
    end
    
end

% Store the correct termination criterion as termination loss function
switch LMobj.lossFunctionTermination
    case {'penaltyLossFunction', 'normalizedAICc'}
        history.terminationLossFunction(iter) = history.penaltyLossFunction(iter);
    case 'normalizedBICc'
        history.terminationLossFunction(iter) = history.normalizedBICc(iter);
    case 'validationDataLossFunction'
        history.terminationLossFunction(iter) = history.validationDataLossFunction(iter);
    case 'AICc'
        history.terminationLossFunction(iter) = history.AICc{iter} *LMobj.outputWeighting;
    case 'CVScore'
        history.terminationLossFunction(iter) = history.CVLossFunction{iter} * LMobj.outputWeighting;
    case 'simulationError'
        if ~isempty(history.simulationLossFunctionValidationData)
            history.terminationLossFunction(iter) = history.simulationLossFunctionValidationData(iter);
        else
            history.terminationLossFunction(iter) = history.simulationLossFunction(iter);
        end
    otherwise
        fprintf('\n\n Accepted termination loss functions are:')
        fprintf('\n penaltyLossFunction')
        fprintf('\n normalizedBICc')
        fprintf('\n validationDataLossFunction')
        fprintf('\n AICc')
        fprintf('\n CVScore')
        fprintf('\n simulationError (for 1-step prediction dynamic Systems)')
        fprintf('\n\n')
        error('Please use an accepted terminationLossFunctionType')
end

% Store current number of LMs in history
history.currentNumberOfLMs(iter) = sum(LMobj.leafModels);

% Store current accurate number of parameters in history
if any(strcmp('accurateNumberOfLMParameters', properties(LMobj)))
    history.currentAccurateNumberOfParameters(iter) = sum(LMobj.accurateNumberOfLMParameters(LMobj.leafModels));
else
    % If the obj class has no such property, store the current number of parameters
    history.currentAccurateNumberOfParameters(iter) = history.currentNumberOfParameters(iter);
end

% set state of leaf models in history
history.leafModelIter{iter} = LMobj.leafModels;
history.idxAllowedLMIter{iter} =  LMobj.idxAllowedLM;

% set training time
if ~isempty(history.trainingStartTic)
    history.trainingTime(iter) = toc(history.trainingStartTic);
else
    history.trainingTime(iter) = NaN;
end

end