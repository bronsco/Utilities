function [ population, problem, stats] = evaluate_population(population, problem, settings, stats, start_time, f, best_exists)
%EVALUATE_POPULATION as a whole, using the other functions available
% All inputs come from the GA
% BEST defines if we already have the information of the best individual

%% Simple objective function for each individual with optional localsearch

if (best_exists)||settings.reinitialize
    % if the best already exists we are using this function to evaluate
    % children and the parents already have their fx values
    
    %if the button is off, we are also using only to evaluate children
    %because the population is being reinitialized
    
    for i=settings.n_ind+1:settings.n_ind*2
        [population.fx(i,:), population.ind{i}] = f.evaluate_individual(population.ind{i}, problem, population.fx(i,:));
    end
% If the best still doesn't exist, it is the 0th generation
else
    % Therefore we just evaluate the parents because there are no children
    % in the population [n_ind+1:n_ind*2]
    for i=1:settings.n_ind
        [population.fx(i,:), population.ind{i}] = f.evaluate_individual(population.ind{i}, problem, population.fx(i));
    end
end

% If we are reinitializing, the parents get nan then because we just have
% children
if settings.reinitialize
    population.fx(1:settings.n_ind) = nan;
end

%% Goes from objetive function to fitness

% Multiobjective problems need to be treated to have only one measure
if (length(problem.minimization)>1)
    [population, problem, settings] = f.multiobjective_treatment(population, problem, settings);
else
    % If it's monoobjective, we just invert for minimization problems
    if (problem.minimization)
        population.fit = -population.fx;
    else % or simply copy for maximization
        population.fit = population.fx;
    end
end

% Shifts the values so they are all greater than 0 in a roullete wheel
if (min(population.fit < 0))
    population.fit = population.fit - min(population.fit) + 1;
end

% We now scale the fitness values, if that is in the settings
if (strcmp(settings.scaling,'off') == 0)
    population = f.scaling(population, settings);
end

%% Calculate the statistics and the best individual
% For monoobjective problems
if (length(problem.minimization)==1)
    % The new candidate is the one with best fx in the population
    if (problem.minimization)
        [best_fx, pos] = min(population.fx);
    else
        [best_fx, pos] = max(population.fx);
    end
    best = population.ind{pos};
% For multiobjective problems
else
    % The new candidates are the ones which are in the pareto front
    pos = paretofronts(population.fx, problem.minimization,'pareto',0);
    pos(isnan(population.fx(:,1))) = 0; % in case there is some nan
    best_fx = population.fx(pos==1,:);
    best = population.ind(pos==1);
end

% If a best individual (or a pareto) already exists
if (best_exists)
    % For monoobjective problems
    if (length(problem.minimization)==1)
        % For minimization problems
        if (problem.minimization)
            % If the candidate has a lower objective value
            if (population.best_fx>best_fx)
                % Copy the candidate as best
                population.best = best;
                population.best_fx = best_fx;
                population.t = 0;
            else
                population.t = population.t + 1;
            end
        % For maximization
        else
            % If best objective in the population is greater than 
            if (population.best_fx<best_fx)
                % Copy the candidate as best
                population.best = best;
                population.best_fx = best_fx;
                population.t = 0;
            else
                population.t = population.t + 1;
            end
        end
    % For multiobjective problems
    else
        % We find a new pareto from the combination of the old and new
        % paretos
        pos = paretofronts([best_fx;population.best_fx],problem.minimization,'pareto',0);
        % The positions of the best ones from this generation
        pos_new = pos(1:size(best_fx,1));
        % The positions of the best ones from previous generations
        pos_old = pos(size(best_fx,1)+1:length(pos));
        % If none of the members are from the new solutions
        if sum(pos_new) == 0
            % we increase the tenure (or number of generations without
            % improvement)
            population.t = population.t + 1;
        else
            % otherwise, we reset its value
            population.t = 0;
        end
        % We then save the best solutions
        population.best = [best(pos_new==1),population.best(pos_old==1)];
        population.best_fx = [best_fx(pos_new==1,:);population.best_fx(pos_old==1,:)];
        % if we have more individuals than the resolution permits, we
        % choose only within the limit
        if (length(population.best)>settings.max_pareto)
            order = randperm(length(population.best));
            population.best = population.best(order(1:settings.max_pareto));
            population.best_fx = population.best_fx(order(1:settings.max_pareto),:);
        end
    end
% If there is no best individual saved yet, the candidate becomes the best    
else
    population.best = best;
    population.best_fx = best_fx;
    population.t = 0;
end

% If it is a monoobjective problem with time limit
if (ceil(toc(start_time))<=settings.time_lim)&&(settings.time_lim  < inf)&&(length(problem.minimization)==1)
    % Saves statistics of the generation in the format [minimum, median,
    % maximum, best] for the current time
    stats.hist(ceil(toc(start_time)),:) = [min(population.fx) median(population.fx) max(population.fx) population.best_fx];
end

end