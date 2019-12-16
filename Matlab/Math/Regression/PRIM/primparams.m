function params = primparams(alphaPeel, alphaPaste, minSupport, maxBoxes, terminateBelowMean)
% primparams
% Creates configuration for the PRIM algorithm. The output structure is for
% further use with function primbuild.
%
% Call:
%   params = primparams(alphaPeel, alphaPaste, minSupport, maxBoxes, terminateBelowMean)
%
% All the input arguments of this function are optional. Empty values are
% also accepted (the corresponding default values will be used).
%
% Input:
%   alphaPeel     : Peeling quantile. Usually chosen somewhere between 0.05
%                   and 0.1 (default value = 0.1) (Friedman & Fisher,
%                   1999). This defines the fraction of the data in the
%                   current box that is removed at each iteration. Too
%                   large values make the peeling crude. Too small values
%                   make the peeling sensitive to noise.
%   alphaPaste    : Pasting quantile. Set to 0 to disable pasting. (default
%                   value = 0.05)
%   minSupport    : The peeling of a box continues until its support (i.e.,
%                   the fraction of data covered by the box) drops below
%                   minSupport. Friedman & Fisher, 1999, call this
%                   parameter "beta0". Values lower than or equal to 1 are
%                   treated as percent of the whole data. Values larger
%                   than 1 are treated as a number of data observations.
%                   Default value = 0.1, i.e., minimum support for a box is
%                   10% of the whole data.
%   maxBoxes      : The maximum number of boxes to build. Default value =
%                   Inf. Usually the most interesting boxes are only the
%                   few first ones. Note that actually the result will
%                   always contain one box more than specified here because
%                   the last box will always be the 'leftovers' box that
%                   contains all the data observations not covered by any
%                   previous boxes.
%   terminateBelowMean : Whether to stop building boxes when the mean value
%                   of Y for a completed new box drops below the global
%                   mean of Y. Default value = true.
%
% Output:
%   params        : A structure of parameters for further use with function
%                   primbuild containing the provided values (or default
%                   ones, if not provided).

% =========================================================================
% Bump hunting using Patient Rule Induction Method for Matlab/Octave
% Author: Gints Jekabsons (gints.jekabsons@rtu.lv)
% URL: http://www.cs.rtu.lv/jekabsons/
%
% Copyright (C) 2015  Gints Jekabsons
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

% Last update: November 9, 2015

if (nargin < 1) || isempty(alphaPeel)
    params.alphaPeel = 0.1;
else
    params.alphaPeel = max(0, alphaPeel);
end

if (nargin < 2) || isempty(alphaPaste)
    params.alphaPaste = 0.05;
else
    params.alphaPaste = max(0, alphaPaste);
end

if (nargin < 3) || isempty(minSupport)
    params.minSupport = 0.1;
else
    params.minSupport = max(0, minSupport);
end

if (nargin < 4) || isempty(maxBoxes)
    params.maxBoxes = Inf;
else
    params.maxBoxes = max(1, maxBoxes);
end

if (nargin < 5) || isempty(terminateBelowMean)
    params.terminateBelowMean = true;
else
    params.terminateBelowMean = terminateBelowMean;
end

return
