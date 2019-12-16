%% Deep Learning for Pet classification
% This example shows how to use a pre-trained Convolutional Neural Network
% (CNN) as a feature extractor for training an image category classifier. 
%
% Copyright 2016 The MathWorks, Inc.

%% Download Pre-trained Convolutional Neural Network (CNN)
% You will need to download a pre-trained CNN model for this example.
% There are several pre-trained networks that have gained popularity.
% Most of these have been trained on the ImageNet dataset, which has 1000
% object categories and 1.2 million training images[1]. "AlexNet" is one
% such model and can be downloaded from MatConvNet[2,3]. 

% Location of pre-trained "AlexNet"
cnnURL = 'http://www.vlfeat.org/matconvnet/models/beta16/imagenet-caffe-alex.mat';
% Specify folder for storing CNN model 
cnnFolder = 'C:\DeepLearning\networks';
cnnMatFile = 'imagenet-caffe-alex.mat'; 
cnnFullMatFile = fullfile(cnnFolder, cnnMatFile);

% Check that the code is only downloaded once
if ~exist(cnnFullMatFile, 'file')
    disp('Downloading pre-trained CNN model...');     
    websave(cnnFullMatFile, cnnURL);
end

%% Load Pre-trained CNN
% The CNN model is saved in MatConvNet's format [3]. Load the MatConvNet
% network data into |convnet|, a |SeriesNetwork| object from Neural Network
% Toolbox(TM), using the helper function |helperImportMatConvNet| in the 
% Computer Vision System Toolbox (TM). A SeriesNetwork object can be used
% to inspect the network architecture, classify new data, and extract
% network activations from specific layers.

% Load MatConvNet network into a SeriesNetwork
convnet = helperImportMatConvNet(cnnFullMatFile);

%% |convnet.Layers| defines the architecture of the CNN 

convnet.Layers

%%
% The intermediate layers make up the bulk of the CNN. These are a series
% of convolutional layers, interspersed with rectified linear units (ReLU)
% and max-pooling layers [2]. Following the these layers are 3
% fully-connected layers.
%
% The final layer is the classification layer and its properties depend on
% the classification task. In this example, the CNN model that was loaded
% was trained to solve a 1000-way classification problem. Thus the
% classification layer has 1000 classes from the ImageNet dataset. 

% Inspect the last layer
convnet.Layers(end)

% Number of class names for ImageNet classification task
numel(convnet.Layers(end).ClassNames)

%%
% Note that the CNN model is not going to be used for the original
% classification task. It is going to be re-purposed to solve a different
% classification task on the pets dataset.

%% Set up image data
dataFolder = 'C:\DeepLearning\data\PetImages';
categories = {'Cat', 'Dog'};
imds = imageDatastore(fullfile(dataFolder, categories), 'LabelSource', 'foldernames');
tbl = countEachLabel(imds) %#ok<*NOPTS>

%% Use the smallest overlap set
minSetCount = min(tbl{:,2});

% Use splitEachLabel method to trim the set.
imds = splitEachLabel(imds, minSetCount, 'randomize');

% Notice that each set now has exactly the same number of images.
countEachLabel(imds)

%% Pre-process Images For CNN
% |convnet| can only process RGB images that are 227-by-227.
% To avoid re-saving all the images to this format, setup the |imds|
% read function, |imds.ReadFcn|, to pre-process images on-the-fly.
% The |imds.ReadFcn| is called every time an image is read from the
% |ImageDatastore|.
%
% Set the ImageDatastore ReadFcn
imds.ReadFcn = @(filename)readAndPreprocessImage(filename);

%% Divide data into training and testing sets
[trainingSet, testSet] = splitEachLabel(imds, 0.3, 'randomize');

%% Extract training features using pretrained CNN
% Each layer of a CNN produces a response, or activation, to an input
% image. However, there are only a few layers within a CNN that are
% suitable for image feature extraction. The layers at the beginning of the
% network capture basic image features, such as edges and blobs. To see
% this, visualize the network filter weights from the first convolutional
% layer. This can help build up an intuition as to why the features
% extracted from CNNs work so well for image recognition tasks. Note that
% visualizing deeper layer weights is beyond the scope of this example. You
% can read more about that in the work of Zeiler and Fergus [4].

% Get the network weights for the second convolutional layer
w1 = convnet.Layers(2).Weights;

