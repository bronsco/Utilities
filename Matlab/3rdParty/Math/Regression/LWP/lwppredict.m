function [Yq, L] = lwppredict(Xtr, Ytr, params, Xq, weights, failSilently)
% lwppredict
% Predicts response values for the given query points using Locally
% Weighted Polynomial regression. Can also provide the smoothing matrix L.
%
% Call:
%   [Yq, L] = lwppredict(Xtr, Ytr, params, Xq, weights, failSilently)
%
% All the input arguments, except the first three, are optional. Empty
% values are also accepted (the corresponding defaults will be used).
%
% Input:
%   Xtr, Ytr      : Training data. Xtr is a matrix with rows corresponding
%                   to observations and columns corresponding to input
%                   variables. Ytr is a column vector of response
%                   values. To automatically standardize Xtr to unit
%                   standard deviation before performing any further
%                   calculations, set params.standardize to true.
%                   If Xq is not given or is empty, Xtr also serves as
%                   query points.
%                   If the dataset contains observations with coincident
%                   Xtr values, it is recommended to merge the observations
%                   before using the LWP toolbox. One can simply reduce the
%                   dataset by averaging the Ytr at the tied values of Xtr
%                   and supplement these new observations at the unique
%                   values of Xtr with an additional weight.
%   params        : A structure of parameters for LWP. See function
%                   lwpparams for details.
%   Xq            : A matrix of query data points. Xq should have the same
%                   number of columns as Xtr. If Xq is not given or is
%                   empty, query points are Xtr.
%   weights       : Observation weights for training data (which multiply
%                   the kernel weights). The length of the vector must be
%                   the same as the number of observations in Xtr and Ytr.
%                   The weights must be nonnegative.
%   failSilently  : In case of any errors, whether to fail with an error
%                   message or just output NaN. This is useful for
%                   functions that perform parameter optimization and could
%                   try to wander out of ranges (e.g., lwpfindh) as well as
%                   for drawing plots even if some of the response values
%                   evaluate to NaN. Default value = false. See also
%                   argument safe of function lwpparams.
%
% Output:
%   Yq            : A column vector of predicted response values at the
%                   query points (or NaN where calculations failed).
%   L             : Smoothing matrix. Available only if Xq is empty.

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

% Citing the LWP toolbox:
% Jekabsons G., Locally Weighted Polynomials toolbox for Matlab/Octave,
% 2016, available at http://www.cs.rtu.lv/jekabsons/

% Last update: September 3, 2016

if nargin < 3
    error('Not enough input arguments.');
end
if isempty(Xtr) || isempty(Ytr)
    error('Training data is empty.');
end
[n, d] = size(Xtr);
if size(Ytr,1) ~= n
    error('The number of rows in Xtr and Ytr should be equal.');
end
if size(Ytr,2) ~= 1
    error('Ytr should have one column.');
end
if isempty(params)
    error('params is empty.');
end
if (nargin < 4)
    Xq = [];
end
if iscell(Xtr) || iscell(Ytr) || iscell(Xq)
    error('Xtr, Ytr, and Xq should not be cell arrays.');
end
if any(any(isnan(Xtr))) || ((~isempty(Xq)) && any(any(isnan(Xq))))
    error('The toolbox cannot handle missing values (NaN).');
end
if (nargin < 5)
    weights = [];
else
    if (~isempty(weights)) && ...
       ((size(weights,1) ~= n) || (size(weights,2) ~= 1))
        error('weights vector is of wrong size.');
    end
end
if (nargin < 6) || isempty(failSilently)
    failSilently = false;
end

if (~failSilently) && size(unique(Xtr, 'rows'),1) < size(Xtr,1)
    warning('Matrix Xtr has duplicate rows.');
end

if ~isKernel(params.kernel)
    error('No such kernel.');
end
if isnan(params.h) || (params.h < 0)
    if failSilently
        Yq = NaN;
        L = NaN;
        return;
    else
        error(['Bad value for params.h (' num2str(params.h) ').']);
    end
end

