function X = lhsdesign_abs(n,p,crit,iter,lb,ub)

% generate normalized design
xn = lhsdesign(n,p,'criterion',crit,'iterations',iter);
% map to bounds
X = bsxfun(@plus,lb,bsxfun(@times,xn,(ub-lb)));

end