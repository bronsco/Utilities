classdef terminationCriterions
    %% TERMINATIONCRITERIONS includes the termination criterions for
    % all LMN training algorithms.
    %
    %   These criterions are checked after each iteration of the corresponding training algorithm.
    %
    %
    %   terminationCriterions properties:
    %       maxNumberOfLM              - (scalar) Maximum number of LMs termination criterion. (default: inf)
    %       minError                   - (scalar) Loss function threshold termination criterion. (default: 0)
    %       maxNumberOfParameters      - (scalar) Maximum number of Parameter termination criterion. (default: inf)
    %       maxTrainTime               - (scalar) Maximum allowed time for the calculation. (default: inf)
    %       maxIterations              - (scalar) Maximum number of iterations termination criterion. (default: inf)
    %       maxValidationDeterioration - (scalar) Maximum number of deteriorations of the validation data or penalty loss function. (default: 2)
    %       minPerformanceImprovement  - (scalar) Minimum performance improvement of termination
    %                                             criterion. (default: 1e-12)
    %
    %
    %   SYMBOLS AND ABBREVIATIONS:
    %
    %       N:    Number of samples.
    %       q:    Number of outputs.
    %       nx:   Number of rule consequents.
    %       nz:   Number of rule premises.
    %       M:    Number of local models.
    %
    %
    %   LMNTool - Nonlinear System Identification Toolbox
    %   Tobias Ebert, 12-September-2012
    %   Institute of Mechanics & Automatic Control
    %   University of Siegen, Germany
    %   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles et. al.
    
    properties
                
        %maxNumberOfLM - (scalar) Maximum number of LMs termination criterion.
        %
        %   It is a constant describing the maximum number of local models
        %   during the training. Here linear local models. It is a termination
        %   criterion.
        maxNumberOfLM = inf;
        
        %minError - (scalar) Loss function threshold termination criterion.
        %
        %   It is a constant decribing the minimum error to be reached during
        %   the training. It is a termination criterion.
        minError = 0;
        
        %maxNumberOfParameters - (scalar) Maximum number of Parameter termination criterion.
        %   It is a constant describing the maximum number of parameter during
        %   the training. It is a termination criterion.
        maxNumberOfParameters = inf;
        
        %maxTrainTime - (scalar) Maximum allowed time for the calculation.
        %
        %   This scalar defines the time in minutes that the algorithm is
        %   allowed to use for training. It is a termination criterion.
        maxTrainTime = inf;
        
        %maxIterations - (scalar) Maximum number of iterations termination criterion.
        %
        %   This scalar defines the maximum number of iteration, that polymot
        %   is allowed to calculate during the training. It is a termination
        %   criterion.
        maxIterations = inf;
        
        %maxValidationDeterioration - (scalar) Maximum number of
        %   deteriorations of the validation data or penalty loss function.
        %
        %   This scalar defines the maximum number of deteriorations of the
        %   validation data or penalty loss function over its development.
        %   It is a termination criterion.
        maxValidationDeterioration = 2;
        
        %minPerformanceImprovement - (scalar) Minimum performance improvement of termination
        %                                     criterion.
        minPerformanceImprovement = 1e-12;
        
    end
    
    methods
        result = checkTerminationCriterions(LMNobj)
    end
    
    methods
        % SET and GET methods
        function obj = set.maxNumberOfLM(obj,value)
            % Check if the max number of LM is greater than one
            if value >= 1
                % Check if the value is a whole number
                if value - floor(value) > eps
                    warning('terminationCriterions:set:maxNumberOfLM','max number of local models must be a whole number! The given value is rounded down.')
                end
                obj.maxNumberOfLM = floor(value);
            else
                error('terminationCriterions:set:maxNumberOfLM','max number of local models must be at least one!')
            end
        end
        
        function obj = set.maxNumberOfParameters(obj,value)
            % Check if the max number of parameters is greater than zero
            if value > 0
                obj.maxNumberOfParameters = value;
            else
                error('terminationCriterions:set:maxNumberOfParameters','max number of parameters must be greater than zero!')
            end
        end
        
        function obj = set.maxTrainTime(obj,value)
            % Check if the max training time is greater than zero
            if value > 0
                obj.maxTrainTime = value;
            else
                error('terminationCriterions:set:maxTrainTime','max training time must be greater than zero!')
            end
        end
        
        function obj = set.minError(obj,value)
            % Check if the min error is greater than zero
            if value >= 0
                obj.minError = value;
            else
                error('terminationCriterions:set:minError','min training error must be at least zero!')
            end
        end
        
        function obj = set.maxIterations(obj,value)
            % Check if the max number of iterations is greater than one
            if value >= 1
                % Check if the value is a whole number
                if value - floor(value) > eps
                    warning('terminationCriterions:set:maxIterations','max number of iterations must be a whole number! The given value is rounded down.')
                end
                obj.maxIterations = floor(value);
            else
                error('terminationCriterions:set:maxIterations','max number of iterations must be at least one!')
            end
        end
        
        %         function obj = set.maxPenaltyDeterioration(obj,value)
        %             % Check if the max penalty deterioration is greater than one
        %             if value >= 1
        %                 % Check if the value is a whole number
        %                 if value - floor(value) > eps
        %                     warning('terminationCriterions:set:maxPenaltyDeterioration','max penalty deterioration must be a whole number! The given value is rounded down.')
        %                 end
        %                 obj.maxPenaltyDeterioration = floor(value);
        %             else
        %                 error('terminationCriterions:set:maxPenaltyDeterioration','max penalty deterioration must be at least one!')
        %             end
        %         end
        
        function obj = set.maxValidationDeterioration(obj,value)
            % Check if the max validation deterioration is greater than one
            if value >= 1
                % Check if the value is a whole number
                if value - floor(value) > eps
                    warning('terminationCriterions:set:maxValidationDeterioration','max validation deterioration must be a whole number! The given value is rounded down.')
                end
                obj.maxValidationDeterioration = floor(value);
            else
                error('terminationCriterions:set:maxValidationDeterioration','max validation deterioration must be at least one!')
            end
        end
        
        function obj = set.minPerformanceImprovement(obj,value)
            % Check if the min performance improvement is greater than zero
            if value >= 0
                obj.minPerformanceImprovement = value;
            else
                error('terminationCriterions:set:minError','min training error must be at least zero!')
            end
        end
        
    end
    
end

