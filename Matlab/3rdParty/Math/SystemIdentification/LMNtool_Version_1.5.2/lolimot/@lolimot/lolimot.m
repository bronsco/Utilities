classdef lolimot < gaussianOrthoGlobalModel & dataSet 
    %% The LOLIMOT class generates a net object consisting of local models.
    %
    %   Each model has a certain area, where it is valid. This area is
    %   specified by a validity function. In case of a LOLIMOT object,
    %   Gaussian are used to decribe the local areas. To get a 'Partition
    %   of Unity' the Gaussians are normed. The training  is pretty fast,
    %   because the algorithmn split only orthogonal halfs. Therefore it is
    %   not very flexible. The local models themselves are linear, i.e.
    %   hyperplanes. This keeps the number of parameter very handly even for
    %   higher dimensional problems.
    %
    %
    %   lolimot properties:
    %       splits             - (1 x 1)  Number of splits in each dimension during the training (default: 1).
    %       MSFValue           - (1 x M)  Membership function values for each local model (default: cell(1,1)).
    %
    %   SYMBOLS AND ABBREVIATIONS:
    %
    %       N:  Number of samples.
    %       q:  Number of outputs.
    %       nx: Number of rule consequents.
    %       nz: Number of rule premises.
    %       M:  Number of local models.
    %
    %   LoLiMoT - Nonlinear System Identification Toolbox
    %   Torsten Fischer, 02-Februar-2013
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles
    
    properties % properties that are not in the super-classes
        
        %SPLITS - (1 x 1) Number of splits tested in each dimension
        %
        %   This property describes how many splits should be taken along each
        %   dimension during the training.
        splits = 1;
        
        %MSFVALUE - (1 x M) Membership function values for each local model
        %
        %   This property stores the Gaussians for each local model.
        %   During the training procedure the storage reduces the
        %   computational effort.
        MSFValue = cell(1,1); 
        
    end
    
    methods(Static)
        [lowerLeftCorner1, upperRightCorner1, lowerLeftCorner2, upperRightCorner2] = ...
            LMSplit(lowerLeftCorner, upperRightCorner, splitDimension, splitRatio)
    end
    
end

