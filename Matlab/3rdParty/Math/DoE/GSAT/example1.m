% Example 1 
%
% 
% Citation: Cannavo' F., Sensitivity analysis for volcanic source modeling quality assessment and model selection, Computers & Geosciences, Vol. 44, July 2012, Pages 52-59, ISSN 0098-3004, http://dx.doi.org/10.1016/j.cageo.2012.03.008.

clear
clc

% create a new project 
pro = pro_Create();

% add 5 input variables with a pdf uniformely distributed in [0 1]
% pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [0 1]), 'param1');
% pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [0 1]), 'param2');
% pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [0 1]), 'param3');
% pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [0 1]), 'param4');
% pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [0 1]), 'param5');

% add to the project 5 input variables, named param*, distributed in the 
% range [0 1] and indicate that the variables will be sampled following a 
% Sobol set 
pro = pro_AddInput(pro, @()pdf_Sobol([0 1]), 'param1');
pro = pro_AddInput(pro, @()pdf_Sobol([0 1]), 'param2');
pro = pro_AddInput(pro, @()pdf_Sobol([0 1]), 'param3');
pro = pro_AddInput(pro, @()pdf_Sobol([0 1]), 'param4');
pro = pro_AddInput(pro, @()pdf_Sobol([0 1]), 'param5');

% set the model, and name it as 'model', to the project 
% the model is well-known as "Sobol’ function" 
pro = pro_SetModel(pro, @(x)TestModel(x,[0 1 9 9 9]), 'model');

% calculate the real analytical values of sensitivity coefficients for the 
% model "Sobol’ function" (3.0.1).
[D, Si] = SATestModel([0 1 9 9 9]);

% set the number of samples for the quasi-random Monte Carlo simulation
pro.N = 20000;

% initialize the project by calculating the model at the sample points
pro = GSA_Init(pro);

% calculate the total global sensitivity coefficient for the set of 2 variables
% ('param1 and param5) (see sections 2.3 and 2.4)
% [Stot eStot pro] = GSA_GetTotalSy(pro, {'param1', 'param5'});

% calculate the global sensitivity coefficient for the set of all the input
% variables and verify that equals 1
[S, eS, pro] = GSA_GetSy(pro, {5,3,1,2,4});

% calculate the first order global sensitivity coefficient for the second variable and
% verify that S2 equals the real value Si(2)
[S2, eS2, pro] = GSA_GetSy(pro, {2});

% calculate the first order global sensitivity coefficients by using FAST
% algorithm and verify that all coefficients equal the real ones in Si
Sfast = GSA_FAST_GetSi(pro);


