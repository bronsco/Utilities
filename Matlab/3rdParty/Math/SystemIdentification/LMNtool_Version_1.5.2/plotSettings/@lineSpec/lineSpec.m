classdef lineSpec
    %% PLOTOPTIONS This class provides standardized options for plotting Matlab figures.
    %
    %   This class is ment to create objects containing all information for
    %   the visualization of plots. The desired width and height of a figure
    %   can be specified.
    %
    %
    %       obj = lineSpec(width,height)
    %
    %
    % 	plotOptions properties:
    %
    %       linewidth  - (nl x 1) Floating point number.
    %       markersize - (1 x 1)  Floating point number.
    %       marker     - (String) Specifies the used marker.
    %       color      - (1 x 3)  R-G-B percentages, that define a color.
    %       linestyle  - (String) Linestyle for the line.
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
    %           color      = [0 0 1]; --> blue
    %           linewidth  = 2;
    %           markersize = 12;
    %           marker     = 'x';
    %           linestyle  = '-';
    %
    %
    %   Julian Belz, 18th-Nov-2014
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2014 by Prof. Dr.-Ing. Oliver Nelles
    
    properties
        linewidth = 2;
        markersize = 12;
        marker = 'x';
        color = [0 0 1];
        linestyle = '-';
    end
    
    
    methods
        
        % Constructor
        function PO = lineSpec(varargin)
            if nargin > 0
                idx = 1;
                
                % Loop over all passed inputs
                while idx <= nargin
                    
                    % If the current input is a string, compare to it to
                    % all possible properties and take idx+1 as value to
                    % set the corresponding property
                    if ischar(varargin{idx})
                        switch lower(varargin{idx})
                            case 'color'
                                PO.color = varargin{idx+1};
                            case 'linewidth'
                                PO.linewidth = varargin{idx+1};
                            case 'marker'
                                PO.marker = varargin{idx+1};
                            case 'markersize'
                                PO.markersize = varargin{idx+1};
                            case 'linestyle'
                                PO.linestyle = varargin{idx+1};
                        end
                        
                    end
                    
                    % Increase index
                    idx = idx + 1;
                    
                end
            end
        end % end constructor
        
    end
    
end