if params.standardize
    meanX = mean(Xtr);
    stdX = std(Xtr);
    Xtr = bsxfun(@rdivide, bsxfun(@minus, Xtr, meanX), stdX + 1e-10);
    if ~isempty(Xq)
        Xq = bsxfun(@rdivide, bsxfun(@minus, Xq, meanX), stdX + 1e-10);
    end
end

if params.robust > 0
    w = weights;
    for i = 1 : floor(double(params.robust) + eps)
        Yq = weightAndPredict(Xtr, Ytr, params, Xtr, weights, failSilently, true);
        if any(isnan(Yq))
            Yq = NaN;
            L = NaN;
            return;
        end
        e = Ytr - Yq;
        if isempty(w)
            weights = kernelBiweight(abs(e / (6 * median(abs(e)))));
        else
            weights = w .* kernelBiweight(abs(e / (6 * median(abs(e)))));
        end
    end
end

if nargout > 1
    if ~params.safe
        error('Output argument L is not available when params.safe = false.');
    end
    if ~isempty(Xq)
        error('Xq should be empty when output argument L is requested.');
    end
    [Yq, L] = weightAndPredict(Xtr, Ytr, params, Xtr, weights, failSilently, true);
else
    if isempty(Xq)
        Yq = weightAndPredict(Xtr, Ytr, params, Xtr, weights, failSilently, true);
    else
        if d ~= size(Xq, 2)
            error('The number of columns in Xtr and Xq should be equal.');
        end
        Yq = weightAndPredict(Xtr, Ytr, params, Xq, weights, failSilently, false);
    end
end
return

%==========================================================================

function [Yq, L] = weightAndPredict(Xtr, Ytr, params, Xq, wObs, failSilently, XqIsXtr)
[n, d] = size(Xtr);
nq = size(Xq, 1);
L = NaN;
needL = nargout > 1;

params.degree = max(0, params.degree);
if abs(params.degree - floor(params.degree + eps)) < eps
    params.degree = floor(params.degree + eps);
    r = exponents(d, params.degree);
    rCoef = NaN;
    rDegree = NaN;
else
    degreeInt = floor(params.degree + eps);
    rCoef = params.degree - degreeInt;
    params.degree = degreeInt + 1;
    r = exponents(d, params.degree);
    rDegree = sum(r, 2);
end
nTerms = size(r, 1);

