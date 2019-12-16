function obj = train(obj)
%% TRAIN Trains a local model network (LMN) by using the HILOMOT algorithm.
%
%   A given data set is is modeled with a local model network. The local models are interpolated with
%   validity functions. These functions define the validity region of each local model and are
%   hierarchically constructed with sigmoidal splitting functions. The splitting with HILOMOT results
%   in an axes-oblqiue partitioning of the input space. All options for training are defined with the
%   HILOMOT object. The all relevant informations about the training are stored in the object.
%
%       [obj] = TRAIN(obj)
%
%
%   TRAIN input:
%
%       obj - (object) Initial HILOMOT object containing all relevant properties and methods.
%
%
%   TRAIN output:
%
%       obj - (object) Trained HILOMOT object.
%
%
%   See also hilomot, lolimot.
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Benjamin Hartmann, 15-January-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

persistent flagOptimizationToolbox

% Check if the version testing has already be done (only when necessary)
if obj.oblique && isempty(flagOptimizationToolbox)
    % Check if nonlinear split optimization is activated. In the case of
    % multiple trainings (for DoE or input selection) the buffering of the
    % flag as a persistent variable leads to a considerable performance
    % improvement.
    MatLabVersion = ver; % Get Version of all toolboxes
    % Check if the Optimization Toolbox in in the path
    if any(strcmp('Optimization Toolbox', {MatLabVersion.Name}))
        flagOptimizationToolbox = true; % Found
    else
        flagOptimizationToolbox = false; % Missing
    end
    clear MatLabVersion
end

% Check if the Optimization Toolbox is needed and available
if obj.oblique && ~flagOptimizationToolbox
    % No sensible optimization possible : orthogonal splitting only
    obj.oblique = false;
    % Give warning about the unavailable Optimization Toolbox
    warning('hilomot:train','\n Nonlinear split optimization for oblique splitting is activated <obj.oblique=true>, but the Optimization Toolbox is not installed. \n Therefore the required method <fmincon> for nonlinear, constrained optimization of the splitting parameters can not be used. \n The property <oblique> is set to false to use only orthogonal splits.\n The Optimization Toolbox is necessary to reveal the full potential of the Hilomot-Algorithm.\n')
end

% Check if analytical gradient for oblique loss function is installed
if obj.GradObj && ~ismethod(obj, 'obliqueGlobalLossFunctionGradient')
    error('hilomot:train','Analytical gradient for oblique loss function is not installed. Optimization with analytical gradient is not possible. To deactivate optimization with analytical gradient set property GradObj to false')
end


% Set timer for training
tStart = tic;

% initialize training
obj = initializeTraining(obj);

% Estimate first net
if isempty(obj.localModels) % Estimate a global linear model
    obj = estimateFirstLM(obj); % one linear model
else % Estimate a nonlinear model based on the given structure
    obj = estimateGivenModel(obj);
end

% Initialize the index vector of the allowed local model in each iteration
obj.idxAllowedLMIter = obj.idxAllowedLM;

% Write history
obj.history = writeHistory(obj.history,obj,tStart);

% Display loss function value for the first net
if obj.history.displayMode
    fprintf('\nInitial net has %d local model(s): J = %f\n', ...
        sum(obj.leafModels), obj.history.globalLossFunction(end));
end

% Make sure that at least some splits (depending on the 
% maxValidationDeterioration property) are made even if the first split 
% does not result in an improvement of the global loss function
iniGlobalLossFunction = obj.history.globalLossFunction(1);
obj.history.globalLossFunction(1) = inf;

% Tree construction algorithm
while obj.checkTerminationCriterions % Go on training until one termination criterion is reached
    
    while any(obj.idxAllowedLM & obj.leafModels & obj.idxAllowedLMIter) % While-loop over all allowed local models
        %% Initialisation
        % Initialize the flag, if a permitted initial split is found
        flagPermittedInitialSplitFound = false;
        
        % Initialize the flag, if one split leads to an improvement of the training error
        flagBetterSplitFound = false;
        
        % Find worst performing LM
        worstLM = findWorstLM(obj);
        
        % Check for split of worst performing LLM
        if obj.history.displayMode
            fprintf('\n\n%d. Iteration. Number of local models = %d. Checking for split of model %d ... \n', ...
                obj.history.iteration, sum(obj.leafModels), worstLM);
        end
        
        % Initialize the error for the best starting point of the optimization
        globalLossFunctionIni = inf;
        
        % Initialize the error for the best model, in every iteration the
        % training error must decrease
        globalLossFunctionBest = obj.history.globalLossFunction(end);
        
        if obj.kStepPrediction <=1
            % Pre-calcualte the global model output values without the
            % influence of the selected worst performing local model (not for simulation)
            if obj.useCenteredLocalModels
                % Calculate the shifted local inputs and the local x-regressors
                xRegressorLocal = data2xRegressor(obj,obj.input,obj.output,obj.localModels(worstLM).center);
                weightedOutputWorstLM = obj.outputModel - obj.calcYhat(xRegressorLocal, obj.phi(:,worstLM), {obj.localModels(worstLM).parameter});
            else
                weightedOutputWorstLM = obj.outputModel - obj.calcYhat(obj.xRegressor, obj.phi(:,worstLM), {obj.localModels(worstLM).parameter});
            end
        else
            weightedOutputWorstLM = [];
        end
        
