function bibsave(tFile)
% bibsave Save the BibTeX entries retrieved by bibget
%
%   Usage:
%
%     bibsave
%
%     bibsave filename
%
%   Description:
%
%     The function bibsave saves the current bibliographic database to a
%     BibTeX file which is either selected by the first input argument,
%     or which is equal to the file from which the database was loaded.
%
% see also bibget, bibload
% this flag enables the usage of '\r\n' instead of '\n'
bWindowsLineFeed = true; %#ok<*UNRCH>
% get bibtex data structure from base workspace
if evalin('base', 'exist(''bib'',''var'')')
	rBib = evalin('base', 'bib');
else
	error('There is no bibtex data structure to save.');
end
% use file from bibtex data structure if no input argument is given
if nargin < 1
	tFile = rBib.tFile;
end
% get directory and file extension
[tDir, tFileName, tExt] = fileparts(tFile);
% use default file extension if not specified
if isempty(tExt)
	tFile = [tFile, '.bib'];
end
% check if directory exists and append file-separator
if ~isempty(tDir)
	if ~isdir(tDir)
		error('The directory %s does not exist.', tDir);
	else
		tDir = [tDir, filesep];
	end
end
% rename present file
if exist(tFile, 'file')
	cClock = num2cell(clock);
	tClock = sprintf('%4d%02d%02d%02d%02d%02.0f', cClock{:});
	tFileCopy = [tDir, tFileName, '_', tClock, tExt];
	movefile(tFile, tFileCopy);
end
% open new file
hFile = fopen(tFile, 'w', 'n', 'UTF-8');
% check file handle
if hFile == -1
	error('Could not create file %s.', tFile);
end
% write header to file
fprintf(hFile, '%s', rBib.tHead);
% write bibtex entries to file
if bWindowsLineFeed
	tLfOld = sprintf('\n');
	tLfNew = sprintf('\r\n');
	for iBib = 1 : length(rBib.cBib)
		fprintf(hFile, '\r\n\r\n%s', strrep(rBib.cBib{iBib},tLfOld,tLfNew));
	end
else
	for iBib = 1 : length(rBib.cBib)
		fprintf(hFile, '\n\n%s', rBib.cBib{iBib});
	end
end
% close file
fclose(hFile);
% delete copy of old file
if exist('tFileCopy', 'var')
	delete(tFileCopy);
end
% update the file path if necessary
if nargin
	tFileFull = which(tFile);
	if isempty(tFileFull)
		tFileFull = tFile;
	end
	evalin('base', sprintf('bib.tFile = ''%s'';', tFileFull));
end
