function [kappa] = adjustKappa(obj,kappaIni,w,idxModel)
% This function adjusts the kappa-value of a sigmoid, such
% that a special requirement is fullfilled (see while-loop). The parameter
% vector 'w' may belong to no local model in the localModels array, i.e.
% within the nonlinear optimization of the sigmoid split during the
% hilomot training. Therefore the information of the parent (phi and idx)
% are needed seperately.
%
% kappa = adjustKappa(zRegressor,...
%    phiParent,smoothness,kappa,w,localModels,idxParent,sigmoidTransitionAdjustment,smoothness)
%
%
% INPUT
%
% zRegressor:       [N x nz] zRegressor.
%
% phiParent:        [N x 1] This vector contains all phi-values of the
%                           local model, that is the parent of the local
%                           model that contains or will contain the sigmoid
%                           parameters 'w'.
%
% demandedMembershipValue: (Real number) Determines the 'loss of validity' from a
%                                 parent to his children. Therefore only
%                                 values between 0 and 1 makes sense. 1
%                                 means, there should be no loss of
%                                 validity. If this value is zero the 'loss
%                                 of validity' may be arbitrary.
%
% kappa:            (Real number) The initial factor kappa, that defines
%                                 the steepness between two sigmoid
%                                 functions.
%
% w:                [nz+1 x 1] Sigmoid parameters.
%
% localModels:      (1 x nLM) Every entry contains one local model.
%
% idxModel:         (Integer number) Index of the local model, that is or
%                                    will be the parent of the local model,
%                                    that contains the splitting parameters
%                                    w.
%
% sigmoidTransitionAdjustment: (Real number) Determines the factor, the kappa
%                                     value is multiplied by, if the
%                                     transition between the sigmoids is
%                                     not steep enough.
%
% smoothness:       (Real number) Global factor for the smoothness of the
%                                 sigmoid transition area
%
%
% OUTPUT
%
% kappa:  (Real number) The first kappa value, that fullfilled
%                                 the requirement-condition.
%
%
% SYMBOLS AND ABBREVIATIONS:
%
% N:   Number of data samples
% nz:  Number of regressors (z)
% nLM: Number of local models

% Determine the indices of the data points, that lay (geometrically) in the
% parent model
idxParent = obj.localModels(idxModel).getDataInLocalModel4nonlinearOpt(idxModel,obj.zRegressor,obj.localModels);

% Determine the indices of the data points, that lay (geometrically) in the
% child models
idxChild1 = obj.localModels(idxModel).getDataInValidSigmoidArea(w,obj.zRegressor);
idxChild2 = ~idxChild1;

% Only points that are assigned to the parent model can be assigned to the
% children
idxChild1 = all([idxParent idxChild1],2);
idxChild2 = all([idxParent idxChild2],2);

% Splitting functions
psi      = 1./(1+exp( (kappaIni./obj.smoothness) * ( w(end) + obj.zRegressor(idxChild1,:)*w(1:end-1) )));
psiComp  = 1./(1+exp( (kappaIni./obj.smoothness) * ( -w(end) - obj.zRegressor(idxChild2,:)*w(1:end-1) )));

% Select one point to adjust the kappa value of the sigmoids. This point
% should be as near as possible to the psi value 0.6

% the one that is closest to the psi limit but greater than the
% demanded psi value. If there are no greater psi values, the closest point
% to the psi limit should be selected.
psiLimit = 0.6;

psiDiff2limit = [psi-psiLimit;psiComp-psiLimit];
[~,idxMin] = min(abs(psiDiff2limit));

%%%% Alte Variante %%%%%%%
% psi(psi<psiLimit) = inf;
% psiComp(psiComp<psiLimit) = inf;
%
% % Find minimal psi value of both new sigmoids
psiBoth = [psi;psiComp];
% [~,idxMin] = min(psiBoth);
%%%% Alte Variante %%%%%%


% Variable, that contains the row numbers, that correspond to the psi
% values of the vector [psi;psiComp].
indices = [find(idxChild1);find(idxChild2)];


% Check if the initial value for kappa already fullfills the requirement,
% that the point with the lowest psi-value is at least equal to
% (1-demandedMembershipValue). Without this condition, the kappa value might
% be decreased, if the smallest psi-value is greater than the demanded one.
if isempty(idxMin) || (psiBoth(idxMin(1)) >= obj.demandedMembershipValue)
    kappa = kappaIni;
    if isempty(idxMin)
        warning('Geometrically there is no data inside the local model, that is about to be split!');
    end
else
    
    % Pick out the point in the z regressor with the smallest validity. The
    % first entry of idxMin is used (idxMin(1)), because there might be more
    % than one point with the same (minimal) psi-value.
    zMin = obj.zRegressor(indices(idxMin(1)),:);
    
    % Calculation of kappa. The absolute value is taken, because the value will
    % get a negative sign, if the zMin-point lays in the area of the sigmoid,
    % that actually has the splitting parameters -w.
    kappa = abs(obj.smoothness*log(1/obj.demandedMembershipValue-1)/(zMin*w(1:end-1)+w(end)));
    
    % Make sure the sigmoid transitions do not become to steep
    if kappa > kappaIni*3
        kappa = kappaIni*3;
    end
    
end


end