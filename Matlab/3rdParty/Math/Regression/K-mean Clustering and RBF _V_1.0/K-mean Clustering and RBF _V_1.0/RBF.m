%% Author : Shujaat Khan , Email : Shujaat123@gmail.com
% The program is the implementation of Radial Basis Function for
% Classification task Using K-Mean Clustering 
clc
clear all
close all

%% Example # 1
% X=[0.5 0.4 0.6 0.6 0.8 0.2 0.1 0.9 0.8 0.3;...
%     0.7 0.5 0.6 0.4 0.6 0.8 0.7 0.3 0.1 0.1]'; % Training Data
% T=[0 0 0 0 0 1 1 1 1 1]'; % Target Classes 
% M=8; % K-Means

%% Example # 2
load ProjectedImages % Loading Data
X=ProjectedImages; % Test data with know class labels
X=Normalization(X,1); % Normalization of data for [0 1] scale
% X=Normalization(X); % Normalization of data for center 0 and maximum density in [-1 1] range
NC=40; % Number of Classes
NS=10; % Number of Subjects
T=Class_IDs(NC,NS); % Class IDs Function
M=80; % Increase Number fo K means for better results


C=K_Means(X,M,1); % K-Mean Clustering with animation
close all % for closing animation
% C=K_Means(X,M); % K-Mean Clustering without animation

[K]=Kernel(X,C); % Kernal Matrix

% Solution of K*W=T using Pseudo Inverse technique
% Multiply K' on Both sides to get K'*K*W=K'*T
% Multiply with the inverse of (K'*K) on Both sides to get W=inv(K'*K)*K'*T
% lamda=inv(K'*K)*K';
% W=lamda*T;
W=inv(K'*K)*K'*T;
G=K*W; % Training State to compare with desired Target Matrix T
G=round(G);

Results=(1-(length(find((T-G)~=0))/(size(T,1))))*100;
display(sprintf('\nClassification fitness %.2f%%',Results)); 