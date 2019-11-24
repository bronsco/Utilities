function globalLossFunctionGradient = obliqueGlobalLossFunctionGradient(obj, output, outputModel, w, xRegressorLocal, zRegressor, localModels, psi, GM, criterion)
%% CALCGLOBALLOSSFUNCTION calculates the global loss function for the net object.
%
%   With the optional input "criterion" it is possible to change the
%   error criterion. Therewith it is possible to calculate another error
%   value without changing the criterion which is stored in the net object.
%
%
%       globalLossFunction = calcGlobalLossFunction(obj, output, outputModel, dataWeighting,...
%               outputWeighting, criterion)
%
%
%   calcGlobalLossFunction output:
%
%       globalLossFunction: (1 x 1)   Global loss function value
%
%   calcGlobalLossFunction inputs:
%
%       obj                 (object)    global model object containing all relevant
%                                       net and data set information and variables
%
%       output:             (N x q)     Output matrix
%
%       outputModel:        (N x q)     Model output matrix
%
%       criterion:          (string)    global error criterion. If not given,
%                                       the one specified in the object will be
%                                       used
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
%   See also lossFunction, calcLocalLossFunction, calcLOOError, calcPenaltyLossFunction,
%            calcErrorbar, crossvalidation, WLSEstimate.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 08-May-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

psiComp = 1-psi;


maxDelay = obj.getMaxDelay();
output = output(maxDelay+1:end,:);

if nargin < 10
    % Used criterion of the lolimot object
    criterion = obj.lossFunctionGlobal;
end

% Calculate weighted squared error matrix
try
    errorWeighted = bsxfun(@times,obj.dataWeighting(maxDelay+1:end,:),(obj.output(maxDelay+1:end,:) - outputModel));
    errorWeightedQuad = sum(errorWeighted .* (obj.output(maxDelay+1:end,:) - outputModel));
catch
    keyboard
end

globalLossFunctionGradient = zeros(size(output,2),size(zRegressor,2));



switch obj.estimationProcedure
    case 'LS'
        % do nothing special
    case 'RIDGE' % see WLS estimate for further explanations
        nx = size(xRegressorLocal{1},2);
        % apply ridge regression
        offsetPenalty = false; % Should the offset be penalized in case of ridge regression? (default: false)
        
        lambda = obj.lambda;
        if isempty(lambda)
            lambda = obj.lambdaDefault;
        end
        penalty  = sqrt(lambda)*eye(nx);
        offset   = false(1,nx);
        if ~offsetPenalty
            offset   = all(xRegressorLocal{1}==1);        % Search for offset columns
        end
        penalty  = penalty(~offset,:);   % Offset should not be penalized
        for k = 1:length(xRegressorLocal)
            xRegressorLocal{k} = [xRegressorLocal{k}; penalty];
        end        
        output    = [output; zeros(sum(~offset),1)];
        psi      = [psi; ones(sum(~offset),1)];
        psiComp      = [psiComp; ones(sum(~offset),1)];
        GM      = [GM; ones(sum(~offset),1)];
        zRegressor = [zRegressor; zeros(sum(~offset),size(zRegressor,2))];
        errorWeighted = [errorWeighted; zeros(sum(~offset),size(output,2))];
        errorWeightedQuad = [errorWeightedQuad; zeros(sum(~offset),size(output,2))];
        
    otherwise
        %error('This estimationProcedure is not supported for oblique splitting')
end

for out = 1:size(output,2)
    
    
    yhat = [xRegressorLocal{1} * localModels(1).parameter(:,out), xRegressorLocal{end} * localModels(end).parameter(:,out)];
    
    %dpsi1 = bsxfun(@times, (psi-1).*psi*kappa/obj.smoothness, bsxfun(@times, -wNorm(1:end-1)'/(wNorm'*wNorm)^(3/2), wNorm(end)+obj.zRegressor*wNorm(1:end-1)) + obj.zRegressor/norm(wNorm));
    dpsi1 = bsxfun(@times, (psi-1).*psi*localModels(1).kappa/obj.smoothness, bsxfun(@times, -w(1:end-1)'/(w'*w)^(3/2), w(end)+zRegressor*w(1:end-1)) + zRegressor/norm(w));
    dpsi2 = -dpsi1; % this is much faster than to repeat an equal computation
    
    PM1X1 = bsxfun(@times, psi, xRegressorLocal{1});
    PM2X2 = bsxfun(@times, psiComp, xRegressorLocal{end});
    X1TGM = bsxfun(@times, xRegressorLocal{1}, GM)';
    X2TGM = bsxfun(@times, xRegressorLocal{end}, GM)';
    
    sum1 =  PM1X1 * (pinv(X1TGM * PM1X1) * (X1TGM * bsxfun(@times, dpsi1, output(:,out)-yhat(:,1))));% + ...
    sum2 =  PM2X2 * (pinv(X2TGM * PM2X2) * (X2TGM * bsxfun(@times, dpsi2, output(:,out)-yhat(:,2))));
    sum3 = bsxfun(@times, dpsi1, yhat(:,1)); % partial derivative of the validity function
    sum4 = bsxfun(@times, dpsi2, yhat(:,2));
    
    gradErrorHelp = -bsxfun(@times, GM, (sum1+sum2+sum3+sum4) );
    
    switch criterion
        case 'MSE' % mean-squared-error
            globalLossFunctionGradient(out,:) = 2/size(outputModel,1) * errorWeighted(:,out)' * gradErrorHelp;
            
        case 'RMSE' % root-mean-squared-error
            globalLossFunctionGradient(out,:) = 1/sqrt(size(outputModel,1) * errorWeightedQuad(out)) * errorWeighted(:,out)' * gradErrorHelp;
            
        case 'NMSE' % normalized-mean-squared-error
            varOut = sum((bsxfun(@minus,output(:,out),mean(output(:,out)))).^2);
            varOut(varOut<eps) = eps;
            globalLossFunctionGradient(out,:) = 2/(varOut) * errorWeighted(:,out)' * gradErrorHelp;
            
        case 'NRMSE' % normalized-root-mean-squared-error
            varOut = sum((bsxfun(@minus,output(:,out),mean(output(:,out)))).^2);
            varOut(varOut<eps) = eps;
            globalLossFunctionGradient(out,:) = 1/sqrt(varOut * errorWeightedQuad(out)) * errorWeighted(:,out)' * gradErrorHelp;
            
            % R2 can be calculated by R2 = 1 - NMSE. Redundant information,
            % only calculate the outside the training procedure.
            % %         case 'R2'
            % %             varOut = sum((bsxfun(@minus,output(:,out),mean(output(:,out)))).^2);
            % %             varOut(varOut<eps) = eps;
            % %             globalLossFunctionGradient(out,:) = -2/(varOut) * errorWeighted(:,out)' * gradErrorHelp;
            
        otherwise
            
            error('hilomot:obliqueGlobalLossFunction','Calculation of the gradient is only supported for lossfunction "MSE", "RMSE", "NMSE" or "NRMSE"!');
    end
    
end

globalLossFunctionGradient = obj.outputWeighting' * globalLossFunctionGradient;
