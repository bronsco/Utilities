function [ x ] = mutacaogaussiana2( x, problema , ~, ~)
%MUTACAO Aplica mutação no ponto x

limite_inferior = problema.centro_intervalo - 0.5*problema.tam_intervalo;
limite_superior = problema.centro_intervalo + 0.5*problema.tam_intervalo;


%escolhe um parametro
var = ceil(rand()*size(x,2));
x(var) = x(var) + 0.05*randn()*(limite_superior(var)-limite_inferior(var));

end

