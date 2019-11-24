function obj = recalcLocalModelParametersAfterTraining(obj)

% validity = calculateVFV(obj,obj.MSFValue,obj.leafModels);

validity = calculateValidity(obj,obj.zRegressor,obj.leafModels);

idxLeafModels = find(obj.leafModels);

for k = 1:size(validity,2)
    parameterCurrent = estimateParametersLocal(obj,obj.xRegressor, obj.output, validity(:,k), obj.localModels(idxLeafModels(k)).accurateNumberOfLMParameters, obj.dataWeighting);
    obj.localModels(idxLeafModels(k)).parameter = parameterCurrent;
end
% [outputModel, validitySimulated] = calculateModelOutputTrain(obj,localModels,validity,leafModels);

% [outputModel, validityNew] = calculateModelOutput(obj,obj.input,obj.output);



