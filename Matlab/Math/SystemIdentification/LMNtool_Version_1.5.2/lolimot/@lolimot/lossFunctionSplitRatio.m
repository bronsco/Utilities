function [globalLossFunctionValue,localModels,leafModels,MSFValueNew,outputModel,validitySimulated,forbiddenSplit] = lossFunctionSplitRatio(obj, worstLM, splitDimension, splitRatio,flagPlot)

% Set flag and abort values
forbiddenSplit = false;

if nargin < 5 || (exist('flagPlot','var') && ~islogical(flagPlot))
    flagPlot = false;
end

%% 1) Perform split
[lowerLeftCorner1, upperRightCorner1, lowerLeftCorner2, upperRightCorner2]  = ...
    obj.LMSplit(obj.localModels(worstLM).lowerLeftCorner, obj.localModels(worstLM).upperRightCorner, splitDimension, splitRatio);

% Evaluate centers and standard deviations for the new local models and generate two new local model objects
localModels = [gaussianOrthoLocalModel(lowerLeftCorner1,upperRightCorner1,obj.smoothness,size(obj.xRegressor,2)) gaussianOrthoLocalModel(lowerLeftCorner2,upperRightCorner2,obj.smoothness,size(obj.xRegressor,2))];

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
% Calculate the membership function values of the newly generated local models
MSFValueNew = arrayfun(@(loc) loc.calculateMSF(obj.zRegressor),localModels,'UniformOutput',false);
% Now use membership function values of the leaf models to to calculate their validity.
validity = obj.calculateVFV([obj.MSFValue MSFValueNew],leafModels);

% Check for sufficient amount of data samples
if  sum(validity(:,end-1)) - obj.pointsPerLMFactor * localModels(1).accurateNumberOfLMParameters < eps
    forbiddenSplit = true;
end
if sum(validity(:,end)) - obj.pointsPerLMFactor * localModels(2).accurateNumberOfLMParameters < eps
    forbiddenSplit = true;
end

%% 3) Estimate parameters of the LM
if obj.useCenteredLocalModels
    xRegressorLocal{1} = data2xRegressor(obj,obj.input,obj.output,localModels(1).center);
    xRegressorLocal{2} = data2xRegressor(obj,obj.input,obj.output,localModels(2).center);
    localModels(1).parameter = estimateParametersLocal(obj,xRegressorLocal{1}, obj.output, validity(:,end-1), [], obj.dataWeighting);
    localModels(2).parameter = estimateParametersLocal(obj,xRegressorLocal{2}, obj.output, validity(:,end), [], obj.dataWeighting);

else
    xRegressorLocal = [];
    localModels(1).parameter = estimateParametersLocal(obj,obj.xRegressor, obj.output, validity(:,end-1), [], obj.dataWeighting);
    localModels(2).parameter = estimateParametersLocal(obj,obj.xRegressor, obj.output, validity(:,end), [], obj.dataWeighting);
end

%% 6) Calculate the global model output
[outputModel, validitySimulated] = calculateModelOutputTrain(obj,localModels,validity,leafModels,xRegressorLocal);

%% 5) Calculate the global loss function value
globalLossFunctionValue = calcGlobalLossFunction(obj, obj.output, outputModel);

if flagPlot
    figure(99)
    hold on
    plot(splitRatio,globalLossFunctionValue,'ko','MarkerSize',12)
    hold off
end

end