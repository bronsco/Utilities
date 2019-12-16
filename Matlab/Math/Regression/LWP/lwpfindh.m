function [hBest, critBest, results] = lwpfindh(Xtr, Ytr, params, crit, ...
    hList, Xv, Yv, weights, finetune, verbose)
% lwpfindh
% Finds the "best" bandwidth for a kernel using a simple grid search
% followed by fine-tuning. Predictive performances are estimated using one
% of the criteria provided by function lwpeval.
%
% Call:
%   [hBest, critBest, results] = lwpfindh(Xtr, Ytr, params, crit, ...
%       hList, Xv, Yv, weights, finetune, verbose)
%
% All the input arguments, except the first four, are optional. Empty
% values are also accepted (the corresponding defaults will be used).
%
% Input:
%   Xtr, Ytr      : Training data. See description of function lwppredict
%                   for details.
%   params        : A structure of parameters for LWP. See description of
%                   function lwpparams. Parameter params.h is ignored, as
%                   it is the one parameter to optimize.
%   crit          : See description of function lwpeval.
%   hList         : A vector of non-negative window size h values to try
%                   (see description of function lwpparams for details
%                   about h). If hList is not supplied, a grid of values is
%                   created automatically depending on params.kernel. For
%                   all kernel types, except 'GAR', equidistant values
%                   between 0.05 and 1 with step size 0.05 are considered.
%                   For kernel type 'GAR', the values grow exponentially
%                   from 0 to 100*2^10. The result from this search step is
%                   (optionally) fine-tuned (see argument finetune).
%   Xv, Yv        : Validation data for criterion 'VD'.
%   weights       : Observation weights for training data. See description
%                   of function lwppredict for details.
%   finetune      : Whether to fine-tune the result from the grid search.
%                   Nearest neighbor window widths are fine-tuned using
%                   more fine-grained grid. Metric window widths are fine-
%                   tuned using Nelder-Mead simplex direct search. Default
%                   value = true.
%   verbose       : Whether to print the optimization progress to the
%                   console. Default value = true.
%
% Output:
%   hBest         : The best found value for h.
%   critBest      : Criterion value for hBest.
%   results       : A matrix with four columns. First column contains all
%                   the h values considered in the initial grid search.
%                   Second column contains the corresponding criterion
%                   values. Third and fourth columns contain df1 and df2
%                   values from function lwpeval. See function lwpeval for
%                   details.

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

if nargin < 4
    error('Too few input arguments.');
end
if isempty(Xtr) || isempty(Ytr)
    error('Training data is empty.');
end
n = size(Xtr, 1);
if size(Ytr,1) ~= n
    error('The number of rows in Xtr and Ytr should be equal.');
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
critName = getCritName(crit);
if isempty(critName)
    error('No such criterion.');
end
if (nargin < 5) || isempty(hList)
    hList = [];
end

if size(unique(Xtr, 'rows'),1) < size(Xtr,1)
    warning('Matrix Xtr has duplicate rows.');
end

if (nargin == 6) || ...
   ((nargin > 6) && xor(isempty(Xv), isempty(Yv)))
    error('Either supply both Xv and Yv or none of them.');
end
if (nargin < 6) || isempty(Xv) || isempty(Yv)
    if isUsesValidationtData(crit)
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
    if ~isUsesValidationtData(crit)
        error('Validation data is supplied but the criterion does not use validation data.');
    end
end

if (nargin < 8)
    weights = [];
end
if (nargin < 9) || isempty(finetune)
    finetune = true;
end
if (nargin < 10) || isempty(verbose)
    verbose = true;
end

if iscell(Xtr) || iscell(Ytr) || iscell(Xv) || iscell(Yv)
    error('Xtr, Ytr, Xv, and Yv should not be cell arrays.');
end

if (~params.safe) && isRequiresL(crit)
    error('The criterion cannot be used with params.safe = false.');
end
params.degree = max(0, params.degree);

