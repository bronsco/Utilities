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

% Check if the properties of the local model objects are given correctly
if numel(obj.localModels) ~= numel(obj.leafModels)
    error('hilomot:estimateGivenModel','Number of active models is not equal to the number of local model objects!')
end

% Indicies of the leaf models
idxLeafModels = find(obj.leafModels);

for k = 1:numel(obj.localModels)
    
    % Check if parents are given correctly
    if k>1 && ( isempty(obj.localModels(k).parent) || ~(0<obj.localModels(k).parent<=numel(obj.localModels)-2))
        error('hilomot:estimateGivenModel','No parent given!')
    end
    
    % Check if the centers are given correctly
    if isempty(obj.localModels(k).center)
        error('hilomot:estimateGivenModel','No proper center or splitting parameters given!')
    end
    
    % Check if the boudaries are known by the object
    if k>1 && isempty(obj.localModels(k).splittingParameter)
        error('hilomot:estimateGivenModel','No proper splitting parameters given!')
    end
    
    % Check the children for all non leaf models
    if ~ismember(k,idxLeafModels) && isempty(obj.localModels(k).children)
        error('hilomot:estimateGivenModel','No children given!')
    end
end

% Initialize the allowed local model if necessary
if isempty(obj.idxAllowedLM)
    obj.idxAllowedLM = true(size(obj.leafModels));
end

% Validities of all leaf local models
[validity] = calculateValidity(obj,obj.zRegressor,1:numel(obj.localModels),obj.phi);

% copy validity into the global model object
obj.phi = validity;

xRegressorLocal = {[]};

for k = 1:numel(idxLeafModels)
    
    % Check for sufficient amount of data samples
    if obj.idxAllowedLM(idxLeafModels(k))
        if sum(validity(:,idxLeafModels(k))) - obj.pointsPerLMFactor * obj.localModels(idxLeafModels(k)).accurateNumberOfLMParameters < eps
            obj.idxAllowedLM(idxLeafModels(k)) = false;
            error('hilomot:estimateGivenModel',['Local model No. ' num2str(idxLeafModels(k)) 'of the given model structure has not enough valid point to estimate the parameters of the local model properly.'])
        elseif sum(validity(:,idxLeafModels(k))) - 2 * obj.pointsPerLMFactor * obj.localModels(idxLeafModels(k)).accurateNumberOfLMParameters < eps
            obj.idxAllowedLM(idxLeafModels(k)) = false;
            warning('hilomot:estimateGivenModel',['Local model No. ' num2str(idxLeafModels(k)) 'of the given model structure has not enough valid point to be splitted properly during the training.'])
        end
    end
    
    % Parameters of all leaf local models
    if obj.useCenteredLocalModels
        % Calculate the local system of the current leaf model
        xRegressorLocal{k} = data2xRegressor(obj,obj.input,obj.output,obj.localModels(idxLeafModels(k)).center);
        obj.localModels(idxLeafModels(k)).parameter = estimateParametersLocal(obj, xRegressorLocal{k}, obj.output, validity(:,idxLeafModels(k)), [], obj.dataWeighting);
    else
        xRegressorLocal = [];
        obj.localModels(idxLeafModels(k)).parameter = estimateParametersLocal(obj, obj.xRegressor, obj.output, validity(:,idxLeafModels(k)), [], obj.dataWeighting);
    end
    
end

% Calculate model output
% obj.outputModel = calculateModelOutput(obj);
obj.outputModel = calculateModelOutputTrain(obj,obj.localModels(idxLeafModels),validity(:,idxLeafModels),obj.leafModels,zeros(size(obj.output)),xRegressorLocal);

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