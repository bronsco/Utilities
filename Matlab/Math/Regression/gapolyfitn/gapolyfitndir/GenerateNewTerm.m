function NewTerm = GenerateNewTerm(vars, maxPower, poly, maxLoops)
% GenerateNewTerm.m
%
% A function for generating new polynomial terms, ensuring the polynomial
% term does not exceed the desired total maximum power, and optionally,
% that it does not already exist in a supplied polynomial vector.
    
    if nargin < 4
        maxLoops = 1000;        
    end
    
    res = 1; 
    loopCount = 1;
    
    while res == 1 && loopCount < maxLoops
        
        % empty term
        NewTerm = [1 zeros(1, vars)];

        % generate new term
        for i = 2:(vars+1)
            % generate a new term member
            if sum(NewTerm(2:end)) < maxPower
                % New term members are only possible if the current terms
                % sum to less than the maximum power allowed
                NewTerm(i) = round(randMat(0, (maxPower-sum(NewTerm(2:end))), 0, 1, 0));
            else
                NewTerm(i) = 0;
            end
        end
        
        % now randomly shuffle term order to avoid any bias
        temp = NewTerm(2:end);
        NewTerm(2:end) = temp(randperm(length(temp)));
        
        % If the term has not randomly been chosen to be all zeros and a
        % polynomial to test has been supplied, we check the term does not
        % already exist in that polynomial
        if nargin > 2
            % Now check if term already exists in polynomial
            res = HasTerm(poly, [], NewTerm, vars);
        else
            res = 0;
        end
        
        loopCount = loopCount + 1;
        
    end
    
    if loopCount == maxLoops
        % Either a term which does not already exist cannot be found, or we
        % did not come up with a polynomial term that matched the criteria
        % within the maximum specified number of attempts (default 2000).
        % In this case a vector of zeros is returned. This will delete a
        % term if called by the mutation function.
        NewTerm = [ 0 repmat(0,1,vars)]; 
    end
    
    % return Newterm as 16 bit signed integer
    NewTerm = int16(NewTerm);
    
end