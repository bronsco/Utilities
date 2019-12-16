%% Fine Tuning A Deep Neural Network
% This example shows how to fine tune a pre-trained deep convolutional
% neural network (CNN) for a new recognition task.

% Copyright 2016 The MathWorks, Inc.

%% Load network
cnnMatFile = fullfile(pwd, '..', 'networks', 'imagenet-cnn.mat');
if ~exist(cnnMatFile,'file')
    disp('Run downloadAndPrepareCNN.m to download and prepare the CNN')
    return;
end
imagenet_cnn = load(cnnMatFile);
net = imagenet_cnn.convnet;

%% Look at structure of pre-trained network
% Notice the last layer performs 1000 object classification
net.Layers

%% Perform net surgery
% The pre-trained layers at the end of the network are designed to classify
% 1000 objects. But we need to classify 2 different objects now. So the
% first step in transfer learning is to replace the last 3 layers of the
% pre-trained network with a set of layers that can classify 2 classes.

% Get the layers from the network. the layers define the network
% architecture and contain the learned weights. Here we only need to keep
% everything except the last 3 layers.
layers = net.Layers(1:end-3);

% Add new fully connected layer for 2 categories.
layers(end+1) = fullyConnectedLayer(2, 'Name', 'fc8_2')

% Add the softmax layer and the classification layer which make up the
% remaining portion of the networks classification layers.
layers(end+1) = softmaxLayer('Name','prob_2');
layers(end+1) = classificationLayer('Name','classificationLayer_2')

% Modify image layer to add randcrop data augmentation. This increases the
% diversity of training images. The size of the input images is set to the
% original networks input size.
layers(1) = imageInputLayer([227 227 3], 'DataAugmentation', 'randcrop');


%% Setup learning rates for fine-tuning
% For fine-tuning, we want to changed the network ever so slightly. How
% much a network is changed during training is controlled by the learning
% rates. Here we do not modify the learning rates of the original layers,
% i.e. the ones before the last 3. The rates for these layers are already
% pretty small so they don't need to be lowered further. You could even
% freeze the weights of these early layers by setting the rates to zero.
%
% Instead we boost the learning rates of the new layers we added, so that
% they change faster than the rest of the network. This way earlier layers
% don't change that much and we quickly learn the weights of the newer
% layer.

% fc 8 - bump up learning rate for last layers
layers(end-2).WeightLearnRateFactor = 100;
layers(end-2).WeightL2Factor = 1;
layers(end-2).BiasLearnRateFactor = 20;
layers(end-2).BiasL2Factor = 0;

%% Load Image Data
% Now we get the training data. This was collected as traffic drove into
% the MathWorks head office in Natick.
%
% Create an imageDataStore to read images
location = 'VehicleData';
imds = imageDatastore(location,'IncludeSubfolders',1,'LabelSource','foldernames');
tbl = countEachLabel(imds);

% Display a sampling of training images

%% Display Sampling of Image Data
% Notice that the cars and SUV look very similar
imagesInMontage = cell(10,2);
carFiles = imds.Files(imds.Labels == 'Car');
suvFiles =  imds.Files(imds.Labels == 'SUV');
imagesInMontage(:,1) =  carFiles(1:length(carFiles)/10:length(carFiles));
imagesInMontage(:,2) =  suvFiles(1:length(suvFiles)/10:length(suvFiles));
figure;
subplot(1,2,1);
DisplayImageMontage({imagesInMontage{:,1}});title('Cars');
subplot(1,2,2);
DisplayImageMontage({imagesInMontage{:,2}});title('SUV');

%% Equalize number of images of each class in training set
minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category
% Use splitEachLabel method to trim the set.
imds = splitEachLabel(imds, minSetCount);

% Notice that each set now has exactly the same number of images.
countEachLabel(imds)
[trainingDS, testDS] = splitEachLabel(imds, 0.7,'randomize');
% Convert labels to categoricals
trainingDS.Labels = categorical(trainingDS.Labels);
trainingDS.ReadFcn = @readFunctionTrain;

%% Setup test data for validation
testDS.Labels = categorical(testDS.Labels);
testDS.ReadFcn = @readFunctionValidation;

%% Fine-tune the Network

miniBatchSize = 32; % lower this if your GPU runs out of memory.
numImages = numel(trainingDS.Files);

% Run training for 5000 iterations. Convert 20000 iterations into the
% number of epochs this will be.
numIterationsPerEpoch = numImages/miniBatchSize;
%maxEpochs = round(20000/numIterationsPerEpoch);
maxEpochs = 100;
lr = 0.001;
opts = trainingOptions('sgdm', ...
    'InitialLearnRate', lr,...
    'LearnRateSchedule', 'none',...
    'L2Regularization', 0.0005, ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', miniBatchSize);

net = trainNetwork(trainingDS, layers, opts);
% This could take over an hour to run.

%% Test 2-class classifier on  validation set
% Now run the network on the test data set to see how well it does:

labels = classify(net, testDS, 'MiniBatchSize', 32);

confMat = confusionmat(testDS.Labels, labels);
confMat = bsxfun(@rdivide,confMat,sum(confMat,2));

mean(diag(confMat))

%% Run on Video Stream
videoPlayer = vision.DeployableVideoPlayer;

% Learn the background ( this takes a few seconds ) 
foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 50,'MinimumBackgroundRatio',0.5);
roi = [139.25 239.75 985.5 400];
videoReader = vision.VideoFileReader('MorningTraffic2.mp4');
for i = 1:150
    frame = step(videoReader); % read the next video frame
    frame = imcrop(frame,roi);
    frameSmall = imresize(frame,0.25);
    foreground = step(foregroundDetector, frameSmall);
end
blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 300);


%% Detect Cars using Background Subtraction then classify
se = strel('square', 3); % morphological filter for noise removal
while ~isDone(videoReader)
    
    frame = step(videoReader); % read the next video frame
    frame = imcrop(frame,roi); % crop to region of interest
    frameSmall = imresize(frame,0.25);
    foreground = step(foregroundDetector, frameSmall);
    
    % Use morphological opening to remove noise in the foreground
    filteredForeground = imopen(foreground, se);
    
    % Detect the connected components with the specified minimum area, and
    % compute their bounding boxes
    bbox = step(blobAnalysis, filteredForeground);
    
    numCars = size(bbox,1);
    bbox = 4.*bbox;
    result = frame;
    if numCars > 0
        for j=1:numCars
            
            % Crop a slightly larger region around car 
            im = imcrop(frame,[bbox(j,1)-10 bbox(j,2)-10 bbox(j,3)+30 bbox(j,4)+30]);
            
            im = single(im2uint8(im));
            im = imresize(im, [227 227]) ;
            label = char(classify(net,im)); % classify with deep learning 
            result = insertObjectAnnotation(result,'Rectangle',bbox(j,:),label,'FontSize',32);
        end
        
    end
    step(videoPlayer,result);
    % Draw bounding boxes around the detected cars
       
end

release(videoReader); % close the video file
