function p = polyVec2polyfit(indepvar, depvar, polyVec)
% polyVec2polyfit: converts an individual polynomial form in the format
% used by gapolyfitn to a full regression model
%
% Input:
%
%  indepvar - (n x p) array of independent variables as columns
%             n is the number of data points
%             p is the dimension of the independent variable space
%
%  depvar   - (n x 1 or 1 x n) vector - dependent variable
%             length(depvar) must be n. Only 1 dependent variable is
%             allowed
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
% Output;
%
%  polymodel - A structure containing the regression model in the format
%              produced by polyfitn by John D'Erico
%              polymodel.ModelTerms = list of terms in the model
%              polymodel.Coefficients = regression coefficients
%              polymodel.ParameterVar = variances of model coefficients
%              polymodel.ParameterStd = standard deviation of model
%              coefficients
%              polymodel.R2 = R^2 for the regression model 
%              polymodel.RMSE = Root mean squared error 
%              polymodel.VarNames = Cell array of variable names as parsed
%              from a char based model specification.
%  
%
% Author:   Richard Crozier
% Release Date: 06 OCT 2009
%      

    % determine the number of independent variables
    vars = size(indepvar,2);
    
    % reshape the polynomial to conform to polyfitn specifications
    polyVec = reshape(polyVec',vars+1,[])';
    
    % find and remove empty terms
    [row, col] = find(polyVec(:,1) == 0);

    polyVec(row,:) = [];

    % remove coefficient/placeholder values, leaving only power terms
    polyVec(:,1) = [];

    % If this leaves nothing, use a term made up of all zeros, i.e. a
    % constant only as polyfitn does not accept empty matrices
    if isempty(polyVec)
        polyVec = zeros(1,vars);
    end
    
    % Evaluate the polynomials by performing a least squares fit to
    % find the best possible coefficients and RMSE
    p = polyfitn(indepvar,depvar,double(polyVec));
    
end