if params.useKNN
    if ~isUsableWithKNN(params.kernel)
        error('Cannot use the kernel with nearest neighbor window.');
    end
    if params.h <= 1 % fraction of the whole data
        params.h = min(n, floor(n * (params.h + eps)));
    else
        params.h = min(n, floor(params.h + eps));
    end
    if params.h < 1
        if failSilently
            Yq = NaN;
            return;
        else
            error('Neighborhood size should be at least 1.');
        end
    end
    if params.safe
        if isUniform(params.kernel)
            if params.h < nTerms
                if failSilently
                    Yq = NaN;
                    return;
                else
                    error(['If params.safe = true then, for this kernel, neighborhood size should be larger than or equal to the number of terms in the polynomial (i.e., at least ' num2str(nTerms) ').']);
                end
            end
        else
            if params.h < nTerms + 1 % "+1" is because the weight for the farthest neighbor will be set to 0
                if failSilently
                    Yq = NaN;
                    return;
                else
                    error(['If params.safe = true then, for this kernel, neighborhood size should be larger than the number of terms in the polynomial (i.e., at least ' num2str(nTerms) ' + 1).']);
                end
            end
        end
    else
        if ((params.h <= 2) && (params.degree > 0) && (~isUniform(params.kernel))) || ...
           ((params.h == 1) && (params.degree > 0) && isUniform(params.kernel))
            % Because that means that there will be one observation for the
            % actual prediction and that is not enough even for the "unsafe"
            % calculations.
            if failSilently
                Yq = NaN;
                return;
            else
                error('Neighborhood size too small.');
            end
        end
    end
    
    % Calculate weights
    if isUniform(params.kernel)
        if isempty(wObs)
            [knnIdx, w] = knnU(Xtr, Xq, params.h, false);
        else
            [knnIdx, w] = knnUW(Xtr, Xq, params.h, wObs, params.knnSumWeights, false);
        end
    else
        if isempty(wObs)
            [knnIdx, u] = knnU(Xtr, Xq, params.h, true);
        else
            [knnIdx, u] = knnUW(Xtr, Xq, params.h, wObs, params.knnSumWeights, true);
        end
        switch upper(params.kernel)
            case 'TRI'
                w = kernelTriangular(u);
            case 'EPA'
                w = kernelEpanechnikov(u);
            case 'BIW'
                w = kernelBiweight(u);
            case 'TRW'
                w = kernelTriweight(u);
            case 'TRC'
                w = kernelTricube(u);
            case 'COS'
                w = kernelCosine(u);
        end
    end
    
    % Apply observation weights
    if ~isempty(wObs)
        for i = 1 : nq
            w(:,i) = w(:,i) .* wObs(knnIdx(:,i));
        end
    end
    
    origWarningState = warning;
    if exist('OCTAVE_VERSION', 'builtin')
        warning('off', 'Octave:nearly-singular-matrix');
        warning('off', 'Octave:singular-matrix');
    else
        warning('off', 'MATLAB:nearlySingularMatrix');
        warning('off', 'MATLAB:singularMatrix');
    end
    
    if needL
        [Yq, L] = predict(Xtr, Ytr, Xq, w, nTerms, knnIdx, params, failSilently, r, rDegree, rCoef, XqIsXtr);
    else
        Yq = predict(Xtr, Ytr, Xq, w, nTerms, knnIdx, params, failSilently, r, rDegree, rCoef, XqIsXtr);
    end
    
    warning(origWarningState);
    return;
end

%---------------------------------------------

if isHCanBeZero(params.kernel)
    if (params.h < 0)
        if failSilently
            Yq = NaN;
            return;
        else
            error('params.h for this kernel should be larger than or equal to 0.');
        end
    end
else
    if (params.h <= 0)
        if failSilently
            Yq = NaN;
            return;
        else
            error('params.h for this kernel should be larger than 0.');
        end
    end
end

if isMultiplyHByMaxDist(params.kernel)
    params.h = params.h * norm(max(Xtr) - min(Xtr)); % distance between two opposite corners of the hypercube
end

% Calculate distances
dist = zeros(n, nq);
for i = 1 : nq
    dist(:,i) = sum((repmat(Xq(i, :), n, 1) - Xtr) .^ 2, 2);
end

% Calculate weights
switch upper(params.kernel)
    case 'UNI'
        w = kernelUniform(sqrt(dist) / params.h);
    case 'TRI'
        w = kernelTriangular(sqrt(dist) / params.h);
    case 'EPA'
        w = kernelEpanechnikov(sqrt(dist) / params.h);
    case 'BIW'
        w = kernelBiweight(sqrt(dist) / params.h);
    case 'TRW'
        w = kernelTriweight(sqrt(dist) / params.h);
    case 'TRC'
        w = kernelTricube(sqrt(dist) / params.h);
    case 'COS'
        w = kernelCosine(sqrt(dist) / params.h);
    case 'GAU'
        w = kernelGaussian(dist, params.h);
    case 'GAR'
        w = kernelGaussianRikards(dist, params.h);
end

% Apply observation weights
if ~isempty(wObs)
    w = w .* repmat(wObs, 1, nq);
end

origWarningState = warning;
if exist('OCTAVE_VERSION', 'builtin')
    warning('off', 'Octave:nearly-singular-matrix');
    warning('off', 'Octave:singular-matrix');
else
    warning('off', 'MATLAB:nearlySingularMatrix');
    warning('off', 'MATLAB:singularMatrix');
end

if needL
    [Yq, L] = predict(Xtr, Ytr, Xq, w, nTerms, [], params, failSilently, r, rDegree, rCoef, XqIsXtr);
