function [obj, thetaAll] = estimateParametersGlobal(obj, estimationProcedure)
%% ESTIMATEPARAMETERSGLOBAL estimates the parameters of all local models globally with one single step.
%
%   ESTIMATEPARAMETERSGLOBAL is a stand-alone method that can be applied to any trained LMN object.
%   All previously stored parameters in the object are deleted, because they're not valid anymore
%   after the global estimation. The global estimation must be performed separately for each model
%   complexity.
%
%   By default, the paramters are estimated with ordinary LS. In this case, 'LS' is used as
%   estimationProcedure. Furthermore, the parameter estimation can be regularized using ridge
%   regression, if 'RIDGE' is used as estimationProcedure. Then, the regularization parameter lambda
%   is optimized w.r.t. the Leave-One-Out-score or PRESS-value, respectively. A mixed global-local
%   estimation is performed using 'GLOBLOC' as estimation method. After estimation, the estimated LM
%   parameters are stored in the object.
%
%   The following methods are implemented:
%
%       'LS'      - Global least squares estimation.
%       'RIDGE'   - Global LS estimation, regularized with ridge regression.
%       'GLOBLOC' - Global estimation that is regularized such that it results in locally
%                   estimated parameters. But the estimation is performed in one single step.
%
%
%       [obj thetaAll] = estimateParametersGlobal(obj, estimationProcedure)
%
%
%   ESTIMATEPARAMETERSGLOBAL input:
%       estimationProcedure - (string) Defines estimation procedure: 
%                                      [ {'LS'} | 'RIDGE' | 'GLOBLOC' ]
%
%   ESTIMATEPARAMETERSGLOBAL outputs:
%       obj      - (object)  Object containing newly estimated LM parameters.
%       thetaAll - (1 x M)   Cell array containing the estimated output
%                            weights for each local model.
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



%% Reliability check for input variables

% If no estimationProcedure is explicitly given, use the same as stored in the object
if nargin < 2
    estimationProcedure = obj.estimationProcedure;
end

% Get matrices for estimation out of object
try
    xRegressor = obj.xRegressor;
    output     = obj.output;
    dataWeighting = obj.dataWeighting;
    if any(strcmp(superclasses(obj),'gaussianOrthoGlobalModel'))
%         error('estimateLocalModels:estimateParametersGlobal','Global estimation is not implemented for orthogonal gaussian models. Abort training!')
        validity = obj.calculateVFV(obj.MSFValue,obj.leafModels);
    else
        validity = obj.phi(:,obj.leafModels);
    end
catch
    error('estimateLocalModel:estimateParametersGlobal','No matrices available for estimation! Check X, y and phi.')
end

% Get some constants
[numberOfSamples,numberOfxRegressors] = size(xRegressor);
M = sum(obj.leafModels);

% Set dataWeighting to default, if not defined already.
if ~exist('dataWeighting','var') || isempty(dataWeighting)
    dataWeighting = ones(numberOfSamples,1);
end
% All variables must have the same number of rows corresponding to the number of samples.
if any([size(output,1) ~= numberOfSamples, size(validity,1) ~= numberOfSamples, size(dataWeighting,1) ~= numberOfSamples])
    error('estimateLocalModel:estimateParametersGlobal','Missmatching number of samples between xRegressor, output, validity or data weighting!')
end
% Check size of validity function matrix.
if all(size(validity) ~= [numberOfSamples M])
    error('estimateLocalModel:estimateParametersGlobal', '<validityFunctionValue> must be a matrix whose number of rows and columns must match with the number of samples and the number of local models.')
end
% Check for complex entries.
if ~isreal(xRegressor) || ~isreal(output) || ~isreal(validity)
    error('estimateLocalModel:estimateParametersLocal','<xRegressor>, <output> and <validityFunctionValue> must be real-valued.');
