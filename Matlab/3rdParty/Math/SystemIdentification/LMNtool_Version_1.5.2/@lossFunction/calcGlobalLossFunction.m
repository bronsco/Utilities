function globalLossFunction = calcGlobalLossFunction(obj, output, outputModel, criterion, dataWeighting, outputWeighting)
%% CALCGLOBALLOSSFUNCTION calculates the global loss function for the net object.
%
%   With the optional input "criterion" it is possible to change the
%   error criterion. Therewith it is possible to calculate another error
%   value without changing the criterion which is stored in the net object.
%
%
%       globalLossFunction = calcGlobalLossFunction(obj, output, outputModel, dataWeighting,...
%               outputWeighting, criterion)
%
%
%   calcGlobalLossFunction output:
%
%       globalLossFunction: (1 x 1)   Global loss function value
%
%   calcGlobalLossFunction inputs:
%
%       obj                 (object)    global model object containing all relevant
%                                       net and data set information and variables
%
%       output:             (N x q)     Output matrix
%
%       outputModel:        (N x q)     Model output matrix
%
%       criterion:          (string)    global error criterion. If not given,
%                                       the one specified in the object will be
%                                       used
%
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
%
%   See also lossFunction, calcLocalLossFunction, calcLOOError, calcPenaltyLossFunction,
%            calcErrorbar, crossvalidation, WLSEstimate.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 17-Nov-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% 18.11.11  help updated (TE)
% 16.12.11  Added "eps" to outputDifference2, otherwise J=NaN possible (B.Hartmann)
% 19.07.13  BUGFIX: normalization was improper; rewrite code to lower
%           computational effort (TF)

% change for dynamic systems the output considered
maxDelay = obj.getMaxDelay();
output = output(maxDelay+1:end,:);

if nargin < 4 || isempty(criterion)
    % Use criterion of the object
    criterion = obj.lossFunctionGlobal;
end

if nargin < 5
    % Use data weighting of the object
    dataWeighting = obj.dataWeighting;
end

% Check if output and data weighting missmatch
if size(output,1) ~= size(dataWeighting)
    % set data weighting to one
    dataWeighting = ones(size(output,1),1);
end

if nargin < 6
    % Use output weighting of the object
    outputWeighting = obj.outputWeighting;
    if isempty(outputWeighting)
        outputWeighting = ones(size(output,2),1);
    end
end


% Calculate weighted squared error matrix
error2Weighted = bsxfun(@times,dataWeighting,(output-outputModel).^2);

% Loss function evaluation
switch criterion
    
    case 'MSE'      % mean-squared-error
        globalLossFunction = mean(error2Weighted);
        
    case 'RMSE'     % root-mean-squared-error
        globalLossFunction = sqrt(mean(error2Weighted));
        
    case 'NMSE'     % normalized-mean-squared-error
        varOut = sum((bsxfun(@minus,output,mean(output))).^2);
        varOut(varOut<eps) = eps;
        globalLossFunction = sum(error2Weighted)./varOut;
        
    case 'NRMSE'    % normalized-root-mean-squared-error
        varOut = sum((bsxfun(@minus,output,mean(output))).^2);
        varOut(varOut<eps) = eps;
        globalLossFunction = sqrt(sum(error2Weighted)./varOut);

    case 'R2'       % coefficient of determination aka R squared
        % R2 can be calculated by R2 = 1 - NMSE. Redundant information,
        % only calculate the outside the training procedure.
        varOut = sum((bsxfun(@minus,output,mean(output))).^2);
        varOut(varOut<eps) = eps;
        globalLossFunction = 1 - sum(error2Weighted)./varOut;
 
    case 'MAXERROR' % Use maximal error as global loss function
        globalLossFunction = max(abs(output-outputModel));

        %     case 'MISCLASS' % Used for classification algorithm
        %         if size(output,2)==1 % Only one output (0/1)
        %             globalLossFunction = dataWeighting'*(output ~= (0.5*(1+sign(outputModel-0.5))));
        %         else % Multiple outputs (0 0 1 ....)
        %             [~, index1] = max(output,[],2);      % Which output is correct?
        %             [~, index2] = max(outputModel,[],2); % Which output is currently most active?
        %             globalLossFunction = dataWeighting'*(index1~=index2);  % How many misclassifications?
        %         end
        
    otherwise
        error('lossfunction:calcGlobalLossFunction','This type of lossfunction is not allowed. Choose "MSE", "RMSE", "NMSE", "NRMSE" or "MAXERROR"!')
        
end

globalLossFunction = globalLossFunction * outputWeighting;
