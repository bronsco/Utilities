function resaveMdl2Slx(basePath, deleteMDL)

if nargin < 2
	deleteMDL = false;
end

fileList = getAllFiles(basePath);

for n = 1:length(fileList)
	currFile = fileList{n};
	[pn,fn,ext] = fileparts(currFile);
	if strcmp(ext,'.mdl')
		open_system(currFile)
		close_system(currFile, fullfile(pn,[fn,'.slx']))
		
		if deleteMDL
			delete(currFile);
		end
	end
end
		
end