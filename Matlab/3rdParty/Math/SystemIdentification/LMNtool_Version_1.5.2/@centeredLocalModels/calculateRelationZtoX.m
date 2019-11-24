function relationZtoX = calculateRelationZtoX(obj)

% If no delays are given, use the standard ones
% if isempty(obj.xInputDelay)
%     obj.xInputDelay = num2cell(zeros(1,size(obj.input,2)));
% end
% if isempty(obj.xOutputDelay)
%     obj.xOutputDelay = cell(1,size(obj.output,2));
% end
% if isempty(obj.zInputDelay)
%     obj.zInputDelay = num2cell(zeros(1,size(obj.input,2)));
% end
% if isempty(obj.zOutputDelay)
%     obj.zOutputDelay = cell(1,size(obj.output,2));
% end


% create a cell array for each input and output
relationZtoX = [];

% Get the regressor that x- and z-space have in common
% First the inputs delays
sizeZData = 0;

for idxInput = 1:length(obj.xInputDelay) % For-loop over every input dimensions
    % Get the x-delays for each input
    xInputDelay = obj.xInputDelay{idxInput};
    % Initialize the relationship matrix for each physical input
    relationZtoX_perDim = zeros(1,length(xInputDelay));
    for l = 1:length(xInputDelay) % For-loop over each delay in the x-space
        % True indicates if the z-regressor is the same as the x-regressor
        if any(xInputDelay(l) == obj.zInputDelay{idxInput})
            relationZtoX_perDim(l) = sizeZData + find(xInputDelay(l) == obj.zInputDelay{idxInput});
        end
    end
    % Update the cell array for each physical input
    relationZtoX = [relationZtoX relationZtoX_perDim];
    sizeZData = sizeZData + length(obj.zInputDelay{idxInput});
end
% Now the output delays
for idxOutput = 1:length(obj.xOutputDelay) % For-loop over all output dimensions
    xOutputDelay = obj.xOutputDelay{idxOutput}; % Get the z-delays for each output
    relationZtoX_perDim = zeros(1,length(xOutputDelay));
    for l = 1:length(xOutputDelay) % For-loop over each delay in the z-space
        if any(xOutputDelay(l) == obj.zOutputDelay{idxOutput})
            % Ture indicates if the z-regressor is the same as the x-regressor
            relationZtoX_perDim(l) = sizeZData + find(xOutputDelay(l) == obj.zOutputDelay{idxOutput});
        end
    end
    % Update the cell array for each physical output
    relationZtoX = [relationZtoX relationZtoX_perDim];
    sizeZData = sizeZData + length(obj.zOutputDelay{idxOutput});
end

end