function x = knapsack_mutation_bitflop(x, ~,~,~)
% Mutates the knapsack 

pos = ceil(rand()*size(x,2));
x(pos) = mod(x(pos)+1,2);

end

