function params = lwpparams(kernel, degree, useKNN, h, robust, ...
    knnSumWeights, standardize, safe)
% lwpparams
% Creates configuration for LWP. The output structure is for further use
% with all the other functions of the toolbox.
%
% Call:
%   params = lwpparams(kernel, degree, useKNN, h, robust, ...
%       knnSumWeights, standardize, safe)
%
% All the input arguments of this function are optional. Empty values are
% also accepted (the corresponding defaults will be used).
%
% Input:
%   kernel        : Kernel type (string). See user's manual for details.
%                   Default value = 'TRC'.
%                   'UNI': Uniform (rectangular)
%                   'TRI': Triangular
%                   'EPA': Epanechnikov (quadratic)
%                   'BIW': Biweight (quartic)
%                   'TRW': Triweight
%                   'TRC': Tricube
%                   'COS': Cosine
%                   'GAU': Gaussian
%                   'GAR': Gaussian modified (Rikards et al., 2006).
%   degree        : Polynomial degree. Default value = 2. If degree is not
%                   an integer, let degree = d1 + d2 where d1 is an integer
%                   and 0 < d2 < 1; then a "mixed degree fit" is performed
%                   where the fit is a weighted average of the local
%                   polynomial fits of degrees d1 and d1 + 1 with weight
%                   1 - d2 for the former and weight d2 for the latter
%                   (Cleveland & Loader, 1996).
%   useKNN        : Whether the bandwidth for kernel is defined in nearest
%                   neighbors (true) or as a metric window (false). Default
%                   value = true.
%   h             : Window size of the kernel defining its bandwidth. If
%                   useKNN = true, h defines the number of nearest
%                   neighbors: for h <= 1, the number of nearest neighbors
%                   is the fraction h of the whole dataset; for h > 1, the
%                   number of nearest neighbors is integer part of h. If
%                   useKNN = false, h defines metric window size. More
%                   specifically, let maxDist be the distance between two
%                   opposite corners of the hypercube defined by Xtr, then:
%                   for the first 7 kernel types, h*maxDist is kernel
%                   radius; for kernel type 'GAU', h*maxDist is standard
%                   deviation; for kernel type 'GAR', h is coefficient
%                   alpha (smaller alpha means larger bandwidth; see user's
%                   manual for details). In any case, h can also be called
%                   smoothing parameter. Default value = 0.5, i.e., 50% of
%                   all data if useKNN = true or 50% of maxDist if useKNN =
%                   false and kernel type is not 'GAR'.
%                   Note that if useKNN = true, the farthest of the nearest
%                   neighbors will get 0 weight.
%   robust        : Whether to use robust local regression and how many
%                   iterations to use for the robust weighting
%                   calculations. Typical values range from 2 to 5. Default
%                   value = 0 (robust version is turned off). The algorithm
%                   for the robust version is from Cleveland (1979).
%   knnSumWeights : This argument is used only if useKNN = true and fitting
%                   uses observation weights or robustness weights (when
%                   robust > 0). Set to true to define neighborhoods using
%                   a total weight content params.h (relative to sum of all
%                   weights) (Hastie et al., 2009). Set to false to define
%                   neighborhoods just by counting observations
%                   irrespective of their weights, except if a weight is 0.
%                   Default value = true.
%   standardize   : Whether to standardize all input variables to unit
%                   standard deviation. Default value = true.
%   safe          : Whether to allow prediction only if the number of the
%                   available data observations for the polynomial at a
%                   query point is larger than or equal to the number of
%                   its coefficients. Default value = true, i.e., the
%                   function will fail with error message or output NaN
%                   (what is the exact action to be taken, is determined
%                   by argument failSilently of the called function). Note
%                   that setting safe = false is not available in Octave.
%
% Output:
%   params        : A structure of parameters for further use with all the
%                   other functions of the toolbox containing the provided
%                   values (or defaults, if not provided).

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

if (nargin < 1) || isempty(kernel)
    params.kernel = 'TRC';
else
    params.kernel = kernel;
end

if (nargin < 2) || isempty(degree)
    params.degree = 2;
else
    params.degree = max(0, degree);
end

if (nargin < 3) || isempty(useKNN)
    params.useKNN = true;
else
    params.useKNN = useKNN;
end

if (nargin < 4) || isempty(h)
    params.h = 0.5;
else
    params.h = h;
end

if (nargin < 5) || isempty(robust)
    params.robust = 0;
else
    params.robust = max(0, robust);
end

if (nargin < 6) || isempty(knnSumWeights)
    params.knnSumWeights = true;
else
    params.knnSumWeights = knnSumWeights;
end

if (nargin < 7) || isempty(standardize)
    params.standardize = true;
else
    params.standardize = standardize;
end

if (nargin < 8) || isempty(safe)
    params.safe = true;
else
    if (~safe) && exist('OCTAVE_VERSION', 'builtin')
        warning('Setting safe = false is not available in Octave. Forcing true.');
        params.safe = true;
    else
        params.safe = safe;
    end
end
return
