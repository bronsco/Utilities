function obj = initializeTraining(obj)
%% INITIALIZETRAINING initializes several parameters before training the first model
%
%
%       obj = initializeTraining(obj)
%
%
%   findWorstLM input:
%       obj        - (object) Local model object containing all relevant net
%                             and data set information and variables.
%
%   findWorstLM output:
%       obj        - (object) Local model object containing all relevant net
%                             and data set information and variables.
%
%
%   Nonlinear System Identification Toolbox
%   Tobias Ebert, 7-November-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% 
persistent flagStatisticsToolbox

% Check if the version testing has already be done (only when necessary)
if isempty(flagStatisticsToolbox)
    % Check if nonlinear split optimization is activated. In the case of
    % multiple trainings (for DoE or input selection) the buffering of the
    % flag as a persistent variable leads to a considerable performance
    % improvement.
    MatLabVersion = ver; % Get Version of all toolboxes
    % Check if the Optimization Toolbox in in the path
    if any(strcmp('Statistics Toolbox', {MatLabVersion.Name})) || any(strcmp('Statistics and Machine Learning Toolbox', {MatLabVersion.Name}))
        flagStatisticsToolbox = true; % Found
    else
        flagStatisticsToolbox = false; % Missing
    end
    clear MatLabVersion
end

% Check if the Optimization Toolbox is needed and available
if ~flagStatisticsToolbox
    % Give warning about the unavailable Optimization Toolbox
    warning('globalModel:initializeTraining','\nThe Statistics Toolbox is not installed. \n Therefore the required method <tinv>, <tcdf> and <ccdesign> for errorbar calculation, Backward- and Forward-Selection and DoEUpdate can not be used. \n If an error stops the algorithm, please check the terminated m-files.\n')
end


% check if input or output is empty
if isempty(obj.input)
    error('train:initializeTraining','Input is empty')
elseif isempty(obj.output)
    error('train:initializeTraining','Output is empty')
end

% set defaults delays on the assumption that the model is a static model
if isempty(obj.xInputDelay)
    if obj.history.displayMode; fprintf('xInputDelay is empty, defaults are used: xInputDelay(1:p) = {0}\n'); end
    obj.xInputDelay(1:size(obj.input,2)) = {0}; % use default delay
elseif all(cellfun(@isempty, obj.xInputDelay))
    % if all cells are empty
    warning('train:initializeTraining:xInputDelay','All cells in xInputDelay are empty, i.e. no physical input is regarded as an regressor')
end
if isempty(obj.zInputDelay)
    if obj.history.displayMode; fprintf('zInputDelay is empty, defaults are used: zInputDelay(1:p) = {0}\n'); end
    obj.zInputDelay(1:size(obj.input,2)) = {0}; % use default delay
elseif all(cellfun(@isempty, obj.zInputDelay))
    % if all cells are empty
    warning('train:initializeTraining:zInputDelay','All cells in zInputDelay are empty, i.e. no dimension is permited to be split.')
end
if isempty(obj.xOutputDelay)
    if obj.history.displayMode; fprintf('xOutputDelay is empty, defaults are used: xOutputDelay(1:p) = {[]}\n'); end
    obj.xOutputDelay(1:size(obj.output,2)) = {[]}; % use default delay
end
if isempty(obj.zOutputDelay)
    if obj.history.displayMode; fprintf('zOutputDelay is empty, defaults are used: zOutputDelay(1:p) = {[]}\n'); end
    obj.zOutputDelay(1:size(obj.output,2)) = {[]}; % use default delay
end



% check if dynamic model
if any([obj.xInputDelay{:}]>0) || ...
        any([obj.zInputDelay{:}]>0) || ...
        any([obj.xOutputDelay{:}]>0) || ...
        any([obj.zOutputDelay{:}]>0)
    % check if termination function is right
    if ~strcmp(obj.lossFunctionTermination,'simulationError') && ~isinf(obj.kStepPrediction)
        warning('globalModel:initializeTraining','It seems you train a dynamic model, you should use simulationError for lossFunctionTermination')
    end
