classdef estimateLocalModels
    %% ESTIMATELOCALMODELS estimates the local model parameters.
    %
    %   ESTIMATELOCALMODELS consist of different methods for estimation of the local model parameters.
    %   The parameter can be estimated locally or globally. 
    % 
    %   In the case of LOCAL estimation the parameters of the local models (LMs) are estimated individually
    %   for each LM. The estimation is performed for only one single LM at a time. With the property
    %   estimationProcedure different estimation methods can be realized:
    % 
    %       'LS'                        - Ordinary weighted least squares estimation.
    %       'RIDGE'                     - Weighted LS estimation combined with ridge regression.
    %       'FORWARD_SELECTION'         - Forward selection with iterative t-test.
    %       'REDUCED_FORWARD_SELECTION' - Forward selection with a given initial set of regressors.
    %       'BACKWARD_ELIMINATION'      - Backward elimination.
    %       'OLS'                       - Forward selection using Orthogonal least squares.
    %
    %
    %   In the case of GLOBAL estimation the parameters of all local models are estimated globally
    %   with one single LS estimation. The following methods are implemented:
    %
    %       'LS'      - Global least squares estimation.
    %       'RIDGE'   - Global LS estimation, regularized with ridge regression.
    %       'GLOBLOC' - Global estimation that is regularized such that it results in locally
    %                   estimated parameters. But the estimation is performed in one single step.
    %
    %
    %   LMNBackwardElimination is a stand-alone method for performing backward elimination for all
    %   LMs separately.
    %
    %   For dynamic models, the methods estimateParametersGlobalIV and estimateParametersGlobalNOE can be
    %   applied.
    %   
    %
    %
    %   ESTIMATELOCALMODELS properties:
    %       estimationProcedure - (string) Precedure that is used for estimation (default: 'LS').
    %                                      See also comments in estimateParametersLocal
    %                                      and estimateParametersGlobal.
    %       lambda              - (scalar) Regularization parameter for ridge regression (default: []).
    %
    %
    %   See also estimateParametersLocal, estimateParametersGlobal, estimateParametersGlobalNOE,
    %            estimateParametersGlobalIV, LMNBackwardElimination, WLSEstimate,
    %            WLSForwardSelection, WLSBackwardElimination, findMinPRESSLambda,
    %            orthogonalLeastSquares.
    %
    %
    %   LMNtool - Local Model Network Toolbox
    %   Benjamin Hartmann, 16-January-2013
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles    
    

    
    properties
        
        %estimationProcedure - (string) Determines the estimation method (default: 'LS').
        estimationProcedure = 'LS';
        
        %LAMBDA - (scalar) Regularization parameter for ridge regression (default: []).
        %                  Can be used for applying ridge regression in the method WLSEstimate.
        %                  The estimation problem becomes: theta = inv(X'*X + lambda*I)*X'*y .
        lambda = [];
        
    end
    
    properties(Hidden=true)
        % Used for OLS estimation only.
        minErrorImprovement = 1e-3; 
        thresholdLinearDependency = 1e-5;
        % used for ridge regression
        lambdaDefault = 1e-8;
    end
    
    methods(Static)
        [theta, nEff, leverage, MSE, LOOE, PRESS, stdx, covTheta, errorbar, nEff2, S] = WLSEstimate(X_org, y_org, phi_org, lambda, X_new, alpha)
        [inmodel, theta] = WLSForwardSelection(XAll, y, phi, regsToSelect, inmodel)
        [theta, inmodel] = WLSBackwardElimination(XAll, y, phi, inmodel, keepcols)
        [PRESS] = findMinPRESSLambda(lambda,U,S,y)
        [selectedRegressors, errorImprovement, linearDependentRegressors] = orthogonalLeastSquares(xRegressorWeighted, outputWeighted, numberOfCoeff, minErrorImprovement, thresholdLinearDependency)
        [thetaWoBias, bias] = WGTLSEstimate(NoiseRegressor,NoiseFreeRegressor,validity,yNoisy);
    end
    
end
