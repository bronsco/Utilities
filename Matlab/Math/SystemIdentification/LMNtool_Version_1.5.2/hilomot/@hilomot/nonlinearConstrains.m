function [nonLinIneqCons,nonLinEqCons,gradNonLinIneqCons,gradNonLinEqCons] = nonlinearConstrains(obj,wRed, w0, kappa, worstLM)
%% OBLIQUEGLOBALLOSSFUNCTION calculates the loss function for split optimization.
%
%   The worst LM of current net is splitted and parameters for the newly generated LMs are
%   estimated. Afterwards the global model is evaluated on the training data and the global loss
%   function value for optimization is calculated.
%
%   Consequently, the linear estimation of the local model parameters is nested inside of the
%   nonlinear optimization of the sigmoid parameters.
%
%
%       [J, parameter, center, phi, outputModelNew] = ...
%           obliqueGlobalLossFunction(...
%           wRed, w0, xRegressor, zRegressor, output, outputModel, ...
%           weightedOutputWorstLM, phiWorstLM, fixedKappa, demandedMembershipValue,...
%           smoothness, dataWeighting, useCenteredLocalModels, data, ...
%           xRegressorExponentMatrix, relationZtoX, localModels,leafModels, ...
%           worstLM, kStepPrediction, xInputDelay, zInputDelay, xOutputDelay, zOutputDelay)
%
%
%   OBLIQUEGLOBALLOSSFUNCTION inputs:
%
%       wRed           - (nz x 1) Weigth vector for sigmoid direction.
%       w0             - (1 x 1)  Sigmoid offset value. Kept constant during optimization.
%       kappa          - (1 x 1)  Scalar that indicates, how sharp the transition is between the neighboured local models.
%       worst LM       - (1 x 1)  Index of the worst LM
%
%   OBLIQUEGLOBALLOSSFUNCTION outputs:
%
%       c              -  (2 x 1)    Current nonlinear inequality constrains.
%       ceq            -  empty      Nonlinear equality constrains. Currently not used.
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 15-May-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

%% nonlinear inequality constrain for fmincon

% 1) Inequality constrains

% Calculate the validity and initialize two new local model objects

w = [wRed; w0];

% initialize the new generated local models
localModels = [sigmoidLocalModel(worstLM,w), sigmoidLocalModel(worstLM,-w)];

% calculate the validities of the local models
[phi, ~, ~, psi] = obj.calculatePhi(localModels, kappa);

if obj.kStepPrediction > 1
    
    % Update the local model objects
    localModels(1).kappa = kappa;
    localModels(2).kappa = kappa;
    
    % Set worst local model on false and update indicies of the leaf models
    leafModels = obj.leafModels;
    leafModels(worstLM) = false;
    leafModels = [leafModels true(1,2)];
    
    % estimate the parameters of the two new local models
    localModels(1).parameter = estimateParametersLocal(obj,obj.xRegressor, obj.output, phi(:,end-1), [], obj.dataWeighting);
    localModels(2).parameter = estimateParametersLocal(obj,obj.xRegressor, obj.output, phi(:,end), [], obj.dataWeighting);
    
    % Combine the existing models with the two new generated
    localModels = [obj.localModels localModels];
    
    % Simulate parallel
    [~,~,phiAll,psiAll]  = obj.simulateParallel(obj.input,obj.output,localModels,leafModels);
    phi = phiAll(:,end-1:end);
end

nonLinIneqCons = bsxfun(@minus,obj.pointsPerLMFactor * size(obj.xRegressor,2),sum(phi,1))';

if nargout > 2
    
    if obj.kStepPrediction <= 1
        GM = obj.phi(:,worstLM);
    else
        GM = phiAll(:,worstLM);
        psi = psiAll(:,end-1);
    end
    
    dpsi1 = bsxfun(@times, (psi-1).*psi*kappa/obj.smoothness, bsxfun(@times, -w(1:end-1)'/(w'*w)^(3/2), w(end)+obj.zRegressor*w(1:end-1))+obj.zRegressor/norm(w));
    dpsi2 = -dpsi1;
    
    gradNonLinIneqCons = -[sum(bsxfun(@times,GM,dpsi1),1)',sum(bsxfun(@times,GM,dpsi2),1)'];
    
end

% 2) Equality constrains
nonLinEqCons = [];
gradNonLinEqCons = [];

end