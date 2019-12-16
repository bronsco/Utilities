function worstLMIdx = findWorstLM(obj)
%% FINDWORSTLM finds the index of the worst performing local model.
%
%
%       [worstLMIdx] = findWorstLM(obj)
%
%
%   findWorstLM input:
%       obj        - (object) Local model object containing all relevant net
%                             and data set information and variables.
%
%   findWorstLM output:
%       worstLMIdx - (1 x 1) Index of the worst performing local model;
%                            highest local loss function value.
%
%
%   Nonlinear System Identification Toolbox
%   Torsten Fischer, 30-Januar-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% Find all leaf models that are not forbidden
idxAllowedLeafs = (obj.leafModels & obj.idxAllowedLM & obj.idxAllowedLMIter);

localLFV = [obj.localModels(idxAllowedLeafs).localLossFunctionValue];

% % % Check if no local loss function values are given
% % if isempty(localLFV)
% %     % Calculate each validity of the leaf models
% %     if isprop(obj,'phi') % for all algorithms that use sigmoids, e.g. HILOMOT etc.
% %         if ~isempty(obj.phi)
% %             % if there is no input given (only happens in training)
% %             validity = obj.phi(:,obj.leafModels);
% %         else
% %             % if there is no given phi, calculate it
% %             validity = obj.calculateValidity(zRegressor,obj.leafModels);
% %         end
% %         
% %     elseif isprop(obj,'MSFValue') % For all algorithms that use gaussians, e.g. LOLIMOT etc.
% %         if ~isempty(obj.MSFValue)
% %             % If there is no input given (only happens in training)
% %             [validity,~] = calculateValidity(obj,zRegressor,obj.leafModels,obj.MSFValue);
% %             
% %         else
% %             % If there is no given MSFs, calculate them
% %             [validity,~] = calculateValidity(obj,zRegressor,obj.leafModels);
% %         end
% %     else
% %         error('globalModel:findWorstLM','No local loss function value is given and the calculation failed because of an improper local model structure! Abort Training!')
% %     end
% %     
% %     % Indicies of the active models
% %     idxLeafModels = find(obj.leafModels);
% %     % Calculate the local loss function values for all leaf models
% %     localLossFunctionValue = calcLocalLossFunction(obj, obj.Output, obj.outputModel , validity, obj.dataWeighting, obj.outputWeighting);
% %     for k = 1:numel(idxLeafModels)
% %         % Allocate the right local loss function value to each local model
% %         obj.localModels(idxLeafModels(k)).localLossFunctionValue = localLossFunctionValue(k);
% %     end
% %     
% %     % Get all local loss function values (loop over all leafs that are allowed for further splitting)
% %     localLFV = [obj.localModels(idxAllowedLeafs).localLossFunctionValue];
% %     
% % end

% Find minimum
[~,index] = max(localLFV);

% Get the index of the model within the active models
realIdx = find(idxAllowedLeafs);
worstLMIdx = realIdx(index);

end