else
    Yq = predict(Xtr, Ytr, Xq, w, nTerms, [], params, failSilently, r, rDegree, rCoef, XqIsXtr);
end

warning(origWarningState);
return

%==========================================================================

function [Yq, L] = predict(Xtr, Ytr, Xq, w, nTerms, knnIdx, params, failSilently, r, rDegree, rCoef, XqIsXtr)
% Calculate coefs and predict response values
n = size(Xtr, 1);
needL = nargout > 1;
if needL
    nq = n;
    L = zeros(n, n); % Smoothing matrix
else
    if XqIsXtr
        nq = n;
        Yq = NaN(n, 1);
        FX = buildDesignMatrix(Xtr, [], r);
        FXq = FX;
    else
        nq = size(Xq, 1);
        Yq = NaN(nq, 1);
        [FX, FXq] = buildDesignMatrix(Xtr, Xq, r);
    end
    isOctave = exist('OCTAVE_VERSION', 'builtin');
end
for i = 1 : nq
    if needL
        nonZero = findNonZeroWeights(w(:,i), nTerms + 1, params.safe); % "+1" because 'CV' etc. uses one observation more than 'CVE' to estimate the same stuff
    else
        nonZero = findNonZeroWeights(w(:,i), nTerms, params.safe);
    end
    ww = w(nonZero,i);
    ww = ww / sum(ww); % so that weights sum to 1
    if isempty(nonZero)
        if failSilently
            if needL
                Yq = NaN;
                L = [];
                return;
            else
                continue;
            end
        else
            error('Not enough neighbors with nonzero weights. Try increasing params.h.');
        end
    end
    if isempty(knnIdx)
        idx = nonZero;
    else
        idx = knnIdx(nonZero,i);
    end
    if needL
        FX = buildDesignMatrix(Xtr(idx,:) - repmat(Xtr(i,:),sum(nonZero),1), [], r);
        FXW = bsxfun(@times, FX, ww)'; %FXW = FX' * diag(ww);
        Z = (FXW * FX) \ FXW;
        L(i,idx) = Z(1,:);
    else
        FXnz = FX(idx,:);
        if isOctave
            FXW = bsxfun(@times, FXnz, ww)'; %FXW = FXnz' * diag(ww);
            coefs = (FXW * FXnz) \ (FXW * Ytr(idx));
        else
            coefs = lscov(FXnz, Ytr(idx), ww);
        end
        Yq(i) = FXq(i,:) * coefs;
    end
    if ~isnan(rCoef)
        if needL
            FX = FX(:,rDegree <= (params.degree-1));
            FXW = bsxfun(@times, FX, ww)'; %FXW = FX' * diag(ww);
            Z = (FXW * FX) \ FXW;
            L(i,idx) = rCoef .* L(i,idx) + (1-rCoef) .* Z(1,:);
        else
            which = rDegree <= (params.degree-1);
            FXnz = FXnz(:,which);
            if isOctave
                FXW = bsxfun(@times, FXnz, ww)'; %FXW = FXnz' * diag(ww);
                coefs = (FXW * FXnz) \ (FXW * Ytr(idx));
            else
                coefs = lscov(FXnz, Ytr(idx), ww);
            end
            Yq(i) = rCoef * Yq(i) + (1-rCoef) * FXq(i,which) * coefs;
        end
    end
end
if needL
    if any(any(isnan(L)))
        if failSilently
            Yq = NaN;
            L = [];
            return;
        else
            error('Cannot fully calculate L. Try increasing params.h.');
        end
    end
    Yq = L * Ytr;
end
return

%==========================================================================

function nonZero = findNonZeroWeights(w, nTerms, safe)
% Finds observations with nonzero weights and checks whether they are sufficiently many
nonZero = w > 0;
if safe
    if sum(nonZero) < nTerms
        nonZero = [];
        return;
    end
else
    if sum(nonZero) < min(2, nTerms)
        nonZero = [];
        return;
    end
end
return

%==========================================================================

