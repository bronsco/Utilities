classdef modelHistory
    %% MODELHISTORY creates a history object containing all relevant
    % information about every iteration step.
    %
    %   This super-class adds the ability to the sub-classes to store all
    %   necessary properties in terms of history. Therefore it updates in
    %   each iteration its properties by the loss function values, the split
    %   characteristics and the leaf models, i.e. in each iteration the size
    %   of the properties changes.
    %
    %   LMNtool - Local Model Network Toolbox
    %   Torsten Fischer, 18-November-2011
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles
    
    % Changelog:
    % - Added "kFoldCVlossFunction", 16-August-2012, B. Julian
    % - Added "akaikeWeights" as a dependent property and the static method
    % - "calcAkaikeWeights", 29-Nov-2012, B. Julian
    % - Complete Revision of the help files.
    % - Added "terminationLossFunction" as the used valdiation criterion to
    %   abort training, 19-September-2013 T.Fischer
    
    properties
        
        %CURRENTNUMBEROFPARAMETERS - (1 x iter) Current number of parameters.
        %
        %   This property stores the current number of parameters for each
        %   iteration, so that a good idea of the model complexity is given.
        currentNumberOfParameters = [];
        
        %CURRENTNUMBEROFEFFPARAMETERS - (1 x iter)  Effective number of model parameters for each iteration
        %
        %   This property stores the current number of effective parameters
        %   for each iteration, so that a good idea of the model complexity
        %   is given.
        currentNumberOfEffParameters = [];
        
        %CURRENTACCURATENUMBEROFPARAMETERS - (1 x iter) Accurate number of model parameters for each iteration
        %
        %   This property stores the current accurate number of parameters
        %   for each iteration, so that a good idea of the model complexity
        %   is given.
        currentAccurateNumberOfParameters = [];
        
        %CURRENTNUMBEROFLMS - (1 x iter)    Overall number of models for each iteration
        %
        %   This property stores the current number of local models for
        %   each iteration, so that a good idea of the model complexity is
        %   given.
        currentNumberOfLMs  = [];
        
        %GLOBALLOSSFUNCTION - (1 x iter)    Training loss function values for the overall model
        %
        %   This property stores for each iteration the global loss
        %   function value, so it is possible to review the progression of
        %   the global error.
        globalLossFunction  = [];
        
        %TERMINATIONLOSSFUNCTION - (1 x iter)   Validation loss function values for the overall model
        %
        %   This property stores for each iteration the validation loss
        %   function value, so it is possible to review the progression of
        %   the validation error. This property stores either the
        %   validation data loss function, the AICc value or the leave one
        %   out cross validation depending which one should be used for
        %   validation.
        terminationLossFunction = [];
        
        %PENALTYLOSSFUNCTION - {1 x iter}   Complexity penalized loss function values
        %
        %   This property stores for each iteration the penalty loss
        %   function values for each output, so it is possible to review the progression of
        %   the penalty error.
        penaltyLossFunction = [];
        
        %normlaizedBICc - {1 x iter}   Complexity penalized loss function values
        %
        %   This property stores for each iteration the normlaized BICc
        %   loss function values for each output, so it is possible to
        %   review the progression of the normlaized BIC error.
        normalizedBICc = [];
        
        %SIMULATIONLOSSFUNCTION - {1 x iter}   simulation output loss function values
        %
        %   This property stores for each iteration the simulation loss
        %   function values for each output, so it is possible to review the progression of
        %   the error between training data and simulated output for dynamic systems.
        simulationLossFunction = [];
        
        %SIMULATIONLOSSFUNCTIONVALIDATIONDATA - {1 x iter}   simulation output validation data loss function values
        %
        %   This property stores for each iteration the simulation loss
        %   function values for each output, so it is possible to review the progression of
        %   the error between validation data and simulated output for dynamic systems.
        simulationLossFunctionValidationData = [];
        
        %SIMULATIONLOSSFUNCTIONTestData - {1 x iter}   simulation output test data loss function values
        %
        %   This property stores for each iteration the simulation loss
        %   function values for each output, so it is possible to review the progression of
        %   the error between test data and simulated output for dynamic systems.
        simulationLossFunctionTestData = [];
        
        %AICc - (1 x iter)  Corrected Akaike Information Criterion (AICc) for each iteration.
        %
        %   This property stores the corrected Akaike Information Criterion
        %   (AIC) after [see  e.g. BURNHAM, ANDERSON: Model Selection and
        %   Multimodel Inference (2002)]. For large N the AICc becomes
        %   nearly the standard AIC. For small sample sizes (~N/nEff < 40)
        %   a bias-correction term is added to the standard AIC which leads
        %   to the AIC_corrected criterion.
        AICc = {};
        
        %BICc - (1 x iter)  Corrected  BICc for each iteration.
        %
        %   This property stores the corrected BIC after [see  e.g.
        %   BURNHAM, ANDERSON: Model Selection and Multimodel Inference
        %   (2002)]. For large N the BICc becomes nearly the standard BIC.
        %   For small sample sizes (~N/nEff < 40) a bias-correction term is
        %   added to the standard AIC which leads to the AIC_corrected
        %   criterion.
        BICc = {};
        
        %CVLOAAFUNCTION - {1 x iter}    Leave-one-out cross validation scores.
        %
        %   This property stores the leave-one-out cross validation error.
        %   Therfore the leave-one-out cross validation for each output
        %   over all local models is estimated using the smoothing matrix
        %   S. Attention: This is only an approximation of the
        %   leave-one-out cross validation.
        CVLossFunction = {};
        
        %SPLITLM - (iter-1 x 1) History of LMs which are split
        %
        %   This property stores for each iteration the local model object,
        %   which was splitted.
        splitLM = [];
        
        %SPLITDIMENSION - (iter-1 x 1)  History of dimensions of the split.
        %
        %   This property stores for each iteration the dimension of the
        %   split done in the premises space.
        splitDimension = [];
        
        %SPLITRATIO - (iter-1 x 1)  History of ratio of the split.
        %
        %   This property stores for each iteration the ratio of the split
        %   done in the premises space.
        splitRatio = [];
        
        %LEAFMODELITER - (1 x iter) History of the active models per iteration.
        %
        %   This property stores in each iteration the index vector that
        %   specifies the leaf models, so its possible to use a net with
        %   lower complexity if the penalty error is too high.
        leafModelIter = {};
        
        %LEAFMODELITER - (1 x iter) History of the splittable models per iteration.
        %
        %   This property stores in each iteration the index vector that
        %   specifies the splittable models, so its possible to use a net with
        %   lower complexity if the penalty error is too high.
        idxAllowedLMIter = {};
        
        
        %TRAININGTIME - % (1 x iter)    Overall Training time up to this iteration.
        %
        %   This property stores the absolute time form the begining of the
        %   training untill the current training iteration is finished.
        trainingTime  = [];
        
        %DISPLAYMODE - (logical)    Flag to de-/activate printouts to the command window during training.
        %
        %   This property is a flag that activates und deactivates
        %   printouts to the command window during the training. If the
        %   user is not interested in such information, printouts should be
        %   deactivated to have a better performance.
        displayMode = true;
        
        %ITERATION - (1 x 1)    Stores the number of the used iteration.
        %
        %   This property stores the current iteration during the training,
        %   so that every other property of the MODELHISTORY class can be
        %   related to it.
        iteration = zeros(1,1);
        
        %VALIDATIONDATALOSSFUNCTION - (1 x iter)    Validation data loss function values for the overall model.
        %
        %   This property stores for the current iteration the vailidation
        %   data loss function, if validation data is given.
        validationDataLossFunction  = [];
        
        %TESTDATALOSSFUNCTION - (1 x iter)  Test data loss function values for the overall model.
        %
        %   This property stores the test data loss function for the
        %   current iteration, if test data is given.
        testDataLossFunction        = [];
        
        %KFOLDCVLOSSFUNCTION - k-fold cross validation RMSE-value
        %
        %   This property stores the k-fold cross validation error. Here
        %   it is the 'real' cross validation error. For each of the k-th
        %   devision a new training procedure is started. Due to the
        %   computational effort of this approach, the calculation is only
        %   considered after the actual training phase.
        kFoldCVLossFunction = [];
        
        %GLOBALLOSSFUNCTIONUNSCALED - (1 x iter)    Loss function values for the overall model.
        %
        %   This property stores for each iteration the global loss
        %   function value of the unscaled output and unscaled output
        %   model, so it is possible to review the progression of the
        %   global error.
        globalLossFunctionUnscaled  = [];
        
        %TERMINATIONLOSSFUNCTIONUNSCALED - (1 x iter)   Complexity penalized loss function values.
        %
        %   This property stores for each iteration the validation loss
        %   function value of the unscaled output and the unscaled output
        %   model, so it is possible to review the progression of the
        %   validation error. This property stores either the validation
        %   data loss function, the AICc value or the leave one out cross
        %   validation depending which one should be used for validation.
        terminationLossFunctionUnscaled = [];
        
        %VALIDATIONDATALOSSFUNCTIONUNSCALED - (1 x iter)    Validation data loss function values for the overall model.
        %
        %   This property stores for the current iteration the vailidation
        %   data loss function of the unscaled output and the unscaled
        %   output model, if a validation data set is given.
        validationDataLossFunctionUnscaled  = [];
        
        %TESTDATALOSSFUNCTIONUNSCALED - (1 x iter)  Test data loss function values for the overall model.
        %
        %   This property stores for the current iteration the test data
        %   loss function of the unscaled output and the unscaled output
        %   model, if a test data set is given.
        testDataLossFunctionUnscaled        = [];
    end
    
    properties (Hidden = true)
        
        %TRAININGSTARTTIC - (1 X 1) Starting time of the training.
        %
        %   This property stores the starting time of the training.
        trainingStartTic = [];
    end
    
    properties (SetAccess = private, GetAccess = public)
        
        %AKAIKEWEIGHTS - (1 x iter) Akaike weight for each iteration/model (with different complexity).
        %
        %   HERE EXPLANATION!
        akaikeWeights       = [];          %
        
    end
    
    methods (Static=true)
        akaikeWeights = calcAkaikeWeights(aicValues);
    end
    
    %% Set and get methods
    methods
        
        % Set method for the display mode
        function obj = set.displayMode(obj,value)
            % Check if the value is logical
            if islogical(value)
                obj.displayMode = value;
            else
                warning('modelHistory:set:displayMode','Try to set <displayMode> to a nonlogical value! Default value is used.')
            end
        end
        
        
        % Get method for the akaike weights.
        function akaikeWeights = get.akaikeWeights(obj)
            % The Akaike weights can only be calculated, if the property
            % AICc is not empty
            if isempty(obj.AICc)
                akaikeWeights = [];
                % Unnecessary explanation...
                % fprintf('\n Because there are no AICc values, no Akaike weights can be calculated.\n \n');
            else
                akaikeWeights = obj.calcAkaikeWeights(obj.AICc);
            end
            
        end
        
    end
    
end

