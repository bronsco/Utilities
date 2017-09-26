function NewChrom = mutatepoly(OldChrom, polyStruct, MutOpt, SUBPOP)
% mutatepoly     (high-level polynomial mutation function)
%
% This function takes a matrix OldChrom containing the representation of
% the individuals in the current population of polynomials, mutates the
% individuals and returns the resulting population.
%
% The function handles multiple populations and calls the low-level
% mutation function mutpoly for the actual mutation process.
%
% Syntax:  NewChrom = mutate(OldChrom, polyStruct, MutOpt, SUBPOP)
%
% Input parameter:
%
%    OldChrom  - Matrix containing the chromosomes of the old
%                population. Each line corresponds to one individual.
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
%	MutOpt - Vector containing mutation rate and generation number
%
%            MutOpt(1): MutR - number containing the mutation rate
%
%            MutOpt(2): Gen - generation number, used to shrink the
%                       mutation rate for later generations.
%
%            The mutation rate is then calculated according to:
%
%            rate = (MutR/100) * e^(-0.002882*(Gen-1))
%
%    SUBPOP - (optional) Number of subpopulations
%             if omitted or NaN, 1 subpopulation is assumed
%
% Output parameter:
%    NewChrom  - Matrix containing the chromosomes of the population
%                after mutation in the same format as OldChrom.
%
% Author:     Richard Crozier

% Check parameter consistency
   if nargin < 3
       error('Not enough input parameters')
   end

   % Identify the population size (Nind) and the number of variables (Nvar)
   [Nind,Nvar] = size(OldChrom);

   if nargin < 4
       SUBPOP = 1;
   elseif nargin > 3
      if isempty(SUBPOP)
          SUBPOP = 1;
      elseif isnan(SUBPOP)
          SUBPOP = 1;
      elseif length(SUBPOP) ~= 1
          error('SUBPOP must be a scalar'); 
      end
   end

   if (Nind/SUBPOP) ~= fix(Nind/SUBPOP)
       error('OldChrom and SUBPOP disagree'); 
   end
   
   Nind = Nind/SUBPOP;  % Compute number of individuals per subpopulation

% Select individuals of one subpopulation and call low level function
   NewChrom = [];
   for irun = 1:SUBPOP,
      ChromSub = OldChrom((irun-1)*Nind+1:irun*Nind,:);  
      NewChromSub = mutpoly(ChromSub, polyStruct, MutOpt);
      NewChrom=[NewChrom; NewChromSub];
   end

end