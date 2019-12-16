function [bsScore,lmns] = bootstrapScore(obj,repititions,modelComplexities,ini)
%% BOOTSTRAPPING creates bootstrap samples and calculates the bootstrap score.
%
%   Creates k bootstrap samples and calculates based on these samples an
%   bootstrap score. The number of repititions k can be specified by the 
%   user. For the bootstrap score the model output on all not selected 
%   samples for each bootstrap sample is calculated. All these model
%   outputs together with the calcGlobalLossFunction method are used to
%   determine the bootstrap score.
%
%
%       [pe,sigma] = bootstrapping(obj,repititions,modelComplexities,ini)
%
%
% 	BOOTSTRAPPING inputs:
%
%       obj               - model object
%       repititions       - integer, defines how many repititions should be
%                           made
%       modelComplexities - (1 x number of model complexities) or (String)
%                           vector:
%                           containing only integer values; every integer value
%                           determines a model complexity for which the
%                           bootstrapping should be performed.
%                           Example: modelComplexities = [3 5] --> The
%                           bootstrap score for 3 and 5 local models
%                           will be calculated.
%                           string:
%                           If the variable modelComplexities is of type
%                           character, the model complexity for every of
%                           bootstrap samples is determined
%                           automatically, either by validation data or by
%                           AICc.
%       ini               - Value to initialze the random generator, that
%                           is used to create the different data groups.
%
% 	BOOTSTRAPPING outputs:
%
%       bsScore           - Bootstrap score
%       lmns              - Trained local model networks with the bootstrap
%                           samples. These models can be used to for the
%                           calculation of the model's uncertainty, e.g.
%
%   LMNtool - Local Model Network Toolbox
%   Julian Belz, 28-May-2014
%   Institute of Measurement and Control, University of Siegen, Germany
%   Copyright (c) 2014 by Prof. Dr.-Ing. Oliver Nelles


% Some checks to prevent errors
if ~exist('repititions','var') || isempty(repititions)
    % If there is no repititions passed, a 10 bootstrap samples should be
    % drawn
    repititions     = 10;
end
if ~exist('modelComplexities','var') || isempty(modelComplexities)
    % If modelComplexities is empty, perform bootstrapping with automatic
    % complexity determination
    modelComplexities   = 'auto';
elseif ~ischar(modelComplexities)
    % If the model complexity should not be determined automatically, the
    % maximum model complexity has to be smaller than the maximum model
    % complexity of the trained model (otherwise there is no reasonable
    % amount of parameters available to stop the training during the
    % training with the bootstrap samples).
    maxComplexity = max(modelComplexities);
    if maxComplexity > size(obj.history.leafModelIter,2)
        fprintf(['Demanded model complexity exceeds the maximum ',...
            'complexity of the trained local model network object.\n',...
            'Demanded model complexity substituted by the maximum',...
            ' available complexity.\n \n']);
        
        modelComplexities = size(obj.history.leafModelIter,2);
    end
end
% If the model object contains no data no bootstrapping can be performed
if isempty(obj.input) || isempty(obj.output)
    error('lossFunction:bootstrapping','There is no data available to run the bootstrapping!\n');
end
if ~exist('ini','var')
    ini = 9596;
end
if isempty(modelComplexities) || (~ischar(modelComplexities) &&  any(modelComplexities == 0))
    error('lossFunction:bootstrapping',['The passed local model network object has not been trained yet.\n',...
        'Please train the object first and try again run the bootstrapping.\n']);
end

% information about the size of all data and about the train data size in
% every loop
[N,numberOfOutputs] = size(obj.output);

% Predefine a variable, that will contain the results of the bootstrap
% samples
if ischar(modelComplexities)
    % If modelComplexities contains a string, the model complexity of the
    % trained model should be determined automatically.
    bsScore = zeros(1,1);
else
    bsScore = zeros(1,max(modelComplexities));
end

% Pre-define output variable lmns, if demanded
lmns = cell(size(modelComplexities,2),repititions);


% To get reproduceable results, the random generator is seeded.
rng(ini,'twister');

