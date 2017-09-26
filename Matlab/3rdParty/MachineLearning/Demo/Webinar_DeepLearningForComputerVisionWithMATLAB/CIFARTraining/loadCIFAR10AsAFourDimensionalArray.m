% Copyright 2016 The MathWorks, Inc.

function [XTrain, TTrain, XTest, TTest] = loadCIFAR10AsAFourDimensionalArray()

% loadCIFAR10AsAFourDimensionalArray   Load the CIFAR-10 data

[XTrain1, TTrain1] = iLoadBatchAsFourDimensionalArray('data_batch_1.mat');
[XTrain2, TTrain2] = iLoadBatchAsFourDimensionalArray('data_batch_2.mat');
[XTrain3, TTrain3] = iLoadBatchAsFourDimensionalArray('data_batch_3.mat');
[XTrain4, TTrain4] = iLoadBatchAsFourDimensionalArray('data_batch_4.mat');
[XTrain5, TTrain5] = iLoadBatchAsFourDimensionalArray('data_batch_5.mat');

XTrain = cat(4, XTrain1, XTrain2, XTrain3, XTrain4, XTrain5);
TTrain = [TTrain1; TTrain2; TTrain3; TTrain4; TTrain5];

[XTest, TTest] = iLoadBatchAsFourDimensionalArray('test_batch.mat');

XTrain = double(XTrain);
XTest = double(XTest);
end

function [XBatch, TBatch] = iLoadBatchAsFourDimensionalArray(batchFileName)
load(batchFileName);
XBatch = data';
XBatch = reshape(XBatch, 32,32,3,[]);
XBatch = permute(XBatch, [2 1 3 4]);
TBatch = iConvertLabelsToCategorical(labels);
end

function categoricalLabels = iConvertLabelsToCategorical(integerLabels)
load('batches.meta.mat');
categoricalLabels = categorical(integerLabels, 0:9, label_names);
end