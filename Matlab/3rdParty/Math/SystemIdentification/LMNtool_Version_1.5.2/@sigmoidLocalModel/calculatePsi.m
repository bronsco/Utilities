function psi = calculatePsi(obj, zRegressor,kappa,smoothness)
%% CALCULATEPSI calculates the psi values of the data for a local model.
%
%
%       [psi] = obj.calculatePsi(zRegressor)
%
%
%   CALCULATEPSI inputs:
%       zRegressor - (N X nz) Regression matrix/Regressors for rule premises.
%       kappa      - (1 x 1)) Scalar indicating the steepness of the
%                             transition of the sigmoid function.
%
%   CALCULATEPSI outputs:
%       psi - (N x 1) Psi values.
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fischer, 11-July-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% 2013/01/17:   help updated
% 2011/11/28:   help updated


if nargin < 3 || isempty(kappa)
    kappa = obj.kappa;
end
    
% calculate the exponent
X = -(kappa./smoothness) .* ( zRegressor*obj.splittingParameter(1:end-1) + obj.splittingParameter(end));

psi = sigmoid(X);

% psi = lineApprox(X);

% function to calculate the sigmoid function
function y = sigmoid(x)
y = 1./(1+exp(-x));
end

% function to approximate the sigmoid in a very simple way (less computational effort)
function y = lineApprox(x)
y = 0.5+ 0.25*x;
y(y < 0) = 0;
y(y > 1) = 1;
end

% figure(99)
% plot(zRegressor,psi,'b-')
% hold on
% plot(zRegressor,psiNEW,'r--')
% plot(zRegressor,approx,'m.-')
% hold off

end