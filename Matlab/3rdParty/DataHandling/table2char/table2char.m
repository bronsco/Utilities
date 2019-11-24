function tableStr = table2char(data,varargin)
% Converts a TABLE/DATASET array to a char array.
%
% @Synopsis:
%   tableStr = table2char(data)
%     Converts 'data' to a character matrix.
%
% @Input:
%   data (required)
%     A nxm TABLE or DATASET array.
%
%   AddUnits (optional)
%     Logical scalar if to also add the units (this will add the additional 2nd
%     row). If empty, the default is used.
%     DEFAULT: false.
%
% @Output:
%   tableStr
%     A (n+2)xk character matrix with the string representation of 'data'. The
%     first row contains the variable names and the second a separator line. If
%     a value has been rounded to 0 at a column's precision (e.g. 0.00001 -> 0
%     at Precision 3), it will be shown as '<0.001' or '-<0.001' if the value
%     was negative.
%
% @Remarks
%   - No error checking is done on the inputs.
%
% @Dependancies
%   none
%
% See also DATASET, TABLE
%
% ML-FEX ID:58951
%
% @Changelog
%   2013-11-13 (DJM): Alpha release
%   2015-12-22 (DJM):
%     - [ADD] Added header.
%     - [ADD] Added number formatting.
%   2016-02-10 (DJM): [FIX] Fixed handling of logical vars.
%   2016-02-11 (DJM):
%     - [FIX] Fixed handling of DATASETs.
%     - [FIX] Overhaul on the zero removal.
%     - [ADD] Added handling of non-fininte values & sign for 0.
%   2016-02-11 (DJM): [FIX] Bug-fix for class determination (now handles
%     CATEGORICAL/NOMINAL/ORDINAL arrays correctly).
%   2016-03-22 (DJM): [FIX] Bug-fix for all-equal numeric columns (now correctly
%     returns the values instead of a column of blanks).
%   2016-04-05 (DJM): [FIX] Changed handling of inf/NaN values (these no longer
%     influence the format spec).
%   2016-06-08 (DJM): [FIX] Fixed a bug with disappearing numbers after rounding
%     to 0. 
%   2016-07-04 (DJM): [FIX] Fixed disappearing numbers if all finite values are
%     equal. 
%   2016-08-08 (DJM): [FIX] Now displays the dimensions of cell arrays of numeric
%     values instead of crashing.
%   2016-08-19 (DJM): [FIX] Fixed disappearing numbers for sparsely distributed
%     data.
%   2016-09-08 (DJM): [ADD] Now indicates, if a value is 0 after rounding to
%     the column's precision.
%   2016-09-08 (DJM): [FIX] Further fix for the rounding to zero problem.
%   2016-09-08 (DJM): [FIX] Fixed a bug where digits were removed when rounding
%     to a columns precision increased the number of integer digits.
%   2016-09-19 (DJM): [ADD] Added the optional input 'AddUnits', to specify if
%     the variables' units should be added to the output.
%   2017-02-24 (DJM): [FIX] Rounding to one problem.
%   2017-02-28 (DJM): [FIX] Error for columns containing only 1 finite negative
%                           entry and otherwise NaNs.
%   2017-05-26 (DJM): [FIX] No returns a proper representation for empty data.
%   2017-06-15 (DJM): [FIX] Error when using row names & units.
%   2017-07-07 (DJM):
%     - [MOD] Major code mod. Outsourced several routines to sub-functions to
%             make the code more maintainable. Changed the style to adhere to
%             Matlab Code Rules.
%     - [FIX] Error when a variable name is shorter than its unit.
%% Check input
id = 1;
if length(varargin) >= id && ~isempty(varargin{id})
	addUnits = varargin{id};
else %Use default.
	addUnits = false;
end
%% Init
SEPARATOR = '_';
if istable(data)
	ROW_PROP_NAME  = 'RowNames';
	UNIT_PROP_NAME = 'VariableUnits';
	varNames       = data.Properties.VariableNames;
