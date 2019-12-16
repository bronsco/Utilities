function directionWeighting = splitAnalysis(obj,modelComplexity)
%% SPLITANALYSIS uses the partition of the rule premises' input space for a ranking of the nonlinear inputs.
%
%   For each input of the rule premises a value of importance is calculated
%   based on the splits of the local model object.
%
%
%       directionWeighting = splitAnalysis(obj,modelComplexity)
%
%
% 	splitAnalysis outputs:
%
%       directionWeighting   - (nz x 1) One value for every nonlinear
%                                       input, that corresponds to the
%                                       inputs' importance.
%
% 	splitAnalysis inputs:
%
%       obj                  - (object) Already trained local model object
%       modelComplexity      - (1 x 1)  Number of local models, for which
%                                       the weighting of the nonlinear
%                                       inputs should be calculated.
%
%
%   LMNtool - Local Model Network Toolbox
%   Julian Belz, 06-March-2014
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2014 by Prof. Dr.-Ing. Oliver Nelles

%% Some checks to prevent errors...
if nargin == 1
    if any(strcmp('leafModels', properties(obj)))
        if isempty(obj.leafModels)
            fprintf('\n It seems the passed local model network object has not been trained yet. Aborting... \n\n');
            return;
        else
            % If there is no model complexity passed explicitely, use the
            % suggested model complexity
            modelComplexity = obj.suggestedNet;
        end
    else
        fprintf('\n The first argument you passed seems to be no local model network object. Aborting... \n\n');
        return;
    end
elseif nargin < 1
    fprintf('\n You have to pass an already trained local model network object to the splitAnalysis function. Aborting... \n\n');
    return;
end
% If the modelComplexity argument is passed empty, the following is
% necessary...
if isempty(modelComplexity)
    % If there is no model complexity passed explicitely, use the
    % suggested model complexity
    modelComplexity = obj.suggestedNet;
end

%% Calculation of the nonlinear inputs weightings

% First, set the model complexity to the demanded one
obj.leafModels = obj.history.leafModelIter{modelComplexity};

% Determine the number of split parameters
numberOfSplitParameters = sum(cellfun(@length,obj.zInputDelay)) + sum(cellfun(@length,obj.zOutputDelay));

% Predefine the directionWeihting variable (output of this function)
directionWeighting = zeros(numberOfSplitParameters,1);

% Variable that sums up all validities used for the weighting of the
% splitting parameters. At the end of the following loop, we will divide
% the result by this number.
helpMeCount = 0;

% Define variable, that contains the parent node of all already considered
% splits. This variable is needed to avoid taking one split two times into
% account, in case the sister/brother local model of an already considered
% local model comes into play.
nodeSplits = NaN(1,size(obj.leafModels,2));

% Calculate maximum performance improvement between two training algorithm
% iterations
maxPerformanceImprovement = max(fliplr(diff(fliplr(obj.history.globalLossFunction))));
if maxPerformanceImprovement < 0
    warning('Training error is always increasing! Check model and data!');
end

for ii = 1:size(obj.leafModels,2)
    
    if isa(obj,'hilomot')
        
        % Pick current splitting parameter without the parameter for the
        % offset (the last parameter contained in the 'splittingParameter'
        % property)
        splittingParameter = obj.localModels(ii).splittingParameter(1:end-1);
        
        % Get the parent node of the currently chosen local model
        parentNode = obj.localModels(ii).parent;
        
        % Get sum of validities of all data points in the parent local
        % model
        sumOfParentValidities = sum(obj.phi(:,parentNode),1);
        
    elseif isa(obj,'lolimot')
        
        % Get the parent node of the currently chosen local model
        if ii==1
            % The first local model has no parent node
            parentNode = [];
        else
            
            % For the determination of the parent local model the splitLM
            % property of the modelHistory class is utilized. Each element
            % in this property is the parent of two local models.
            if mod(ii,2) ~= 0
                leafModel = ii-1;
            else
                leafModel = ii;
            end
            
            % The parent index of local model 2 and 3 is found in the first
            % entry of the splitLM property, the parent index of local
            % model 4 and 5 is found in the second entry of the splitLM
            % property and so on. The leafModel variable always contains
            % the even index of two sister/brother models, so the half of
            % the index corresponds to the correct index in the splitLM
            % property.
            parentNode = obj.history.splitLM(leafModel/2);
        end
        
        % Get sum of validities of all data points in the parent local
        % model
        if ~isempty(parentNode) && sum(nodeSplits==parentNode) == 0
            
            % Get split direction of the current local model and create
            % equivalent splitting parameter vector (if this splitting function
            % would have been a sigmoid)
            splitDirection = obj.history.splitDimension(leafModel/2);
            splittingParameter = zeros(numberOfSplitParameters,1);
            splittingParameter(splitDirection) = 1;
            
            % Get the leaf models of the model before the currently
            % investigated split has been made
%             parentLeafModels = obj.history.leafModelIter{leafModel/2+1};

            obj.leafModels = obj.history.leafModelIter{leafModel/2};
            
            
            % Calculate validity values
%             validities = obj.calculateVFV(obj.MSFValue,parentLeafModels);
            validities = calculateValidity(obj,obj.zRegressor,parentNode,obj.MSFValue);
            
            % Sum up the validity values
%             sumOfParentValidities = sum(validities(:,parentNode),1);
            sumOfParentValidities = sum(validities,1);
            
        end
        
    else
        fprintf('\n The passed class type is not yet supported. Aborting... \n\n');
        return;
    end
    
    % Check if the current split has already be considered (this is the
    % case, when the sister/brother local model has already been
    % evaluated)
    if ~isempty(parentNode) && sum(nodeSplits==parentNode) == 0
        % The split has not been considered before
        
        % Add parent node to the nodeSplits variable to avoid taking
        % the sister/brother local model also into account
        nodeSplits(ii) = parentNode;
        
        % Consideration of the model's performance improvement
        
        % Determine corresponding loss function value for the current
        % leaf node
        globalLFindex = ceil((ii-1)/2)+1;
        
        % Previous loss function value. If the current leaf node is the
        % root, take the root's performance as previous performance
        previousLFindex = max([globalLFindex-1 1]);
        
        % Determine weighting for the current performance improvement
        performanceImprovementWeighting = ...
            (obj.history.globalLossFunction(previousLFindex)-obj.history.globalLossFunction(globalLFindex));
        
        % Sum up the direction weightings of all local models
        directionWeighting = directionWeighting + ...
            abs(splittingParameter)*sumOfParentValidities*performanceImprovementWeighting;
        
        % Sum up the direction weightings of all local models
        %         directionWeighting = directionWeighting + abs(splittingParameter)*sumOfParentValidities;
        
        % Increase the variable's value, that contains the sum of all
        % data points used as weighting factors for the splitting
        % parameters
        helpMeCount = helpMeCount + sumOfParentValidities;
        
    end
    
end

%
% directionWeighting = directionWeighting./helpMeCount;
directionWeighting = directionWeighting./sum(directionWeighting);

end