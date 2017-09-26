function [ f ] = initialize_functions(problem, settings)
%INITIALIZE_FUNCTIONS with handles for the specific problem to be solved

%% FUNCTIONS WHICH ARE DEPENDENT ON THE PROBLEM

% Function that generates each individual
f.initialize_individual = str2func([problem.name,'_generate_',problem.generation_method,'']);

% Function that evaluates an individual
f.evaluate_individual = str2func([problem.name,'_evaluate']);

% Crossover Operator
f.crossover = str2func([problem.name,'_crossover_',problem.crossover_method]);

% Mutation Operatoe
f.mutation = str2func([problem.name,'_mutation_',problem.mutation_method]);

%% FUNCTIONS THAT CAN OPTIONALLY DEPEND ON THE PROBLEM

% Function that initializes the population
if exist([problem.name,'_population.m'],'file')
    f.initialize_population = str2func([problem.name,'_population']);
else
    f.initialize_population = @initialize_population;
end

% Function that evaluates the population
if (exist([problem.name,'_evaluate_population.m'],'file'))
    f.evaluate_population = str2func([problem.name,'_evaluate_population']);
else
    f.evaluate_population = @evaluate_population;
end

% Survival
if (exist([problem.name,'_evaluate_population.m'],'file'))
    f.survival = str2func([problem.name,'_survival']);
else
    f.survival = @survival;
end

% Prints/plots the results on every generation
if (settings.print)
    f.print = str2func([problem.name,'_print']);
end

%% FUNCTIONS WHICH ARE DEPENDANT ON THE SETTINGS

% Scaling method
f.scaling = str2func(['scaling_',settings.scaling]);

% Function for selection of the parents
f.selection = str2func(['selection_',settings.selection]);

% Adaptation method
f.adaptation = str2func(['adaptation_',settings.adaptation]);

% Function for reproduction of the whole population
f.reproduction = @reproduction;

% Function that defines how multiobjective problems will be treated
f.multiobjective_treatment = str2func(['mop_',settings.multiobjective_treatment]);

end