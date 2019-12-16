function [ population ] = adaptation_populational( population, problem, settings)
%POPULATIONAL ADAPTATION of the crossover and mutation probabilities

vmin = 1.2;
vmax = 1.9;
k = 1.1;

if (problem.minimization)
    temp_fitness = -population.fx(1:settings.n_ind);
else
    temp_fitness = population.fx(1:settings.n_ind);
end
temp_fitness = temp_fitness - min(temp_fitness) + 1;

fmed = mean(temp_fitness); %average fitness
fmax = max(temp_fitness); %maximum fitness
mdg = fmax/fmed; %maximum/average ratio

if ( mdg > vmax ) %if maximum is too far from mean
    population.mp = min(population.mp.*k,1); % increase mutation
    population.cp = max(population.cp./k,0); % decreases crossover
elseif (mdg<vmin) % if maximum is too close from mean
    population.mp = max(population.mp./k,0); % decrease mutation
    population.cp = min(population.cp.*k,1); % increase crossover
end
   

end

