function [phi, kappaOut, center, psi] = calculatePhi(obj, localModels, kappaIn, flagInitialFirstOptimization)
%% CALCULATEPHI calculates the validity values during the split optimization.
%
%   This is a subfunction used during the nonlinear optimization for the
%   calculation of the validity of the split models during the lossfunction
%   and the nonlinear constrains.
%
%   [phi, kappa, center, wNorm] = calculatePhi(wRed, w0, zRegressor, phiWorstLM, fixedKappa, ...
%                  demandedMembershipValue, smoothness, localModels, worstLM)
%
%   CALCULATEPHI inputs:
%       wRed           - (nz x 1)   Complete vector fo the sigmoid
%       w0             - (1 x 1)    Regression matrix for rule premises (Splitting).
%       kappa          - (1 x 1)
%       worst LM       - (1 x 1)    Index of the worst LM
%
%   CALCULATEPHI outputs:
%       phi            - (N x 2)    Validity functions for the two newly generated LMs.
%       kappaOut       - (1 x 1)    Scalar that indicates, how sharp the transition is between the neighboured local models.
%       center         - (2 x nz)   New LM center values after splitting.
%       wNorm          - (nz+1 x 1)
%       psi            - (N x 1)
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 15-May-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

if nargin<4
    flagInitialFirstOptimization = false;
elseif isempty(flagInitialFirstOptimization)
    flagInitialFirstOptimization = false;
end
    
if nargin<3
    kappaIn = [];
end
    
% Get some constants
numberOfInputs      = size(obj.zRegressor,2);
zLowerBound         = min(obj.zRegressor);
zUpperBound         = max(obj.zRegressor);

% Get some variables
wNorm = localModels(1).splittingParameter;
worstLM = localModels(1).parent;

%% 1) Calculate the validity functions for the two newly generated LMs with splitting parameter w
%
% 1.1) Calculate centers with crisp validity functions
%
% Normalize and correct weight vector
deltaCenter = 0.01*(zUpperBound - zLowerBound);             % Choose a small value (sharp transition)
if any(deltaCenter<eps); deltaCenter=deltaCenter+eps; end
kappaCenterCalc  = 20/(norm(deltaCenter));    % Factor that normalizes the sigmoid parameters

% Splitting functions
psiCenterCalc      = localModels(1).calculatePsi(obj.zRegressor,kappaCenterCalc,obj.smoothness);
psiCompCenterCalc  = 1-psiCenterCalc;

% Validity functions
phiCenterCalc = bsxfun(@times, obj.phi(:,worstLM), [psiCenterCalc psiCompCenterCalc]);
% bsxfun for better performance, equal to:
% phi      = zeros(numberOfSamples,2);
% phi(:,1) = phiWorstLM.*psi;
% phi(:,2) = phiWorstLM.*psiComp;


%
% 1.2) Calculate validity functions with correctly smoothed transitions
%

% Calculate centers from validity functions and data distribution (crisp transitions)
center = zeros(2,numberOfInputs);
for dim = 1:numberOfInputs
    center(1,dim) = obj.zRegressor(:,dim)'*phiCenterCalc(:,1)/(sum(phiCenterCalc(:,1))+eps);
    center(2,dim) = obj.zRegressor(:,dim)'*phiCenterCalc(:,2)/(sum(phiCenterCalc(:,2))+eps);
end

if isempty(kappaIn)
    % Calculate a new kappa
    
    % Update kappa-value with center info (correctly smoothed transition)
    deltaCenter = center(1,:) - center(2,:);                    % Updated distance between LM-centers
    if any(deltaCenter<eps); deltaCenter=deltaCenter+eps; end
    kappaCenter       = 20/(norm(deltaCenter));    % kappa depending on the center distances
    
    % Switch between the methods for kappa
    if ~isempty(obj.demandedMembershipValue) && ~flagInitialFirstOptimization % kappa with demanded membership value
        
        % Check if the current kappa-value fullfills the requirement
        % If demandedMembershipValue is empty, no adjustment of kappa is done,
        % only the new phi values are calculated.
        [kappaOut] = obj.adjustKappa(kappaCenter,wNorm,worstLM);
    else
        % no demanded membership value is given, use kappa center
        kappaOut = kappaCenter;
    end
    
else
    % use the given kappaIn for calculation
    kappaOut = kappaIn;
end

% Recalculate Splitting function values with corrected kappa

psi      = localModels(1).calculatePsi(obj.zRegressor,kappaOut,obj.smoothness);
psiComp  = 1-psi;

% Validity functions
phi = bsxfun(@times, obj.phi(:,worstLM), [psi psiComp]);

