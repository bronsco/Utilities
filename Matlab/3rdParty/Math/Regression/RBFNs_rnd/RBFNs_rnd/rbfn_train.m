function [W, MU, SIGMA]  = rbfn_train(F, C, K)

%% Random selection of Mu and Sigma
bias        = repmat(min(F)', 1, K);
scale       = repmat((max(F) - min(F))', 1, K);
MU          = scale .* rand(size(F, 2), K) + bias;
SIGMA       = rand(size(F, 2), size(F, 2), K) .* repmat(diag(var(F)), [1, 1, K]);
%% Train RBF (MU, SIGMA & K is Provided in last step)
N           = size(F,1);                  % n = Number of Pixels
H           = zeros(N,K);
for k       = 1:K
h           = RBFKernel(F,MU,SIGMA,N,k);
H(:,k)      = h;
end
A           = (inv(H'*H))*H';                            
W           = A*C;                        % Weight

end
