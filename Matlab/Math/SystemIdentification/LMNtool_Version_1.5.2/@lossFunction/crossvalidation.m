function [cvValues,obj] = crossvalidation(obj,numberOfBatches,modelComplexities,ini)
%% CROSSVALIDATION performs a k-fold cross-validation.
%
%   Evaluate the errors of a k-fold cross-validation
%   (k=numberOfBatches) for the model complexities specified by the user
%
%
%       [cvValues,obj] = crossvalidation(obj,numberOfBatches,modelComplexities,ini)
%
%
% 	CROSSVALIDATION inputs:
%
%       obj               - model object
%       numberOfBatches   - integer; in how many batches the whole
%                           dataSet should be devided
%       modelComplexities - (1 x number of model complexities) or (String)
%                           vector:
%                           containing only integer values; every integer value
%                           determines a model complexity for which the
%                           cross-validation value should be calculated.
%                           Example: modelComplexities = [3 5] --> The
%                           cross-validation values for 3 and 5 local models
%                           will be calculated.
%                           string:
%                           If the variable modelComplexities is of type
%                           character, the model complexity for every of
%                           the k training-data groups is determined
%                           automatically, either by validation data or by
%                           AICc.
%       ini               - Value to initialze the random generator, that
%                           is used to create the different data groups.
%
% 	CROSSVALIDATION outputs:
%
%       cvValues          - crossvalidation values for the demanded model
%                           complexities
%       obj               - model object with updated model history
%                           (crossvalidation values)
%
%   LMNtool - Local Model Network Toolbox
%   Julian Belz, 16-March-2012
%   Institute of Measurement and Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

%  2014-05-23: Possibility added to determine the model complexity for each
%  of the k models, resulting from the k training-data groups. This feature
%  does NOT rate a model, but a certain subset of input variables. To rate
%  a model, the model complexity has to be set.

% Some checks to prevent errors
if ~exist('numberOfBatches','var') || isempty(numberOfBatches)
    % If there is no numberOfBatches passed, a 10-fold crossvalidation
    % should be performed
    numberOfBatches     = 10;
end
if ~exist('modelComplexities','var') || isempty(modelComplexities)
    % If modelComplexities is empty, perform crossvalidation for the
    % suggested net
    modelComplexities   = obj.suggestedNet;
elseif ~ischar(modelComplexities)
    % If the model complexity should not be determined automatically, the
    % maximum model complexity has to be smaller than the maximum model
    % complexity of the trained model (otherwise there is no reasonable
    % amount of parameters available to stop the training during the
    % calculation of the cross-validation score).
    [maxComplexity,idxMax] = max(modelComplexities);
    if maxComplexity > size(obj.history.leafModelIter,2)
        fprintf(['Demanded model complexity exceeds the maximum ',...
            'complexity of the trained local model network object.\n',...
            'Demanded model complexity substituted by the maximum',...
            ' available complexity.\n \n']);
        
        modelComplexities(idxMax) = size(obj.history.leafModelIter,2);
    end
end
% If the model object contains no data no crossvalidation can be performed
if isempty(obj.input) || isempty(obj.output)
    error('lossFunction:crossvalidation','There is no data available to perform a crossvalidation!\n');
end
if ~exist('ini','var')
    ini = 9596;
end
if isempty(modelComplexities) || (~ischar(modelComplexities) &&  any(modelComplexities == 0))
        error('lossFunction:crossvalidation',['The passed local model network object has not been trained yet.\n',...
            'Please train the object first and try again to calculate the cross-validation score.\n']);
end

% information about the size of all data and about the train data size in
% every loop
[N,numberOfOutputs] = size(obj.output);

% If the demanded number of batches is greater than the number of data
% samples, set the number of batches to the number of data samples
if numberOfBatches-N > eps
    numberOfBatches = N;
    fprintf(['Number of demanded batches is greater than the number',...
        ' of data samples.\n Number of batches is set to the number of data samples.\n \n'])
end

% Calculate the group size of every batch
groupSize   = N - floor(N/numberOfBatches);

% Predefine a variable, that will contain the cross-validation values.
if ischar(modelComplexities)
    % If modelComplexities contains a string, the model complexity of the
    % trained model should be determined automatically. Only one
    % cross-validation score will be calculated.
    cvValues = zeros(1,1);
else
    cvValues = zeros(1,max(modelComplexities));
end

% waitbar
% hwait           = waitbar(0,'Please wait...');

% To maintain the training of the original model, the training for the
% cross-validation calculation is performed with tmpObj
tmpObj          = obj.deleteLMNTraining;

% Recover all scaling information
tmpObj.scaleParaInput = obj.scaleParaInput;
tmpObj.scaleParaOutput = obj.scaleParaOutput;

tmpObj.inputScalingComplete = false;
tmpObj.outputScalingComplete = false;

