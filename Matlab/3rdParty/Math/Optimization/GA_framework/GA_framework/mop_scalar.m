function [ population, problem, settings ] = mop_scalar( population, problem, settings )
% MOP_SCALAR Those MOP functions must return unidimensional values for the
% fitness of solutions that have multiobjectives values for each individual
% The scalar approach is the simplest approach for this problem
% It consists of simply summing all of the objective function values
% Those functions must also consider that sometimes the first n_ind values
% will be nan and sometime the last n_ind values will be nan. That means
% that we don't have parents or we don't have children.

% Where it is minimization, we multiply by -1 to get higher fitness for lower
% values. Where it's maximization, we just keep the values the way they
% are.
temp = population.fx;
temp(:,problem.minimization==1) = temp(:,problem.minimization==1)*-1;

for i=1:settings.n_ind*2
    population.fit(i) = sum(temp(i,:));
end

end

