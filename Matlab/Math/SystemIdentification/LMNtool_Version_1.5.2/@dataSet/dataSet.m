classdef dataSet
    %% dataSet creates a dataSet object.
    %
    %   This class generates a dataSet object, which stores measured data.
    %   Beneath the ability to store data, there are methods to
    %   scale/unscale the data and to set a name for the whole
    %   dataSet as well as for the various in- and outputs.
    %
    %
    % 	DATASET properties:
    %
    %       input            - (N x p) Matrix of the inputs.
    %       scaleInput       - (class) Scale input object.
    %
    %       output           - (N x q) Matrix of the outputs.
    %       scaleOutput      - (class) Scale output object. Empty for no
    %                                  scaling (Default = []).
    %       dataWeighting    - (N x 1) Weighting of the inputs.
    %       outputWeighting  - (q x 1) Weighting of the outputs.
    %       info             - (class) dataSetInfo object.
    %
    %       validationInput  - (N x p) Matrix of the validation data inputs.
    %       validationOutput - (N x q) Matrix of the validation data outputs.
    %       testInput        - (N x p) Matrix of the test data inputs.
    %       testOutput       - (N x q) Matrix of the test data outputs.
    %
    %
    %   SYMBOLS AND ABBREVIATIONS:
    %
    %       LM:  Local model
    %
    %       p:   Number of inputs (physical inputs)
    %       q:   Number of outputs
    %       N:   Number of data samples
    %       M:   Number of LMs
    %       nx:  Number of regressors (x)
    %       nz:  Number of regressors (z)
    %
    %
    %   See also editDataSet, editModelObject, loadDataSet, saveDataSet.
    %
    %
    %   LMNtool - Local Model Network Toolbox
    %   Tobias Ebert & Julian Belz, 15-March-2012
    %   Institute of Mechanics & Automatic Control, University of Siegen, Germany
    %   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles
    

    % 2013-01-16: Changed layout of comments. (Benjamin Hartmann)
    % 2012-11-21: Attributes of the properties unscaledInput and
    % unscaledOutput changed. Set-method of the input property changed. Now
    % the scaled and unscaled data is saved explicitly. (Julian Belz)
    
    properties (Hidden = true)
        inputScalingComplete = false;   % is set to true after scaling is complete
        outputScalingComplete = false;
        %validationInputScalingComplete = false;   % is set to true after scaling is complete
        %validationOutputScalingComplete = false;
        %testInputScalingComplete = false;   % is set to true after scaling is complete
        %testOutputScalingComplete = false;
    end
    
    properties
        
        %SCALEPARAINPUT - (struc) Sructure with information how to scale input data.
        scaleParaInput = [];      
        
        %INPUT - (N x p) Matrix of the inputs.
        input                 
        
        %VALIDATIONINPUT - (N x p) Matrix of the validation inputs.
        validationInput = [];
        
        %TESTINPUT - (N x p) Matrix of the test data inputs.
        testInput = [];      
       
        %SCALEPARAOUTPUT - (struc) Structure with information how to scale output data.
        scaleParaOutput = []      
        
        %OUTPUT - (N x q) Matrix of the outputs.
        output                
        
        %VALIDATIONOUTPUT - (N x q) Matrix of the validatino outputs.
        validationOutput = [];
        
        %TESTOUTPUT - (N x q) Matrix of the test data outputs.
        testOutput = [];      
        
        
        %DATAWEIGHTING - (N x 1) Weighting of the inputs.
        dataWeighting = [];   
        
        %OUTPUTWEIGHTING - (q x 1) Weighting of the outputs.
        outputWeighting = []; 
        
        %INFO - (class) dataSetInfo object.
        info = dataSetInfo;
        
        %scalingMethod - (string) Determines method for data scaling.
        scalingMethod = 'zeroOne';
        
    end
    
    properties (SetAccess = private, GetAccess = public)
