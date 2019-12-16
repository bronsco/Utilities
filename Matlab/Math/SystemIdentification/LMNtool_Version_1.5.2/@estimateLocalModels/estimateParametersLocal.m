function theta = estimateParametersLocal(obj, xRegressor, output, validity, ...
    regressorsToSelect, dataWeighting)
%% ESTIMATEPARAMETERSLOCAL estimates the parameters of a local model.
%
%   In order to perform local estimation, the regressor matrix and the output targets are weighted
%   with their associated validity function value. The user has the possibility to incorporate prior
%   knowledge in terms of a data weighting vector. This allows a specific weighting of the data,
%   e.g., if the user knows about uncertainties in some data regions. If the process has several
%   outputs, the data weighting is a matrix with q columns. The estimated parameters are stored in
%   coeff.
%
%
%       [theta] = estimateParametersLocal(obj, xRegressor, output, validity, ...
%       	regressorsToSelect, dataWeighting)
%
%
%   ESTIMATEPARAMETERSLOCAL inputs:
%
%       xRegressor             - (N x nx) Matrix containing the complete
%                                         regression matrix (columns of
%                                         used regressors).
%       output                 - (N x q)  Output vector.
%       validity               - (N x 1)  Array of validity of the local model.
%       regressorsToSelect     - (1 x 1)  Indicates how many regressor have to be chosen.
%       dataWeighting          - (N x 1)  Weight for each data point (optionally).
%
%
%
% 	ESTIMATEPARAMETERSLOCAL output:
%
%       theta - (nx x q) Array containing the local model parameters estimated with weighted LS.
%
%
%   See also estimateParametersLocal, estimateParametersGlobal, estimateParametersGlobalNOE,
%            estimateParametersGlobalIV, LMNBackwardElimination, WLSEstimate,
%            WLSForwardSelection, WLSBackwardElimination, findMinPRESSLambda,
%            orthogonalLeastSquares.
%
%
%   LMNtool - Local Model Network Toolbox
%   Benjamin Hartmann, 16-January-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles



% Get some constants
maxDelay = obj.getMaxDelay();
output = output(maxDelay+1:end,:);

[numberOfSamples, numberOfxRegressors] = size(xRegressor);
numberOfOutputs = size(output,2);



%% Reliability check for input variables

% Set dataWeighting to default, if not defined already.
if ~exist('dataWeighting','var') || isempty(dataWeighting)
    dataWeighting = ones(numberOfSamples,1);
end

% All variables must have the same number of rows corresponding to the number of samples.
if any([size(output,1) ~= numberOfSamples, size(validity,1) ~= numberOfSamples, size(dataWeighting,1) ~= numberOfSamples])
   % error('estimateLocalModel:estimateParametersLocal','Missmatching number of samples between xRegressor, output, validity or data weighting!')
end

% Set validityFunctionValue to default if not defined.
if ~exist('validity','var') || isempty(validity)
    validity = ones(numberOfSamples,1);
end

% Check, if the number of validity function values match to the number of samples.
if all(size(validity) ~= [numberOfSamples 1])
    error('estimateLocalModel:estimateParametersLocal','<validityFunctionValue> must be a column vector with N entries')
end

% Check for complex entries.
if ~isreal(xRegressor) || ~isreal(output) || ~isreal(validity)
    error('estimateLocalModel:estimateParametersLocal','<xRegressor>, <output> and <validityFunctionValue> must be real-valued.');
end

% Check for subset selection options.
if strcmp(obj.estimationProcedure,'STEPWISE_LS')
    warning('estimateLocalModel:estimateParametersLocal','Please use <FORWARD_SELECTION> instead of <STEPWISE_LS> as estimation procedure. Now, this is switched automatically.');
    obj.estimationProcedure = 'FORWARD_SELECTION';
end
if strcmp(obj.estimationProcedure,'REDUCED_STEPWISE_LS')
    warning('estimateLocalModel:estimateParametersLocal','Please use <REDUCED_FORWARD_SELECTION> instead of <REDUCED_STEPWISE_LS> as estimation procedure. Now, this is switched automatically.');
    obj.estimationProcedure = 'REDUCED_FORWARD_SELECTION';
