%% Scene Identification Using Image Data
% Image classification involves determining if an image contains some 
% specific object, feature, or activity. The goal of this example is to
% provide a strategy to construct a classifier that can automatically 
% detect which scene we are looking at
% This example uses function from the Computer Vision System Toolbox and
% Statistics and Machine Learning
% Copyright (c) 2016, MathWorks, Inc.

%% Description of the Data
% The dataset contains 4 scenes: Field, Auditorium, Beach ,Restaurant
% The images are photos of the scenes that have been taken from different
% angles, positions, and different lighting conditions. These variations make 
% this a challenging task.
%%%
%% 
% Data needs to be downloaded in order for this demo to run
% Please use your own data or download a database online
% Here's an example of a good source of scene data
% http://groups.csail.mit.edu/vision/SUN/

%% Load image data
% This assumes you have a directory: Scene_Categories
% with each scene in a subdirectory
imds = imageDatastore('Scene_Categories',...
    'IncludeSubfolders',true,'LabelSource','foldernames')              %#ok

%% Display Class Names and Counts
tbl = countEachLabel(imds)                                             %#ok
categories = tbl.Label;

%% Display Sampling of Image Data
sample = splitEachLabel(imds,16);

montage(sample.Files(1:16));
title(char(tbl.Label(1)));

%% Show sampling of all data
for ii = 1:4
    sf = (ii-1)*16 +1;
    ax(ii) = subplot(2,2,ii);
    montage(sample.Files(sf:sf+3));
    title(char(tbl.Label(ii)));
end
% expandAxes(ax); % this is an optional feature, 
% you can download this from the fileexchange as well!
%% Pre-process Training Data: *Feature Extraction using Bag Of Words*
% Bag of features, also known as bag of visual words is one way to extract 
% features from images. To represent an image using this approach, an image 
% can be treated as a document and occurance of visual "words" in images
% are used to generate a histogram that represents an image.
%% Partition 700 images for training and 200 for testing
[training_set, test_set] = prepareInputFiles(imds);

%% Create Visual Vocabulary 
tic
bag = bagOfFeatures(training_set,...
    'VocabularySize',250,'PointSelection','Detector');
scenedata = double(encode(bag, training_set));
toc
return;
%% Visualize Feature Vectors 
img = read(training_set(1), randi(training_set(1).Count));
featureVector = encode(bag, img);

subplot(4,2,1); imshow(img);
subplot(4,2,2); 
bar(featureVector);title('Visual Word Occurrences');xlabel('Visual Word Index');ylabel('Frequency');

img = read(training_set(2), randi(training_set(2).Count));
featureVector = encode(bag, img);
subplot(4,2,3); imshow(img);
subplot(4,2,4); 
bar(featureVector);title('Visual Word Occurrences');xlabel('Visual Word Index');ylabel('Frequency');

img = read(training_set(3), randi(training_set(3).Count));
featureVector = encode(bag, img);
subplot(4,2,5); imshow(img);
subplot(4,2,6); 
bar(featureVector);title('Visual Word Occurrences');xlabel('Visual Word Index');ylabel('Frequency');

img = read(training_set(4), randi(training_set(4).Count));
featureVector = encode(bag, img);
subplot(4,2,7); imshow(img);
subplot(4,2,8); 
bar(featureVector);title('Visual Word Occurrences');xlabel('Visual Word Index');ylabel('Frequency');

%% Create a Table using the encoded features
SceneImageData = array2table(scenedata);
sceneType = categorical(repelem({training_set.Description}', [training_set.Count], 1));
SceneImageData.sceneType = sceneType;

%% Use the new features to train a model and assess its performance using 
classificationLearner

%% Can we look at Beaches and Fields and see why they are misidentified?
jj = randi(randi(training_set(ii).Count));
imshowpair(read(training_set(2),jj),read(training_set(3),jj),'montage')
title('Beaches vs. Fields');

%% Test out accuracy on test set!

testSceneData = double(encode(bag, test_set));
testSceneData = array2table(testSceneData,'VariableNames',trainedClassifier.RequiredVariables);
actualSceneType = categorical(repelem({test_set.Description}', [test_set.Count], 1));

predictedOutcome = trainedClassifier.predictFcn(testSceneData);

correctPredictions = (predictedOutcome == actualSceneType);
validationAccuracy = sum(correctPredictions)/length(predictedOutcome) %#ok

%% Visualize how the classifier works
ii = randi(size(test_set,2));
jj = randi(test_set(ii).Count);
img = read(test_set(ii),jj);

imshow(img)
% Add code here to invoke the trained classifier
imagefeatures = double(encode(bag, img));
% Find two closest matches for each feature
[bestGuess, score] = predict(trainedClassifier.ClassificationSVM,imagefeatures);
% Display the string label for img
if strcmp(char(bestGuess),test_set(ii).Description)
	titleColor = [0 0.8 0];
else
	titleColor = 'r';
end
title(sprintf('Best Guess: %s; Actual: %s',...
	char(bestGuess),test_set(ii).Description),...
	'color',titleColor)

