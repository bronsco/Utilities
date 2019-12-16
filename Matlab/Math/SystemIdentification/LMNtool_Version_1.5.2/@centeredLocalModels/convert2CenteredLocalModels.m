function [obj, validity] = convert2CenteredLocalModels(obj)
% converts a model with UNCENTERED local model to a model with CENTERED
% local models

% mark the object as one which uses centered local models
obj.useCenteredLocalModels = true;

% clear the estimated output
obj.outputModel = [];

% Reset the global xRegressor, its no longer usefull
obj.xRegressor = [];

% get the relations between rule premises and consequents
obj.relationZtoX = calculateRelationZtoX(obj);

% Check for a missmatch in the global model structure
if numel(obj.localModels) > numel(obj.leafModels) % more local model objects than leaf models
    warning('centeredLocalModels:convert2CenteredLocalModels','The number of local models is larger than the number of leaf models. Erase the oversupplied local models.')
    obj.localModels(numel(obj.leafModels)+1:numel(obj.localModels)) = [];
elseif numel(obj.localModels) < numel(obj.leafModels) % less local models object than leaf models
    error('centeredLocalModels:convert2CenteredLocalModels','The number of local models is lesser than the number of leaf models. Abort calculation!')
end

% Get some constant
numberOfLocalModels = length(obj.localModels);

if numberOfLocalModels>0
    % if there are already some existing local models, convert them
    if obj.history.displayMode
        fprintf('\n\n Convert given local model network with %d local models into centered lcoal models by using the estimation procedure <%s>. \n\n', ...
            numberOfLocalModels,obj.estimationProcedure);
    end
    
    
    %% calculate the validity for each local model
    
    % check which kind of validity calculation is necessary
    if any(strcmp(superclasses(obj),'sigmoidGlobalModel'))
        
        % calculate the validity of all local models
        validity = obj.calculateValidity(obj.zRegressor,1:numberOfLocalModels);
        
    elseif any(strcmp(superclasses(obj),'gaussianOrthoGlobalModel'))
        
        validity = zeros(size(obj.zRegressor,1),numberOfLocalModels);
        leafModels = obj.leafModels;
        for k = 1:obj.history.iteration
            % get the leaf models
            obj.leafModels = obj.history.leafModelIter{k};
            validity(:,obj.leafModels) = obj.calculateValidity(obj.zRegressor, obj.leafModels, obj.MSFValue);
        end
        obj.leafModels = leafModels;
    end
    
    %% Loop over all local models and recalculate the new local parameters
    xRegressorLocal = cell(1,length(obj.localModels));
    for k = 1:length(obj.localModels)
        
        % get local xRegressor
        xRegressorLocal{k} = data2xRegressor(obj,obj.input,obj.output,obj.localModels(k).center);
        
        
        % Check if the number of regressors to select are higher than the number of possible regressors    
        regressorsToSelect = min([size(obj.xRegressorExponentMatrix,1)+1, round(obj.localModels(k).accurateNumberOfLMParameters)]);
   
        % Recalculate local parameters
        obj.localModels(k).parameter = estimateParametersLocal(obj, xRegressorLocal{k}, obj.output,validity(:,k), regressorsToSelect, obj.dataWeighting);
        
        % Reset the local loss functino value
        obj.localModels(k).localLossFunctionValue = [];
        
    end
    
    %% Use only the leaf models to calculate the model output
    if any(strcmp(superclasses(obj),'sigmoidGlobalModel'))
        obj.outputModel = calculateModelOutputTrain(obj,obj.localModels(obj.leafModels),validity(:,obj.leafModels),obj.leafModels,zeros(size(obj.output)),xRegressorLocal(obj.leafModels));
        
    elseif any(strcmp(superclasses(obj),'gaussianOrthoGlobalModel'))
        obj.outputModel = calculateModelOutputTrain(obj,obj.localModels(obj.leafModels),validity(:,obj.leafModels),leafModels,xRegressorLocal(obj.leafModels));
    end
    
    %% Evaluate new loss function values and update structure
    idxLeafModels = find(obj.leafModels);
    localLossFunctionValue = calcLocalLossFunction(obj, obj.output, obj.outputModel , validity(:,obj.leafModels));
    for k = 1:numel(idxLeafModels)
        obj.localModels(idxLeafModels(k)).localLossFunctionValue = localLossFunctionValue(k);
    end
    
    % No new iteration is done, decrease the number of iteration by one
    obj.history.iteration = obj.history.iteration - 1;
    
    % Reset the history, corresponding the right iteration
    obj.history = writeHistory(obj.history,obj);
    
end





end