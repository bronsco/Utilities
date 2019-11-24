function [phi,phiMemory] = calculateValidity(obj,zRegressor,idx,phiMemory)
%% CALCULATEVALIDITY callculates the validity functino values (phi) of every z
% regressor for every local model
%
%
%       [phi,phiMemory] = obj.calculateValidity(zRegressor,idx,phiMemory)
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 24-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% CHANGELOG:
% 201301-30: Changed name from ...Phi to ...Validity

%% prevent errors
if nargin<4
    phiMemory = [];
elseif ~iscell(phiMemory)
    % convert to cells
    phiMemory = mat2cell(phiMemory,size(phiMemory,1),ones(1,size(phiMemory,2)));
end

if islogical(idx)
    % convert to non-logical index, makes things easier
    idx = find(idx);
end

if arrayfun(@(LMO) isempty(LMO.splittingParameter) && ~isempty(LMO.parent), obj.localModels(idx))
    % if splittingParameter is empty and knot is not the root, then error
    error('sigmoidGlobalModel:calculateValidity','Property <splittingParameter> is empty!')
end


%% loop over all idx
phi = zeros(size(zRegressor,1),length(idx));
for k = 1:length(idx)
    
    if isempty(obj.localModels(idx(k)).parent) && isempty(obj.localModels(idx(k)).splittingParameter)
        
        % if there is no parent AND the parameters of the sigmoid are empty, it is the root
        phi(:,k) = ones(size(zRegressor,1),1);    
    
    elseif size(phiMemory,2)<idx(k) || isempty(phiMemory{1,idx(k)}) % test if phi must be calculated
        
        % phi has not been calculated already, calculate now
        phi(:,k) = obj.localModels(idx(k)).calculatePsi(zRegressor,[],obj.smoothness);
        % if there is a parent AND the parent is NOT the root, then multiply with it
        if ~isempty(obj.localModels(idx(k)).parent) && ~isempty(obj.localModels(obj.localModels(idx(k)).parent).parent)
            % calculate phi of parent
            [rootPhi,phiMemory] = obj.calculateValidity(zRegressor,obj.localModels(idx(k)).parent,phiMemory);
            % multiply with parent to get phi of idx(k)
            phi(:,k) = phi(:,k) .* rootPhi;
        end    
        
        % write phi to memory, it may be used later
        if any(phi(:,k))==0
            % if there are phis==0 then make a sparse matrix to save memory
            phiMemory{1,idx(k)} = sparse(phi(:,k));
        else
            phiMemory{1,idx(k)} = phi(:,k);
        end
        
    else
        
        % phi has been calculated, read from memory
        phi(:,k) = phiMemory{1,idx(k)};
        
    end
    
end

end