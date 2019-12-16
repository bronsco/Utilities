function child = reverse2_crossover_intersection(parents,~,~, population)
%CRUZAMENTO2REVERSE


%child formado pela interseção dos pais
child.p = population.ind{parents(1)}.p&population.ind{parents(2)}.p;
child.q = population.ind{parents(1)}.q&population.ind{parents(2)}.q;

%vetor de união menos interseção
vector_p = (population.ind{parents(1)}.p|population.ind{parents(2)}.p)&(~child.p);
vector_q = (population.ind{parents(1)}.q|population.ind{parents(2)}.q)&(~child.q);


%child deve ter um número de facilidades abertas igual à dos pais
goal_p = round((sum(population.ind{parents(1)}.p)*population.fit(parents(1))+sum(population.ind{parents(2)}.p)*population.fit(parents(2)))/(population.fit(parents(1))+population.fit(parents(2))));
goal_q = round((sum(population.ind{parents(1)}.q)*population.fit(parents(1))+sum(population.ind{parents(2)}.q)*population.fit(parents(2)))/(population.fit(parents(1))+population.fit(parents(2))));

% se a meta de facilidade não foi atingida
if (sum(child.p) < goal_p)
    % enquanto ela não for atingida
    count2 = 0;
    while (sum(child.p) < goal_p)
        % escolhe uma facilidade aberta no vector_p
        pos = randi(sum(vector_p));
        % procura a facilidade
        count = 0;
        for i=1:size(vector_p,2)
            if (vector_p(i) == 1)
                count = count + 1;
                if (count == pos)
                    break;
                end
            end
        end
        % adiciona no child
        child.p(i) = 1;
        % remove do vetor
        vector_p(count) = 0;
        count2 = count2 + 1;
        if (count2>30)
            break;
        end
    end
end

% se a meta de facilidade não foi atingida
if (sum(child.q) < goal_q)
    % enquanto ela não for atingida
    count2 = 0;
    while (sum(child.q) < goal_q)
        % escolhe uma facilidade aberta no vector_p
        pos = randi(sum(vector_q));
        % procura a facilidade
        count = 0;
        for i=1:size(vector_q,2)
            if (vector_q(i) == 1)
                count = count + 1;
                if (count == pos)
                    break;
                end
            end
        end
        % adiciona no child
        child.q(i) = 1;
        % remove do vetor
        vector_q(count) = 0;
        count2 = count2 + 1;
        if (count2>30)
            break;
        end
    end
end
