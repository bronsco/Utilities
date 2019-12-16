function [ x ] = realfunction_crossover_polarized(parents,problem,~,population)
%CROSSOVER polarized with the parents
%   É utilizado um cruzamento polarizado e linear nesse algoritmo
%   Este cruzamento é definido como:
%       x_g = \alpha x_1 + (1-\alpha) x_2;
%   \alpha é um valor escolhido entre -0.1 e 1.1 com uma distribuição
%   de probabilidades definida por:
%       \alpha = 1.4 * \beta_1 beta_2 - 0.2
%   onde \beta_1 e \beta_2 são variáveis aleatórias com distribuição
%   de probabilidades uniforme dentro do domínio definido [0;1]

x1 = population.ind{parents(1)};
x2 = population.ind{parents(2)};


limite_inferior = problem.interval_center - 0.5*problem.interval_size;
limite_superior = problem.interval_center + 0.5*problem.interval_size;

%gera indivíduo
beta1 = rand();
beta2 = rand();
alpha = 1.4 * beta1 * beta2 - 0.2;
x = alpha * x1 + (1-alpha) * x2;

%aplica reflexão
x = reflexao(x, limite_inferior, limite_superior);

function [ x ] = reflexao( x, limite_inferior, limite_superior )
%REFLEXAO Aplica reflexão no ponto x de acordo com os limites

if (sum(x<limite_inferior)>0)
    x = limite_inferior + abs(x-limite_inferior);
end
if (sum(x>limite_superior)>0)
    x = limite_superior - abs(x-limite_superior);
end

end


end

