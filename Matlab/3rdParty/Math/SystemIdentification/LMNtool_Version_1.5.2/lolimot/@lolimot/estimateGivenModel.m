function [obj] = estimateGivenModel(obj)
% ESTIMATEGIVENMODEL estimates a local neuro-fuzzy model to a given net
% sturcture. The function allows to refine an already trained LOLIMOT
% object. If the user realizes, that his net is not good enough, the
% algorithmn can continue processing without stating all over again.
%
%       [obj] = estimateGivenModel(obj)
%
%   estimateGivenModel input/output:
%       obj - (object) LOLIMOT object containing all relevant net and data set
%                      information and variables.
%
%
%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 05-February-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% error('lolimot:estimateGivenModel','New lolimot approach needs to be implemented!')

% Check if the properties of the local model objects are given correctly
if numel(obj.localModels) ~= numel(obj.leafModels)
    warning('lolimot:estimateGivenModel','Number of active models is not equal to the number of local model objects!')
end

for k = 1:numel(obj.localModels)
    
    % Check if corners are given correctly
    if (isempty(obj.localModels(k).lowerLeftCorner) || isempty(obj.localModels(k).upperRightCorner) || ...
            (numel(obj.localModels(k).upperRightCorner)~=size(obj.zRegressor,2)) || (numel(obj.localModels(k).lowerLeftCorner)~=size(obj.zRegressor,2)))
        error('lolimot:estimateGivenModel','no corner given for at least one hyper-rectangle! training aborted!')
    end
    
    % Check if the gaussians are given or have to be calculated
    if isempty(obj.localModels(k).center) || isempty(obj.localModels(k).standardDeviation)
        % Calculate the centers and standard deviation from corner positions and smoothness
        [obj.localModels(k).center,obj.localModels(k).standardDeviation] = ...
            obj.localModels.corner2Center(obj.localModels(k).lowerLeftCorner,obj.localModels(k).upperRightCorner,obj.smoothness);
    end
    
    % Check if the boudaries are known by the object
    if isempty(obj.localModels(k).zLowerBound) || isempty(obj.localModels(k).zUpperBound)
        % Add boundaries to each local model
        obj.localModels(k).zLowerBound = min(obj.zRegressor);
        obj.localModels(k).zUpperBound = max(obj.zRegressor);
    end
end

% Initialize the allowed local model
obj.idxAllowedLM = true(size(obj.leafModels));

% Validities of all leaf local models
[validity,obj.MSFValue] = obj.calculateValidity(obj.zRegressor,obj.leafModels,obj.MSFValue);

% Indicies of the leaf models
idxLeafModels = find(obj.leafModels);

xRegressorLocal = cell(1,numel(idxLeafModels));

for k = 1:numel(idxLeafModels)
    
    % Check for sufficient amount of data samples
    if sum(validity(:,k)) - obj.pointsPerLMFactor * size(obj.xRegressor,2) < eps
        obj.idxAllowedLM(k) = false;
        error('lolimot:estimateGivenModel',['Local model No. ' num2str(idxLeafModels(k)) 'of the given model structure has not enough valid point to estimate the parameters of the local model properly.'])
    elseif sum(validity(:,k)) - 2 * obj.pointsPerLMFactor * size(obj.xRegressor,2) < eps
        obj.idxAllowedLM(k) = false;
        warning('lolimot:estimateGivenModel',['Local model No. ' num2str(idxLeafModels(k)) 'of the given model structure has not enough valid point to be splitted properly during the training.'])
    end
    
    % Parameters of all leaf local models
    if obj.useCenteredLocalModels
        % Calculate the local system of the current leaf model
        xRegressorLocal{k} = data2xRegressor(obj,obj.input,obj.output,obj.localModels(idxLeafModels(k)).center);
        obj.localModels(idxLeafModels(k)).parameter = estimateParametersLocal(obj, xRegressorLocal{k}, obj.output, validity(:,k), [], obj.dataWeighting);
    else
        obj.localModels(idxLeafModels(k)).parameter = estimateParametersLocal(obj, obj.xRegressor, obj.output, validity(:,k), [], obj.dataWeighting);
    end
    
end

% Calculate model output
obj.outputModel = calculateModelOutputTrain(obj,obj.localModels(obj.leafModels),validity,obj.leafModels,xRegressorLocal);

% Calculate the local loss function values for all leaf models
localLossFunctionValue = calcLocalLossFunction(obj, obj.output, obj.outputModel , validity);
for k = 1:numel(idxLeafModels)
    % Allocate the right local loss function value to each local model
    obj.localModels(idxLeafModels(k)).localLossFunctionValue = localLossFunctionValue(k);
end

% Set number of iteration
if obj.history.iteration > 0
    obj.history.iteration = obj.history.iteration - 1;
end

end