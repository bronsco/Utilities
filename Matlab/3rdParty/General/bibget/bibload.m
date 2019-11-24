function rBib = bibload(tFile)
% bibload Load a BibTeX file for use by bibget
%
%   Usage:
%
%     bibload
%
%     bibload filename
%
%   Description:
%
%     The function bibload loads an existing BibTeX file or creates a new
%     one such that it can be used by bibget. The content of the file is
%     returned in the output structure. If the function is called without
%     an output argument, the output structure is directly assigned in the
%     caller workspace as the variable 'bib'.
%
% see also bibget, bibsave
% enable UTF-8 character set
try
	feature('DefaultCharacterSet', 'UTF-8');
catch
	warning('bibload:utf8support','Unable to activate UTF-8 support.');
end
if nargin < 1
	
	% determine which file to load from
	
	% check for a bibliographic structure in the base workspace
	tFile = [];
	if evalin('base', 'exist(''bib'',''var'')')
		rBib = evalin('base', 'bib');
		if isfield(rBib, 'tFile') && isfield(rBib, 'tDate')
			tFile = rBib.tFile;
			rFile = dir(tFile);
			if isempty(rFile)
				warning( ['The file "%s" cannot be found. ', ...
					'No data was loaded.'], tFile );
				if nargout == 0
					clear; % prevent undesired command-line output
				end
				return;
			end
			if rFile.datenum < datenum(rBib.tDate) % data is up-to-date
				if nargout == 0
					clear; % prevent undesired command-line output
				end
				return;
			end
		end
	end
	
	% select a bibtex file from the current directory
	if isempty(tFile)
		rFiles = dir('*.bib');
		nFiles = length(rFiles);
		if nFiles == 0
			tFile = [pwd, filesep, 'bib.bib'];
		elseif nFiles == 1
			tFile = rFiles.name;
		else
			fprintf(  [ 'There is more than one bibtex file ', ...
				'in the current directory.\n\n'] );
			for iFile = 1 : nFiles
				fprintf(' %2d - %s\n', iFile, rFiles(iFile).name);
			end
			fprintf('\n');
			while true
				tSel = input('Please select a number: ', 's');
				if isempty(tSel)
					fprintf('\baborted by user\n\n');
					if nargout > 0
						rBib = [];
					end
					return;
				else
					iSel = str2double(tSel);
					if isnan(iSel) || mod(iSel,1) || iSel < 1 || iSel > nFiles
						fprintf('\b <= invalid input!\n');
					else
						break;
					end
				end
			end
			tFile = rFiles(iSel).name;
		end
	end
	
else
	
	% check the filename from the input argument
	
	% get directory and file extension
	[tDir, ~, tExt] = fileparts(tFile);
	% check if directory exists
	if ~isempty(tDir) && ~isdir(tDir)
		error('The directory %s does not exist.', tDir);
	end
	% use default file extension if not specified
	if isempty(tExt)
		tFile = [tFile, '.bib'];
	end
end
if exist(tFile, 'file')
	
	% load data from an existing bibtex file
	
	% read
	hFile = fopen(tFile, 'r', 'n', 'UTF-8');
	cBib  = textscan(hFile, '%s', 'Delimiter', '@', 'EndOfLine', '');
	fclose(hFile);
	cBib  = cBib{1};
	nBib  = length(cBib);
	
	% reduce whitespace characters
	for iBib = 1 : nBib
		tBib = cBib{iBib};
		tBib = regexprep(tBib, '[ \f\r\t\v]*\n[ \f\r\t\v]*', '\n');
		tBib = regexprep(tBib, '\n+$', '');
		cBib{iBib} = tBib;
	end
	
	% extract header
	tHead = cBib{1};
	cBib  = cBib(2:end);
	nBib  = length(cBib);
	if nBib
		% extract bibtex keys and entries
		cKey = cell(nBib,1);
		for iBib = 1 : nBib
			% bibtex key
			cTok = regexp(cBib{iBib}, '[^{]+{([^,]+)', 'tokens', 'once');
			if isempty(cTok)
				cKey{iBib} = [];
			else
				cKey{iBib} = cTok{1};
			end
			% bibtex entry
			cBib{iBib} = ['@', cBib{iBib}];
		end
	else
		cKey = {};
		cBib = {};
	end
	
else
	
	% create a new bibtex file
	
	% data for new file
	cHead    = cell(5,1);
	cHead{1} = '% -------------------------------------------------------------------------';
	cHead{2} = '% --- This file was created with the Matlab program bibget. ---------------';
	cHead{3} = '% -------------------------------------------------------------------------';
	cHead{4} = '% --- www.mathworks.com/matlabcentral/fileexchange/53412-bibget -----------';
	cHead{5} = '% -------------------------------------------------------------------------';
	tHead    = sprintf('%s\n', cHead{:});
	tHead    = tHead(1:end-1);
	cKey     = {};
	cBib     = {};
	
	% create file
	hFile = fopen(tFile, 'w', 'n', 'UTF-8');
	if hFile == -1
		error('Could not create the file %s.', tFile);
	end
	fprintf(hFile, '%s', tHead);
	fclose(hFile);
	
end
% get the full path to the file
tFileFull = which(tFile);
if isempty(tFileFull)
	tFileFull = tFile;
end
% bibtex structure
rBib.tFile = tFileFull;
rBib.tHead = tHead;
rBib.cKey  = cKey;
rBib.cBib  = cBib;
rBib.tDate = datestr(now);
% assign result structure in base workspace
assignin('base', 'bib', rBib);
if nargout == 0
	clear; % prevent undesired command-line output
end
