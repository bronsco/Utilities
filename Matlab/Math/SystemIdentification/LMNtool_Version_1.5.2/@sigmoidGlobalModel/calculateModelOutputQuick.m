function [outputModel, grad] = calculateModelOutputQuick(obj,input,output)
%% CALCULATEMODELOUTPUTQUICK Simulates the output of the model given an input sequence.
% This fast implementation is prefereable if only one query to calculate is
% given.
%
%
%       [outputModel, grad] = calculateModelOutputQuick(obj,input,output)
%
%
%   calculateModelOutputQuick output:
%       outputModel - (1 x q) Matrix of model outputs.
%       grad        - (1 x p) Gradient of the model output
%
%
%   calculateModelOutputQuick inputs:
%       obj         - (obj)   LMN class-object.
%       input       - (1 x p) Data matrix containing physical inputs
%       output      - (1 x q) (optional) Data matrix containing physical
%                             outputs. These are only needed for dynamic
%                             systems.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 14-March-2014
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

if isempty(obj.localModels)
   error('hilomot:calculateModelOutputQuick','Local Models are empty, please train the model first!') 
end

if size(input,1) > 1
    error('hilomot:calculateModelOutputQuick','This function should only be used to calculate the output for one data sample.')
end

% Input must be scaled
input = obj.scaleData(input,obj.scaleParaInput);

if exist('output','var')
    % if output is given
    output = obj.scaleData(output,obj.scaleParaOutput);
else
    % if input is given, but no output
    output = [];
end


%% Create regressors
if obj.useCenteredLocalModels == false
    % if uncentered local models are used, we must calculate the
    % xRegressor only once
    xRegressor = obj.data2xRegressor(input,output);
else
    xRegressor = [];
end
zRegressor = obj.data2zRegressor(input,output);

numberOfOutputs = obj.info.numberOfOutputs;
%% Simulate the model
if obj.kStepPrediction <= 1 % Static model or dynamic model with one-step-ahead prediction
    
    numberOfLeafs = length(obj.leafModels);
    % get the partition parameters from the local models
    splittingPara = [obj.localModels(1:numberOfLeafs).splittingParameter];
    kappa = [obj.localModels(1:numberOfLeafs).kappa];
    smoothness = obj.smoothness;
    parent = [obj.localModels(1:numberOfLeafs).parent];
    
    % Get the index of the non root local models
    idxNonRoot = find(cell2mat(arrayfun(@(x) ~isempty(obj.localModels(x).splittingParameter), 1:numberOfLeafs, 'UniformOutput', false)));
    
    % get the local model parameters of the polynomials
    localParameter = [obj.localModels(obj.leafModels).parameter];
    if numberOfOutputs > 1
        parameter_Part = [];
        for k = 1:numberOfOutputs
            parameter_Part{k} = localParameter(:,k:numberOfOutputs:end);
        end
    end
    
    % Initialize psi
    psi = ones(size(zRegressor,1),numberOfLeafs);
    
    if isempty(splittingPara) && numel(parent) == 0 % no parents; only roots are given.
        validity = psi;
    else
        % calculate validity per sigmoidal (no line approximation of the sigmoidal is provided, should be added!)
        psi(idxNonRoot) = [1./(1+exp( ...
            (kappa./smoothness) .* (zRegressor*splittingPara(1:end-1,:) + splittingPara(end,:))...
            ))];
        
        validity = psi;
        
        for childIdx = 1:length(idxNonRoot)
            % multiply with parent validity if necessary to calculate phi
            % only the 4th and beyond need to multiplied with their parent
            % to compute the final validity value
            validity(idxNonRoot(childIdx)) = validity(idxNonRoot(childIdx)) .* validity(parent(childIdx));
        end
    end
    
    if nargout>1
        phi = validity(obj.leafModels);
    end
    
    
    
    if obj.useCenteredLocalModels == false
        
        if numberOfOutputs == 1
            % calculation with only ONE output
            outputModel = sum(validity(obj.leafModels).*(xRegressor * localParameter),2);
        else
            % calculation with several outputs
            temp = cellfun(@(parai) xRegressor*parai, parameter_Part,'UniformOutput', false);
            outputModel = cellfun(@(tempi) sum(validity(obj.leafModels).*tempi,2), temp);
        end
        
    else
        
        idxLM = find(obj.leafModels);
        outputModel = zeros(1, numberOfOutputs);
        for h = 1:numel(idxLM)
            % Calculate the shifted local inputs and the local x-regressors
            if isempty(output)
                xRegressorLocal = data2xRegressor(obj,input,[],obj.localModels(idxLM(h)).center);
            else
                xRegressorLocal = data2xRegressor(obj,input,output,obj.localModels(idxLM(h)).center);
            end
            if numberOfOutputs == 1
                % calculation with only ONE output
                try outputModelLocal = sum(validity(idxLM(h)).*(xRegressorLocal * localParameter(:,h)),2);catch; keyboard;end
            else
                % calculation with several outputs
                temp = cellfun(@(parai) xRegressorLocal*parai, parameter_Part,'UniformOutput', false);
                outputModelLocal = cellfun(@(tempi) sum(validity(idxLM(h)).*tempi,2), temp);
            end
            outputModel = outputModel + outputModelLocal;
        end
        
    end
    
    
else % Dynamic model parallel simulation
    
    outputModel = obj.simulateParallel(xRegressor,zRegressor,obj.localModels,obj.leafModels,output);
    
end

%% Always unscale output
outputModel = obj.unscaleData(outputModel,obj.scaleParaOutput);


%% Calculate the gradient
if nargout == 2
    warninng('globalModel:calculateModelOutput','Scaling is always active! The gradient must be unscaled to fit to the output data!')
    grad = obj.calculateModelOutputQuickGradient(input, output, xRegressor, localParameter, validity, psi);
end


end


