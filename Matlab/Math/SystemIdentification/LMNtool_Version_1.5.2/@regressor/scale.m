function [data, obj] = scale(obj, data)
%% SCALE scales the given data according to the information in the class.
%
%
%       [scaledData, obj] = scale(obj, data)
%
%
%   scale input:
%
%       data - (N x dim) Unscaled data.
%
%
%   scale outputs:
%
%       data - (N x dim)         Scaled data.
%       obj  - (dataScale class) Optional output including the scaling parameters.
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


if any(any(isnan(data)))
    warning('There are NaN values in the given data samples!')
elseif any(any(isinf(data)))
    warning('There are INF values in the given data samples!')
end


switch obj.method
    case 'unitVarianceScaling'
        % scale data to mean zero and standard deviation one
        
        if isempty(obj.parameter)
            % no previos scaling, write new parameter into obj
            [data, obj.parameter] = unitVarianceScaling_noPara(data);
        else
            % use existing scaling parameters
            data = unitVarianceScaling(data, obj.parameter);
        end
        
    case 'boxcox'
        % scale data with boxcox transformation
        
        if isempty(obj.parameter)
            %error('no parameters for boxcox transformation where given. Use boxcox_0.5 for example')
            [data, obj.parameter] = boxcox_noPara_scaling(data,obj.method);
        else
            % use existing scaling parameters
            data = boxcox_scaling(data, obj.parameter);
        end
        
    case 'robustBoxcox'
        % scale data with boxcox transformation
        
        if isempty(obj.parameter)
            %error('no parameters for boxcox transformation where given. Use boxcox_0.5 for example')
            [data, obj.parameter] = robustBoxcox_noPara_scaling(data,obj.method);
        else
            % use existing scaling parameters
            data = robustBoxcox_scaling(data, obj.parameter);
        end
        
        
        
    otherwise
        
        if strncmpi(obj.method,'boxcox',6)
            % check if the first 6 characters for box cox transformation
            
            % scale data
            [data, obj.parameter] = boxcox_noPara_scaling(data,obj.method);
            % overwrite obj.method for faster calculation after parameters
            % have been set
            obj.method = 'boxcox';
            
        elseif strncmpi(obj.method,'robustBoxcox',12)
            % check if the first 6 characters for robust box cox transformation
            
            % scale data
            [data, obj.parameter] = robustBoxcox_noPara_scaling(data,obj.method);
            % overwrite obj.method for faster calculation after parameters
            % have been set
            obj.method = 'robustBoxcox';
            
            
        else
            error('The method you specified is not allowed')
        end
        
end


if any(any(isnan(data)))
    warning('There are NaN values in the transformed data samples!')
elseif any(any(isinf(data)))
    warning('There are INF values in the transformed data samples!')
end

end

%% BOx Cox transformation
function [data, parameter] = boxcox_noPara_scaling(data,method)


% get the offset variable (lambda 2)
if any(data <= 0)
    parameter.offset = -min(data);
    % do add a negative offset, high minimal values should remain
    % (only necessary for multiple coloums of data)
    parameter.offset(parameter.offset<0) = 0;
else
    % set offset to zero
    parameter.offset = zeros(1,size(data,2));
end


% get lambda value for boxcox transformation
if length(method) == 6
    [data, parameter.lambda] = boxcox(data);
else
    % read lambda value
    parameter.lambda = str2double(method( regexp(method,'[+-.0123456789]','once'):end));
    % apply scaling
    data = boxcox_scaling(data, parameter);
end

end

function data = boxcox_scaling(data, parameter)

% scale data
% if parameter.lambda == 0
%     data = log(bsxfun(@plus,data,parameter.offset)+eps);
% else
%     data = (bsxfun(@plus,data,parameter.offset).^parameter.lambda - 1) / parameter.lambda;
% end

% scale data with matlab boxcox function
data = data + parameter.offset;
data = boxcox(parameter.lambda, data);

end


%% ROBUSTE BOXCOX transformation
function [data, parameter] = robustBoxcox_noPara_scaling(data,method)

% read lambda value
parameter.lambda = str2double(method( regexp(method,'[+-.0123456789]','once'):end));

parameter.offset = -min(data)+0.1;

parameter.v1 = 0.1;
parameter.v2 = max(data)+parameter.offset;

% apply scaling
data = robustBoxcox_scaling(data, parameter);
%end

end

function data = robustBoxcox_scaling(data, parameter)

% scale data
% if parameter.lambda == 0
%     data = log(bsxfun(@plus,data,parameter.offset)+eps);
% else
%     data = (bsxfun(@plus,data,parameter.offset).^parameter.lambda - 1) / parameter.lambda;
% end

% scale data with robust boxcox transformation
data = data + parameter.offset;

idx1 = [];
idx2 = [];

v1 = parameter.v1;
v2 = parameter.v2;

% get v parameter

if parameter.lambda == 0
    
    idx1 = data >= v1;
    idx3 = data < v1;
    
    if any(idx1)
        % special case lambda = 0
        data(idx1) = log(data(idx1));
    end
   
    if any(idx3)
        % linear extrapolation for yi < v1!
        data(idx3) = v1.^(parameter.lambda-1) .* (data(idx3)-v1) + log(v1);
    end
    
elseif parameter.lambda >= 0
    
    % get data above and below of the v value
    idx1 = data >= v1;
    idx2 = data < v1;
    
    if any(idx1)
        data(idx1) =  ((data(idx1).^parameter.lambda) - 1) ./ parameter.lambda;
    end
    
    if any(idx2)
        data(idx2) = v1.^(parameter.lambda-1) .* (data(idx2)-v1) + ((v1.^parameter.lambda-1) ./ parameter.lambda);
    end
    
elseif parameter.lambda < 0
    
    % get data above and below of the v value
    idx1 = (data <= v2) & (data > v1);
    idx2 = data > v2;
    idx3 = data <= v1;
    
    if any(idx1)
        data(idx1) =  ((data(idx1).^parameter.lambda) - 1) ./ parameter.lambda;
    end
    
    if any(idx2)
        data(idx2) = v2.^(parameter.lambda-1) .* (data(idx2)-v2) + ((v2.^parameter.lambda-1) ./ parameter.lambda);
    end
    
    if any(idx3)
        % linear extrapolation for yi < v1!
        data(idx3) = v1.^(parameter.lambda-1) .* (data(idx3)-v1) + ((v1.^parameter.lambda-1) ./ parameter.lambda);
    end
    
    
end




end

%% unitVarianceScaling
function [data, parameter] = unitVarianceScaling_noPara(data)
% scale data to mean zero and standard deviation one

% calculate mean
parameter.mean = mean(data,1);
% subtract mean
data = bsxfun(@minus,data,parameter.mean);
% calculate standard deviation
parameter.std = std(data);
% check for std = 0
if any(parameter.std == 0)
    % set std=0 to std=1
    parameter.std(parameter.std == 0) = 1;
end
% divide by standard deviation
data = bsxfun(@rdivide,data,parameter.std);
end

function data = unitVarianceScaling(data, parameter)

% give a warning if data has already been scaled
if all(mean(data) < 1e-15 & std(data) == 1)
    warning('scaleData:scaling','It seems the data is already scaled! Check your data!')
end

% scale data to mean zero and standard deviation one
data = bsxfun(@rdivide,bsxfun(@minus,data,parameter.mean),parameter.std);
end




