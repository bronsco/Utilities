%% lolimotdemo LOLIMOT-Toolbox Demos
%
%
%   Available demonstration examples:
%       Demo 1: Static process with 1 input and 1 output.
%       Demo 2: Static process with 2 inputs and 1 output.
%       Demo 3: Static process with 2 inputs and 2 outputs.
%       Demo 4: Dynamic process of second order with 1 input and 1 output.
%       Demo 5: Dynamic process of first order with 2 inputs and 2 outputs.
%       Demo 6: Estimate a model given an initial structure.
% 
%
%   LoLiMoT - Nonlinear System Identification Toolbox
%   Torsten Fischer, 17-February-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


clear;
clear all;
close all;
clc

% Menu
i = menu('Choose one of the following examples:',...
    '1. Static process with 1 input and 1 output', ...
    '2. Static process with 2 inputs and 1 output', ...
    '3. Static process with 2 inputs and 2 outputs', ...
    '4. Dynamic process of second order with 1 input and 1 output',...
    '5. Dynamic process of first order with 2 inputs and 2 outputs', ...
    '6. Estimate a model given an initial structure');


% Add LOLIMOT directory to MATLAB search path
lolimotDirectory = fileparts(which(mfilename));
classesDirectory = fileparts(lolimotDirectory);
lolimotDemoDirectory = [lolimotDirectory '/demo'];
addpath(classesDirectory);
addpath(lolimotDirectory);
addpath(lolimotDemoDirectory);

% Execute demo program
if i == 1
    lolimotDemo1
elseif i == 2
    lolimotDemo2
elseif i == 3
    lolimotDemo3
elseif i == 4
    lolimotDemo4
elseif i == 5
    lolimotDemo5
elseif i == 6
    lolimotDemo6
end


% Clear variables
clear i lolimotDirectory lolimotDemoDirectory classesDirectory
