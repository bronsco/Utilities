classdef gaussianOrthoGlobalModel < globalModel
    %% GAUSSIANORTHOGLOBALMODEL class generates a global model consisting of orthogonal
    % Gaussians.
    %
    %   GAUSSIANORTHOGLOBALMODEL  delivers all global properties of the local
    %   models and the methods, that are needed to calculate the output model
    %   and to plot the model, the partition and the membership function
    %   values. Therefore some hidden methods are required, like the
    %   calcualtion of the validity function value or the parallel simulation
    %   for dynamic processes.
    %
    %
    %   gaussianOrthoGlobalModel properties:
    %
    %       smoothness - (1 x 1) Parameter for defining the global interpolation
    %                            behaviour of the Gaussians (a factor that
    %                            proportionally changes their standard deviation)
    %                            (default: 1).
    %
    %
    %   See also globalModel, gaussianOrthoLocalModel.
    %
    %
    %   LMNtool - Local Model Network Toolbox
    %   Tobias Ebert, 16-November-2011
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles
    
    % 18.11.11  help updated (TE)
    % 09.03.12  set and get method for the property 'smoothness' updated (JB) 
    
    properties
        
        %SMOOTHNESS - (1 x 1) Parameter for defining the global interpolation behaviour of the Gaussians 
        %                     (a factor that proportionally changes their standard deviation).
        %
        %   This property defines the global behaviour of all Gaussians. Its a
        %   factor that changes the steepness of the Gaussians over the whole
        %   global model object. Therefore its a 'fuddle'-parameter that can be
        %   choosen by the operator to get a more or less smooth sureface. The
        %   default value is set to '1', which in most instances leads to a
        %   sufficient solution.
        smoothness = 1;
        
    end

    methods
        %% Constructor
        function LM = gaussianOrthoGlobalModel
            
        end
        
        %% SET and GET methods, to prevent errors later
        function smoothness = get.smoothness(obj)
            smoothness  = obj.smoothness;
        end
        function obj = set.smoothness(obj,value)
            if isscalar(value)
                obj.smoothness = value;
                
%                 % check if there are existing local models
%                 if ~isempty(obj.localModels)
%                     % update standardDeviations of local models
%                     for localModel=1:size(obj.localModels,2)
%                         [obj.localModels(1,localModel).center,obj.localModels(1,localModel).standardDeviation] = ...
%                             obj.localModels(1,localModel).corner2Center(obj.localModels(1,localModel).lowerLeftCorner,obj.localModels(1,localModel).upperRightCorner,value);
%                     end
%                     
%                     % update MSFValues
%                     obj.MSFValue = arrayfun(@(loc) loc.calculateMSF(obj.zRegressor),obj.localModels,'UniformOutput',false);
%                     
%                     % update local model parameter
%                     localModel = 1;
%                     leafModelsTmp   = obj.leafModels;
%                     for iteration=1:size(obj.history.leafModelIter,2)
%                         % set number of iteration
%                         obj.leafModels = obj.history.leafModelIter{1,iteration};
%                         
%                         % get all active gaussians and normalize them
%                         validityFunctionValue = obj.calculateVFV(obj.MSFValue(obj.leafModels));
%                         
%                         % estimate parameters of the LM
%                         if localModel == 1
%                             % for the first iteration only one (global)
%                             % model exists
%                             obj.localModels(localModel).parameter = ...
%                                 estimateParametersLocal(obj,obj.xRegressor, obj.output, validityFunctionValue{end}, [], obj.dataWeighting);
%                             localModel = localModel + 1;
%                         else
%                             obj.localModels(localModel).parameter = ...
%                                 estimateParametersLocal(obj,obj.xRegressor, obj.output, validityFunctionValue{end-1}, [], obj.dataWeighting);
%                             localModel = localModel + 1;
%                             obj.localModels(localModel).parameter = ...
%                                 estimateParametersLocal(obj,obj.xRegressor, obj.output, validityFunctionValue{end}, [], obj.dataWeighting);
%                             localModel = localModel + 1;
%                         end
%                     end
%                     obj.leafModels = leafModelsTmp;
%                 end
                
            else
                error('localModel:set:smoothness','smoothness must be a scalar')
            end
            
        end
        
        %         function obj = set.leafModels(obj,value)
        %             if islogical(value)
        %                 obj.leafModels = value;
        %             else
        %                 error('localModel:set:leafModels','leafModels must be a logical array')
        %             end
        %         end
    end
    
    
end

