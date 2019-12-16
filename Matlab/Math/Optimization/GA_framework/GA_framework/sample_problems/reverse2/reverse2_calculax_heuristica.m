function [ solucao ] = calculax_heuristica( solucao, problema )
%CALCULAX_HEURISTICA calcula rotas dos produtos

solucao.x = zeros(problema.n_i, problema.n_j+1, problema.n_k);

%coloca custo infinito para os caminhos impossíveis
for j=1:problema.n_j+1
    for k=1:problema.n_k
        if (j>1)
            if (solucao.p(j-1)==0)||(solucao.q(k)==0)
                problema.c(:,j,k) = inf;
            end
        else
            if (solucao.q(k)==0)
                problema.c(:,j,k) = inf;
            end
        end
    end
end

%Para cada ponto i
for i=1:problema.n_i
    %inicializa problema do depósito
    a_enviar = problema.a(i);
    enviado = 0;
    
    %procura caminho com menor custo
    menor = inf;
    menor_j = randi(problema.n_j+1);
    menor_k = randi(problema.n_k);
    for j=1:problema.n_j+1
        for k=1:problema.n_k
            if (problema.c(i,j,k)<menor)
                menor = problema.c(i,j,k);
                menor_j = j;
                menor_k = k;
            end
        end
    end
    
    %envia maior fração possível de i para k por j
    if (menor_j>1)
        enviado = enviado + min([problema.a(i) problema.b(menor_j-1) problema.d(menor_k)]);
        solucao.x(i,menor_j,menor_k) = enviado/problema.a(i);
    else
        enviado = enviado + min([problema.a(i) inf problema.d(menor_k)]);
        solucao.x(i,menor_j,menor_k) = enviado/problema.a(i);
    end
        
    %atualiza as capacidades de j e k
    if (menor_j>1)
        problema.b(menor_j-1) = problema.b(menor_j-1) - enviado;
    end
    problema.d(menor_k) = problema.d(menor_k) - enviado;
    
    %atualiza a quantidade de produtos em i
    a_enviar = a_enviar - enviado;
    
    %se todos o produtos de i foram enviados passa para o próximo ponto i
    %caso contrário, procura o próximo menor caminho até acabar
    if (a_enviar>0)
        c_temp = problema.c;
        while (a_enviar>0)
            %marca a solucao anterior como custo infinito
            c_temp(i,menor_j,menor_k) = inf;

            %procura caminho com menor custo
            menor = inf;
            menor_j = randi(problema.n_j+1);
            menor_k = randi(problema.n_k);
            for j=1:problema.n_j+1
                for k=1:problema.n_k
                    if (c_temp(i,j,k)<menor)
                        menor = problema.c(i,j,k);
                        menor_j = j;
                        menor_k = k;
                    end
                end
            end

            %envia maior fração possível de i para k por j
            if (menor_j>1)
                enviado_agora = min([a_enviar problema.b(menor_j-1) problema.d(menor_k)]);
                enviado = enviado + enviado_agora;
                solucao.x(i,menor_j,menor_k) = enviado_agora/problema.a(i);
            else
                enviado_agora = min([a_enviar inf problema.d(menor_k)]);
                enviado = enviado + enviado_agora;
                solucao.x(i,menor_j,menor_k) = enviado_agora/problema.a(i);
            end

            %atualiza as capacidades de j e k
            if (menor_j>1)
                problema.b(menor_j-1) = problema.b(menor_j-1) - enviado_agora;
            end
            problema.d(menor_k) = problema.d(menor_k) - enviado_agora;

            %atualiza a quantidade de produtos em i
            a_enviar = a_enviar - enviado_agora;
        end  
    end
end

end

