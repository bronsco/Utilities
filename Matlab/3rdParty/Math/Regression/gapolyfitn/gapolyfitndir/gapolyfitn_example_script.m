%% gapolyfitn example script
%
% This script demonstrates the use of gapolyfitn to fit to the function
% sin(5xy) using 15 terms up to order 7
%
% Author:   Richard Crozier
% Release Date: 06 OCT 2009
%

% generate the variable data, requires randMat, available here:
%
% http://www.mathworks.co.uk/matlabcentral/fileexchange/24712
%
indepvar = randMat([0.00001; 0.00001], [0.99999; 0.99999], [0; 0], 1000);

% get the function values
depvar = sin(5 .* indepvar(:,1) .* indepvar(:,2));

% Choose 15 possible terms
maxTerms = 15;

% Choose a maximum possible power of 15
maxPower = 7;

% Print some output and progress information
options.VERBOSE = 1;
% Max number of generations set to 250
options.MAXGEN = 250;
options.DOSAVE = 0;
options.SAVEFILE = [cd '\testsav.mat'];
% options.LOADFILE = [cd '\testsav.mat'];
% multicore options, may actually slow things down for small polys,
% requires multicore package of functions
% options.MCORE = true;
% options.MCOREDIR = 'C:\';

% perform the polynomial fit using the GA
[polymodel, Best, IndAll] = gapolyfitn(indepvar, depvar, maxTerms, maxPower, options);

% plot the original function and the polynomial
figure;
[XI,YI] = meshgrid(0.00001:(0.9999-0.00001)/100:0.9999, 0.00001:(0.9999-0.00001)/100:0.9999); 
[XI,YI,ZI] = griddata(indepvar(:,1),indepvar(:,2),depvar, XI, YI);
mesh(XI,YI,ZI)
hold on
[XI,YI,ZI] = griddata(indepvar(:,1),indepvar(:,2),polyvaln(polymodel,indepvar), XI, YI);
mesh(XI,YI,ZI)
hold off

% Generate model using all possible terms for comparison
alltmspolymodel = polyfitn(indepvar, depvar, maxPower);


