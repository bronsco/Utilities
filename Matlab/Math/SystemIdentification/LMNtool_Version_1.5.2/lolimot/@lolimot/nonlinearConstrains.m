function [nonLinIneqCons,nonLinEqCons,gradNonLinIneqCons,gradNonLinEqCons] = nonlinearConstrains(obj, worstLM, splitDimension, splitRatio)


%% 1) Perform split
[lowerLeftCorner1, upperRightCorner1, lowerLeftCorner2, upperRightCorner2]  = ...
    obj.LMSplit(obj.localModels(worstLM).lowerLeftCorner, obj.localModels(worstLM).upperRightCorner, splitDimension, splitRatio);

% Evaluate centers and standard deviations for the new local models and generate two new local model objects
localModels = [gaussianOrthoLocalModel(lowerLeftCorner1,upperRightCorner1,obj.smoothness) gaussianOrthoLocalModel(lowerLeftCorner2,upperRightCorner2,obj.smoothness)];

% Add the training boundaries of the z-regression
localModels(1).zUpperBound = obj.localModels(worstLM).zUpperBound;
localModels(1).zLowerBound = obj.localModels(worstLM).zLowerBound;
localModels(2).zUpperBound = obj.localModels(worstLM).zUpperBound;
localModels(2).zLowerBound = obj.localModels(worstLM).zLowerBound;

% Set worst local model on false and update indicies of the leaf models
leafModels = obj.leafModels;
leafModels(worstLM) = false;
leafModels = [leafModels true(1,2)];

%% 2) Calculate the validity values for all leaf models
[validity, ~] = obj.calculateVFV(localModels,leafModels);

%% 3) Calculate the nonlinear inequality constraints
nonLinIneqCons = bsxfun(@minus,obj.pointsPerLMFactor * size(obj.xRegressor,2),sum(validity(:,end-1:end),1))';

% The other nonliear constraints and their gradients are not defined
nonLinEqCons = [];
gradNonLinIneqCons = [];
gradNonLinEqCons = [];