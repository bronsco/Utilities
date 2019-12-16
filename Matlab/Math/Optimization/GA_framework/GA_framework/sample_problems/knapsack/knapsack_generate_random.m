function [ solution ] = knapsack_generate_random( problem, ~ )
%KNAPSACK_INITIALIZE_RANDOM generates a solution for the problem

solution = randi(2,1,problem.n_var)-1;

end