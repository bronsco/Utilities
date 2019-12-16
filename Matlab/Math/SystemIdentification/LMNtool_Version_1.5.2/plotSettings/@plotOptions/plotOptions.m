classdef plotOptions
    %% PLOTOPTIONS This class provides standardized options for plotting Matlab figures.
    %
    %   This class is ment to create objects containing all information for
    %   the visualization of plots. The desired width and height of a figure
    %   can be specified.
    %
    %
    %       obj = plotOptions(width,height)
    %
    %
    % 	plotOptions properties:
    %
    %       fontsize   - (1 x 1)  Floating point number.
    %       fontname   - (String) Specifies the used font.
    %       width      - (1 x 1)  Desired width of the matlab figure in pixels.
    %       height     - (1 x 1)  Desired height of the matlab figure in pixels.
    %       lineSpec   - {1 x nf} nf different lineSpec objects
    %
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
    %       Nc:  Number of input combinations
    %       pf:  Number of fixed inputs
    %       nl:  Number of different lines
    %
    %
    %   EXPLANATIONS:
    %
    %       All standard values of the corresponding properties:
    %
    %           fontsize   = 12;
    %           fontname   = 'Times';
    %           width      = 600;
    %           height     = 400;
    %           lineSpec   = lineSpecObject;
    %
    %
    %   Julian Belz, 18th-Nov-2013
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles
    
    properties
        fontsize = 12;
        fontname = 'Times';
        width = 600;
        height = 400;
        differentLines = 1;
    end
    
    properties (Dependent = true, SetAccess = public)
        position    % The position property depends on the width and height properties
        lineSpec    % Different line specifications for a defined number contained in the property differentLines
    end
    
    properties (Hidden = true)
        savedLineSpec = lineSpec;
    end
    
    methods
        
        % Constructor
        function PO = plotOptions(width,height,varargin)
            
            % If there is more than 1 input, interprete the first two
            % inputs as the width and height of the figure
            if nargin > 1
                if ~isempty(width)
                    PO.width = width;
                end
                if ~isempty(height)
                    PO.height = height;
                end
            end
            
            % If there are more than two inputs, all other properties can
            % be set
            if nargin > 2
                idx = 1;
                
                % Loop over all passed inputs
                while idx <= nargin-2
                    
                    % If the current input is a string, compare to it to
                    % all possible properties and take idx+1 as value to
                    % set the corresponding property
                    if ischar(varargin{idx})
                        switch lower(varargin{idx})
                            case 'fontsize'
                                PO.fontsize = varargin{idx+1};
                            case 'fontname'
                                PO.fontname = varargin{idx+1};
                            case 'differentlines'
                                PO.differentLines = varargin{idx+1};
                        end
                        
                    end
                    
                    % Increase index
                    idx = idx + 1;
                    
                end
            end
            
        end
        
        % Determination of the figure position with respect to the desired
        % width and height. The values are calculated such that the figure
        % is centered.
        function senf = get.position(obj)
            scrsize = get(0,'screensize');
            senf = [(scrsize(3) - obj.width)/2 (scrsize(4) - obj.height)/2 ...
                obj.width obj.height];
        end
        
        % Generate a various number of lineSpec objects depending on the
        % property 'differentLines'
        function senf = get.lineSpec(obj)
            
            % Check if number of lineSpec-objects matches the number of
            % user demanded different line types
            if size(obj.savedLineSpec,2) == obj.differentLines
                senf = obj.savedLineSpec;
            else
                senf = obj.generateLineSpecObjects(obj.differentLines);
            end
            
        end % end get lineSpec
        
        function obj = set.lineSpec(obj,value)
            obj.savedLineSpec = value;
        end % end set lineSpec
        
    end
    
    methods(Static=true, Hidden=true)
        lineSpecObjects = generateLineSpecObjects(numberOfDifferentLines);
    end
    
    
end

