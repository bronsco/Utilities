function realfunction_print( population, ~, settings, stats)
%PRINT the best solution in the population

figure(1);

hold off;
subplot(2,1,1);
hold off;
plot(population.best);
title(['Current solution with fx = ',num2str(population.best_fx) ,' in generation ',num2str(stats.gen), ' (', num2str(population.t),' with no improvement)']);
soma = population.ind{1};
for i=2:settings.n_ind
    soma = soma + population.ind{i};
end
hold on;
plot(soma./settings.n_ind,'r-');
legend({'Best solution','Average Solution'});
subplot(2,1,2);
hist(population.fx(1:settings.n_ind));
title('Variety of fx values');
drawnow;


end




