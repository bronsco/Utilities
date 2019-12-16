classdef sigmoidGlobalModel < globalModel
    %% SIGMOIDGLOBALMODEL Superclass of hierarchically organized models like HILOMOT.
    %
    %   With SIGMOIDGLOBALMODEL the model structure is hierarchically organized, i.e. the validity
    %   functions are realized with sigmoidal splitting functions that are organized with a tree
    %   structure. Each leaf of the tree is a validity function and each knot is a splitting
    %   function. The validity functions are calculated by multiyplication of sigmoidal splitting
    %   functions along the tree path.
    %
    %
    %   SIGMOIDGLOBALMODEL properties:
    %       smoothness - (1 x 1) - Global model value that controls the interpolation smoothness.
    %       demandedMembershipValue - (1 x 1) - The demanded membership value of a specific training data point
    %
    %
    %   See also hilomot, globalModel, simulateParallel, addChildren, 
    %            calculateModelOutputCentered, calculateModelOutputQuick.
    %
    %
    %   LMNtool - Local Model Network Toolbox
    %   Tobias Ebert, 16-January-2013
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles
    
    properties
        %SMOOTHNESS - (1 x 1) - Global model value that controls the interpolation smoothness.
        smoothness = 1;
        
        % DEMANDEDMEMBERSHIPVALUE - (1 x 1) - The demanded membership value of a specific training data point
        demandedMembershipValue = 0.8;
        
    end

    
    methods(Static)
%         [kappa] = adjustKappa(zRegressor,demandedMembershipValue,...
%             kappaIni,w,localModels,idxModel,smoothness)
    end
    
    methods
        %% SET and GET
        function obj = set.smoothness(obj, value)
            if ~isscalar(value)
                error('sigmoidGlobalModel:set:smoothness','smoothness must be a scalar')
            end
            
            obj.smoothness = value;
            
        end
        
        
        function obj = set.demandedMembershipValue(obj,value)
            if isscalar(value)
                if value <= 0.5 || value >= 1
                    error('sigmoidGlobalModel:set:demandedMembershipValue','demandedMembershipValue has to be greater than 0.5 and smaller than 1.')
                end
            elseif ~isempty(value)
                error('sigmoidGlobalModel:set:demandedMembershipValue','demandedMembershipValue must be a scalar or empty.')
            end
            % Set passed value
            obj.demandedMembershipValue = value;
        end
        
    end
end

