function outputModel = calcYhat(xRegressor,validityFunctionValue,parameter)
%% CALCYHAT predicts the output of the model for a given regressor matrix
% of the consequent space (x-regressor).
%
%
%       [outputModel] = calcYhat(xRegressor,validityFunctionValue,parameter)
%
%
%   calcYhat outputs:
%
%       outputModel - (N x q) Predicts the model output(s).
%
%
%   calcYhat inputs:
%
%       xRegressor            - (N x nx) Regression matrix of the rule consequents (x-space).
%
%       validityFunctionValue - {1 x M}  Cell array containing the matrices of
%                                        the normalized validity function values
%                                        for each local model
%
%       parameter             - {1 x M}  cell array containing the parameter
%                                        vector og each local model
%
%
%   SYMBOLS AND ABBREVIATIONS:
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
%
%   See also globalModel, calculateModelOutput, plotLossFunction, plotModel, plotPartition,
%            plotCorrelation, plotModelCentered.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 16-November-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% 2013/01/18:   help updated (Benjamin Hartmann)
% 2011/11/18:   help updated (TE)


% number of data samples
numberOfSamples = size(xRegressor, 1);

% number of outputs
numberOfOutputs = size(parameter{1},2);

% convert the cell to a matrix
if iscell(validityFunctionValue)
    error('Validity must be a matrix, not a cell!')
end


if numberOfOutputs == 1
    % special case only one output, faster than loop below
    outputModel = sum(validityFunctionValue.*(xRegressor * [parameter{:}]),2);
    
else
    
    % loop over all outputs to predict the output model
    outputModel = zeros(numberOfSamples,numberOfOutputs);
    for out = 1:numberOfOutputs
        para_out = cell2mat(cellfun(@(x) x(:,out),parameter,'UniformOutput',false));
        outputModel(:,out) = sum(validityFunctionValue.*(xRegressor * para_out),2);
    end
    
end
end