function TableStr = table2char(Data,varargin)
% Converts a TABLE/DATASET array to a char array.
%
% @Synopsis:
%   TableStr = table2char(Data)
%     Converts 'Data' to a character matrix.
%
% @Input:
%   Data (required)
%     A nxm TABLE or DATASET array.
%
%   AddUnits (optional)
%     Logical scalar if to also add the units (this will add the additional 2nd
%     row). If empty, the default is used.
%     DEFAULT: false.
%
% @Output:
%   TableStr
%     A (n+2)xk character matrix with the string representation of 'Data'. The
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
%   2017-05-26 (DJM): [FIX] No returns a proper representation for empty Data.
%   2017-06-15 (DJM): [FIX] Error when using row names & units.

%% Check input
Id = 1;
if length(varargin) >= Id && ~isempty(varargin{Id})
	AddUnits = varargin{Id};
else %Use default.
	AddUnits = false;
end

if istable(Data)
	RowPropName  = 'RowNames';
	UnitPropName = 'VariableUnits';
	VarNames     = Data.Properties.VariableNames;
else %Dataset
	RowPropName  = 'ObsNames';
	UnitPropName = 'Units';
	VarNames     = Data.Properties.VarNames;
end

%% Init
%String representations of logicals.
LogicalValues = {'false';'true'}; %Should be column vector.

[nRows,nVars] = size(Data);

%Check row names.
HasRowNames = ~isempty(Data.Properties.(RowPropName));
if HasRowNames
	%use blanks for var names / units / seperator line.
	TableStr = char(Data.Properties.(RowPropName));
	Data.Properties.(RowPropName) = {};
else
	TableStr = '';
end

HasUnits = ~isempty(Data.Properties.(UnitPropName));

%% Convert columns
%+1 for header & +1 for units.
nVarCols = 1+double(AddUnits);
Blanks = repmat(' ',nRows+nVarCols+1,2); %+1 seperator line.
if HasRowNames
	TableStr = [repmat(' ',nVarCols+1,size(TableStr,2));TableStr];
end

for VarId = 1:nVars
	Var = VarNames{VarId};
	Var = Var(~isspace(Var));

	%Keep the "weird" indexing to avoid problems with DATASET.
	Col = Data.(VarNames{VarId});

	%Convert column to character array (handle multi-dimensional columns by
	%concatenation)...
	if isempty(Col)
		ColStr = '';
	elseif ischar(Col)
		ColStr = Col;
	else %Other data types
		for i = 1:size(Col,2)
			if isnumeric(Col(:,i))
				TmpStr = numcol2char(Col(:,i));
			elseif islogical(Col(:,i))
				TmpStr = char(LogicalValues(Col(:,i)+1));
			elseif iscellstr(Col(:,i))% || iscategorical(Col(:,i))
				%ISCATEGORICAL also covers depricated NOMINAL/ORDINAL arrays.
				TmpStr = char(Col(:,i));
			else  %other types
				try 
					if iscell(Col(:,i))
						if all(cellfun(@isnumeric,Col(:,i)))
							%Cell array of numeric values. Just show the dimensions...
							if all(cellfun(@ismatrix,Col(:,i)))
								%...all matrices, so show the exact dimensions.
								TmpStr = strcat(int2str(cellfun(@(X) size(X,1),...
												Col(:,i))), 'x', ...
												int2str(cellfun(@(X) size(X,2),Col(:,i))));
							else
								%...some n-d arrays, so just show dummy dimensions.
								TmpStr = {'n-d'};
							end
							TmpStr = char(strcat('[',TmpStr,{' '},...
												cellfun(@class,Col(:,i), ...
													'UniformOutput',false), ']'));
						else
							%Cell arrays of something other, just try to convert the
							%content to char (e.g. this works fine for function
							%handles).
							TmpStr ...
								= char(cellfun(@char,Col(:,i),'UniformOutput',false));
						end
					else
						%Now we really do not know what it is. Just try direct
						%conversion to char and hope it is implemented for that
						%class.
						TmpStr = char(Col(:,i));
					end
				catch Err
					warning('DJM:IOFailure',...
						'Could not convert %s to a string!\n %s',Var,Err.message);
					TmpStr = repmat('<ERROR>',nRows,1);
				end
			end
			%...do the concatenation.
			if i == 1
				ColStr = TmpStr;
			else
				%...add some blanks in-between columns.
				ColStr = [ColStr repmat(' ',size(ColStr,1),2) TmpStr];  %#ok<AGROW>
			end
		end
	end

	if AddUnits
		if HasUnits
			Unit = Data.Properties.(UnitPropName){VarId};
		else
			Unit = '';
		end
		Unit = sprintf('[%s]', Unit);
		
		%Center variable name & units.
		nVarChars  = length(Var);
		nUnitChars = length(Unit);
		nDiff = abs(nUnitChars-nVarChars)/2;
		if nDiff > 0
			LeftBlanks  = blanks(floor(nDiff));
			RightBlanks = blanks( ceil(nDiff));
			if nVarChars < nUnitChars
				Var = [LeftBlanks Var RightBlanks; Unit]; %#ok<AGROW>
			else %nUnitChars < nVarChars
				Var = [Var; LeftBlanks Unit RightBlanks]; %#ok<AGROW>
			end
		end
	end
	
	%Create centered columns.
	nColChars = size(ColStr,2);
	nVarChars = size(Var,2);
	nDiff = abs(nColChars-nVarChars)/2;
	if nDiff > 0
		LeftBlanks  = blanks(floor(nDiff));
		RightBlanks = blanks( ceil(nDiff));
		if nColChars > nVarChars
			Var = [repmat(LeftBlanks,nVarCols,1) ...
			       Var ...
			       repmat(RightBlanks,nVarCols,1)]; %#ok<AGROW>
		else %nColChars < nVarChars
			ColStr = [repmat(LeftBlanks,nRows,1) ...
			          ColStr ...
			          repmat(RightBlanks,nRows,1)]; %#ok<AGROW>
		end
	end

	%Add separator line and concatenate to output.
	TableStr = [TableStr Blanks ...
               [Var;repmat('_',1,max(nColChars,nVarChars));ColStr]]; %#ok<AGROW>
