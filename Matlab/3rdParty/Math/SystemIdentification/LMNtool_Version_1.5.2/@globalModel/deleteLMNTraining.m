function LMN = deleteLMNTraining(LMN)
%% deleteLMNtraining deletes all information of the local model network related to an earlier training.
%
%   Deletes the local models, all validity values as well as other
%   properties related to an earlier training, such that a new training can
%   be performed.
%
%
%       LMN = deleteLMNTraining(LMN)
%
%
%   deleteLMNtraining inputs:
%
%       LMN         - model object, that has been trained
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fischer & Julian Belz, 13-Feb-2013
%   Institute of Measurement and Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% This function deletes all information, that is related to the training of
% the LMN, but keeps all options for training procedure itself.

%% Saving options, that should be kept the same
displayMode = LMN.history.displayMode;

%% Delete information related to a performed training
LMN.idxAllowedLM    = [];
LMN.idxAllowedLMIter = [];
LMN.history         = modelHistory;
LMN.leafModels      = [];
LMN.localModels     = [];
LMN.outputModel     = [];
LMN.xRegressor      = [];
LMN.xRegressorExponentMatrix = [];
LMN.relationZtoX    = [];
LMN.zRegressor      = [];
if any(strcmp('phi', properties(LMN)))
    LMN.phi = [];
elseif any(strcmp('MSFValue', properties(LMN)))
    LMN.MSFValue = {[]};
else
    error('globlaModel:deleteLMNTraining','The object from which you tried to delete the training seems to be no supported model class. Aborting...');
end
LMN.input            = [];
LMN.output           = [];
LMN.validationInput  = [];
LMN.validationOutput = [];
LMN.testInput        = [];
LMN.testOutput       = [];
LMN.scaleParaInput   = [];
LMN.scaleParaOutput  = [];
LMN.inputScalingComplete = false;
LMN.outputScalingComplete = false;
LMN.dataWeighting = [];
LMN.outputWeighting = [];
LMN.info = dataSetInfo;


%% Set saved options from above
LMN.history.displayMode = displayMode;

end
