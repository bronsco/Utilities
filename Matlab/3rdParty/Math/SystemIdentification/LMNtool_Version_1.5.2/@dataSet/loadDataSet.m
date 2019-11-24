function ds = loadDataSet(matfile)
%% loadDataSet Load a previously saved dataSet object
%
%
%       [ds] = loadDataSet(matfilename)
%
%
%   loadDataSet input:
%
%       matfilename - (String) Containing the filename (and path)
%                              of the mat-file, that should be
%                              loaded
%
% 	loadDataSet output:
%
%       ds - (class) dataSet object
%
%
%   See also dataSet, editDataSet, editModelObject, saveDataSet.
%
%
%   LMNtool - Local Model Network Toolbox
%   Julian Belz, 20-March-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


if nargin == 0
    [file,filepath] = uigetfile('*.mat',...
        'Auswahl eines mat-Files');
    if file
        matfile = [filepath,file];
    else
        ds = [];
        return;
    end
end

tmp = load(matfile);
ds                  = dataSet;

names   = fieldnames(tmp);

% Only independent properties can be passed. Dependent properties
% within the dataset class are the 'unscaledInput' and the
% 'unscaledOutput'. These two properties has to be deleted from the
% 'names' cell. Some properties of the regressor class are deleted as well.
idx1  = strcmp(names,'unscaledInput');
idx2  = strcmp(names,'unscaledOutput');
idx3  = strcmp(names,'xInputDelay');
idx4  = strcmp(names,'zInputDelay');
idx5  = strcmp(names,'xOutputDelay');
idx6  = strcmp(names,'zOutputDelay');
idx   = abs((idx1 + idx2 + idx3 + idx4 + idx5 +idx6) - 1);
names = names(logical(idx),1);
    
for ii = 1:size(names,1)
    % Check if fieldname is a property of the dataset class
    if any(strcmp(names{ii,1}, properties(ds)))
        eval(['ds.',names{ii,1},'=tmp.',names{ii,1},';']);
    end
end

end % end loadDataSet