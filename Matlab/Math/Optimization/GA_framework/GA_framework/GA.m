function [ population, stats, settings, problem ] = GA( problem, settings, population )
%GA (Genetic Algorithm) on a PROBLEM with certain SETTINGS
%
% [population,stats,time_spent,settings,problem] = GA( problem, settings )
% finds the solution for PROBLEM with the specified SETTINGS. The operators
% for the problem can be defined by the user. The algorithm returns the
% final population, statistics, time spent to find the result, the
% settings, and the population.
%
% Inputs: 
%    problem   = struct with the information about the problem. The
%       function the initialize the problem can be defined by the user
%       according to a example problem
%
%    settings = struct with the settings for the genetic algorithm.
%
% Outputs:
%    population = last population of the algorithm, including their
%       objective function values and the best solution found by the GA
%
%    stats = statistics about the evolution that can be used later
%
%    time_spent = time spent by the algorithm to find the results (seconds)
%
%    settings = the settings used by the GA
%
%    problem = the problem that was optimized
%
% You need to define the functions for your own problem before using the GA
%   There are some examples included in the framework.
% Include the framework folder in your search path and go to the folder
%   where the problem is defined.
% You can then initialize your problem with problem = [problem]_initialize
%   and run the GA with GA(problem) or GA(problem, settings)
%
% The struct variables PROBLEM and SETTINGS can be obtained from the
%       functions [problem name]_initialize.m (in the problem folder) and
%       initialize_settings.m (in the framework folder)
%
%   In order to define your own problem, you can follow the examples in the
%       folder problems. Help this project by sharing the problems you have
%       modeled. You will have to create these new functions:
%       * [problem name]_initialize_[generation method].m
%       * [problem name]_generate_[generation method].m
%       * [problem name]_evaluate.m
%       * [problem name]_crossover_[crossover method].m
%       * [problem name]_mutation_[mutation method].m
%
%   You can also create those functions if you want to extend possibilities:
%       * [problem name]_population.m
%       * [problem name]_print.m
%       * [problem name]_evaluate_population.m
%
%   You can also colaborate on the GA itself by defining new functions:
%       * selection_[name of selection method].m
%       * scaling_[name of the scaling method].m
%       * adaptation_[name of the adaptation method].m
%
%
% Examples: 
% 
% % (1) Save the framework folder to your search path
% % (2) Go to the folder of a sample problem and run
% >> [population, stats] = GA([problem name]_initialize());
% >> population.best
%
% See also: randn, rand, plot
%
% $Author: Alan de Freitas $    $Date: 2012/09/02 $    $Revision: 1.0 $
% Copyright: 2012
% http://www.mathworks.com/matlabcentral/fileexchange/authors/255737
% 

% Initializes everything

if nargin < 1
    warndlg({'You have to give the GA a problem to solve','Use a function [problem name]_initialize.m for that','If you need help with the method, type "help GA"'},'No problem to solve','modal')
    return;
end
if nargin < 2
    % Automatically initializing the settings
    settings = initialize_settings();
end

stats.gen = 0;

% Statistics (saves the minimum, average, max and best value known as a function of time)
if (settings.time_lim < inf)&&(length(problem.minimization)==1)
    stats.hist = nan(settings.time_lim,4);
else
    stats.hist = 'Unable to save without a time limit';
end

% Initializes the control interface
if (settings.realtime_control) 
    h = GA_gui(settings);
else
    h = false;
end

% Initializes Functions
f = initialize_functions(problem, settings);

% Begins measuring time
stats.start_time = tic;

% Initializes the population
if nargin < 3
    population = f.initialize_population(settings,problem,f);
end

% Evaluates the population
[population, problem, stats]= f.evaluate_population(population, problem, settings, stats, stats.start_time, f, 0);

% Update settings
[settings, population, problem, stats, h, f] = update_settings(settings, population, problem, stats, h, f);

while (~settings.halt)
    % Updates the generation number
    stats.gen = stats.gen + 1;
    
    % Selects the parents in the format (n_children, parents_per_crossover)
    parents_idx = f.selection(population, settings, problem, 0);
    
    % Reproduction: Crossover + Mutation = Children
    population = f.reproduction(settings, population, problem, parents_idx, f);
    
    % Evaluation of the new population
    [population, problem, stats] = f.evaluate_population(population, problem, settings, stats, stats.start_time, f, 1);
    
    % Survival of the new population (applies elitism and selects the rest from (children + parents) or children)
    [population,settings] = f.survival(population, settings, problem, f);
    
    % Adaptation of the settings, operators probabilities or anything else
    if (~strcmp(settings.adaptation,'off')) population = f.adaptation(population, problem, settings); end
    
    % Shows partial results
    if (settings.print)
        f.print(population, problem, settings, stats);
    end    
    
    % Updates the settings
    [settings, population, problem, stats, h, f] = update_settings(settings, population, problem, stats, h, f);

end

stats.time_spent = toc(stats.start_time);

if (settings.realtime_control) 
    delete(h.figure1);
end

end

