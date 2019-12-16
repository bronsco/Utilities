function Chrom = crtpolyp(PopSize, polyStruct)
% crtpolyp: generates a new population of chromosomes made up of
% polynomial vectors suitable for the gapolyfit function
%
% Syntax:       Chrom = crtpolyp(PopSize,polyStruct);
%
% Input parameters:
%
%    Nind      - A scalar containing the number of individuals in the new 
%                population.
%
%    polyStruct - A structure containing information about the polynomial
%                 to be fitted. There should be five members: tVars: column
%                 matrix of the independent variables of the data to be
%                 fitted tData: column vector the dependent variables vars:
%                 the number of variables (i.e. size(tVars,2)) maxTerms:
%                 the maximum number of term groups to be used maxPower:
%                 the total maximum power of any term (i.e. the maximum
%                 that the sum of all of the powers in a term can be)
%              
% Output parameter:
%
%    Chrom     - Matrix containing the random valued individuals of the
%                new population of size Nind by number of variables.
%                Individuals are encoded as a series of integers with the
%                following format:
%
%                [A p11 p12 p1n A p21 p22 p2n A p31 p32 pkn ... ]
%               
%                Where A is a placeholder value with value 1 or 0. If 1 the
%                term is active and will be used, if 0 the term is inactive
%                and will not be used (it will be deleted before performing
%                a regression). The p values are the powers of each
%                variable in that term. Therefore the chromosome will have 
%                (polyStruct.vars + 1) * polyStruct.maxTerms columns and
%                PopSize rows, one for each individual.
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
%                Terms are not repeated to avoid least square algoithm
%                being overspecified
%
% Author:     Richard Crozier
    
    % Chromosome is initialized with zeros with the int16 format
    Chrom = zeros(PopSize, (polyStruct.vars+1)*polyStruct.maxTerms, 'int16');
    
    % The number of terms in each polynomial is chosen randomly
%     terms = round(randMat(1, polyStruct.maxTerms, 0, PopSize));
    terms = repmat(polyStruct.maxTerms, PopSize, 1);
    %h = waitbar(0, 'Creating Population');
    for i = 1:PopSize
        for j = 1:terms(i)
           chromInd = ((j-1) * (polyStruct.vars+1)) + 1;
           if chromInd == 1
               NewTerm = GenerateNewTerm(polyStruct.vars, polyStruct.maxPower);
               Chrom(i,chromInd:chromInd+polyStruct.vars) = NewTerm;
           else
               NewTerm = GenerateNewTerm(polyStruct.vars, polyStruct.maxPower, Chrom(i,1:chromInd-1));
               Chrom(i,chromInd:chromInd+polyStruct.vars) = NewTerm;
           end
        end
        %waitbar(i/PopSize,h)
    end
    %close(h)
    
end