function [C]=K_Means(X,M,D)
%% Function for Finding K-Means in the X data
% X is the Data Matrix
% M is the Number of Means Required (K)

temp=randperm(size(X,1));   % Random Permutation of Random index to pick data point
C=X(temp(1:M),:);           % Initial Guess for Centers is the random data point
J=[];                       % Cost Function to be minimized
k=1;                        % Iteration number
while(1)
    J(k)=0; 
    S=zeros(M,size(X,2));   % Sum of values fall in K Centers
    indeX=[];               % Index of the closest Center to the test data point
    for i=1:size(X,1)
        temp=0;             % temporary Variable for storing distance to centers
        for j =1:M
        temp(j)=(norm((X(i,:)-C(j,:))).^2);
        end
        [tmp,ind]=min(temp);  % Finding the closest Center for ith data point
        indeX=[indeX ind];  % Index of the closest Center to the test data point
        S(ind,:)=S(ind,:)+X(i,:);   % Sum of values fall in K Centers
        J(k)=J(k)+sum(temp); % Cost Function
    end
    for j=1:M
            N(j)=length(find(indeX==j)); % Number of Values closest to jth Center
    end
    
    Ctemp=[];   % Temporary Values for Center that will be updated only if different
    for l=1:size(X,2)
    Ctemp=[Ctemp S(:,l)./N'];
    end
    %% Check for update and stoping condition
    % Temporary Values for Center that will be updated only if different
    if(sum(sum(~(C==Ctemp)))~=0)
        C=Ctemp;
    else
        break
    end 
    %% Optional Animated Graph for Data only work if number of argument to function > 2
    % START
    if (nargin>2)
    scatter(X(:,1),X(:,2))
    hold on
    scatter(C(:,1),C(:,2),'filled')
    hold off
    pause(0.25)
    end
    % END
k=k+1;
end
%% Optional Graph for Cost only work if number of argument to function > 2
% START
if (nargin>2)
figure,plot(J)
xlabel('Iterations');
ylabel('Cost');
title('Cost Function');
end
% END