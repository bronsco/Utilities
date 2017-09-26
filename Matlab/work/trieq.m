% function dsys = trieq(SYS,T)
% ##  dsys = trieq(sys,T) computes the discrete time 
% ##  triangle hold equivalent of purely contiouns system
% ##  SYS at sampling period T.
% ##
% ##  The triangle hold equvialent is described in 
% ##  Digital Control of Dynamic Systems, Franklin et. al, 2nd edtion, 
% ##  page 151-155.
% ##
% if(!(0 == is_digital(SYS)))
%   error("trieq: system is not purely contionous") % Mayby this restriction could be removed.
% else
%   [a,b,c,d,tsam,n,nz,stname,inname,outname,yd] = sys2ss(SYS);
%   stnamed = strappend(stname,"_d");
  [n,n] = size(a);
  [ny,nx] = size(c);
  [nx,nu] = size(b);
  cc = zeros(nu,nx);
  bb = zeros(nx,nu);
  ccc = zeros(nu, nu);
  tt = 1/T* eye(nu, nu);
  aa = [a b bb ; cc ccc tt; cc ccc ccc]; % Create big matrix
  pp = expm(aa*T);
  f = pp(1:n,1:n);
  gamma1 = pp(1:n,n+1:n+nu);
  gamma2 = pp(1:n,n+nu+1:n+2*nu);
  g = gamma1 + f*gamma2 - gamma2;
  h = c;
  j = d + c*gamma2;
%   dsys = ss(f,g,h,j,T,0,rows(f),stnamed,inname,outname);
% endif
