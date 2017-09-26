%% Classification using Deep Learning 
% Copyright 2017 The MathWorks, Inc.
%% Load Pre-trained CNN
% This network is available from out add-ons location in the home tab. 
% You can use a variety of pretrained networks available for download
%
net = alexnet;
% net = vgg16;
% net = vgg19;

%% Classify 'peppers' in 4 lines of code
% This is a great opportunity to inspect the network and look at the input
% layer. There is a size requirement of 227 x 227 for AlexNet. 
% If you try to classify without resizing, you will get an error
im = imread('peppers.png');
imshow(im);
im = imresize(im,[227 227]);
classify(net,im)
