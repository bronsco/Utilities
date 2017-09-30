%This is an example demonstrating the Radial Basis Function.
%If you select a RBF that supports it (Gausian, or 1st or 3rd order
%polyharmonic spline), this also calculates a line integral between two
%points.

%
%Copyright (c) 2014, Travis Wiens
%All rights reserved.
%
%Redistribution and use in source and binary forms, with or without 
%modification, are permitted provided that the following conditions are 
%met:
%
%    * Redistributions of source code must retain the above copyright 
%      notice, this list of conditions and the following disclaimer.
%    * Redistributions in binary form must reproduce the above copyright 
%      notice, this list of conditions and the following disclaimer in 
%      the documentation and/or other materials provided with the distribution
%      
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%POSSIBILITY OF SUCH DAMAGE.
%
% If you would like to request that this software be licensed under a less
% restrictive license (i.e. for commercial closed-source use) please
% contact Travis at travis.mlfx@nutaksas.com

rng(0);

N_dim=2;%number of dimensions in input (1 or 2 for this example)

N_t=10;%number of training points

X_t=rand(N_t,N_dim);%training input
Y_t=rand(N_t,1);%training output

basisfunction='polyharmonicspline';%'gaussian' or 'polyharmonicspline'

samecentres=true;%use the training data from the RBF centres?
%This is advisable for polyharmonic splines
if samecentres
    X_c=X_t;
    N_r=size(X_c,1);%number of RBF centres
else
    N_r=6;
    X_c=rand(N_r,N_dim);%pick RBF centres
end

k_i=3*ones(N_r,1);%this is a prescaler if Gaussian,
%otherwise it is the polyharmonic function order

[W]=train_rbf(X_t,Y_t,X_c,k_i,basisfunction);%train weights

N_plot=100*ones(1,N_dim);%number of points to calculate at
switch N_dim
    case 1
        X_plot=linspace(0,1,N_plot(1))';%points to calculate at
    case 2

        x_plot=linspace(0,1,N_plot(1))';
        y_plot=linspace(0,1,N_plot(2))';
        [x_mesh, y_mesh]=meshgrid(x_plot,y_plot);
        X_plot=[reshape(x_mesh,[],1) reshape(y_mesh,[],1)];
end

[Y_hat, phi]=sim_rbf(X_c,X_plot,W,k_i,basisfunction);

if (N_dim==2)&&(strcmp(basisfunction,'gaussian')||( strcmp(basisfunction,'polyharmonicspline')&&(all(k_i==1|k_i==3))))
    %check line integral
    int_flag=true;
    X1=rand(1,N_dim);%endpoints of line
    X2=rand(1,N_dim);


    N_numsoln=10000;%number of points in numerical solution


    X_numsoln=[linspace(X1(:,1),X2(:,1),N_numsoln)' linspace(X1(:,2),X2(:,2),N_numsoln)'];

    Y_num=sim_rbf(X_c,X_numsoln,W,k_i,basisfunction);%calculate points along line

    d=sqrt(sum((X1-X2).^2));%distance along line

    Y_int_num=mean(Y_num)*d;%numerical integration along line

    Y_int_anal=rbfn_integral(X_c,X1,X2,W,k_i,basisfunction);%analytical integration

    fprintf('Numerical integration=%e\nAnalytical integration=%e\n',Y_int_num,Y_int_anal)
else
    int_flag=false;
end

figure(1)
clf
switch N_dim
    case 1
        plot(X_plot,Y_hat)
        hold on
        plot(X_t,Y_t,'k*')
        hold off

    case 2

        surf(x_plot,y_plot,reshape(Y_hat,N_plot(1),[]))

        shading interp
        hold on

        plot3(X_t(:,1),X_t(:,2),Y_t,'k*')
        if int_flag
            plot3(X_numsoln(:,1),X_numsoln(:,2),Y_num,'k')
            plot3([X1(:,1) X2(:,1)],[X1(:,2) X2(:,2)],Y_num([1 end]),'ko')
        end
        hold off
end

