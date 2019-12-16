function obj = getZinputDelay(obj)
% Get z-input-delay
if ~isempty(obj.input) % test if an input is given
    if ~isempty(obj.zInputDelay)
        obj.zInputDelay = obj.zInputDelay; % use given delay
    else
        obj.zInputDelay = num2cell(zeros(1,size(obj.input,2))); % use default delays
    end
else
    obj.zInputDelay = [];
end
end % getZinputDelay