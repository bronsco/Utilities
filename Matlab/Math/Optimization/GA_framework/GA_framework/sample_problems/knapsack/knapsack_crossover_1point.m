function child = knapsack_crossover_1point(parents,~,~,population)
% Generates a child from certain parents

n_parents = length(parents);
randparents = randperm(n_parents);

parent1 = population.ind{parents(randparents(1))};
parent2 = population.ind{parents(randparents(2))};

cross_point = ceil(rand()*(size(parent1,2)-1));
child = [parent1(1:cross_point),parent2(cross_point+1:size(parent2,2))];

end

