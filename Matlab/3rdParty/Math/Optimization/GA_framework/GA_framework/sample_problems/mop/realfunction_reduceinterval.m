function [ problema ] = reduzintervalo( problema, best , j)
%REDUZINTERVALO reduz o intervalo de busca do problema
%   O intervalo é sempre reduzido e centrado no melhor individuo

if (nargin < 3)
    j = -0.002;
end

problema.tam_intervalo =  problema.tam_intervalo.*(1+j);
problema.centro_intervalo = best;

end

