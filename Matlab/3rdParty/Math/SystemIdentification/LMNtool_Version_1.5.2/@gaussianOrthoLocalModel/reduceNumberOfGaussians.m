function [obj,MSFValue] = reduceNumberOfGaussians(obj,zRegressor,smoothness,MSFValue)
% REDUCENUMBEROFGAUSSIANS reduces the number of Gaussians per
% local model, if possible. Therefore it compares the centers of the
% Gaussians of each model. Of they are similar in one direction, they can
% be expressed by one new Gaussian.
%
%
% obj = reduceNumberOfGaussians(obj,selectionLM)
%
%
% INPUT:
%   obj:          object    LOLIMOTMERGE object containing all relevant net
%                           and data set information and variables.
%   selectionLM:  (1 x ?)   Array containing the local models, that are to
%                           be checked.
%
%
% OUTPUT:
%   obj:          object    LOLIMOTMERGE object containing all relevant net
%                           and data set information and variables.
%
%
% Local Model Toolbox, Version 1.0
% Torsten Fischer, 08-Dec-2011
% Institute of Measurement and Control, University of Siegen, Germany
% Copyright (c) 2011 by Torsten Fischer

return
% Get some constants
[numberOfSamples, numberOfzRegressors] = size(zRegressor);
numberOfGaussians = size(obj.center,1);

% Initialize neighbour index
indexNeighbour = [];

% Check the LM until no Gaussians can be merged no more
while numberOfGaussians > 1
    
    % Initialize flag for breaking the loops
    flagMatchingGaussiansFound = false;
    
    % Check for possible combinations/neighbours within the local model
    for k = 1:numberOfGaussians % Pointer one
        for l = k+1:numberOfGaussians % Pointer two
            if sum(obj.center(k,:) ~= obj.center(l,:)) == 1 % Check if just one dimension is unequal
                idx = (obj.center(k,:) ~= obj.center(l,:)); % Catching the different dimension
                a = abs(obj.upperRightCorner(k,idx) - obj.lowerLeftCorner(k,idx)); % Length of the unequal edge of the kth element
                b = abs(obj.upperRightCorner(l,idx) - obj.lowerLeftCorner(l,idx)); % Length of the unequal edge of the lth element
                c = abs(obj.center(k,idx) - obj.center(l,idx));
                if abs(c - 0.5*(a+b)) <= eps % Check if the two LLM are neighbors
                    indexNeighbour =[k l find(idx)]; % Adding indicies to matrix
                    flagMatchingGaussiansFound = true; % Index added : setting true for breaking both loops
                end
            end
            
            if flagMatchingGaussiansFound
                break % Break loop; neighbour found
            end
            
        end % End loop pointer one
        
        if flagMatchingGaussiansFound
            break % Break loop; neighbour found
        end
    end % End loop pointer two
    
    % Check if any neighbours are found
    if isempty(indexNeighbour)
        break % No neighbours : break while-loop
    end
    
    % Catch the index of the Gaussians to manipulate
    A = indexNeighbour(1); B = indexNeighbour(2); dim = indexNeighbour(3);
    % clear indexNeighbour
    indexNeighbour = [];
    
    %  Copy the lower left and upper right corners
    upperRightCorners = obj.upperRightCorner;
    lowerLeftCorners = obj.lowerLeftCorner;
    
    % Reducing the current local model object and its MSFValues
    obj.center([A B],:) = [];
    obj.lowerLeftCorner([A B],:) = [];
    obj.upperRightCorner([A B],:) = [];
    obj.standardDeviation([A B],:) = [];
    MSFValue(:,[A B]) = [];

    % Initialize the new gaussian to the local object and its MSFValue
    obj.center = [obj.center; zeros(1,numberOfzRegressors)];
    obj.standardDeviation = [obj.standardDeviation; zeros(1,numberOfzRegressors)];
    obj.lowerLeftCorner = [obj.lowerLeftCorner; zeros(1,numberOfzRegressors)];
    obj.upperRightCorner = [obj.upperRightCorner; zeros(1,numberOfzRegressors)];
    MSFValue = [MSFValue zeros(numberOfSamples,1)];
    
    % Choosing the right corners for the new Gaussian
    if lowerLeftCorners(A,dim) < lowerLeftCorners(B,dim)
        obj.lowerLeftCorner(end,:) = lowerLeftCorners(A,:);
        obj.upperRightCorner(end,:) = upperRightCorners(B,:);
    else
        obj.lowerLeftCorner(end,:) = lowerLeftCorners(B,:);
        obj.upperRightCorner(end,:) = upperRightCorners(A,:);
    end
    
    % Calculate new center coordinates and standard deviation
    [obj.center(end,:), obj.standardDeviation(end,:)] = obj.corner2Center(obj.lowerLeftCorner(end,:), obj.upperRightCorner(end,:), smoothness);
    
    % Number of Gaussians in the local model; for a better clarity
    numberOfGaussians = size(obj.center,1);
    
    % Calculate the new Gaussian for the local model object
    MSFValue(:,end) = obj.calculateMSF(zRegressor,numberOfGaussians);
    
end % End of while-loop