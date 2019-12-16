function [outputModel,validitySimulated,phiAll,psiAll,xRegressor,zRegressor] = simulateParallel(obj,input,output,localModels,leafModels)
%% SIMULATEPARALLEL  Simulates the output of a local linear neuro-fuzzy model.
%
%
%       [outputModel,validitySimulated,phiAll,psiAll,xRegressor,zRegressor] = simulateParallel(obj,input,output,localModels,leafModels)
%
%
%   simulateParallel outputs:
%       outputModel         - (N x q)   Matrix of model outputs
%       validitySimulated   - (N x M)   (Simulated) validities
%       phiAll              - (N x nLM) Validities of all local models 
%       psiAll              - (N x nLM) Membership values of all splitting functions.
%       xRegressor          - (N x nx)  Regression matrix of the consequents (local models).
%       zRegressor          - (N x nz)  Regression matrix of the premises (validity functions).
%
%
%   simulateParallel inputs:
%       input       - (N x nx)  Regression matrix of the consequents (local models).
%       output      - (N x nz)  Regression matrix of the premises (validity functions).
%       localModels - (1 x nLM) Array with all local model objects
%       leafModels  - (1 x nLM) Logical, indicating the leaf models
%
%
%   See also globalModel, addChildren, calculateModelOutput,
%            calculateModelOutputQuick.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 24-April-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles
% 
% Update T.Fischer (16.July.2013)
% Update J.Belz (November 4, 2016)

% Create one-step prediction xRegressor and zRegressor (will be adjusted
% during this function)
[xRegressor,expMat] = obj.data2xRegressor(input,output);
zRegressor = obj.data2zRegressor(input,output);

% Determine data matrix
dataMat = obj.delay2DataMatrix(input,output,obj.xInputDelay,obj.xOutputDelay);

% Number of data samples
numberOfSamples = size(xRegressor,1);

% Number of outputs
numberOfOutputs = obj.info.numberOfOutputs;

% Determine number of regressor inputs
xNumberOfInputRegressorsSum = sum(cellfun(@length,obj.xInputDelay));
zNumberOfInputRegressorsSum = sum(cellfun(@length,obj.zInputDelay));

% preallocation for function outputs
outputModel = zeros(numberOfSamples,numberOfOutputs);
validitySimulated = ones(numberOfSamples,sum(leafModels));
phiAll = ones(numberOfSamples,length(leafModels));
psiAll = ones(numberOfSamples,length(leafModels));

% save output delays to a variable (the get method in the obj is rather slow)
zOutputDelay = obj.zOutputDelay;

% get the parameters of all leaf models
%localParameter = arrayfun(@(cobj) cobj.parameter,obj.localModels(obj.leafModels),'UniformOutput',false);
localParameter = [localModels(leafModels).parameter];
if numberOfOutputs > 1
    parameter_Part = [];
    for k = 1:numberOfOutputs
        parameter_Part{k} = localParameter(:,k:numberOfOutputs:end);
    end
end

% Distinction between gaussianOrtho-related and sigmoidal-related models

