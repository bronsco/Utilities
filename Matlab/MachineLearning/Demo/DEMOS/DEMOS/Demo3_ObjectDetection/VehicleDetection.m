%% Object Detection Using Faster R-CNN Deep Learning
% This example shows how to train an object detector using a deep learning
% technique named Faster R-CNN (Regions with Convolutional Neural
% Networks).
%
% Copyright 2017 The MathWorks, Inc.

%% Overview
% This example shows how to train a Faster R-CNN object detector for
% detecting vehicles. Faster R-CNN [1] is an extension of the R-CNN [2] and
% Fast R-CNN [3] object detection techniques. All three of these techniques
% use convolutional neural networks (CNN). The difference between them is
% how they select regions to process and how those regions are classified.
% R-CNN and Fast R-CNN use a region proposal algorithm as a pre-processing
% step before running the CNN. The proposal algorithms are typically
% techniques such as EdgeBoxes [4] or Selective Search [5], which are
% independent of the CNN. In the case of Fast R-CNN, the use of these
% techniques becomes the processing bottleneck compared to running the CNN.
% Faster R-CNN addresses this issue by implementing the region proposal
% mechanism using the CNN and thereby making region proposal a part of the
% CNN training and prediction steps.
% 
% In this example, a vehicle detector is trained using the
% |trainFasterRCNNObjectDetector| function from Computer Vision System
% Toolbox(TM). The example has the following sections:
%
% * Load the data set.
% * Design the convolutional Neural Network (CNN).
% * Configure training options.
% * Train Faster R-CNN object detector.
% * Evaluate the trained detector.

%% Show what we're trying to do
% Visualize Images: Notice they aren't already cropped

imageBrowser('vehicles');

%% Open up the Training Image Labeler App

% import vehicles folder, you can also import vehicleRois.mat into the 
% labeling session, which contains all of the rois for each image
% export the session with default configurations

trainingImageLabeler

%% note if you do not want to open the labeler app
% and you would rather simply import the ROIs, 
% run the 2 line of code directly below:

    data = load('fasterRCNNVehicleTrainingData.mat');
    vehicleDataset = data.vehicleTrainingData;

% The training data is now stored in a table. The first column contains the
% path to the image files. The remaining columns contain the ROI labels for
% vehicles.

% Display first few rows of the data set.
vehicleDataset(1:4,:)

%%
% Display one of the images from the data set to understand the type of
% images it contains.

% Read one of the images.
I = imread(vehicleDataset.imageFilename{10});

% Insert the ROI labels.
I2 = insertObjectAnnotation(I, 'Rectangle', vehicleDataset.vehicle{10}, 'Vehicle');

% Resize and display image.
figure;
imshowpair(imresize(I,3), imresize(I2, 3), 'montage');


%%
% Split the data set into a training set for training the detector, and a
% test set for evaluating the detector. Select 60% of the data for
% training. Use the rest for evaluation.

% Split data into a training and test set.
idx = floor(0.6 * height(vehicleDataset));
trainingData = vehicleDataset(1:idx,:);
testData = vehicleDataset(idx:end,:);

%% Create a Convolutional Neural Network (CNN)
% A CNN is the basis of the Faster R-CNN object detector. Create the CNN
% layer by layer using Neural Network Toolbox(TM) functionality.

% Either explain creating the CNN from scratch and training options
[layers,trainingOpts] = createCNN(width(vehicleDataset));

%% Train Faster R-CNN
% Now that the CNN and training options are defined, you can train the
% detector using |trainFasterRCNNObjectDetector|.

% A trained network is loaded from disk to save time when running the
% example. Set this flag to true to train the network. 
doTrainingAndEval = false;

if doTrainingAndEval
    % Set random seed to ensure example training reproducibility.
    rng(0);
    
    % Train Faster R-CNN detector. Select a BoxPyramidScale of 1.2 to allow
    % for finer resolution for multiscale object detection.
    %detector = trainFasterRCNNObjectDetector(trainingData, layers, options, ...
    detector = trainFasterRCNNObjectDetector(trainingData, layers, trainingOpts, ...
        'NegativeOverlapRange', [0 0.3], ...
        'PositiveOverlapRange', [0.6 1], ...
        'BoxPyramidScale', 1.2);
else
    % Load pretrained detector for the example.
    data = load('fasterRCNNVehicleTrainingData.mat');
    
    detector = data.detector;
end

%%
% To quickly verify the training, run the detector on a test image.

% Read a test image.
I = imread('highway.png');

% Run the detector.
[bboxes, scores] = detect(detector, I);

% Annotate detections in the image.
I = insertObjectAnnotation(I, 'rectangle', bboxes, scores);
figure
imshow(I)

%% Evaluate Detector Using Test Set
% Testing a single image showed promising results. To fully evaluate the
% detector, testing it on a larger set of images is recommended. Computer
% Vision System Toolbox(TM) provides object detector evaluation functions
% to measure common metrics such as average precision
% (|evaluateDetectionPrecision|) and log-average miss rates
% (|evaluateDetectionMissRate|). Here, the average precision metric is
% used. The average precision provides a single number that incorporates
% the ability of the detector to make correct classifications (precision)
% and the ability of the detector to find all relevant objects (recall).
%
% The first step for detector evaluation is to collect the detection
% results by running the detector on the test set. To avoid long evaluation
% time, the results are loaded from disk. Set the |doTrainingAndEval| flag
% from the previous section to true to execute the evaluation locally.

if doTrainingAndEval
    % Run detector on each image in the test set and collect results.
    resultsStruct = struct([]);
    for i = 1:height(testData)
        
        % Read the image.
        I = imread(testData.imageFilename{i});
        
        % Run the detector.
        [bboxes, scores, labels] = detect(detector, I);
        
        % Collect the results.
        resultsStruct(i).Boxes = bboxes;
        resultsStruct(i).Scores = scores;
        resultsStruct(i).Labels = labels;
    end
    
    % Convert the results into a table.
    results = struct2table(resultsStruct);
else
    % Load results from disk.
    results = data.results;
end

% Extract expected bounding box locations from test data.
expectedResults = testData(:, 2:end);

% Evaluate the object detector using Average Precision metric.
[ap, recall, precision] = evaluateDetectionPrecision(results, expectedResults);

%%
% The precision/recall (PR) curve highlights how precise a detector is at
% varying levels of recall. Ideally, the precision would be 1 at all recall
% levels. In this example, the average precision is 0.6. The use of
% additional layers in the network can help improve the average precision,
% but might require additional training data and longer training time.

% Plot precision/recall curve
figure
plot(recall, precision)
xlabel('Recall')
ylabel('Precision')
grid on
title(sprintf('Average Precision = %.1f', ap))

%% Summary
% This example showed how to train a vehicle detector using deep learning.
% You can follow similar steps to train detectors for traffic signs,
% pedestrians, or other objects.
