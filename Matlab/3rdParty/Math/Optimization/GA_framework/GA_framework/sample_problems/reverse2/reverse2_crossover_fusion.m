function child = reverse2_crossover_fusion(parents,~,~, population)
%CRUZAMENTO2REVERSE

%probabilidade de copiar do pai1
if (population.fx(parents(1))==inf)&&(population.fx(parents(2))==inf)
    p1 = 0.5;
elseif (population.fx(parents(1))==inf)
    p1 = 1;
elseif (population.fx(parents(2))==inf)
    p1 = 0;
else
    p1 = population.fx(parents(2))/(population.fx(parents(1))+population.fx(parents(2)));
end

child.p = population.ind{parents(1)}.p&population.ind{parents(2)}.p;
child.q = population.ind{parents(1)}.q&population.ind{parents(2)}.q;

for i=1:length(child.p)
    if rand()<p1
        child.p(i) = population.ind{parents(1)}.p(i);
    else
        child.p(i) = population.ind{parents(2)}.p(i);
    end
end
for i=1:length(child.q)
    if rand()<p1
        child.q(i) = population.ind{parents(1)}.q(i);
    else
        child.q(i) = population.ind{parents(2)}.q(i);
    end
end
end