% waitbar
% hwait           = waitbar(0,'Please wait...');

% To maintain the training and settings of the original model, the
% training with the bootstrap samples is performed with tmpObj
tmpObj          = obj.deleteLMNTraining;

% Recover all scaling information
tmpObj.scaleParaInput = obj.scaleParaInput;
tmpObj.inputScalingComplete = obj.inputScalingComplete;
tmpObj.scaleParaOutput = obj.scaleParaOutput;
tmpObj.outputScalingComplete = obj.outputScalingComplete;

% Switch off all termination criteria, that should be deactivated for both
% versions (the one, where the model complexity is set by the user and the
%  one, where the model complexity is set automatically)
if any(strcmp('maxNumberOfLM', properties(tmpObj)))
    tmpObj.maxNumberOfLM = inf;
end
if any(strcmp('minError', properties(tmpObj)))
    tmpObj.minError = 0;
end
if any(strcmp('maxTrainTime', properties(tmpObj)))
    tmpObj.maxTrainTime = inf;
end
if any(strcmp('maxIterations', properties(tmpObj)))
    tmpObj.maxIterations = inf;
end

% If the model complexity should be determined automatically it has to be
% checked, if the required termination criterion can be fullfilled.
if ischar(modelComplexities)
    % If there is validation data available and it should be used for the
    % automatic complexity determination, pass the validation data set to
    % the tmpObj
    if strcmp(tmpObj.lossFunctionTermination,'validationDataLossFunction')
        if ~isempty(obj.validationInput) && ~isempty(obj.validationOutput)
            tmpObj.validationInput = obj.validationInput;
            tmpObj.validationOutput = obj.validationOutput;
        else
            error('lossFunction:bootstrapping',['Cross-validation calculation aborted because the ',...
                'lossFunctionTermination property is set to ''validationDataLossFunction''',...
                ' but there is no validation data available.']);
        end
    end
    
else
    % Model complexities are set by the user - only in this case the
    % following termination criterions should be adjusted
    if any(strcmp('minPerformanceImprovement', properties(tmpObj)))
        tmpObj.minPerformanceImprovement = 0;
    end
    if any(strcmp('maxValidationDeterioration', properties(tmpObj)))
        tmpObj.maxValidationDeterioration = inf;
    end
    
    % If the model complexity is determined by the user, set the loss
    % function termination property to 'AICc'. The criterion is not active,
    % but in case of 'validationDataLossFunction' as the loss
    % function termination criterion without available validation data, an
    % error will occur.
    tmpObj.lossFunctionTermination = 'AICc';
end

% Turn display mode off - should save some computation time...
tmpObj.history.displayMode = false;

% Create variable for outer loop, which is
if ischar(modelComplexities)
    loopVar = ones(2,1);
else
    loopVar = [modelComplexities;1:size(modelComplexities,2)];
end

