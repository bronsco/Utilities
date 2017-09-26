function [ ind ] = reverse2_generate_greedy( problem, ~ )
%GERAINDIVIDUO greedy

%calculates cost/capacity
value_p = problem.f./problem.b;
value_q = problem.g./problem.d;
[~, order_p] = sort(value_p);
[~, order_q] = sort(value_q);

%calcula quantos serão usados
if (problem.p_min~=problem.p_max)
    k_p = problem.p_min + randi(problem.p_max - problem.p_min ) ;
else
    k_p = problem.p_min;
end
if (problem.q_min~=problem.q_max)
    k_q = problem.q_min + randi(problem.q_max - problem.q_min ) ;
else
    k_q = problem.q_min;
end


%coloca os k menores na solução
ind.p = zeros(1,problem.n_j);
ind.p(order_p(1:k_p)) = 1;
ind.q = zeros(1,problem.n_k);
ind.q(order_q(1:k_q)) = 1;
ind.x = zeros(problem.n_i,problem.n_j+1,problem.n_k);
    
end