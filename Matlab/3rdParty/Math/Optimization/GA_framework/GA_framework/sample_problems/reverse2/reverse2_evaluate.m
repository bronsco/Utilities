function [ fx, solution ] = reverse2_evaluate( solution , problem , ~ )
%2REVERSE 


% Checks if there is feasible solution for the route
% In other words, if everything in a fits in q
if (sum(problem.d(solution.q==1))<sum(problem.a))
    constante = 10;
    fx = max(0,sum(problem.b(solution.p==1))-sum(problem.a));
    fx = fx + max(0,sum(problem.d(solution.q==1))-sum(problem.a));
    fx = constante*fx + max(max(max(problem.c)))*max(problem.a)*problem.n_i*problem.n_j*problem.n_k + max(problem.f)*problem.n_j + max(problem.g)*problem.n_k;
    solution.x = zeros(problem.n_i,problem.n_j+1,problem.n_k);
    return;
end

% Calculates the route X for this solution
if (strcmp(problem.calculate_x,'heuristica'))
    solution = reverse2_calculax_heuristica(solution,problem);
elseif (strcmp(problem.calculate_x,'simplex'))
    % se vai ter busca local, vai na heurística mesmo
    if (problem.localsearch)
        solution = reverse2_calculax_heuristica(solution,problem);
    else % se não tem busca local, aí é simplex neles
        solution = reverse2_calculax_simplex(solution,problem);
    end
end

% Calculate the objective function for the solution in the route X
fx = 0;

%save('problemtica','solution','problem');

for i=1:problem.n_i
    for j=1:problem.n_j+1
        for k=1:problem.n_k
            fx = fx + problem.c(i,j,k)*problem.a(i)*solution.x(i,j,k);
        end
    end
end

for j=1:problem.n_j
    fx = fx + problem.f(j) * solution.p(j);
end

for k=1:problem.n_k
    fx = fx + problem.g(k) * solution.q(k);
end

%Confere se p e q respeitam os limites
if ((sum(solution.p)>problem.p_max)||(sum(solution.q)>problem.q_max)||(sum(solution.p)<problem.p_min)||(sum(solution.q)<problem.q_min))
    fx = inf;
end
   
% aplica a busca local
if (problem.localsearch)
    [fx, solution] = reverse2_fi_search(solution,fx,problem);
end    


end