else % DATASET
	ROW_PROP_NAME  = 'ObsNames';
	UNIT_PROP_NAME = 'Units';
	varNames       = data.Properties.varNames;
end
%% Compute stuff
[nRows,nVars] = size(data);
%Check row names.
hasRowNames = ~isempty(data.Properties.(ROW_PROP_NAME));
if hasRowNames
	%use blanks for var names / units / seperator line.
	tableStr = char(data.Properties.(ROW_PROP_NAME));
	data.Properties.(ROW_PROP_NAME) = {};
else
	tableStr = '';
end
hasUnits = ~isempty(data.Properties.(UNIT_PROP_NAME));
%% Convert columns
% 1 for header, 1 for seperator line (+1 for units).
nVarRows = 2+double(addUnits);
if hasRowNames
	tableStr = [repmat(' ',nVarRows,size(tableStr,2)); tableStr];
end
blankCol = repmat(' ',nRows+nVarRows,2);
for varId = 1:nVars
	% Remove blanks.
	varName = varNames{varId};
	varName = varName(~isspace(varName));
	% Add units to var name if necessary.
	if addUnits
		if hasUnits
			varUnit = data.Properties.(UNIT_PROP_NAME){varId};
		else
			varUnit = '';
		end
		varName = charCatCentered(varName, sprintf('[%s]', varUnit), '');
	end
	% Do actual conversion. Use "weird" indexing to avoid problems with DATASET.
	colStr = col2char(varName, data.(varNames{varId}));
	%Add separator line and concatenate with output.
	colStr   = charCatCentered(varName, colStr, SEPARATOR);
	tableStr = [tableStr blankCol colStr]; %#ok<AGROW>
end
end % MAINFUNCTION
%% SUBFUNCTION: col2char
% COL2CHAR Convert data column to character array (handle multi-dimensional
% columns by concatenation).
%
% @Input
%   varName (required): String with the name of the column (used for errors).
%
%   col (required): nxm column of table to convert.
%
% @Output
%   colStr: nxk char array with string representation of 'col'.
function colStr = col2char(varName,col)
%% >SUB: Init
%String representations of logicals.
LOGIC_NAMES = {'false';'true'}; %Should be column vector.
%% >SUB: Compute
if isempty(col)
	colStr = '';
elseif ischar(col)
	colStr = col;
else % Other data types
	for i = 1:size(col,2)
		if isnumeric(col(:,i))
			tmpStr = numcol2char(col(:,i));
		elseif islogical(col(:,i))
			tmpStr = char(LOGIC_NAMES(col(:,i)+1));
		elseif iscellstr(col(:,i)) || iscategorical(col(:,i))
			% ISCATEGORICAL also covers depricated NOMINAL/ORDINAL arrays.
			tmpStr = char(col(:,i));
		else % other types
			try 
				if iscell(col(:,i))
					tmpStr = cellcol2char(col);
				else
					% Now we really do not know what it is. Just try direct
					% conversion to char and hope it is implemented for that
					% class.
					tmpStr = char(col(:,i));
				end
			catch Err
				warning('DJM:IOFailure', ['Could not convert %s to a ' ...
					'string!\n %s'], varName, Err.message);
				tmpStr = repmat('<ERROR>',size(col,1),1);
			end
		end
		% Do the concatenation.
		if i == 1
			colStr = tmpStr;
		else
			% Add blanks in-between columns.
			colStr = [colStr repmat(' ',size(colStr,1),2) tmpStr];  %#ok<AGROW>
		end
	end
end
end % COL2CHAR
%% SUBFUNCTION: numcol2char
function colStr = numcol2char(col)
% NUMCOL2CHAR Convert numeric column to char array.
%
% @Input
%   col (required): nx1 numeric column vector.
%
% @Output
%   colStr: nxk char array with string representation of 'col'.
%% >SUB: Get props of data
isNegative   = col < 0;
isNaN        = isnan(col);
isFinite     = isfinite(col);
isAllInteger = all(mod(col(isFinite),1) == 0);
colAbs       = abs(col);
nRows        = size(col,1);
%Check for all-inf or all-NaN and return if found.
if ~any(isFinite)
	colStr = num2str(col);
	return;
