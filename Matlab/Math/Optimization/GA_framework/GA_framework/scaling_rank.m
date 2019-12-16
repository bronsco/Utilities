function [ population ] = scaling_rank( population , settings )
%SCALING_RANK ranks the population as fitness

% Scaling methods should deal with nan values if there are inexistent 
% children in the last positions or inexistent parents in the first

if isnan(population.fit(settings.n_ind*2))
    n = settings.n_ind;
    [~,order] = sort(population.fit(1:n));
    for i=1:n
        population.fit(order(i)) = i;
    end
elseif isnan(population.fit(1))
    n = settings.n_ind;
    [~,order] = sort(population.fit(n+1:n*2));
    for i=1:n
        population.fit(order(i)+n) = i;
    end
else
    n = settings.n_ind * 2;
    [~,order] = sort(population.fit(1:n));
    for i=1:n
        population.fit(order(i)) = i;
    end
end


end