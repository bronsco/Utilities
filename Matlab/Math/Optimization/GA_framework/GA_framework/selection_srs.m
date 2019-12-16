function [ parents ] = selection_srs( population, settings, ~ , survival)
%SELECTION_SRS Stochastic Remainder Sampling

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

% Stochastic Remainder Sampling
if sum(fitness==0)>0
    fitness = fitness + 1;
end
fitness2 = fitness./mean(fitness);

% Sort value in descendent order
[fitness2, ordem] = sort(fitness2,2,'descend');

% If even the smallest is greater than 1, just returns everyone
if (fitness2(settings.n_ind)>=1)
    parents = mod(randperm(n),settings.n_ind)+1;
% If it is just survival, and even the worst survival is > 1, also take it
% all
elseif (survival>0)&&(fitness2(survival)>=1)
    parents = mod(randperm(survival),settings.n_ind)+1;
% If we have to complete with individuals below the average
else
    % We have to find out from where we are going to complete
    for i=1:settings.n_ind
        if (fitness2(i)<1)
            break;
        end
    end
    % i divides the good ones from the ones below the average
    % if it is for sexual selection, the good values are replicated
    if (survival == 0)
        parents(1:(i-1)*settings.parents_per_crossover) = ordem(mod(randperm((i-1)*settings.parents_per_crossover),settings.n_ind)+1);
        parents(((i-1)*settings.parents_per_crossover+1):(n)) = tournament(fitness, (n)-(i-1)*settings.parents_per_crossover, settings);
    else
        %if it is for survival selection, the values are used only once
        parents(1:(i-1)) = ordem(1:(i-1));
        parents(i:survival) = tournament(fitness, survival-(i-1), settings);
    end
end

if survival == 0
    parents = reshape(parents,settings.n_ind,settings.parents_per_crossover);
end

function [ parents ] = tournament( fitness, n, settings )
%TOUNAMENT returns N indexes with 2-tournaments
%   2 = k is the size of the tournament

k = 2;
parents=zeros(1,n);

for j=1:n
    torneio = randi(settings.n_ind,1,k);
    [~, parents(j)] = max(fitness(torneio));
    parents(j) = torneio(parents(j));
end

end

end

