function [ parents ] = selection_roulette( population, settings, ~ , survival )
% ROULETTE WHEEL on the population

if nargin < 4
    %survival defines if the selection is for survival or reproduction
    % if it is for reproduction, it will return a table with combinations of parents
    % if it is for survival > 0, it will return a vector with survival individuals
    survival = 0;
end

if survival > 0
    fitness = population.fit;
    n = survival;
else
    fitness = population.fit(1:settings.n_ind);
    n = settings.n_ind * settings.parents_per_crossover;
end

fitness_sum = sum(fitness);
n_ind = size(fitness,2);

if (fitness_sum == 0)
    fitness = ones(1,n_ind);
    fitness_sum = sum(fitness);
end

parents = zeros(1,n);

% Sorts the individuals
[fitness_sorted, ordem] = sort(fitness,2,'descend');

% Spin the wheel
for j=1:n
    soma = 0;
    ponteiro = rand()*fitness_sum;
    for i=1:n_ind
        soma = soma + fitness_sorted(i);
        if (ponteiro < soma)
            parents(j) = ordem(i);
            break;
        end
    end
end

if (survival==0)
    parents = reshape(parents,settings.n_ind,settings.parents_per_crossover);
end

end

