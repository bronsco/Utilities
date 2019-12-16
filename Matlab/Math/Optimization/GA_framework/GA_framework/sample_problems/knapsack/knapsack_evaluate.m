function [ fx, solution ] = knapsack_evaluate( solution , problem, ~)
%Evaluates a solution for the problem 

penality = sum(problem.value)*10;
fx = problem.value * solution';
fx = fx - penality*max(problem.cost*solution'-problem.capacity,0);

end

