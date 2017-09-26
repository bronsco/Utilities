function [ ind ] = reverse2_generate_jayaraman_temp( problem, ~ )
%GERAINDIVIDUO

%quantidade máxima de clientes i
maxIteracao = 50;

%armazena as melhores soluções
solFinalOtima = Inf;

poolSolucoes = Inf;
for ii=2:round(round(maxIteracao*0.05))
    poolSolucoes = [poolSolucoes Inf];
end
poolEscolhidosJOtimo = zeros(round(maxIteracao*0.05),problem.n_j);
poolEscolhidosKOtimo = zeros(round(maxIteracao*0.05),problem.n_k);

for iteracao=1:maxIteracao,
    clear escolhidosJ;
    clear escolhidosK;
    
    %seleciona uma quantidade de depósitos maxJ aleatoriamente, criando o vetor
    %escolhidosJ que contém os maxJ escolhidos (marcado como 1)
    i=0;
    escolhidosJ = zeros(1,problem.n_j);
    while(1)
        pos=mod(round(100*rand()),problem.n_j)+1;
        if escolhidosJ(1,pos)==0
            escolhidosJ(1,pos)=1;
            i=i+1;
        else
            continue;
        end
        if(i==problem.p_max)
            break;
        end
    end
    
    %seleciona uma quantidade de fabricas maxJ aleatoriamente, criando o vetor
    %escolhidosK que contém os maxK escolhidos (marcado como 1)
    i=0;
    escolhidosK = zeros(1,problem.n_k);
    while(1)
        pos=mod(round(100*rand()),problem.n_k)+1;
        if escolhidosK(1,pos)==0
            escolhidosK(1,pos)=1;
            i=i+1;
        else
            continue
        end
        if(i==problem.q_max)
            break;
        end
    end
    
    ind.p = escolhidosJ;
    ind.q = escolhidosK;
    
    [fx,ind] = reverse2_evaluate(ind, problem);
    
    escolhidosJ = ind.p;
    escolhidosK = ind.q;
    
    %coloca solução no pool de solucoes
    [valor, index] = max(poolSolucoes);
    if (fx < valor)
        poolSolucoes(index) = fx;
        poolEscolhidosJOtimo(index,:) = escolhidosJ;
        poolEscolhidosKOtimo(index,:) = escolhidosK;
    end
    
    if (solFinalOtima > fx)
        solFinalOtima = fx;
        escolhidosJOtimo = escolhidosJ;
        escolhidosKOtimo = escolhidosK;
    end
end


%iniciando heuristic concentration. nesse caso, pegamos a melhor solução
%encontrada e adicionamos P_max + 2 - números de locais na solução. Como o
%número de locais na solução é igual a P_max, vamos adicionar 2 locais k e j ao
%conjunto de soluções, rodar novalmente o simplex e comparar com a melhor solução
%obtida. Os locais adicionados são os dois que mais apareceram nas outras
%soluções do pool.

%fprintf('inicia heuristic concentration\n');
for it=1:size(poolEscolhidosJOtimo,1)
poolEscolhidosJOtimo(it,:) =(poolEscolhidosJOtimo(it,:) - escolhidosJOtimo);
end
[~,index] = sort(sum(poolEscolhidosJOtimo,1),'descend');
escolhidosJOtimoHC = escolhidosJOtimo;
escolhidosJOtimoHC(index(1)) = 1; escolhidosJOtimoHC(index(2)) = 1;

for it=1:size(poolEscolhidosKOtimo,1)
poolEscolhidosKOtimo(it,:) = (poolEscolhidosKOtimo(it,:) - escolhidosKOtimo);
end
[~,index] = sort(sum(poolEscolhidosKOtimo,1),'descend');
escolhidosKOtimoHC = escolhidosKOtimo;
escolhidosKOtimoHC(index(1)) = 1; escolhidosKOtimoHC(index(2)) = 1;

indHC.p = escolhidosJOtimoHC;
indHC.q = escolhidosKOtimoHC;

[fx,indHC] = reverse2_evaluate(indHC, problem);


    %verifica se a solução respeita maxJ e maxD
    if ( size(indHC.p(indHC.p~=0),2) > (problem.n_j) || size(indHC.q(indHC.q~=0),1) > (problem.n_k)) 
        solFinal = Inf;
    else
        solFinal = fx;
   end

if (solFinalOtima > solFinal)
    fprintf('Melhor solucao encontrada com a HC!\n');
    ind.p = escolhidosJOtimoHC;
    ind.q = escolhidosKOtimoHC;
    ind.x = indHC.x;
end



end

