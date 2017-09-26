function fileList = getAllFiles(dirName, fileExtension, appendFullPath)

% searches recursively through all subdirectories of a given directory,
% collecting a list of all file names it finds. The adduitional parameters
% are file extensions to filter on and a flag indicating whether to
% concatenate the full path to the name of the file or not.
%
% Example
%	fileList = getAllFiles(dirName, '*.xml', 0)

if nargin < 3
	appendFullPath = true;
end
if nargin < 2
	fileExtension = '*.*';
end

dirData = dir([dirName '/' fileExtension]);      %# Get the data for the current directory
dirWithSubFolders = dir(dirName);
dirIndex = [dirWithSubFolders.isdir];  %# Find the index for directories
fileList = {dirData.name}';  %'# Get a list of the files
if ~isempty(fileList)
	if appendFullPath
		fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
			fileList,'UniformOutput',false);
	end
end
subDirs = {dirWithSubFolders(dirIndex).name};  %# Get a list of the subdirectories
validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
%#   that are not '.' or '..'
for iDir = find(validIndex)                  %# Loop over valid subdirectories
	nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
	fileList = [fileList; getAllFiles(nextDir, fileExtension, appendFullPath)];  %# Recursively call getAllFiles
end

end