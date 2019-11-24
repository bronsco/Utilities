classdef gaussianOrthoLocalModel
    %% GAUSSIANORTHOLOCALMODEL is used for a local model with orthogonal gaussian functions.
    %
    %   This class generates a local model object with all relevant information for its orthogonal
    %   Gaussians. It delivers all local properties of the local models and the methods to calculate
    %   the membership function values and the centers und standard deviations of the Gaussians out
    %   of the corners.
    %
    %
    %   gaussianOrthoLocalModel properties:
    %         center                 - (G x nz) Center of the gaussian (default: []).
    %         lowerLeftCorner        - (G x nz) Lower left corner of the rectangle surrounding the
    %                                           gaussian (default: []).
    %         localLossFunctionValue - (1 x 1)  Local loss function value (default: []).
    %         standardDeviation      - (G x nz) Standard deviations of all gaussians (default: []).
    %         upperRightCorner       - (G x nz) Upper right corner of the rectangle surrounding the
    %                                           gaussian (default: []).
    %         parameter              - (nx x 1) Parameters of the local model (default: []).
    %         zLowerBound            - (1 x nz) Lower boundary of the training data (default: []).
    %         zUpperBound            - (1 x nz) Upper boundary of the training data (default: []).
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
    %       G:   Number of Gaussians
    %
    %
    %   LMNtool - Local Model Network Toolbox
    %   Tobias Ebert, 18-October-2011
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles
    
    
    properties
        
        %CENTER - (G x nz) Center of the gaussian.
        %
        %   This property stores the centers of each Gaussian, that
        %   are used to describe the validity area of the local model object.
        center = [];
        
        %lowerLeftCorner - (G x nz) Lower left corner of the rectangle surrounding the gaussian.
        %
        %   This property stores the lower left corners of each Gaussian, that
        %   are used to describe the validity area of the local model object.
        lowerLeftCorner = [];
        
        %localLossFunctionValue - (1 x 1) Local loss function value.
        %
        %   This property stores the value of the local loss function for this
        %   local model object. This is needed to find the worst performing
        %   local model.
        localLossFunctionValue = [];
        
        %standardDeviation - (G x nz) Standard deviations of all gaussians.
        %
        %   This property stores the standard deviations of each Gaussian, that
        %   is used to describe the validity area of the local model object.
        standardDeviation = [];
        
        %upperRightCorner - (G x nz) Upper right corner of the rectangle surrounding the gaussian.
        %
        %   This property stores the upper right corners of each Gaussian, that
        %   are used to describe the validity area of the local model object.
        upperRightCorner = [];
        
        %PARAMETER - (nx x 1) Parameter of the local model.
        %
        %   This property contains the parameter vector of the local model,
        %   which is used to calculate the local model output.
        parameter = [];
        
        %zLowerBound - (1 x nz) Lower boundary of the training data.
        %
        %   This property stores the lower boundary of the design space. This
        %   helps to avoid extrapolation in case of recalculating with another
        %   data set (instead the one used for training).
        zLowerBound = [];
        
        %zUpperBound - (1 x nz) Upper boundary of the training data.
        %
        %   This property stores the upper boundary of the design space. This
        %   helps to avoid extrapolation in case of recalculating with another
        %   data set (instead the one used for training).
        zUpperBound = [];      
        
        %ACCURATENUMBEROFLMPARAMETERS - (1 x 1) Accurate number of parameters (with offset) for each local model
        %
        %   This property is a vector. Each entry decribes the number of
        %   allowed parameters for a local model. Hence the subset
        %   selection needs whole numbers this integere is rounded.
        %   parameters is used for the estimation.
        accurateNumberOfLMParameters = [];
        
    end
    
    methods
        function obj = gaussianOrthoLocalModel(lowerLeftCorner,upperRightCorner,smoothness,accurateNumberOfLMParameters)
            % constructor of the class
            if nargin >= 2 && ~isempty(lowerLeftCorner) && ~isempty(upperRightCorner)
                if numel(lowerLeftCorner)~=numel(upperRightCorner)
                    disp(['number of lower left corners: ' num2str(size(lowerLeftCorner,1))])
                    disp(['number of upper right corners: ' num2str(size(upperRightCorner,1))])
                    warning('gaussianOrthoLocalModel:constructor','Number of lower left and upper right corners must be the same. Empty local model is generated!')
                else
                    % Update corners
                    obj.lowerLeftCorner = lowerLeftCorner;
                    obj.upperRightCorner = upperRightCorner;
                    if nargin >= 3
                        [obj.center, obj.standardDeviation] = obj.corner2Center(lowerLeftCorner,upperRightCorner,smoothness);
                    else
                        % default value for the smoothness is used
                        [obj.center, obj.standardDeviation] = obj.corner2Center(lowerLeftCorner,upperRightCorner);
                    end
                end
            end
            if nargin == 4
                obj.accurateNumberOfLMParameters = accurateNumberOfLMParameters;
            end
            %Otherwise generate an empty local model object
        end
        
    end
end
