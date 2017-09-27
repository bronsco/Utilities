function [ problem ] = reverse2_initialize( n_i, n_j, p_max, n_k, q_max )
% REVERSE2_INITIALIZE returns a two-level reverse distribution problem

%% THE FOLLOWING VARIABLES ARE MANDATORY TO GUIDE THE TOOLBOX

% Defines the problem for the genetic algorithm
problem.name = 'reverse2';
problem.minimization = true; % 1 for minimization and 0 for maximization

% Tells the genetic algorithm which of your functions you want to use
problem.generation_method = 'random';
problem.mutation_method = 'random';
problem.crossover_method = 'intersection';

% You can also define here extra information for your functions
% problem.evaluation = 'simplex';
% or
% problem.evaluation = 'withlocalsearch';

% This special variable defines that simplex is used to calculate the route
% and the fitness, consequently. Another option would be heuristic.
problem.calculate_x = 'simplex';
problem.localsearch = true;

%% THOSE FOLLOWING VARIABLES DEFINE THE PROBLEM INSTANCE

% Defines the instance
if nargin == 0
    problem.n_i = 30;
    problem.n_j = 14;
    problem.p_max = 4;
    problem.p_min = 0;
    problem.n_k = 12;
    problem.q_max = 2;
    problem.q_min = 0;
else
    problem.n_i = n_i;
    problem.n_j = n_j;
    problem.p_max = p_max;
    problem.p_min = 0;
    problem.n_k = n_k;
    problem.q_max = q_max;
    problem.q_min = 0;
end


problem.points_i = rand(problem.n_i,2)*100;
problem.points_j = rand(problem.n_j,2)*100;
problem.points_k = rand(problem.n_k,2)*100;
problem.c = zeros(problem.n_i, problem.n_j+1, problem.n_k);
for i=1:problem.n_i
    for j=1:problem.n_j+1
        for k=1:problem.n_k
            % when j > 1, c(i,j,k) represents from i to j-1 and j-1 to k
            if (j>1)
                problem.c(i,j,k) = 0.1*(dist(problem.points_i(i,:),problem.points_j(j-1,:)')+dist(problem.points_j(j-1,:),problem.points_k(k,:)'));
            % when j == 1, we are representing the distance between i and k
            else
                problem.c(i,j,k) = 0.4*(dist(problem.points_i(i,:),problem.points_k(k,:)'));
            end
        end
    end
end
problem.a = round(rand(1,problem.n_i)*500); % products in i
problem.b = round(rand(1,problem.n_j)*6000); % capacity of j
problem.d = round(rand(1,problem.n_k)*30000); % capacity of k
problem.f = round(0.1*(rand(1,problem.n_j).*10000 + problem.b.*rand()*10)); % cost of j
problem.g = round(0.1*(rand(1,problem.n_k).*25000 + problem.d.*rand()*100)); % cost of k

% if the problem if unfeasible
if ((sum(problem.a)>sum(problem.b))||(sum(problem.a)>sum(problem.d)))
    problem = inicializaproblem();
end


% disp('Initializing the following problem:');
% disp(problem);


end