for jj = loopVar
    
    % set the maximum number of parameters for the following
    % bootstrapping, only if the model complexity is set by the user
    if ~ischar(modelComplexities)
        tmpObj.maxNumberOfParameters = obj.history.currentNumberOfParameters(jj(1));
    end
    
    % perform boostrapping for the current complexity
    helpMeCount         = 1;
    output              = zeros(N,numberOfOutputs); % Initialising
    modelOutput         = zeros(N,numberOfOutputs); % Initialising
    weightings          = zeros(N,1); % Initialising
    
    % Predefine some variables
    outputIndexesCell = cell(1,repititions);
    outputCell = cell(1,repititions);
    modelOutputCell = cell(1,repititions);
    weightingsCell = cell(1,repititions);
    parforInput = cell(1,repititions);
    parforOutput = cell(1,repititions);
    parforWeighting = cell(1,repititions);
    parforTestInput = cell(1,repititions);
    parforTestOutput = cell(1,repititions);
    parforTestWeighting = cell(1,repititions);
    lmnsTmp = cell(1,repititions);
    
    % This first loop is neccessary to parallelize the following loop,
    % which is more computional expensive.
    for ii = 1:repititions
        % Seed random generator
        trainSetIdx = round(rand(1,N)*(N-1))+1;
        testSetIdx = setxor(1:N,trainSetIdx);
        
        % Save sliced training/test inputs, outputs and weightings for
        % the following parfor-loop
        parforInput{ii} = obj.input(trainSetIdx,:);
        parforOutput{ii} = obj.output(trainSetIdx,:);
        
        parforTestInput{ii} = obj.unscaledInput(testSetIdx,:);
        parforTestOutput{ii} = obj.unscaledOutput(testSetIdx,:);
        
        % Keep data-weightings, if available
        if isempty(obj.dataWeighting)
            parforWeighting{ii}     = ones(length(trainSetIdx),1);
            parforTestWeighting{ii} = ones(length(testSetIdx),1);
        else
            parforWeighting{ii}     = obj.dataWeighting(trainSetIdx,:);
            parforTestWeighting{ii} = obj.dataWeighting(testSetIdx);
        end
        
        outputIndexesCell{ii} = helpMeCount:(size(testSetIdx,2)+helpMeCount-1);
        
        % increasing the variable helpMeCount for the next run of the loop
        helpMeCount             = helpMeCount + size(testSetIdx,2);
    end
    
    parfor ii = 1:repititions % parfor
        
        % Load local model network object with all neccessary settings
        tmpObj2 = tmpObj;
        
        % Pass training data for the current loop
        tmpObj2.input           = parforInput{ii};
        tmpObj2.output          = parforOutput{ii};
        
        % Make sure the data weighting is kept the same
        tmpObj2.dataWeighting = parforWeighting{ii};
        
        % Train LMN with new data set
        tmpObj2                 = tmpObj2.train;
        
        % Make sure the correct model complexity is chosen for further
        % steps in case of the user defined model complexity
        if ~ischar(modelComplexities)
            [~,idxMin] = min(abs(tmpObj2.history.currentNumberOfParameters - tmpObj2.maxNumberOfParameters));
            tmpObj2.leafModels = tmpObj2.history.leafModelIter{idxMin};
        end
        
        % evaluate the output of the trained model at the test samples
        if isempty(parforTestInput{ii})
            yTestData = [];
        else
            yTestData = tmpObj2.calculateModelOutput(parforTestInput{ii},...
                parforTestOutput{ii});
        end
        
        % Save results for the evaluation of the cv values after the
        % parfor-loop is finished
        outputCell{ii}         = parforTestOutput{ii};
        modelOutputCell{ii}    = yTestData;
        weightingsCell{ii}     = parforTestWeighting{ii};
        lmnsTmp{ii}            = tmpObj2;
        
    end
    
    for ii=1:repititions
        % This loop is neccessary because of the way, the variables are
        % allowed to be indexed within the parfor-loop
        outputIndexes                   = outputIndexesCell{ii};
        output(outputIndexes,:)         = outputCell{ii};
        modelOutput(outputIndexes,:)    = modelOutputCell{ii};
        weightings(outputIndexes)       = weightingsCell{ii};
    end
    
    % Pass all trained local model trees to the lmns-variable
    lmns(jj(2),:) = lmnsTmp;
    
    % Calculation of the loss function value.
    if isempty(obj.outputWeighting)
        obj.outputWeighting = ones(1,size(obj.output,2));
    end
    bsScore(jj(1)) = obj.calcGlobalLossFunction(output, modelOutput, obj.lossFunctionGlobal, weightings, obj.outputWeighting);
    
%     if exist('hwait','var')
%         waitbar(jj(2)/size(loopVar,2),hwait);
%     end
    
end

if ischar(modelComplexities)
    % If the model complexity is not set by the user, different model
    % complexities for the different k training-data groups might have
    % occured --> Not reasonable to save the result in the local model
    % network object.
    % obj = [];
else
    % Give only non-zero values back corresponding to the order of the
    % 'modelComplexities' vector
    bsScore = bsScore(modelComplexities);
end


% if exist('hwait','var')
%     % hwait does not exist, if the user closed the waitbar window before
%     % the calculation ended
%     delete(hwait);
% end


end % end bootstrapping