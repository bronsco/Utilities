function Yq = primpredict(prim, Xq)
% primpredict
% Predicts response values for the given query points Xq using a sequence
% of PRIM boxes.
%
% Call:
%   Yq = primpredict(prim, Xq)
%
% Input:
%   prim          : PRIM built using function primbuild.
%   Xq            : A matrix of query data points. Missing values in Xq
%                   must be indicated as NaN. Any previously unseen values
%                   of categorical variables are treated as NaN.
%
% Output:
%   Yq            : A column vector of predicted response values.

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

if nargin < 2
    error('Not enough input arguments.');
end
nq = size(Xq,1);
Yq = zeros(nq,1);
nBoxes = length(prim.boxes);
for i = 1 : nq
    for b = 1 : nBoxes
        box = prim.boxes{b};
        success = true;
        if b < nBoxes % the last box ('leftovers') should always succeed
            for j = 1 : length(box.vars)
                k = box.vars(j);
                % If value is unknown or it's a previously unseen category
                if isnan(Xq(i,k)) || ...
                   (prim.info.isBinCat(k) && ~any(prim.info.catVals{k} == Xq(i,k)))
                    if ~box.nan(j)
                        success = false;
                        break;
                    end
                else
                    if prim.info.isBinCat(k)
                        if ~any(box.cats{j} == Xq(i,k))
                            success = false;
                            break;
                        end
                    else
                        if (Xq(i,k) < box.min(j)) || (Xq(i,k) > box.max(j))
                            success = false;
                            break;
                        end
                    end
                end
            end
        end
        if success
            Yq(i) = box.mean;
            break;
        end
    end
end
return
