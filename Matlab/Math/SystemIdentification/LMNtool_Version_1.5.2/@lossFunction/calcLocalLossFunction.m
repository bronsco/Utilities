function localLossFunction = calcLocalLossFunction(obj, output, outputModel, validityFunctionValue, criterion, dataWeighting, outputWeighting)
%% CALCLOCALLOSSFUNCTION calculates the local loss function value for each column given in
% "validityFunctionValue".
%
%   It is possible to calculate only the lossfunction values of certain local models, because every
%   column is the validity of one local model. With the optional input "criterion" it is possible to
%   change the error criterion. Therewith it is possible to calculate another error value without
%   changing the criterion stored in the net object.
%
%
%       localLossFunction = calcLocalLossFunction(obj, output, outputModel, ...
%               validityFunctionValue, dataWeighting, outputWeighting, criterion)
%
%
%   calcLocalLossFunction output:
%
%       localLossFunction:      (1 x 1)     Global loss function value
%
%   calcLocalLossFunction inputs:
%
%       obj                     (object)    Global model object containing all relevant
%                                           net and data set information and variables
%
%       output:                 (N x q)     Output matrix
%
%       outputModel:            (N x q)     Model output matrix
%
%       validityFunctionValue   (N x M)     validity function matrix
%
%       criterion:              (string)    global error criterion. If not given,
%                                           the one specified in the object will be
%                                           used
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
%   See also lossFunction, calcGlobalLossFunction, calcLOOError, calcPenaltyLossFunction,
%            calcErrorbar, crossvalidation, WLSEstimate.
%
%
%   LMNtool - Local Model Network Toolbox
%   Benjamin Hartmann, 04-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% change length of dynamic output considered
maxDelay = obj.getMaxDelay();
output = output(maxDelay+1:end,:);

if nargin < 5 || isempty(criterion)
    % Read loss function criterion of the LMN object
    criterion = obj.lossFunctionLocal;
end

if nargin < 6
    % Used data weighting of the lolimot object
    dataWeighting = obj.dataWeighting;
end

if nargin < 7
    % Used data weighting of the lolimot object
    outputWeighting = obj.outputWeighting;
end

% Check if output and data weighting missmatch
if size(output,1) ~= size(dataWeighting)
    % set data weighting to one
    dataWeighting = ones(size(output,1),1);
end

% convert the cell to a matrix
if iscell(validityFunctionValue)
    validityFunctionValue = cell2mat(validityFunctionValue);
end



% Calculate weighted squared error matrix
error2Weighted = bsxfun(@times,dataWeighting,(output-outputModel).^2);

% Loss function evaluation
switch criterion
    
    case 'SE' % Use squared error as local loss function
        localLossFunction =  validityFunctionValue' * error2Weighted;
        
    case 'RSE' % Use root squared error as local loss function
        localLossFunction = sqrt(validityFunctionValue' * error2Weighted);
        
    case 'DRSE' % DRSE: Density Root Square Error
        % Used for HILOMOT utilized as a Design of Experiments (DoE) algorithm.
        % The RSE is normalized with the sum of validity functions that represent
        % a measure of the number of local model data points.
        approxNumberOfPoints = sum(validityFunctionValue,1)';
        approxNumberOfPoints(approxNumberOfPoints<eps) = eps;
        localLossFunction = sqrt(validityFunctionValue'*error2Weighted)./approxNumberOfPoints;
        
        % %     case 'MISCLASS',
        % %         % Used for classification algorithm
        % %         if size(output,2)==1 % Only one output (0/1)
        % %             localLossFunction = validityFunctionValue'*(dataWeighting.*(output~=(0.5*(1+sign(outputModel-0.5)))));
        % %         else % Multiple outputs (0 0 1 ....)
        % %             [~, index1]=max(output,[],2);      % Which output is correct?
        % %             [~, index2]=max(outputModel,[],2); % Which output is currently most active?
        % %             localLossFunction = validityFunctionValue'*(dataWeighting.*(index1~=index2));
        % %         end
        
    case 'MAXERROR' % Use the maximal error as local loss function
        localLossFunction = zeros(size(validityFunctionValue,2),size(output,2));
        for k = 1:size(output,2)
            localLossFunction(:,k) = max(abs(bsxfun(@times,validityFunctionValue,output(:,k)-outputModel(:,k))));
        end
    otherwise
        error('lossFunction:calcLocalLossFunction','This type of lossfunction is not allowed: Choose "SE", "RSE", "DRSE", "MISCLASS" or "MAXERROR"!')
        
end

localLossFunction = localLossFunction * outputWeighting;
