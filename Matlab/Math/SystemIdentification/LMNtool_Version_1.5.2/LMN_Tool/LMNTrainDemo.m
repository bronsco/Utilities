% DEMO FOR LMNTRAIN
%
% LMNTool - Nonlinear System Identification Toolbox
% Institute of Mechanics & Automatic Control 
% University of Siegen, Germany 
% Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles et. al.

% Version: 21-March-2012


% Clearing
clear
clear all
clear java
close all
clc

% Add path of LMN class files, if not existing already
me = mfilename;     % What is my filename?
mydir = which(me);  % Where am I located?
mydir = mydir(1:end-2-numel(me));
if isempty(strfind(path,mydir))
    addpath(mydir);
    addpath([mydir,'lolimot'])
    addpath([mydir,'lolimot/demo'])
    addpath([mydir,'hilomot'])
    addpath([mydir,'hilomot/demo'])
    addpath([mydir,'LMNTrainExamples'])
end

% Menu
i = menu('Choose one of the following examples:',...
    '1. Static process with 1 input and 1 output', ...
    '2. Static process with 2 inputs and 1 output', ...
    '3. Static process with 2 inputs and 1 output', ...
    '4. Static process with 2 inputs and 2 outputs');

% Execute demo program
if i == 1
    LMNDemo1
elseif i == 2
    LMNDemo2
elseif i == 3
    LMNDemo3
elseif i == 4
    LMNDemo4
end

% Clear variables
clear me mydir i s