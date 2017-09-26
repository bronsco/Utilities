function [ x ] = mop_mutation_gaussian( x, problema, ~, ~, ~ )
%MUTACAO Aplica mutação no ponto x

limite_inferior = problema.interval_center - 0.5*problema.interval_size;
limite_superior = problema.interval_center + 0.5*problema.interval_size;

x = x + 0.05*randn()*(limite_superior-limite_inferior);

end

