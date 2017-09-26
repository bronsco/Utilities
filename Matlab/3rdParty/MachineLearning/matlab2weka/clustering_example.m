function clustering_example()
% A example code that runs a clustering algorithm on the IRIS dataset.
% http://www.sunghoonivanlee.com
% Written by Sunghoon Ivan Lee, All copy rights reserved, 2/20/2015 
% Revised on 7/22/2015

clear all; close all;

%% Initializing 
% adding the path to matlab2weka codes
addpath([pwd filesep 'matlab2weka']);
% adding Weka Jar file
if strcmp(filesep, '\')% Windows    
    javaaddpath('C:\Program Files\Weka-3-6\weka.jar');
elseif strcmp(filesep, '/')% Mac OS X
    javaaddpath('/Applications/weka-3-6-12/weka.jar')
end
% adding matlab2weka JAR file that converts the matlab matrices (and cells)
% to Weka instances.
javaaddpath([pwd filesep 'matlab2weka' filesep 'matlab2weka.jar']);

%% Loading Iris Dataset
load iris

% numerical class variable
feat_num = iris(:,1:4);
featName = {'sepal length', 'sepal width', 'petal length', 'petal width'};
class_num = iris(:,5);

% Choosing a regression tool to be used
% -------------------------------------
% clusterer = 1: EM Clusterer from WEKA
% clusterer = 2: K-mean clusterer from WEKA
clusterer = 1;

% Choosing the number of clusters
% -------------------------------------
% numClusters = -1: if the number of clusters is not known
% numClusters > 0: the predefined number of clusters
numClusters = 3;

%% Performing Clustering Algorithm
[predicted, probDistr, numClusters] = wekaClustering(feat_num, featName, numClusters, clusterer);