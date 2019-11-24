function [data, parameter] = scaleData(obj, data, parameter)
%% SCALEDATA scales the given data between zero and one.
%   Using the LMNTool a scaling of the input data is necessary. During
%   the optimization large values can mislead the optimization steps.
%   Another problem accrues during the optimization: If a nonlinear
%   optimization is initialized in the origin, it is not possible to
%   make any progress. Therefore any data set is scaled between zero
%   and one for each axis.
%
%   [dataScaled, parameter] = scaleData(data, parameter)
%
%   SCALEDATA input:
%       obj         - (object)  Complete model object of the LMNTool
%       parameter   - (struc)   Structure including the scaling parameters.
%
%   SCALDEDATA outputs:
%
%       data        - (N x dim) Scaled data.
%       parameter   - (struc)   Structure including the scaling parameters.
%
%   SYMBOLS AND ABBREVIATIONS
%
%       N:   Number of data samples
%       dim: Number of data dimensions
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fischer, 13-Mai-2014
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2014 by Prof. Dr.-Ing. Oliver Nelles


% Check given data set for <NaN> and <Inf>
if any(any(isnan(data)))
    warning('There are NaN values in the given data samples!')
elseif any(any(isinf(data)))
    warning('There are INF values in the given data samples!')
end

if isempty(data)
    % If data is empty, give empty matrix back
    data = [];
else
    
    % If no parameters are given, calculate the scaling parameters
    if isempty(parameter)
        dataRanges = max(data) - min(data);
        switch lower(obj.scalingMethod)
            case 'unitvariance'
                % Mean of each column is 0 and std is 1 after scaling
                parameter.para1 = mean(data,1);
                parameter.para2 = std(data,[],1);
            case 'none'
                % No scaling at all
                parameter.para1 = zeros(1,size(data,2));
                parameter.para2 = ones(1,size(data,2));
            otherwise
                % Scale each column of data to the interval [0,1]
                parameter.para1 = min(data);
                parameter.para2 = dataRanges;
                
        end
        
        % Do not scale columns without variation
        idxZero = dataRanges==0;
        parameter.para1(idxZero) = 0;
        parameter.para2(idxZero) = 1;
        
        if any(idxZero)
            % Show warning that one column has always the same value
            warning('scaleData:nonUniqueData','All rows of a input column are equal')
        end
    end
    
    % Scale data with the determined scaling parameters
    data = bsxfun(@rdivide,bsxfun(@minus,data,parameter.para1),parameter.para2);
    
end

% Check scaled data set for <NaN> and <Inf>
if any(any(isnan(data)))
    warning('There are NaN values in the transformed data samples!')
elseif any(any(isinf(data)))
    warning('There are INF values in the transformed data samples!')
end
