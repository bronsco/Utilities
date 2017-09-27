function [ x ] = reflexao( x, limite_inferior, limite_superior )
%REFLEXAO Aplica reflexão no ponto x de acordo com os limites

if (sum(x<limite_inferior)>0)
    x = limite_inferior + abs(x-limite_inferior);
end
if (sum(x>limite_superior)>0)
    x = limite_superior - abs(x-limite_superior);
end

end