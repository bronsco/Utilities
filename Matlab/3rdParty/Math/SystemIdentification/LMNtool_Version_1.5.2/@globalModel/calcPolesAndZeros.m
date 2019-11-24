function [poles, ZEROS] = calcPolesAndZeros(obj,modelComplexity)
%% CALCPOLESANDZEROS calculates the poles and zeros for each local model
%
%       [poles, ZEROS] = calcPolesAndZeros(obj,modelComplexity)
%
%   calcPolesAndZeros outputs:
%       poles       - {q x M}     Cell array containing the poles for each
%                                 local model
%       Zeros       - {p x M x q} Cell array containing the poles for each
%                                 local model, input and output
%
%   calcPolesAndZeros inputs:
%       obj                 - (object) LMN object
%       modelComplexity     - (1 x 1)  Integer value specifying the number
%                                      of local models
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
%   Julian Belz, 13-March-2016
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2016 by Prof. Dr.-Ing. Oliver Nelles

% Check if input is given
if nargin < 2 || isempty(modelComplexity)
    % If no model complexity is demanded, use the suggested lmn complexity
    modelComplexity = obj.suggestedNet;
end

% Set user demanded model complexity
obj.leafModels = obj.history.leafModelIter{modelComplexity};

% Determine the number of leaf nodes
nLM = sum(obj.leafModels);

% Determine the number of all leaf nodes
LMnumber = find(obj.leafModels);

% Calculate maximum numerator order
numberOfInputs = size(obj.xInputDelay,2);
numberOfOutputs = size(obj.xOutputDelay,2);

% Pre-define cell arrays that will contain the zeros and poles of all local
% models (cell arrays are used, since, in general, each local model might
% have its own order)
poles = cell(numberOfOutputs,nLM);
ZEROS = cell(numberOfInputs,nLM,numberOfOutputs);

% Determine maximum order of each output (important for the correct ZEROS
% calculation)
maxDenOrder = cellfun(@max,obj.xOutputDelay);

% For each leaf node the zeros and poles are calculated
for ii=1:nLM
    
    % Parameters of the current local model
    currentLMparameter = obj.localModels(LMnumber(ii)).parameter;
    
    % First parameter corresponds to the offset and will therefore not be
    % considered for the calculation of the poles and zeros. The variable
    % 'paraIdxStart' points to the first parameter in 'currentLMparameter'
    % belonging to the current (delayed) in- or output
    paraIdxStart = 2;
    
    % Calculation of the zeros
    for jj=1:size(obj.xInputDelay,2)
        
        % Determine end index
        paraIdxEnd = paraIdxStart + size(obj.xInputDelay{jj},2) - 1;
        
        for kk=1:numberOfOutputs
            % Determine difference between numerator and denominator degree
            degreeDiff = maxDenOrder(kk)-max(obj.xInputDelay{jj});
            
            % Generate vector with the length = maximum order (of the current
            % in- or output)
            if any(obj.xInputDelay{jj} == 0)
                % If a zero-delay is contained, the number of parameters
                % for the numerator is the maximum delay + 1
                tmpVec = zeros(1,max(obj.xInputDelay{jj})+1+degreeDiff);
                idxTmp = obj.xInputDelay{jj}+1;
            else
                tmpVec = zeros(1,max(obj.xInputDelay{jj})+degreeDiff);
                idxTmp = obj.xInputDelay{jj};
            end
            
            % Now fill in corresponding parameters
            tmpVec(idxTmp) = currentLMparameter(paraIdxStart:paraIdxEnd,kk);
            
            % Calculate zeros for current local model and current input
            ZEROS{jj,ii,kk} = roots(tmpVec);
        end
        
        paraIdxStart = paraIdxEnd + 1;
    end
    
    % Calculation of the poles
    for jj=1:size(obj.xOutputDelay,2)
        % Determine end index
        paraIdxEnd = paraIdxStart + size(obj.xOutputDelay{jj},2) - 1;
        
        for kk=1:numberOfOutputs
            % Generate vector with the length = maximum order (of the current
            % in- or output)
            % In general the denominator looks like:
            % 1*z^m + a1*z^{m-1} + ... + a_m
            tmpVec = [1 zeros(1,max(obj.xOutputDelay{jj}))];
            
            % Now fill in corresponding parameters
            tmpVec(obj.xOutputDelay{jj}+1) = -1*currentLMparameter(paraIdxStart:paraIdxEnd,kk);
            
            % Calculate zeros for current local model and current input
            poles{kk,ii} = roots(tmpVec);
        end
        
        paraIdxStart = paraIdxEnd + 1;
    end
    
end

if numberOfOutputs == 1
    ZEROS = ZEROS(:,:,1);
end

end


