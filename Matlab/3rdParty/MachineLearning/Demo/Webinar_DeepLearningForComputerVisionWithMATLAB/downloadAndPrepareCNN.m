% Copyright 2016-2017 The MathWorks, Inc.

function downloadAndPrepareCNN()
% Download AlexNet CNN in MatConvNet format and converts to SerialNetwork

addpath(fullfile(pwd, 'WebcamClassification'));
mkdir(fullfile(pwd,'networks'));
cnnMatFile = fullfile(pwd, 'networks', 'imagenet-cnn.mat');
synsetsFile = fullfile(pwd, 'networks', 'synsetMap.mat');

if ~exist(cnnMatFile,'file')
    
    cnnSourceMatFile  = fullfile(pwd, 'networks', 'imagenet-caffe-alex.mat');
    cnnURL = 'http://www.vlfeat.org/matconvnet/models/beta16/imagenet-caffe-alex.mat';

    if ~exist(cnnSourceMatFile,'file') % download only once
        disp('Downloading 233MB AlexNet pre-trained CNN model. This may take several minutes...');
        websave(cnnSourceMatFile, cnnURL);
    end
    convnet = helperImportMatConvNet(cnnSourceMatFile);

    save(cnnMatFile, 'convnet');
    delete(cnnSourceMatFile)
end

if ~exist(synsetsFile,'file')
    synsets2words(convnet);
end
