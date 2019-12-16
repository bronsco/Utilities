function primprint(prim, precision)
% primprint
% Prints the rules of the boxes in a human-readable form.
%
% Call:
%   primprint(prim, precision)
%
% Input:
%   prim          : PRIM built using function primbuild.
%   precision     : (optional) Number of digits to display for the floating
%                   point numbers. (default value = 4)

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

if nargin < 1
    error('Not enough input arguments.');
end
if (nargin < 2) || isempty(precision)
    precision = 4;
end

p = ['%.' num2str(precision) 'g'];

disp(['YmeanGlobal = ' num2str(prim.info.meanGlobal,p) '   n = ' num2str(prim.info.n,p)]);

nBoxes = length(prim.boxes);
for i = 1 : nBoxes
    box = prim.boxes{i};
    
    fprintf('\n');
    if isempty(box.vars)
        disp(['Box' num2str(i) ' ''leftovers'':']);
    else
        disp(['Box' num2str(i) ':']);
    end
    
    str = [' Ymean = ' num2str(box.mean,p)];
    str = [str '   support = ' num2str(box.support,p) ' (' num2str(box.supportN) ')'];
    if isfield(box,'meanTest')
        str = [str '   YmeanTest = ' num2str(box.meanTest,p)];
    end
    if isfield(box,'meanTest')
        str = [str '   supportTest = ' num2str(box.supportTest,p) ' (' num2str(box.supportNTest) ')'];
    end
    disp(str);
    
    for j = 1 : length(box.vars)
        k = box.vars(j);
        if ~isnan(box.min(j)) && ~isnan(box.max(j))
            str = [num2str(box.min(j),p) ' <= x' num2str(k) ' <= ' num2str(box.max(j),p)];
        elseif ~isnan(box.min(j))
            str = ['x' num2str(k) ' >= ' num2str(box.min(j),p)];
        elseif ~isnan(box.max(j))
            str = ['x' num2str(k) ' <= ' num2str(box.max(j),p)];
        elseif ~isempty(box.cats(j))
            cats = box.cats{j};
            if isempty(cats)
                str = [];
            else
                str = ['x' num2str(k) ' in {'];
                for kk = 1 : length(cats)
                    if kk > 1
                        str = [str ', '];
                    end
                    str = [str num2str(cats(kk))];
                end
                str = [str '}'];
            end
        else
            str = [];
        end
        if prim.info.hasNan(k)
            % Some parts are commented-out because in PRIM boxes are
            % usually defined only by excluding values.
            if isempty(str)
                %if box.nan(j)
                %    str = ['x' num2str(k) ' == missing'];
                %else
                    str = ['x' num2str(k) ' ~= missing'];
                %end
            else
                %if box.nan(j)
                %    str = [str ' OR x' num2str(k) ' == missing'];
                %else
                    str = [str ' AND x' num2str(k) ' ~= missing'];
                %end
            end
        end
        disp([' ' str]);
    end
end

fprintf('\n');
printinfo(prim)
return

%==========================================================================

function printinfo(prim)
nBoxes = length(prim.boxes);
vars = [];
for i = 1 : nBoxes
    vars = union(vars, prim.boxes{i}.vars);
end
fprintf('Number of boxes: %d\n', nBoxes);
if ~isempty(vars)
    list = '';
    for i = 1:length(vars)
        list = [list 'x' int2str(vars(i))];
        if i < length(vars)
            list = [list ', '];
        end
    end
    fprintf('Total number of variables used (except the ''leftovers'' box): %d (%s)\n', length(vars), list);
else
    fprintf('Total number of variables used (except the ''leftovers'' box): 0\n');
end
return
