function [center, standardDeviation] = corner2Center(obj,lowerLeftCorner,upperRightCorner,smoothness)
%% CORNER2CENTER convert the corners of the validity areas to centers and
% standard deviations of the resulting membership functions (Gaussians).
%
%
%       [center, standardDeviation] = corner2Center(obj, lowerLeftCorner, upperRightCorner, smoothness)
%
%
%   corner2Center outputs:
%       center            - (G x nz) Centers of the Gaussian
%       standardDeviation - (G x nz) Standard deviations of the Gaussians
%
%
%   corner2Center inputs:
%       lowerLeftCorner   - (G x nz) Lower left corners of the hyper-rectangles
%       upperRightCorner  - (G x nz) Upper right corners of the hyper-rectangles
%       smoothness        - (1 x 1)  Smoothness factor
%
%
%   SYMBOLS AND ABBREVIATIONS:
%
%       LM:  Local model
%
%       G:   Number of Gaussians
%       p:   Number of inputs (physical inputs)
%       q:   Number of outputs
%       N:   Number of data samples
%       M:   Number of LMs
%       nx:  Number of regressors (x)
%       nz:  Number of regressors (z)
%
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fischer, 16-November-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% 18.11.11  help updated

% % Store lower left and upper right corner in object
% % prevents missmatching entries in the local model
% obj.lowerLeftCorner = lowerLeftCorner;
% obj.upperRightCorner = upperRightCorner;

% initialize output paramters with zeros
center = zeros(size(lowerLeftCorner));
standardDeviation = zeros(size(lowerLeftCorner));

% Set smoothness to default if not defined
if nargin < 4
    smoothness = 1;
end

% Evaluate centers and standard deviations for the given corners
for Gaussian = 1:size(center,1) % for-loop over all Gaussians
    % Center of a hyper-rectangle
    center(Gaussian,:) = (upperRightCorner(Gaussian,:) + lowerLeftCorner(Gaussian,:)) / 2;
    % Standard deviation proportional to the size of the hyper-rectangle, proportionality factor: 2.5
    standardDeviation(Gaussian,:) = smoothness * (upperRightCorner(Gaussian,:) - lowerLeftCorner(Gaussian,:)) / 2.5;
end

