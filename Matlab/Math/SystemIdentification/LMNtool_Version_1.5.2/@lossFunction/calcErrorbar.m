function [errorbar] = calcErrorbar(obj, inputNew, outputNew, alpha)
%% CALCERRORBAR calculates the confidence intervalls or errorbars, respectively, for the regressors
% on inputNew. By default, it considers the t-distribution such that 95% of the data lie in the
% confidence interval (for alpha=0.05).
%
%
%       [errorbar] = calcErrorbar(obj, inputnew, outputNew)
%
%
%   OUTPUTS:
%
%       errorbar:      (Nnew x 1)   Errorbar or confidence intervals, respectively.
%
%   INPUTS:
%
%       obj:           (object)     Global model object containing all relevant
%                                   properties and methods
%       inputNew:      (Nnew x p)   New input (unscaled) for generalization of the errorbar
%       outputNew:     (Nnew x q)   New output (unscaled). This is needed for dynamical systems
%                                   (kStepPrediction>0).
%       alpha:         scalar       Level of confidence for errorbar.
%
%
%   SYMBOLS AND ABBREVIATIONS
%
%       LM:  Local model
%
%       p:      Number of inputs (physical inputs)
%       q:      Number of outputs (physical outputs)
%       Nnew:   Number of new data samples
%
%
%   LMNtool - Local Model Network Toolbox
%   Benjamin Hartmann, 17-December-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% Check if centered local models are used
if obj.useCenteredLocalModels
    % Here only for a global x regressor a calculation of the errorbar is
    % possible. Loop over all local models is needed...
    error('lossfunction:calcErrorbar','Using centered local models is not implemented jet for errorbar calculation!')
end

%% Check inputs and get Xnew for calculating the errorbar
if ~exist('inputNew','var')
    % If no new input and output is given, use the training data
    Xnew = obj.xRegressor;
    Znew = obj.zRegressor;
    if any(strcmp(superclasses(obj),'gaussianOrthoGlobalModel'))
        phiNew = cell2mat(obj.calculateVFV(obj.MSFValue(obj.leafModels)));
    else
        phiNew = obj.phi(:,obj.leafModels);
    end

else
    % Scale new inputs and assemble X-regression matrix
    inputNew = obj.scaleData(inputNew,obj.scaleParaInput); % input must be scaled
        
    if exist('outputNew','var')
        % if output should be scaled
        outputNew = obj.scaleData(outputNew,obj.scaleParaOutput);
    else
        outputNew = [];
    end
    Xnew = obj.data2xRegressor(inputNew,outputNew);
    Znew = obj.data2zRegressor(inputNew,outputNew);
    phiNew = obj.calculateValidity(Znew,obj.leafModels);
%     if any(strcmp(superclasses(obj),'gaussianOrthoGlobalModel'))
%         phiNew = cell2mat(phiNew);
%     end
end
if obj.kStepPrediction > 0 && ~exist('outputNew','var')
    error('lossFunction:calcErrorbar','Variable <outputNew> does not exist. If the errorbar has to be calculated on new data for a dynamical system, both inputNew and outputNew must be delivered.')
end

M    = sum(obj.leafModels);
X    = obj.xRegressor;
y    = obj.output;
if any(strcmp(superclasses(obj),'gaussianOrthoGlobalModel'))
%     phi = cell2mat(obj.calculateVFV(obj.MSFValue(obj.leafModels)));
    % calculate sum
    sumMSFValue = sum(cell2mat(obj.MSFValue(obj.leafModels)),2);
    % normalize and superpose all active gaussians
    phi = cell2mat(cellfun(@(MSFOneCell) sum(bsxfun(@rdivide,MSFOneCell,sumMSFValue),2),obj.MSFValue(obj.leafModels),'UniformOutput',false));
else
    phi = obj.phi(:,obj.leafModels);
end

% Compute weighted sum of local errorbars
if ~exist('alpha','var')
    alpha = 0.05; % level of confidence for errorbar
end
errorbar = zeros(size(Xnew,1),1);
for LM = 1:M
    [~, ~, ~, ~, ~, ~, ~, ~, errorbarLM] = obj.WLSEstimate(X,y,phi(:,LM),[],Xnew,alpha);
    errorbar = errorbar + phiNew(:,LM).*errorbarLM;
end