if ~isempty(hList)
    if any(hList < 0)
        error('hList should contain only non-negative values.');
    end
    % Let's check all h values and remove inadequate ones
    if params.useKNN
        if any(hList > 1)
            if any(hList < 1)
                error('For kNN window sizes, hList values lower than 1 and larger than 1 are not allowed to be mixed.');
            end
            hList = floor(hList + eps);
            if isUsesValidationtData(crit)
                hList(hList == 1) = 1 + eps; % "+eps" so that it is not recognized as 100% of data
            else
                hList(hList == 1) = []; % because KNN with k=1 is available for validation data only
            end
        else
            hList = floor(n * (hList + eps));
        end
        hList(hList > n) = [];
        if isUsesValidationtData(crit)
            hList(hList < 1) = [];
        else
            hList(hList < 2) = [];
        end
    else
        if isKernelHZeroToInf(params.kernel)
            hList(hList < 0) = [];
        else
            hList(hList <= 0) = [];
        end
    end
    if isempty(hList)
        error('There were no usable values in hList.');
    end
    if isKernelHZeroToInf(params.kernel)
        hList = sort(hList, 'ascend');
    else
        hList = sort(hList, 'descend');
    end
    hList = hList(:)'; % force row vector
end

if verbose
    if abs(params.degree - floor(params.degree + eps)) < eps
        nTerms = countTerms(size(Xtr, 2), floor(params.degree + eps));
    else
        nTerms = countTerms(size(Xtr, 2), floor(params.degree + eps) + 1);
    end
    fprintf('Number of terms in polynomial: %d\n', nTerms);
    fprintf('Searching for best h using %s...\n', critName);
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

if params.useKNN
    if isempty(hList)
        hList = floor(n * ((1:-0.05:0.05) + eps)); % descending
        if isUsesValidationtData(crit)
            hList = [hList 1 + eps]; % "+eps" so that it is not recognized as 100% of data
        end
        [hBest, critBest, results] = gridSearch(Xtr, Ytr, params, hList, crit, Xv, Yv, weights, verbose, false);
    else
        [hBest, critBest, results] = gridSearch(Xtr, Ytr, params, hList, crit, Xv, Yv, weights, verbose, true);
    end
    if finetune && (~isnan(critBest))
        [hBest, critBest] = gridSearchKNNFinetuning(Xtr, Ytr, params, hList, crit, Xv, Yv, weights, hBest, critBest, verbose);
    end
    return;
end

if isempty(hList)
    if isKernelHZeroToInf(params.kernel)
        hList = [0 25 * 2 .^ (0:12)]; % ascending
    else
        hList = 1:-0.05:0.05; % descending
    end
    [hBest, critBest, results] = gridSearch(Xtr, Ytr, params, hList, crit, Xv, Yv, weights, verbose, false);
else
    [hBest, critBest, results] = gridSearch(Xtr, Ytr, params, hList, crit, Xv, Yv, weights, verbose, true);
end

if finetune && (~isnan(critBest))
    % Fine-tuning the result from the grid search
    tolX = max(1e-4, 1e-4 * hBest);
    tolFun = max(1e-4, 1e-4 * critBest);
    if verbose
        fprintf('\nFine-tuning using Nelder-Mead simplex direct search...\n');
    end
    cvfun = @(h) lwpeval(Xtr, Ytr, ...
    	lwpparams(params.kernel, params.degree, params.useKNN, h, params.robust, params.knnSumWeights, params.standardize, params.safe), ...
    	crit, Xv, Yv, weights, true, false);
    if exist('OCTAVE_VERSION', 'builtin')
        if verbose
            options = optimset('TolX', tolX, 'TolFun', tolFun, 'MaxIter', 100, 'MaxFunEvals', 100, 'Display', 'iter');
        else
            options = optimset('TolX', tolX, 'TolFun', tolFun, 'MaxIter', 100, 'MaxFunEvals', 100);
        end
        [hBest, critBest] = fminsearch(@(h) cvfun(h), hBest, options);
    else
        if verbose
            options = optimset('TolX', tolX, 'TolFun', tolFun, 'MaxIter', 100, 'MaxFunEvals', 100, 'OutputFcn', @printInfo);
        else
            options = optimset('TolX', tolX, 'TolFun', tolFun, 'MaxIter', 100, 'MaxFunEvals', 100);
        end
        [hBest, critBest] = fminsearch(@(h, varargin) cvfun(h), hBest, options, crit);
    end
    if verbose
        fprintf('Best result: h = %0.6g, %s = %0.6g\n', hBest, critName, critBest);
    end
end
return

%==========================================================================

