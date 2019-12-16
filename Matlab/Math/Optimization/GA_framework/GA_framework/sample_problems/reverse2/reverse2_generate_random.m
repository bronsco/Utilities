function [ ind ] = reverse2_generate_random( problem, ~ )
%GERAINDIVIDUO

ind.p = zeros(1,problem.n_j);
pos = randperm(problem.n_j);
ind.p(pos(1:problem.p_max)) = 1;
ind.q = zeros(1,problem.n_k);
pos = randperm(problem.n_k);
ind.q(pos(1:problem.q_max)) = 1;
ind.x = zeros(problem.n_i,problem.n_j+1,problem.n_k);
    
end

