function obj = getZoutputDelay(obj)
% Get z-input-delay
if ~isempty(obj.output) % test if an input is given
    if ~isempty(obj.zOutputDelay)
        obj.zOutputDelay = obj.zOutputDelay; % use given delay
    else
        obj.zOutputDelay = num2cell(zeros(1,size(obj.input,2))); % use default delays
    end
else
    obj.zOutputDelay = [];
end
end % getZoutputDelay