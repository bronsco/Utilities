function [idx,numberOfPoints] = getDataInLocalModel4nonlinearOpt(knotIdx,zRegressor,localModels)
% This function determines indices of the training data, that lay in one
% local model. Additionally the number of points is calculated.
% For which local models the outputs are calculated is defined by the knotIdx
% variable.
% Because this function is needed within the nonlinear split optimization,
% it is defined as static, such that no large class objects have to be
% passed. This should result in a better performance.
%
% [idx,numberOfPoints] = getDataInLocalModel4nonlinearOpt(knotIdx,zRegressor,localModels)
%
%
% INPUTS
%
%
% knotIdx:      [1 x nd] Indices of knots within the localModels variable.
%
% zRegressor:   [N x nz] zRegressor.
%
% localModels:  [1 x nk] All sigmoidLocalModel objects, that already exist
%                        in the corresponding local model network.
%
%
% OUTPUTS
%
%
% idx:          [N x nd] Logicals, that indicate which data points from the
%                        training data set lay in a local model. Every
%                        column in idx belongs to the corresponding knot
%                        index in the knotIdx vector.
%
% numberOfPoints: [1 x nd] Contains the number of points that belong to the
%                          corresponding local model indexed in the knotIdx
%                          vector.
%
% SYMBOLS AND ABBREVIATIONS:
%
%
% N:   Number of data samples
% nz:  Number of regressors (z)
% nd:  Number of local models for which the outputs are demanded
% nk:  Number of knots in the variable localModels

% LMNtool - Local Model Network Toolbox
% Julian Belz, 18th-Jan-2013
% Institute of Mechanics & Automatic Control, University of Siegen, Germany
% Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% Checks to prevent errors
if nargin < 3 || isempty(localModels) || isempty(zRegressor)
    fprintf('\n Not enough information passed to get the data points in the local models. \n\n');
    return;
end

if isempty(knotIdx)
    knotIdx = 1:size(localModels,2);
end

% Initializing the output vector/matrix
idx = false(size(zRegressor,1),size(knotIdx,2));

% For brothers and sisters only one
% index vector has to be calculated, lets say for the sister. The vector
% for the corresponding brother is the complement of the sister's index
% vector. IMPORTANT: The complement should be taken instead of calculating
% the index vector of the brother, because of one fact. Within the method
% 'getDataInValidSigmoidArea' the indices are determined by an less or
% EQUAL comparison. If data points are exactly on the splitting plane,
% these points would be counted twice (one time for the sister and one time
% for the brother)!

% Generate vector, that contains the parents of the corresponding entries
% in the knotIdx vector. At the end only one entry of the parentsIdx
% variable remains zero. This is the root.
parentsIdx = zeros(1,size(knotIdx,2));
for ii=1:size(knotIdx,2)
    if ~isempty(localModels(knotIdx(ii)).parent)
        parentsIdx(ii) = localModels(knotIdx(ii)).parent;
    end
end

% Look for brothers/sisters (same parent) and build matrix.
% Matrix: 1st line --> Indices of models (in the knotIdx-vector) for
% which the number of points, that lay in that local model, should be
% calculated; 2nd line --> Zero if no brother/sister was found or index of
% the brother/sister of the entry in the first line and the same column.
knotIdxMat = zeros(2,size(knotIdx,2));
knotIdxMat(1,:) = 1:size(knotIdx,2);
for ii=2:size(knotIdx,2)
    duplicates = find(parentsIdx(ii-1)==parentsIdx);
    if size(duplicates,2)>1
        knotIdxMat(2,ii-1) = duplicates(end);
        knotIdxMat(1,duplicates(end)) = 0;
    end
end
indices=knotIdxMat(1,:)~=0;
knotIdxMat=knotIdxMat(:,indices);


for ii=knotIdxMat
    % In every loop iteration ii consists of one column of the knotIdxMat.
    % I.E. in the 2nd cylce of the loop ii(1) contains the value
    % knotIdxMat(1,2) and ii(2) contains the value knotIdxMat(2,2).
    
    % Get current model and the index of its parent
    currentLocalModel = localModels(knotIdx(ii(1)));
    parentModel = currentLocalModel.parent;
    
    % Calculate which data belongs to the current local model
    idx(:,ii(1)) = currentLocalModel.getDataInValidSigmoidArea(currentLocalModel.splittingParameter,zRegressor);
    
    if ii(2)
        % If ii(2) is not null, a sister/brother exists
        idx(:,ii(2)) = ~idx(:,ii(1));
    end
    
    while ~isempty(parentModel)
        % If the parentModel property is empty, the local model is the root
        
        % Define new current model
        currentLocalModel = localModels(parentModel);
        parentModel = currentLocalModel.parent;
        
        % Calculate which data points lay in the area, where the sigmoid
        % tends to one for the parent local model
        idxTMP = currentLocalModel.getDataInValidSigmoidArea(currentLocalModel.splittingParameter,zRegressor);
        
        % Check what data points lay in the area where the parent and the
        % children sigmoid tend both to one
        idx(:,ii(1)) = all([idx(:,ii(1)) idxTMP],2);
        
        % Sister/brother exists
        if ii(2)
            idx(:,ii(2)) = all([idx(:,ii(2)) idxTMP],2);
        end
        
    end
    
end


% Calculate the number of points, that are contained in the corresponding
% model
numberOfPoints = sum(idx,1);

end