%         unscaledInput
%         unscaledOutput
        %unscaledTestInput
        %unscaledTestOutput
        %unscaledValidationInput
        %unscaledValidationOutput
    end
    
    properties(Dependent=true)
        unscaledInput
        unscaledOutput
    end
    
    
    methods
        
        saveDataSet(obj,matfile);
        obj = getZinputDelay(obj);
        obj = getXinputDelay(obj);
        obj = getXoutputDelay(obj)
        obj = getZoutputDelay(obj);
        
        %% Constructor
        function ds=dataSet(input,output,varargin)
            % Constructor of an dataSet object.
            %
            % ds = dataSet(input,output,dataWeighting,info)
            %
            %
            % INPUT
            %
            % input (optional):         (N x p) Matrix with the input data.
            % output (optional):        (N x q) Matrix with the output data.
            % dataWeighting (optional): (N x 1) Weighting of the inputs.
            % info (optional):                  dataSetInfo object
            %
            % OUTPUT
            %
            % ds:                               dataSet object
            
            % Set in- and output data
            if nargin == 0
                ds.input  = [];
                ds.output = [];
            elseif nargin >= 2
                ds.input    = input;
                ds.output   = output;
            elseif nargin == 1
                ds.input    = input;
                ds.output   = zeros(size(input,1),1);
            end
            
            % If passed, set the dataWeighting property and the info
            % property
            if ~isempty(varargin)
                ds.dataWeighting = varargin{1,1};
                if size(varargin,2) > 1
                    ds.info = varargin{1,2};
                end
            end
            
        end % end constructor
        
        % SET and GET methods, to prevent errors later
        
        %% set.input
        function obj = set.input(obj,data)
            
            testDataForErrors(data)
            
            if size(data,2) > size(data,1)
                warning('dataSet:setInput','The data has %.0f dimensions, but only %.0f data samples',size(data,2),size(data,1))
            end
            
            % Check if there is data given and scaling is incomplete
            if ~isempty(data) && ~obj.inputScalingComplete

                [scaledInput, scalingParameter] = obj.scaleData(data,[]);
                obj.scaleParaInput = scalingParameter;
                obj.input = scaledInput;
                obj.inputScalingComplete = true; % remember that the input is already scaled (for save and load)
%                 if isprop(obj,'history') && isprop(obj.history,'displayMode')
%                     displayMode = obj.history.displayMode;
%                 else
%                     displayMode = true;
%                 end
%                 if displayMode; fprintf('\nInput scaling complete.\n'); end
            else
                obj.input = data;
            end
            
        end % end set.input
        
        
        %% set.output
        function obj = set.output(obj,data)
            
            testDataForErrors(data)
            
            if size(data,2) > size(data,1)
                warning('dataSet:setOutput','The data has %.0f dimensions, but only %.0f data samples',size(data,2),size(data,1))
            end 
            
            % Check if there is data given and scaling is incomplete
            if ~isempty(data) && ~obj.outputScalingComplete
                
                [scaledOutput, scalingParameter] = obj.scaleData(data,obj.scaleParaOutput);
                obj.scaleParaOutput = scalingParameter;
                obj.output = scaledOutput;
                obj.outputScalingComplete = true;
