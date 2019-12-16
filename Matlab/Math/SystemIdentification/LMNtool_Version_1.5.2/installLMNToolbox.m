% Local Model Network Toolbox installation file

% first, lets prevent some realy stupid errors
close all
clear run addpath version

% get directory of the toolbox
LMNDirectory = fileparts(which(mfilename));

% make a help database
if exist(fullfile(LMNDirectory,'html'),'dir') == 7
    pathToToolboxHelp = [LMNDirectory '/html'];
    eval(['builddocsearchdb(''',pathToToolboxHelp,''')']);
end

% Add toolbox directory to MATLAB search path
addpath(LMNDirectory);

% Add LMN-Tool to MATLAB search path
addpath(fullfile(LMNDirectory,'LMN_Tool'))
addpath(fullfile(LMNDirectory,'LMN_Tool','LMNTrainExamples'))

% Add lolimot directory to MATLAB search path
addpath(fullfile(LMNDirectory,'lolimot'))
addpath(fullfile(LMNDirectory,'lolimot','demo'))

% Add hilomot directory to MATLAB search path
addpath(fullfile(LMNDirectory,'hilomot'))
addpath(fullfile(LMNDirectory,'hilomot','demo'))

if exist(fullfile(LMNDirectory,'inputSelection'),'dir') == 7
    % Add inputSelection directory to MATLAB search path
    addpath(fullfile(LMNDirectory,'inputSelection'))
    addpath(fullfile(LMNDirectory,'inputSelection','demo'))
end

% Add plotSettings directory to MATLAB search path
addpath(fullfile(LMNDirectory,'plotSettings'))

if exist(fullfile(LMNDirectory,'hilomotDoE'),'dir') == 7
    % Add hilomotDoE directory to MATLAB search path
    addpath(fullfile(LMNDirectory,'hilomotDoE'))
    addpath(fullfile(LMNDirectory,'hilomotDoE','demo'))
    addpath(fullfile(LMNDirectory,'hilomotDoE','minMaxMaps'))
end

% Check if additional features should be installed
if (exist(fullfile(LMNDirectory,'additionalFeatures'),'dir') == 7) && ...
        (exist(fullfile(LMNDirectory,'additionalFeatures','installAdditionalFeatures.m'),'file') == 2)
    run(fullfile(LMNDirectory,'additionalFeatures','installAdditionalFeatures.m'))
end

% Save path for future sessions
savepath

% Clear variables
clear LMNDirectory pathToToolboxHelp

% Clear classes
clear classes

disp('Please restart MATLAB to enable the HELP and DOC for this toolbox')


