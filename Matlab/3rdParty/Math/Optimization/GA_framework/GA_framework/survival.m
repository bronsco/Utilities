function [population, settings] = survival(population, settings, problem, f)
%SURVIVAL of the elite_ind best and competition between parents and
%children

% The population has parents in 1:n_ind and children in n_ind+1:n_ind*2
if ~settings.reinitialize
%% Saves the elite best positions
    elite_ind = ceil(settings.n_ind * settings.elitism);
    [~,order] = sort(population.fit,'descend');
    elites = order(1:elite_ind);

%% If there is competition between parents and children, saves selected ind
    if settings.parent_children_competition
        % Selects from the population n_ind - elite_ind individuals
        if settings.n_ind-elite_ind ~=0
            selected = f.selection(population, settings, problem, settings.n_ind-elite_ind);        
        else
            selected = [];
        end
    else
%% If there is no competition between parents and children, selects children
        % creates a new paliative population only with childrens fitness to
        % choose from
        if settings.n_ind-elite_ind ~=0
            temp_pop.fit = population.fit(settings.n_ind+1:settings.n_ind*2);
            selected = f.selection(temp_pop, settings, problem, settings.n_ind-elite_ind);
            selected = selected + settings.n_ind;
        else
            selected = [];
        end

    end
%% Saves the new population of parents in the positions 1:n_ind
    new_pop = [elites', selected];
else
%% If the population is being reinitialized, we just save the children
    new_pop = settings.n_ind+1:settings.n_ind*2;
    settings.reinitialize = false;
end

%% Copy the values
population.ind(1:settings.n_ind) = population.ind(new_pop);
population.cp(1:settings.n_ind) = population.cp(new_pop);
population.mp(1:settings.n_ind) = population.mp(new_pop);
population.fx(1:settings.n_ind,:) = population.fx(new_pop,:);
population.fit(1:settings.n_ind) = population.fit(new_pop);
    
end