% Switch off all termination criteria, that should be deactivated for both
% versions of the k-fold cross-validation (the one, where the model
% complexity is set by the user and the one, where the model complexity is
% set automatically)
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
            error('lossFunction:crossvalidation',['Cross-validation calculation aborted because the ',...
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
    % cross-validation, only if the model complexity is set by the user
    if ~ischar(modelComplexities)
        tmpObj.maxNumberOfParameters = obj.history.currentNumberOfParameters(jj(1));
    end
    
    % perform cross validation for the current model
    if ~ischar(modelComplexities) && jj(1) > groupSize
        % If there are more local models allowed than training data
        % points are available, the CV value is set to not a number
        % to avoid problems in the parameter estimation.
        cvValues(jj(1)) = NaN;
    else
        
        helpMeCount         = 1;
        output              = zeros(N,numberOfOutputs); % Initialising
        modelOutput         = zeros(N,numberOfOutputs); % Initialising
        weightings          = zeros(N,1); % Initialising
        
        % Predefine some variables
        outputIndexesCell = cell(1,numberOfBatches);
        outputCell = cell(1,numberOfBatches);
        modelOutputCell = cell(1,numberOfBatches);
        weightingsCell = cell(1,numberOfBatches);
        parforInput = cell(1,numberOfBatches);
        parforOutput = cell(1,numberOfBatches);
        parforWeighting = cell(1,numberOfBatches);
        parforTestInput = cell(1,numberOfBatches);
        parforTestOutput = cell(1,numberOfBatches);
        parforTestWeighting = cell(1,numberOfBatches);
        
        % This first loop is neccessary to parallelize the following loop,
        % which is more computional expensive.
        for ii = 1:numberOfBatches
            [testSetIdx, trainSetIdx] = generateCVsamples(obj,numberOfBatches,ii);
            
            % Save sliced training/test inputs, outputs and weightings for
            % the following parfor-loop
            parforInput{ii} = obj.unscaledInput(trainSetIdx,:);
            parforOutput{ii} = obj.unscaledOutput(trainSetIdx,:);
            
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
        
        parfor ii = 1:numberOfBatches % parfor
            
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
            yTestData = tmpObj2.calculateModelOutput(parforTestInput{ii},...
                parforTestOutput{ii});
            
            % Save results for the evaluation of the cv values after the
            % parfor-loop is finished
            outputCell{ii}         = parforTestOutput{ii};
            modelOutputCell{ii}    = yTestData;
            weightingsCell{ii}     = parforTestWeighting{ii};
            
        end
        
        % Make sure the outputWeighting property of the object is set.
        if isempty(obj.outputWeighting)
            obj.outputWeighting = ones(1,size(obj.output,2));
        end
        
        % Build vectors containing outputs, model outputs and data
        % weightings
        startIdx = 1;
        for kk=1:numberOfBatches
            endIdx = startIdx + size(outputCell{kk},1) - 1;
            output(startIdx:endIdx,:) = outputCell{kk};
            modelOutput(startIdx:endIdx,:) = modelOutputCell{kk};
            weightings(startIdx:endIdx,1) = weightingsCell{kk};
            startIdx = endIdx + 1;
        end
        
        % Calculate sum of squared errors (SOSE)
        cvValues(jj(1)) = calcGlobalLossFunction(obj, output,...
            modelOutput, obj.lossFunctionGlobal, weightings, obj.outputWeighting);
        
    end
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
    cvValues = cvValues(modelComplexities);
    obj.numberOfCVgroups = numberOfBatches;
    obj.history.kFoldCVLossFunction(modelComplexities) = cvValues;
end


% if exist('hwait','var')
%     % hwait does not exist, if the user closed the waitbar window before
%     % the calculation ended
%     delete(hwait);
% end

    function [testSetIdx, trainSetIdx] = generateCVsamples(dataSetObject,numberOfGroups,groupSelection,options)
        % Function creates various dataSets
        % [testSet trainSet] = generateTrainTestSet(data, numberOfGroups, groupSelection, options)
        %
        % Output:
        %   testSet:          group size x no. of data columns     test data set
        %   trainSet:         N-group size x no. of data columns   training data set
        %
        % Input:
        %   obj:              dataSet-object
        %   numberOfGroups:   N x q   Number of groups (LOO-cross-validation: numberOfGroups = N)
        %   groupSelection:   1 x 1   Selection of the group that has to be extracted as test set
        %   options:          string  Options for data partitioning
        
        % HILOMOT Nonlinear System Identification Toolbox, Version 1.0
        % Benjamin Hartmann, 27-September-2008
        % Institute of Automatic Control & Mechatronics, Department of Mechanical Engineering, University of Siegen, Germany
        % Copyright (c) 2008 by Benjamin Hartmann
        
        data      = [dataSetObject.input dataSetObject.output];
        
        % Get constants
        Ndata = size(data,1);
        groupsize = floor(Ndata/numberOfGroups);
        
        
        % usualy the groups should be selected randomly
        if nargin < 4
            options = 'randomize';
        end
        
        % Options
        switch options
            case 'randomize'             % Randomize data set
                rng(ini,'twister'); % 9596
                permIdx = randperm(Ndata);
        end
        
        % Perform data partitioning
        if groupSelection == 1
            testSetIdx = permIdx(1:groupsize);
            trainSetIdx = permIdx(groupsize+1:size(data,1));
        elseif groupSelection == numberOfGroups
            testSetIdx = permIdx((groupSelection-1)*groupsize+1 :size(data,1));
            trainSetIdx = permIdx(1:(groupSelection-1)*groupsize);
        else
            testSetIdx = permIdx((groupSelection-1)*groupsize+1 : groupSelection*groupsize);
            trainSetIdx = [permIdx(1:(groupSelection-1)*groupsize), permIdx(groupSelection*groupsize+1:size(data,1))];
        end
    end

end % end crossvalidation