function [hBest, critBest, results] = gridSearch(Xtr, Ytr, params, hTry, crit, Xv, Yv, weights, verbose, userSupplied)
% Searches for the "best" bandwidth using a simple grid search
nTry = numel(hTry);
critEval = NaN(1, nTry);
results = NaN(nTry, 4);
results(:,1) = hTry(:);
if verbose
    if userSupplied
        fprintf('\nUser supplied values...\n');
    else
        fprintf('\nGrid search...\n');
    end
    if isRequiresL(crit)
        fprintf('Iter             h %14s           df1           df2\n', getCritName(crit));
    else
        fprintf('Iter             h %14s\n', getCritName(crit));
    end
end
if verbose
    resOld1 = 0;
    resOld2 = 0;
    hBad1 = NaN;
    hBad2 = NaN;
end
% Try the values in the list
for i = 1 : nTry
    [critEval(i), results(i,3), results(i,4)] = lwpeval(Xtr, Ytr, ...
        lwpparams(params.kernel, params.degree, params.useKNN, hTry(i), params.robust, params.knnSumWeights, params.standardize, params.safe), ...
        crit, Xv, Yv, weights, true, false);
    if verbose
        if isRequiresL(crit)
            if (i > 1) && (hTry(i) ~= hTry(i-1)) && ...
                (((~isnan(results(i,3))) && (results(i,3) + 1 < resOld1)) || ...
                 ((~isnan(results(i,4))) && (results(i,4) + 1 < resOld2)))
                hBad1 = min(hBad1, hTry(i));
                hBad2 = max(hBad2, hTry(i));
            end
            if (results(i,4) > size(Xtr,1) + 0.1)
                hBad1 = min(hBad1, hTry(i));
                hBad2 = max(hBad2, hTry(i));
            end
            resOld1 = results(i,3);
            resOld2 = results(i,4);
            fprintf('%4.0f  %12.6g   %12.6g  %12.6g  %12.6g\n', i, hTry(i), critEval(i), results(i,3), results(i,4));
        else
            fprintf('%4.0f  %12.6g   %12.6g\n', i, hTry(i), critEval(i));
        end
    end
    if (nTry > 1) && (isnan(critEval(i)) || isinf(critEval(i)))
        % Encountering NaN or Inf/-Inf means that there is no point in trying smaller bandwidths
        if verbose
            if isnan(critEval(i))
                if isKernelHZeroToInf(params.kernel)
                    fprintf('Terminated: Largest usable h reached.\n');
                else
                    fprintf('Terminated: Smallest usable h reached.\n');
                end
            else
                fprintf('Terminated: %s = %d\n', getCritName(crit), critEval(i));
            end
        end
        break;
    end
end
[critBest, idx] = min(critEval);
if isnan(critBest)
    hBest = NaN;
else
    hBest = hTry(idx);
end
results(:,2) = critEval;
if verbose
    fprintf('Best result: h = %0.6g, %s = %0.6g\n', hBest, getCritName(crit), critBest);
    if ~isnan(hBad1)
        if hBad1 == hBad2
            fprintf('Warning: Possible numerical instability detected for h around %0.6g\n', hBad1);
        else
            fprintf('Warning: Possible numerical instability detected for h around %0.6g to %0.6g\n', hBad1, hBad2);
        end
    end
end
return

%==========================================================================

function [hBest, critBest] = gridSearchKNNFinetuning(Xtr, Ytr, params, hList, crit, Xv, Yv, weights, hBest, critBest, verbose)
% Refined search for KNN window widths
if hBest == min(hList)
    lower = max(2, hBest - (hList(end-1) - hList(end)) + 1); % search outside
else
    lower = max(hList(hList < hBest)) + 1; % search until next already tried value
end
if hBest == max(hList)
    higher = min(size(Xtr,1), hBest + (hList(1) - hList(2)) - 1); % search outside
else
    higher = min(hList(hList > hBest)) - 1; % search until next already tried value
end
if isempty(lower) || (lower == hBest)
    lower = hBest + 1;
end
if isempty(higher) || (higher == hBest)
    higher = hBest - 1;
end
if lower > higher
    return;
end
if verbose
    fprintf('\nFine-tuning...\n');
    fprintf('Iter             h %14s\n', getCritName(crit));
end
% Make the list of h values to try
hTryH = higher:-1:(hBest+1);
hTryL = (hBest-1):-1:lower;
numelHTry = numel(hTryH) + numel(hTryL);
if numelHTry <= 20
    hTry = [hTryH hTryL];
else
    step = numelHTry / 20;
    hTry = [fliplr(hTryH(round(numel(hTryH):-step:1))) hTryL(round(1:step:numel(hTryL)))];
