classdef dataSetInfo
    %% dataSetInfo stores information about the data.
    % 
    %   dataSetInfo creates an object, that contains information about a
    %   dataSet object, such as the dataSet description and the description
    %   of all in- and outputs.
    %
    %
    % 	dataSetInfo properties:
    %
    %       inputDescription   - (1 x p)  Description of the input variables.
    %       outputDescription  - (1 x q)  Description of the output variables.
    %       dataSetDescription - (String) Description of the dataset.
    %       samplingTime       - (1 x 1)  Sampling time for dynamic systems.
    %       numberOfInputs    - (1 x 1) Number of all physical inputs for training (without delays).
    %       numberOfOutputs   - (1 x 1) Number of all physical outputs for training (without delays).
    %
    %
    %   LMNtool - Local Model Network Toolbox
    %   Julian Belz, 21-November-2011
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles

    
    properties
        inputDescription        % Description of the inputs
        outputDescription       % Description of the outputs
        dataSetDescription      % Description of a dataSet object
        samplingTime            % Sampling time of the dynamic systems
    end
        
    properties
        %numberOfInputs - (1 x 1) Number of all physical inputs for training (without delays).
        %
        %       This property stores the number of inputs of the data set, which
        %       were used to train the global model object. If another data set is
        %       used for validation or testing, the quantities must fit.
        numberOfInputs
        
        %numberOfOutputs - (1 x 1) Number of all physical outputs for training (without delays).
        %
        %       This property stores the number of inputs/outputs of the data set, which
        %       were used to train the global model object. If another data set is
        %       used for validation or testing, the quantities must fit.
        numberOfOutputs    
    end
    
    methods
        function info = dataSetInfo(dsName)
            % Constructor for a dataSetInfo object, where a description of
            % a dataSet object can be passed directly
            %
            %
            % info = dataSetInfo(dsName)
            %
            %
            % INPUT
            %
            % dsName:       String, which describes a dataSet object
            %
            %
            % OUTPUT
            %
            % info:         dataSetInfo object
            
            if nargin == 0 || isempty(dsName)
                dsName = 'No Description';
            end
            
            info.dataSetDescription = dsName;
            
        end % end constructor
        
        %         %% SET and GET methods
        %
        %         % get method for the dependent property numberOfInputs
        %         function numberOfInputs = get.numberOfInputs(obj)
        %             % Check if the input description is empty
        %             if numel(obj.inputDescription) == 0
        %                 numberOfInputs = 'None';
        %             else
        %                 numberOfInputs = numel(obj.inputDescription);
        %             end
        %         end
        %
        %
        %         % get method for the dependent property numberOfOutputs
        %         function numberOfOutputs = get.numberOfOutputs(obj)
        %         % Check if the input description is empty
        %             if numel(obj.outputDescription) == 0
        %                 numberOfOutputs = 'None';
        %             else
        %                 numberOfOutputs = numel(obj.outputDescription);
        %             end
        %         end
        
    end
    
end

