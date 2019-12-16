function [fx_old, solucao] = fi_search(solucao, fx_old, problema)
%FI_SEARCH First Improvement Local Search

thereisimprovement = true;

% while time < patience (iteration without improvement)
while (thereisimprovement)
    thereisimprovement = false;
    % for all neighbors (at random)
    for i=randperm(problema.n_j+problema.n_k)
        % calculates the neighbor i
        if i < problema.n_j+1
            solucao.p(i) = 1 - solucao.p(i);
        else
            solucao.q(i-problema.n_j) = 1 - solucao.q(i-problema.n_j);
        end        
        % calculates the neighbor's fx
        if ((sum(solucao.p)>problema.p_max)||(sum(solucao.p)<problema.p_min)||(sum(solucao.q)>problema.q_max)||(sum(solucao.q)<problema.q_min))
            fx = inf;
        elseif (sum(problema.d(solucao.q==1))<sum(problema.a))
            constante = 10;
            fx = max(0,sum(problema.b(solucao.p==1))-sum(problema.a));
            fx = fx + max(0,sum(problema.d(solucao.q==1))-sum(problema.a));
            fx = constante*fx + max(max(max(problema.c)))*max(problema.a)*problema.n_i*problema.n_j*problema.n_k + max(problema.f)*problema.n_j + max(problema.g)*problema.n_k;
            solucao.x = zeros(problema.n_i,problema.n_j+1,problema.n_k);
        else
            solucao = reverse2_calculax_heuristica(solucao,problema);
            fx = 0;
            for i2=1:problema.n_i
                for j=1:problema.n_j+1
                    for k=1:problema.n_k
                        fx = fx + problema.c(i2,j,k)*problema.a(i2)*solucao.x(i2,j,k);
                    end
                end
            end
            for j=1:problema.n_j
                fx = fx + problema.f(j) * solucao.p(j);
            end
            for k=1:problema.n_k
                fx = fx + problema.g(k) * solucao.q(k);
            end
        end
        % if neighbor improves fx
        if (fx < fx_old)
            % neighbor is left as the current solution and fx
            fx_old = fx;
            % thereisimprovement
            thereisimprovement = true;
            % and we get out of the loop
            break;            
        %else, we return the solution to normal
        else
            if i < problema.n_j+1
                solucao.p(i) = 1 - solucao.p(i);
            else
                solucao.q(i-problema.n_j) = 1 - solucao.q(i-problema.n_j);
            end
        end      
    end
end

if (strcmp(problema.calculate_x,'simplex'))
    solucao = reverse2_calculax_simplex(solucao,problema);
    fx = 0;
    for i=1:problema.n_i
        for j=1:problema.n_j+1
            for k=1:problema.n_k
                fx = fx + problema.c(i,j,k)*problema.a(i)*solucao.x(i,j,k);
            end
        end
    end

    for j=1:problema.n_j
        fx = fx + problema.f(j) * solucao.p(j);
    end

    for k=1:problema.n_k
        fx = fx + problema.g(k) * solucao.q(k);
    end
    fx_old = fx;
end

end

