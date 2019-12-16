function lineSpecObjects = generateLineSpecObjects(numberOfDifferentLines)
%% GENERATELINESPECOBJECTS Generates an array of lineSpec objects
%
%       lineSpecObjects = generateLineSpecObjects(numberOfDifferentLines)
%
%
%   beginSearch inputs:
%       numberOfDifferentLines - (1 x 1)   Number of lineSpec objects.
%
%
%   beginSearch outputs:
%       lineSpecObjects        - (1 x numberOfDifferentLines)  Array of lineSpec objects.
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
%   Julian Belz, 18-Nov-2014
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2014 by Prof. Dr.-Ing. Oliver Nelles


lineSpecObjects(numberOfDifferentLines) = lineSpec;