end


estimationProcedure = obj.estimationProcedure;

if exist('regressorsToSelect','var') && ~isempty(regressorsToSelect) && any([strcmp(estimationProcedure,'FORWARD_SELECTION') strcmp(estimationProcedure,'REDUCED_FORWARD_SELECTION') strcmp(estimationProcedure,'BACKWARD_ELEMINATION') strcmp(estimationProcedure,'OLS') strcmp(estimationProcedure,'LARS')])
    if regressorsToSelect >= numberOfxRegressors
        estimationProcedure = 'LS';
    end
end

%% Local estimation of the model parameters

% Initialize the parameter vector
theta = zeros(numberOfxRegressors, numberOfOutputs);

% Perform data weighting, if any element of dataWeighting has not value 1.
if any(dataWeighting~=1)
    validity = validity.*dataWeighting;
end

% Switch between different estimation methods
switch estimationProcedure
    
    case 'LS'
        % Perform weighted LS estimation
        theta = obj.WLSEstimate(xRegressor,output,validity);
        
    case 'RIDGE'
        % Perform weighted LS estimation combined with ridge regression
        lambda = obj.lambda;
        if isempty(obj.lambda)
            lambda = obj.lambdaDefault;
        end
        theta = obj.WLSEstimate(xRegressor,output,validity,lambda);
        
    case 'FORWARD_SELECTION'
        
        % Perform forward selection with iterative t-test.
        for out = 1:numberOfOutputs
            [inmodel, theta(:,out)] = obj.WLSForwardSelection(xRegressor,output(:,out),validity,regressorsToSelect);
            theta(~inmodel,out) = 0;
        end
        
    case 'REDUCED_FORWARD_SELECTION'
        
        % Ensure, that at least the offset and the linear terms are included in each local model; if more regressors are intended use
        % subset selection.
        initialRegs = false(1,numberOfxRegressors);
        initialRegs(1:obj.numberOfInputs+1) = true;
        
        % Perform forward selection with a given initial set of regressors.
        for out = 1:numberOfOutputs
            [inmodel, theta(:,out)] = obj.WLSForwardSelection(xRegressor,output(:,out),validity,regressorsToSelect,initialRegs);
            theta(~inmodel,out) = 0;
        end
        
    case 'BACKWARD_ELIMINATION'
        
        % Perform backward elimination.
        for out = 1:numberOfOutputs
            [inmodel, theta(:,out)] = obj.WLSBackwardElimination(xRegressor,output(:,out),validity);
            theta(~inmodel,out) = 0;
        end
        
    case 'OLS'
        
        % Apply Orthogonal Least Squares as subset selection algorithm
        for out = 1:numberOfOutputs
            
            % Weight rows of X matrix and response y with sqrt(phi)
            xRegressorWeighted = bsxfun(@times,sqrt(validity),xRegressor);
            outputWeighted     = bsxfun(@times,sqrt(validity),output(:,out));
            
            % NOTICE: The column order of thetaReduced must correspond to the order in subsetSelectionIndexCoeff!
            [thetaReduced, subsetSelectionIndexCoeff] = obj.orthogonalLeastSquares(xRegressorWeighted, outputWeighted, regressorsToSelect, obj.minErrorImprovement, obj.thresholdLinearDependency);
            
            % Update parameter vector with the selected regressors from OLS
            theta(subsetSelectionIndexCoeff,out) = thetaReduced;
        end
    case 'TLS'
        % Calls 'WGTLSEstimate' with the Info that the complete Regressor
        % is disturbed by noise
        yNoisy=true;
        for out=1:numberOfOutputs
            xRegressor=xRegressor(:,2:end);
            NoiseRegressor = [output(:,out),xRegressor];
            NoiseFreeRegressor=[];
            [thetaWoBias, bias] = obj.WGTLSEstimate(NoiseRegressor,NoiseFreeRegressor,validity,yNoisy);
            theta(:,out) = [bias; thetaWoBias];
        end
    case 'GTLS'
        yNoisy=true;
        numOfNoiseInputs=sum(cellfun(@length,obj.xOutputDelay));
        xRegressor=xRegressor(:,2:end);
        numOfInputs=size(xRegressor,2);
        for out=1:numberOfOutputs
            NoiseRegressor = [output(:,out),xRegressor(:,numOfInputs-numOfNoiseInputs+1:end)];
            NoiseFreeRegressor = xRegressor(:,1:numOfInputs-numOfNoiseInputs);
            [thetaWoBias, bias] = obj.WGTLSEstimate(NoiseRegressor,NoiseFreeRegressor,validity,yNoisy);
            thetaWoBias = circshift(thetaWoBias(:,out),-numOfNoiseInputs);
            theta(:,out) = [bias ; thetaWoBias];
        end
        
    case 'LARS'
        % Least Angle Regressions Splines: Least angle regressions using Lasso!
        
        % Set options.
        options = glmnetSet;
        options.dfmax = regressorsToSelect-1;
        options.weights = validity;
        options.nlambda = 200; % default is 100; higher values, higher resolution.
        
        % Perform weigthed lars algorithm.
        for out = 1:numberOfOutputs
            % Use lasso for selection
            % Regularization is not inteded, recalculate with simple Least-Squares
            fitLARS = glmnet(xRegressor(:,2:end),output(:,out),[],options);
            
            idxLarsBest = [];
            numDF = regressorsToSelect-1;
                        
            % Select the best Subset.
            while isempty(idxLarsBest)
                
                try idxLarsBest = find(fitLARS.df == numDF,1,'first');
                catch
                    keyboard
                end
                    
                if ~isempty(idxLarsBest)
                    break % The intended number of coefficients is reached.
                end
                
                % Take the smaller best subset!
                numDF = numDF - 1;
                
                % Check if the degrees of freedom is smaller than one.
                if numDF < 1
                    lambdaMax = fitLARS.lambda(find(fitLARS.df < regressorsToSelect-1,1,'first'));
                    lambdaMin = fitLARS.lambda(find(fitLARS.df > regressorsToSelect-1,1,'first'));
                    try
                        options.lambda = logspace(log10(lambdaMax),log10(lambdaMin),50);
                    catch
                        keyboard
                    end
                    fitLARS = glmnet(xRegressor(:,2:end),output(:,out),[],options);
                    numDF = regressorsToSelect-1;
