function [validity,MSFValueOut] = calculateValidity(obj,zRegressor,idx,MSFValueIn)
%% CALCULATEValidity calculates the validity function values of the leaf models of the local model object.
%
%
%   First all not given membership funciton are calculated. Storing the membership function of the current structure reduces the computational
%   effort a lot during the training. Than the membership functions of the leaf models are normalized. It is possible to hand a cell array
%   or a matrix over. If the MSFValues are given as cells {1 x M}, a cell is returned {1 x M}. If a
%   matrix is given (n x M), a matrix is returned (n x M)
%
%       [validityFunctionValue] = calculateValidity(obj,zRegressor,idxLeafModels,MSFMemory)
%
%
%   calculateVFV output:
%       validityFunctionValue - (N x M) matrix of validity function values.
%
%   calculateVFV input:
%       obj - (object) gaussian model object containing all relevant net and data set information and variables.
%       zRegressor - (N x nz) Regression matrix of the premises (validity functions).
%       idx - (1 x M)  logical vector of the local models, notifying which validity should be calculate.
%       MSFValueMemory - (1 x M) cell array or matrix of (non-normalized) membership function values of the previous local model structure.
%
%
%   SYMBOLS AND ABBREVIATIONS:
%
%       LM:  Local model
%       p:   Number of inputs (physical inputs)
%       q:   Number of outputs
%       N:   Number of data samples
%       M:   Number of LMs
%       nx:  Number of regressors (x)
%       nz:  Number of regressors (z)
%
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fischer, 12-July-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles


% Check if the stored MSFValue is a cell arrays
if nargin<4
    MSFValueIn = {[]};
elseif ~iscell(MSFValueIn)
    error('gaussianOrthoGLobalModel:calculateValidity','The membership function value must be stored in cells!')
end

% Check if the index of the validity is feasible
if nargin<3
    idx = find(obj.leafModels);
elseif islogical(idx)
    % Convert to non-logical index
    idx = find(idx);
%     % Check that the index is part of the leaf models
%     if ~ismember(find(obj.leafModels),idx)
%         error('gaussianOrthoGLobalModel:calculateValidity','Only the validity of a leaf model can be calculated!')
%     end
end

% Get the index of all given membership function that are empty
idxEmptyMSFMemory = cell2mat(cellfun(@(MSFOneCell) isempty(MSFOneCell),MSFValueIn,'UniformOutput',false));

if all(~idxEmptyMSFMemory) && numel(MSFValueIn) >= numel(obj.localModels)
    % No changes done, use the given membership functions
    MSFValueOut = MSFValueIn;
else
    % Initialize the MSFValues
    MSFValueOut = cell(1,numel(obj.localModels));
    
    % Calculation the MSFValues of all leaf models, use the stored
    % membership function values to minimize the computational effort
    if strcmp(version('-release'),'2010a')
        % workaround for R2010a
        MSFValueOut(~idxEmptyMSFMemory) = MSFValueIn;
        idxLeafModels = find(obj.leafModels);
        for k = 1:numel(idxLeafModels)
            if isempty(MSFValueOut{:,idxLeafModels(k)})
                MSFValueOut{:,idxLeafModels(k)} = obj.localModels(idxLeafModels(k)).calculateMSF(zRegressor);
            end
            
        end

    else
        %  for R2010b and later
        MSFValueOut(~idxEmptyMSFMemory) = MSFValueIn;
        idxEmptyMSFValue = cell2mat(cellfun(@(MSFOneCell) isempty(MSFOneCell),MSFValueOut,'UniformOutput',false));
        MSFValueOut(idxEmptyMSFValue) = arrayfun(@(loc) loc.calculateMSF(zRegressor),obj.localModels(idxEmptyMSFValue),'UniformOutput',false);
    end
    
end
    
    % calculate sum
    sumMSFValue = sum(cell2mat(MSFValueOut(obj.leafModels)),2);
    % normalize and superpose all active gaussians
    validity = cell2mat(cellfun(@(MSFOneCell) sum(bsxfun(@rdivide,MSFOneCell,sumMSFValue),2),MSFValueOut(idx),'UniformOutput',false));
    
end
