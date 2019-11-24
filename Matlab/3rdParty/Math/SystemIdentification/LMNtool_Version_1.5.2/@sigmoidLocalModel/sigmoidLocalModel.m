classdef sigmoidLocalModel
    %% SIGMOIDLOCALMODEL is a class to construct local models based sigmoidal splitting functions.
    %
    %
    %   SIGMOIDLOCALMODEL properties:
    %       center                 - (1 x nz) Vector of the center coordinates (default: []).
    %       parameter              - (nx x q) Vector/matrix of local model parameters (default: []).
    %       localLossFunctionValue - (scalar) The local loss function value (default: []).
    %       parent                 - (scalar) Index of parent knot (default: []).
    %       children               - (1 x ?)  Indices of children knots (default: []).
    %       splittingParameter     - (nz+1 x 1) Parameter of the sigmoid (default: []).
    %       kappa                  - (scalar) Determines the steepness of the sigmoid transition area (default: []).
    %
    %
    %   See also calculatePsi.
    %
    %
    %   LMNtool - Local Model Network Toolbox
    %   Tobias Ebert, 24-April-2012
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles
    
    % 2013/01/17:   help updated
    % 2011/11/28:   help updated (TE)
    
    properties
        
        %CENTER - (1 x nz) Vector of the center coordinates (default: []).
        center      = [];
        
        %PARAMETER - (nx x q) Vector/matrix of local model parameters (default: []).
        parameter   = [];
        
        %localLossFunctionValue - (scalar) the local loss function value (default: []).
        localLossFunctionValue = [];
        
        %PARENT - (scalar) Index of parent knot (default: []).
        parent      = [];
        
        %CHILDREN - (1 x ?) Indices of children knots (default: []).
        children    = [];
        
        %splittingParameter - (nz+1 x 1) Parameter of the sigmoid (default: []).
        splittingParameter = [];
        
        %kappa - (scalar) Determines the steepness of the sigmoid transition area (default: []).
        kappa = [];
                
        %ACCURATENUMBEROFLMPARAMETERS - (1 x 1) Accurate number of parameters (with offset) for each local model
        %
        %   This property is a vector. Each entry decribes the number of
        %   allowed parameters for a local model. Hence the subset
        %   selection needs whole numbers this integere is rounded.
        %   parameters is used for the estimation.
        accurateNumberOfLMParameters = [];
        
    end
    
    methods
        % Constructor
        function obj = sigmoidLocalModel(parent, splittingParameter, center, parameter, kappa, accurateNumberOfLMParameters)
            if nargin>=1
                obj.parent = parent;
                if nargin>=2
                    obj.splittingParameter = splittingParameter;
                    if nargin>=3
                        obj.center = center;
                        if nargin>=4
                            obj.parameter = parameter;
                            if nargin>=5
                                obj.kappa = kappa;
                                if nargin>=6
                                    obj.accurateNumberOfLMParameters = accurateNumberOfLMParameters;
                                end
                            end
                        end
                    end
                end
            end
        end
        
        % SET and GET methods, to prevent errors later
        function obj = set.splittingParameter(obj,value)
            if isempty(value)
                obj.splittingParameter = value;
            else
                obj.splittingParameter = value/norm(value);
            end
        end
    end
    
    methods(Static) % static methods
        [idx,numberOfPoints] = getDataInLocalModel4nonlinearOpt(knotIdx,zRegressor,localModels);
        idx = getDataInValidSigmoidArea(v,zRegressor);
    end
    
end

