function obj = updateModelObject(obj, leafModels, splitDimension, splitRatio, localModels, MSFValueNew, outputModel, validitySimulatedBest, worstLM)
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
%   Torsten Fischer, 15-July-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% Update active models and allocation of gaussian
obj.leafModels = leafModels;

% Update the allowed LM
obj.idxAllowedLM = [obj.idxAllowedLM true(1,numel(localModels))];

% Update net history
obj.history.splitLM = [obj.history.splitLM; worstLM];
obj.history.splitDimension = [obj.history.splitDimension; splitDimension];
obj.history.splitRatio = [obj.history.splitRatio; splitRatio];

% Update the local model structure
obj.localModels = [obj.localModels, localModels];

% Update the MSFValues and calculate the validities
obj.MSFValue = [obj.MSFValue, MSFValueNew];

% Calculate the NARX values
sumMSFValue = sum(cell2mat(obj.MSFValue(obj.leafModels)),2); % Calculate sum
% Normalize and superpose all active gaussians
validity = cell2mat(cellfun(@(MSFOneCell) sum(bsxfun(@rdivide,MSFOneCell,sumMSFValue),2),obj.MSFValue(obj.leafModels),'UniformOutput',false));

% Indicies of the active models
idxLeafModels = find(obj.leafModels);

% Calculate model output
obj.outputModel = outputModel;

% Calculate the local loss function values for all leaf models
if isinf(obj.kStepPrediction)
    localLossFunctionValue = calcLocalLossFunction(obj, obj.output, obj.outputModel, validitySimulatedBest);
else
    localLossFunctionValue = calcLocalLossFunction(obj, obj.output, obj.outputModel, validity);
end

for k = 1:numel(idxLeafModels)
    % Allocate the right local loss function value to each local model
    obj.localModels(idxLeafModels(k)).localLossFunctionValue = localLossFunctionValue(k);
end

% Check for sufficient amount of data samples for potentional further splits
for k=1:numel(localModels)
    if  sum(validity(:,end-numel(localModels)+k)) - 2 * obj.pointsPerLMFactor * localModels(k).accurateNumberOfLMParameters  < eps
        obj.idxAllowedLM(end-1) = false;
    end
end

end