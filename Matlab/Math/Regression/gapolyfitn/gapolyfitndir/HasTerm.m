function res = HasTerm(p1, p2, newTerm, vars)
% HasTerm.m
%
% A function for determining whether either of two polynomials contain a
% given term group. This function ignores coefficients of the polynomials and
% looks only at the groups of power terms.
%
% Input:
%
%   p1 - First polynomial. Polynomials are described as vectors with the
%        following format:
% 
%       [ a1 p11 p12 p13 a2 p21 p22 p23 ... an pn1 pn2 pnj ]
%
%       e.g. x^2y + x + xy + 5 would be:
%
%       [ 1 2 1 1 1 0 1 1 1 5 0 0 ]
%
%       This vector can be of any length provided these conventions are
%       observed
%
%   p2 - Second polynomial in same form. This does not have to be of the
%        same length as p1, but must conform to the same scheme, i.e. have
%        the same number of variables.
%
%   newTerm - single polynomial term in same format as the other
%             polynomials terms, e.g. to find if the term x^2y in the
%             previous polynomial example you would use:
%
%                       [1 2 1]
%             As we only compare power terms the constant (1 in this case)
%             will be ignored, i.e. the following examples would also give
%             a positive result:
%
%             [0 2 1]  or  [0.245646 2 1] or [1000 2 1]
%
%   vars - The number of variables in the polynomials, this is 2 for the
%          examples above.
%
% Output:
%
%   res - Scalar, if 0, the term does not already exist. If 1, the term
%         exists in the first polynomial, if 2, the term exists in the
%         second polynomial. If 3, the term exists in both polynomials
%


    if isempty(p1)

        res(1) = 0;

    else
        
        p1 = reshape(p1',vars+1,[])';

        if any(all(bsxfun(@eq, p1(:,2:end), newTerm(2:end)), 2))
            res(1) = 1;
        else
            res(1) = 0;
        end

    end

    if isempty(p2)

        res(2) = 0;

    else
        
        p2 = reshape(p2',vars+1,[])';

        if any(all(bsxfun(@eq, p2(:,2:end), newTerm(2:end)), 2))
            res(2) = 2;
        else
            res(2) = 0;
        end

    end

    res = sum(res);
    
    
%     if size(p1,2) == 0
%         res = 0;
%     else
% 
%         res = 0;
% 
%         % First we reshape the polynomial vectors to (n x (vars+1)) matrix,
%         % where n is the total number of terms
%         p1 = reshape(p1',vars+1,[])';
%         p2 = reshape(p2',vars+1,[])';
% 
%         % Next we remove the placeholder values at the start of each matrix
%         p1(:,1) = [];
%         p2(:,1) = [];
% 
%         % The new terms are replicated to the same size as the p1 and p2
%         % matrices
% %         newTerm1 = repmat(newTerm(2:end), size(p1,1), 1);
% %
% %         newTerm2 = repmat(newTerm(2:end), size(p2,1), 1);
% 
%         % We test by
% %         test1 = sum(newTerm1 == p1, 2);
% %
% %         test2 = sum(newTerm2 == p2, 2);
% 
% %         if any(test1 == vars) && any(test2 == vars)
% %             res = 3;
% %         elseif any(test1 == vars)
% %             res = 1;
% %         elseif any(test2 == vars)
% %             res = 2;
% %         end
% 
%         test1 = 0;
%         test2 = 0;
% 
%         for i = 1:size(p1,1)
%             if sum(newTerm(2:end) == p1(i,:), 2) == vars
%                 test1 = 1;
%                 break;
%             end
%         end
% 
%         for i = 1:size(p2,1)
%             if sum(newTerm(2:end) == p2(i,:), 2) == vars
%                 test2 = 2;
%                 break;
%             end
%         end
% 
%     end

end


