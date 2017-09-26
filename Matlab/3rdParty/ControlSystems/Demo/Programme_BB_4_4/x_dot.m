function [ableitung] = x_dot(t,x)
global A b K T r p t_vorwaerts

% vorbereitend müssen wir p(t) bereitstellen. Wir suchen zunächst dasjenige
% Element von t_vorwaerts, das dem aktuellen t am nächsten ist:
[t_min,zeiger] = min(abs(t - t_vorwaerts));
% Nun benutzen wir einfach P(zeiger) als Approximation von P(t)

% Die Ableitung ist Ax+bu = A*x - b*R^(-1)*b^T*P(zeiger)*x
ableitung = A*x - (K/(r*T))*b*[p(zeiger,2) p(zeiger,3)]*x;