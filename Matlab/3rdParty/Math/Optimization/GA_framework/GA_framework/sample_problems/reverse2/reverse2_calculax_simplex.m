function [solucao] = calculax_simplex(solucao, problema)

%comentar isso depois
% problema.calculox = 'heurística';
% [ ~, solucao ] = reverse2( solucao , problema );
%disp(['Melhor solução da heuristica = ',num2str(fx)]);

prunned_c = problema.c(:,[1,solucao.p]==1,solucao.q==1);
prunned_b = problema.b(solucao.p==1);
prunned_d = problema.d(solucao.q==1);

posicao = 1;
f = zeros(numel(prunned_c),1);
Aeq = zeros(problema.n_i,length(f));
beq = ones(problema.n_i,1);
A = zeros(sum(solucao.p)+sum(solucao.q),length(f));
b = [prunned_b';prunned_d'];
lb = zeros(length(f),1);
ub = ones(length(f),1);
for i=1:problema.n_i
    for j=1:(sum(solucao.p)+1)
        for k=1:sum(solucao.q)
            f(posicao) = prunned_c(i,j,k)*problema.a(i);
            Aeq(i,posicao) = 1;
            if (j>1)
                A(j-1,posicao) = problema.a(i);
            end
            A(sum(solucao.p)+k,posicao) = problema.a(i);            
            posicao = posicao + 1;
        end
    end
end

%options=optimset('LargeScale','off','Simplex','on','Display','off');
options=optimset('Display','off');
x = linprog(f,A,b,Aeq,beq,lb,ub,[],options);

posicao = 1;
solucao.x = zeros(problema.n_i,problema.n_j+1,problema.n_k);
pos_p = find(solucao.p);
pos_q = find(solucao.q);
for i=1:problema.n_i
    for j=1:(sum(solucao.p)+1)
        for k=1:sum(solucao.q)
            if j == 1
                solucao.x(i,j,pos_q(k)) = x(posicao);
            else
                solucao.x(i,pos_p(j-1)+1,pos_q(k)) = x(posicao);
            end
            posicao = posicao + 1;
        end
    end
end



end