function [ problem ] = mop_initialize(  )
% KNAPSACK_INITIALIZE returns a real function problem

%% THE FOLLOWING VARIABLES ARE MANDATORY TO GUIDE THE TOOLBOX

% Defines the problem for the genetic algorithm
problem.name = 'mop';
problem.minimization = [true,true]; % 1 for minimization and 0 for maximization

% Tells the genetic algorithm which of your functions you want to use
problem.generation_method = 'random';
problem.mutation_method = 'gaussian';
problem.crossover_method = 'polarized';

%% You can also define here extra information for your functions
% problem.evaluation = 'simplex';
% or
% problem.evaluation = 'withlocalsearch';

% We could use this area to define an auxiliar population g, which is
% important for PICEA-g but we don't know how many individuals we'll have
% yet. The GA will define somewhere the variable:
%
% problem.g = zeros(n_individuals,n_objectives);

%% THOSE FOLLOWING VARIABLES DEFINE THE PROBLEM INSTANCE

% Defines the instance
%problem.n_var = input('Please enter the number of variables: '); % instance size
problem.n_var = 2; % instance size in the design space
problem.instance = @mop_evaluate_bk1; % function to evaluate
problem.interval_center = 2.5*ones(1,problem.n_var);
problem.interval_size = 15*ones(1,problem.n_var);

problem.reduction_rate = 1; % rate of reduction of search space (not used currently)

% disp('Initializing the following problem:');
% disp(problem);

end

