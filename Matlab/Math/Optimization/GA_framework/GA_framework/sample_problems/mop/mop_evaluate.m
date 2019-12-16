function [ fx, solution ] = mop_evaluate( solution , problem, ~)
%Evaluates a solution for the problem 

fx = problem.instance(solution);

end

