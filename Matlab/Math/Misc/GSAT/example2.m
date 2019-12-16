% Example 2 
%
% 
% Citation: Cannavo' F., Sensitivity analysis for volcanic source modeling quality assessment and model selection, Computers & Geosciences, Vol. 44, July 2012, Pages 52-59, ISSN 0098-3004, http://dx.doi.org/10.1016/j.cageo.2012.03.008.

clear
clc

% create a new project 
pro = pro_Create();

% add 3 input variables with a pdf uniformely distributed in [-pi pi]
% pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [-pi pi]), 'X1');
% pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [-pi pi]), 'X2');
% pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [-pi pi]), 'X3');

% add to the project 3 input variables, named X*, distributed in the 
% range [-pi pi] and indicate that the variables will be sampled following a 
% Sobol quasi-random set 
pro = pro_AddInput(pro, @()pdf_Sobol([-pi pi]), 'X1');
pro = pro_AddInput(pro, @()pdf_Sobol([-pi pi]), 'X2');
pro = pro_AddInput(pro, @()pdf_Sobol([-pi pi]), 'X3');


% set the model, and name it as 'model', to the project 
% the model is well-known as "Ishigami function" (see 3.0.1)
pro = pro_SetModel(pro, @(x)TestModel2(x), 'model');

% set the number of samples for the quasi-random Monte Carlo simulation
pro.N = 20000;

% initialize the project by calculating the model at the sample points
pro = GSA_Init(pro);

% calculate the first order global sensitivity coefficients by using FAST
% algorithm
Sfast = GSA_FAST_GetSi(pro);

% calculate the first order global sensitivity coefficient for the second variable and
% verify that S1 equals the value calculated by FAST Sfast(1)
[S1 eS1 pro] = GSA_GetSy(pro, {1});

% calculate the total global sensitivity coefficient for the first input
% variable
[Stot eStot pro] = GSA_GetTotalSy(pro, {1});

