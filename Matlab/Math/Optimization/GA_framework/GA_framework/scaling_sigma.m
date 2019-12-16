function [ population ] = scaling_sigma( population, settings)
% SCALING_SIGMA

if isnan(population.fit(settings.n_ind*2))
    n = settings.n_ind;
else
    n = settings.n_ind * 2;
end


fmed = mean(population.fit(1:n));
sigma = std(population.fit(1:n));

for i=1:n
    population.fit(i) = sigma_scaling( population.fit(i), fmed, sigma);
end

    function [ f_linha ] = sigma_scaling( f, fmed, sigma, c)
    % Scales the fitness of solution with standard deviation sigma

    if nargin < 4
        c = 2;
    end

    if (f>fmed - c)
        f_linha = f - (fmed - c*sigma);
    else
        f_linha = 0;
    end

    end

end