end
nTry = numel(hTry);
if verbose
    resOld1 = 0;
    resOld2 = 0;
    hBad1 = NaN;
    hBad2 = NaN;
end
% Try the values in the list
for i = 1 : nTry
    [critEval, results3, results4] = lwpeval(Xtr, Ytr, ...
        lwpparams(params.kernel, params.degree, params.useKNN, hTry(i), params.robust, params.knnSumWeights, params.standardize, params.safe), ...
        crit, Xv, Yv, weights, true, false);
    if verbose
        if isRequiresL(crit)
            if (i > 1) && (hTry(i) ~= hTry(i-1)) && ...
                (((~isnan(results3)) && (results3 + 1 < resOld1)) || ...
                 ((~isnan(results4)) && (results4 + 1 < resOld2)))
                hBad1 = min(hBad1, hTry(i));
                hBad2 = max(hBad2, hTry(i));
            end
            if (results4 > size(Xtr,1) + 0.1)
                hBad1 = min(hBad1, hTry(i));
                hBad2 = max(hBad2, hTry(i));
            end
            resOld1 = results3;
            resOld2 = results4;
            fprintf('%4.0f  %12.6g   %12.6g  %12.6g  %12.6g\n', i, hTry(i), critEval, results3, results4);
        else
            fprintf('%4.0f  %12.6g   %12.6g\n', i, hTry(i), critEval);
        end
    end
    if isnan(critEval) || isinf(critEval)
        if (nTry > 1)
            % Encountering NaN or Inf/-Inf means that there is no point in trying smaller bandwidths
            if verbose
                if isnan(critEval)
                    if isKernelHZeroToInf(params.kernel)
                        fprintf('Terminated: Largest usable h reached.\n');
                    else
                        fprintf('Terminated: Smallest usable h reached.\n');
                    end
                else
                    fprintf('Terminated: %s = %d\n', getCritName(crit), critEval);
                end
            end
            break;
        end
    else
        if critEval < critBest
            hBest = hTry(i);
            critBest = critEval;
        end
    end
end
if verbose
    fprintf('Best result: h = %0.6g, %s = %0.6g\n', hBest, getCritName(crit), critBest);
    if ~isnan(hBad1)
        if hBad1 == hBad2
            fprintf('Warning: Possible numerical instability detected for h around %0.6g\n', hBad1);
        else
            fprintf('Warning: Possible numerical instability detected for h around %0.6g to %0.6g\n', hBad1, hBad2);
        end
    end
end
return

%==========================================================================

function critName = getCritName(crit)
% Outputs name of the criterion
names = {'Validation MSE', 'LOOCVE MSE', 'LOOCV MSE', 'GCV', 'AICC1', 'AICC', 'AIC', 'FPE', 'T', 'S'};
idx = strcmpi(crit, {'VD', 'CVE', 'CV', 'GCV', 'AICC1', 'AICC', 'AIC', 'FPE', 'T', 'S'});
if ~any(idx)
    critName = [];
    return;
end
critName = names{idx};
return

function yes = isUsesValidationtData(crit)
% Whether the criterion uses validation data
yes = any(strcmpi(crit, {'VD'}));
return

function yes = isRequiresL(crit)
% Whether the calculation of the criterion requires the smoothing matrix
yes = ~any(strcmpi(crit, {'VD', 'CVE'}));
return

function yes = isKernelHZeroToInf(kernel)
% Whether for this kernel max bandwidth is with h = 0 and decreases with increasing h
yes = any(strcmpi(kernel, {'GAR'}));
return

%==========================================================================

function nTerms = countTerms(d, degree)
% Counts terms that would be in the polynomial of the given degree
if degree == 0
	nTerms = 1;
    return
end
if d == 1
	nTerms = degree + 1;
    return
end
nTerms = 0;
for i = 0 : degree
    nTerms = nTerms + countTerms(d - 1, degree - i);
end
return

%==========================================================================

function stop = printInfo(x, optimValues, state, varargin)
% Prints results at each iteration
stop = false;
if strcmp(state, 'init')
    fprintf('Iter    Evals             h %14s        Procedure\n', getCritName(varargin{1}));
    return
end
if ~strcmp(state, 'iter')
    return
end
fprintf('%4.0f    %5.0f  %12.6g   %12.6g       %s\n', ...
	optimValues.iteration, optimValues.funccount, x, optimValues.fval, optimValues.procedure);
return
