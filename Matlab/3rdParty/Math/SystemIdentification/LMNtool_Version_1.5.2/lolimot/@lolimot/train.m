function obj = train(obj)
% TRAIN trains a local model network with the LOLIMOT algorithm.
%
% TRAIN is the central training algorithm. It calls all the other for the
% construction of the LOLIMOT object required functions and
% administrates the LOLIMOT object. It is also responsible for
% stopping the training with respect to the no-go criteria and delivering
% the finished net object.
%
%
% obj = train(obj,displayMode)
%
%
% INPUT/OUTPUT:
%   obj:          object    LOLIMOT object containing all relevant net
%                           and data set information and variables.
%
%
% Local Model Toolbox, Version 1.0
% Torsten Fischer, 08-Dec-2011
% Institute of Measurement and Control, University of Siegen, Germany
% Copyright (c) 2011 by Torsten Fischer

% Get the starting time for abording algorithm
time = tic;

% initialize training
obj = initializeTraining(obj);

% Estimate first net
if isempty(obj.localModels) % Estimate a global linear model
    obj = estimateFirstLM(obj); % One linear model
else % Estimate a nonlinear model based on the given structure
    obj = estimateGivenModel(obj); % Model based on structure
end

% Initialize the index vector of the allowed local model in each iteration
obj.idxAllowedLMIter = obj.idxAllowedLM;

% Make history entries
obj.history = writeHistory(obj.history,obj,time);

% Display loss function value for the first net
if obj.history.displayMode
    fprintf('\nInitial net has %d local linear model(s): J = %f.\n', ...
        numel(obj.localModels), obj.history.globalLossFunction(obj.history.iteration));
end

% Make sure that at least some splits (depending on the 
% maxValidationDeterioration property) are made even if the first split 
% does not result in an improvement of the global loss function
iniGlobalLossFunction = obj.history.globalLossFunction(1);
obj.history.globalLossFunction(1) = inf;

% Tree construction algorithm
while obj.checkTerminationCriterions % Go on training until one termination criterion is reached
    
    while any(obj.idxAllowedLM & obj.leafModels & obj.idxAllowedLMIter) % While-loop over all allowed local models
        
        % Initialize the best global loss function value
        globalLossFunctionBest = obj.history.globalLossFunction(end);
        
        % Initialize the flag, if a permitted split is found
        flagPermittedSplitFound = false;
        
        % Initialize the flag, if one split leads to an improvement of the training error
        flagBetterSplitFound = false;
        
        % Find worst performing LM
        worstLM = findWorstLM(obj);
        
        % Check for split of worst performing LLM
        if obj.history.displayMode
            fprintf('\n\n%d. Iteration. Number of local linear models = %d. Checking for split of model %d ...', ...
                obj.history.iteration, sum(obj.leafModels), worstLM);
        end
        
        for splitDimension = 1:size(obj.zRegressor,2) % Over all dimensions of the z-regressor
            
            % Split in halves
            splitRatio = 0.5;
            
            % calculate the global loss function of the current model structure
            [globalLossFunctionSplit,localModels,leafModels,MSFValueNew,outputModel, validitySimulated, forbiddenSplit] = obj.lossFunctionSplitRatio(worstLM, splitDimension, splitRatio);
            
            % If the split is forbidden, try the next dimension or split ratio
            if forbiddenSplit
                if obj.history.displayMode
                    fprintf('\n   Split in dimension %d with ratio %4.2f is forbidden!', ...
                        splitDimension, splitRatio);
                end
                continue % Continue with the next split
            else
                flagPermittedSplitFound = true;
            end
            
            if obj.history.displayMode
                fprintf('\n   Testing split in dimension %d with ratio %4.2f: J = %f.', ...
                    splitDimension, splitRatio, globalLossFunctionSplit);
            end
            
            % If better than the currently best alternative, save the calculated variables
            if globalLossFunctionBest - globalLossFunctionSplit > eps
                splitDimensionBest = splitDimension;
                splitRatioBest = splitRatio;
                globalLossFunctionBest = globalLossFunctionSplit;
                localModelsBest = localModels;
                leafModelsBest = leafModels;
                MSFValueNewBest = MSFValueNew;
                outputModelBest = outputModel;
                validitySimulatedBest = validitySimulated;
                flagBetterSplitFound = true;
            end
        end
        
        % Check if a permitted split of the current worstLM can be done
        if flagBetterSplitFound
            % Break while-loop; no other local models need to be tested
            break
        elseif flagPermittedSplitFound && ~flagBetterSplitFound
            % At least one permitted split is found, but no improvement of the training error was achieved
            % Lock the current worstLM for this iteration and go on investigating another local model and lock the worstLM
            %             keyboard
            obj.idxAllowedLMIter(worstLM) = false;
            if obj.history.displayMode
                fprintf('\n\n%d. Iteration. Split of the %d . Model achieves no improvement. Try another model...', ...
                    obj.history.iteration, worstLM);
            end
        else
            % No permitted split found; go one investigating another local
            % model and lock the worstLM finally
            %             keyboard
            obj.idxAllowedLM(worstLM) = false;
            if obj.history.displayMode
                fprintf('\n\n%d. Iteration. Model %d can not be splitted. Try another model...', ...
                    obj.history.iteration, worstLM);
            end
        end
    end
    
    % Update model object, if a better split is found
    if flagBetterSplitFound
        
        % Perform best split (update model structure)
        obj = updateModelObject(obj, leafModelsBest, splitDimensionBest, splitRatioBest, localModelsBest, MSFValueNewBest, outputModelBest, validitySimulatedBest, worstLM);
        
        % Reset the logical index vector for each iteration to idxAllowedLM
        obj.idxAllowedLMIter = obj.idxAllowedLM;
        
        % Make history entries
        obj.history = writeHistory(obj.history,obj,time);
        
        if obj.history.displayMode
            fprintf('\n-> Splitting in dimension %d with ratio %4.2f: J = %f and penalty = %f.', ...
                obj.history.splitDimension(obj.history.iteration-1), obj.history.splitRatio(obj.history.iteration-1), ...
                obj.history.globalLossFunction(obj.history.iteration),obj.history.penaltyLossFunction(obj.history.iteration));
        end
    end
end

% Restore global loss function of global model
obj.history.globalLossFunction(1) = iniGlobalLossFunction;

% Final display
if obj.history.displayMode
    fprintf('\n\nFinal net has %d local models and %d parameters: J = %f', ...
        sum(obj.leafModels), round(obj.history.currentNumberOfParameters(end)), obj.history.globalLossFunction(end));
    fprintf('\n\nNet %d with %d LMs and %d parameters is suggested as the model with the best complexity trade-off.\n', ...
        obj.suggestedNet, sum(obj.history.leafModelIter{obj.suggestedNet}), round(obj.history.currentNumberOfParameters(obj.suggestedNet)));
end

% Update model output with suggested model complexity.
obj.leafModels = obj.history.leafModelIter{obj.suggestedNet};
obj.idxAllowedLM = obj.idxAllowedLM(1:length(obj.leafModels));
obj.idxAllowedLMIter = obj.idxAllowedLM;

end