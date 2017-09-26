function [ problem ] = knapsack_initialize(  )
% KNAPSACK_INITIALIZE returns a knapsack problem

%% THE FOLLOWING VARIABLES ARE MANDATORY TO GUIDE THE TOOLBOX

% Defines the problem for the genetic algorithm
problem.name = 'knapsack';
problem.minimization = false; % 1 for minimization and 0 for maximization

% Tells the genetic algorithm which of your functions you want to use
problem.generation_method = 'random';
problem.mutation_method = 'bitflop';
problem.crossover_method = '1point';

% You can also define here extra information for your functions
% problem.evaluation = 'simplex';
% or
% problem.evaluation = 'withlocalsearch';


%% THOSE FOLLOWING VARIABLES DEFINE THE PROBLEM INSTANCE

% Defines the instance
problem.n_var = input('Please enter the size of the knapsack: '); % instance size
problem.cost = rand(1,problem.n_var); % cost of carrying each item
problem.value = rand(1,problem.n_var); % value of each item
problem.capacity = sum(problem.cost)/3; % capacity of the knapsack

% disp('Initializing the following problem:');
% disp(problema);

end

