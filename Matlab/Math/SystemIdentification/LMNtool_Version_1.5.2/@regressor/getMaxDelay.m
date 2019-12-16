
function maxDelay = getMaxDelay(obj)
% GETMAXDELAY returns the maximal Delay of the regressor object
%
%
%
%
% INPUT/OUTPUT:
%   obj:          object    LMN object containing all relevant net
%                           and data set information and variables.
%
%
% Local Model Toolbox, Version 1.0
% Julian Belz + Tobias Münker, 25-Oct-2016
% Institute of Measurement and Control, University of Siegen, Germany
% Copyright (c) 2016 by Oliver Nelles

% for static systems the xOutputDelay property is empty, while the
% xInputDelay properties is a cell array with zeros. Thus only nonempty
% components of the cell array are used for the outputs and the maximal
% delay is computed from the entries which are nonempty. 

    % in case of input selection also the xInputDelay properties can be
    % empty
    if(~all(cellfun(@isempty,obj.xInputDelay)))
        indexnonempty = not(cellfun(@isempty,obj.xInputDelay));
        maxInputDelayx = max(cellfun(@max,obj.xInputDelay(indexnonempty)));
    else
        maxInputDelayx = 0;
    end
    
    if(~all(cellfun(@isempty,obj.zInputDelay)))
        indexnonempty = not(cellfun(@isempty,obj.zInputDelay));
        maxInputDelayz = max(cellfun(@max,obj.zInputDelay(indexnonempty)));
    else
        maxInputDelayz = 0;
    end

    if(~all(cellfun(@isempty,obj.xOutputDelay)))
        indexnonempty = not(cellfun(@isempty,obj.xOutputDelay));
        maxOutputDelayx = max(cellfun(@max,obj.xOutputDelay(indexnonempty)));
    else
        maxOutputDelayx = 0;
    end
    
    if(~all(cellfun(@isempty,obj.zOutputDelay)))
        indexnonempty = not(cellfun(@isempty,obj.zOutputDelay));
        maxOutputDelayz = max(cellfun(@max,obj.zOutputDelay(indexnonempty)));
    else
        maxOutputDelayz = 0;
    end
    maxDelay = max([maxInputDelayx,maxInputDelayz, maxOutputDelayx,maxOutputDelayz]);
end