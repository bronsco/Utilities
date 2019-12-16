function [normalizedAICc, normalizedBICc, numberOfAllParameters, CVScore, nEff, AICc, BICc] = calcPenaltyLossFunction(obj)
%% CALCPENALTYLOSSFUNCTION calculates the penalty loss function for the current LMN object. 
%
%   The model complexity is assessed with the corrected Akaike Information Criterion (AICc). By
%   default, the number of model parameters is approximated with the number of all consequents
%   regressors. If the flag LOOCV  is used, the number of effective parameters is calculated with
%   nEff = trace(S). Furthermore, if a nonlinear optimization of the sigmoid parameters is
%   performed, the amount of parameters is roughly considered with nz*(M-1). This penalizes the
%   higher model flexibility compared to only heuristically defined splitting.
%
%
%       [penaltyLossFunction, numberOfAllParameters, CVScore, nEff, AICc] = calcPenaltyLossFunction(obj)
%
%
% 	calcPenaltyLossFunction outputs:
%
%       penaltyLossFunction   - (1 x 1) Penalty loss function value (AICc is transformed
%                                       to global loss function type).
%       numberOfAllParameters - (1 x 1) Approximated sum of linear and nonlinear
%                                       parameters in the LMN as complexity measure.
%       CVScore:              - (1 x 1) Leave-one-out cross validation score (nonlinear
%                                       sigmoid parameter influences neglected).
%       nEff:                 - (1 x 1) Number of effective parameters. The degrees of
%                                       freedom for the weighted least squares estimation 
%                                       are considered with: nEff = trace(S).
%       AICc                  - (1 x 1) Value of corrected Akaike Information Criterion.
%
% 	calcPenaltyLossFunction inputs:
%
%       obj                     (object) Global model object containing all relevant
%                                        properties and methods
%
%
%   See also lossFunction, calcGlobalLossFunction, calcLocalLossFunction,
%            calcLOOError, calcErrorbar, crossvalidation, WLSEstimate.
%
%
%   LMNtool - Local Model Network Toolbox
%   Benjamin Hartmann, 04-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% 2015/02/17: Added BIC and renamed penalty loss function to normalizedAICc

% 2016/02/10: Münker / Added flag for the use of the multivariate AIC,
% default is now, that the mean AIC is used e.g. the mean value of the
% error and the number of parameters required to calculate one output in
% the AIC formula. 

% get maxDelay from obj
maxDelay = obj.getMaxDelay();

% Get number of z-regressors and the number of data samples
[N,nz] = size(obj.zRegressor);
ny = size(obj.output,2);

% Get number of local models
if any(strcmp('leafModels', properties(obj)))
    M  = sum(obj.leafModels);
else
    M = 1;
end

% Get the output model from the object
if any(strcmp('outputModel', properties(obj)))
    outputModel = obj.outputModel;
else
    error('lossFunction:calcPenaltyLossFunction','During the training the output model must be stored in the model object.')
end

%% Calculate the MSE value as an approximation of the noise variance for each output individually.
errorMSE = mean(bsxfun(@times,obj.dataWeighting(maxDelay+1:end,:),(obj.output(maxDelay+1:end,:)-outputModel).^2));

% Calculate the weighted error value, which will be used for the
% determinant for the AIC and BIC criterion calculation

dataWeighting = obj.dataWeighting * N / sum(obj.dataWeighting);
errorOfAllOutputs = bsxfun(@times,sqrt(dataWeighting(maxDelay+1:end,:)),(obj.output(maxDelay+1:end,:)-outputModel));


%% Determine the overall number of LM parameters (all parameter not equal to 0)
numberOfAllParameters = sum(sum(cell2mat({obj.localModels(obj.leafModels).parameter})~=0));
if obj.LOOCV
    % Perform a leave-one-out cross validation (only the linear parameters are newly estimated) 
    % and determine the effective number of parameters by calculation of trace(S).
    [CVScore, nEff]  = calcLOOError(obj);
else
    nEff = numberOfAllParameters;
    CVScore = [];
end

% Consider the contribution of the nonlinear sigmoid parameters heuristically
if(~obj.correlatedOutputsAIC)
    nEff = nEff/ny;  % use mean value of effective number of parameters
end
    nEffAIC = nEff+1; % One degree of freedom for variance estimation
if any(strcmp(superclasses(obj),'sigmoidGlobalModel'))
    if any(strcmp('oblique', properties(obj))) && obj.oblique % case hilomot with oblique splitting
        % # all parameters = # LM parameters + # nonlinear splitting parameters ( nz*(M-1) )
        numberOfAllParameters = numberOfAllParameters + nz*(M-1);
        nEffAIC = nEffAIC + nz*(M-1);
    end
end

%% Calculate AIC value. Only if the LOOCV flag is set the effective number of parameters is used
% [see e.g. C. LOADER: Local Regression and Likelihood (1999)]
% AIC = N*log(errorMSE) + 2     * nEffAIC*obj.complexityPenalty;
% BIC = N*log(errorMSE) + log(N)* nEffAIC*obj.complexityPenalty;
% AIC/BIC for multiple output depends also on the correlation of the errors
% [see Chapter 7.7.6 in  Burnham, Kenneth P and Anderson, David R: Model selection and multimodel inference: a practical information-theoretic approach (2002)]

