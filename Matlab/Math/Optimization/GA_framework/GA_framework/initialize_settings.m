function [ settings, ok ] = initialize_settings( settings )
%INITIALIZE_SETTINGS for a GA
%   This function initializes or edits the settings for a GA

%% Defines the default settings

if nargin == 0

    % Number of individuals
    settings.n_ind = 40;

    % Initial mutation probability
    settings.mp = 0.0500;

    % Initial crossover probability
    settings.cp = 0.9000;

    % Number of parents involved in a crossover operation
    settings.parents_per_crossover = 2;

    % Parents compete with children
    settings.parent_children_competition = false;

    % Percentage of elitism
    settings.elitism = 0.1;

    % Scaling method
    settings.scaling = 'rank';

    % Selection Method
    settings.selection = 'srs';

    % Adaptation of setting
    settings.adaptation = 'individual';
    
    % Multiobjective Treatment
    settings.multiobjective_treatment = 'scalar';
    
    % Resolution of the Pareto Set
    settings.max_pareto = 100;

    % Number of generations (Halting criteria)
    settings.n_ger = inf; %200

    % Max generations without improvement (Halting criteria)
    settings.tenure = inf; %round(settings.n_ger/3);

    % Time limit (in seconds) (Halting criteria)
    settings.time_lim = inf; %60;

    % Will we print the results after each generation
    settings.print = true;
    
    % Do you want to control de evolution in real time
    settings.realtime_control = true;
    
    % Auto reinitializes the population if median individual == best
    settings.takeover_reinitialize = true;

end 

%% Calls the GUI to edit the default settings

[settings, ok] = initialize_settings_gui(settings);

%% Adds extra settings for realtime control

% Variable that stops the evolutions
settings.halt = false;

% Variable that tests if there is a takeover
settings.takeover = false;

% Variable that transmits reinitialization requests
settings.reinitialize = false;

end