else
    % check if validation data is present and training should be abortet with
    % respect to validation data
    if ~isempty(obj.validationInput) && ~strcmp(obj.lossFunctionTermination,'validationDataLossFunction')
        warning('globalModel:initializeTraining','You have validation data, you should use validationDataLossFunction for lossFunctionTermination')
    end
    
    % check for non unique data
    if ~obj.tested4NonUniqueData
        data = [obj.input, obj.output];
        uniqueData = unique(data,'rows');
        if size(data,1) > size(uniqueData,1)
            warning('train:initializeTraining','Data consists of non unique data points')
        end
        %         for k=1:size(data,1)
        %             if sum(all(bsxfun(@eq, data, data(k,:)),2)) > 1
        %                 warning('train:initializeTraining','Data consists of non unique data points')
        %             end
        %         end
        clear data uniqueData
        obj.tested4NonUniqueData = true;
    end
end


% set default output weighting
if isempty(obj.outputWeighting)
    obj.outputWeighting = ones(size(obj.output,2),1) ./ size(obj.output,2);
end


% If no dataWeighting is defined previously, all data points will be
% multiplied by one.
if isempty(obj.dataWeighting)
    obj.dataWeighting = ones(size(obj.input,1),1);
end


% If the info property already contains an dataSetInfo object, check if
% the number of inputs and the number of input descriptions are equal.
% Otherwise overwrite the existing descriptions with the standard
% description (u_1...u_p). Outputs analogous!
if ~isempty(obj.info.inputDescription) || ...
        size(obj.input,2) ~= size(obj.info.inputDescription,2)
    tmp                  = cell(1,size(obj.input,2));
    obj.info.inputDescription  = obj.fillDescription(tmp,'u');
end
if ~isempty(obj.info.outputDescription) || ...
        size(obj.output,2) ~= size(obj.info.outputDescription,2)
    tmp                  = cell(1,size(obj.output,2));
    obj.info.outputDescription = obj.fillDescription(tmp,'y');
end


if isempty(obj.info.numberOfInputs)
    obj.info.numberOfInputs = size(obj.input,2);
end

if isempty(obj.info.numberOfOutputs)
    obj.info.numberOfOutputs = size(obj.output,2);
end

% Check regressors for rule premises (z) and rule consequents (x)
% also save the exponent matrix for faster computation of model outputs
% when training is finished
if isempty(obj.zRegressor)
    obj.zRegressor = data2zRegressor(obj,obj.input,obj.output);
    
    if isempty(obj.zRegressorDisplacement)
        minzRegressor = min(obj.zRegressor);
        if any(minzRegressor < 0)
            obj.zRegressorDisplacement = zeros(1,size(obj.zRegressor,2));
            obj.zRegressorDisplacement(minzRegressor<0) = minzRegressor(minzRegressor<0);
            obj.zRegressor = bsxfun(@minus, obj.zRegressor, obj.zRegressorDisplacement);
        end
    end
    
end

if obj.useCenteredLocalModels
    % If centered local models are used, we need no global xRegressor, but
    % the information how X and Z is related
    obj.relationZtoX = obj.calculateRelationZtoX;
    [~, obj.xRegressorExponentMatrix] = data2xRegressor(obj,obj.input,obj.output);
elseif isempty(obj.xRegressor)
    [obj.xRegressor, obj.xRegressorExponentMatrix] = data2xRegressor(obj,obj.input,obj.output);
end

if any(strcmp('increasingNumberOfLMParameters', properties(obj))) && isempty(obj.increasingNumberOfLMParameters)
    % If plus-algorithms are used, use defalt number for increasing the
    % parameter (number of inputs).
    % For standard usage the LS-estimation is used.
    obj.increasingNumberOfLMParameters = size(obj.input,2) + 1;
end

% Check how AICc is calculated
if ~obj.LOOCV
    warning('globalModel:initializeTraining','AICc uses nominal (not effective) number of parameters.')
end

end