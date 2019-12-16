function [ableitung] = p_dot(t,p)
global K T Q r
ableitung = [-K*K*p(2)*p(2)/(r*T*T) + Q(1,1);
   -K*K*p(2)*p(3)/(r*T*T) + p(1) - p(2)/T;
   -K*K*p(3)*p(3)/(r*T*T) + 2*p(2) - 2*p(3)/T + Q(1,1)];