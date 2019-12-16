function [ problem ] = realfunction_initialize(  )
% KNAPSACK_INITIALIZE returns a real function problem

%% THE FOLLOWING VARIABLES ARE MANDATORY TO GUIDE THE TOOLBOX

% Defines the problem for the genetic algorithm
problem.name = 'realfunction';
problem.minimization = true; % 1 for minimization and 0 for maximization

% Tells the genetic algorithm which of your functions you want to use
problem.generation_method = 'random';
problem.mutation_method = 'gaussian';
problem.crossover_method = 'polarized';

% You can also define here extra information for your functions
% problem.evaluation = 'simplex';
% or
% problem.evaluation = 'withlocalsearch';

%% THOSE FOLLOWING VARIABLES DEFINE THE PROBLEM INSTANCE

% Defines the instance
problem.n_var = input('Please enter the number of variables: '); % instance size
problem.instance = @realfunction_evaluate_foxholes; % function to evaluate
problem.interval_center = zeros(1,problem.n_var);
problem.interval_size = 10*ones(1,problem.n_var);
problem.reduction_rate = 1;

% disp('Initializing the following problem:');
% disp(problem);

end

