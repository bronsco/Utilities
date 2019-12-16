function [ population, problem, settings ] = mop_piceag( population, problem, settings )
% MOP_PICEAG Those MOP functions must return unidimensional values for the
% fitness of solutions that have multiobjectives values for each individual
% Those functions must also consider that sometimes the first n_ind values
% will be nan and sometime the last n_ind values will be nan. That means
% that we don't have parents or we don't have children.
% problem.minimization keeps if the objectives are to be minimized (true)
% or maximized (false)

% initial variables
maximum = max(population.fx);
minimum = min(population.fx);
range = maximum - minimum;
% if we don't have parents
begin = 1;
ending = settings.n_ind*2;
if isnan(population.fx(1,1))
    begin = settings.n_ind + 1;
end
% if we don't have children
if isnan(population.fx(settings.n_ind+1,1))
    ending = settings.n_ind;
end


% new random goals
goals = rand(settings.n_ind,length(problem.minimization));
for i=1:length(problem.minimization)
    goals(:,i) = goals(:,i)*range(i)*1.5;
    goals(:,i) = goals(:,i)-minimum(i)-range(i)*0.25;
end

% if we already have goals for the algorithm
if isfield(population,'goals')
    % inserts more n_ind goals to compete
    population.goals = [population.goals; goals];
else
    % if there are no goals, we just save the new random ones with some new
    % ones to complete 2n
    goals2 = rand(settings.n_ind,length(problem.minimization));
    for i=1:length(problem.minimization)
        goals2(:,i) = goals2(:,i)*range(i)*1.5;
        goals2(:,i) = goals2(:,i)-minimum(i)-range(i)*0.25;
    end
    population.goals = [goals;goals2];
    population.goal_fit = zeros(1,settings.n_ind*2);
end

% Calculates which solutions satisfy which goals
population.goal_n = zeros(1,settings.n_ind*2);
% for each solution
for i=begin:ending
    % for each goal
    for j=1:settings.n_ind*2
        % if the goal is attended
        if (population.fx(i,:).*(problem.minimization.*2-1)<=population.goals(j,:))
            % we increase the counter for that goal
            population.goal_n(j) = population.goal_n(j) + 1;
        end
    end
end

% fitness of the solutions
% for each solution
for i=begin:ending
    population.fit(i) = 0;
    % for each goal
    for j=1:settings.n_ind*2
        % if the goal is attended
        if (population.fx(i,:).*(problem.minimization.*2-1)<=population.goals(j,:))
            % we increase the counter for that goal
            population.fit(i) = population.fit(i) + 1/(population.goal_n(j));
        end
    end
end

% fitness of the goal
for i=begin:settings.n_ind*2
    if (population.goal_n(i)==0)
        alpha = 1;
    else
        alpha = (population.goal_n(i) - 1)/(2*settings.n_ind - 1);
    end
    population.goal_fit(i) = 1/1+alpha;
end


end

