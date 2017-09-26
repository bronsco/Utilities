function [ x ] = mutacaouniforme( x, problema, ~, ~ )
%MUTACAO Aplica mutação no ponto x

limite_inferior = problema.centro_intervalo - 0.5*problema.tam_intervalo;
limite_superior = problema.centro_intervalo + 0.5*problema.tam_intervalo;


var = ceil(rand()*size(x,2));
x(var) = limite_inferior(var) + rand()*(limite_superior(var)-limite_inferior(var));

end

