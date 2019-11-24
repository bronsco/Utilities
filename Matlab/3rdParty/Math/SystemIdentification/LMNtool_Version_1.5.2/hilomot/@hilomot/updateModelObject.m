function obj = updateModelObject(obj, leafModels, localModels, phiNew, outputModel, phiSimulated)
%  UPDATEMODELOBJECT update the global model object, considering the best
%  solution for the current iteration.
%
%
%   [obj] = LMSplitEstimate(obj, worstLM, splitDimension, splitRatio)
%
%
%   LMSplitEstimate output:
%       obj            - (object)   LOLIMOT object containing all relevant net
%                                   and data set information and variables.
%
%   LMSplitEstimate inputs:
%       obj            - (object)   LOLIMOT object containing all relevant net
%                                   and data set information and variables.
%       worstLM        - (1 x 1)    Index of the worst performing LLM which is
%                                   splitted.
%       splitDimension - (1 x 1)    Splitting dimension.
%       splitRatio     - (1 x 1)    Splitting ratio.
%
%
%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 08-December-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% Update active models and allocation of gaussian
obj.leafModels = leafModels;

% Update the allowed LM
obj.idxAllowedLM = [obj.idxAllowedLM true(1,2)];

% Update net history
obj.history.splitLM = [obj.history.splitLM; localModels(1).parent];

% Calculate model output
obj.outputModel = outputModel;

% Update the MSFValues and calculate the validities
obj.phi = [obj.phi, phiNew];

% Update information about the latest children
obj.localModels(localModels(1).parent).children = length(obj.localModels)+1:length(obj.localModels)+2;
% Update the local model structure
obj.localModels = [obj.localModels, localModels];

if ~isinf(obj.kStepPrediction)
    
    % Calculate the local loss function values for the last two leaf models
    localLossFunctionValue = calcLocalLossFunction(obj, obj.output, obj.outputModel , phiNew);
    
    for k = 1:numel(localModels)
        % Allocate the right local loss function value to each local model
        obj.localModels(length(obj.localModels)-2+k).localLossFunctionValue = localLossFunctionValue(k);
    end
    
else
    % As we use the simulated output for the global loss function, we must
    % use the simulated validity to assign the local loss function!
    
    % calculate the validity of all leaf models (Simulation)
    % phiSimulated = obj.calculateValidity(zRegressor,leafModels);
    
    % Calculate the local loss function values for all leaf models
    localLossFunctionValue = calcLocalLossFunction(obj, obj.output, obj.outputModel , phiSimulated);
    
    trueLeafIdx = find(leafModels);
    for k = 1:numel(trueLeafIdx)
        % Allocate the right local loss function value to each local model
        obj.localModels(trueLeafIdx(k)).localLossFunctionValue = localLossFunctionValue(k);    
    end
    
end

% Check for sufficient amount of data samples for potentional further splits
if  sum(phiNew(:,1)) - 2*obj.pointsPerLMFactor * size(obj.xRegressor,2) < eps
    obj.idxAllowedLM(end-1) = false;
end
if sum(phiNew(:,2)) - 2*obj.pointsPerLMFactor * size(obj.xRegressor,2) < eps
    obj.idxAllowedLM(end) = false;
end

end