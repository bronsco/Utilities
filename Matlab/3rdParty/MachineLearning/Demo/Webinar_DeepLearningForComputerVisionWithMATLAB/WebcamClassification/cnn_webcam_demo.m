% Copyright 2016-2017 The MathWorks, Inc.

function cnn_webcam_demo(numTopClasses)

    if nargin == 0
        numTopClasses = 5;
    end
    
    if verLessThan('nnet','9.1') % Neural Network Toolbox from R2016a or earlied
        cnnMatFile = fullfile(pwd, '..', 'networks', 'imagenet-cnn.mat');
        
        if ~exist(cnnMatFile,'file')
            disp('Run ''downloadAndPrepareCNN.m'' to download and prepare the CNN')
            return;
        else
            imagenet_cnn = load(cnnMatFile);
            convnet = imagenet_cnn.convnet; 
        end
        
        % Convert ImageNet synset IDs to meaningful word descriptions
        synsetsFile = fullfile(fileparts(mfilename('fullpath')),'..',...
            'networks','synsetMap');

        % Image net class labels are synset IDs.
        synsetMap = load(synsetsFile);
        synsetMap = synsetMap.synsetMap;
        synsetMapKeys = keys(synsetMap);
        categories = values(synsetMap, synsetMapKeys);
    else
        try
            convnet = alexnet;
        catch
            error('Download the CNN model: AlexNet from the Add-On Explorer.');
        end
        
        % Proper category names already available in last layer. No need to
        % use syset IDs
        categories = convnet.Layers(end).ClassNames;
    end
       
    wcam = webcam;
    player = vision.DeployableVideoPlayer('Name', ...
        'Object Detection using Convolutional Neural Networks');
    
    % Configure position of labels and scores in Video Player
    imgResolution = str2double(strsplit(wcam.Resolution,'x'));
    classBarWidth = 30;
    spaceBetweenBars = 15;
    xPosition = imgResolution(1) + 50;
    yPosition = round((imgResolution(2) - classBarWidth * ...
        numTopClasses - spaceBetweenBars * (numTopClasses - 1))/2);
    
    cont = true;
    while cont
        img = snapshot(wcam);

        I = imresize(img, convnet.Layers(1).InputSize(1:2));
        [~, scores] = classify(convnet, I);
        [scores, idx] = sort(scores, 'descend');
       
        labelsTopCategories = categories(idx(1:numTopClasses));
        topScores = scores(1:numTopClasses)' * 100;

        img = insertTopClasses(img, labelsTopCategories, topScores);
        step(player,img)

        cont = isOpen(player);
    end

    function img = insertTopClasses(img, labels, scores)

        labelsXposition = xPosition * ones(numTopClasses,1);
        labelsYposition = yPosition * ones(numTopClasses,1) + ...
            (classBarWidth + spaceBetweenBars) * (0:numTopClasses-1)';
        
        img = padarray(img, [0 300], 0, 'post');
        
        % Top class scores
        img = insertShape(img, 'FilledRectangle', [labelsXposition, ...
            labelsYposition, 2*round(scores), ...
            classBarWidth * ones(numTopClasses,1)], 'Color', 'green');
        
        scoreLabels = cellfun(@(c1,c2) sprintf('%s (%2.2f %%)', c1, c2),...
            labels(:), num2cell(scores), 'UniformOutput', false);
        
        % Top class labels
        img = insertText(img, [labelsXposition, labelsYposition], ...
            scoreLabels, 'BoxOpacity', 0, 'TextColor', 'white', ...
            'FontSize', 14);
        
        % Highlighting top class
        img = insertText(img, [imgResolution(1)/2 30], labels(1), ...
            'BoxColor', 'green', 'FontSize', 20, ...
            'AnchorPoint', 'CenterTop');
    end

end
