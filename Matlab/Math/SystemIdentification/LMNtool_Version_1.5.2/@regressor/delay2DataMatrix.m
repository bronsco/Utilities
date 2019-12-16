function data = delay2DataMatrix(obj,input,output,inputDelay,outputDelay)
%% DELAY2DATAMATRIX creates a data matrix from the input & output data and the
% information about delays
%
%
%       [data] = delay2DataMatrix(input,output,inputDelay,outputDelay)
%
%
%   delay2DataMatrix inputs:
%       obj         -           Local Model Object containing all
%                               information
%       input       - (N x p)   p columns of physical inputs.
%       output      - (N x q)   q columns of physical inputs.
%       inputDelay  - {1 x p}   Delays of the input regressors.
%       outputDelay - {1 x p}   Delays of the output regressors.
%
%
%   delay2DataMatrix outputs:
%       data        - (N x p+q) Delayed data set (input and output data).
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

% 16.11.11 help updated (TE)
% 13.02.13 elseif-condition (check if all variables fit) adjusted (JB)

% Some checks to prevent errors
if isempty(input) && isempty(output)
    error('regressor:delay2datamatrix','Neither input nor output given. Aborting...')
end

% check if all variables fit
if ~isempty(input) && ...
        (isempty(inputDelay) || size(input,2)~=numel(inputDelay))
% if xor(isempty(input),isempty(inputDelay)) ... % if one of those is empty
%         || (size(input,2)~=numel(inputDelay))
    disp(['number of inputs: ' num2str(size(input,2))])
    disp(['number of input delays: ' num2str(numel(inputDelay,2))])
    error('regressor:delay2datamatrix','number of inputs is not equal to number of input delays')
% elseif xor(isempty(output),isempty(outputDelay)) ... % if one of those is empty
%         || (size(output,2)~=numel(outputDelay))
elseif ~isempty(output) && ...
        (isempty(outputDelay) || size(output,2)~=numel(outputDelay))
    disp(['number of outputs: ' num2str(size(output,2))])
    disp(['number of output delays: ' num2str(numel(outputDelay,2))])
    error('regressor:delay2datamatrix','number of outputs is not equal to number of output delays')
end

% Get some variables
numberOfSamples = size([input,output], 1);
numberOfInputs = size(input, 2);
numberOfOutputs = size(output, 2);


maxDelay = obj.getMaxDelay();

% initialisation of the data matrix
if ~exist('output','var') || ~exist('outputDelay','var') || isempty(output) || isempty(outputDelay)
    % only input is given, initialize data matrix without output
    data = zeros(numberOfSamples-maxDelay,sum(cellfun(@numel,inputDelay)));
elseif  ~exist('input','var') || ~exist('inputDelay','var') || isempty(input) || isempty(inputDelay)
    % only output given, initialize data matrix without input
    data = zeros(numberOfSamples-maxDelay,sum(cellfun(@numel,outputDelay)));
else
    % both given
    data = zeros(numberOfSamples-maxDelay,sum(cellfun(@numel,inputDelay))+sum(cellfun(@numel,outputDelay)));
end

colPointer = 0;
% Fill matrix with inputs
for inp = 1:numberOfInputs
    numberOfInputDelays = length(inputDelay{inp});
    for col = 1:numberOfInputDelays
        colPointer = colPointer + 1;
        delay = inputDelay{inp}(col);
        %data(1:delay,colPointer) = input(1,inp)*ones(delay,1);
        data(1:numberOfSamples-maxDelay,colPointer) = input(maxDelay-delay+1:numberOfSamples-delay,inp);
    end
end

% Fill matrix with outputs
for out = 1:numberOfOutputs
    numberOfOutputDelays = length(outputDelay{out});
    for col = 1:numberOfOutputDelays
        colPointer = colPointer + 1;
        delay = outputDelay{out}(col);
        %data(1:delay,colPointer) = output(1,out)*ones(delay,1);
        data(1:numberOfSamples-maxDelay,colPointer) = output(maxDelay-delay+1:numberOfSamples-delay,out);
    end
end

end