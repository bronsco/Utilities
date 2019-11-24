classdef regressor
    %% REGRESSOR is used to build premises (z) and consequents (x) regressor matrices
    %
    %   This class adds the ability to build the regressors for rule consequents (x-regressors) and
    %   for rule premises (z-regressors) for the object. Therefore, it needs information about the
    %   input and output delays for the x- and z-Regressor and the type of the trail function for
    %   each regressor.
    %
    %
    %   REGRESSOR properties:
    %
    %       xRegressorDegree - (1 x 1) Highest order within the regressor for
    %                                  polynomials (default: 1).
    %
    %       xRegressorExponentMatrix - (nx x p) Exponent matrix for the
    %                                           regressors (default: []).
    %
    %       xRegressorType   - (string) Type of regressor; 'polynomial' or
    %                                   'sparsePolynomial' (default: 'polynomial').
    %
    %
    %   REGRESSOR properties for dynamic models:
    %
    %       xInputDelay   - {1 x p} Delays of the input regressors for rule
    %                               consequents (default: []).
    %
    %       xOutputDelay  - {1 x p} Delays of the output regressors for
    %                               rule consequents (default: []).
    %
    %       zInputDelay   - {1 x p} Delays of the input regressors for rule
    %                               premises (default: []).
    %
    %       zOutputDelay  - {1 x p} Delays of the input regressors for
    %                               rule premises (default: []).
    %
    %
    %   IMPORTANT NOTICE: If the delays are left empty ([]), they will be interpreted
    %                     as zeros ([0]) which equals a static model.
    %
    %
    %   SYMBOLS AND ABBREVIATIONS:
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
    %   EXPLANATIONS:
    %
    %       "xInputDelay"/"zInputDelay": Contains the delays of the input
    %       regressors for rule consequents/premises. One row of the cell
    %       arrays contains the delay for one physical input. For static
    %       systems (default), it is e.g. xInputDelay{i} = 0 for the i-th
    %       input. If dynamic systems are intended, xInputDelay{i} holds the
    %       delays in shape of whole numbers. Each whole number stands for n-th
    %       descrecte time step delays,e.g. zInputDelay{3} = [0 1 2] means that
    %       the thrid physical input should be delayed zero time steps, one
    %       time step and two time steps in the z-Regressor: zRegressor =
    %       [...,u3(k),u3(k-1),u3(k-2),...].
    %
    %       "xOutputDelay"/"zOutputDelay": Contains the delays of the output
    %       regressors for rule consequents/premises. One row of the cell
    %       arrays contains the delay for one physical output. For static
    %       systems (default), it is e.g. xOutputDelay{i} = [] for the i-th
    %       input. If dynamic systems are intended, xInputDelay{i} holds the
    %       delays in shape of whole numbers. Each whole number stands for n-th
    %       descrecte time step delays,e.g. zOutputDelay{2} = [1 2] means that
    %       the second physical output should be delayed one time step and two
    %       time steps in the z-Regressor: zRegressor =
    %       [...,y2(k-1),y2(k-2),...].
    %
    %       Important: If the delays are left empty ([]), they will be
    %       interpreted as zeros ([0]).
    %
    %       "xRegressorType"/"zRegressorType": Both are string arrays that
    %       define the type of trail function for the consequents/premises. For
    %       now, only polynomials are implemented. Other trail functions shall
    %       follow.
    %
    %       "xRegressorDegree"/"zRegressorDegree": Indicates witch degree for
    %       the polynomial should be used.
    %
    %       "xRegressorExponentMatrix"/"zRegressorExponentMatrix": Contains all
    %       Exponents for each polynomial term, depending on the degree of the
    %       polynomial and the number of physical inputs and outputs and their
    %       delays. If left empty, REGRESSOR will automatically generate an
    %       exponent matrix based on the information in regressorDegree and
    %       reressorType
    %
    %
    %   LMNtool - Local Model Network Toolbox
    %   Tobias Ebert, 24-April-2012
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles
    
    % 14.09.11 v0.1
    % 29.09.11 v0.2
    % 30.09.11 v0.3
    % 05.10.11 added SET methods to prevent errors
    % 08.11.11 xRegressorType is not hidden anymore
    % 16.11.11 rewrite help/doc
    % 21.01.13 help format update
    
    properties
        
        xRegressorDegree = 1;               % order of the polynomial within the regressor
        xRegressorMaxPower = inf;           % highest power within the regressor for polynomials
        xRegressorExponentMatrix   = [];    % exponent matrix for the regressors
        xRegressorType = 'polynomial';      % Type of regressor; 'polynomial' (default) or 'sparsePolynomial'
        xInputDelay = {};                   % Delays of the input regressors for rule consequents
        xOutputDelay = {};                  % Delays of the output regressors for rule consequents
        zInputDelay = {};                   % Delays of the input regressors for rule premises
        zOutputDelay = {};                  % Delays of the input regressors for rule premises
        zRegressorDisplacement = [];        % Shift of the z-regressor to prevent numerical problems in a split optimization
    end
    
    properties(Hidden=true) % Versteckt weil bisher nicht benutzt
        zRegressorType = 'polynomial';     % Type of regressor; default 'polynomial' for polynoms
        zRegressorDegree = 1;              % highest order within the regressor for polynomials
        zRegressorExponentMatrix   = [];   % exponent matrix for the regressors
        zRegressorMaxPower = inf;          % highest power within the regressor for polynomials
    end
    
    methods(Static) % static methods
        exponentMatrix = buildExponentMatrix(regressorType,regressorDegree,numInputs)
    end
    
    methods % SET and GET methods, to prevent errors later
        % SET Methods for the delays of the premise and consequent input space
        function obj = set.xInputDelay(obj,value)
            if ~iscell(value)
                error('regressor:set:xInputDelay','xInputDelay must be of type cell')
            end
            obj.xInputDelay = value;
        end
        function obj = set.xOutputDelay(obj,value)
            if ~iscell(value)
                error('regressor:set:xOutputDelay','xOutputDelay must be of type cell')
            end
            obj.xOutputDelay = value;
        end
        function obj = set.zInputDelay(obj,value)
            if ~iscell(value)
                error('regressor:set:zInputDelay','zInputDelay must be of type cell')
            end
            obj.zInputDelay = value;
        end
        function obj = set.zOutputDelay(obj,value)
            if ~iscell(value)
                error('regressor:set:zOutputDelay','zOutputDelay must be of type cell')
            end
            obj.zOutputDelay = value;
        end
        
        %% The delays are set in the initializeTrainin function!
        %         function delay = get.xInputDelay(obj)
        %             if isempty(obj.xInputDelay)
        %                 if isprop(obj,'input')
        %                     delay(1:size(obj.input,2)) = {0}; % use default delay
        %                 else
        %                     delay = [];
        %                 end
        %             else
        %                 delay = obj.xInputDelay;
        %             end
        %         end
        %         function delay = get.zInputDelay(obj)
        %             if isempty(obj.zInputDelay)
        %                 if isprop(obj,'input')
        %                     delay(1:size(obj.input,2)) = {0}; % use default delay
        %                 else
        %                     delay = [];
        %                 end
        %             else
        %                 delay = obj.zInputDelay;
        %             end
        %         end
        %         function delay = get.xOutputDelay(obj)
        %             if isempty(obj.xOutputDelay)
        %                 if isprop(obj,'output')
        %                     delay(1:size(obj.output,2)) = {[]}; % use default delay
        %                 else
        %                     delay = [];
        %                 end
        %             else
        %                 delay = obj.xOutputDelay;
        %             end
        %         end
        %         function delay = get.zOutputDelay(obj)
        %             if isempty(obj.zOutputDelay)
        %                 if isprop(obj,'output')
        %                     delay(1:size(obj.output,2)) = {[]}; % use default delay
        %                 else
        %                     delay = [];
        %                 end
        %             else
        %                 delay = obj.zOutputDelay;
        %             end
        %         end
    end
end
