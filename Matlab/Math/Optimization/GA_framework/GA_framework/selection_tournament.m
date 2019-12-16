function [ parents ] = selection_tournament( population, settings, ~ , survival)
%TOURNAMENT for n parents
%   k is the size of the tournament

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

k = 2;

parents = zeros(1,n);

for i=1:n
    torneio = randi(settings.n_ind,1,k);
    [~, parents(i)] = max(fitness(torneio));
    parents(i) = torneio(parents(i));
end

if survival == 0 
    parents = reshape(parents,settings.n_ind,settings.parents_per_crossover);
end


end
