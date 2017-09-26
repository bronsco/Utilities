function numbers = randMat(a, b, method, n, newseed)
% randMat: Generates a matrix of random numbers with uniform or normal
% distribution on a specified interval [a,b] or with a specific mean (a) 
% and variance (b) for any number of a,b pairs. For uniform distributions,
% the values returned by the MATLAB function rand() are multiplied by 
% (b-a), then added to a. For normal distributions the output of randn() is 
% multiplied by the standard deviation (b), and then added to the desired 
% to the mean (a).
%
% Arguments: (input)
%
%   a - (i x 1) row vector of values specifying the lower limit in each
%       interval or mean value of the normal distribution.
%
%   b - (i x 1) row vector of values specifying the higher limit in each
%       interval or variance of the normal distribution.
%
%   method - (i x 1) row vector of integers to indicate normal or uniform 
%            distribution for each corresponding a,b pair, 0 indicates a
%            uniform distribution, 1 indicates a normal distribution.
%
%   n - scalar, number of random numbers to be output for all desired
%       distributions.
%
%   newseed - optional scalar, if 1, a new seed is generated from the
%             system clock, if 0 the existing sequence is used. If omitted,
%             the default value is zero.
%
% Arguments: (output)
%   
%   numbers - (i x n) matrix of random numbers generated for each a,b pair
%             in the input arguments. Each a,b pair's corresponding output is
%             represented by a column of n random numbers. 

    if size(a,1) ~= size(b,1)

        error('a and b are not of the same size')

    elseif size(a,1) ~= size(method,1)

        if isscalar(method)
            method = repmat(method,size(a));
        else
            error('method is not scalar or the same size as a')
        end

    elseif size(b,1) ~= size(method,1)

        if isscalar(method)
            method = repmat(method,size(a));
        else
            error('method is not scalar or the same size as b')
        end
    end

    if nargin == 4 || (nargin > 4 && newseed == 1)
        % Initialise the state of the pseudorandom number generator to
        % ensure unique numbers are produced
        rand('state',sum(100*clock));
    end

    for i = 1:size(a,1)
        if method(i,1) == 0
            numbers(1:n,i) = a(i,1) + (b(i,1)-a(i,1)) * rand(n,1);
        elseif method(i,1) == 1
            numbers(1:n,i) = a(i,1) + sqrt(b(i,1)) * randn(n,1);
        else
            error('method value must be 0 or 1, see help for details')
        end
    end

end