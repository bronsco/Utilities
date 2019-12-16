function costSensitiveClassifier_example()
% A example code that runs a cost-sensitive classification algorithm on the IRIS dataset.
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

% converting to nominal variables (Weka cannot classify numerical classes)
class_nom = cell(size(class_num));
uClass_num = unique(class_num);
tmp_cell = cell(1,1);
for i = 1:length(uClass_num)
    tmp_cell{1,1} = strcat('class_', num2str(i-1));
    class_nom(class_num == uClass_num(i),:) = repmat(tmp_cell, sum(class_num == uClass_num(i)), 1);
end
clear uClass_num tmp_cell i

% Choosing a regression tool to be used
% -------------------------------------
% classifier = 1: Random Forest Classifier from WEKA
% classifier = 2: Gaussian Process Regression from WEKA
% classifier = 3: Support Vector Machine from WEKA
% classifier = 4: Logistic Regression from WEKA
classifier = 1;

%% Performing K-fold Cross Validation
K = 10;
N = size(feat_num,1);
%indices for cross validation
idxCV = ceil(rand([1 N])*K);
actualClass = cell(size(feat_num,1),1);
predictedClass = cell(size(feat_num,1),1);
for k = 1:K
    %defining training and testing sets
    feature_train = feat_num(idxCV ~= k,:);
    class_train = class_nom(idxCV ~= k,1);
    feature_test = feat_num(idxCV == k,:);
    class_test = class_nom(idxCV == k,1);
	
	%defining cost matrix
	numClasses = length(unique(class_train));
	costMatrix = ones(numClasses, numClasses);
	for iclass = 1:numClasses
		costMatrix(iclass,iclass) = 0;
	end
	clear iclass numClasses;	
    
    %performing regression	
    [actual_tmp, predicted_tmp, probDistr_tmp] = wekaCostSensitiveClassification(feature_train, class_train, feature_test, class_test, featName, costMatrix, classifier);
    
    %accumulating the results
    actualClass(idxCV == k,:) = actual_tmp;
    predictedClass(idxCV == k,:) = predicted_tmp;    
    clear feature_train class_train feature_test class_test
    clear actual_tmp predicted_tmp probDistr_tmp
end
clear idxCV k