% Scale and resize the weights for visualization
w1 = mat2gray(w1);
w1 = imresize(w1,5); 

% Display a montage of network weights. 
figure
montage(w1)
title('First convolutional layer weights')

%%
% Notice how the first layer of the network has learned filters for
% capturing blob and edge features. These "primitive" features are then
% processed by deeper network layers, which combine the early features to
% form higher level image features. These higher level features are better
% suited for recognition tasks because they combine all the primitive
% features into a richer image representation [5].
%
% You can easily extract features from one of the deeper layers using the
% |activations| method. Selecting which of the deep layers to choose is a
% design choice, but typically starting with the layer right before the
% classification layer is a good place to start. In |convnet|, the this
% layer is named 'fc7'. Let's extract training features using that layer.


featureLayer = 'fc7';
trainingFeatures = activations(convnet, trainingSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

%%
% Note that the activations are computed on the GPU and the 'MiniBatchSize'
% is set 32 to ensure that the CNN and image data fit into GPU memory.
% You may need to lower the 'MiniBatchSize' if your GPU runs out of memory.
%
% Also, the activations output is arranged as columns. This helps speed-up
% the multiclass linear SVM training that follows.

%% Train a multiclass SVM classifier
% Get training labels from the trainingSet
trainingLabels = trainingSet.Labels;

% Train multiclass SVM classifier using a fast linear solver, and set
% 'ObservationsIn' to 'columns' to match the arrangement used for training
% features.
classifier = fitcecoc(trainingFeatures, trainingLabels, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

%% Evaluate classifier
% Extract test features using the CNN
testFeatures = activations(convnet, testSet, featureLayer, 'MiniBatchSize',32);

% Pass CNN image features to trained classifier
predictedLabels = predict(classifier, testFeatures);

% Get the known labels
testLabels = testSet.Labels;

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2)) 

%% Test it on an unseen image
newImage = 'Hobbes.png';
img = readAndPreprocessImage(newImage);
imageFeatures = activations(convnet, img, featureLayer);
label = predict(classifier, imageFeatures) 

%% Now put the whole Deep Learning and Computer Vision workflow together
%  and test it on a video
frameNumber = 0;
vr = VideoReader('Cat.Avi');
opticFlow = opticalFlowFarneback;
imageSize = [227 227];
vp = vision.VideoPlayer;

%%
while hasFrame(vr)
    % Count frames
    frameNumber = frameNumber + 1
    
    % Step 1. Read Frame
	vFrame = readFrame(vr);
    
    % Step 2. Detect ROI
    frameGray = rgb2gray(vFrame);            % Convert to gray for detection
    [bboxes, flow] = findPet(frameGray,opticFlow);   % Find bounding boxes
        
    if ~isempty(bboxes)
        img = zeros([imageSize 3 size(bboxes,1)]);
        for ii = 1:size(bboxes,1)
            img(:,:,:,ii) = imresize(imcrop(vFrame,bboxes(ii,:)),imageSize(1:2));
            
            % Step 3: Extract image features and predict label
            imageFeatures = activations(convnet, img(:,:,:,ii), featureLayer);
            label = predict(classifier, imageFeatures);

            % Step 4: Annotation
            vFrame = insertObjectAnnotation(vFrame,'Rectangle',bboxes(ii,:),cellstr(label),'FontSize',40);
             
        end
        step(vp, vFrame);
        
    end
    
end


%% References
% [1] Deng, Jia, et al. "Imagenet: A large-scale hierarchical image
% database." Computer Vision and Pattern Recognition, 2009. CVPR 2009. IEEE
% Conference on. IEEE, 2009.
%
% [2] Krizhevsky, Alex, Ilya Sutskever, and Geoffrey E. Hinton. "Imagenet
% classification with deep convolutional neural networks." Advances in
% neural information processing systems. 2012.
%
% [3] Vedaldi, Andrea, and Karel Lenc. "MatConvNet-convolutional neural
% networks for MATLAB." arXiv preprint arXiv:1412.4564 (2014).
%
% [4] Zeiler, Matthew D., and Rob Fergus. "Visualizing and understanding
% convolutional networks." Computer Vision-ECCV 2014. Springer
% International Publishing, 2014. 818-833.
%
% [5] Donahue, Jeff, et al. "Decaf: A deep convolutional activation feature
% for generic visual recognition." arXiv preprint arXiv:1310.1531 (2013).
