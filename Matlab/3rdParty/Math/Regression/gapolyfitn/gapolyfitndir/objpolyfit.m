function ObjVal = objpolyfit(Chrom, rtn_type, polyStruct)
% objpolyfit: This function implements the polynomial form optimisation
% algorithm
%
% Syntax:  ObjVal = objpolyfit(Chrom, rtn_type, polyStruct)
%
% Input parameters:
%    Chrom      - Matrix containing the chromosomes of the current
%                 population. Each row corresponds to one individual's
%                 string representation.
%                 if Chrom == [], then special values will be returned
%
%    rtn_type   - if Chrom == [] and
%                 rtn_type == 1 (or []) return boundaries
%                 rtn_type == 2 return title
%                 rtn_type == 3 return value of global minimum
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
%
% Output parameters:
%    ObjVal    - Column vector containing the objective values of the
%                individuals in the current population.
%                if called with Chrom == [], then ObjVal contains
%                rtn_type == 1, matrix with the boundaries of the function
%                rtn_type == 2, text for the title of the graphic output
%                rtn_type == 3, value of global minimum
%                
%
% Author:   Richard Crozier
% Release Date: 06 OCT 2009
%

% Compute population parameters
   [Nind,Nvar] = size(Chrom);

    Dim = polyStruct.maxTerms * (polyStruct.vars+1);
   
% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % return text of title for graphic output
      if rtn_type == 2
         ObjVal = ['GA POLYFIT - ' int2str(polyStruct.maxTerms), 'TERMS'];
      % return value of global minimum
      elseif rtn_type == 3
         ObjVal = 0;
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables, this is
         % really provided for compatibility as the actiual upper bound is
         % determined by polyStruct.maxPower    
         ObjVal = repmat([0 repmat(0,1,polyStruct.vars);...
                          1 repmat(polyStruct.maxPower,1,polyStruct.vars)],1,polyStruct.maxTerms);
      end
      
   % if Dim variables, compute values of function
   elseif Nvar == Dim
       
       % Initialise the objective values column vector
       ObjVal = zeros(size(Chrom,1),1);
   
       % Evaluate the polynomials by performing a least squares fit on each
       % one to find the best possible coefficients and RMSE
       for i = 1:size(Chrom,1)
           %tic
           ObjVal(i,1) = PolyFitScore(Chrom(i,:), polyStruct);
           %toc
       end

   else
      error('size of matrix Chrom is not correct for function evaluation');
   end

end







