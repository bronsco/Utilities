function saveDataSet(obj,matfile)
%% saveDataSet Saves the current dataSet object.
%
%       save(obj,matfilename)
%
% 	saveDataSet inputs:
%
%       obj         - (object) dataSet object, that should be saved.
%       matfilename - (String) Containing the name, which is used to save the dataSet object. If
%                              there is no name passed, the user will be asked for a name within a
%                              gui (optional).
%
%
%   See also dataSet, editDataSet, editModelObject, loadDataSet.
%
%
%   LMNtool - Local Model Network Toolbox
%   Julian Belz, 20-March-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Get all properties of the object
names = properties(obj);

% Only independent properties should be saved. Dependent properties
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

for ii=1:size(names,1)
    % Create variables with the same names as the corresponding property
    if strcmp(names{ii,1},'input')
        % The unscaled values has to be saved to 'input', so the
        % loadDataSet function can put the field 'input' to the property
        % 'input'
        eval([names{ii,1},'=obj.unscaledInput;']);
    elseif strcmp(names{ii,1},'output')
        eval([names{ii,1},'=obj.unscaledOutput;']);
    else
        eval([names{ii,1},'=obj.',names{ii,1},';']);
    end
end

% Save all created variables to a mat-file
if nargin > 1
    save(matfile,names{:});
else
    [file,filepath] = uiputfile('*.mat');
    if file
        save([filepath,file],names{:});
    end
end
end % end saveDataSet