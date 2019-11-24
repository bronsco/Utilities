function [inmodel, theta] = WLSBackwardElimination(XAll,y,phi,regsToSelect,inmodel,keepcols)
%% WLSBACKWARDELIMINATION selects a subset of regressors (columns of XAll) using the method of
%  backward elimination. The algorithm starts with the whole set of regressors and then iteratively
%  eliminates unimportant regressors.
%
%   The regressors are rated using a hypothesis test. The parameters theta are weighted with their
%   inverse standard deviation of the estimation. This delivers the t-values. The corresponding
%   probability values deliver the information, if a regressor can be eliminated or must be included
%   in order to find the best regression fit for the output y. The most unimportant regressor
%   possesses the highest p-value.
%
%   In contrast to Matlab's stepwisefit, this function allows the application of subset selection in
%   the framework of weighted least squares estimation. Before the algorithm starts, XAll is
%   normalized to zero mean and unit variance. The weighting with the validity function phi comes
%   after the normalization. The first column of XAll is defined as offset and is not allowed to be
%   removed during the subset selection. This ensure a correct hypothesis testing.
%
%
%       [inmodel, theta] = WLSBackwardElimination(XAll,y,phi,inmodel,keepcols)
%
%
%   WLSBACKWARDELIMINATION inputs:
%       XAll         - (N x nx)  X-regressor matrix with all possible columns (unweighted).
%                                First column is defined as offset!
%       y            - (N x 1)   Output vector (unweighted).
%       phi          - (N x 1)   Validity function values for current local model.
%       regsToSelect - (scalar)  Number of regressors that have to be in the model
%                                after backward elimination. Default: [].
%       inmodel      - (logical) Enables the user to initially include model terms.
%                                Must be a logical vector with one value for each
%                                column of X, or a list of column numbers of X.
%       keepcols     - (logical) Specifies which regression terms must be included.
%
%
%   WLSBACKWARDELIMINATION outputs:
%       inmodel - (logical) Indicates which model terms are included
%                           after subset selection.
%       theta   - (nx x 1)  Regression coefficients after subset selection.
%
%
%   Requires tcdf.m (Statistics Toolbox).
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
   error('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination','y must be a column vector. Multiple outputs are not supported.');
end
if size(y,1)~=N
   error('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination','X and y must have the same number of rows.');
end
if isempty(phi)
    phi = ones(N,1);
    warning('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination','No validity weights delivered. All phi values are set to 1.');
end
if size(phi,1)~=N
    error('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination','X, y and phi must have the same number of rows.');
end
if ~isreal(XAll) || ~isreal(y) || ~isreal(phi)
    error('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination','X, y and phi must be real-valued.');
end
if size(phi,2)~=1
    error('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination','phi must be a column vector.');
end
if nargin>3 && (~isempty(regsToSelect) && ~isscalar(regsToSelect))
    error('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination','regsToSelect must be a scalar or empty.');
end
if nargin>3 && (~isempty(regsToSelect) && regsToSelect<1)
    error('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination','regsToSelect must have at least the value 1. Otherwise no selection is possible.');
end
if nargin < 6 || isempty(keepcols)
    keepcols = false(1,nxAll);
    keepcols(1) = true; % Offset must be included for hypothesis testing.
end
if nargin < 5 || isempty(inmodel)
    inmodel = true(1,nxAll);
end
if nargin < 4 || isempty(regsToSelect)
    % Define the threshold probability for rejection of regressors.
    % The amount of terms will be low for low pRemove values.
    pRemove = 0.1;
    regsToSelect = 1;
else
    % Force term elimination until regsToSelect reached.
    pRemove = 0;
end
if regsToSelect > nxAll
    regsToSelect = nxAll;
    warning('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination','regsToSelect must be less or at least equal to the number of columns in X.');
end

% Check inmodel logical vector
if islogical(inmodel)
   if length(inmodel)~=nxAll
      error('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination',...
          'The inmodel parameter value must be a logical vector with one value for each column of X, or a list of column numbers of X.');
   end
else
   if any(~ismember(inmodel,1:nxAll))
      error('estimateLocalModels:estimateParametersLocal:WLSBackwardElimination',...
          'The inmodel parameter value must be a logical vector with one value for each column of X, or a list of column numbers of X.');
   end
   % Convert inmodel to a logical vector.
   inmodel = ismember((1:nxAll),inmodel);
end
if sum(inmodel) == 0
    inmodel(1) = true; % Offset must be included for hypothesis testing.
end

% Check keepcols logical vector
if islogical(keepcols)
   if length(keepcols)~=nxAll
      error('estimateLocalModel:estimateParametersLocal:WLSBackwardElimination',...
          'The keepcols parameter value must be a logical vector with one value for each column of X, or a list of column numbers of X.');
   end
