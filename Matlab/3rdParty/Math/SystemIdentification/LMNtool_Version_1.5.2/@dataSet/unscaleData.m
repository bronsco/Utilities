function [data] = unscaleData(obj, data, parameter)
%% UNSCALEDATA unscales the given data according to the stored parameters.
%   Using the LMNTool a scaling of the input data is necessary. After the
%   training the data must be unscaled for e.g. calculating the
%   unscaled output for plotting.
%
%   [data] = scaleData(obj, data)
%
%   SCALEDATA input:
%       obj     - (object)  Complete model object of the LMNTool
%       data    - (N x dim) Unscaled data.
%
%   SCALDEDATA outputs:
%
%       data        - (N x dim) Scaled data.
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

% Unscale data
data = bsxfun(@plus,bsxfun(@times,data,parameter.para2),parameter.para1);