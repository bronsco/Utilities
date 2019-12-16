classdef lossFunction
    %% LOSSFUNCTION is a class for loss function calculation.
    %
    %   Different types of loss function values can be calculated, such as the local, the global and a
    %   penalty loss function value. The penalty loss function can be used for approximation of the
    %   optimal tradeoff between bias and variance error, based only on the training data and without
    %   a separate validation data set and without the application of cross-validation mehtods. This
    %   can be used as a first insight for finding the optimal model complexity.
    %
    %
    % 	lossFunction properties:
    %
    %       lossFunctionGlobal - (string) Global lossfunction type. Options are (default: 'NRMSE'):
    %                                        'MSE'
    %                                        'RMSE' 
    %                                        'NMSE' 
    %                                       {'NRMSE'}
    %                                        'R2'
    %                                        'MAXERROR'
    %       lossFunctionLocal  - (string) Local lossfunction type. Options are (default: 'RSE'):
    %                                        'SE'
    %                                       {'RSE'}
    %                                        'DRSE'
    %                                        'MAXERROR'
    %       complexityPenalty  - (scalar) Complextiy penalty factor. Used for penalty loss function
    %                                     calculation (optional, default: 1)
    %       LOOCV              - (logical) If true (default), the leave-one-out cross validation
    %                                      error is approximated by using the smoothing matrix S.
    %       numberOfCVgroups   - (scalar)  Number of groups, if a k-fold cross validation has to be evaluated.
    %
    %
    %   See also calcGlobalLossFunction, calcLocalLossFunction, calcPenaltyLossFunction,
    %            calcLOOError, calcErrorbar, crossvalidation, WLSEstimate.
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
    %   LMNtool - Local Model Network Toolbox
    %   Benjamin Hartmann, 04-April-2012
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles
    
    % 16.11.11 help updated (TE) 
    % 13.12.11 Property lossFunctionPenalty removed and update for
    %          calcPenaltyLossFunction, B.Hartmann
    % 15.12.11 Added properties 'noiseVariance' and 'complexityPenalty'. Help updated, B.Hartmann
    % 16.03.12 Added properties 'crossvalidationValues'; Added static method 'crossvalidation' (JB)
    % 15.08.12 Removed property 'crossvalidationValues; Method 'crossvalidation' no longer a static method (JB)
    % 16.08.12 Added property: kFold (JB)
    % 09.02.15 Added property: usemvAIC (TM)
    % 07.06.16 Renamed property: usemvAIC --> correlatedOutputsAIC (JB)
    
    properties
        
        %LOSSFUNCTIONGLOBAL - (string) Global lossfunction type.
        %
        %   This proterty defines which type of loss function should be
        %   used to calculate the training data loss function. This is the
        %   critical value to minimise during the training. The possible
        %   global loss function typs are:
        %   'MSE','RMSE','NMSE','NRMSE','MISCLASS','R2' and 'MAXERROR'.
        %  	The default is 'NRMSE'.
        lossFunctionGlobal = 'NRMSE';
        
        %LOSSFUNCTIONLOCAL - (string) Local lossfunction type.
        %
        %   This proterty defines which type of loss function should be
        %   used to calculate the training data loss function for each
        %   local model individually. During the training the local model
        %   with the highest local loss function is splitted. The possible
        %   local loss function typs are:
        %   'SE','RSE','DRSE','MISCLASS' and 'MAXERROR'.
        %  	The default is 'RSE'.
        lossFunctionLocal  = 'RSE';
        
        %LOSSFUNCTIONTERMINATION -  (string) TERMINATION lossfunction type.
        %
        %   This property defines the type of termination criterion should
        %   be used to avoid overfitting by validation. The default is
        %   'penaltyLossFunction'.
        %
        %   'penaltyLossFunction': The algorithm uses the corrected AIC,
        %   normalize to the global loss function type.
        %
        %   'validationDataLossFunction': The algorithm uses the global
        %   loss function of validation data to abort the training
        %
        %   'AICc': If the user chooses 'AICc' the algorithm uses the
        %   corrected AIC (Akaikes Information Criterion) to stop the
        %   training.
        %
        %   'CVScore': The string 'CVScore' lets the algorithm use an
        %   approximated leave-one-out cross validation error, which is
        %   used to avoid the overfitting.
        %
        %   'simulationError': For dynamic models it is usefull to check
        %   the error between one-step-predictino and the simulated output.
        lossFunctionTermination = 'penaltyLossFunction';
        
        %COMPLEXITYPENALTY - (scalar) Complextiy penalty factor. Used for penalty loss function calculation.
        %
        %   This property defines the factor to punish the number of
        %   effective parameters during the calculation of the AICc. For
        %   more information please look up <Akaikes Information
        %   Criterion>.
        %   The default value is 1.        
        complexityPenalty  = 1;
        
        %LOOCV - (logical) The leave-one-out cross validation error is approximated by using the smoothing matrix S.
        %
        %   This logical property indicates if the leave-one-out cross
        %   validation error should be estimated by the using the
        %   smoothing matrix S. This needs to be done for each weighted
        %   Least-Squares estimation for all leaf models.
        %   The default is true.
        LOOCV              = true;
        
        %NUMBEROFCVGROUPS - (scalar)  Number of groups of a k-fold cross validation.
        %
        %   This property defines the number of groups the data shold be
        %   divided in for a k-fold cross validation. Here it is a 'real'
        %   cross-validation with a new training for each devision. 
        %   Attention: Do not mix with LOOCV (above)! That is only an
        %   approximation requiring less computation. The calculation of
        %   the cross validation error should be done after the training.
        %   The default is empty ([]).
        numberOfCVgroups   = [];
        
        %correlatedOutputsAIC - (logical) Use AIC for correlated outputs
        % 
        %  This property is set to 1, if the novel AIC method for multiple
        %  output systems described in Model Selection and Multimodel 
        %  inference - A Practical Information Theretic Approach by 
        %  Kennth P. Burnham and David R. Anderson, 2007 should be used. 
        %  As a default the mean NRMSE and the mean number of effective 
        %  parameters are used to calculate the information criterions
        correlatedOutputsAIC = 0;
    end
    

end

