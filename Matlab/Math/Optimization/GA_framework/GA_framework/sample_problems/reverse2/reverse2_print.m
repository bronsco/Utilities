function reverse2_print( population, problem, parametros, stats)
%IMPRIMIR Imprime um resultado parcial, de acordo com o problem
figure(1);

% if (nargin>2)
%     %figure(1);
%     subplot(1,2,1);
%     pos = get(gcf,'Position');
%     pos(3:4) = [1120,412];
%     set(gcf,'Position',pos);
% end
hold off;
plot(problem.points_i(:,1),problem.points_i(:,2),'ok');
hold on;
plot(problem.points_j((population.best.p==1),1),problem.points_j((population.best.p==1),2),'sk');
plot(problem.points_k((population.best.q==1),1),problem.points_k((population.best.q==1),2),'^k');
plot(problem.points_j((population.best.p==0),1),problem.points_j((population.best.p==0),2),'sr');
plot(problem.points_k((population.best.q==0),1),problem.points_k((population.best.q==0),2),'^r');
xlim([-10 110]);
ylim([-10 110]);

%plota setas entre i e j
for i=1:problem.n_i
    for j=2:problem.n_j+1
        if (sum(population.best.x(i,j,:))>0)
            arrow(problem.points_i(i,:),problem.points_j(j-1,:));
        end
    end
end
%plota setas entre j e k
for j=2:problem.n_j+1
    for k=1:problem.n_k
        if (sum(population.best.x(:,j,k))>0)
            arrow(problem.points_j(j-1,:),problem.points_k(k,:));
        end
    end
end
%plota setas entre i e k
for i=1:problem.n_i
    for k=1:problem.n_k
        if (sum(population.best.x(i,1,k))>0)
            arrow(problem.points_i(i,:),problem.points_k(k,:));
        end
    end
end
legend('Origination','Collection','Refurbishing','Location','Best');
title('Best reverse logistics distribution solution known');
h = gca;
set(h,'XTick',[]);
set(h,'YTick',[]);
drawnow;

figure(2)
settings = parametros;
hold off;
subplot(2,1,1);
hold off;
plot([population.best.p,population.best.q]);
title(['Current solution with fx = ',num2str(population.best_fx) ,' in generation ',num2str(stats.gen), ' (', num2str(population.t),' with no improvement)']);
soma = [population.ind{1}.p,population.ind{1}.q];
for i=2:settings.n_ind
    soma = soma + [population.ind{i}.p,population.ind{i}.q];
end
hold on;
plot(soma./settings.n_ind,'r-');
legend({'Best solution','Average Solution'});
subplot(2,1,2);
hist(population.fx(1:settings.n_ind));
title('Variety of fx values');
drawnow;


% if (nargin>2)
%     %figure(2);
%     subplot(2,2,2);
%     hold off;
%     hist(population.fo,parametros.n_ind);
%     title('Population Objetive Function Histogram');
%     xlabel('Objective Function');
%     ylabel('Occurence');
% 
%     subplot(2,4,7);
%     hold off;
%     plot(0:stats.n_ger,stats.historico(1:stats.n_ger+1,:));
%     legend(['Best (',num2str(stats.historico(stats.n_ger+1,1)),')'],...
%         ['Mean (',num2str(stats.historico(stats.n_ger+1,2)),')'],...
%         ['Worst (',num2str(stats.historico(stats.n_ger+1,3)),')'],...
%         ['Best known (',num2str(stats.historico(stats.n_ger+1,4)),')']);
%     xlim([0 stats.n_ger])
%     title('Objective values throughout the generations');
%     xlabel('Generation');
%     ylabel('Objective Function');
%     
%     subplot(2,4,8);
%     hold off;
%     plot(0:stats.n_ger,stats.historico(1:stats.n_ger+1,[1,2,4]));
%     legend(['Best (',num2str(stats.historico(stats.n_ger+1,1)),')'],...
%         ['Mean (',num2str(stats.historico(stats.n_ger+1,2)),')'],...
%         ['Best known (',num2str(stats.historico(stats.n_ger+1,4)),')']);
%     xlim([0 stats.n_ger])
%     title('Objective values throughout the generations');
%     xlabel('Generation');
%     ylabel('Objective Function');
%     
%     figure(1);
% end

end



