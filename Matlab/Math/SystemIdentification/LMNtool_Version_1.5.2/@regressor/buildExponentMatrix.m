function exponentMatrix = buildExponentMatrix(regressorType,regressorDegree,numInputs)
%% BUILDEXPONENTMATRIX creates a exponent matrix. The exponent matrix depends
% on the number of inputs.
%
%
%       [exponentMatrix] = buildExponentMatrix(regressorType,regressorDegree,numInputs)
%
%
%   buildExponentMatrix inputs:
%       regressorType   - (string) Speciefies the setup of the regressor
%                                  matrix. Options are:
%                                   'polynomial'
%                                   'sparsePolynomial'
%
%       regressorDegree - (1 x 1) Degree of the polynomial.
%
%       numInputs       - (1 x 1) Specifies the number of physical inputs
%                                 for the exponent matrix.
%
%   buildExponentMatrix output:
%       exponentMatrix  - (nx x p) Exponent matrix with as many coloums as
%                                  inputs.
%
%
%   SYMBOLS AND ABBREVIATIONS
%
%       LM:  Local model
%
%       p:   Number of inputs (physical inputs)
%       q:   Number of outputs
%       N:   Number of data samples
%       M:   Number of LMs
%       nx:  Number of regressors (x)
%       nz:  Number of regressors (z)
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 16-November-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

% 30.09.11 change to static function
% 08.11.11 case 'sparsePolynomial' implemented
% 16.11.11 help/doc updated (TE)

switch regressorType
    case 'polynomial'
        exponentMatrix = buildPolynomialExponentMatrix(regressorDegree,numInputs);
    case 'sparsePolynomial'
        exponentMatrix = [];
        for degreeIdx = 1:regressorDegree
            exponentMatrix = [exponentMatrix; degreeIdx*eye(numInputs)];
        end
    otherwise
        error('regressor:buildExponentMatrix','This type of trail function for the regressor is not implemented!')
end

end

%% subfunctions
function exponentMatrix = buildPolynomialExponentMatrix(polynomialDegree,numInputs)
% BUILDPOLYNOMIALEXPONENTMATRIX is used to build a full polynom
%
% polynomialDegree:	(1 x 1)	degree of the polynomial
%
% numInputs:       	(1 x 1)	specifies the number of physical inputs
%                          	for the exponent matrix

if ~isscalar(polynomialDegree)
    error('mod:BuildFullExponentMatrix','<polynomialDegree> should be a scalar!')
end

if polynomialDegree == 0
    exponentMatrix = 0;
else
    exponentMatrix = zeros(1,numInputs);
    pointer = 0;
    
    % organized from end to 1
    %     while exponentMatrix(end,1) < polynomialDegree % as long as the first entry of the exponent matrix is not equal to maximal dimension
    %
    %         if sum(exponentMatrix(end,:)) < polynomialDegree
    %
    %             exponentMatrix(end,end-pointer) = exponentMatrix(end,end-pointer)+1;
    %             pointer = 0; % go back to right end
    %             if exponentMatrix(end,1) < polynomialDegree
    %                 exponentMatrix(end+1,:) = exponentMatrix(end,:); % copy last one
    %             end
    %
    %         else
    %
    %             exponentMatrix(end,end-pointer) = 0;
    %             pointer = pointer+1; % switch one to the left
    %
    %         end
    %
    %     end
    
    % organized from 1 to end
    while exponentMatrix(end,end) < polynomialDegree % as long as the last entry of the exponent matrix is not equal to maximal dimension
        if sum(exponentMatrix(end,:)) < polynomialDegree
            exponentMatrix(end,1+pointer) = exponentMatrix(end,1+pointer)+1;
            pointer = 0; % go back to right end
            if exponentMatrix(end,end) < polynomialDegree
                exponentMatrix(end+1,:) = exponentMatrix(end,:); % copy last one
            end
        else
            exponentMatrix(end,1+pointer) = 0;
            pointer = pointer+1; % switch one to the left
        end
    end
end

end

