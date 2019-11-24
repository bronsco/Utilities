function obj = getXoutputDelay(obj)
% Get z-input-delay
if ~isempty(obj.output) % test if an input is given
    if ~isempty(obj.xOutputDelay)
        obj.xOutputDelay = obj.xOutputDelay; % use given delay
    else
        obj.xOutputDelay = num2cell(zeros(1,size(obj.input,2))); % use default delays
    end
else
    obj.xOutputDelay = [];
end
end % getXoutputDelay