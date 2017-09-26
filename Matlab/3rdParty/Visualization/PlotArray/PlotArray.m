function [ M ] = PlotArray( V,M )
%This function takes the vector corresponding to the additional series
%being added to a plot and the matrix corresponding to the series that have
%already been plotted, and makes them all the same length by filling
%columns with NaN as needed.
%The purpose of this function is to be able to combine series of different
%lengths so that they can be plotted simultaneously with a single plotting
%command
%
%Example
%
%  X= [0
%      1 
%      3
%      6
%      7
%      4];
%
%  M= [1 2 3 
%      4 5 6
%      7 8 9];
% 
%  Matrix=PlotArray(X,M)
%        
%        = 1   2   3   0
%          4   5   6   1
%          7   8   9   3
%          NaN NaN NaN 6
%          NaN NaN NaN 7
%          NaN NaN NaN 4
%
%Patrick Breach
%email: pbreach@uwo.ca

[~,b]=size(M);

if length(V)<length(M)
    Matrix=NaN(1,length(M));
    for i=1:length(V)
        Matrix(i)=V(i);
    end
    M(:,b+1)=Matrix;
elseif length(V)==length(M)
    M(:,b+1)=V;
else
    [a,b]=size(M);
    Matrix=NaN(length(V),b+1);
    for i=1:b
        for j=1:a
            Matrix(j,i)=M(j,i);
        end
    end
    for i=1:length(V)
        Matrix(i,b+1)=V(i);
    end
    M=Matrix;
end


end

