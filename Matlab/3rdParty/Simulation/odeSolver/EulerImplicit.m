function [t,x]= EulerImplicit(MyFunc,InitialValue,Start,Finish,dt)
% solves the initial value problem dx/dt = f(x)
% Uses the Implicit Euler method

% INPUTS 
% ------
% Myfunc       = Handle to the function which calculates F(x,t)
% InitialValue = starting value (column vector)
% Start        = start time
% finish       = end time 
% dt           = time step size

% OUTPUTS
% -------
% x            = a vector containing the solution at each time
% t            = a vector containing the times which correspond to each element of x

% Description 
% -----------
% Uses the Implicit Euler method to solve an ode  of the form dx/dt=f(x,t). The function f(x,t) is supplied by the 
% user and must be of the form

% function [dx/dt] = f(x,t)
% i.e. its input arguments are the solution at time t (x) and t. It should return the rate of change of x

% Requires
% ---------
% fsolve  - used to solve the implicit equation. fsolve is part of the
% matlab optimisation toolbox and is not part of the standard matlab package.
%

x(:,1) = InitialValue;
t(1) = Start;
 
%calculate the time ste
Nsteps = (Finish-Start)/dt;
 
for i = 1:Nsteps
    
  %solve the implicit equation to get the updated value of x
  %calculate the new value of x and t
  t(i+1) = dt + t(i);
  x(:,i+1) = fsolve(@funToSolve,x(:,i),[],x(:,i),t(i+1),MyFunc,dt);
 
end
      
t = t';
x = x';
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The function to solve 
function residual = funToSolve(x,xo,t,MyFunc,dt)
  residual=xo+feval(MyFunc,t,x)*dt-x;
return