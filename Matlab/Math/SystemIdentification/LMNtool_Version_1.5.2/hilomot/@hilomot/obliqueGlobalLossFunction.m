function [globalLossFunction, globalLossFunctionGradient, localModels, leafModels, phi, outputModel, forbiddenSplit, phiSimulated] = ...
    obliqueGlobalLossFunction(obj, wRed, w0, weightedOutputWorstLM,kappaIn,worstLM)
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
%       wRed                        - (nz x 1) Weigth vector for sigmoid direction.
%       w0                          - (1 x 1)  Sigmoid offset value. Kept constant during optimization.
%       xRegressor                  - (N x nx) Regression matrix for rule consequents (LM estimation).
%       zRegressor                  - (N x nz) Regression matrix for rule premises (Splitting).
%       output                      - (N x q)  Measured training data output.
%       outputModel                 - (N x q)  Current model output.
%       weightedOutputWorstLM       - (N x q)  Weighted model output of current worst LM that is splitted.
%       phiWorstLM                  - (N x 1)  Validity function values of the worst LM.
%       fixedKappa                  - (1 x 1)
%       demandedMembershipValue     - (1 x 1)
%       smoothness                  - (1 x 1)  Value for interpolation smoothness.
%       dataWeighting               - (N x 1)  Weighting of the data samples (optionally for LM estimation).
%       useCenteredLocalModels      - ()
%       data                        - ()
%       xRegressorExponentMatrix    - ()
%       relationZtoX                - ()
%       localModels                 - ()
%       leafModels                  - ()
%       worst LM                    - (1 x 1)  Index of the worst LM
%       kStepPrediction             - ()
%       xInputDelay                 - ()
%       zInputDelay                 - ()
%       xOutputDelay                - ()
%       zOutputDelay                - ()
%
%   OBLIQUEGLOBALLOSSFUNCTION outputs:
%
%       J              - (1 x 1)    Current global loss function value after splitting.
%       parameter      - (cell 1x2) New LM parameter values after splitting.
%       center         - (2 x nz)   New LM center values after splitting.
%       phi            - (N x 2)    Validity functions for the two newly generated LMs.
%       outputModelNew - (N x 1)    Model output including the two newly generated LMs.
%
%
%   See also estimateFirstLM, LMSplit, LMSplitOpt.
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Benjamin Hartmann, 10-January-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% Set flag and abort values
forbiddenSplit = false;

%% 1) Calculate the validity and initialize two new local model objects

% Combine the optimization parameters (wRed) with the constant part (w0)
w = [wRed; w0];

% initialize the new generated local models
localModels = [sigmoidLocalModel(worstLM,w,[],[],[],size(obj.xRegressor,2)), sigmoidLocalModel(worstLM,-w,[],[],[],size(obj.xRegressor,2))];

% calculate the validities of the local models
[phi, kappa, center, psi] = obj.calculatePhi(localModels, kappaIn);

% Check for sufficient amount of data samples.
if sum(phi(:,1)) - obj.pointsPerLMFactor * localModels(1).accurateNumberOfLMParameters < eps
    forbiddenSplit = true;
end
if sum(phi(:,2)) - obj.pointsPerLMFactor * localModels(2).accurateNumberOfLMParameters < eps
    forbiddenSplit = true;
end

% Update the local model objects
localModels(1).center = center(1,:);
localModels(1).kappa = kappa;
localModels(2).center = center(2,:);
localModels(2).kappa = kappa;

% Set worst local model on false and update indicies of the leaf models
leafModels = obj.leafModels;
leafModels(worstLM) = false;
leafModels = [leafModels true(1,2)];

% Check for sufficient amount of data samples. At least one point has to be
% contained geometrically.
[~,numberOfPoints] = localModels(1).getDataInLocalModel4nonlinearOpt(numel(obj.leafModels)+1,obj.zRegressor,[obj.localModels localModels]);
if numberOfPoints < 1
    forbiddenSplit = true;
end
[~,numberOfPoints] = localModels(1).getDataInLocalModel4nonlinearOpt(numel(obj.leafModels)+2,obj.zRegressor,[obj.localModels localModels]);
if numberOfPoints < 1
    forbiddenSplit = true;
end

%% 2) Estimate parameters and calculate the model output

% Estimate parameters of the LM
phiSimulated = [];
if obj.useCenteredLocalModels
    % calculate local x regressors
    xRegressorLocal{1} = data2xRegressor(obj,obj.input,obj.output,localModels(1).center);
    xRegressorLocal{2} = data2xRegressor(obj,obj.input,obj.output,localModels(2).center);
    % estimate the parameters of the two new local models
    localModels(1).parameter = estimateParametersLocal(obj,xRegressorLocal{1}, obj.output, phi(:,1), [], obj.dataWeighting);
    localModels(2).parameter = estimateParametersLocal(obj,xRegressorLocal{2}, obj.output, phi(:,2), [], obj.dataWeighting);
else
    xRegressorLocal = [];
    % estimate the parameters of the two new local models
    localModels(1).parameter = estimateParametersLocal(obj,obj.xRegressor, obj.output, phi(:,1), [], obj.dataWeighting);
    localModels(2).parameter = estimateParametersLocal(obj,obj.xRegressor, obj.output, phi(:,2), [], obj.dataWeighting);
end


%% 4) Calculate model output
[outputModel,phiAll,psiAll,xRegressor,zRegressor] = calculateModelOutputTrain(obj,localModels,phi,leafModels,weightedOutputWorstLM,xRegressorLocal);
if isinf(obj.kStepPrediction)
    phiSimulated = phiAll(:,leafModels);
end

%% 3) Calculate global loss function value (MSE), multiple outputs possible
globalLossFunction = calcGlobalLossFunction(obj, obj.output, outputModel);

%% 4) calculate Gradient

if nargout == 2
    % only calculate the gradient if necessary
    
    if obj.kStepPrediction <= 1
        GM = obj.phi(:,worstLM);
    else
        GM = phiAll(:,worstLM);
        psi = psiAll(:,end-1);
    end
    
    if obj.kStepPrediction > 1
        % used the dynamic x- and z-Regressor (already calculated)
        xRegressorLocal = {xRegressor};
    else
        % Used the global, static zRegressor
        zRegressor = obj.zRegressor;
        % For centered local models use their centered x regressors (already calcualted)
        if ~obj.useCenteredLocalModels
            % Use the global x regressor for both local models
            xRegressorLocal = {obj.xRegressor};
        end
    end
    
    globalLossFunctionGradient = obliqueGlobalLossFunctionGradient(obj, obj.output, outputModel, w, xRegressorLocal, zRegressor, localModels, psi, GM);
    
else
    globalLossFunctionGradient = [];
end


end