end
% Check if data is too spares and give warning
if obj.history.displayMode && (numberOfSamples < M*numberOfxRegressors)
    warning('estimateModel:estimateParametersGlobal','Data is actually too sparse for a reliable estimate of the parameters!');
end


%% Global estimation of the local model parameters

% Initialize
thetaAll = cell(1,M);

% Perform data weighting, if any element of dataWeighting has not value 1.
if any(dataWeighting~=1)
    validity = bsxfun(@times,dataWeighting,validity);
end

% Assembly of the weighted regression matrix for global estimation and storing of the correct indices.
XAll = [];
idxLeafModels = find(obj.leafModels);
idxMatrixLeafModels = NaN(size(xRegressor,2),numel(idxLeafModels));
for currentLeafModel = 1:numel(idxLeafModels)
    idxCurrentLeafModel = obj.localModels(idxLeafModels(currentLeafModel)).parameter ~= 0;
    idxMatrixLeafModels(:,currentLeafModel) = idxCurrentLeafModel;
    XAll = [XAll, bsxfun(@times,validity(:,currentLeafModel),xRegressor(:,idxCurrentLeafModel))];  % Global regression matrix
end

% Switch between different estimation methods
switch estimationProcedure
    
    case 'LS'  % Ordinary global least-squares estimation.
        
        % Global LS estimation for all LM at once
        theta = pinv(XAll)*output; % For numerical robustnes: pseudoinverse using SVD.
        
    case 'RIDGE'  % Estimation using SVD. Lambda is optimized w.r.t. the PRESS value / LOO-cross validation.
        
        % Produce the singular value decomposition of XAll.
        [U,S,V]=svd(XAll,'econ');
        p = size(S,1);
        
        % Optimiere lambda bezüglich Leave-One-Out-Fehler = PRESS
        myOptions = optimset;
        myOptions = optimset(myOptions,'Display','off','Diagnostics','off');
        
%         % Plot Lossfunction Opt
%         NumberOfPlotPoints = 1e4;
%         lambda = linspace(0,1e-3,NumberOfPlotPoints)';
%         J = inf(size(lambda,1),1);
%         parfor K = 1:length(J)
%             J(K) = findMinPRESSLambdaNew(lambda(K), U,S,output);
%         end
%         figure(99)
%         clf
%         hold on
%         plot(lambda,J,'x-')
%         plot(1e-8,obj.findMinPRESSLambda(1e-8, U,S,output),'ro')
%         hold off
%         keyboard
        
