function [ x ] = cruzamentolinear(indices,~,~, populacao)
%CRUZAMENTO faz o cruzamento dos indivíduos x1 e x2
%   É utilizado um cruzamento polarizado e linear nesse algoritmo
%   Este cruzamento é definido como:
%       x_g = \alpha x_1 + (1-\alpha) x_2;
%   \alpha é um valor escolhido entre -0.1 e 1.1 com uma distribuição
%   de probabilidades definida por:
%       \alpha = 1.4 * \beta_1 beta_2 - 0.2
%   onde \beta_1 e \beta_2 são variáveis aleatórias com distribuição
%   de probabilidades uniforme dentro do domínio definido [0;1]


x1 = populacao.ind{indices(1)};
x2 = populacao.ind{indices(2)};

%gera indivíduo
beta = rand();
x = beta * x1 + (1-beta) * x2;

end

