function regression_example()
% A example code that runs a regression algorithm on the Car dataset.
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

%% Loading Car Dataset
load imports-85

% numerical class variable
feat_num = X(:,[5, 6, 7, 8]);
featName = {'width', 'height', 'curb_weight', 'engine_size'};
class_num = X(:,15); %price

% Choosing a regression tool to be used
% -------------------------------------
% classifier = 1: Random Forest
% classifier = 2: J48 Decision Tree
% classifier = 3: Support Vector Machine with PuK Kernel
% classifier = 4: Logistic Regression

classifier = 1;

%% Performing K-fold Cross Validation
K = 10;
N = size(feat_num,1);
%indices for cross validation
idxCV = ceil(rand([1 N])*K); 

actualClass = zeros(size(feat_num,1),1);
predictedClass = zeros(size(feat_num,1),1);
for k = 1:K
    %defining training and testing sets
    feature_train = feat_num(idxCV ~= k,:);
    class_train = class_num(idxCV ~= k,1);
    feature_test = feat_num(idxCV == k,:);
    class_test = class_num(idxCV == k,1);
    
    %performing regression
    [actual_tmp, predicted_tmp, stdDev_tmp] = wekaRegression(feature_train, class_train, feature_test, class_test, featName, classifier);
    
    %accumulating the results
    actualClass(idxCV == k,:) = actual_tmp;
    predictedClass(idxCV == k,:) = predicted_tmp;    
    clear feature_train class_train feature_test class_test
    clear actual_tmp predicted_tmp probDistr_tmp
end
clear idxCV k

figure;
scatter(actualClass, predictedClass);
xlabel('Actual Price');
ylabel('Predicted Price');
