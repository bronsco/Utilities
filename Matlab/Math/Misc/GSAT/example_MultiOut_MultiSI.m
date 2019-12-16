% Example 1 
%
% 
% Citation: Cannavo' F., Sensitivity analysis for volcanic source modeling quality assessment and model selection, Computers & Geosciences, Vol. 44, July 2012, Pages 52-59, ISSN 0098-3004, http://dx.doi.org/10.1016/j.cageo.2012.03.008.

clear all
home

% create a new project 
pro = pro_Create();

% add 5 input variables with a pdf uniformely distributed in [0 1]
%pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [0 1]), 'param1');
%pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [0 1]), 'param2');
%pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [0 1]), 'param3');
%pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [0 1]), 'param4');
%pro = pro_AddInput(pro, @(N)pdf_Uniform(N, [0 1]), 'param5');

% add 5 input variables to the project, named param*, distributed in the 
% range [0 1] and indicate that the variables will be sampled following a 
% Sobol set
pro = pro_AddInput(pro, @()pdf_Sobol([0 1]), 'param1');
pro = pro_AddInput(pro, @()pdf_Sobol([0 1]), 'param2');
pro = pro_AddInput(pro, @()pdf_Sobol([0 1]), 'param3');
pro = pro_AddInput(pro, @()pdf_Sobol([0 1]), 'param4');
pro = pro_AddInput(pro, @()pdf_Sobol([0 1]), 'param5');

% set the model, and name it as 'model', to the project 
% the model is well-known as "Sobol’ function"
pro = pro_SetModel(pro, @(x)TestModel(x,[0 1 9 9 9]), 'TestModel');

% calculate the real analytical values of sensitivity coefficients for the 
% model "Sobol’ function" (3.0.1).
[D, Si] = SATestModel([0 1 9 9 9]);

% set the number of samples for the quasi-random Monte Carlo simulation
pro.N = 100000;

% initialize the project by calculating the model at the sample points
pro = GSA_Init_MultiOut_MultiSI(pro);

% Calculate the first order global sensitivity coefficient for the set of
% variables comprising all the FUNDAMENTAL, DISTRIBUTED parameters and 
% verify that it equals 1
[S12345, eS12345, pro] = GSA_GetSy_MultiOut_MultiSI(pro, {1,2,3,4,5}); % THIS PART SHOULD TAKE A LONG AMOUNT OF TIME

% Calculate the total global sensitivity coefficient for the set of 
% variables comprising all the FUNDAMENTAL, DISTRIBUTED parameters and 
% verify that it equals 1
[Stot12345, eStot12345, pro] = GSA_GetTotalSy_MultiOut_MultiSI(pro, {'param1','param2','param3','param4','param5'});

% Calculate the first order global sensitivity coefficient for the set of
% variables comprising only the first FUNDAMENTAL, DISTRIBUTED parameter
[S1, eS1, pro] = GSA_GetSy_MultiOut_MultiSI(pro, {1});
% Calculate the first order global sensitivity coefficient for the set of
% variables comprising only the second FUNDAMENTAL, DISTRIBUTED parameter
[S2, eS2, pro] = GSA_GetSy_MultiOut_MultiSI(pro, {2});
% Calculate the first order global sensitivity coefficient for the set of
% variables comprising only the third FUNDAMENTAL, DISTRIBUTED parameter
[S3, eS3, pro] = GSA_GetSy_MultiOut_MultiSI(pro, {3});
% Calculate the first order global sensitivity coefficient for the set of
% variables comprising only the fourth FUNDAMENTAL, DISTRIBUTED parameter
[S4, eS4, pro] = GSA_GetSy_MultiOut_MultiSI(pro, {4});
% Calculate the first order global sensitivity coefficient for the set of
% variables comprising only the fifth FUNDAMENTAL, DISTRIBUTED parameter
[S5, eS5, pro] = GSA_GetSy_MultiOut_MultiSI(pro, {5});

% Calculate the total global sensitivity coefficient for the set of 
% variables comprising only the first FUNDAMENTAL, DISTRIBUTED parameter
[Stot1, eStot1, pro] = GSA_GetTotalSy_MultiOut_MultiSI(pro, {'param1'});
% Calculate the total global sensitivity coefficient for the set of 
% variables comprising only the second FUNDAMENTAL, DISTRIBUTED parameter
[Stot2, eStot2, pro] = GSA_GetTotalSy_MultiOut_MultiSI(pro, {'param2'});
% Calculate the total global sensitivity coefficient for the set of 
% variables comprising only the third FUNDAMENTAL, DISTRIBUTED parameter
[Stot3, eStot3, pro] = GSA_GetTotalSy_MultiOut_MultiSI(pro, {'param3'});
% Calculate the total global sensitivity coefficient for the set of 
% variables comprising only the fourth FUNDAMENTAL, DISTRIBUTED parameter
[Stot4, eStot4, pro] = GSA_GetTotalSy_MultiOut_MultiSI(pro, {'param4'});
% Calculate the total global sensitivity coefficient for the set of 
% variables comprising only the fifth FUNDAMENTAL, DISTRIBUTED parameter
[Stot5, eStot5, pro] = GSA_GetTotalSy_MultiOut_MultiSI(pro, {'param5'});
