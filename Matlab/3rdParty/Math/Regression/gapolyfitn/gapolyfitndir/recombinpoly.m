function NewChrom = recombinpoly(Chrom, polyStruct, SUBPOP)
% recombimpoly: (polynomial recombination high-level function)
%
% This function performs recombination between pairs of polynomial
% individuals and returns the new individuals after mating. The function
% handles multiple populations and calls the low-level recombination
% function for the actual recombination process.
%
% Syntax:  NewChrom = recombin(OldChrom, polyStruct, SUBPOP)
%
% Input parameters:
%
%    Chrom     - Matrix containing initial population of individuals with
%                which to begin the GA search, must be of size
%                (options.NIND x (maxTerms*(size(indepvar,2)+1))). 
%                Individuals are encoded as a series of integers with the
%                following format:
%
%                [A p11 p12 p1n A p21 p22 p2n A p31 p32 pkn ... ]
%
%                Where A is a placeholder value with value 1 or 0. If 1 the
%                term is active and will be used, if 0 the term is inactive
%                and will not be used (it will be deleted before performing
%                a regression). The p values are the powers of each
%                variable in that term.
%
%                e.g.
%
%                 A        A        A        A
%                [1 2 4 4  1 3 1 5  0 6 2 2  1 0 4 0]
%
%                encodes:
%
%                a1*x1^2*x2^4*x3^4 + a2*x1^3*x2*x3^5 + a3*x2^4
%                
%                As the third term is inactive due to a zero in the
%                placeholder position (shown above) and hence is ignored.
%                Terms should not be repeated to avoid least square
%                algoithm being overspecified
%
%   polyStruct - A structure containing information about the polynomial
%                to be fitted. There should be five members:
%
%                tVars: column matrix of the independent variables of the
%                data to be fitted
%
%                tData: column vector the dependent variables
%
%                vars: the number of variables (i.e. size(tVars,2))
%
%                maxTerms: the maximum number of term groups to be used
%
%                maxPower: the total maximum power of any term (i.e. the
%                maximum that the sum of all of the powers in a term can
%                be)
%
%    SUBPOP    - (optional) Number of subpopulations
%                if omitted or NaN, 1 subpopulation is assumed
%
% Output parameter:
%    NewChrom  - Matrix containing the chromosomes of the population
%                after recombination in the same format as OldChrom.
%
%  Author:    Richard Crozier
%

% Check parameter consistency
   if nargin < 2
       error('Not enough input parameter'); 
   end

   % Identify the population size (Nind)
   [Nind,Nvar] = size(Chrom);
 
   if nargin < 3
       SUBPOP = 1; 
   end
   
   if nargin > 2
      if isempty(SUBPOP)
          SUBPOP = 1;
      elseif isnan(SUBPOP)
          SUBPOP = 1;
      elseif length(SUBPOP) ~= 1
          error('SUBPOP must be a scalar'); end
   end

   if (Nind/SUBPOP) ~= fix(Nind/SUBPOP)
       error('Chrom and SUBPOP disagree'); 
   end
   
   Nind = Nind/SUBPOP;  % Compute number of individuals per subpopulation

% Select individuals of one subpopulation and call low level function
   NewChrom = [];
   
   for irun = 1:SUBPOP
       
      ChromSub = Chrom((irun-1)*Nind+1:irun*Nind,:);
      
      NewChromSub = recpoly(ChromSub, polyStruct);
      
      NewChrom=[NewChrom; NewChromSub];
      
   end

end