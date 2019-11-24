function [lowerLeftCornerNew1, upperRightCornerNew1, lowerLeftCornerNew2, upperRightCornerNew2] = ...
    LMSplit(lowerLeftCorner, upperRightCorner, splitDimension, splitRatio)
%% LMSPLIT splits one local model into two halves by calculating
% the new corners of the resulting local models out of the given corners.
% Therefore it needs the splitting ratio and dimension to provide the
% correct split.
%
%
%       [lowerLeftCornerNew1, upperRightCornerNew1, lowerLeftCornerNew2, upperRightCornerNew2] = ...
%               LMSplit(lowerLeftCorner, upperRightCorner, splitDimension, splitRatio)
%
%
%   LMSplit outputs:
%       lowerLeftCorner1  - (1 x nz) Vector, lower left corner of new LLM 1.
%       upperRightCorner1 - (1 x nz) Vector, upper right corner of new
%                                    LLM 1.
%       lowerLeftCorner2  - (1 x nz) Vector, lower left corner of new LLM 2.
%       upperRightCorner2 - (1 x nz) Vector, upper right corner of new
%                                    LLM 2.
%
%   LMSplit inputs:
%       lowerLeftCorner   - (1 x nz) Vector, upper right corner of LLM to
%                                    split.
%       upperRightCorner  - (1 x nz) Vector, upper right corner of LLM to
%                                    split.
%       splitDimension    - (1 x 1)  Dimension in which the LLM has to be
%                                    splitted.
%       splitRatio        - (1 x 1)  Ratio in which the LLM has to be
%                                    splitted, e.g. 0.5.
%
%
%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 08-December-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


lowerLeftCornerNew1 = lowerLeftCorner;
lowerLeftCornerNew2 = lowerLeftCorner;
upperRightCornerNew1 = upperRightCorner;
upperRightCornerNew2 = upperRightCorner;

% LM 1 (lower left corner stays the same; upper right corner needs to be adjusted)
upperRightCornerNew1(splitDimension) = ...
    (1-splitRatio) * lowerLeftCorner(splitDimension) + splitRatio * upperRightCorner(splitDimension);

% LM 2 (upper right corner stays the same; lower left corner needs to be adjusted)
lowerLeftCornerNew2(splitDimension) = ...
    (1-splitRatio) * lowerLeftCorner(splitDimension) + splitRatio * upperRightCorner(splitDimension);

