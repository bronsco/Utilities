function [outputModel, validity, grad] = calculateModelOutput(obj,input,output)
%% CALCULATEMODELOUTPUT Simulates or predicts, respectively, the output of the model on new data.
%
%       [outputModel, validity] = calculateModelOutput(obj,input,output)
%
%   calculateModelOutput outputs:
%       outputModel - (N x q) Matrix of model outputs
%       validity    - (N x M) Validity function matrix of leaf models
%       grad        - (N x p) Gradient of the model
%
%   calculateModelOutput inputs:
%       obj     - (object) LMN object
%       input   - (N x p)  Data matrix containing physical inputs
%       output  - (N x q)  (optional) Data matrix containing physical outputs. Only needed
%                          for dynamic systems.
%
%   SYMBOLS AND ABBREVIATIONS
%
%       LM:  Local model
%
%       p:   Number of inputs (physical inputs)
%       q:   Number of outputs
%       N:   Number of data samples
%       M:   Number of LMs
%       nx:  Number of regressors (x)
%       nz:  Number of regressors (z)
%
%   See also globalModel, calcYhat, plotLossFunction, plotModel, plotPartition,
%            plotCorrelation, plotModelCentered.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 24-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles
%
%   Update 19-September-2013 (TF) : Only use after training. Input must be given.

% Check if input is given
if nargin < 2
    error('globalModel:calculateModelOutput','At least the variable <input> must be given.')
end

% Leaf models mst be given
if isempty(obj.leafModels)
    error('globalModel:calculateModelOutput','The property <leafModels> is empty. This usually means, that you forgot to save your trained network.')
end

% Check if given inputs match the dimensions of the delays
if length(obj.xInputDelay) ~= size(input,2)
    error('globalModel:calculateModelOutput','The dimension of the input does not match xInputDelay')
elseif length(obj.zInputDelay) ~= size(input,2)
    error('globalModel:calculateModelOutput','The dimension of the input does not match zInputDelay')
end

% Check if an output delay is given, and therfore an output must be delivered
if ~isempty([obj.xOutputDelay{:}]) % Output delay for the x-regressor
    % Check if the output is given
    if nargin<3
        error('globalModel:calculateModelOutput','The output is missing as an input argument.')
    % Check for a dimension mismatch    
    elseif (length(obj.xOutputDelay) ~= size(output,2))
        error('globalModel:calculateModelOutput','The dimension of the output does not match xOutputDelay.')
    end  
elseif ~isempty([obj.zOutputDelay{:}]) && obj.kStepPrediction == 1 % Output delay for the z-regressor
    if nargin<3
        error('globalModel:calculateModelOutput','The output is missing as an input argument.')
    elseif (length(obj.zOutputDelay) ~= size(output,2))
        error('globalModel:calculateModelOutput','The dimension of the output does not match zOutputDelay.')
    end
end

% If input should be scaled
input = obj.scaleData(input,obj.scaleParaInput);

% Check if output is given
if exist('output','var')
    output = obj.scaleData(output,obj.scaleParaOutput);
else % If input is given, but no output
    output = [];
end

% if ~obj.useCenteredLocalModels
%     % if uncentered local models are used, we must calculate the
%     % xRegressor only once
%     xRegressor = obj.data2xRegressor(input,output);
% end

% Check the model structure
if obj.kStepPrediction <= 1 || ...
        (all(cellfun(@isempty, obj.xOutputDelay)) && all(cellfun(@isempty, obj.zOutputDelay)))
    % Static model or dynamic model with one-step-ahead prediction
    
    % Calculate the z-regressor for the given input and output
    zRegressor = obj.data2zRegressor(input,output);
    
    % If there is a new input, calculate its validity
    [validity,~] = calculateValidity(obj,zRegressor,obj.leafModels);
    
    % Get the local model parameter from each local model obj into cell arrays
    localParameter = {obj.localModels(obj.leafModels).parameter};
    
    % Calculate the output
    if obj.useCenteredLocalModels
        
        % initialize the output model
        outputModel = zeros(size(input,1),size(obj.output,2));
        
        idxLM = find(obj.leafModels);
        for k = 1:sum(obj.leafModels)
            % Calculate the shifted local inputs and the local x-regressors for each local model
            xRegressorLocal = data2xRegressor(obj,input,output,obj.localModels(idxLM(k)).center);
            outputModelLocal = obj.calcYhat(xRegressorLocal,validity(:,k),localParameter(k));
            outputModel = outputModel + outputModelLocal;
        end
    else
        % Uncentered local models are used: calculate the x-regressor only once
        xRegressor = obj.data2xRegressor(input,output);
        outputModel = obj.calcYhat(xRegressor,validity,localParameter);
    end
    
else % Dynamic model parallel simulation
    if obj.useCenteredLocalModels
        error('globelModel:calculateModelOutput','A simulation with centered local models is redundant and therefore not supported.')
    else
        [outputModel, validity] = obj.simulateParallel(input,output,obj.localModels,obj.leafModels);
    end
    
end

%% Always unscale output
outputModel = obj.unscaleData(outputModel,obj.scaleParaOutput);

%% calculate the gradient if necessary
if nargout ==3
    warninng('globalModel:calculateModelOutput','Scaling is always active! The gradient must be unscaled to fit to the output data!')
    if obj.useCenteredLocalModels
        idxLM = find(obj.leafModels);
    else
        % Calculate the derivative of the xRegressor
        derivative = obj.data2xRegressorDerivative(input,output);
    end
    
    % Calculate the gradient of each local model
    gradcell = cell(1, sum(obj.leafModels));
    for k = 1:sum(obj.leafModels)
        if obj.useCenteredLocalModels
            derivative = obj.data2xRegressorDerivative(input,output,obj.localModels(idxLM(k)).center);
        end
        gradcell{k} = cell2mat(cellfun(@(dXdu) dXdu*localParameter{k}(2:end,:), derivative, 'UniformOutput',false));
    end
    
    % Multiplay with the validity of each model
    gradcell = cellfun(@(grad, val) bsxfun(@times, grad, val), gradcell, ...
        mat2cell(validity, size(validity,1), ones(1,size(validity,2))), ...
        'UniformOutput',false);
    
    % Sum of all local weighted gradients
    grad = sum(cat(3,gradcell{:}),3);
end

end


