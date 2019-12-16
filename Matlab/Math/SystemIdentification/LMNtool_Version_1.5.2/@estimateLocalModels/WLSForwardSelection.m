function [inmodel, theta] = WLSForwardSelection(XAll,y,phi,regsToSelect,inmodel)
%% WLSFORWARDSELECTION selects a subset of regressors (columns of XAll) using the method of
%  forward selection.
%
%   The algorithm starts with the offset, i.e. the first column of XAll, and then iteratively adds
%   important regressors to the model. The regressors are rated using a hypothesis test. In each
%   iteration the candidate regressors are orthogonalized to the regressors that are already
%   included in the model. Then the parameters are weighted with their inverse standard deviation of
%   the estimation. This delivers the t-values. The corresponding probability values deliver the
%   information, if a regressor must be included into the model in order to find the best regression
%   fit for the output y. The most important regressor that is included possesses the lowest
%   p-value.
%
%   In contrast to Matlab's stepwisefit, this function allows the application of subset selection in
%   the framework of weighted least squares estimation. Before the algorithm starts, XAll is
%   normalized to zero mean and unit variance. The weighting with the validity function phi comes
%   after the normalization. The first column of XAll is defined as offset and is not allowed to be
%   removed during the subset selection. This ensure a correct hypothess testing.
%
%
%       [inmodel, theta] = WLSForwardSelection(XAll,y,phi,regsToSelect,inmodel)
%
%
%   WLSFORWARDSELECTION inputs:
%       XAll         - (N x nx)  X-regressor matrix with all possible columns (unweighted).
%                                First column is defined as offset!
%       y            - (N x 1)   Output vector (unweighted).
%       phi          - (N x 1)   Validity function values for current local model.
%       regsToSelect - (scalar)  Number of regressors that have to be in the model
%                                after forward selection. Default: [].
%       inmodel      - (logical) Enables the user to initially include model terms.
%                                Must be a logical vector with one value for each
%                                column of X, or a list of column numbers of X.
%
%
%   WLSFORWARDSELECTION outputs:
%       inmodel - (logical) Indicates which model terms are included
%                           after subset selection.
%       theta   - (nx x 1)  Regression coefficients after subset selection.
%
%
%   Requires tcdf.m (Statistics Toolbox).
%   This function is based on Matlab's stepwisefit.m, but customized to the
%   apllication of Weighted Least Squares.
%
%
%   See also estimateParametersLocal, estimateParametersGlobal, estimateParametersGlobalNOE,
%            estimateParametersGlobalIV, LMNBackwardElimination, WLSEstimate,
%            WLSForwardSelection, WLSBackwardElimination, findMinPRESSLambda,
%            orthogonalLeastSquares.
%
%
%   LMNtool - Local Model Network Toolbox
%   Benjamin Hartmann, 06-May-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles


% Check inputs
[N,nxAll] = size(XAll);
if size(y,2)~=1
    error('estimateLocalModels:estimateParametersLocal:WLSForwardSelection','y must be a column vector. Several outputs are not supported.');
end
if size(y,1)~=N
    error('estimateLocalModels:estimateParametersLocal:WLSForwardSelection','X and y must have the same number of rows.');
end
if isempty(phi)
    phi = ones(N,1);
    warning('estimateLocalModels:estimateParametersLocal:WLSForwardSelection','No validity weights delivered. All phi values are set to 1.');
end
if size(phi,1)~=N
    error('estimateLocalModels:estimateParametersLocal:WLSForwardSelection','X, y and phi must have the same number of rows.');
end
if ~isreal(XAll) || ~isreal(y) || ~isreal(phi)
    error('estimateLocalModels:estimateParametersLocal:WLSForwardSelection','X, y and phi must be real-valued.');
end
if size(phi,2)~=1
    error('estimateLocalModels:estimateParametersLocal:WLSForwardSelection','phi must be a column vector.');
end
if nargin>3 && (~isempty(regsToSelect) && ~isscalar(regsToSelect))
    error('estimateLocalModels:estimateParametersLocal:WLSForwardSelection','regsToSelect must be a scalar or empty.');
end
if nargin>3 && (~isempty(regsToSelect) && regsToSelect<1)
    error('estimateLocalModels:estimateParametersLocal:WLSForwardSelection','regsToSelect must have at least the value 1. Otherwise no selection is possible.');
end


% The logical vector inmodel enables the user to initially include model terms.
if nargin < 5 || isempty(inmodel)
    inmodel = false(1,nxAll);
    inmodel(1) = true; % Offset must be included for hypothesis testing.
end
if nargin<4 || isempty(regsToSelect)
    % Define the threshold probability for inclusion of regressors.
    % The amount of terms will be low for low pEnter values.
    pEnter = 0.05;
    regsToSelect = [];
else
    % Force selection
    pEnter = 1;
end
if regsToSelect > nxAll
    regsToSelect = nxAll;
    warning('estimateLocalModels:estimateParametersLocal:WLSForwardSelection','Regressors to select must be less than or equal to number of columns of X!')
end

% Check inmodel logical vector
if islogical(inmodel)
    if length(inmodel)~=nxAll
        error('estimateLocalModels:estimateParametersLocal:WLSForwardSelection',...
            'The inmodel parameter value must be a logical vector with one value for each column of X, or a list of column numbers of X.');
    end
else
    if any(~ismember(inmodel,1:nxAll))
        error('estimateLocalModels:estimateParametersLocal:WLSForwardSelection',...
            'The inmodel parameter value must be a logical vector with one value for each column of X, or a list of column numbers of X.');
    end
    % Convert inmodel to a logical vector.
    inmodel = ismember((1:nxAll),inmodel);
