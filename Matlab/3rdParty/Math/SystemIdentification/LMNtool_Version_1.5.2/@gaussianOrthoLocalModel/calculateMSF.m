function MSFValue = calculateMSF(obj,zRegressor,indexGaussians)
%% CALCULATEMSF calculates the membership function values for each local
% model object based on the standard deviations of the gaussian.
%
%
%       [MSFValue] = calculateMSF(obj, zRegressor, indexGaussians)
%
%
%   calculateMSF output:
%       MSFValue       - (N x G) Matrix of (non-normalized) membership
%                                function values.
%
%
%   calculateMSF input:
%       obj            - (object) Local model object containing all
%                                 relevant information and variables.
%       zRegressor     - (N x nz) Premise regression matrix.
%       indexGaussians - (1 x G)  Index vector of the Gaussians to be
%                                 calculated.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 18-October-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% 18.11.11 help updated (TE)


[numberOfSamples, zNumberOfRegressors] = size(zRegressor);
% check how many Gaussians describe the validity area of the local model
if ~exist('indexGaussians','var')
    indexGaussians = 1:size(obj.center,1);
else
    if indexGaussians > size(obj.center,1)
        error('gaussianOrthoLocalModel:calculateMSF','The index of the Gaussians exceed the dimension of the center matrix!')
    end
end

% get number of Gaussians to be calculated
numberOfGaussians = length(indexGaussians);

% check if no premise input space is given
if zNumberOfRegressors < 1
    if size(obj.center,1) <= 1
        MSFValue = ones(numberOfSamples,1);
        return
    end
    error('gaussianOrthoLocalModel:calculateMSF','More than one gaussians per local model in an empty premise input space. Abort training!')
end

% catch errors
if ~all(size(obj.center,2) == zNumberOfRegressors)
    error('Not all <center> have the same length as the number of z-regressors')
elseif ~all(size(obj.standardDeviation,2) == zNumberOfRegressors)
    error('Not all <standardDeviation> have the same length as the number of z-regressors')
end

% Check for data outside the premise input space boundaries
for dim = 1:zNumberOfRegressors
    % Data outside input space boundary (too large)
    outside = zRegressor(:,dim) > obj.zUpperBound(dim);
    zRegressor(outside,dim) = obj.zUpperBound(dim)*ones(sum(outside),1); % Set to boundary
    % Data outside input space boundary (too small)
    outside = zRegressor(:,dim) < obj.zLowerBound(dim);
    zRegressor(outside,dim) = obj.zLowerBound(dim)*ones(sum(outside),1); % Set to boundary
end

% Calculate exponential
% for G = 1:numberOfGaussians
%     % calc difference to center
%     diff = bsxfun(@minus,zRegressor,obj.center(G,:))
%     % calc distance (divide by standard deviation)
%     r2 = sum(bsxfun(@rdivide,diff,obj.standardDeviation(G,:)).^2,2)
%     % calc Gaussian
%     MSFValue(:,G) = exp(-r2/2);
% end

% v2, same as above but faster
MSFValue = zeros(numberOfSamples,numberOfGaussians);
for G = 1:numberOfGaussians
    % calc distance, save in a variable which is used again to save memory
    MSFValue(:,G) = sum(bsxfun(@rdivide,bsxfun(@minus,zRegressor,obj.center(indexGaussians(G),:)),obj.standardDeviation(indexGaussians(G),:)).^2,2);
end
MSFValue = exp(-MSFValue./2);

end
