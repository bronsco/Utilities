function [theta, indexSelectedRegressors, errorImprovement, linearDependentRegressors] = orthogonalLeastSquares(xRegressorWeighted, outputWeighted, numberOfCoeff, minErrorImprovement, thresholdLinearDependency)
%% ORTHOGONALLEASTSQUARES estimates the parameters using orthogonal-least-squares (OLS) for subset
% selection.
%
%
%       [theta, selectedRegressors, errorImprovement, linearDependentRegressors] = ...
%           orthogonalLeastSquares(regressionMatrix, outputVector, subsetSelectionMaxNumber, ...
%           minErrorImprovement, thresholdLinearDependency)
%
%
%   ORTHOGONALLEASTSQUARES inputs:
%       regressionMatrix          - (N x nx)  Regression matrix (columns of potential rergressors)
%       outputVector              - (N x 1)   Output vector
%       subsetSelectionMaxNumber  - (1 x 1)   Maximum number of regressors to be selected
%       minErrorImprovement       - (1 x 1)   Minimum Error Improvement for Selection
%       thresholdLinearDependency - (1 x 1)   Threshold for selection of linear dependency
%                                             Note: Must always be used with a minErrorImprovement > 0,
%                                                   else linear dependent regressors are not ruled out.
%                                                   thresholdLinearDependency=0: no linear dependence check
%
%
%   ORTHOGONALLEASTSQUARES outputs:
%       theta                     - (Ms x 1)  Parameter vector for one output of one LM ~ parameter(lm,:,out)
%       selectedRegressors        - (Ms x 1)  Vector of indices of selected regressors (columns)
%       errorImprovement          - (Mm x 1)  Improvement of the error according to the selected regressor
%       linearDependentRegressors - (Ml x 1)  Vector of indices of linear dependent regressors
%                                             Note: Obviously, this vector is not unique.
%                                                   If regressor 1 is linear dependent on regressor 2,
%                                                   then the reverse is also true. It depends on
%                                                   small influences which of the two regressors is
%                                                   selected.
%
%
%   Ms: number of selected regressors
%   Ml: number of linear dependent regressors
%
%
%   See also estimateParametersLocal, estimateParametersGlobal, estimateParametersGlobalNOE,
%            estimateParametersGlobalIV, LMNBackwardElimination, WLSEstimate,
%            WLSForwardSelection, WLSBackwardElimination, findMinPRESSLambda,
%            orthogonalLeastSquares.
%
%
%   LMNtool - Local Model Network Toolbox
%   Torsten Fischer, 19-Januar-2012
%   Automatic Control - Mechatronics, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% Get some constants
[numberOfSamples numberOfxRegressors] = size(xRegressorWeighted);

% Initialization
theta = zeros(numberOfCoeff,1);
selectedRegressors = zeros(numberOfCoeff,1);
selectedRegressors_alt = zeros(numberOfCoeff,1);
indexSelectedRegressors = false(1,numberOfxRegressors);
errorImprovement = zeros(numberOfCoeff,1);
LinearDependency = zeros(numberOfxRegressors,1); % Determines whether Regressor linearly dependent


g = zeros(numberOfCoeff,1);                          % Parameter in the transformed space
g_alt = zeros(numberOfCoeff,1);                          % Parameter in the transformed space
A = eye(numberOfCoeff,numberOfCoeff);     % becomes an upper triangular matrix
A_alt = eye(numberOfCoeff,numberOfCoeff);     % becomes an upper triangular matrix
BULLSHIT = zeros(numberOfxRegressors,1);            % Error Improvement for all possible regressors in each step
errorImprovementTest = zeros(numberOfxRegressors,1);            % Error Improvement for all possible regressors in each step
errorImprovementTest_alt = zeros(numberOfxRegressors,1);            % Error Improvement for all possible regressors in each step
W = zeros(numberOfSamples,numberOfCoeff);            % Matrix with the Ms selected regressors
W_alt = zeros(numberOfSamples,numberOfCoeff);            % Matrix with the Ms selected regressors
N = size(outputWeighted,1);                                       % Determine number of data points


