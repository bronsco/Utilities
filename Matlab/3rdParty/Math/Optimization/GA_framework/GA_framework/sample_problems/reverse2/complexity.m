function [ complexity ] = complexity( problema )
%COMPLEXITY of the NP part of the problem

complexity1 = 0;
for i = problema.p_min:problema.p_max
    complexity1 = complexity1 + factorial(problema.n_j)/(factorial(i).*factorial(problema.n_j-i));
end
complexity2 = 0;
for i = max(1,problema.q_min):problema.q_max
    complexity2 = complexity2 + factorial(problema.n_k)/(factorial(i).*factorial(problema.n_k-i));
end

complexity = complexity1 * complexity2;

end

