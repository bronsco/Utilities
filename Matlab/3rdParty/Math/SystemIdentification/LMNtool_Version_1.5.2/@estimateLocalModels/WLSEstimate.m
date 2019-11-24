function [theta, nEff, leverage, MSE, LOOE, PRESS, stdx, covTheta, errorbar, nEff2, S] = ...
    WLSEstimate(X_org,y_org,phi_org,lambda,X_new,alpha)
%% WLSESTIMATE estimates the parameters of a local model. 
%
%   In order to perform local estimation, the regressor matrix and the output targets are weighted
%   with their associated validity function value. Depending on the input and output arguments,
%   several kinds of statistics can be computed. Therefore, the computational effort strongly
%   depends on the setup. In the following, a detailed description of all inputs and outputs is
%   given.
%
%   CASE OF MULTIPLE OUTPUTS: For more than one output dimension only theta, nEff, leverage, MSE,
%   LOOE and PRESS can be calculated.
%
%
%       [theta, nEff, leverage, MSE, LOOE, PRESS, stdx, covTheta, errorbar, nEff2, S] = ...
%           WLSEstimate(X_org,y_org,phi_org,lambda,X_new,alpha)
%
%
%   WLSESTIMATE inputs:
%       X_org   - (N x nx)     Matrix containing the complete regression matrix (unweighted).
%       y_org   - (N x q)      Output vector (unweighted).
%       phi_org - (N x 1)      Validity function values of current LM.
%       lambda  - (scalar)     Regularization parameter for ridge regression.
%       X_new   - (N_new x nx) Regression matrix for calculation of errorbar on new data.
%       alpha   - (scalar)     Level of confidence for errorbar.
%
%
%   WLSESTIMATE outputs:
%       theta    - (nx x q)    Parameter vector for current LM estimated using WLS.
%       nEff     - (scalar)    Effective number of parameters defined as nEff = trace(S). (First order DOF).
%       leverage - (N x q)     Leverage is used for calculating LOOE & PRESS. leverage = diag(S).
%       MSE      - (scalar)    Mean squared error: MSE = sum((y-X*theta).^2)./(sum(phi)-nEff).
%       LOOE     - (N x q)     Vector containing the leave-one-out error values on each sample.
%       PRESS    -  (scalar)   Predicted residual sum of squares: PRESS = sum(LOOE.^2)/N
%       stdx     - (nx x 1)    Standard deviations of the parameter estimation.
%       covTheta - (nx x nx)   Covariance matrix of the parameter estimation.
%       errorbar - (N_new x 1) Errorbar that is calculated on new data X_new. If X_new is missing,
%                              the errorbar is calculated on the training data X_org.
%       nEff2    - (scalar)    Effective number of parameters defined as nEff2 = trace(S'*S).
%                              (Second order DOF).
%       S        - (N x N)     Smoothing matrix. yModel = S*y_org.   
%
%
%   Some useful notations:
%
%      Using unweighted matrices X_org and y_org and W = diag(phi):
%
%              X = diag(sqrt(phi))*X_org
%              y = diag(sqrt(phi))*y_org
%
%          theta = X \ y
%          theta = (sqrt(W)*X_org) \ (sqrt(W)*y_org)
%          theta = inv(X_org'*W*X_org)*X_org'*W*y_org
%           nEff = sum(diag( W*X_org*inv(X_org'*W*X_org)*X_org'*W ))
%       leverage = diag( W*X_org*inv(X_org'*W*X_org)*X_org'*W )./(phi+eps)
%              S = W*X_org*inv(X_org'*W*X_org)*X_org'*W )
%            MSE = sum( phi.*(y_org-X_org*theta).^2 )./(sum(phi)-nEff)
%           LOOE = sqrt(phi).*((y_org-X_org*theta)./(ones(N,1)-leverage))
%           !!!!!!!! WARNING: LOOE on scaled data!
%          PRESS = sum( phi.*((y_org-X_org*theta)./(ones(N,1)-leverage)).^2 )/N
%           stdx = sqrt(diag(covTheta)) ))
%       covTheta = inv(X_org'*W*X_org)*(X_org'*W.^2*X_org)*inv(X_org'*W*X_org).*MSE
%       errorbar = sqrt( diag(X_new*covTheta*X_new') + MSE)*tval
%          nEff2 = trace(S'*S)
%
%
%   Comments on covariance matrix:
%
%       The following only reflects an approximation of the covariance matrix (used in lscov.m):
%
%       covTheta = inv(X_org'*W*X_org).*MSE
%
%       This would be comutationally much cheaper. But the standard computation which is used e.g.
%       in lscov.m does not hold in the framework of WLS how it is used in the LMNtool. The reason
%       for that is that in contrast to LM weightings in case of lscov the weighting is assumed to
%       be the inverse variance vector. However, one can think about using it as an fast and
%       accurate approximation of covTheta.
%
%
%   Comments on effective number of parameters:
%
%       The following rule holds: The effective number of parameters nEff are allowed to be summed
%       up for the whole model:
%       trace(S_global_model) = (nEff_1+nEff_2+nEff_3+...)
%
%       BUT BE AWARE: The following does NOT hold!
%       trace(S_global_model'*S_global_model) = (nEff2_1+nEff2_2+nEff2_3+...),
%       where S_global_model = S_1+S_2+S_3+... (sum over all local models).
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


% Options
offsetPenalty = false; % Should the offset be penalized in case of ridge regression? (default: false)

% Check inputs
nx = size(X_org,2);
[numberOfSamples, numberOfOutputs] = size(y_org);
if size(y_org,1)~=numberOfSamples
    error('estimateLocalModel:estimateParametersLocal:WLSEstimate','X, y and phi must have the same number of rows.');
end
if isempty(phi_org)
    phi_org = ones(numberOfSamples,1);
    warning('estimateLocalModel:estimateParametersLocal:WLSEstimate','No weights delivered. All phi values are set to 1.');
end
if size(phi_org,1)~=numberOfSamples
%    error('estimateLocalModel:estimateParametersLocal:WLSEstimate','X, y and phi must have the same number of rows.');
end
if size(phi_org,2)~=1
    error('estimateLocalModel:estimateParametersLocal:WLSEstimate','phi must be a column vector.');
end
if ~isreal(X_org) || ~isreal(y_org) || ~isreal(phi_org)
    error('estimateLocalModel:estimateParametersLocal:WLSEstimate','X, y and phi must be real-valued.');
end
if nargin>3 && ~isempty(lambda)
    if ~isscalar(lambda) || lambda<0
        error('estimateLocalModel:estimateParametersLocal:WLSEstimate','lambda must be a scalar greater than zero.');
    end
end
if nargin>4 && ~isempty(X_new)
    if size(X_new,2)~=nx
        error('estimateLocalModel:estimateParametersLocal:WLSEstimate','X and X_new must have the same number of columns.');
    end
end
if nargout > 6 && numberOfOutputs>1
    error('estimateLocalModel:estimateParametersLocal:WLSEstimate',...
        'For more than one output dimension only theta, nEff, leverage, MSE, LOOE and PRESS can be calculated.')
end


% Apply ridge regression, if lambda is given
if nargin>3 && ~isempty(lambda) && lambda ~= 0
    penalty  = sqrt(lambda)*eye(nx);
    offset   = false(1,nx);
    if ~offsetPenalty
        offset   = all(X_org==1);        % Search for offset columns
    end
    penalty  = penalty(~offset,:);   % Offset should not be penalized
    X_org    = [X_org; penalty];
    y_org    = [y_org; zeros(sum(~offset),numberOfOutputs)];
    phi      = [phi_org; ones(sum(~offset),1)];
    ridgeIdx = [false(numberOfSamples,1); true(sum(~offset),1)]; % Exclude terms used for ridge regression
else
    phi      = phi_org;
    ridgeIdx = false(numberOfSamples,1);
end

% Weight rows of X matrix and response y with sqrt(phi)
X = bsxfun(@times,sqrt(phi),X_org);
y = bsxfun(@times,sqrt(phi),y_org);

if nargout == 1
    
    % Standard LS estimation
    theta = X \ y;
    
else
    
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
    tol = max(numberOfSamples,nx)*eps(class(X));
    keepCols = (abs(diag(R)) > tol*abs(R(1)));
    rankX = sum(keepCols);
    if rankX < nx
        warning('estimateLocalModel:estimateParametersLocal:WLSEstimate','Rank deficient, rank = %u, tol = %e',rankX,tol);
        R = R(keepCols,keepCols);
        Q = Q(:,keepCols);
        z = z(keepCols,:);
        perm = perm(keepCols);
    end
    
    % Estimate parameters
    theta = zeros(nx,numberOfOutputs);
    theta(perm,1:numberOfOutputs) = R \ z;
    
    % Remove weights that are almost zero and re-estimate remaining parameters
    % idxBadPara = theta~=0 & abs(theta)<tol;
    % if any(idxBadPara)
    %     setZero = abs(theta)<paratol;
    %     keepCols = ~ismember(perm,find(setZero)); % Find setZero values in the perm vector (QR space) in the correct order as the original X space.
    %     R = R(keepCols,keepCols);
    %     Q = Q(:,keepCols);
    %     z = z(keepCols,:);
    %     perm = perm(keepCols);
    %     theta = zeros(nx,nOut);
    %     theta(perm,1:nOut) = R \ z; % theta = inv(R'*R)*R'*z with z = Q'*y
    % end
    
end

%
% Only compute values that are queried as output argument:
%

%% Compute leverage, nEff, MSE, LOOE and PRESS
if nargout > 1
    
    % Calculate leverage:
    leverage = sum(abs(Q).^2,2);
    leverage(ridgeIdx) = [];
    %
    % Equivalent formulations:
    % leverage.*phi_org = diag(Q*Q').*phi_org = diag( X*inv(X'*X)*X' ).*phi_org = diag(S),
    % when yHat = W*X_org*theta = S*y_org
    % S = W*X_org*inv(X_org'*W*X_org)*X_org'*W, with W = diag(phi_org)
    
    % Calculate effective DOF nEff: trace(S)
    nEff = sum(leverage.*phi_org);
    
    % Compute the mean squared error
    residual = y(~ridgeIdx,:)-X(~ridgeIdx,:)*theta;
    MSE = sum(residual.^2)./(sum(phi)-nEff);
    
    % Leave-one-out error and PRESS value
    LOOE  = residual./(ones(numberOfSamples,numberOfOutputs)-leverage(:,ones(1,numberOfOutputs)));
    PRESS = sum(LOOE.^2)/numberOfSamples;
    % LOOE = sqrt(phi_org).*LOOE;
    
end

%% Calculate the standard deviations of the parameters
if nargout > 6
    
    Rinv = R\eye(size(R)); % the same like inv(R)
    Rinv2 = (Rinv*Rinv');
    Xperm = Q*R;
    X2 = bsxfun(@times,sqrt(phi),Xperm); % = sqrt(W)*Q*R = W*X_org
    Rinv2X2 = Rinv2*X2'; % Pseudo-Inverse inv(X_org'*W*X_org)*X_org'*W
    stdx(perm,1:numberOfOutputs) = sqrt(sum((Rinv2X2.^2),2) * MSE);
    % the same like sqrt( MSE.*diag( (inv(R'*R)*R'*Q'*sqrt(W))*(inv(R'*R)*R'*Q'*sqrt(W))' ) )
    
end

%% Calculate the covariance matrix of the parameters
if nargout > 7
    
    covTheta = zeros(nx,nx);
    covTheta(perm,perm) = Rinv2X2*Rinv2X2' .* MSE;
    % With MSE = sigma^2.
    %
    % Faster implementation of:
    %     W = diag(phi_org);
    %     covTheta(perm,perm) = (inv(R'*R)*R'*Q'*sqrt(W))*(inv(R'*R)*R'*Q'*sqrt(W))' .* MSE;
    
end

%% Calculate confidence intervals for a given alpha
if nargout > 8
    
    % If no new input is given, use training input
    if nargin < 5
        X_new = X;
    end
    if nargin < 6
        alpha = 0.05; % level of confidence for errorbar
    end

    % Confidence bounds (depending on the approach)
    %
    % The basic idea of the Confidence interval is to describe the
    % reliability of an estimate. Here this refers to the estimated
    % parameters of the local model. The uncertainty of the estimation is
    % described by the square-root of the diagonal of the covariance matrix
    % of the model output yHat: errorbar = sqrt(diag(cov(yHat)));
    % The errorbar describes the interval in which the true process value
    % for each data point lies, with a certain probability.

    % calculate quadratic errorbar: diag(cov(yHat))
    errorbarQuad = sum((X_new*covTheta) .* X_new,2);
    
    % is faster than diag(yHat) = diag(X_new*covTheta*X_new');
    % This avoids matrix-multiplication.
    
    % Calculate the correction factor depending on alpha.
    % Alpha = 0.05 means that the interval is the 95% percentile.
    % Calculate the correction factor depending on the degrees of freedom
    tval     = tinv(1-alpha/2,sum(phi_org)-nEff); 
    
    % Restrict high t-values to avoid errors due to numerical calculation
    tval(tval==inf) = 1e3.*(max(y_org)-min(y_org));
    
    % Calculate the errorbar of the requested confidence interval
    % Here the errorbar is a prediction of the position of the true
    % process value. Depending on the choosen alpha the process value lies
    % inside the errorbar with a certain probability. The errorbar can be
    % interpret as the reliablility of the estimation. The uncertainty
    % result from the variance of the measured data points process output.
    errorbar = sqrt(errorbarQuad) * tval;
    % Simpler then:
    % errorbar = ± sqrt(diag(cov(yHat))) * correctionTerm
    
%     % Here the errorbar is an prediction of the position of the true
%     % process value. In addition to the uncertainty of the local model
%     % itself the assumed variance of the measurement of the process output
%     % is considered. Mean Squared Error is used as simple approximator for
%     % the variance. If we would have an endless amout of data samples, the
%     % output model fits perfekt and the errorbar is the variance of the
%     % measured process output. The errorbar is an indicator for new
%     % measured process outputs to be categorized. 
%     errorbar = sqrt(errorbarQuad + MSE) * tval; % calculate the confidence interval
%     % Simpler then:
%     % errorbar = ± sqrt(diag(cov(yHat)) + MSE) * correctionTerm
%     % with MSE = sigma^2.

end

%% Calculate smoothing matrix S and the correct amount of effective Parameters nEff = trace(S'*S)
if nargout > 9
    
    phi(ridgeIdx) = 0;
    weighting = repmat(sqrt(phi),1,numberOfSamples+sum(ridgeIdx));
    weighting = weighting.*weighting';
    Stilde = (Q*Q');
    S = weighting.*Stilde;
    % same like S = sqrt(phi*phi').*(Q*Q');
    
    nEff2 = norm(S,'fro')^2;
    % same like trace(S'*S)
    
end



% Checks for development.
% Only valid, if matrices are not permuted from QR decomposition!
%
% if nargin<4 || isempty(lambda) || lambda == 0
%     
%     W = diag(phi);
%     
%     sum(abs(   theta - X \ y ))
%     sum(abs(   theta - (sqrt(W)*X_org) \ (sqrt(W)*y_org) ))
%     sum(abs(   theta - inv(X_org'*W*X_org)*X_org'*W*y_org ))
%     sum(abs(    nEff - sum(diag( W*X_org*inv(X_org'*W*X_org)*X_org'*W )) ))
%     sum(abs(leverage - diag( W*X_org*inv(X_org'*W*X_org)*X_org'*W )./(phi+eps) ))
%     norm(          S - W*X_org*inv(X_org'*W*X_org)*X_org'*W )
%     sum(abs(     MSE - sum( phi.*(y_org-X_org*theta).^2 )./(sum(phi)-nEff) ))
%     sum(abs(    LOOE - sqrt(phi).*((y_org-X_org*theta)./(ones(N,1)-leverage)) ))
%     sum(abs(   PRESS - sum( phi.*((y_org-X_org*theta)./(ones(N,1)-leverage)).^2 )/N ))
%     sum(abs(    stdx - sqrt(diag(covTheta)) ))
%     norm(   covTheta - inv(X_org'*W*X_org)*(X_org'*W.^2*X_org)*inv(X_org'*W*X_org).*MSE)
%     sum(abs(errorbar - sqrt( diag(X_new*covTheta*X_new') + MSE)*tval ))
%     
% end