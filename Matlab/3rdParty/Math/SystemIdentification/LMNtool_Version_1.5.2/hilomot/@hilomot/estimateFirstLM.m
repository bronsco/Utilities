function [obj] = estimateFirstLM(obj)
%% ESTIMATEFIRSTLM initializes the training. The first local=global model is estimated with LS.
%
%       [obj] = ESTIMATEFIRSTLM(obj)
%
%
%   ESTIMATEFIRSTLM inputs:
%
%       obj - (object) LMN object containing all relevant properties and methods
%
%
%   See also LMSplit, LMSplitOpt.
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Benjamin Hartmann, 15-January-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles


% % % Define some variables
% % zLowerBound         = min(obj.zRegressor);
% % zUpperBound         = max(obj.zRegressor);
% % center              = (zLowerBound+zUpperBound)/2;
weightedOutputWorstLM = zeros(size(obj.output));

% Calcualate center coordinate
center = mean(obj.zRegressor,1);

% Initialize the local model object
localModels = sigmoidLocalModel([], [], center, [], [],size(obj.xRegressor,2));

% update the active model vector
leafModels = true; % the first active model

% Calculate validity function values (Here: all equal to 1)
phi = ones(size(obj.zRegressor,1),1); 

% Check for sufficient amount of data samples
if sum(phi) - obj.pointsPerLMFactor * localModels.accurateNumberOfLMParameters >= eps
    obj.idxAllowedLM = true;
else
    obj.idxAllowedLM = false;
    error('hilomot:estimateFirstModel','The first local model has not enough valid point to estimate its parameters properly.')
end

% Estimate parameters of the first LM and calculate the model output
if obj.useCenteredLocalModels
    % Calculate the shifted local inputs and the local x-regressors
    xRegressorLocal = {data2xRegressor(obj,obj.input,obj.output,center)};
    localModels.parameter = estimateParametersLocal(obj, xRegressorLocal{1}, obj.output, phi, [], obj.dataWeighting);
else
    xRegressorLocal = [];
    localModels.parameter = estimateParametersLocal(obj, obj.xRegressor, obj.output, phi, [], obj.dataWeighting);
end

% Calculate the output model
[outputModel,phiAll,psiAll] = calculateModelOutputTrain(obj,localModels,phi,leafModels,weightedOutputWorstLM,xRegressorLocal);


% Evaluate loss function values
localModels.localLossFunctionValue = calcLocalLossFunction(obj, obj.output, outputModel, phi);

% Update the model object
obj.leafModels = leafModels;
obj.localModels = [obj.localModels localModels];
obj.outputModel = outputModel;
obj.phi = phi;

% Check for sufficient amount of data samples for further splits
if sum(phi) - 2*obj.pointsPerLMFactor * size(obj.xRegressor,2) >= eps
    obj.idxAllowedLM = true;
else
    obj.idxAllowedLM = false;
    warning('hilomot:estimateFirstModel','The first local model has not enough valid point to be splitted properly during the training.')
end

end