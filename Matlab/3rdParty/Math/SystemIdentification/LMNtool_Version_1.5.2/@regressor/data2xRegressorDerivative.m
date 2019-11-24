function derivative = data2xRegressorDerivative(obj,input,output, centerLocalModel)
%% DATA2XREGRESSORDERIVATIVE is used to build the derivative of the
% x-regression matrix depending on the number of inputs and outputs and
% their delays. In the x-Regressor matrix the offset is intended to be in
% the first column, i.e. the whole first column of the derivative contains
% zeros.
%
%
%       derivative = data2xRegressorDerivative(obj,input,output, idxOfLocalModel)
%
%
%   data2xRegressorDerivative inputs:
%       obj    - (object) Regressor object containing all relevant
%                         information and variables.
%
%       input  - (N x p) Data matrix containing physical inputs.
%
%       output - (N x q) Data matrix containing physical outputs
%                        (optional).
%
%       numberOfLocalModel  (1 x 1) idicates for which local model the local
%                                   transformation should be done
%
%   data2xRegressorDerivative outputs:
%       derivative - {p}(N x nx) Derivatives of the Regression matrix with
%                                as many cells as physical inputs. In each
%                                cell is the derivative of the xRegressor
%                                for one physical input
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
%   Tobias Ebert, 10-April-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

if ~exist('output','var')
    % only inputs are used to assemble to regressor
    output = [];
end

inputDelay = obj.xInputDelay; % use given delay
outputDelay = obj.xOutputDelay; % use given delay

% assemble all the delayed physical inputs and outputs to a data matrix
if all(~cellfun(@isempty,inputDelay)) && all([inputDelay{:}] == 0) && ...
        all(cellfun(@isempty,outputDelay))
    % static systems with inputs = all physical inputs. This is a lot
    % faster than to actually compute the matrix with delays as necessary
    % below!
    data = input;
else
    % subset of inputs or dynamic system
    error('regressor:data2xRegressorDerivative','The Gradient of dynamic models is currently not implemented.')
end


if obj.useCenteredLocalModels  && nargin > 3
    % Scale the data into local coordinates, this is only necessary for
    % centered local models!
    
    % Initialize scaled data matrix
    dataScaled = zeros(size(data));
    
    % Check if the local model center is correct
    if isempty(centerLocalModel)
        error('regressor:data2xRegressorDerivative','No Centering possible for the given local model. Check your source code!')
    elseif size(centerLocalModel,2) ~= size(obj.zRegressor,2)
        error('regressor:data2xRegressorDerivative','Number of center coordinates missmatches the number of z regressors. Check your source code!')
    end
    
    for idx = 1:length(obj.relationZtoX)% For-loop over all physical inputs and outputs
        
        if obj.relationZtoX(idx) == 0
            dataScaled(:,idx) = data(:,idx) - mean(data(:,idx));
        elseif obj.relationZtoX(idx) > 0;
            dataScaled(:,idx) = data(:,idx) - centerLocalModel(obj.relationZtoX(idx));
        else
            error('regressor:data2xRegressorDerivative','The property realtionZtoX must have non negative entries!')
        end
    end
    data = dataScaled;
end

% get the exponent Matrix
exponentMatrix = obj.xRegressorExponentMatrix;

% fill derivative with data
switch obj.xRegressorType
    case {'polynomial', 'sparsePolynomial'}
        
        noOfRegressors = size(exponentMatrix,1);
        derivative = cell(1,size(exponentMatrix,2));
        
        if (numel(exponentMatrix) == noOfRegressors^2) && ...
                all(all(exponentMatrix == eye(noOfRegressors)))
            % 1st order model
            for t = 1:noOfRegressors
                derivative{t} = exponentMatrix(t,:); 
            end
            
        else % n-th order model
            % loop over all inputs, as a derivative for every single one is
            % needed
            for t = 1:size(exponentMatrix,2)
                % split the derivative in its new prefactors and exponents
                derivativeFactor = exponentMatrix(:,t);
                derivativeExponents = exponentMatrix;
                derivativeExponents(exponentMatrix(:,t)>0, t) = exponentMatrix(exponentMatrix(:,t)>0, t)-1;
                % initialize the derivative
                derivative{t} = ones(size(data,1), noOfRegressors);
                % apply prefactors
                derivative{t} = bsxfun(@times, derivative{t}, derivativeFactor');
                % multiply with physical inputs to the power of derivative exponents
                for h = 1:size(exponentMatrix,2)
                    % find all exponent greater than zero.
                    i = derivativeExponents(:,h)>0;
                    % multiply inputs
                    derivative{t}(:,i) = derivative{t}(:,i) .*  bsxfun(@power, data(:,h)*ones(1,sum(i)), derivativeExponents(i,h)');
                end
            end
        end
    otherwise
        error('regressor:data2xRegressor','This type of trail function for the regressor is not implemented!')
end

end
