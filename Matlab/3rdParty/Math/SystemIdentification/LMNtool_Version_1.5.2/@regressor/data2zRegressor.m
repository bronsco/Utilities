function regressor = data2zRegressor(obj, input, output)
%% DATA2ZREGRESSOR is used to build the z-Regressor matrix depending on the
% number of inputs and outputs and their delays. In the z-Regressor matrix
% the offset is not intended. If a polynomial trial function is used its
% degree must be one.
%
%
%       [regressor] = data2zRegressor(obj,input,output)
%
%
%   data2zRegressor inputs:
%       obj    - (object) Regressor object containing all relevant
%                         information and variables.
%
%       input  - (N x p) Data matrix containing physical inputs.
%
%       output - (N x q) Data matrix containing physical outputs
%                        (optional).
%
%   data2zRegressor outputs:
%       regressor      - (N x nx) Regression matrix containing inputs
%                                 (and outputs if dynamic model).
%
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
% 05.10.11 changed to new format
% 16.11.11 doc/help updated (TE)

if ~exist('output','var')
    % only inputs are used to assemble to regressor
    output = [];
end

% TODO: tidy up comments
% create datamatrix for regressor
% if ~isempty(input) % test if an input is given
%     if ~isempty(obj.zInputDelay)
%         inputDelay = obj.zInputDelay; % use given delay
%     else
%         % use default delays
%         %inputDelay = num2cell(zeros(1,size(input,2))); 
%         inputDelay(1:size(input,2)) = {0}; % faster implementation
%     end
% else
%     inputDelay = [];
% end
% if ~isempty(output) % test if an output is given
%     if ~isempty(obj.zOutputDelay)
%         outputDelay = obj.zOutputDelay; % use given delay
%     else
%         outputDelay = cell(1,size(output,2)); % use default delays
%     end
% else
%     outputDelay = [];
% end

% assemble all the delayed physical inputs and outputs to a data matrix
% regressor = obj.delay2DataMatrix(input,output,inputDelay,outputDelay);

% assemble all the delayed physical inputs and outputs to a data matrix
if all(~cellfun(@isempty, obj.zInputDelay)) && all([obj.zInputDelay{:}] == 0) && ...
        all(cellfun(@isempty, obj.zOutputDelay))
    
    % static systems with inputs = all physical inputs, this is a lot
    % faster than to actually compute the matrix with delays as necessary
    % below!
    regressor = input;
else
    % subset of inputs or dynamic system
    regressor = obj.delay2DataMatrix(input,output,obj.zInputDelay,obj.zOutputDelay);
end

% apply displacement to prevent numerical problems due to bad problem
% formulation in the split optimization
if ~isempty(obj.zRegressorDisplacement)
   regressor = bsxfun(@minus, regressor, obj.zRegressorDisplacement); 
end

% For the future: Further manipulations of the 'regressor' data matrix 
% might be necessary, depending on the properties 'zRegressorType',
% 'zRegressorDegree', 'zRegressorExponentMatrix', 'zRegressorMaxPower', etc.

end

