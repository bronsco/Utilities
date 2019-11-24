function akaikeWeights = calcAkaikeWeights(AICvalues)
%% Calculates Akaike weights for a set of AIC values.
%
%   This function can be utilized to calculate the Akaike weights of a series
%   of absolute Akaike values.
%
%       akaikeWeights = calculateAkaikeWeights(AICvalues)
%
% 
%   INPUTS
%
%       AICvalues:      (1 x nM) AIC values of different models. Note that the
%                       comparison of different models with the help of the AIC
%                       makes only sense, if all models are trained with the
%                       same training data set!
%
%
%   OUTPUTS
%
%       akaikeWeights: 	(1 x nM) Akaike weights, that belong to the
%                       corresponding AIC-value in the AICvalues vector. For
%                       details see 'Model Selection and Multimodel Inference'
%                       from Kenneth P. Burnham and David R. Anderson.
%
% 
%   SYMBOLS AND ABBREVIATIONS
%
%       nM: Number of different models. For each model one AIC value is contained
%           in the input vector 'AICvalues'.
%
%
%   LMNtool - Local Model Network Toolbox
%   Julian Belz, 29-November-2012
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% Calculate AIC differences
deltaAICs = [AICvalues{:}] - min([AICvalues{:}]);

% Calculate nominator values for the calculation of the different Akaike
% weights
numerator = arrayfun(@(x) exp(-0.5*x), deltaAICs);
% nominator2 = zeros(1,size(deltaAICs,2));
% for ii=1:size(deltaAICs,2)
%     nominator2(ii) = exp(-0.5*deltaAICs(ii));
% end

% Make sure no NaN values are present in the numerator
idxNaN = isnan(numerator);
numerator(idxNaN) = 0;

% Calculate denominator for the calculation of all Akaike weights
denominator = sum(numerator);
% denominator2 = 0;
% for ii=1:size(deltaAICs,2)
%     denominator2 = denominator2 + exp(-0.5*deltaAICs(ii));
% end

% Restore the NaN values
numerator(idxNaN) = NaN;

% Calculate Akaike weights
akaikeWeights = numerator/denominator;

end