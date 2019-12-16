classdef globalModel < regressor & lossFunction & estimateLocalModels & terminationCriterions & centeredLocalModels
    %% GLOBALMODEL Superclass to organize a global model.
    %
    %   With GLOBALMODEL both, parallel model classes like LOLIMOT and hierarchical model classes
    %   like HILOMOT can be treated equally. This improves the usability in terms of calculation of
    %   the global model output or e.g. the plotting of the global model.
    %
    %
    %   GLOBALMODEL properties:
    %       history           - (class) History class stores informations concerning the training algorithm.
    %       kStepPrediction   - (scalar) 0 or 1 for static model or one-step-predictor,
    %                                    inf for dynamic simulation (default: 0).
    %       leafModels        - (logical 1xM) true for active leaf models, false for inactive leaf models.
    %       idxAllowedLM      - (1 x M) Indicates, which local models are allowed for further splitting.
    %       idxAllowedLMIter  - (1 x M) Indicates, which local models are allwed to be splitted during the current itreration.
    %       localModels       - (cell 1xM) Cell array containing all local models objects.
    %       pointsPerLMFactor - (1 x 1) Factor to ensure a minimum amount of points in a LM (default: 1).
    %       outputModel       - (N x q)  Global model output (default: []).
    %       xRegressor        - (N x nx) Regression matrix/Regressors for rule
    %                                    consequents (default: []).
    %       zRegressor        - (N x nz) Regression matrix/Regressors for rule
    %                                    premises (default: []).
    %       suggestedNet      - (1 x 1) Suggested net with best performance/complexity trade-off
    %                                   according to corrected AIC (default: []).
    %
    %
    %   See also calculateModelOutput, calcYhat, plotLossFunction, plotModel, plotPartition,
    %            plotCorrelation, plotModelCentered.
    %
    %
    %   LMNtool - Local Model Network Toolbox
    %   Tobias Ebert, 16-January-2013
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles
    
    properties
        %HISTORY - (class) History class stores informations concerning the training algorithmn.
        %
        %       This property contains a history object, that stores all relevant
        %       information about the net structure and its evolution. Every
        %       iteration is kept inside this object.
        history = [];
        
        %kStepPrediction - (scalar) 0 or 1 for static model or one-step-predictor, inf for dynamic
        %                           calculation (default: 0).
        %
        %       This property differs between a static model, a dynamic model with
        %       one-step-ahead prediction or a dynamic model simulation. For the
        %       first two cases, a simple prediction is performed, because all
        %       relevant data is existent. To simulate the output model for
        %       each time step, each step has to be calculated
        %       separately.
        kStepPrediction = 0;
        
        %leafModels - (1 x M) Logical vector, true for active leaf models, false for inactive leaf
        %                     models.
        %
        %       This logical vector contains the information, which local models
        %       are the leaf one, i.e. they are the ones, that in super position
        %       result in the global model net.
        leafModels = [];
        
        %idxAllowedLM - (1 x M) Indicates, which local models are allowed for further splitting.
        %
        %       This logical vector contains the information, which local
        %       models are in general allowed to be split in further iterations.
        %       Models are finally forbidden, if its number of valid data
        %       samples is too low.
        idxAllowedLM = [];
        
        %idxAllowedLMIter - (1 x M) Indicates, which local models are allwed to be splitted during the current itreration.
        %
        %       This logical vector contains the information, which local
        %       models are in allowed to be split in the current iteration.
        %       Models are temporary forbidden, if all of its splits leads
        %       to no decrease of the global loss function.
        idxAllowedLMIter = [];
        
        %localModels - (1 x M) Cell array containing all local models objects.
        %
        %       This property contains all local model objects of the global model
        %       object. Each object stores all relevant infomation about the
        %       local model.
        localModels = [];
        
        %pointsPerLMFactor - (1 x 1) Factor to ensure a minimum amount of points in a LM (default: 1).
        %                            LMs that have less samples than pointsPerLMFactor*nx are not
        %                            allowed for further splitting.
        pointsPerLMFactor = 1;
        
        %outputModel - (N x q) Model outputs
        %
        %   This is the output model of the net object. It is updated in each
        %   iteration. With each additional local model, the training model
        %   will generate a lower error.
        outputModel = [];
        
        %xRegressor - (N x nx) Regression matrix/Regressors for rule consequents
        %
        %   This properties store the regression matrix for the rule
        %   consequents. This has a practical mean: Both only have
        %   to be calculated once during the training.
        xRegressor = [];
        
        %zRegressor - (N x nz) Regression matrix/Regressors for rule premises
        %
        %   This properties store the regression matrix for the rule
        %   premises. This has a practical mean: Both only have
        %   to be calculated once during the training.
        zRegressor = [];
        
    end
    
    properties(Dependent = true, SetAccess = private)
        %suggestedNet - (1 x 1) Suggested net with best performance/complexity trade-off
        %                       according to corrected AIC (default: []).
        suggestedNet
    end
    
    properties(Hidden = true)
        tested4NonUniqueData = false;
    end
    
    
    methods(Static,Hidden)
        outputModel = calcYhat(xRegressor,validityFunctionValue,parameter)
    end
    
    %% Constructor
    methods
        function GM = globalModel
            GM.history = modelHistory;
        end
    end
    
    %% SET and GET methods
    methods
        
        function obj = set.xRegressor(obj, value)
            if obj.useCenteredLocalModels && ~isempty(value)
                % error if centered local models are used
                error('globalModel:set:xRegressor','CENTERED local models are used. The use of an uncentered global xRegressor is realy, realy wrong!')
            else
                obj.xRegressor = value;
            end
        end
        
        function suggestedNet = get.suggestedNet(obj)
            % get method for suggestedNet calculates the best complexity for
            % the local model network
            if isempty(obj.history)
                % if there is no history, return empty answer
                suggestedNet = [];
            else
                % if the history is of type modelHistory then...
                [~, idxBest] = min(obj.history.terminationLossFunction);
                suggestedNet = idxBest;
            end
        end
        
        % Set method to check if the values for idxAllowedLM are correct
        function obj = set.idxAllowedLM(obj,value)
            % idxAllowedLM must be logical
            if islogical(value) || isempty(value)
                obj.idxAllowedLM = value;
            else
                error('globalModel:set:idxAllowedLM','Value must be logical!')
            end
        end
        
        % Set method to check if the values for idxAllowedLM are correct
        function obj = set.idxAllowedLMIter(obj,value)
            % idxAllowedLM must be logical
            if islogical(value) || isempty(value)
                obj.idxAllowedLMIter = value;
            else
                error('globalModel:set:idxAllowedLM','Value must be logical!')
            end
        end
        
        % set method leafModels
        function obj = set.leafModels(obj,value)
            if isempty(value)
                % If the passed value is empty, pass that value to the
                % property
                obj.leafModels = value;
                obj.outputModel = [];
            else
                % leafModels must be logical
                if islogical(value)
                    % leafModels must not be empty
                    if ~isempty(value)
                        obj.leafModels = value;
                        obj.outputModel = [];
                    else
                        error('globalModel:set:leafModels','Just deleting the local model structre is forbidden. It must be replaced by another local model structure!')
                    end
                else
                    error('globalModel:set:leafModels','Value must be logical!')
                end
            end
        end
        
        % set method outputModel
        function obj = set.outputModel(obj,value)
            if ~isempty(value) && size(obj.output,2) ~= size(value,2)
                error('globalModel:set:outputModel','Property outputModel does not match the measured output data!')
            else
                obj.outputModel = value;
            end
        end
    end
    
    
end

