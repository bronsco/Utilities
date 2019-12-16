function [validity] = calculateVFV(obj,MSFValue,idxLeafModels)
% CALCULATEVFV calculates the validity during the training, after the
% models structure is changed. Therefore the current leaf models and the
% new generated local models are considered. During training the worst
% local model should be removed. This approach reduces the effort during
% the training.

%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 02-September-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% Calculate the validity values for all leaf models
% MSFValueNew = arrayfun(@(loc) loc.calculateMSF(obj.zRegressor),localModelsNew,'UniformOutput',false);
% MSFValue = [obj.MSFValue(idxLeafModels(1:end-numel(localModelsNew))),MSFValueNew];

MSFValueRed = MSFValue(idxLeafModels);

% calculate sum
sumMSFValue = sum(cell2mat(MSFValueRed),2);
% normalize and superpose all active gaussians
validity = cell2mat(cellfun(@(MSFOneCell) sum(bsxfun(@rdivide,MSFOneCell,sumMSFValue),2),MSFValueRed,'UniformOutput',false));

