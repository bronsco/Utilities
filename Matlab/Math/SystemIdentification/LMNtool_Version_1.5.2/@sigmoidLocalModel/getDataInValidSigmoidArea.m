function idx = getDataInValidSigmoidArea(v,zRegressor)
% identify all data points which are on the LMs side of its splitting plane
% (The area of the sigmoid, where the validity values tend to one).
% ATTENTION: This will include data from neighboring local models of higher
% hierarchical order (see circles 'o' in the graphic below).
%
% \      .o
%  \    .oo
%   \  .ooo
%    \.oooo
%    /\oooo
%   /xx\ooo
%  /xxxx\oo
% /x LM x\o
%/xxxxxxxx\
%
% idx = getDataInValidSigmoidArea(obj,zRegressor)
%
% INPUTS
%
%
% v:            (nz+1 x 1) Sigmoid parameters, where the last entry
%                          corresponds to v0.
%
% zRegressor:   (N x nz) zRegressor
%
%
% OUTPUTS
%
%
% idx:          (N x 1) Logical vector, that determines which lines of the
%                       zRegressor lay in the valid region of the sigmoid,
%                       that is described by its parameter vector 'v'.
%
%
% SYMBOLS AND ABBREVIATIONS:
%
% N:   Number of data samples
% nz:  Number of regressors (z)

% LMNtool - Local Model Network Toolbox
% Tobias Ebert & Julian Belz, 18th-Jan-2013
% Institute of Mechanics & Automatic Control, University of Siegen, Germany
% Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% Check if the object is the root (empty v)
if isempty(v)
    
    % The root contains all data
    idx = true(size(zRegressor,1),1);
    
else
    
    % get v1 to vi (sigmoid parameters)
    vstern = v(1:end-1);
    
    % calculate the minimum distance from the origin to the splitting plane
    L = v(end) / norm(vstern);
    
    % get the normal vector of the splitting plane
    ev = v(1:end-1) / norm(v(1:end-1));
    
    
    % get the vector which describes the splitting plane: The point with the
    % minimal distance of the splitting plane to the origin,
    splittingPlane = -L*ev;
    
    % get all those data points which are on the LM side of the splitting plane
    idx = bsxfun(@minus,zRegressor,splittingPlane')*ev <= 0;
    
end

end