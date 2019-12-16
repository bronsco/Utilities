function [obj] = estimateFirstLM(obj)
%% ESTIMATEFIRSTLM calculates a global model to initialize the LOLIMOT
% object. This is nessassary, because the splitting procedure needs a model
% and its validity area to operate.
%
%
%       [obj] = estimateFirstLM(obj)
%
%
%   estimateGivenModel input/output:
%       obj - (object) LOLIMOT object containing all relevant net and data set
%                      information and variables.
%
%
%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 08-December-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% Define some variables
zLowerBound = min(obj.zRegressor);
zUpperBound = max(obj.zRegressor);

% Corners of the first local model are identical to the boundaries of the z regressor space
lowerLeftCorner = zLowerBound;
upperRightCorner = zUpperBound;

% Initialize the local model object and calculating its gaussian
localModels = gaussianOrthoLocalModel(lowerLeftCorner,upperRightCorner,obj.smoothness,size(obj.xRegressor,2));

% First leaf model
leafModels = true;

% Add boundaries to the local model object
localModels.zLowerBound = zLowerBound;
localModels.zUpperBound = zUpperBound;

% Validities of the leaf local models (Here: all equal to 1)
MSFValue = {localModels.calculateMSF(obj.zRegressor)};
validity = ones(size(MSFValue{1}));

% Check for sufficient amount of data samples

if sum(validity) - obj.pointsPerLMFactor * localModels.accurateNumberOfLMParameters >= eps
    obj.idxAllowedLM = true;
else
    obj.idxAllowedLM = false;
    error('lolimot:estimateFirstModel','The first local model has not enough valid point to estimate its parameters properly.')
end

% Estimate parameters of the first LM
if obj.useCenteredLocalModels
    % Calculate the shifted local inputs and the local x-regressors
    xRegressorLocal = {data2xRegressor(obj,obj.input,obj.output,localModels.center)};
    localModels.parameter = estimateParametersLocal(obj, xRegressorLocal{1}, obj.output, validity, [], obj.dataWeighting);
else    
    xRegressorLocal = [];
    localModels.parameter = estimateParametersLocal(obj, obj.xRegressor, obj.output, validity, [], obj.dataWeighting);
end

% Calculate model output
outputModel = calculateModelOutputTrain(obj,localModels,validity,leafModels,xRegressorLocal);

% Calculate the local loss function value for one leaf models
localModels.localLossFunctionValue = calcLocalLossFunction(obj, obj.output, outputModel , validity);

% Update the model object
obj.leafModels = leafModels;
obj.localModels = [obj.localModels localModels];
obj.MSFValue = MSFValue;
obj.outputModel = outputModel;

% Check for sufficient amount of data samples for further splits
if sum(validity) - 2*obj.pointsPerLMFactor * localModels.accurateNumberOfLMParameters >= eps
    obj.idxAllowedLM = true;
else
    obj.idxAllowedLM = false;
    warning('lolimot:estimateFirstModel','The first local model has not enough valid point to be splitted properly during the training.')
end

end