function [FX, FXq] = buildDesignMatrix(Xtr, Xq, r)
% Builds design matrix for both, training data and query points
n = size(Xtr, 1);
nTerms = size(r, 1);
FX = ones(n, nTerms);
if nargout == 1
    for idx = 2 : nTerms
        rr = r(idx,:);
        which = find(rr > 0);
        for column = which
            exponent = rr(column);
            if exponent == 1
                FX(:,idx) = FX(:,idx) .* Xtr(:,column);
            else
                FX(:,idx) = FX(:,idx) .* Xtr(:,column) .^ exponent;
            end
        end
    end
else
    nq = size(Xq, 1);
    FXq = ones(nq, nTerms);
    for idx = 2 : nTerms
        rr = r(idx,:);
        which = find(rr > 0);
        for column = which
            exponent = rr(column);
            if exponent == 1
                FX(:,idx) = FX(:,idx) .* Xtr(:,column);
                FXq(:,idx) = FXq(:,idx) .* Xq(:,column);
            else
                FX(:,idx) = FX(:,idx) .* Xtr(:,column) .^ exponent;
                FXq(:,idx) = FXq(:,idx) .* Xq(:,column) .^ exponent;
            end
        end
    end
end
return

%==========================================================================

function r = exponents(d, degree)
% Builds array of exponents for polynomial of given degree
if degree == 0
	r = zeros(1, d);
    return
end
if d == 1
	r = (0:degree)';
    return;
end
r = zeros(0, d);
for i = 0 : degree
    rr = exponents(d - 1, degree - i);
    r = [r; [repmat(i, size(rr,1), 1) rr]];
end
return

%==========================================================================

function w = kernelUniform(u)
w = zeros(size(u));
w(u <= 1) = 1;
return

function w = kernelTriangular(u)
w = zeros(size(u));
which = u < 1;
w(which) = 1 - u(which);
return

function w = kernelEpanechnikov(u)
w = zeros(size(u));
which = u < 1;
w(which) = 1 - u(which).^2;
return

function w = kernelBiweight(u)
w = zeros(size(u));
which = u < 1;
w(which) = (1 - u(which).^2).^2;
return

function w = kernelTriweight(u)
w = zeros(size(u));
which = u < 1;
w(which) = (1 - u(which).^2).^3;
return

function w = kernelTricube(u)
w = zeros(size(u));
which = u < 1;
w(which) = (1 - u(which).^3).^3;
return

function w = kernelCosine(u)
w = zeros(size(u));
which = u < 1;
w(which) = cos(0.5 * pi * u(which));
return

function w = kernelGaussian(dist, h)
w = exp(-1 / (2 * h^2) * dist); % dist is not squared because it was already
return

function w = kernelGaussianRikards(dist, h)
nq = size(dist, 2);
for i = 1 : nq
    % dividing dist by the farthest point from the query point
    dist(:,i) = dist(:,i) / max(dist(:,i)); % dist is not squared because it was already
end
w = exp(-h * dist);
return

%==========================================================================

function [knnIdx, u] = knnU(Xtr, Xq, k, nonuniform)
% Finds nearest neighbors and calculates u for the kernel (or just gives weight vector of ones, if kernel is uniform)
n = size(Xtr, 1);
nq = size(Xq, 1);
if nonuniform
    % For all kernels except uniform
    knnIdx = zeros(k-1, nq);
    u = zeros(k-1, nq);
    farthest = zeros(1, nq);
    for i = 1 : nq
        dist = sum((repmat(Xq(i,:), n, 1) - Xtr).^2, 2);
        [sortedDist, sortedIdx] = sort(dist, 'ascend');
        knnIdx(:,i) = sortedIdx(1:(k-1)); % ties broken arbitrarily. not important because all farthest get 0 weight anyway
        u(:,i) = sortedDist(1:(k-1));
        farthest(i) = sortedDist(k);
    end
    u = sqrt(u) ./ repmat(sqrt(farthest),k-1,1); % divided by the farthest