% In case of a gaussianOrthoLocalModel determine the upper and lower
% bounds of the hyper-rectangle
if isa(localModels,'gaussianOrthoLocalModel')
    zUpperBound = localModels(1).zUpperBound;
    zLowerBound = localModels(1).zLowerBound;
    centers = cell2mat({localModels(leafModels).center}');
    standardDeviations = cell2mat({localModels(leafModels).standardDeviation}');
    hierarchical_validity = false;
elseif isa(localModels,'sigmoidLocalModel')
    splittingPara = [localModels(2:end).splittingParameter];
    kappa = [localModels(2:end).kappa];
    smoothness = obj.smoothness;
    parent = [0 localModels(2:end).parent];
    hierarchical_validity = true;
else
    error('Local model type not (yet) supported.');
end

% Determine number of delays for all physical outputs
lengthOutputDelays = cellfun(@length,obj.xOutputDelay);

% Determine in which column of the dataMat matrix the outputs begin
startOutputDelay = xNumberOfInputRegressorsSum+1;

% Determine columns in the x regressor matrix in which delayed outputs are
% involved (1/true: delayed output involved)
idxOutputDelay = sum(bsxfun(@ge,expMat(:,startOutputDelay:end),...
    ones(1,sum(lengthOutputDelays))),2) ~= 0;

outputIdx = find(idxOutputDelay);

% Determine all x delays
xDelays = [obj.xInputDelay{:}  obj.xOutputDelay{:}];

startSample = 1;

for k = startSample:numberOfSamples % Through all samples
    %% Build x regressor
    
    % Determine demanded delay for current time step k
    entry = k - xDelays;
    
    for jj=1:length(outputIdx)
        
        % Process model output according to information contained in
        % the exponent matrix
        regressorColumnEntry = 1;
        for mm=1:size(expMat,2)
            if entry(mm) >= 1
                
                if mm < startOutputDelay && ...
                        expMat(outputIdx(jj),mm) ~= 0
                    
                    regressorColumnEntry = regressorColumnEntry * ...
                        dataMat(k,mm)^expMat(outputIdx(jj),mm);
                elseif mm >= startOutputDelay && ...
                        expMat(outputIdx(jj),mm) ~= 0
                    
                    cOut = determinePhysicalOutput(lengthOutputDelays,...
                        startOutputDelay,mm);
                    regressorColumnEntry = regressorColumnEntry * ...
                        outputModel(entry(mm),cOut)^expMat(outputIdx(jj),mm);
                end
            else
                    regressorColumnEntry = xRegressor(k,outputIdx(jj)+1);
            end
        end
        
        % Insert processed model output in xRegressor matrix
        xRegressor(k,outputIdx(jj)+1) = regressorColumnEntry;
        
    end
    

    %% Build z regressor
    %%% As long as the z regressor degree is one, no changes have to be
    %%% done for the zRegressor matrix. If the z regressor degree will be
    %%% increased in the future, replace the zRegressor correction
    %%% (replacement of delayed measured outputs by delayed model outputs)
    %%% as done for the xRegressor correction above.
    idx = zNumberOfInputRegressorsSum + 1; % For regression matrix z
    
    % Fill matrix with output regressors
    for out = 1:numberOfOutputs % Through all outputs
        for outReg = 1:length(zOutputDelay{out}) % Through all output regressors
            kDelay = k-zOutputDelay{out}(outReg);
            if kDelay > 0
                zRegressor(k,idx) = outputModel(kDelay,out);
            end
            idx = idx + 1;
        end
    end
    
    %     % Calculate validity function values, only one row
    %     % phi1row = obj.calculateValidity(zRegressor(k,:),obj.leafModels);
    %     phi1row = calculateValiditySub(obj.localModels,zRegressor(k,:),obj.leafModels);
    %
    %     % save phi(k,:) to variable for function output
    %     phi(k,:) = phi1row;
    %
    %     % Calculate model output for sample k AND MORE THAN ONE OUTPUT!
    %     outputModel(k,:) = obj.calcYhat(xRegressor(k,:),phi1row,localParameter);
    
    %% Calculate model output
    if length(localModels)==1 % there is only one local=global model
        
        outputModel(k,:) = xRegressor(k,:) * localParameter;
        
    else % For more than one local model
        
        if hierarchical_validity
            % Calculate validities for hierarchical model structure
            psi = [1 1./(1+exp( ...
                (kappa./smoothness) .* (zRegressor(k,:)*splittingPara(1:end-1,:) + splittingPara(end,:))...
                ))];
            
            phi = psi;
            for childIdx = 4:length(phi)
                % multiply with parent psi if necessary to calculate phi
                % only the 4th and beyond need to multiplied with their parent!
                phi(childIdx) = phi(childIdx) * phi(parent(childIdx));
            end
            
            % Write validity of leaf models to validity variable
            validitySimulated(k,:) = phi(leafModels);
            
            if nargout > 2
                % During the training necessary for gradient caculation of the golbal loss function.
                psiAll(k,:) = psi;
                phiAll(k,:) = phi;
            end
            
        else
            % Calculate validities for flat model structure
            % Check for data outside the premise input space boundaries
            % this prevents influence of reactivatted gaussians
            % Data outside input space boundary (too large)
            outside = zRegressor(k,:) > zUpperBound;
            zRegressor(k,outside) = zUpperBound(outside);
            % Data outside input space boundary (too small)
            outside = zRegressor(k,:) < zLowerBound;
            zRegressor(k,outside) = zLowerBound(outside);
            
            MSFValue1row = sum((bsxfun(@minus,zRegressor(k,:),centers)./standardDeviations).^2,2)';
            MSFValue1row = exp(-MSFValue1row./2);
            validityRow = MSFValue1row./ sum(MSFValue1row);
            
            % Write validity of leaf models to validity variable
            validitySimulated(k,:) = validityRow;
        end
        
        
        if numberOfOutputs == 1
            % calculation with only ONE output
            outputModel(k,:) = sum(validitySimulated(k,:).*(xRegressor(k,:) * localParameter),2);
        else
            % calculation with several outputs
            temp = cellfun(@(parai) xRegressor(k,:)*parai, parameter_Part,'UniformOutput', false);
            outputModel(k,:) = cellfun(@(tempi) sum(validitySimulated(k,:).*tempi,2), temp);
        end
    end
    
    
    
end

% if any(isinf(outputModel)) || any(isnan(outputModel))
%     warning('sigmoidGlobalModel:simulateParallel', 'INF or NAN value!')
% end

    function cOut = determinePhysicalOutput(lengthOutDelay,startOutDelay,currentXregColumn)
        for ll=1:length(lengthOutDelay)
            if currentXregColumn >= startOutDelay && ...
                    currentXregColumn < startOutDelay+lengthOutDelay(ll)
                cOut = ll;
            end
            startOutDelay = startOutDelay + lengthOutDelay(ll);
        end
    end

end
