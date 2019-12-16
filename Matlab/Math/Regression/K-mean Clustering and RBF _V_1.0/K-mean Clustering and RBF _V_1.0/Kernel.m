function [K]=Kernel(X,C)
%% Function for Creating Kernal Matrix
% X is the Data Matrix
% C contains centers of Data
% K is the desired Kernal Matrix
K=[];
for i=1:size(X,1)
    for j=1:size(C,1)
    K(i,j)=exp(-norm(X(i,:)-C(j,:))); % using exponential Kernal function
    end
end