function mop_print( population, problem, settings, stats)
%PRINT the best solution in the population

hold off;
subplot(2,1,1);
hold off;
for i=length(population.best):-1:1
    best_x(i,:) = population.best{i};
end
plot(best_x');
title(['Current solutions in generation ',num2str(stats.gen), ' (', num2str(population.t),' with no improvement)']);
subplot(2,1,2);
paretofronts([population.best_fx;population.fx], problem.minimization,'pareto',1);
title(['Variety of fx values. ',num2str(length(population.best)),' pareto solutions']);
drawnow;

end




