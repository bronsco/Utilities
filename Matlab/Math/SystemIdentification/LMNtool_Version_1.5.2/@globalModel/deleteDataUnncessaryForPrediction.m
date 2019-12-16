function obj = deleteDataUnncessaryForPrediction(obj)
%% DELETEDATAUNNCESSARYFORPREDICTION deletes all information unnecessary for predictions
%
%
%       obj = deleteDataUnncessaryForPrediction(obj)
%
%
%   DELETEDATAUNNCESSARYFORPREDICTION inputs:
%
%       obj         - model object, that has been trained
%
%   DELETEDATAUNNCESSARYFORPREDICTION outputs:
% 
%       obj         - model object containing only information for predictions
%
%   LMNtool - Local Model Network Toolbox
%   Julian Belz, 05-Feb-2016
%   Institute of Measurement and Control, University of Siegen, Germany
%   Copyright (c) 2016 by Prof. Dr.-Ing. Oliver Nelles


% A lot of information stored in a model object after the training of it
% are not necessary to predict the model output for specified input values

% Delete history
obj.history = modelHistory;

% Delete all information related to the training data
obj.xRegressor = [];
obj.zRegressor = [];
obj.input = [];
obj.output = [];
obj.validationInput = [];
obj.validationOutput = [];
obj.testInput = [];
obj.testOutput = [];
obj.dataWeighting = [];
obj.outputWeighting = [];

% Delete information related to the validities of the trainind data samples
if isa(obj,'lolimot')
    obj.MSFValue = [];
    
    % Delete all local models except for the ones needed to calculate the model
    % output
    necessaryLocalModels = obj.localModels(obj.leafModels);
    obj.localModels = necessaryLocalModels;
    obj.leafModels = true(1,size(necessaryLocalModels,2));
elseif isa(obj,'hilomot')
    obj.phi = [];
    
    % Here no local models can be deleted, because they are all necessary
    % due to the hierachical way in which the validities are calculated.
end

% Delete information about locked local models
obj.idxAllowedLM = [];
obj.idxAllowedLMIter = [];



end
