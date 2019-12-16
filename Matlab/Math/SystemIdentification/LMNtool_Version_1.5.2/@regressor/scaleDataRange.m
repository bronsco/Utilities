classdef scaleDataRange
    %% SCALEDATARANGE is a class for data scaling
    %
    %   scaleDataRange propeties:
    %
    %       method    - (String) Method how the data is scaled. Options are:
    %                              'unitVarianceScaling' (default)
    %                              'orthogonalScaling'
    %                              'boxcox_[value]' bsp boxcox_0.5
    %
    %       parameter - (Struct) Parameters of the data scaling method
    %                            (default: [])
    %
    %
    %   LMNtool - Local Model Network Toolbox
    %   Tobias Ebert, 24-April-2012
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles
    
    properties
        method = 'unitVarianceScaling' % data scaling method
        parameter = [];                % parameters of the data scaling method
    end
    
    methods
        % constructor
        function obj = scaleData(varargin)
            if nargin == 1
                obj.method = varargin{1};
            end
        end
    end
    
end