else
   if any(~ismember(keepcols,1:nxAll))
      error('estimateLocalModel:estimateParametersLocal:WLSBackwardElimination',...
          'The keepcols parameter value must be a logical vector with one value for each column of X, or a list of column numbers of X.');
   end
   % Convert inmodel to a logical vector.
   keepcols = ismember((1:nxAll),keepcols);
end

% Check regsToSelect
if regsToSelect > sum(inmodel)
    regsToSelect = sum(inmodel);
    warning('estimateLocalModel:estimateParametersLocal:WLSBackwardElimination','Regressors to select must be less than the number of columns of X!')
elseif regsToSelect < 1
    regsToSelect = 1;
    warning('estimateLocalModel:estimateParametersLocal:WLSBackwardElimination',...
        'The model must consist of at least one regressor after subset selection, therefore the scalar value regsToSelect must be greater than zero.')
end

% Scale data to mean zero and standard deviation one
stdX = std(XAll,0,1);
stdX(stdX==0) = 1;
XAll = XAll./stdX(ones(size(XAll,1),1),:);

% Weight rows of X matrix and response y with sqrt(phi)
XAll = bsxfun(@times,sqrt(phi),XAll);
y    = bsxfun(@times,sqrt(phi),y);

if  regsToSelect == sum(inmodel)
    % No backward elimination required
    theta = zeros(nxAll,1);
    theta(inmodel) = XAll(:,inmodel) \ y;
    theta = theta./stdX';
    go_on = false;
else
    go_on = true;
end

% Perform backward elimination
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
    keepCols = (abs(diag(R)) > tol*abs(R(1)));
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
    
    % Remove weights that are almost zero
    theta(abs(theta)<tol) = 0;
    
    % Calculate leverage: diag(S) = diag( W*X*inv(X'*W*X)*X'*W ) , where yHat = S*y
    leverage = phi.*sum(abs(Q).^2,2);
    
    % Calculate effective number of observations and effective DOF nEff: trace(S), where yHat = S*y;
    nEffi = sum(leverage);
    Ni = sum(phi);
    
    % Compute the mean squared error MSE = phi'*(y-X*bStandard).^2./(sum(phi)-nEffi)
    NRMSE = norm(y-X*theta)^2/norm(y-mean(y))^2;
    if NRMSE > tol
        MSE = ( y'*y - z'*z )./(Ni-nEffi);
    else % if Ni = nEffi, we have the exact solution for X*theta == y with zero error
        MSE = 0;
    end
    
    % Calculate the standard deviations of the weightes LS estimates
    Rinv = R\eye(size(R));
    stdTheta = zeros(nx,1);
    Rinv2   = (Rinv*Rinv');
    X2      = bsxfun(@times,sqrt(phi),X(:,perm)); % sqrt(W)*Q*R = W*X_org
    Rinv2X2 = Rinv2*X2'; % Pseudo-Inverse inv(X_org'*W*X_org)*X_org'*W                         
    % Calculate the diagonal elements of the covariance matrix of theta
    stdTheta(perm) = sqrt(sum((Rinv2X2.^2),2) * MSE);
    % std =  sqrt( MSE.*diag( (inv(R'*R)*R'*Q'*sqrt(W))*(inv(R'*R)*R'*Q'*sqrt(W))' ) )
    
    % Compute t-values and p-values
    tVal = zeros(nxAll,1);
    tVal(inmodel) = theta./stdTheta;
    pVal = 2*tcdf( -abs(tVal) , Ni-nEffi );
    
    % Store back zeros for coefficients that were removed
    thetaAll = zeros(nxAll,1);
    thetaAll(inmodel)  = theta;
    
    % Unscale parameter vector
    theta = thetaAll./stdX';
    
    % Check which terms should be removed
    removeIdx = 0;
    termsin = find(inmodel & ~keepcols);
    if ~isempty(termsin)
        badterms = termsin(isnan(pVal(termsin)));
        if ~isempty(badterms)
            % Apparently we have a perfect fit but it is also overdetermined.
            % Terms with NaN coefficients may as well be removed.
            removeIdx = isnan(theta(badterms));
            if any(removeIdx)
                removeIdx = badterms(removeIdx);
                removeIdx = removeIdx(1);
            else
                % If there are many terms contributing to a perfect fit, we
                % may as well remove the term that contributes the least.
                % For convenience we'll pick the one with the smallest coeff.
                [~,removeIdx] = min(abs(theta(badterms)));
                removeIdx = badterms(removeIdx);
            end
        else
            [pmax,kmax] = max(pVal(termsin));
            if pmax>pRemove
                removeIdx = termsin(kmax(1));
            end
        end
    end
    
    if removeIdx == 0 || sum(inmodel)==regsToSelect
        go_on = false;
    else
        inmodel(removeIdx) = false;
        go_on = true;
    end
    
end
end