% Copyright 2016 The MathWorks, Inc.
function [bboxes,flow] = findPet(frameGray, opticFlow)
% Calculate Optical Flow
flow = estimateFlow(opticFlow,frameGray);
% Threshold Image 
threshImage = ( flow.Magnitude > 4);
% Find connected components and filter regions 
[~,regions] = filterRegions(threshImage);

if(size(regions) > 0)
    bboxes = regions.BoundingBox;
else
    bboxes = [];
end
end
