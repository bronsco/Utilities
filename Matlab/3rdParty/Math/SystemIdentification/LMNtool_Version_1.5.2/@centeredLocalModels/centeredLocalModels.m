classdef centeredLocalModels
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        relationZtoX = [];              % 1 x n     Indicates which Regressor z- and x-space have in common
    end
    
    properties (SetAccess = protected)
        useCenteredLocalModels = false; % logical   activates the centering of local models, important for subset selection
    end
    
    methods
        
        function obj = set.useCenteredLocalModels(obj,value)
            if ~islogical(value)
                % check if logical yes/no
                error('globalModel:set:useCenteredLocalModels','Value must be logical, (true or false)!')
            else
                obj.useCenteredLocalModels = value;
            end
        end
        
    end
    
end