% First step
for i = 1:numberOfxRegressors
    W(:,1) = xRegressorWeighted(:,i); % Test-regressor
    W_quad = sum(W(:,1).*W(:,1));
    
    %     W_quad = (W(:,1)'*W(:,1));
    
    g(1) = sum(W(:,1).*outputWeighted)/W_quad;
    
    errorImprovementTest(i) = (g(1)^2)*(W_quad)/sum(outputWeighted.*outputWeighted);
    
    g_alt(1) = (W(:,1)'*outputWeighted)/(W(:,1)'*W(:,1));
    errorImprovementTest_alt(i) = (g(1)^2)*(W(:,1)'*W(:,1))/(outputWeighted'*outputWeighted);
    
    if g_alt(1)~=g(1)
%         keyboard
    end
    
    if errorImprovementTest(i) ~= errorImprovementTest_alt(i)
%         keyboard
        BULLSHIT(i) = errorImprovementTest(i)-errorImprovementTest_alt(i);
    end
    
end
% keyboard
% Regressor with maximum error reduction
[errorImprovement(1) selectedRegressors(1)] = max(errorImprovementTest);
errorImprovementSum = errorImprovement(1); % Sum of the errors
errorImprovementSumTilde = 1-errorImprovementSum(1);

W(:,1) = xRegressorWeighted(:,selectedRegressors(1)); % Save first regressor
W_alt(:,1) = xRegressorWeighted(:,selectedRegressors(1)); % Save first regressor

g(1) = sum(W(:,1).*outputWeighted)/sum(W(:,1).*W(:,1));     % Save first parameter
g_alt(1) = (W_alt(:,1)'*outputWeighted)/(W_alt(:,1)'*W_alt(:,1));     % Save first parameter

if g_alt(1)~=g(1)
%     keyboard
end

% Step 2, 3, ..., subsetSelectionMaxNumber
for k = 2:numberOfCoeff % Over all regressors to be selected
    errorImprovementTest = zeros(numberOfxRegressors,1);
    errorImprovementTest_alt = zeros(numberOfxRegressors,1);
    for i = 1:numberOfxRegressors
        if any(selectedRegressors == i) % If i is already selected
        else
            sumTmp = 0;
            sumTmp_alt = 0;
            for j = 1:k-1 % Over column k of matrix A down to the  (excluding) diagonal A(k,k) = 1
                B1 = sum(W(:,j).*xRegressorWeighted(:,i));
                B2 = sum(W(:,j).*W(:,j));
                A(j,k) = B1/B2;
                
                A_alt(j,k) = (W_alt(:,j)'*xRegressorWeighted(:,i))/(W_alt(:,j)'*W_alt(:,j));
                
                if A_alt(j,k)~=A(j,k)
%                     keyboard
                end
                sumTmp = sumTmp + A(j,k)*W(:,j);
                sumTmp_alt = sumTmp_alt + A_alt(j,k)*W_alt(:,j);
            end
            W(:,k) = xRegressorWeighted(:,i) - sumTmp; % Test-regressor orthogonal to W(:,1) ... W(:,k-1)
            W_alt(:,k) = xRegressorWeighted(:,i) - sumTmp_alt; % Test-regressor orthogonal to W(:,1) ... W(:,k-1)
            W_quad = sum(W(:,k).*W(:,k));
            %if (sum(W(:,k).*W(:,k))/N)< thresholdLinearDependency         % Test linear dependency
            if (W_quad/N)< thresholdLinearDependency         % Test linear dependency
                errorImprovementTest(i) = 0;                            % If linear dependent -> Improvement=0,
                errorImprovementTest_alt(i) = 0;                            % If linear dependent -> Improvement=0,
                % i.e. regressor  will not be considered
                LinearDependency(i) = 1;                                % Signal linear dependency
                % disp('Linear dependency');
            else
                
                g(k) = (W(:,k)'*outputWeighted)/W_quad;
                errorImprovementTest(i) = (g(k)^2)*W_quad/sum(outputWeighted.*outputWeighted);
                
                g_alt(k) = (W_alt(:,k)'*outputWeighted)/(W_alt(:,k)'*W_alt(:,k));
                errorImprovementTest_alt(i) = (g_alt(k)^2)*(W_alt(:,k)'*W_alt(:,k))/(outputWeighted'*outputWeighted);
            end
        end
    end
    
    % Regressor with maximum error reduction
    [errorImprovement(k) selectedRegressors(k)] = max(errorImprovementTest);
    [errorImprovement(k) selectedRegressors_alt(k)] = max(errorImprovementTest_alt);
    if selectedRegressors(k) ~= selectedRegressors_alt(k)
        keyboard
    end
    errorImprovementSum = [errorImprovementSum errorImprovementSum(k-1)+errorImprovement(k)];
    errorImprovementSumTilde = [errorImprovementSumTilde 1-errorImprovementSum(k)];
    
    if errorImprovement(k) < minErrorImprovement % If error improvement threshold is reached
        break;
    end
    
    % Calculate again with selected regressor since it has been overwritten
    sumTmp = 0;
    for j = 1:k-1 % Over column k of matrix A down to the  (excluding) diagonal A(k,k) = 1
        A(j,k) = sum(W(:,j).*xRegressorWeighted(:,selectedRegressors(k)))/sum(W(:,j).*W(:,j));
%         A(j,k) = (W(:,j)'*xRegressorWeighted(:,selectedRegressors(k)))/(W(:,j)'*W(:,j));
        sumTmp = sumTmp + A(j,k)*W(:,j);
    end
    W(:,k) = xRegressorWeighted(:,selectedRegressors(k)) - sumTmp; % Test-regressor orthogonal to W(:,1) ... W(:,k-1)
    g(k) = sum(W(:,k).*outputWeighted)/sum(W(:,k).*W(:,k)); % Save k-th parameter
end

% Extract theta from diagonal matrix A * theta = g by backward substitution
if errorImprovement(k) < minErrorImprovement % If error improvement threshold has been reached
    numberOfCoeff = k-1;
end
errorImprovement = errorImprovement(1:numberOfCoeff);
selectedRegressors = selectedRegressors(1:numberOfCoeff);
g = g(1:numberOfCoeff);
theta = theta(1:numberOfCoeff);

theta(numberOfCoeff) = g(numberOfCoeff);
for i = numberOfCoeff-1:-1:1
    sumTmp = 0;
    for j = i+1:numberOfCoeff
        sumTmp = sumTmp + A(i,j)*theta(j);
    end
    theta(i) = g(i) - sumTmp;
end

selectedRegressors = selectedRegressors(:);
indexSelectedRegressors(selectedRegressors) = true;
errorImprovement = errorImprovement(:);

% Create Vector of indices of linearly dependent regressors
linearDependentRegressors=find(LinearDependency==1);