end
%% >SUB: Compute format spec
[formatSpec, intPlaces, decPlaces] = computeFormatSpec(col(isFinite));
%% >SUB: Prep conversion
% Check values qreater than 0 & less than 1 after rounding.
isAbsGt0Lt1 = all(round(colAbs(isFinite),decPlaces) < 1 ...
                & round(colAbs(isFinite),decPlaces) > 0);
colStr = cellstr(num2str(colAbs,formatSpec));
colStr(isNaN)      = {num2str(NaN())}; %Avoid leading spaces.
colStr(isinf(col)) = {num2str(inf())}; %Avoid leading spaces.
%% >SUB: Remove zeros
% Do this before adding the sign!
if any(isFinite) && ~isAllInteger
	% Split the string at the decimal point.
	tmpStr = char(colStr(isFinite));
	IntStr = tmpStr(:,1:intPlaces); %Integer part.
	decStr = tmpStr(:,end-(decPlaces+double(decPlaces~=0))+1:end);%Dec. part+point.
	% Remove trailing zeros.
	decStr = regexprep(deblank(regexprep(cellstr(decStr),'0',' ')),' ','0');
	tmpStr = strcat(IntStr,decStr);
	% Remove resulting trailing dots.
	tmpStr = regexprep(tmpStr,'[.]+$','');
	% Remove leading zeros if all values are within (0,1).
	if isAbsGt0Lt1
		% Check if cells are 0 after rounding and mark them by '0.0'.
		tmpStr(ismember(tmpStr,'0')) = {'0.0'};
		tmpStr = cellfun(@(X) X(2:end), tmpStr, 'UniformOutput',false);
	end
	% Merge non-finite values back in.
	colStr(isFinite) = tmpStr;
end
%% >SUB: Check for zeros due to rounding
isRoundedZero = colAbs ~= 0 & cellfun(@(X) all(ismember(X,' 0')),colStr);
if any(isRoundedZero)
	colStr(~isRoundedZero) = strcat({' '},colStr(~isRoundedZero));
	str = sprintf(formatSpec,10^(-decPlaces));
	if isAbsGt0Lt1
		str = str(2:end); %Clip first 0.
	end
	colStr( isRoundedZero) = strcat({'<'},str);
end
%% >SUB: Add sign
if any(isNegative)
	tmpStr = [repmat(' ',nRows,1) char(colStr)];
	tmpStr(isNegative,1) = '-';
%	tmpStr(dataCol > 0   ,1) = '+';
	colStr = cellstr(tmpStr);
end
%% Convert to char again
colStr = char(colStr);
end %NUMCOL2CHAR
%% SUBFUNCTION: cellcol2char
function colStr = cellcol2char(col)
% CELLCOL2CHAR Convert numeric column to char array.
%
% @Input
%   col (required): nx1 cell.
%
% @Output
%   colStr: nxk char array with string representation of 'col'.
if all(cellfun(@isnumeric,col))
	% Cell array of numeric values. Just show the dimensions.
	if all(cellfun(@ismatrix,col))
		% All matrices, show exact dimensions.
		colStr = strcat(int2str(cellfun(@(X) size(X,1),col)), 'x', ...
						int2str(cellfun(@(X) size(X,2),col)));
	else
		% Some n-d arrays, just show dummy dimensions. 
		colStr = {'n-d'};
	end
	% Add class.
	colStr = char(strcat('[', colStr, {' '}, ...
				cellfun(@class,col,'UniformOutput',false), ']'));
else
	% Cell arrays of something other, just try to convert the content to char
	% (e.g. this works fine for function handles).
	colStr = char(cellfun(@char,col, 'UniformOutput',false));
