function solution = reverse2_mutation_random(solution, problem,~,~)
%MUTACAO REVERSE2

pos = randi(problem.n_j);
% se já estiver no máximo
if (sum(solution.p)==problem.p_max)
    %faz mutação de redução na posição
    solution.p(pos) = max(solution.p(pos)-1,0);
% se já estiver no mínimo
elseif (sum(solution.p)==problem.p_min)
    %faz mutação de acréscimo na posição
    solution.p(pos) = min(solution.p(pos)+1,1);
% se estiver no meio termo
else
    %faz um bit-flop simples
    solution.p(pos) = mod(solution.p(pos)-1,2);
end

pos = randi(problem.n_k);
% se já estiver no máximo
if (sum(solution.q)==problem.q_max)
    %faz mutação de redução na posição
    solution.q(pos) = max(solution.q(pos)-1,0);
% se já estiver no mínimo
elseif (sum(solution.q)==problem.q_min)
    %faz mutação de acréscimo na posição
    solution.q(pos) = min(solution.q(pos)+1,1);
% se estiver no meio termo
else
    %faz um bit-flop simples
    solution.q(pos) = mod(solution.q(pos)-1,2);
end


end