%         obj.initialLOLIMOTsplits = false;
        %% Perform axes-orthogonal splitting
        if (size(obj.zRegressor,2) <= 1 || obj.initialLOLIMOTsplits) || length(obj.leafModels)==1
            for splitDimension = 1:size(obj.zRegressor,2) % Over all dimensions of the z-regressor
                
                
                % Define sigmoid parameters for orthogonal split
                wRed = zeros(size(obj.zRegressor,2),1);
                wRed(splitDimension) = 1;                                      % Split in dimension splitDimension
                w0 = -obj.localModels(worstLM).center(splitDimension);  % Split at the center coordinate of the worst LM
                
                % Calculate current orthogonal split
                [globalLossFunctionValue, ~, localModels, leafModels, phi, outputModel, forbiddenSplit, phiSimulated] = obliqueGlobalLossFunction(obj, wRed, w0, weightedOutputWorstLM, [],worstLM);
                
                % If the split is forbidden, try the next dimension or split ratio
                if forbiddenSplit
                    if obj.history.displayMode
                        fprintf('\n   Testing split in dimension %d:         Forbidden!', splitDimension);
                    end
                    continue % Continue with the next split
                end
                
                if obj.history.displayMode
                    fprintf('\n   Testing split in dimension %d:         J = %f', splitDimension, globalLossFunctionValue);
                end
                
                % If better than the currently best axes-orthogonal split
                if globalLossFunctionIni - globalLossFunctionValue > eps
                    globalLossFunctionIni = globalLossFunctionValue;
                    localModelsIni = localModels;
                    leafModelsIni = leafModels;
                    phiIni = phi;
                    outputModelIni = outputModel;
                    phiSimulatedIni = phiSimulated;
                    flagPermittedInitialSplitFound = true; % At least one permitted othogonal split is found
                end
            end
        end
        
        % Perform axes-oblique splitting
        if obj.oblique
            
            
            % Test previous split for possibly better initialization
            if sum(obj.leafModels)>1 && size(obj.zRegressor,2) > 1
                %                 splitDimension = 'lastSplit'; % Over all dimensions of the z-regressor
                %                 [objSplitLast, forbiddenSplit] = LMSplit(obj, worstLM, splitDimension);
                
                w      = obj.localModels(worstLM).splittingParameter * obj.localModels(worstLM).kappa/obj.smoothness;
                w(end) = -obj.localModels(worstLM).center * obj.localModels(worstLM).splittingParameter(1:end-1) * obj.localModels(worstLM).kappa/obj.smoothness;
                
                [globalLossFunctionValue, ~, localModels, leafModels, phi, outputModel, forbiddenSplit, phiSimulated] = obliqueGlobalLossFunction(obj, w(1:end-1), w(end), weightedOutputWorstLM, [],worstLM);
                
                if forbiddenSplit
                    if obj.history.displayMode
                        fprintf('\n   Testing parent split:                 Forbidden!');
                    end
                else
                    if obj.history.displayMode
                        fprintf('\n   Testing parent split:                 J = %f', globalLossFunctionValue);
                    end
                    % If better than the best axes-orthogonal split
                    if globalLossFunctionIni - globalLossFunctionValue > eps
                        globalLossFunctionIni = globalLossFunctionValue;
                        leafModelsIni = leafModels;
                        localModelsIni = localModels;
                        phiIni = phi;
                        outputModelIni = outputModel;
                        phiSimulatedIni = phiSimulated;
                        flagPermittedInitialSplitFound = true; % At least the last split direction leads to a permitted split
                    end
                end
            end
            
            
            
            
            
            
            %% Check if a permitted initial split exist; without initialization no nonlinear optimization
            if flagPermittedInitialSplitFound
                
                % Set best initial model as currently best model, if it is better the model of the last iteration
                if globalLossFunctionBest - globalLossFunctionIni > eps % Check if the initial model is better
                    globalLossFunctionBest = globalLossFunctionIni;
                    leafModelsBest = leafModelsIni;
                    localModelsBest = localModelsIni;
                    phiBest = phiIni;
                    outputModelBest = outputModelIni;
                    phiSimulatedBest = phiSimulatedIni;
                    flagBetterSplitFound = true; % A permitted split is found, that decrease the training error
                end
                
                % Split optimization
                [globalLossFunctionValue, localModels, leafModels, phi, outputModel, successfulOpt, phiSimulated] = LMSplitOpt(obj, localModelsIni, weightedOutputWorstLM);
                
                %                             figure
                %                 obj.plotPartition
                %                 drawnow
                %             worstLM
                %             figure(131);clf;obj.plotPartition
                %             % Plot Lossfunction Opt
                %             w = localModelsIni(1).splittingParameter;
                %             wRedIni = w(1:end-1);
                %             w = localModels(1).splittingParameter;
                %             a=0.2;
                % %             w0 = 0.4459;
                %             NumberOfPlotPoints = 40;
                % %             [X1, X2] = meshgrid(linspace(wRedIni(1)-2,wRedIni(1)+2,NumberOfPlotPoints),linspace(wRedIni(2)-2,wRedIni(2)+2,NumberOfPlotPoints));
                %             [X1, X2] = meshgrid(linspace(w(1)-a,w(1)+a,NumberOfPlotPoints),linspace(w(2)-a,w(2)+a,NumberOfPlotPoints));
                %             wRed = [X1(:) X2(:)];
                %             J = inf(size(wRed,1),1);
                %             for K = 1:length(J)
                %                 J(K) = obliqueGlobalLossFunction(obj, wRed(K,:)', w(end), weightedOutputWorstLM, [],worstLM);
                %             end
                %             figure(99)
                %             clf
                %             surfc(X1,X2,reshape(J,NumberOfPlotPoints,NumberOfPlotPoints))
                % %             keyboard
                
                
                % Check if Optimization was successful
                if successfulOpt
                    if obj.history.displayMode
                        fprintf('\n   Axes-oblique splitting:               J = %f', globalLossFunctionValue);
                    end
                    
                    % If better than the model of the last iteration and the best initial model
                    if globalLossFunctionBest - globalLossFunctionValue > eps  % Check if the optimized model is better
                        globalLossFunctionBest = globalLossFunctionValue;
                        localModelsBest = localModels;
                        leafModelsBest = leafModels;
                        phiBest = phi;
                        outputModelBest = outputModel;
                        phiSimulatedBest = phiSimulated;
                        flagBetterSplitFound = true; % A split was found that decrease the training error
                    end
                    
                else % Optimization failed
                    if obj.history.displayMode
                        fprintf('\n   Axes-oblique splitting:               Optimization Failed!');
                    end
                end
            end
            
        elseif flagPermittedInitialSplitFound % Check if one permitted axes-orthogonal split exist
            % Check if the orthogonal split leads to animprovement of the performance
            if globalLossFunctionBest - globalLossFunctionIni > eps
                globalLossFunctionBest = globalLossFunctionIni;
                leafModelsBest = leafModelsIni;
                localModelsBest = localModelsIni;
                phiBest = phiIni;
                outputModelBest = outputModelIni;
                phiSimulatedBest = phiSimulatedIni;
                flagBetterSplitFound = true; % A permitted split is found, that decrease the training error
            end
            
        end
        
        %% Check if a permitted split of the current worstLM can be done
        if flagBetterSplitFound
            % Break while-loop; no other local models need to be tested
            break
        elseif flagPermittedInitialSplitFound && ~flagBetterSplitFound
            % At least one permitted initial split is found, but no improvement of the training error was achieved
            % Lock the current worstLM for this iteration and go on investigating another local model and lock the worstLM
            obj.idxAllowedLMIter(worstLM) = false;
            if obj.history.displayMode
                fprintf('\n\n%d. Iteration. Split of the %d . Model achieves no improvement. Try another model...', ...
                    obj.history.iteration, worstLM);
            end
        else
            % No permitted split found; go on investigating another local model and lock the worstLM finally
            obj.idxAllowedLM(worstLM) = false;
            if obj.history.displayMode
                fprintf('\n\n%d. Iteration. Model %d can not be splitted. Try another model...', ...
                    obj.history.iteration, worstLM);
            end
        end
        
    end
    
    %% Update model object, if a permitted split is found
    if flagBetterSplitFound
        
        % Perform best split
        
        % update of the model object necessary
        obj = updateModelObject(obj, leafModelsBest, localModelsBest, phiBest, outputModelBest, phiSimulatedBest);
        
        % Reset the logical index vector for each iteration to idxAllowedLM
        obj.idxAllowedLMIter = obj.idxAllowedLM;
        
        % Make history entries
        obj.history = writeHistory(obj.history,obj,tStart);
        
        if obj.history.displayMode
            fprintf('\n-> SPLITTING RESULT:                     J = %f', obj.history.globalLossFunction(end));
        end
    end
    
end

% Restore global loss function of global model
obj.history.globalLossFunction(1) = iniGlobalLossFunction;

% Final display
if obj.history.displayMode
    fprintf('\n\nFinal net has %d local models and %d parameters: J = %f', ...
        sum(obj.leafModels), round(obj.history.currentNumberOfParameters(end)), obj.history.globalLossFunction(end));
    fprintf('\n\nNet %d with %d LMs and %d parameters is suggested as the model with the best complexity trade-off.', ...
        obj.suggestedNet, sum(obj.history.leafModelIter{obj.suggestedNet}), round(obj.history.currentNumberOfParameters(obj.suggestedNet)));
end

% Update model output with suggested model complexity.
obj.leafModels = obj.history.leafModelIter{obj.suggestedNet};
obj.idxAllowedLM = obj.history.idxAllowedLMIter{obj.suggestedNet};
obj.idxAllowedLMIter = obj.idxAllowedLM;

% Final warning for unavailable Optimization Toolbox
if ~flagOptimizationToolbox
    warning('hilomot:train','\n No nonlinear optimization was performed due to the absence of the Optimization Toolbox. Simple orthogonal splits are done.')
end

end