end
end % CELLCOL2CHAR
%% SUBFUNCTION: computeFormatSpec
% COMPUTEFORMATSPEC Compute the optimal format spec for a column as used by
% SPRINTF. Optimal means showing only the significant digits along a column.
%
% @Input
%   x (required)
%     Column vector with the data. Must be all-finite.
%
% @Output
%   formatSpec
%     A string with the format spec.
%
%   intPlaces
%     An integer scalar with the number of integer places of the data.
%
%   decPlaces
%     An integer scalar with the number of decimal places of the data (e.g. its
%     precision).
%
function [formatSpec, intPlaces, decPlaces] = computeFormatSpec(x)
%% >SUB: Estimate number of decimal digits
% Use the log10 of a measure of spread to determine #decimal digits.
if any(x(1) ~= x) % Check if not all values are the same.
	% Use the IQR. Avoid dependency on Stats Toolbox's IQR.
	nDecDigits = computeIqr(x);
	% For sparsely distributed data (e.g. [0 0 0 0 0.3 0 0 0 0]), the IQR is
	% "too robust". Use SD instead.
	if nDecDigits == 0
		nDecDigits = std(x);
	end
else % All same.
	% Just use the first value.
	nDecDigits = abs(x(1));
end
nDecDigits = log10(nDecDigits);
%% >SUB: Compute number decimal places
if isfinite(nDecDigits) && any(mod(x,1)~=0) % non-integer
	% Use floor of signed nDigits to add more digits for small values.
	decPlaces = max(0,ceil(abs(nDecDigits)) - floor(nDecDigits));
else
	decPlaces = 0;
end
%% >SUB: Compute field width (number of total places)
xAbsMax = max(abs(x));
if floor(xAbsMax) > 0
	intPlaces = floor(log10(round(xAbsMax,decPlaces))) + 1;
else
	intPlaces = 1;
end
fieldWidth = intPlaces + decPlaces + double(decPlaces~=0); %add dec. point
%% >SUB: Create format string
formatSpec = sprintf('%%%d.%df',fieldWidth,decPlaces);
end % COMPUTEFORMATSPEC
%% SUBFUNCTION: computeIqr
% COMPUTEIQR Computes the empirical IQR using solution R-9 in:
%  https://en.wikipedia.org/wiki/Quantile#Estimating_quantiles_from_a_sample.
%
% @Input
%   x (required)
%     Column vector with the data. Must be all-finite.
%
% @Output
%   iQR
%     Scalar with the IQR.
%
function iQR = computeIqr(x)
%% >SUB: Init
QUARTILES = 0.25*[1;3];
%% >SUB: Compute
x = sort(x);
n = length(x);
if QUARTILES(1) < 5/(8*n+2) % <=> (5/8)/(n+1/4); lower bound on p
	xP = x([1 end]);
else
	h  = (n+1/4)*QUARTILES + 3/8;
	hF = floor(h);
	xP = x(hF) + (h-hF).*(x(hF+1)-x(hF));
end
iQR = diff(xP);
end % COMPUTEIQR
%% SUBFUNCTION: str = charCatCentered(str1, str2, sep)
% CHARCATCENTERED Concatenates two strings vertically centered.
%
% @Input
%   str1 (required)
%     A kxn char array.
%
%   str2 (required)
%     A lxm char array.
%
%   sep (required)
%     A 1x1 char used as separator between str1 & str2. If empty, no separator
%     is used.
%
% @Output
%   str
%     A (k+l+length(sep))xmax(m,k) char array with the concatenated strings.
%
function str = charCatCentered(str1, str2, sep)
%% >SUB: Create centered columns
[nRows1,nCols1] = size(str1);
[nRows2,nCols2] = size(str2);
nDiff = abs(nCols1-nCols2)/2;
if nDiff > 0
	leftBlanks  = blanks(floor(nDiff));
	rightBlanks = blanks( ceil(nDiff));
	if nCols2 > nCols1
		str1 = [repmat(leftBlanks ,nRows1,1) str1 ...
		        repmat(rightBlanks,nRows1,1)];
	else
		str2 = [repmat(leftBlanks ,nRows2,1) str2 ...
		        repmat(rightBlanks,nRows2,1)];
	end
end
%% >SUB: Concatenate
if sep
	sep = repmat(sep,1,max(nCols1,nCols2));
else
	sep = '';
end
str = [str1;sep;str2];
end % CHARCATCENTERED