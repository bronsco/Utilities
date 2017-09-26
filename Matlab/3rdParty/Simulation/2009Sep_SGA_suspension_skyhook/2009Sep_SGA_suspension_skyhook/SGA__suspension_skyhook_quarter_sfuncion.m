function [sys,x0,str,ts] = SGA__suspension_skyhook_quater_sfuncion(t,x,u,flag,Cfirm,Csoft,Csh)

% /*M-FILE Function SGA__suspension_skyhook_quater_sfuncion MMM SSTSLAB */
% /*==================================================================================================
%  Simple Genetic Algorithm Laboratory Toolbox for Matlab 7.x
%
%  Copyright 2007 The SxLAB Family - Yi Chen - leo.chen.yi@gmail.com
% ====================================================================================================
%File description:
%
%   this function is a control block for vehicle semi active suspension
%   systems , which based on the skyhook theory
%    a type of "practical" skyhook control method
%
%Input:
%
%   t -- time                                         [Not modify]
%   x -- state of s funciton                          [Not modify]
%   u -- inputs vector , where                        [by user]
%                            u(1) = Unsprung_Velocity
%                            u(2) = Sprung_Velocity
%                            u(3) = Road_Velocity
%   flag -- flat status                               [No modify]
%   Cfirm-- damping coefficient in firm status
%   Csoft-- damping coefficient in soft status,
%   Csh  -- damping coefficient in skyhook status,
%Output:
%   sys -- outputs vector        [by user]
%                         sys(1)=u
%                         sys(2)=c_skyhook
%   x0  -- sfunction std output  [Not modify]
%   str -- sfunction std output  [Not modify]
%   ts  -- sfunction std output  [Not modify]
%
% Appendix comments:
%  follow the example of timestwo.m, provide by matlab
%
% Usage:
%
%===================================================================================================
%  See Also:         SGA__suspension_skyhook_quater_sfuncion
%
%
%===================================================================================================
%
%===================================================================================================
%Revision -
%Date         Name       Description of Change    email                 Location
%01-May-2003  Yi Chen    Initial version          leo.chen.yi@gmail.com Chongqing
%09-Jan-2007  Yi Chen    Update it as SGALAB demo leo.chen.yi@gmail.com Glasgow
%HISTORY$
%==================================================================================================*/

% SGA__suspension_skyhook_quater_sfuncion Begin

% The following outlines the general structure of an S-function.

%
switch flag,

    case 0,
        [sys,x0,str,ts]=mdlInitializeSizes;
    case 2,
        sys=mdlUpdate(u,Cfirm,Csoft,Csh);
    case 3,
        sys=mdlOutputs(x);
    case{1,4,9},
        sys=[];
    otherwise
        error(['Unhandled flag = ',num2str(flag)]);
end

% SGA__suspension_skyhook_quater_sfuncion End

function [sys,x0,str,ts]=mdlInitializeSizes
sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 2;  % x
sizes.NumOutputs     = 2;  % sys
sizes.NumInputs      = 3;  %  u
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;   % at least one sample time is needed
sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [0;0];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [-1  0];

% end mdlInitializeSizes

function sys=mdlUpdate( u,Cfirm,Csoft,Csh )
[sys(1),sys(2)] = skyhook(u(1),u(2),u(3),Cfirm,Csoft,Csh);

%u(1)=Unsprung_Velocity
%u(2)=Sprung_Velocity
%u(3)=Road_Velocity

function sys=mdlOutputs(x)

sys=x;

%sys(1)=u_control;
%sys(2)=c_semi_skyhook;

% end mdlOutputs



function  [u_control,c_semi_skyhook] = skyhook( Unsprung_Velocity, Sprung_Velocity, Road_Velocity,Cfirm,Csoft,Csh)


if ( Unsprung_Velocity - Sprung_Velocity )==0
%     u_control     = 0;
%     c_semi_skyhook= 0;

    u_control = 0;
    c_semi_skyhook = Csoft;
    
else
    if (Cfirm/Csh)<Sprung_Velocity/(Unsprung_Velocity-Sprung_Velocity)
        
        u_control=Cfirm*(Unsprung_Velocity-Sprung_Velocity);
        c_semi_skyhook=Cfirm;
        
    elseif (Csoft/Csh)<Sprung_Velocity/(Unsprung_Velocity-Sprung_Velocity)&(Cfirm/Csh)>Sprung_Velocity/(Unsprung_Velocity-Sprung_Velocity)
        
        u_control=Csh*Sprung_Velocity;
        c_semi_skyhook=Csh*Sprung_Velocity/(Unsprung_Velocity-Sprung_Velocity);
        
    else
        
        u_control=Csoft*(Unsprung_Velocity-Sprung_Velocity);
        c_semi_skyhook=Csoft;
        
    end
end