%                     keyboard
                end
                
            end
            
            %             figure; glmnetPlot(fitLARS,'dev',true);line([fitLARS.dev fitLARS.dev]',[-ones(size(fitLARS.dev,1),1) ones(size(fitLARS.dev,1),1)]'*0.3,'LineStyle','--','Color',[0 0 1])
            
            % Check different lambdas, same DF, different selections.
            I = find(fitLARS.df == fitLARS.df(idxLarsBest));
            if sum(sum(fitLARS.beta(:,I) ~=0,2)==length(I))~=fitLARS.df(idxLarsBest)
%                 figure; glmnetPlot(fitLARS,'dev',true);line([fitLARS.dev(I) fitLARS.dev(I)]',[-ones(size(fitLARS.dev(I),1),1) ones(size(fitLARS.dev(I),1),1)]'*0.3,'LineStyle','--','Color',[0 0 1])
%                 keyboard
            end
            
            theta([true; fitLARS.beta(:,idxLarsBest)~=0],out) =  obj.WLSEstimate(xRegressor(:,[true; fitLARS.beta(:,idxLarsBest)~=0]),output(:,out),validity);

        end
        
    otherwise
        error('estimateLocalModel:estimateParametersLocal','Unknown estimation procedure: use "LS", "RIDGE", "FORWARD_SELECTION", "REDUCED_FORWARD_SELECTION", "BACKWARD_ELIMINATION", "OLS", "GTLS" or "LARS".')
        
end

end