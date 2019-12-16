function data = unscale(obj, data)
%% UNSCALE unscales the given data according to the scaling parameters in
% the class
%
%
%       [unscaledData] = unscale(obj, scaledData)
%
%
%   unscale input:
%
%       data - (N x dim) Unscaled data.
%
%
%   unscale output:
%
%       data - (N x dim) Scaled data.
%
%
%   SYMBOLS AND ABBREVIATIONS
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
%   Tobias Ebert, 24-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

switch obj.method
    case 'unitVarianceScaling'
        
        data = unscaleUnitVarianceScaling(data, obj.parameter);
        
    case 'boxcox'
        
        data = unscaleBoxCox(data, obj.parameter);
        
    case 'robustBoxcox'
        
        data = unscaleRobustBoxCox(data, obj.parameter);
        
    otherwise
        
        error('The method you specified is not allowed')
        
end

end

%% robust Box Cox
function data = unscaleRobustBoxCox(data, parameter)


lambda = parameter.lambda;
v1 = parameter.v1;
v2 = parameter.v2;

if parameter.lambda == 0
        
    % get scaled v
    v1s = log(v1);
    
    % get indices of partial transformations
    idx1 = (data >= v1s);
    idx3 = (data < v1s);
    
    % reverse transformation
    if any(idx1)
        data(idx1) = exp(data(idx1));
    end
    if any(idx3)
        data(idx3) = v1 + (data(idx3) - log(v1)) ./ (v1.^(lambda-1));
    end
    
elseif parameter.lambda >= 0
    
    % get scaled v
    v1s = ((v1.^lambda) - 1) ./ lambda;
    
    % get indices of partial transformations
    idx1 = data >= v1s;
    idx2 = data < v1s;
    
    % reverse transformation
    if any(idx1)
        data(idx1) = ((data(idx1) .* lambda) + 1).^(1/lambda);
    end
    if any(idx2)
        data(idx2) = v1 + (data(idx2) - ((v1.^lambda-1) ./ lambda)) ./ (v1.^(lambda-1));
    end
    
elseif parameter.lambda < 0
    
    % get scaled v
    v1s = ((v1.^lambda) - 1) ./ lambda;
    v2s = ((v2.^lambda) - 1) ./ lambda;
    
    % get data above and below of the v value
    idx1 = (data <= v2s) & (data > v1s);
    idx2 = data > v2s;
    idx3 = (data <= v1s);
    
    if any(idx1)
        data(idx1) = ((data(idx1) .* lambda) + 1).^(1/lambda);
    end
    if any(idx2)
        data(idx2) = v2 + (data(idx2) - ((v2.^lambda-1) ./ lambda)) ./ (v2.^(lambda-1));
    end
    if any(idx3)
        % linear extrapolation for yi < v1!
        data(idx3) = v1 + (data(idx3) - ((v1.^lambda-1) ./ lambda)) ./ (v1.^(lambda-1));
    end
   
end

% reverse offset
data = bsxfun(@minus,data,parameter.offset);

end

%% unitVarianceScaling
function data = unscaleUnitVarianceScaling(data, parameter)
data = bsxfun(@plus,bsxfun(@times,data,parameter.std),parameter.mean);
end

%% box cox
function data = unscaleBoxCox(data, parameter)

% reverse boxcox transformation
if parameter.lambda == 0
    data = bsxfun(@minus,exp(data)-eps,parameter.offset);
else
    data = bsxfun(@minus,((data .* parameter.lambda) + 1) .^ (1/parameter.lambda),parameter.offset);
end


end




