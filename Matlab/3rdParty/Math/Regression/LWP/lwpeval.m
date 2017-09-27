function [val, df1, df2] = lwpeval(Xtr, Ytr, params, crit, Xv, Yv, ...
    weights, failSilently, checkArguments)
% lwpeval
% Evaluates predictive performance of LWP using one of the criteria.
%
% Call:
%   [evaluation, df1, df2] = lwpeval(Xtr, Ytr, params, crit, Xv, Yv, ...
%       weights, failSilently, checkArguments)
%
% All the input arguments, except the first four, are optional. Empty
% values are also accepted (the corresponding defaults will be used).
%
% Input:
%   Xtr, Ytr      : Training data. See description of function lwppredict
%                   for details.
%   params        : A structure of parameters for LWP. See description of
%                   function lwpparams for details.
%   crit          : Criterion (string):
%                   'VD': Use validation data (Xv, Yv)
%                   'CVE': Explicit Leave-One-Out Cross-Validation
%                   'CV': Closed-form expression for Leave-One-Out Cross-Validation
%                   'GCV': Generalized Cross-Validation (Craven & Wahba, 1979)
%                   'AICC1': improved version of AIC (Hurvich et al., 1998)
%                   'AICC': approximation of AICC1 (Hurvich et al., 1998)
%                   'AIC': Akaike Information Criterion (Akaike, 1973, 1974)
%                   'FPE': Final Prediction Error (Akaike, 1970)
%                   'T': (Rice, 1984)
%                   'S': (Shibata, 1981)
%                   The study by Hurvich et al. (1998) compared GCV, AICC1,
%                   AICC, AIC, and T for nonparametric regression. Overall,
%                   AICC gave the best results. It was concluded that
%                   AICC1, AICC, and T tend to slightly oversmooth, GCV has
%                   a tendency to undersmooth, while AIC has a strong
%                   tendency to choose the smallest bandwidth available.
%                   Note that if robust fitting or observation weights are
%                   used, the only available criteria are 'VD' and 'CVE'.
%   Xv, Yv        : Validation data for criterion 'VD'.
%   weights       : Observation weights for training data. See description
%                   of function lwppredict for details.
%   failSilently  : See description of function lwppredict. Default value =
%                   false.
%   checkArguments: Whether to check if all the input arguments are
%                   provided correctly. Default value = true. It can be
%                   useful to turn it off when calling this function many
%                   times for optimization purposes.
%
% Output:
%   val           : The calculated criterion value.
%   df1, df2      : Degrees of freedom of the LWP fit: df1 = trace(L),
%                   df2 = trace(L'*L). Not available if crit is 'VD' or
%                   'CVE'.

% =========================================================================
% Locally Weighted Polynomials toolbox for Matlab/Octave
% Author: Gints Jekabsons (gints.jekabsons@rtu.lv)
% URL: http://www.cs.rtu.lv/jekabsons/
%
% Copyright (C) 2009-2016  Gints Jekabsons
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
% =========================================================================

% Last update: September 3, 2016

if (nargin < 9) || isempty(checkArguments) || checkArguments
    if nargin < 4
        error('Too few input arguments.');
    end
    if isempty(Xtr) || isempty(Ytr)
        error('Training data is empty.');
    end
    n = size(Xtr, 1);
    if size(Ytr,1) ~= n
        error('The number of rows in X and Y should be equal.');
    end
    if size(Ytr,2) ~= 1
        error('Y should have one column.');
    end
    if isempty(params)
        error('params is empty.');
    end
    if isempty(crit)
        error('crit is empty.');
    end
    
    if (nargin == 5) || ...
       ((nargin > 5) && xor(isempty(Xv), isempty(Yv)))
        error('Either supply both Xv and Yv or none of them.');
    end
    if (nargin < 5) || isempty(Xv) || isempty(Yv)
        if isUsesValidationData(crit)
            error('The criterion requires validation data Xv, Yv.');
        end
        Xv = [];
        Yv = [];
    else
        if (size(Xv, 1) ~= size(Yv, 1))
            error('The number of rows in Xv and Yv should be equal.');
        end
        if size(Yv,2) ~= 1
            error('Ytst should have one column.');
        end
        if (size(Xtr,2) ~= size(Xv,2))
            error('The number of columns in Xtr and Xv should be equal.');
        end
        if ~isUsesValidationData(crit)
            error('Validation data is supplied but the criterion does not use validation data.');
        end
    end
    
    if (nargin < 7)
        weights = [];
    end
    if (nargin < 8) || isempty(failSilently)
        failSilently = false;
    end
    
    if iscell(Xtr) || iscell(Ytr) || iscell(Xv) || iscell(Yv)
        error('Xtr, Ytr, Xv, and Yv should not be cell arrays.');
    end
    if (~failSilently) && size(unique(Xtr, 'rows'),1) < size(Xtr,1)
        warning('Matrix Xtr has duplicate rows.');
    end
else
    n = size(Xtr, 1);
end

if ((~isempty(weights)) || params.robust) && ~isAvailableWithWeightsAndRobust(crit)
	error('The criterion is not available when using observation weights or robust fitting.');
end

if params.standardize
    meanX = mean(Xtr);
    stdX = std(Xtr);
    Xtr = bsxfun(@rdivide, bsxfun(@minus, Xtr, meanX), stdX + 1e-10);
    if ~isempty(Xv)
        Xv = bsxfun(@rdivide, bsxfun(@minus, Xv, meanX), stdX + 1e-10);
    end
    params.standardize = false; % so that lwppredict does not standardize each time it is called
end

if isRequiresL(crit)
    [Yhat, L] = lwppredict(Xtr, Ytr, params, [], weights, failSilently);
    if any(isnan(Yhat))
        val = NaN;
        df1 = NaN;
        df2 = NaN;
        return;
    end
    df1 = trace(L);
    if (df1 < 0) || (df1 > n + 0.1)
        val = Inf;
        df1 = NaN;
        df2 = NaN;
        return;
    end
    if nargout >= 3
        df2 = trace(L'*L);
    end
else
    df1 = NaN;
    df2 = NaN;
end

% If a new criterion is added here, you should update all functions whose
% name starts with "is" in this file and in lwpfindh.m as well as update
% function getCritName in lwpfindh.m.
switch upper(crit)
    case 'VD' % validation data
        val = mean((lwppredict(Xtr, Ytr, params, Xv, weights, failSilently) - Yv) .^ 2);
    case 'CVE' % LOOCV explicit
        val = explicitLOOCVMSE(Xtr, Ytr, params, weights, failSilently);
    case 'CV' % LOOCV closed form
        val = mean(((Ytr - Yhat) ./ (1 - diag(L))) .^ 2);
    case 'GCV'
        if df1 < n
            val = n * sum((Ytr - Yhat) .^ 2) / ((n - df1) ^ 2);
        else
            val = Inf;
        end
    case 'AICC1'
        I = eye(size(L));
        B = (I - L)' * (I - L);
        delta1 = trace(B);
        delta2 = trace(B^2);
        if abs(delta2) < eps
            val = Inf;
        else
            penalty = (delta1 / delta2) * (n + trace(L'*L)) / (delta1^2 / delta2 - 2);
            if penalty >= 0
                val = log(mean((Ytr - Yhat) .^ 2)) + penalty;
            else
                val = Inf;
            end
        end
    case 'AICC'
        penalty = 1 + 2 * (df1 + 1) / (n - df1 - 2);
        if penalty >= 0
            val = log(mean((Ytr - Yhat) .^ 2)) + penalty;
        else
            val = Inf;
        end
    case 'AIC'
        if df1 < n
            val = log(mean((Ytr - Yhat) .^ 2)) + 2 * df1 / n;
        else
            val = Inf;
        end
    case 'FPE'
        if df1 < n
            val = mean((Ytr - Yhat) .^ 2) * (1 + df1 / n) / (1 - df1 / n);
        else
            val = Inf;
        end
    case 'T'
        penalty = n - 2 * df1;
        if penalty > 0
            val = sum((Ytr - Yhat) .^ 2) / penalty;
        else
            val = Inf;
        end
    case 'S'
        val = mean((Ytr - Yhat) .^ 2) * (1 + 2 * df1 / n);
    otherwise
        error('No such criterion.');
end
return

%==========================================================================

function val = explicitLOOCVMSE(Xtr, Ytr, params, weights, failSilently)
n = size(Xtr, 1);
which = true(n, 1);
val = 0;
if params.useKNN
    if params.h <= 1 % fraction of whole data
        params.h = floor(n * (params.h + eps));
    else
        params.h = floor(params.h + eps);
    end
    % Correct the bandwidth so that the assumption holds that the bandwidth
    % does not change even though with KNN LOOCV would reduce the dataset.
    % This makes 'CVE' results fully aligned with 'CV' results.
    params.h = params.h - 1;
end
for i = 1 : n
    which(i) = false;
    if isempty(weights)
        Ytrq = lwppredict(Xtr(which,:), Ytr(which), params, Xtr(i,:), [], failSilently);
    else
        Ytrq = lwppredict(Xtr(which,:), Ytr(which), params, Xtr(i,:), weights(which), failSilently);
    end
    if isnan(Ytrq)
        val = NaN;
        return
    end
    if isempty(weights)
        val = val + (Ytrq - Ytr(i)) .^ 2;
    else
        val = val + (Ytrq - Ytr(i)) .^ 2 * weights(i);
    end
    which(i) = true;
end
if isempty(weights)
    val = val / n;
else
    val = val / sum(weights);
end
return

%==========================================================================

function yes = isRequiresL(crit)
% Whether the calculation of the criterion requires the smoothing matrix
yes = ~any(strcmpi(crit, {'VD', 'CVE'}));
return

function yes = isUsesValidationData(crit)
% Whether the criterion uses validation data
yes = any(strcmpi(crit, {'VD'}));
return

function yes = isAvailableWithWeightsAndRobust(crit)
% Whether the criterion is available with user-supplied observation weights and robust fitting
yes = any(strcmpi(crit, {'VD', 'CVE'}));
return