end %nCols
end %TABLE2CHAR



%% SUBFUNCTION: numcol2char
function ColStr = numcol2char(Col)
%Convert numeric column to char array.
%
% @Input
%   Col (required): The column of the table to convert.
%
% @Output
%   ColStr: The string representation of 'Col'.

%% >SUB: Get props of Col
IsNegative   = Col < 0;
IsNaN        = isnan(Col);
IsFinite     = isfinite(Col);
IsAllInteger = all(mod(Col(IsFinite),1) == 0);
ColAbs       = abs(Col);
ColAbsMax    = max(ColAbs(IsFinite));
nRows        = size(Col,1);

%Check for all-inf or all-NaN and return if found.
if ~any(IsFinite)
	ColStr = num2str(Col);
	return;
end

%% >SUB: Compute format spec
%Get indicator for the numer of decimal digits from the variance...
Id = find(IsFinite,1,'first');
if all(Col(Id) == Col(IsFinite))
	%...if they are all the same use just the log.
	ColVarLog = abs(Col(Id));
else 
	%...otherwise use the log of the IQR. Compute empirical prctiles as taken
	%from solution R-9 in: 
	%  https://en.wikipedia.org/wiki/Quantile#Estimating_quantiles_from_a_sample
	%to avoid depency on Stats Toolbox's IQR.
	X = sort(Col(IsFinite));
	n = length(X);
	if 0.25 < 5/(8*n+2) % <=> (5/8)/(n+1/4); lower bound on p
		XP = X([1 end]);
	else
		H  = (n+1/4)*[0.25;0.75] + 3/8;
		HF = floor(H);
		XP = X(HF) + (H-HF).*(X(HF+1)-X(HF));
	end
	ColVarLog = diff(XP);

	%Check for sparsely distributed data (e.g. [0 0 0 0 0.3 0 0 0 0]) for which
	%the IQR is too robust. Use SD instead. 
	if ColVarLog == 0
		ColVarLog = std(Col(IsFinite));
	end
end
ColVarLog = log10(ColVarLog);

%Compute decimal places. Use floor of signed value to add more digits for small
%values.
if isfinite(ColVarLog) && ~IsAllInteger
	Precision = max(0,ceil(abs(ColVarLog)) - floor(ColVarLog));
else
	Precision = 0;
end

%Compute field width.
if ~isempty(ColAbsMax) && floor(ColAbsMax) > 0
	IntegersPlaces = floor(log10(round(ColAbsMax,Precision))) + 1;
else
	IntegersPlaces = 1;
end
FieldWidth = IntegersPlaces + Precision + double(Precision>0); %add dec. point

FormatSpec = sprintf('%%%d.%df',FieldWidth,Precision);

%% >SUB: Create formatted string
% Check values qreater than 0 & less than 1 after rounding.
IsAbsQt0Lt1 = all(round(ColAbs(IsFinite),Precision) < 1 ...
                & round(ColAbs(IsFinite),Precision) > 0);

ColStr = cellstr(num2str(ColAbs,FormatSpec));
ColStr(IsNaN)      = {num2str(NaN())}; %Avoid leading spaces.
ColStr(isinf(Col)) = {num2str(inf())}; %Avoid leading spaces.

%Remove zeros (before adding the sign!)...
if any(IsFinite) && ~IsAllInteger
	%...split the string at the decimal point.
	TmpStr = char(ColStr(IsFinite));
	IntStr = TmpStr(:,1:IntegersPlaces); %Integer part.
	DecStr = TmpStr(:,end-(FieldWidth-IntegersPlaces)+1:end);%Decimal part+point.
	%...remove trailing zeros.
	DecStr = regexprep(deblank(regexprep(cellstr(DecStr),'0',' ')),' ','0');
	TmpStr = strcat(IntStr,DecStr);
	%...remove resulting trailing dots.
	TmpStr = regexprep(TmpStr,'[.]+$','');
	%...remove leading zeros if all values are within (0,1).
	if IsAbsQt0Lt1
		%...check if cells are 0 after rounding and mark them by '0.0'.
		TmpStr(ismember(TmpStr,'0')) = {'0.0'};
		TmpStr = cellfun(@(X) X(2:end), TmpStr, 'UniformOutput',false);
	end
	%...merge non-finite values back in.
	ColStr(IsFinite) = TmpStr;
end

%Check for zeros due to rounding.
IsRoundedZero = ColAbs ~= 0 & cellfun(@(X) all(ismember(X,' 0')),ColStr);
if any(IsRoundedZero)
	ColStr(~IsRoundedZero) = strcat({' '},ColStr(~IsRoundedZero));
	Str = sprintf(FormatSpec,10^(-Precision));
	if IsAbsQt0Lt1
		Str = Str(2:end); %Clip first 0.
	end
	ColStr( IsRoundedZero) = strcat({'<'},Str);
end

%Add sign.
if any(IsNegative)
	TmpStr = [repmat(' ',nRows,1) char(ColStr)];
	TmpStr(IsNegative,1) = '-';
%	TmpStr(Col > 0   ,1) = '+';
	ColStr = cellstr(TmpStr);
end

%Convert to char again.
ColStr = char(ColStr);
end %NUMCOL2CHAR