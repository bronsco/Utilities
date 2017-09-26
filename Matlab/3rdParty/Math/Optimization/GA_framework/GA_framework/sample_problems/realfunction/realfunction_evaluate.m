function [ fx, solution ] = realfunction_evaluate( solution , problem, ~)
%Evaluates a solution for the problem 

fx = problem.instance(solution);

end

