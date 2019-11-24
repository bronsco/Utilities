function obj = getXinputDelay(obj)
% Get z-input-delay
if ~isempty(obj.input) % test if an input is given
    if ~isempty(obj.xInputDelay)
        obj.xInputDelay = obj.xInputDelay; % use given delay
    else
        obj.xInputDelay = num2cell(zeros(1,size(obj.input,2))); % use default delays
    end
else
    obj.xInputDelay = [];
end
end % getXinputDelay