%                 if isprop(obj,'history') && isprop(obj.history,'displayMode')
%                     displayMode = obj.history.displayMode;
%                 else
%                     displayMode = true;
%                 end
%                 if displayMode; fprintf('\nOutput scaling complete.\n'); end
            else
                obj.output = data;
            end
            
        end % end set.output
        
        
        %% set validation input
        function obj = set.validationInput(obj,data)
            
            testDataForErrors(data)
            
            %             if ~isempty(data) && ~isempty(obj.scaleInput) && ~obj.validationInputScalingComplete
            %                 % if there is data given and scaling is allowed
            %
            %                 if ~obj.inputScalingComplete
            %                     error('Specify the training input first')
            %                 end
            %
            %                 obj.validationInput = obj.scaleInput.scale(data);
            %                 obj.validationInputScalingComplete = true; % remember that the input is already scaled (for save and load)
            %
            %                 if isprop(obj,'history') && isprop(obj.history,'displayMode')
            %                     displayMode = obj.history.displayMode;
            %                 else
            %                     displayMode = true;
            %                 end
            %                 if displayMode; fprintf('\n\nValidation Input scaling complete.\n'); end
            %             else
            obj.validationInput = data;
            %             end
            %
            %             obj.unscaledValidationInput = data;
            
            
            
        end
        
        %% set validation out
        function obj = set.validationOutput(obj,data)
            
            testDataForErrors(data)
            
            %             if ~isempty(data) && ~isempty(obj.scaleOutput) && ~obj.validationOutputScalingComplete
            %                 % if there is data given and scaling is allowed
            %
            %                 if ~obj.outputScalingComplete
            %                     error('Specify the training output first')
            %                 end
            %
            %                 obj.validationOutput = obj.scaleOutput.scale(data);
            %                 obj.validationOutputScalingComplete = true; % remember that the input is already scaled (for save and load)
            %
            %                 if isprop(obj,'history') && isprop(obj.history,'displayMode')
            %                     displayMode = obj.history.displayMode;
            %                 else
            %                     displayMode = true;
            %                 end
            %                 if displayMode; fprintf('\n\nvalidation Output scaling complete.\n'); end
            %             else
            obj.validationOutput = data;
            %             end
            %
            %             obj.unscaledValidationOutput = data;
            
        end
        
        %% set test input
        function obj = set.testInput(obj,data)
            
            testDataForErrors(data)
            
            %             if ~isempty(data) && ~isempty(obj.scaleInput) && ~obj.testInputScalingComplete
            %                 % if there is data given and scaling is allowed
            %
            %                 if ~obj.inputScalingComplete
            %                     error('Specify the training input first')
            %                 end
            %
            %                 obj.testInput = obj.scaleInput.scale(data);
            %                 obj.testInputScalingComplete = true; % remember that the input is already scaled (for save and load)
            %
            %                 if isprop(obj,'history') && isprop(obj.history,'displayMode')
            %                     displayMode = obj.history.displayMode;
            %                 else
            %                     displayMode = true;
            %                 end
            %                 if displayMode; fprintf('\n\nTest Input scaling complete.\n'); end
            %             else
            obj.testInput = data;
            %             end
            %
            %             obj.unscaledTestInput = data;
            
        end
        
        %% set validation out
        function obj = set.testOutput(obj,data)
            
            testDataForErrors(data)
            
            %             if ~isempty(data) && ~isempty(obj.scaleOutput) && ~obj.testOutputScalingComplete
            %                 % if there is data given and scaling is allowed
            %
            %                 if ~obj.outputScalingComplete
            %                     error('Specify the training output first')
            %                 end
            %
            %                 obj.testOutput = obj.scaleOutput.scale(data);
            %                 obj.testOutputScalingComplete = true; % remember that the input is already scaled (for save and load)
            %
            %                 if isprop(obj,'history') && isprop(obj.history,'displayMode')
            %                     displayMode = obj.history.displayMode;
            %                 else
            %                     displayMode = true;
            %                 end
            %                 if displayMode; fprintf('\n\nTest Output scaling complete.\n'); end
            %             else
            obj.testOutput = data;
            %             end
            %
            %             obj.unscaledTestOutput = data;
            
        end
        
        
        % get.unscaledInput
        function unscaledInput = get.unscaledInput(obj)
            if isempty(obj.input)
                unscaledInput = [];
            elseif isempty(obj.scaleParaInput)
                unscaledInput = obj.input;
            else
                dataObj = dataSet;
                unscaledInput = dataObj.unscaleData(obj.input,obj.scaleParaInput);
            end
        end
        
        %% get.unscaledOutput
        function unscaledOutput = get.unscaledOutput(obj)
            if isempty(obj.output)
                unscaledOutput = [];
            elseif isempty(obj.scaleParaOutput)
                unscaledOutput = obj.output;
            else
                dataObj = dataSet;
                unscaledOutput = dataObj.unscaleData(obj.output,obj.scaleParaOutput);
            end
        end
        
%         %% set scale input
%         function obj = set.scaleInput(obj,scaling)
%             if isempty(obj.input)
%                 obj.scaleInput = scaling;
%             else
%                 error('dataSet:scaleInput','input is not empty')
%             end
%         end
%         
%         %% set scale output
%         function obj = set.scaleOutput(obj,scaling)
%             if isempty(obj.output)
%                 obj.scaleOutput = scaling;
%             else
%                 error('dataSet:scaleOutput','output is not empty')
%             end
%         end
        
%         function obj = set.outputWeighting(obj,value)
%            keyboard 
%             
%         end
%         
        
    end % end methods
    
    methods(Static=true, Hidden=true)
        ds                  = loadDataSet(matfile);
        out                 = fillDescription(in,bez);
    end
    
end

function testDataForErrors(data)

if isfloat(data)
    % warn if NaN or INF values are present
    if any(any(isnan(data)))
        warning(['Attention: There are NaN values in output ' num2str(find(any(isnan(data))))])
    end
    if any(any(isinf(data)))
        warning(['Attention: There are inf values in output ' num2str(find(any(isinf(data))))])
    end
else
    msgbox(['Wrong data type for setting the input ',...
        'property!'],'Error','error');
end

if size(data,2) > size(data,1)
    warning('dataSet:testDataForErrors','The data has %.0f dimensions, but only %.0f data samples',size(data,2),size(data,1))
end


end