if(obj.correlatedOutputsAIC)
    AIC = N*log(det(N\(errorOfAllOutputs'*errorOfAllOutputs)))+2* nEffAIC*obj.complexityPenalty + N*ny*(log(2*pi)+1);  
    BIC = N*log(det(N\(errorOfAllOutputs'*errorOfAllOutputs)))+log(N)* nEffAIC*obj.complexityPenalty;
else
    AIC = N*log(errorMSE)+2*nEffAIC*obj.complexityPenalty;
    BIC = N*log(errorMSE)+ log(N)*nEffAIC*obj.complexityPenalty;
end

% Use the corrected AIC (AICc) criterion. For large N AICc -> AIC. For small sample sizes (~N/nEff < 40) a bias-correction term is added to the standard
% AIC which leads to the AIC_corrected criterion [see  e.g. BURNHAM, ANDERSON: Model Selection and Multimodel Inference (2002)].
AICc = AIC + 2*nEffAIC*(nEffAIC+1)/(N-1-nEffAIC+eps);
BICc = BIC + 2*nEffAIC*(nEffAIC+1)/(N-1-nEffAIC+eps);
if nEffAIC > N-1
    AICc = inf(1,size(AICc,2));
    BICc = inf(1,size(AICc,2));
end

%% Normalize to global loss function type
if(obj.correlatedOutputsAIC)
    MSEequivalentAIC = exp((AICc-N*ny*(log(2*pi)+1))/N);
    MSEequivalentBIC = exp(BICc/N);
else
    MSEequivalentAIC = exp(AICc/N);
    MSEequivalentBIC = exp(BICc/N);
end    

if any(strcmp(obj.lossFunctionGlobal,{'MSE' 'RMSE' 'NMSE' 'NRMSE'}))
    criterion = obj.lossFunctionGlobal;
else
    criterion = 'NRMSE';
end

if(obj.correlatedOutputsAIC)
switch criterion
    
    case 'MSE'      % mean-squared-error
        normalizedAICc = MSEequivalentAIC;
        normalizedBICc = MSEequivalentBIC;
        
    case 'RMSE'     % root-mean-squared-error    
        normalizedAICc = sqrt(MSEequivalentAIC);
        normalizedBICc = sqrt(MSEequivalentBIC);
        
    case 'NMSE'     % normalized-mean-squared-error
        
        % In case of more than one output, the problem occurs, that the
        % equivalent MSE is just one single value. The errors of all
        % outputs are used in the determinant. Therefore all variances are
        % combined to one value. At first the covariance matrix is
        % calculated.
        covarianceMat = cov(obj.output(maxDelay+1:end,:));
        % The combined variance corresponds to the summation of all
        % covariance matrix elements. The equation for only two outputs
        % looks as follows:
        %
        % combinedVariance = var(out1) + var(out2) + 2*cov(out1,out2)
        %
        % In the covariance matrix the variances are placed on the
        % diagonal, all covariances exist twice (once above and below the
        % diagonal). Therefore summing up all elements yields the combined
        % variance.
        combinedVariance = sum(sum(covarianceMat));
        if combinedVariance == 0
            combinedVariance = eps;
        end
        
        % Divide the equivalent MSE by the overall variance
        normalizedAICc = MSEequivalentAIC/combinedVariance;
        normalizedBICc = MSEequivalentBIC/combinedVariance;
        
    case 'NRMSE'    % normalized-root-mean-squared-error
        
        % In case of more than one output, the problem occurs, that the
        % equivalent MSE is just one single value. The errors of all
        % outputs are used in the determinant. Therefore all variances are
        % combined to one value. At first the covariance matrix is
        % calculated.
        covarianceMat = cov(obj.output(maxDelay+1:end,:));
        % The combined variance corresponds to the summation of all
        % covariance matrix elements. The equation for only two outputs
        % looks as follows:
        %
        % combinedVariance = var(out1) + var(out2) + 2*cov(out1,out2)
        %
        % In the covariance matrix the variances are placed on the
        % diagonal, all covariances exist twice (once above and below the
        % diagonal). Therefore summing up all elements yields the combined
        % variance.
        combinedVariance = sum(sum(covarianceMat));
        if combinedVariance == 0
            combinedVariance = eps;
        end
        
        normalizedAICc = sqrt(MSEequivalentAIC/combinedVariance);
        normalizedBICc = sqrt(MSEequivalentBIC/combinedVariance);
        
%     otherwise
%         error('lossfunction:calcPenaltyLossFunction','This type of lossfunction is not implemented so far. Choose "MSE", "RMSE", "NMSE", "NRMSE" or "MAXERROR"!')
end
else
    switch criterion
    
    case 'MSE'      % mean-squared-error
        normalizedAICc = MSEequivalentAIC;
        normalizedBICc = MSEequivalentBIC;
        
    case 'RMSE'     % root-mean-squared-error
        normalizedAICc = sqrt(MSEequivalentAIC);
        normalizedBICc = sqrt(MSEequivalentBIC);
        
    case 'NMSE'     % normalized-mean-squared-error
        varOut = sum((bsxfun(@minus,obj.output(maxDelay+1:end,:),mean(obj.output(maxDelay+1:end,:)))).^2);
        varOut(varOut<eps) = eps;
        normalizedAICc = N*MSEequivalentAIC./varOut;
        normalizedBICc = N*MSEequivalentBIC./varOut;
        
    case 'NRMSE'    % normalized-root-mean-squared-error
        varOut = sum((bsxfun(@minus,obj.output(maxDelay+1:end,:),mean(obj.output(maxDelay+1:end,:)))).^2);  % not the true variance(!) variance*N
        varOut(varOut<eps) = eps;
        normalizedAICc = sqrt(N*MSEequivalentAIC./varOut);
        normalizedBICc = sqrt(N*MSEequivalentBIC./varOut);
        
%     otherwise
%         error('lossfunction:calcPenaltyLossFunction','This type of lossfunction is not implemented so far. Choose "MSE", "RMSE", "NMSE", "NRMSE" or "MAXERROR"!')
        
    end

%% multiple outputs
normalizedAICc = normalizedAICc * obj.outputWeighting;
normalizedBICc = normalizedBICc * obj.outputWeighting;
end




