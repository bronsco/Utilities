% Read and pre-process images
% Copyright 2016 The MathWorks, Inc.
function Iout = readAndPreprocessImage(filename)

I = imread(filename);

% Some images may be grayscale. Replicate the image 3 times to
% create an RGB image.
if ismatrix(I)
    I = cat(3,I,I,I);
end

% Resize the image as required for the CNN.
Iout = imresize(I, [227 227]);

end
