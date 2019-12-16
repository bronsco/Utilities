function [ population ] = adaptation_individual( population, ~, settings)
%INDIVIDUAL ADAPTATION for crossover and mutation (only for parents)

k1 = 1.5;
k2 = 0.12;
k3 = 1;
k4 = 0.12;

fmed = mean(population.fit(1:settings.n_ind)); % average fitness
fmax = max(population.fit(1:settings.n_ind)); % maximum fitness

for i=1:settings.n_ind % for each individual
    if population.fit(i)>= fmed % if its fitness is better than average
        % increases crossover probability according to distance to average
        % in other words, cp = 0 for the best and cp = 1 for the median
        population.cp(i) = min(k1 * (fmax-population.fit(i))./(fmax-fmed),1);
        % Does the same to mutation, but scaled to 0.12
        population.mp(i) = k2 * (fmax-population.fit(i))./(fmax-fmed);
    else
        % If its fitness is not better than average
        % Crossover = 1 and mutation = 0.12
        population.cp(i) = k3;
        population.mp(i) = k4;
    end
end

end

