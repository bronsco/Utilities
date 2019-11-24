function PRESS = findMinPRESSLambda(lambda,U,S,y)
%% FINDMINPRESSLAMBDA calculates the PRESS value for a given lambda using the orthogonal matrices
% from a previously calculated SVD. This function is used for optimization of lambda.
%
%
%       [PRESS] = findMinPRESSLambda(lambda,U,S,y)
%
%
%   FINDMINPRESSLAMBDA inputs:
%
%       lambda - (scalar)   Regularization parameter for ridge regression.
%       U,S    - (matrices) Previously calculated by SVD.
%       y      - (N x 1)    Measured output vector.
%                                       
%
% 	FINDMINPRESSLAMBDA output:
%
%       PRESS:  (nx x q)    Predicted residual sum of squares. (Leave-One-Out-Cross Validation).
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