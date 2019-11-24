function [outputModel, validitySimulated] = calculateModelOutputTrain(obj,localModels,validity,leafModels,xRegressorLocal)
%% CALCULATEMODELOUTPUTTRAIN Simulates or predicts, respectively, the output of the model on the traininig data.
%
%       [outputModel, validity] = calculateModelOutputTrain(obj,localModels,validity,leafModels,xRegressorLocal1,xRegressorLocal2))
%
%   calculateModelOutput outputs:
%       outputModel - (N x q) Matrix of model outputs
%
%   calculateModelOutput inputs:
%       obj     - (object) LMN object
%
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fsicher, 03-July-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% Static model or dynamic model with one-step-ahead prediction
if obj.kStepPrediction <= 1 || ...
        (all(cellfun(@isempty, obj.xOutputDelay)) && all(cellfun(@isempty, obj.zOutputDelay)))
    
    % Get some constant
    numberOfNewLocalModels = numel(localModels);
    
    % Get the local model parameter from the obj into cell arrays
    if numel(obj.localModels) == 0 % no local model object is given
        localParameter = [];
    elseif numel(localModels) == nnz(leafModels) % only new generated local models must be considered (first split,retrain or switch to centered local models)
        localParameter = [];
    elseif numel(obj.localModels)< numel(leafModels)
        localParameter = {obj.localModels(obj.leafModels & leafModels(1:end-numberOfNewLocalModels)).parameter};
    end
    localParameter = [localParameter, {localModels(1:numberOfNewLocalModels).parameter}];
    
    %calculate the output
    if obj.useCenteredLocalModels
        if nargin > 4
            outputModel = zeros(size(obj.input,1),size(obj.output,2));
            idxLM = find(leafModels);
            
            % Claculate the new local x-regressors of the leaf models, without the new ones
            for k = 1:numel(idxLM)-numberOfNewLocalModels
                % Calculate the shifted local inputs and the local x-regressors
                xRegressor = data2xRegressor(obj,obj.input,obj.output,obj.localModels(idxLM(k)).center);
                % add the local model output to the global model
                outputModel = outputModel + obj.calcYhat(xRegressor,validity(:,k),localParameter(k));
            end
            % Calculate and add the local model output of the new generated local models
            for k = 1:numberOfNewLocalModels
                outputModel = outputModel + obj.calcYhat(xRegressorLocal{k},validity(:,end-numberOfNewLocalModels+k),localParameter(end-numberOfNewLocalModels+k));
            end
        else
            error('globalMode:calculateModelOutputTrain','For centered local models, the two x regressors of the new generated local models must be passed.')
        end
    else
        outputModel = obj.calcYhat(obj.xRegressor,validity,localParameter);
    end
    
    if obj.kStepPrediction > 1
        validitySimulated = validity;
    else
        % No calculation of all phi and psi is necessary (only for simulation)
        validitySimulated = [];
    end
    
else % Dynamic model parallel simulation
    
    if obj.useCenteredLocalModels == false
        
        % combine the existing models with the two new generated
        localModels = [obj.localModels localModels];
        
        % Simulate parallel
        [outputModel, validitySimulated] = obj.simulateParallel(obj.input,obj.output,localModels,leafModels);
    else
        error('globalModel:calculateModelOutputTrain','A simulation with centered local models is redundant are therefore not supported.')
    end
    
end

end


