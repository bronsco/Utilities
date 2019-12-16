% Copyright 2016 The MathWorks, Inc.

function I = readFunctionValidation(filename)
% Resize the flowers images to the size required by the network.
I = imread(filename);

I = imresize(I, [227 227]);