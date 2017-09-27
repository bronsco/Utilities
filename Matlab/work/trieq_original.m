function [f,g,h,j] = trieq_original(a,b,c,d,T)
%  [F,G,H,J] = trieq(A,B,C,D,T) computes the triangle
%  equivalent of the continuous system  A  B C D at
%  sampling period T
[n,n] = size(a);
[ny,nx] = size(c);
cc = zeros(ny,nx);
[nx,nu] = size(b);
bb = zeros(nx,nu);
aa = [a b bb ; cc 0 1/T; cc 0 0];
pp = expm(aa*T);
f = pp(1:n,1:n);
g1 = pp(1:n,n+1);
g2 = pp(1:n,n+2);
g = g1 + f*g2 - g2;
h = c;
j = d + c*g2;
