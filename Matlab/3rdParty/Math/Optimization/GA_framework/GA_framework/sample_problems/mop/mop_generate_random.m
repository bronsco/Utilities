function [ x ] = mop_generate_random( problem, ~ )
%GERAINDIVIDUO Gera um indivíduo aleatório de tamanho size(range,2)

x = rand(1,problem.n_var).*problem.interval_size-problem.interval_size/2+problem.interval_center;

end

