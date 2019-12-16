function NewChrom = recpoly(OldChrom, polyStruct)
% recpoly.m       (RECombination POLYnomial)
%
% This function performs term group recombination between pairs of
% polynomial individuals and returns the new individuals after mating.
%
% Syntax:  NewChrom = recpoly(OldChrom, polyStruct)
%
% Input parameters:
%    OldChrom  - Matrix containing the chromosomes of the old
%                population. Each line corresponds to one
%                individual
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
% Output parameter:
%
%    NewChrom  - Matrix containing the chromosomes of the population
%                after mating, ready to be mutated and/or evaluated,
%                in the same format as OldChrom.
%
%  Author:    Richard Crozier
%  History:   11.11.2008    file created
    
    a = zeros(polyStruct.maxTerms,1);
    b = ones(polyStruct.maxTerms,1);
    method = a;
    myRands = randMat(a,b,method,size(OldChrom,1));
    
    vars = polyStruct.vars;
    NewChrom = zeros(size(OldChrom), 'int16');
  
    for i = 1:2:size(OldChrom,1)
        
        if i == size(OldChrom,1)
            % If the number of individuals is odd, we can't mate the last
            % one, so we just return it to the population, bad luck big
            % fella.
            NewChrom(i,:) = OldChrom(i,:);
            return;
        end
        
        ChildTermCnt_1 = 1;
        ChildTermCnt_2 = 1;
        n = 1;
        % first allocate the first parents terms randomly, checking that
        % the terms exist first
        for j = 1:vars+1:size(OldChrom,2)
            
           if OldChrom(i,j) == 1
               
               newrand = rand(1,1);
               
               if (ChildTermCnt_2 > size(OldChrom,2) && ChildTermCnt_1 < size(OldChrom,2)) || newrand > myRands(i,n)
                   n = n + 1;
                   NewChrom(i,ChildTermCnt_1:ChildTermCnt_1+vars) = OldChrom(i,j:j+vars);
                   ChildTermCnt_1 = ChildTermCnt_1 + vars + 1;
               elseif (ChildTermCnt_1 > size(OldChrom,2) && ChildTermCnt_2 < size(OldChrom,2)) || newrand <= myRands(i,n)
                   n = n + 1;
                   NewChrom(i+1,ChildTermCnt_2:ChildTermCnt_2+vars) = OldChrom(i,j:j+vars);
                   ChildTermCnt_2 = ChildTermCnt_2 + vars + 1;
               else
                   error('more terms needed to be allocated, but both polynomials are full, this should not happen')
               end
                 
           end
            
        end
        
        % Now allocate the second parents terms, randomly if the term does
        % not already exist in the child chromosome
        
        n = 1; 
        for j = 1:vars+1:size(OldChrom,2)
           
           if OldChrom(i+1,j) == 1
              
               if ChildTermCnt_2 == 1 && ChildTermCnt_1 == 1
                   % no terms allocated yet (very strange?) so termTest = 0
                   termTest = 0;              
               elseif ChildTermCnt_1 == 1
                   % no terms allocated to child 1 yet, so use dummy
                   % chromosome part consisting of all -1 values
                   termTest = HasTerm((-1*ones(1,vars+1)), NewChrom(i+1,1:ChildTermCnt_2-1), OldChrom(i+1,j:j+vars), vars);
               elseif ChildTermCnt_2 == 1
                   % no terms allocated to child 2 yet, so use dummy
                   % chromosome part consisting of all -1 values
                   termTest = HasTerm(NewChrom(i,1:ChildTermCnt_1-1), (-1*ones(1,vars+1)), OldChrom(i+1,j:j+vars), vars);
               else
                   termTest = HasTerm(NewChrom(i,1:ChildTermCnt_1-1), NewChrom(i+1,1:ChildTermCnt_2-1), OldChrom(i+1,j:j+vars), vars);
               end
               
               newrand = rand(1,1);
               
               if (ChildTermCnt_2 > size(OldChrom,2) && ChildTermCnt_1 > size(OldChrom,2))
                   error('more terms needed to be allocated, but both polynomials are full, this should not happen')
                   
               elseif termTest == 3 || (termTest == 2 && ChildTermCnt_1 > size(OldChrom,2)) || (termTest == 1 && ChildTermCnt_2 > size(OldChrom,2))
                   % Either term is already in both polys (termTest == 3)
                   % Or the term is already in poly 2 (termTest == 2), but
                   % there is no more room in poly 1 (ChildTermCnt_1 >
                   % size(OldChrom,2)) to add it there
                   % Or the term is already in poly 1 (termTest == 1), but
                   % there is no more room in poly 2 (ChildTermCnt_2 >
                   % size(OldChrom,2)) to add it there
                   % So we discard the term, and move to the next one
                   n = n + 1;
               elseif (ChildTermCnt_2 > size(OldChrom,2) && ChildTermCnt_1 < size(OldChrom,2)) || termTest == 2 || (termTest == 0 && ChildTermCnt_1 < size(OldChrom,2) && newrand > myRands(i,n))
                   % If there is no room to append the term to the second
                   % polynomial, we allocate it to poly 1
                   % Or if termTest is 2 (i.e. the term already exists in
                   % the second child polynomial we allocate it to poly 1
                   % Or if a random number is greater than the previously
                   % generated random number for this term, we allocate
                   % it to poly 1
                   NewChrom(i,ChildTermCnt_1:ChildTermCnt_1+vars) = OldChrom(i+1,j:j+vars);
                   ChildTermCnt_1 = ChildTermCnt_1 + vars + 1;
                   n = n + 1;
               elseif (ChildTermCnt_1 > size(OldChrom,2) && ChildTermCnt_2 < size(OldChrom,2)) || termTest == 1 || (termTest == 0 && ChildTermCnt_2 < size(OldChrom,2) && newrand <= myRands(i,n))
                   % If there is no room to append the term to the first
                   % polynomial, we allocate it to poly 1 
                   % Or if termTest is 2 (i.e. the term already exists in
                   % the first child polynomial we allocate it to poly 2 
                   % Or if a random number is less than or equal to
                   % the previously generated random number for this
                   % term, we allocate it to poly 1
                   NewChrom(i+1,ChildTermCnt_2:ChildTermCnt_2+vars) = OldChrom(i+1,j:j+vars);
                   ChildTermCnt_2 = ChildTermCnt_2 + vars + 1;
                   n = n + 1;
               end
                 
           end
            
        end
        
    end

end


