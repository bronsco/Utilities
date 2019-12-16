function score = PolyFitScore(polyVec, polyStruct)
% PolyFitScore: scores the polynomial fit to the data based on several
% options 
%
% Input:
%
%   polyVec - Individual's chromosome encoded in the same manner as in the
%             Chrom matrix (see gapolyfitn help) i.e. with the following
%             format:
%
%             [A p11 p12 p1n A p21 p22 p2n A p31 p32 pkn ... ]
%
%             Where A is a placeholder value with value 1 or 0. If 1 the
%             term is active and will be used, if 0 the term is inactive
%             and will not be used (it will be deleted before performing a
%             regression). The p values are the powers of each variable in
%             that term.
%
%             e.g.
%
%              A        A        A        A
%             [1 2 4 4  1 3 1 5  0 6 2 2  1 0 4 0]
%
%             encodes:
%
%             a1*x1^2*x2^4*x3^4 + a2*x1^3*x2*x3^5 + a3*x2^4
%                
%             As the third term is inactive due to a zero in the
%             placeholder position (shown above) and hence is ignored.
%             Terms should not be repeated to avoid least square algoithm
%             being overspecified
%
%             These are transformed into a fomat suitable for polyfitn to
%             perform generate a regression model.
%
%    polyStruct - A structure containing information about the polynomial
%                 to be fitted. There should be five members:
%
%                 tVars: column matrix of the independent variables of the
%                 data to be fitted
%
%                 tData: column vector the dependent variables
%
%                 vars: the number of variables (i.e. size(tVars,2))
%
%                 maxTerms: the maximum number of term groups to be used
%
%                 maxPower: the total maximum power of any term (i.e. the
%                 maximum that the sum of all of the powers in a term can
%                 be)
%
%                 scoremethod: scalar integer denoting the scoring method
%                 to use, the folllowing options are available
%                   1 - mean squared error (mse)  
%                   2 - normalised mean squared error (nmse)
%                   3 - root mean squared error (rmse)
%                   4 - normalised root mean squared error (nrmse)
%                   5 - mean absolute error (mae)
%                   6 - mean  absolute relative error  (mare)
%                   7 - coefficient of correlation (r)
%                   8 - coefficient of determination (r2)
%                   9 - coefficient of efficiency (e)
%                   10 - maximum absolute error 
%                   11 - maximum absolute relative error (mxare) 
% 
% Output:
%
%   score - polynomial fit score based on the method chosen in
%           polyStruct.scoremethod
%
%
% Author:   Richard Crozier
% Release Date: 06 OCT 2009
%

    % reshape the polynomial to conform to polyfitn specifications
    polyVec = reshape(polyVec',polyStruct.vars+1,[])';

    % find and remove empty terms
    [row, col] = find(polyVec(:,1) == 0);

    polyVec(row,:) = [];

    % remove coefficient/placeholder values, leaving only power terms
    polyVec(:,1) = [];

    if isempty(polyVec)
        polyVec = zeros(1,size(polyStruct.tVars,2));
    end
    
    % Evaluate the polynomials by performing a least squares fit to
    % find the best possible coefficients and RMSE
    p = polyfitn(polyStruct.tVars,polyStruct.tData,double(polyVec));
    
    if ~isfield(polyStruct, 'fitTestData') || ~isfield(polyStruct, 'fitTestVars')
        
        switch polyStruct.scoremethod

            case 1
                % mean squared error (mse)
                score = gfit2(polyStruct.tData,polyvaln(p,polyStruct.tVars),'1');
            case 2
                % normalised mean squared error (nmse)
                score = gfit2(polyStruct.tData,polyvaln(p,polyStruct.tVars),'2');
            case 3
                % root mean squared error (rmse)
                score = p.RMSE;
            case 4
                % normalised root mean squared error (nrmse)
                score = gfit2(polyStruct.tData,polyvaln(p,polyStruct.tVars),'4');
            case 5
                % mean absolute error (mae)
                score = gfit2(polyStruct.tData,polyvaln(p,polyStruct.tVars),'5');
            case 6
                % mean  absolute relative error  (mare)
                score = gfit2(polyStruct.tData,polyvaln(p,polyStruct.tVars),'6');
            case 7
                % coefficient of correlation (r)
                score = 1 - gfit2(polyStruct.tData,polyvaln(p,polyStruct.tVars),'7');
            case 8
                % coefficient of determination (r-squared)
                score = 1 - p.R2;
            case 9
                % coefficient of efficiency (e)
                score = gfit2(polyStruct.tData,polyvaln(p,polyStruct.tVars),'9');
            case 10
                % maximum absolute error
                score = gfit2(polyStruct.tData,polyvaln(p,polyStruct.tVars),'10');
            case 11
                % maximum absolute relative error (mxare)
                score = gfit2(polyStruct.tData,polyvaln(p,polyStruct.tVars),'11');
            otherwise
                error('Unknown scoring method, should be integer between 1-11')
        end

    else
        % if extra data is provided, test fit with all the data
        switch polyStruct.scoremethod

            case 1
                % mean squared error (mse)
                score = gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'1');
            case 2
                % normalised mean squared error (nmse)
                score = gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'2');
            case 3
                % root mean squared error (rmse)
                score = gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'3');
            case 4
                % normalised root mean squared error (nrmse)
                score = gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'4');
            case 5
                % mean absolute error (mae)
                score = gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'5');
            case 6
                % mean  absolute relative error  (mare)
                score = gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'6');
            case 7
                % coefficient of correlation (r)
                score = 1 - gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'7');
            case 8
                % coefficient of determination (r-squared)
                score = 1 - gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'8');
            case 9
                % coefficient of efficiency (e)
                score = gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'9');
            case 10
                % maximum absolute error
                score = gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'10');
            case 11
                % maximum absolute relative error (mxare)
                score = gfit2([polyStruct.tData; polyStruct.fitTestData],polyvaln(p,[polyStruct.tVars; polyStruct.fitTestVars]),'11');
            otherwise
                error('Unknown scoring method, should be integer between 1-11')
        end

    end

end