end
if sum(inmodel) == 0
    inmodel(1) = true; % Offset must be included for hypothesis testing.
end
% if regsToSelect < sum(inmodel)
%     warning('estimateLocalModels:estimateParametersLocal:WLSForwardSelection','regsToSelect must have at least the number of terms that must be included.');
%     regsToSelect = sum(inmodel);
% end

% Scale data to mean zero and standard deviation one BEFORE WEIGHTING WITH PHI!
stdX = std(XAll,0,1);
stdX(stdX==0) = 1;
XAll = XAll./stdX(ones(size(XAll,1),1),:);

% Weight rows of X matrix and response y with sqrt(phi)
XAll = bsxfun(@times,sqrt(phi),XAll);
y    = bsxfun(@times,sqrt(phi),y);

% Perform forward selection
go_on = true;
while go_on
    
    % Select current regressors
    X = XAll(:,inmodel);
    
    % QR decomposition
    [Q,R,perm] = qr(X,0);
    
    % Transform output vector
    z = Q'*y;
    
    % Explanation:
    % y = X*theta transforms to Q'*y = R*theta, i.e.:
    % X = Q*R
    % y = Q*R*theta
    % Q'*y = (Q'*Q)*R*theta
    % Q'*y = R*theta, because Q'*Q = eye(nx,nx)
    % theta = R \ Q'*y
    
    % Check rank of R in order to remove dependent columns of X
    nx = sum(inmodel);
    tol = max(N,nx)*eps(class(X));
    if ~isempty(R)
        keepCols = (abs(diag(R)) > tol*abs(R(1)));
    else
        keepCols = false(1,nxAll);
    end
    rankX = sum(keepCols);
    if rankX < sum(inmodel)
        R = R(keepCols,keepCols);
        Q = Q(:,keepCols);
        z = z(keepCols,:);
        perm = perm(keepCols);
    end
    z( abs(z) < tol*max(abs(z)) ) = 0;
    
    % Estimate parameters
    theta = zeros(nx,1);
    theta(perm) = R \ z;
    
    % Calculate leverage: diag(S) = diag( W*X*inv(X'*W*X)*X'*W ) , where yHat = S*y
    leverage = phi.*sum(abs(Q).^2,2);
    
    % Calculate effective number of observations and effective DOF nEff: trace(S), where yHat = S*y;
    nEffi = sum(leverage);
    Ni = sum(phi);
    
    % Residual
    residual = y-X*theta;
    
    % Compute separate added-variable coefficients and their standard errors
    XCand = XAll(:,~inmodel);       % Candidate predictors
    XOrtho = XCand - Q*(Q'*XCand);  % Remove effect of "in" predictors on "out" predictors.
                                    % Applies the Orthogonalization XOut = XCand - X*inv(X'*X)*X'*XCand.
    yOrtho = residual;              % Remove effect of "in" predictors on response,
                                    % i.e. take error y-X*theta as new response.
    
    xx  = sum(XOrtho.^2,1);                          % equals X_org'*W*X_org (for each candidate regressor)
    xWx = sum(bsxfun(@times,sqrt(phi),XOrtho).^2,1); % equals X_org'*W^2*X_org
    
    % Set coefficients of dependent "in"-columns to zero.
    perfectxfit = (xx<=tol*sum(XCand.^2,1));
    if any(perfectxfit)           
        XOrtho(:,perfectxfit) = 0;
        xx(perfectxfit) = 1;
    end
    thetaOrtho = (yOrtho'*XOrtho)./xx;  % For each candidate regressor i individually: thetaOrtho = inv(XOrtho_i'*XOrtho_i)*XOrtho_i'*yOrtho.
    residOrtho = repmat(yOrtho,1,sum(~inmodel)) - XOrtho .* repmat(thetaOrtho,N,1); % Residuals of each candidate regressor.
    
    DOF           = max(0,Ni - nEffi - 1);
    MSEOrtho      = sum(residOrtho.^2,1)/DOF;
    stdThetaOrtho = sqrt( xWx./(xx.^2) .* MSEOrtho ); % Standard deviations for all candidate prediction terms,
    % equals sqrt(inv(X_org'*W*X_org)*X_org'*W^2*X_org*inv(X_org'*W*X_org)*MSE).
    
    
    % Compute t-values and p-values
    tVal = zeros(nxAll,1);
    pVal = zeros(nxAll,1);
    if DOF>0
        tVal(~inmodel) = thetaOrtho./stdThetaOrtho;
        pVal(~inmodel) = 2*tcdf( -abs(tVal(~inmodel)) , DOF );
    else
        pVal(~inmodel) = NaN;
    end
    
    % Store back zeros for coefficients that were removed
    thetaAll = zeros(nxAll,1);
    thetaAll(inmodel)  = theta;
    thetaAll(~inmodel) = thetaOrtho;
    
    % Unscale parameter vector
    theta = thetaAll./stdX';
    
    % Check which terms should be removed
    includeIdx = 0;
    
    % Look for terms out that should be in
    termsout = find(~inmodel);
    if ~isempty(termsout)
        [pmin,kmin] = min(pVal(termsout));
        if pmin<=pEnter
            includeIdx = termsout(kmin(1));
        end
    end
    
    % Loop termination check
    if includeIdx == 0 || sum(inmodel)==nxAll
        go_on = false;
    else
        if sum(inmodel)>=regsToSelect
            % Stop selection if user defined number of regressors reached
            go_on = false;
        else
            inmodel(includeIdx) = true;
            go_on = true;
        end
    end
    
end
end