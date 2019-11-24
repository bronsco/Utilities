function [regressor ,exponentMatrix] = data2xRegressor(obj,input,output, centerLocalModel)
%% DATA2XREGRESSOR is used to build the x-regression matrix depending on the
% number of inputs and outputs and their delays. In the x-Regressor matrix
% the offset is intended to be in the first column, i.e. the whole first
% column contains ones.
%
%
%       [regressor, exponentMatrix] = data2xRegressor(obj,input,output)
%
%
%   data2xRegressor inputs:
%       obj    - (object) Regressor object containing all relevant
%                         information and variables.
%
%       input  - (N x p) Data matrix containing physical inputs.
%
%       output - (N x q) Data matrix containing physical outputs
%                        (optional).
%
%       centerLocalModel  (1 x nz)  center of the local model for centering
%                                   the regression matrix.
%
%   data2xRegressor outputs:
%       regressor      - (N x nx) Regression matrix containing inputs
%                                 (and outputs if dynamic model).
%
%       exponentMatrix - (nx x p) Exponent matrix with as many coloums as
%                                 inputs.
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
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 24-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% 30.09.11 v0.1
% 04.10.11 v0.2
% 05.10.11
% 08.11.11 case 'sparsePolynomial' implemented
% 18.11.11  help updated

if ~exist('output','var')
    % only inputs are used to assemble to regressor
    output = [];
end

% TODO: tidy up comments
% create datamatrix for regressor
% if ~isempty(input)
%     % test if an input is given
%     
%     if ~isempty(obj.xInputDelay)
%         % use given delay
%         inputDelay = obj.xInputDelay;
%     else
%         % use default delays
%         % inputDelay = num2cell(zeros(1,size(input,2)));
%         inputDelay(1:size(input,2)) = {0}; % faster implementation
%     end
% else
%     inputDelay = [];
% end
% 
% if ~isempty(output)
%     % test if an output is given
%     
%     if ~isempty(obj.xOutputDelay)
%         % use given delay
%         outputDelay = obj.xOutputDelay;
%     else
%         % use default delays
%         outputDelay = cell(1,size(output,2));
%     end
% else
%     outputDelay = [];
% end

maxDelay = obj.getMaxDelay();

if isempty(output) && ~any(cellfun(@isempty,obj.xOutputDelay))
    error('regressor:data2xRegressor:outputEmpty','Output is empty, output delays are not!')
end

% assemble all the delayed physical inputs and outputs to a data matrix
if all(~cellfun(@isempty, obj.xInputDelay)) && all([obj.xInputDelay{:}] == 0) && ...
        all(cellfun(@isempty, obj.xOutputDelay))
    % static systems with inputs = all physical inputs. This is a lot
    % faster than to actually compute the matrix with delays as necessary
    % below!
    data = input;
else
    % subset of inputs or dynamic system
    data = obj.delay2DataMatrix(input,output,obj.xInputDelay,obj.xOutputDelay);
end

% Scale the data into local coordinates, this is only necessary for
% centered local models!
if nargin > 3 && obj.useCenteredLocalModels
    
    % Check if the local model is correct
    if isempty(centerLocalModel)
        error('regressor:data2xRegressor','No Centering possible for the given local model. Check your source code!')
    elseif size(centerLocalModel,2) ~= size(obj.zRegressor,2)
        error('regressor:data2xRegressor','Number of center coordinates missmatches the number of z regressors. Check your source code!')
    end
    
    % Initialize scaled data matrix
    dataScaled = zeros(size(data));
    
    for idx = 1:length(obj.relationZtoX)% For-loop over all physical inputs and outputs
        
        if obj.relationZtoX(idx) == 0
            dataScaled(:,idx) = data(:,idx) - mean(data(:,idx));
        elseif obj.relationZtoX(idx) > 0;
            dataScaled(:,idx) = data(:,idx) - centerLocalModel(obj.relationZtoX(idx));
        else
            error('regressor:data2xRegressor','The property realtionZtoX must have non negative entries!')
        end
    end
    data = dataScaled;
end

% get N and number of inputs
[N, numInputs] = size(data);

% check exponent matrix
if isempty(obj.xRegressorExponentMatrix)
    % build exponent matrix
    exponentMatrix = obj.buildExponentMatrix(obj.xRegressorType,obj.xRegressorDegree,numInputs);
    
    % delete higher orders of exponents if necessary
    idx2Delete = any(exponentMatrix > obj.xRegressorMaxPower,2);
    exponentMatrix = exponentMatrix(~idx2Delete,:);
    
    % sort the exponent Matrix, according to lowest order to highest
    % calculate the sum of all exponents
    sumExponents = sum(exponentMatrix,2);
    % get highest power for all expoents of each regressor
    maxExponents = max(exponentMatrix,[],2);
    % initialise vector for the new indice sequence to use
    idxOrder = [];
    for k = unique(sumExponents') % loop over sum of exponents
        % get the indices of the regressor to sort for, start with highest
        idx2Sort = (sumExponents == k);
        for kk = unique(maxExponents(idx2Sort))' % loop over max of exponents
            idxOrder = [idxOrder; find((maxExponents == kk) & idx2Sort)];
        end
    end
    % use the idxOrder vector to shape expoentMatrix in the new Order
    exponentMatrix = exponentMatrix(idxOrder,:);
else
    exponentMatrix = obj.xRegressorExponentMatrix;
end

% fill regressor with data
switch obj.xRegressorType
    case {'polynomial', 'sparsePolynomial'}
        if all(all(exponentMatrix== 0))
            % 0th Order Model
            regressor = ones(N,1);
        elseif all(exponentMatrix(exponentMatrix>0)==1)
            % 1st order model, faster than the loop below
            noOfRegressors = size(exponentMatrix,1)+1;
            regressor = ones(N,noOfRegressors);
            regressor(:,2:end) = data;
        else
            % n-th order model
            noOfRegressors = size(exponentMatrix,1);
            regressor = ones(N,noOfRegressors);
            for h = 1:size(exponentMatrix,2)
                % find all exponent greater than zero.
                % with regressor = ones(...)
                i = exponentMatrix(:,h)>0;
                % multiply inputs
                regressor(:,i) = regressor(:,i) .*  bsxfun(@power,data(:,h) *ones(1,sum(i)),exponentMatrix(i,h)');
            end
            % add 0th Order
            regressor = [ones(N,1), regressor];
        end
    otherwise
        error('regressor:data2xRegressor','This type of trail function for the regressor is not implemented!')
end



end

