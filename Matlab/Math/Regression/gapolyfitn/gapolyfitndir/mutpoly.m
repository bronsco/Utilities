function NewChrom = mutpoly(OldChrom, polyStruct, mVars)
% mutpoly.m
%
% This function takes the representation of the current population,
% mutates each element with given probability and returns the resulting
% population.
%
% Syntax:	NewChrom = mut(OldChrom,polyStruct,Gen)
%
% Input parameters:
%
%	OldChrom - A matrix containing the chromosomes of the
%              current population. Each row corresponds to
%              an individuals string representation.
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
%	mVars - Vector containing mutation rate and generation number
%           mVars(1): MutR - number containing the mutation rate -
%
%           mVars(2): Gen - generation number, used to shrink the
%                     mutation rate for later generations.
%
%           The mutation rate is then calculated according to:
%
%           x = (MutR/100) * e^(-0.002882*(Gen-1))
%
% Output parameter:
%
%		NewChrom - A Matrix containing a mutated version of
%                   OldChrom.
%
     
    x = randMat(0, 1, 0, size(OldChrom,1),1) < ((mVars(1))*exp(-0.002882*(mVars(2)-1)));

    NewChrom = OldChrom;
    
    for i = 1:size(OldChrom,1)
        % First check if there are any empty term slots
        ind = find(OldChrom(i,1:polyStruct.vars+1:end-(polyStruct.vars))==0);

        if x(i,1) == 1 && ~isempty(ind)    
            % insert new term in first empty slot

            % Generate a new term for the polynomial
            NewTerm = GenerateNewTerm(polyStruct.vars, polyStruct.maxPower, OldChrom(i,:));
            
            % Get the real position of the first empty slot
            ind = (ind(1)-1)*(polyStruct.vars+1)+1;
            
            % Insert the new term
            NewChrom(i,ind:ind+polyStruct.vars) = NewTerm;
            
        elseif x(i,1) == 1 && isempty(ind)      
            % swap with existing term in chromosome
            
            NewTerm = GenerateNewTerm(polyStruct.vars, polyStruct.maxPower, OldChrom(i,:));
            
            % randomly pick a term to swap
            k = round(randMat(1, polyStruct.maxTerms - 1, 0, 1)) * (polyStruct.vars+1) + 1;
            
            NewChrom(i,k:k+polyStruct.vars) = NewTerm;
        
        end
        
    end
    
end