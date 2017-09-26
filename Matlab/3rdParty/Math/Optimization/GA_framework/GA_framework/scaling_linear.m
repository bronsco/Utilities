function [ population ] = scaling_linear( population, settings )
% SCALING_LINEAR Scales the whole population linearly

if isnan(population.fit(settings.n_ind*2))
    n = settings.n_ind;
    initial = 1;
elseif isnan(population.fit(1))
    n = settings.n_ind;
    initial = n+1;
else
    initial = 1;
    n = settings.n_ind * 2;
end

fmed = mean(population.fit(initial:n+initial-1));
fmax = max(population.fit(initial:n+initial-1));

for i=initial:initial+n-1
    population.fit(i) = individual_scaling( population.fit(i), fmed, fmax);
end



    function [ f_line ] = individual_scaling( f, fmed, fmax, c)
    %ESCALONAMENTOLINEAR Escalona o fitness da solução

    if nargin < 4
        c = 2;
    end

    fmax_line = fmed * c;
    fmed_line = fmed;

    %calcular linha que passa por [fmed fmed_linha] e [fmax fmax_linha]
    m = (fmax_line - fmed_line)/(fmax - fmed);

    %y-y0 = m(x-x0), f_linha = y, f = x
    %y = m(x-x0)+y0, f_linha = y, f = x
    f_line = m*(f-fmax)+fmax_line;

    %corrige números negativos
    f_line = max(0,f_line);

    end

end

