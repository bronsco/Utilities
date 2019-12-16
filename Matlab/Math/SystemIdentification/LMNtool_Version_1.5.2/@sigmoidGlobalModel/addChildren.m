function obj = addChildren(obj,parent,splittingParameter,center,parameter,kappa)
%% addChildren adds a children knot to the tree.
%
%
%       [obj] = addChildren(obj,parent,splittingParameter,center,parameter)
%
%
%   addChildren inputs:
%       parentIdx          - Index of parent knot. If empty, new knot is considered to be the root.
%       splittingParameter - (optional) Sigmoid parameter of the new knot.
%       center             - (optional) Center of the new knot.
%       parameter          - (optional) Parameter of the new local model (consequent parameters).
%       kappa              - (optional) Value that determines the steepness of the transition area
%
%
%   LMNtool - Local Model Network Toolbox
%   Benjamin Hartmann, 28-Oct-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles



if ~exist('parent','var')
    parent = [];
end
if ~exist('splittingParameter','var')
    splittingParameter = [];
end
if ~exist('center','var')
    center = [];
end
if ~exist('parameter','var')
    parameter = [];
end
if ~exist('kappa','var')
    kappa = [];
end

if isempty(obj.localModels)
    % the new knot is the root knot
    obj.localModels = sigmoidLocalModel(parent,splittingParameter,center,parameter,kappa);
else
    % add a new child
    obj.localModels(end+1) = sigmoidLocalModel(parent,splittingParameter,center,parameter,kappa);
    % get child idx
    childIdx = length(obj.localModels);
    % add the child index to the parent model
    obj.localModels(parent).children(end+1) = childIdx;
end


end