else
    % For uniform kernel
    knnIdx = zeros(k, nq);
    for i = 1 : nq
        dist = sum((repmat(Xq(i,:), n, 1) - Xtr).^2, 2);
        [~, sortedIdx] = sort(dist, 'ascend');
        knnIdx(:,i) = sortedIdx(1:k); % ties broken arbitrarily
    end
    u = ones(k, nq); % weights
end
return

%==========================================================================

function [knnIdx, u] = knnUW(Xtr, Xq, k, wObs, knnSumWeights, nonuniform)
% Finds nearest neighbors and calculates u for the kernel (or weights, if
% kernel is uniform) for local regression with observation weights
n = size(Xtr, 1);
nq = size(Xq, 1);
wObs = wObs / sum(wObs) * n; % so that wObs sum to n
knnIdx = zeros(n, nq);
if knnSumWeights
    epsw = eps(max(wObs));
end
if nonuniform
    % For all kernels except uniform
    u = ones(n, nq);
    for i = 1 : nq
        dist = sum((repmat(Xq(i,:), n, 1) - Xtr).^2, 2);
        [sortedDist, knnIdx(:,i)] = sort(dist, 'ascend');
        % ties broken arbitrarily. not important because all farthest get 0 weight anyway
        s = 0;
        if knnSumWeights
            for j = 1 : n
                s = s + wObs(knnIdx(j,i));
                if (s >= k - epsw) || (j == n)
                    u(1:(j-1),i) = sqrt(sortedDist(1:(j-1))) ./ sqrt(sortedDist(j)); % divided by the farthest
                    break;
                end
            end
        else
            for j = 1 : n
                if wObs(knnIdx(j,i)) > 0
                    s = s + 1;
                else
                    continue;
                end
                if (s >= k) || (j == n)
                    u(1:(j-1),i) = sqrt(sortedDist(1:(j-1))) ./ sqrt(sortedDist(j)); % divided by the farthest
                    break;
                end
            end
        end
    end
else
    % For uniform kernel
    u = zeros(n, nq); % weights
    for i = 1 : nq
        dist = sum((repmat(Xq(i,:), n, 1) - Xtr).^2, 2);
        [~, knnIdx(:,i)] = sort(dist, 'ascend');
        % ties broken arbitrarily
        s = 0;
        if knnSumWeights
            for j = 1 : n
                s = s + wObs(knnIdx(j,i));
                if (s >= k - epsw) || (j == n)
                    if j > 1
                        u(1:(j-1),i) = ones(j-1,1);
                    end
                    u(j,i) = max(0, k - (s - wObs(knnIdx(j,i))));
                    break;
                end
            end
        else
            for j = 1 : n
                if wObs(knnIdx(j,i)) > 0
                    s = s + 1;
                else
                    continue;
                end
                if (s >= k) || (j == n)
                    if j > 1
                        u(1:(j-1),i) = ones(j-1,1);
                    end
                    u(j,i) = max(0, k - (s - wObs(knnIdx(j,i))));
                    break;
                end
            end
        end
    end
end
return

%==========================================================================

% If a new kernel type is added, you should update all these functions
% whose name starts with "is" in this file as well as update lwpfindh.m
% file where the string constants are used.

function yes = isKernel(kernel)
% Whether there is such kernel
yes = any(strcmpi(kernel, {'UNI', 'TRI', 'EPA', 'BIW', 'TRW', 'TRC', 'COS', 'GAU', 'GAR'}));
return

function yes = isUsableWithKNN(kernel)
% Whether the kernel can be used with KNN window widths
yes = ~any(strcmpi(kernel, {'GAU', 'GAR'}));
return

function yes = isUniform(kernel)
% Whether the kernel gives uniform weights to all neighbors
yes = any(strcmpi(kernel, {'UNI'}));
return

function yes = isHCanBeZero(kernel)
% Whether for this kernel the value of h is allowed to be 0
yes = any(strcmpi(kernel, {'GAR'}));
return

function yes = isMultiplyHByMaxDist(kernel)
% Whether for this kernel the value of h should be multiplied by maxDist
yes = ~any(strcmpi(kernel, {'GAR'}));
return
