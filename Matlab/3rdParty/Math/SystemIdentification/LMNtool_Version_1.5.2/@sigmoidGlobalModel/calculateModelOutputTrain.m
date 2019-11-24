function [outputModel,phiAll,psiAll,xRegressor,zRegressor] = calculateModelOutputTrain(obj,localModels,validity,leafModels,weightedOutputWorstLM,xRegressorLocal)
%% CALCULATEMODELOUTPUTTRAIN Simulates or predicts, respectively, the output of the model on the traininig data.
%
%       [outputModel, validity] = calculateModelOutputTrain(obj,localModels,validity,leafModels,xRegressorLocal1,xRegressorLocal2))
%
%   calculateModelOutput outputs:
%       outputModel - (N x q)   Matrix of model outputs
%       phiAll      - (N x M)   Simulated validity of all local models.
%       psiAll      - (N x M)   Simulated splitting function value for each local model.
%       xRegressor  - (N x nx)  Simulated x-regressor.
%       zRegressor  - (N x nz)  Simulated z-Regressor.
%
%   calculateModelOutput inputs:
%       obj                     - (object)  LMN object
%       localModels             - (? x 1)   Cell array, containing the new local models.
%       validity                - (N x ?)   Validity function value of the new local models.
%       leafModels              - (M x 1)   Logical array, defining the leaf models.
%       weightedOutputWorstLM   - (N x q)   The old output model without the influence of the worst local model.
%       xRegressorLocal         - (N x nx)  The x-regressor of the local model. Only necessary, if the local model are centered.
%
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fischer, 17-September-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

if nargin < 3
    error('sigmoidGlobalModel:calculateModelOutputTrain','Not enough input variables: During training the new local models and their validity are necessary!')
end

% Procedure explanation:
%
% Due to the hierarchical model structure, it is possible to substract the
% weighted output of the worstLM from the overall model output in order to
% add the weighted local model outputs that result from splitting the worst
% LM. This approach accelerates the split optimization. The influence of
% the worst local model is removed before the new split is tested.
%
% outputModel    = sum_i( phi_i*yHat_i ) + phi_worstLM*yHat_worstLM
% outputModelNew = sum_i( phi_i*yHat_i ) + phi_newLM1*yHat_newLM1   + phi_newLM2*yHat_newLM2
%
% Difference:
% outputModelNew - outputModel = { phi_newLM1*yHat_newLM1 + phi_newLM2*yHat_newLM2 } - phi_worstLM*yHat_worstLM
%
%                                                        ||                                       ||
% This leads to:
% outputModelNew - outputModel =                 weightedOutputNewLM                 -   weightedOutputWorstLM

if obj.kStepPrediction <= 1  %|| ...
        %(all(cellfun(@isempty, obj.xOutputDelay)) && all(cellfun(@isempty, obj.zOutputDelay)))
    % Static model or dynamic model with one-step-ahead prediction
    
    if nargin > 4
        % Get some constant
        numberOfNewLocalModels = numel(localModels);
        
        % initialize Variable
        weightedOutputNewLM = zeros(size(weightedOutputWorstLM));
        
        %calculate the output
        if obj.useCenteredLocalModels
            if nargin > 5
%                 % get the local model parameter from the obj into cell arrays
%                 if numel(obj.localModels) == 0
%                     localParameter = {};
%                 else
%                     localParameter = {obj.localModels(leafModels(1:end-numberOfNewLocalModels)).parameter};
%                 end
%                 localParameter = [localParameter, {localModels(1:numberOfNewLocalModels).parameter}];
                
                % Use the given x regressors to calculate the model output of the new generated models
                for LM = 1:numberOfNewLocalModels
                    weightedOutputNewLM = weightedOutputNewLM + obj.calcYhat(xRegressorLocal{LM},validity(:,LM),{localModels(LM).parameter});
                end
            else
                error('globalMode:calculateModelOutputTrain','For centered local models, the two x regressors of the new generated local models must be passed.')
            end
        else
            % Use the global x regressors stored in the model object to calculate the model output of the two new generated models
            for LM = 1:numberOfNewLocalModels
                weightedOutputNewLM = weightedOutputNewLM + obj.calcYhat(obj.xRegressor,validity(:,LM),{localModels(LM).parameter});
            end
        end
        
        % Update model output
        outputModel = weightedOutputWorstLM + weightedOutputNewLM;
        
        % No calculation of all phi and psi is necessary (only for simulation)
        phiAll = [];
        psiAll = [];
        xRegressor = [];
        zRegressor = [];
    else
        % First local model is calculated
        error('sigmoidGlobalModel:calculateModelOutputTrain','During training of a static model output without the current worst local model must be passed!')
    end
    
else % Dynamic model parallel simulation
    
    if nargin < 4
        error('sigmoidGlobalModel:calculateModelOutputTrain','Not enough input variables: During training of a simulated dynamic model the leaf models are necessary!')
    end

    if obj.useCenteredLocalModels
        error('sigmoisGlobalModel:calculateModelOutputTrain','A simulation with centered local models is redundant and therefore not supported.')
    else
        % Combine the existing models with the two new generated
        localModels = [obj.localModels localModels];
        
        % Simulate parallel
        [outputModel,~,phiAll,psiAll,xRegressor,zRegressor]  = obj.simulateParallel(obj.input,obj.output,localModels,leafModels);
    end
    
end

end