%         % First, find a good initial value for lambda in the bounds [1e-10,1e10]
%         [lambdaIni,PRESSIni] = fminbnd(@(lambda) obj.findMinPRESSLambda(lambda,U,S,output) ,1e-10,1e10,myOptions);
%         
%         % Second, perform an unconstrained optimization with the previously found lambdaIni.
%         [lambdaOpt,PRESSOpt] = fminunc(@(lambda) obj.findMinPRESSLambda(lambda,U,S,output) ,lambdaIni, myOptions);
        
        % Better fmincon!!
        [lambdaOpt,PRESSOpt] = fmincon(@(lambda) obj.findMinPRESSLambda(lambda,U,S,output),1,[],[],[],[],1e-10,1e10,[],myOptions);
        
        
        % Calculate the LM parameters
        theta = V*S*((S.^2 + lambdaOpt*eye(p))\eye(p))*U'*output;
        
    case 'GLOBLOC'
        
        % Assembly of the weighted regression matrix for global estimation.
        XAll = zeros(numberOfSamples,numberOfxRegressors*sum(obj.leafModels));
        for currentLeafModel = 1:M
            XAll(:,(currentLeafModel-1)*numberOfxRegressors + (1:numberOfxRegressors)) = bsxfun(@times,validity(:,currentLeafModel),xRegressor);  % Global regression matrix
        end
        
        % Build regularization matrix L
        L = buildPenaltyMatrix(xRegressor, validity);
        
        % Parameter for regularization:
        % If alpha = 1: Local Estimation
        % If alpha = 0: Global Estimation
        %
        % J = e'*e + alpha* w'*L*w
        %
        alpha = 1;
        
        % Global LS estimation for all LM at once
        theta = pinv(XAll'*XAll + alpha*L)*XAll'*output; % For numerical robustnes: pseudoinverse using SVD.
        
    otherwise
        % intended estimation prodedure is not implemented?
        error('estimateModel:estimateParametersGlobal','Unknown estimation procedure: use "LS" or "RIDGE"')
end

if nargout == 2
    % Initialize
    thetaAll = cell(1,M);
    % Re-arrange the parameters in the cell thetaAll
    for currentLeafModel = 1:M
        thetaAll{currentLeafModel} = theta((currentLeafModel-1)*numberOfxRegressors + (1:numberOfxRegressors),:);
    end
end

% Re-arrange the parameters in the cell thetaAll
for currentLeafModel = 1:numel(idxLeafModels)
    idxCurrentLeafModel = find(idxMatrixLeafModels(:,currentLeafModel));
    thetaCurrent = theta(1:numel(idxCurrentLeafModel));
    theta(1:numel(idxCurrentLeafModel)) = [];

    obj.localModels(idxLeafModels(currentLeafModel)).parameter(idxCurrentLeafModel) = thetaCurrent;
end
% Delete all parameters in knots, because they're not valid anymore.
knots = find(~obj.leafModels);
for k = 1:sum(~obj.leafModels)
    obj.localModels(knots(k)).parameter = [];
end

%% Use only the leaf models to calculate the model output
% First try without centered local models
obj.outputModel = calculateModelOutputTrain(obj,obj.localModels(obj.leafModels),validity,obj.leafModels,zeros(size(obj.output)));

% Calculate the local loss function values for all leaf models
localLossFunctionValue = calcLocalLossFunction(obj, obj.unscaledOutput, obj.outputModel , validity);
for k = 1:M
    % Allocate the corrected local loss function value to each local model
    obj.localModels(idxLeafModels(k)).localLossFunctionValue = localLossFunctionValue(k);
end

% Update the history object
obj.history = writeHistory(obj.history,obj);

end


function L = buildPenaltyMatrix(xRegressor, phi)
% Builds up the penalty matrix L used for global/local regularization according to Zimmerschied of local linear models

% Get some constants
[N, nx] = size(xRegressor);
M = size(phi,2);

% Build up weighting matrix L for global-local regularization
L = zeros(M*nx,M*nx);
xRegressorWeighted = zeros(N,nx);
for LM1 = 1:M
    for LM2 = LM1:M
        for reg = 1:nx
            if LM1 == LM2
                xRegressorWeighted(:,reg) = (phi(:,LM1)-phi(:,LM2).^2).*xRegressor(:,reg);
            else
                xRegressorWeighted(:,reg) = -phi(:,LM1).*phi(:,LM2).*xRegressor(:,reg);
            end
        end
        L((LM1-1)*nx+1:LM1*nx,(LM2-1)*nx+1:LM2*nx) = xRegressor'*xRegressorWeighted;
        if LM1 ~= LM2
            L((LM2-1)*nx+1:LM2*nx,(LM1-1)*nx+1:LM1*nx) = xRegressor'*xRegressorWeighted;
        end
    end
end
end

function  PRESS = findMinPRESSLambdaNew(lambda,U,S,y)


p = size(S,1);
[N q] = size(y);


if lambda~=0
    hatMat = -lambda*U*((S.^2 + lambda*eye(p))\eye(p)-1/lambda*eye(p))*U';
else
    hatMat = U*U';
end

PRESS = 0;
for k = 1:q
    PRESS  = PRESS + sum( ((y(:,k) - hatMat*y(:,k)) ./ (ones(N,1) - diag(hatMat))).^2 )/N;
end
end