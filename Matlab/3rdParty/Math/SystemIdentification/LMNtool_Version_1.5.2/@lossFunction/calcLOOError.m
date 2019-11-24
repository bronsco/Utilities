function [CVScore, nEff, LOOE, nEffAllLM] = calcLOOError(obj)
%% CALCLOOERROR calculates the leave-one-out cross validation error (only
% the linear parameters are newly estimated) and determines the effective
% number of parameters by calculation of trace(S).
%
%
%       [CVScore, nEff, LOOE, nEffAllLM] = calcLOOError(obj)
%
%
%   OUTPUTS:
%
%       CVScore:                (1 x q)     Leave-one-out cross validation score for each output
%                                           (nonlinear sigmoid parameter influences neglected).
%       nEff:                   (1 x 1)     Number of effective parameters. The degrees of
%                                           freedom for the weighted least squares estimation 
%                                           are considered with: nEff = trace(S).
%       LOOE:                   (N x q)     Leave-one-out CV error on each sample.
%       nEffAllLM:              (q x M)     Number of effective parameters for all LMs
%                                           and outputs separately.
%
%   INPUTS:
%
%       obj:                    (object)    global model object containing all relevant
%                                           properties and methods
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
%
%   Comments on number of effective parameters:
%
%       Usually, for local model networks nEff is calculated as nEff = trace(S*S) [see e.g.
%       Murray-Smith et al.]. However, this is computationally very expensive. Therefore, it will be
%       calculated as nEff = trace(S). Consider: trace(S) >= trace(S*S) [Hastie et al.]. This leads
%       to an overestimated amount of parameters which is more secure in terms of complexity
%       considerations.
%
%
%   See also lossFunction, calcGlobalLossFunction, calcLocalLossFunction, calcPenaltyLossFunction,
%            calcErrorbar, crossvalidation, WLSEstimate.
%
%
%   LMNtool - Local Model Network Toolbox
%   Benjamin Hartmann, 03-December-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Get values
maxDelay = obj.getMaxDelay();
y     = obj.output(maxDelay+1:end,:);
[N, q] = size(y);
M     = sum(obj.leafModels);
lmIdx = find(obj.leafModels);


% Get validity function values for leaf models only
if any(strcmp('phi', properties(obj)))
    % hilomot models
    phi = obj.phi(:,obj.leafModels);
%     phi = obj.calculateValidity(obj.zRegressor,obj.leafModels,obj.phi);
elseif any(strcmp('MSFValue', properties(obj)))
    % lolimot models
    % calculate sum
    sumMSFValue = sum(cell2mat(obj.MSFValue(obj.leafModels)),2);
    % normalize and superpose all active gaussians
    phi = cell2mat(cellfun(@(MSFOneCell) sum(bsxfun(@rdivide,MSFOneCell,sumMSFValue),2),obj.MSFValue(obj.leafModels),'UniformOutput',false));
%     phi = obj.calculateValidity(obj.zRegressor,obj.leafModels,obj.MSFValue);
else
    error('lossFunction:calcLOOError','The global model structure is not implemented! Training aborted')
end

% Perform data weighting, if any element of dataWeighting has not value 1.
if any(obj.dataWeighting~=1)
    phi = bsxfun(@times,obj.dataWeighting,phi);
end

% Pre-define variables
nEff      = 0;
nEffAllLM = zeros(q,M);
LOOE      = zeros(N,q);
CVScore   = zeros(1,q);

% Calculation of nEff, LOOE and CVScore is done indivually for each LM and for each output.
% The values are summed up to get the scores for the global model.
for i = 1:M
    for j = 1:q
        
        % Get selected regressors for each output individually
        if obj.useCenteredLocalModels
            % If centered local models are used then use a LOCAL
            % xRegressor!
            X = data2xRegressor(obj,obj.input,obj.output,obj.localModels(lmIdx(i)).center);
            X = X(:,obj.localModels(lmIdx(i)).parameter(:,j)~=0);
        else
            X = obj.xRegressor(:,obj.localModels(lmIdx(i)).parameter(:,j)~=0);
        end
        
        % Here, all LMs are newly estimated in order to get the queried values.
        [~,nEff_i,~,~,LOOE_i,CVScore_i] = obj.WLSEstimate(X,y(:,j),phi(:,i));
        
        CVScore(:,j)   = CVScore(:,j) + CVScore_i;
        nEff           = nEff + nEff_i;
        LOOE(:,j)      = LOOE(:,j) + LOOE_i;
        nEffAllLM(j,i) = nEff_i;
        
    end
end

% Normalize to global loss function type
switch obj.lossFunctionGlobal
    
    case 'MSE'      % mean-squared-error
        
    case 'RMSE'     % root-mean-squared-error
        CVScore = sqrt(CVScore);
        
    case 'NMSE'     % normalized-mean-squared-error
        outputDifference2 = bsxfun(@minus,obj.unscaledOutput,mean(obj.unscaledOutput,1)).^2;
        den = sum(outputDifference2);
        if den<eps; den=eps; end
        CVScore = N*CVScore./den;
        
    case 'NRMSE'    % normalized-root-mean-squared-error
        outputDifference2 = bsxfun(@minus,obj.unscaledOutput,mean(obj.unscaledOutput,1)).^2;
        den = sum(outputDifference2);
        if den<eps; den=eps; end
        CVScore = sqrt(N*CVScore./den);
        
    otherwise
        error('lossfunction:calcLOOError','This type of lossfunction is not implemented so far. Choose "MSE", "RMSE", "NMSE" or "NRMSE"!')
        
end
end

