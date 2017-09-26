function [ population ] = initialize_population(settings,problem,f)
%INITIALIZE_POPULATION for the GA if the user hasn' specified his own function

% A cell variable will keep the individuals (parents and children)
population.ind = cell(1,settings.n_ind*2);
for i=1:settings.n_ind
    % Generates the number of individuals defined by the settings
    population.ind{i} = f.initialize_individual(problem,settings);
end

% Initializes the crossover and mutation probabilities
population.cp = settings.cp*ones(1,settings.n_ind*2);
population.mp = settings.mp*ones(1,settings.n_ind*2);

% Creates the objective value and fitness variables
population.fx = nan(settings.n_ind*2,length(problem.minimization));
population.fit = nan(settings.n_ind*2,1);

% Initializes the tenure value (number of generations without improvement)
population.t = 0;

end

