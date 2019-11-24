function result = checkTerminationCriterions(obj)
%% CHECKTERMINATIONCRITERION checks the history and the termination
% criterions if the training should be aborted.
%
%   result is TRUE if training should be proceeded
%   result is FALSE if training should be aborted
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 24-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

if ~exist('obj','var')
    error('modelHistory:checkTerminationCriterions',...
        'This is a static function. You have to hand over the local model network object')
end

if any(strcmp('displayMode', properties(obj.history)))
    displayMode = obj.history.displayMode;
else
    displayMode = true;
end


% Default: training should not be aborted
result = true;


% Test termination criterions for break. A combinations of if-conditions
% are used for readability
if (sum(obj.leafModels) >= obj.maxNumberOfLM)
    
    % If there are enough local models
    result = false;
    
    if displayMode; fprintf('\n\nMaximum number of local models reached.\n'); end
    return
    
elseif obj.history.globalLossFunction(end) < obj.minError
    
    % If the minimal error falls below the specified error
    result = false;
    
    if displayMode; fprintf('\n\nError limit reached.\n'); end
    return
    
elseif obj.history.currentNumberOfParameters(end) > obj.maxNumberOfParameters
    
    % If the current number of parameters is greater than the maximal number of parameters
    result = false;
    
    if displayMode; fprintf('\n\nMaximum number of parameters reached.\n'); end
    return
    
elseif obj.history.trainingTime(end) > obj.maxTrainTime*60
    
    % If a maximal training time is reached
    result = false;
    
    if displayMode; fprintf('\n\nMaximum Training time reached.\n'); end
    return
    
elseif obj.history.iteration > obj.maxIterations
    
    % If a maximal training time is reached
    result = false;
    
    if displayMode; fprintf('\n\nMaximum number of iterations reached.\n'); end
    return
    
elseif any(strcmp('idxAllowedLM', properties(obj))) &&...
        any(strcmp('idxAllowedLMIter', properties(obj))) &&...
        ~any(obj.idxAllowedLM & obj.idxAllowedLMIter & obj.leafModels)
    
    % If there is no leaf model left allowed to be split
    result = false;
    
    if displayMode; fprintf('\n\nAll leaf models are locked. No further splitting possible. Training accomplished.\n'); end
    return
    
elseif any(strcmp('idxAllowedLM', properties(obj))) ...
        && all(~strcmp('idxAllowedLMIter', properties(obj))) % --> idxAllowedLMIter is no property of obj
    
    keyboard
end

% Test model complexity
%     historyDepth = obj.maxPenaltyDeterioration;

% Search index of the best model complexity
[~, idxMin] = min(obj.history.terminationLossFunction);

% Find the iteration with the lowest error and those which are nearly as good as the best one
errorDiff = abs(obj.history.terminationLossFunction - obj.history.terminationLossFunction(idxMin)) <= obj.minPerformanceImprovement;

% We pick the first one. This ensures the stopping of the training algorithm if there is only insignificant performance improvement.
bestIdx = find(errorDiff,1);

if (length(obj.history.terminationLossFunction) - bestIdx) >= obj.maxValidationDeterioration
    result = false;
    if displayMode;
        if ~isempty(obj.history.simulationLossFunctionValidationData)
            fprintf('\n\nEstimated model complexity limit reached. The improvement of \nthe loss function (%s) was %d times less than \n%d on VALIDATION data.\n',obj.lossFunctionTermination, obj.maxValidationDeterioration, obj.minPerformanceImprovement);
        else
            fprintf('\n\nEstimated model complexity limit reached. The improvement of \nthe loss function (%s) was %d times less than \n%d on TRAINING data.\n',obj.lossFunctionTermination, obj.maxValidationDeterioration, obj.minPerformanceImprovement);
        end
    end
end

%     if length(obj.history.penaltyLossFunction)>historyDepth
%         errorDiff = zeros(1,historyDepth);
%         for idxPrevious = 1:historyDepth
%             errorDiff(idxPrevious) = obj.history.penaltyLossFunction(end+1-idxPrevious) - obj.history.penaltyLossFunction(end-idxPrevious);
%         end
%         if all(errorDiff>-obj.minPerformanceImprovement) || any(abs(errorDiff)>abs(100*mean(obj.history.penaltyLossFunction)))
%             result = false;
%             if displayMode; fprintf('\n\nEstimated model complexity limit reached. Penalty loss function (AICc) increased %d times.\n',historyDepth); end
%         end
%     end

end




