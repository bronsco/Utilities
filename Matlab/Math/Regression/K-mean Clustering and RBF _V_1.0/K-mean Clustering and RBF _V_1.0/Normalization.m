function [NX]=Normalization(X,D);
%% Function for Normalization of Data
% Two different approaches for converting features to comparable scale 

% 1 -- Min-Max-Scaling makes all data fall into range [0, 1]
% 2 -- Z-score conversion make center data on '0' scale data so majority falls into range [-1, 1]

if nargin>1
%% Min-Max-Scaling makes all data fall into range [0, 1]
Xmin=min(X);
Xmax=max(X);
NX=(X-repmat(Xmin,size(X,1),1))./repmat((Xmax-Xmin),size(X,1),1);
else
%% Z-score conversion make center data on '0' scale data so majority falls into range [-1, 1]
Xmean=mean(X);
Xstd=std(X);
NX=(X-repmat(Xmean,size(X,1),1))./(repmat(Xstd,size(X,1),1));
end