classdef hilomot < sigmoidGlobalModel & dataSet
    %% HILOMOT creates a HIerarchical LOcal MOdel Tree object with the HILOMOT algorithm.
    %
    %   The HILOMOT algorithm trains a local model network. The validity functions are determined
    %   heuristically with an incrementally growing tree-search algorithm. In each iteration one
    %   local model is added to the global model.
    %
    %   HILOMOT automatically determines the validity regions in the input space using axes-oblique
    %   splitting. HILOMOT models are hierarchically organized as so-called generalized hinging
    %   hyperplane trees. The hinges, i.e. the validity function parameters are optimized with
    %   respect to the global model error.
    %
    %   The output of a local model network is calculated as the weighted sum of local submodels
    %   that are of polynomial type, i.e. linearly parametrized. By default, the HILOMOT algorithm
    %   uses local 'affine' models, but extensions to higher order polynomials are straightforward.
    %   The estimation of the local model parameters is performed with Weighted Least Squares.
    %
    %
    %   HILOMOT properties:
    %       oblique      - (logical)  0: axes-orthogonal, 1: axis-oblique partitioning (default: 1).
    %       phi          - (N x M)    Validity function matrix.
    %       GradObj      - (logical)  0: analytical gradient (split optimization) not used, 1: analytical gradient will be used
    %
    %
    %   See also lolimot, dataSet, sigmoidGlobalModel.
    %
    %
    %   SYMBOLS AND ABBREVIATIONS
    %
    %       LM:  Local model
    %       p:   Number of inputs (physical inputs)
    %       q:   Number of outputs
    %       N:   Number of data samples
    %       M:   Number of LMs
    %       nx:  Number of regressors (x-space)
    %       nz:  Number of regressors (z-space)
    %
    %
    %   HiLoMoT - Nonlinear System Identification Toolbox
    %   Benjamin Hartmann, 15-January-2013
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles
    
    
    properties
        
        %OBLIQUE - (logical) 0: axes-orthogonal partitioning, 1: axis-oblique partitioning (default: 1).
        %
        %   This flag determines, if a nonlinear split optimization is applied during the training
        %   or not. If oblique is switched off (false), the training is similar to the LOLIMOT
        %   algorithm.
        oblique = true;
        
        %PHI - (N x M) Validity function matrix.
        %
        %   In this matrix the validity function values are stored for all tree knots and leaves.
        phi = [];
        
        %GRADOBJ - (logical) Flag to activate analytical gradient for split optimization.
        %
        %   This flag activates the analytical gradient for the nonlinear
        %   split optimization, which leads to a massive speed improvement.
        GradObj
        
        %REOPTIMIZENEWKAPPA - (logical) Flag to activate the re-optimization after kappa is adjusted.
        %
        %   If this property is set to true, the current split is optimized
        %   once again, after the kappa value is adjusted.
        reoptimizeNewKappa = false;
        
        %initialLOLIMOTsplits - (logical) Flag to activate the initial splits.
        %
        %   If this property is set to false, only the first splitting is 
        %   performed with the initial LoLiMoT splits.
        %   The optimization of the next splits are based on the parent
        %   split.
        initialLOLIMOTsplits = true;
        
    end
    
    % Constructor
    methods
        function obj = hilomot
            % make sure obliqueGlobalLossFunctionGradient.m is installed!
            if ismethod(obj, 'obliqueGlobalLossFunctionGradient')
                obj.GradObj = true;
            else
                obj.GradObj = false;
            end
        end
    end
    
end

