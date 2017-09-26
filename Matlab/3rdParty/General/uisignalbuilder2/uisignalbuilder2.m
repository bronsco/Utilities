function uisignalbuilder2(varargin)
% UISIGNALBUILDER2 Signal Builder GUI
%
% UISIGNALBUILDER2 allows the user to create, delete and drag control points in
% order to build a signal using different interpolation methods.
%
%
% Useful commands: See help button
%
% Example:
%  >> uisignalbuilder2()
%  >> uisignalbuilder2(previously_saved_session_variable)
%
% This is a modified version of the UISIGNALBUILDER function by Laurent VAYLET.
%
% Author of modifications: Gijs van Oort
% Release 1.1
% Release date: 05/03/2013
% Additional features:
%   - Save button now saves the key points plus other settings so that you
%     can re-open it with the tool
%   - Export is now the original 'save' button (it exports a sampled
%     version of the signal to variables in the workspace
%   - Multiple signals
%   - Zoom/pan (by using akZoom2, a modified version of akZoom by Alexander Kessel
%   - No (snap to) grid anymore (not easily compatible with vertical zooming)
%
% Original Author: Laurent VAYLET
% Release: 1.0
% Release date: 04/22/2009
%


% Create controls
% Do not specify positions as GridBagLayout will take care of the layout later
hFig = figure('Name', 'Signal Builder', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Color', 'w');

hAxes = axes('Parent', hFig);
grid on;
akZoom2(hAxes);

hHelp = uicontrol(hFig, ...
    'Style', 'pushbutton', ...
    'BackgroundColor', 'w', ...
    'String', 'Help', ...
    'Callback', @(srv,evt)showhelp());

hOptions = uipanel(hFig, 'Title', ' Options ', 'FontWeight', 'bold', 'BackgroundColor', 'w', 'ForegroundColor', [0 0 0.5]);
hInterpMethodsLbl = uicontrol(hOptions, ...
    'Style', 'text', ...
    'BackgroundColor', 'w', ...
    'String', 'Interpolation method:', ...
    'HorizontalAlignment', 'left');
hInterpMethods = uicontrol(hOptions, ...
    'Style', 'popup', ...
    'BackgroundColor', 'w', ...
    'String', {'linear', 'spline', 'pchip', 'nearest'}, ...
    'Callback', @(src,evt)changeinterpmethod(), ...
    'ToolTipString', 'Method used when interpolating');
hSamplingPeriodLbl = uicontrol(hOptions, ...
    'Style', 'text', ...
    'BackgroundColor', 'w', ...
    'String', 'Sampling period (s):', ...
    'HorizontalAlignment', 'left');
hSamplingPeriod = uicontrol(hOptions, ...
    'Style', 'edit', ...
    'BackgroundColor', 'w', ...
    'String', '0.01', ...
    'Callback', @(src,evt)changesamplingperiod(src), ...
    'ToolTipString', 'Sampling period (s)');
hSignalLengthLbl = uicontrol(hOptions, ...
    'Style', 'text', ...
    'BackgroundColor', 'w', ...
    'String', 'Signal length (s):', ...
    'HorizontalAlignment', 'left');
hSignalLength = uicontrol(hOptions, ...
    'Style', 'edit', ...
    'BackgroundColor', 'w', ...
    'String', '6', ...
    'Callback', @(src,evt)changesignallength(src), ...
    'ToolTipString', 'Signal length (s)');
% hSnapGrid = uicontrol(hOptions, ...
%     'Style', 'checkbox', ...
%     'BackgroundColor', 'w', ...
%     'String', 'Snap To Grid', ...
%     'Value', 1, ...
%     'Callback', @(src,evt)togglesnapgrid());
hAddSignal = uicontrol(hOptions, ...
    'Style', 'pushbutton', ...
    'BackgroundColor', 'w', ...
    'String', 'Add Signal', ...
    'Value', 1, ...
    'Callback', @(src,evt)addsignal(), ...
    'ToolTipString', 'Add a signal');

hLoad = uicontrol(hOptions, ...
    'Style', 'pushbutton', ...
    'BackgroundColor', 'w', ...
    'String', 'Load', ...
    'Value', 1, ...
    'Callback', @(src,evt)loadButton(), ...
    'ToolTipString', 'Load signal points and settings from workspace variable');
hSave = uicontrol(hOptions, ...
    'Style', 'pushbutton', ...
    'BackgroundColor', 'w', ...
    'String', 'Save', ...
    'Value', 1, ...
    'Callback', @(src,evt)save(), ...
    'ToolTipString', 'Save signal points and settings to workspace');
hExport = uicontrol(hOptions, ...
    'Style', 'pushbutton', ...
    'BackgroundColor', 'w', ...
    'String', 'Export', ...
    'Value', 1, ...
    'Callback', @(src,evt)export(), ...
    'ToolTipString', 'Export interpolated signal to workspace');
hExportSimulink = uicontrol(hOptions, ...
    'Style', 'pushbutton', ...
    'BackgroundColor', 'w', ...
    'String', 'Export for Simulink', ...
    'Value', 1, ...
    'Callback', @(src,evt)exportsimulink(), ...
    'ToolTipString', 'Export interpolated signal to struct readable by the Simulink ''From Workspace'' block.');
  

% Layout controls using GridBagLayout
figureLayout = layout.GridBagLayout(hFig, 'HorizontalGap', 15, 'VerticalGap', 15);
figureLayout.add(hAxes, [1 2], 1, 'Fill', 'Both');
figureLayout.add(hHelp, 1, 2, 'Fill', 'Horizontal', 'MinimumHeight', 25);
figureLayout.add(hOptions, 2, 2, 'Fill', 'Vertical', 'MinimumWidth', 130);
figureLayout.VerticalWeights = [0 1];
figureLayout.HorizontalWeights = [1 0];
figureLayout.setConstraints([1 2], 1, ... % hAxes
    'LeftInset', 45, ...
    'BottomInset', 45, ...
    'RightInset', 15, ...
    'TopInset', 15);

optionsLayout = layout.GridBagLayout(hOptions, 'HorizontalGap', 15, 'VerticalGap', 0);
optionsLayout.add(hInterpMethodsLbl,  1, 1, 'Fill', 'Horizontal');
optionsLayout.add(hInterpMethods,     2, 1, 'Fill', 'Horizontal');
optionsLayout.add(hSamplingPeriodLbl, 3, 1, 'Fill', 'Horizontal');
optionsLayout.add(hSamplingPeriod,    4, 1, 'Fill', 'Horizontal');
optionsLayout.add(hSignalLengthLbl,   5, 1, 'Fill', 'Horizontal');
optionsLayout.add(hSignalLength,      6, 1, 'Fill', 'Horizontal');
%optionsLayout.add(hSnapGrid,          7, 1, 'Fill', 'Horizontal');
optionsLayout.add(hAddSignal,         7, 1, 'Fill', 'Horizontal', 'MinimumHeight', 20, 'Anchor', 'North');
optionsLayout.add(hLoad,              8, 1, 'Fill', 'Horizontal', 'MinimumHeight', 30, 'Anchor', 'South');
optionsLayout.add(hSave,              9, 1, 'Fill', 'Horizontal', 'MinimumHeight', 30, 'Anchor', 'South');
optionsLayout.add(hExport,           10, 1, 'Fill', 'Horizontal', 'MinimumHeight', 30, 'Anchor', 'South');
optionsLayout.add(hExportSimulink,   11, 1, 'Fill', 'Horizontal', 'MinimumHeight', 30, 'Anchor', 'South');
optionsLayout.VerticalWeights = [0 0 0 0 0 0 1 0 0 0 0];
optionsLayout.HorizontalWeights = 1;
optionsLayout.setConstraints(1, 1, ... % hInterpMethodsLbL
    'TopInset', 30);
optionsLayout.setConstraints(3, 1, ... % hSamplingPeriodLbL
    'TopInset', 15);
optionsLayout.setConstraints(5, 1, ... % hSignalLengthLbL
    'TopInset', 15);
% optionsLayout.setConstraints(7, 1, ... % hSnapGrid
%     'TopInset', 15);
optionsLayout.setConstraints(11, 1, ... % hExport
    'BottomInset', 15);

% Perform some initializations
plotColors = colormap(lines);
        
nSignals = 0;
hMarkers = []; % handles to markers
signalIndexForMarkers = []; % Each marker belongs to one signal; the signal index is here.
hSignal  = []; % handle to interpolated signal


% Create some variables to give them full scope in the function
origWindowButtonUpFcn = [];
origWindowButtonMotionFcn = [];
exportSimulinkVariableName = 'simin';

% Add some default markers
hold(hAxes, 'all')

% Freeze axis
axis tight
ylim([-3 3])
axis manual % freeze axis

xLim = xlim(hAxes);

l = length(varargin);

if l==0
    signalLength = str2double(get(hSignalLength, 'String'));
    changesignallength(hSignalLength)
    addsignal(0:signalLength, zeros(size(0:signalLength)));
    updateplot()
elseif l==1
    load(varargin{1})
    % load does an updateplot by itself
else
    error('Wrong number of input arguments (should be zero or one)');
end;

% -------------------------------------------------------------------------

    function selectmarker(hMarker)
        
        switch get(hFig, 'SelectionType')
            
            case 'normal' % left click: drag
                origWindowButtonMotionFcn = get(hFig,'WindowButtonMotionFcn');
                origWindowButtonUpFcn = get(hFig,'WindowButtonUpFcn');
                
                set(hFig, 'WindowButtonMotionFcn', @(src,evt)drag(hMarker), ...
                    'WindowButtonUpFcn',@(src,evt)releasemarker());
                
            case 'open' % double click: delete
                % Find out to which signal this marker belongs
                signalIndex = signalIndexForMarkers(hMarkers==hMarker);
                if length(hMarkers(signalIndexForMarkers == signalIndex)) > 2
                    signalIndexForMarkers(hMarkers == hMarker) = [];
                    hMarkers(hMarkers == hMarker) = [];
                    delete(hMarker);
                    updateplot()
                else
                    warning('UISIGNALBUILDER:TwoMarkersNeeded', 'Cannot delete this marker. At least two markers are needed for each signal.');
                end
                
            case 'alt' % right click: change coordinates
                prompt = {'X:', 'Y:'};
                dlgTitle = 'Coordinates?';
                numLines = 1;
                defaults = {num2str(get(hMarker, 'XData')), ...
                    num2str(get(hMarker, 'YData'))};
                answer = inputdlg(prompt, dlgTitle, numLines, defaults);
                if ~isempty(answer)
                    set(hMarker, 'XData', str2double(answer{1}), ...
                        'YData', str2double(answer{2}));
                    updateplot()
                end
        end
        
    end

% -------------------------------------------------------------------------

%     function [x_out,y_out] = getclosestgridpoint(x,y)
%         
%         [~,x_ind] = min ( abs(xGrid-x) ); x_out = xGrid(x_ind); 
%         [~,y_ind] = min ( abs(yGrid-y) ); y_out = yGrid(y_ind); 
%     end

% -------------------------------------------------------------------------

    function drag(hMarker)
        cp = get(hAxes, 'CurrentPoint');
        x = cp(1,1);
        y = cp(1,2);
%         if snapGrid
%             [x, y] = getclosestgridpoint(x, y);
%         end
        set(hMarker, 'XData', x, 'YData', y);
        updateplot()
        
    end

% -------------------------------------------------------------------------

    function releasemarker()
        set(hFig,'WindowButtonMotionFcn',origWindowButtonMotionFcn, ...
                 'WindowButtonUpFcn',origWindowButtonUpFcn);
    end

% -------------------------------------------------------------------------

    function updateplot()
        
        idxMethod = get(hInterpMethods, 'Value');
        availableMethods = get(hInterpMethods, 'String');
        chosenMethod = availableMethods{idxMethod};
        
        for i=1:nSignals
            markersForThisSignal = hMarkers(signalIndexForMarkers==i);
            x = cell2mat(get(markersForThisSignal, 'XData'));
            [x, sortOrder] = sort(x);
            y = cell2mat(get(markersForThisSignal, 'YData'));
            y = y(sortOrder);

            % Use specified sampling period for interpolating values
            xi = xLim(1):str2double(get(hSamplingPeriod, 'String')):xLim(2);

            if ~isempty(x)
                try
                    yi = interp1(x, y, xi, chosenMethod);
                catch me
                    if strcmp(me.identifier, 'MATLAB:interp1:RepeatedValuesX') || ...
                       strcmp(me.identifier, 'MATLAB:griddedInterpolant:NonUniqueCompVecsPtsErrId') || ...
                       strcmp(me.identifier, 'MATLAB:griddedInterpolant:NonMonotonicCompVecsErrId')
                        yi = NaN(size(xi)); % plot nothing
                    else
                        disp (me.identifier);
                        rethrow(me)
                    end
                end

                set(hSignal(i), 'XData', xi, 'YData', yi, 'zdata',zeros(size(xi)), 'Visible', 'on');
            end; % else do nothing
        end; % for each signal
    end

% -------------------------------------------------------------------------

   function signalbuttondown(varargin)
        signalNumber = get(varargin{1},'userdata');
        if strcmp(get(hFig, 'SelectionType'), 'open') % double click
            cp = get(hAxes, 'CurrentPoint');
            addmarker(cp(1,1), cp(1,2),signalNumber);
            updateplot();
        end
        
    end

% -------------------------------------------------------------------------

    function addmarker(x,y, signalNumber)
        for k = 1:length(x)
            hMarkers(end+1) = plot(x(k), y(k), 'o', ...
                'MarkerEdgeColor', plotColors(signalNumber,:), ...
                'MarkerFaceColor', 'y', ...
                'MarkerSize', 8, ...
                'hittest','on', ...
                'ButtonDownFcn', @(src,evt)selectmarker(src)); %#ok<AGROW>
            signalIndexForMarkers(end+1) = signalNumber; %#ok<AGROW>
        end
        
    end
% -------------------------------------------------------------------------
    function removeallsignals()
        % Removes all markers and signals (useful just before load)
        
        delete(hMarkers); % Remove the plot
        hMarkers=[]; % Remove handles to the (removed) plot objects
        signalIndexForMarkers = [];
        
        delete(hSignal);
        hSignal = [];
        nSignals = 0;
    end

    function addsignal(markerX,markerY)
        % If no arguments are given, a signal will be made with two
        % (default) key points.
        nSignals = nSignals + 1;
        hSignal(nSignals) = plot3([-1001,-1000],[0,0],[0,0], 'HitTest', 'on', 'buttondownfcn',@signalbuttondown);
        set(hSignal(nSignals),'color',plotColors(nSignals,:),'userdata',nSignals); % in userdata we store the signal number
        
        if exist('markerX','var') && ~isempty(markerX)
            addmarker(markerX,markerY,nSignals)
        else
            signalLength = str2double(get(hSignalLength, 'String'));
            addmarker([0,signalLength],[0,0],nSignals);
        end;

        legendString = cell(nSignals,1);
        for i=1:nSignals
            legendString{i} = sprintf('Signal %d',i);
        end;
        legend(hSignal, legendString);
        updateplot();
    end

% -------------------------------------------------------------------------

    function changeinterpmethod()
        
        updateplot()
        
    end

% -------------------------------------------------------------------------

%     function togglesnapgrid()
%         
%         snapGrid = ~snapGrid;
%         
%     end

% -------------------------------------------------------------------------
    function load(D)
        % Loads the data from a given variable (a struct D)
%         snapGrid = D.snapGrid;
        
        % Set interpolation method
        availableInterpolationMethods = get(hInterpMethods, 'String');
        interpMethodIndex = find(strcmp(D.interpolationMethod,availableInterpolationMethods));
        if isempty(interpMethodIndex), interpMethodIndex = 1; end;
        set(hInterpMethods,'Value',interpMethodIndex);
        
        set(hSamplingPeriod,'String',num2str(D.samplingPeriod));
        set(hSignalLength,'String',num2str(D.signalLength));
        changesignallength(hSignalLength);
        exportSimulinkVariableName = D.exportSimulinkVariableName;
        
        removeallsignals();
        for i=1:D.nSignals
            markerIndices = (D.MarkersSignalIndex == i);
            addsignal(D.MarkersX(markerIndices),D.MarkersY(markerIndices));
        end;
        
        updateplot();
    end
% -------------------------------------------------------------------------

    function loadButton()
        % Asks for a variable name and loads the data from the variable
        
        % Constrcut a list of all compatible structs
        v = evalin('base','who');
        vl = length(v);
        isusableVariable = false(vl,1);
        for i=1:length(v)
            if isstruct(evalin('base',v{i})) && isfield(evalin('base',v{i}),'MarkersX')
                isusableVariable(i) = true;
                
            end;
        end;
        usableVariables = v(isusableVariable);

        [s,~] = listdlg('PromptString','Select a variable:',...
                'SelectionMode','single',...
                'ListString',usableVariables);
            
        if ~isempty(s)
            load(evalin('base',usableVariables{s}));
        else
            disp('Nothing loaded.');
        end;
            
    end
% -------------------------------------------------------------------------
    function save()
        % Generate struct with all data
        D = struct;
        D.MarkersX = cell2mat(get(hMarkers,'xdata'));
        D.MarkersY = cell2mat(get(hMarkers,'ydata'));
        D.MarkersSignalIndex = signalIndexForMarkers;
        D.nSignals = nSignals;
        D.exportSimulinkVariableName = exportSimulinkVariableName;

%         D.snapGrid = snapGrid;
        availableInterpolationMethods = get(hInterpMethods, 'String');
        D.interpolationMethod = availableInterpolationMethods{get(hInterpMethods, 'Value')};
        D.samplingPeriod = str2double(get(hSamplingPeriod, 'String'));
        D.signalLength = str2double(get(hSignalLength, 'String'));
        
        checkLabels = {'Export signals data to struct:'};
        varNames = {'SignalData'};
        items = {D};
        export2wsdlg(checkLabels, varNames, items, 'Save signals data to Workspace');
      
    end
% -------------------------------------------------------------------------

    function export()
        % Exports sampled versions of all signals to the workspace
        
        checkLabels = {'Export X coordinates to variable:'};
        varNames = {'x'};
        items = {get(hSignal(1),'Xdata')};
        for i=1:nSignals
            checkLabels{i+1} = sprintf('Export Y coordinates of signal %d to variable:',i);
            varNames{i+1} = sprintf('y%d_',i);
            items{i+1} = get (hSignal(i),'Ydata');
        end;
        export2wsdlg(checkLabels, varNames, items, 'Export to Workspace');
    end


% -------------------------------------------------------------------------

    function exportsimulink()
        % Exports sampled versions of all signals to the workspace
        
        name = inputdlg('Enter variable name to export to','Enter variable name',1,{exportSimulinkVariableName});
        if isempty(name)
            % Then cancel/close/escape was pressed
            disp('Nothing exported.');
            return;
        end;
        
        name=name{1};
        exportSimulinkVariableName = name; % Save variable name for next time

        D.time = get(hSignal(1),'Xdata')';
        n = length(D.time);
        D.signals.dimensions = nSignals;
        D.signals.values = zeros(n,nSignals);
        for i=1:nSignals,
            D.signals.values(:,i) = get(hSignal(i),'ydata')';
        end;
        assignin('base',name,D);
        disp(['Signals exported to workspace variable ',name,'. Use them with the ''From Workspace'' block in Simulink.']);
    end

% -------------------------------------------------------------------------

    function changesamplingperiod(src)
        
        % Get new sampling period
        newValue = str2double(get(src, 'String'));
        % Validate
        if isempty(newValue)
            warning('UISIGNALBUILDER:InvalidSamplingPeriod', 'Invalid value for sampling period. Resetting to 0.01.');
            newValue = 0.01;
            set(src, 'String', num2str(newValue));
        end
        
        updateplot()
        
    end

% -------------------------------------------------------------------------

    function changesignallength(src)
        
        % Get new sampling period
        newValue = str2double(get(src, 'String'));
        % Validate
        if isempty(newValue)
            warning('UISIGNALBUILDER:InvalidSignalLength', 'Invalid value for signal length. Resetting to 6.');
            newValue = 6;
            set(src, 'String', num2str(newValue));
        end
        xLim = [0 newValue];
        xlim(hAxes, xLim);
       
%         updategrid()
        updateplot()
        
    end

% -------------------------------------------------------------------------

%     function updategrid()
%         
%         delete(hGrid)
         xLim = xlim(hAxes);
%         xGrid = xLim(1):xGridInc:xLim(2);
%         yGrid = yLim(1):yGridInc:yLim(2);
%         [XGrid,YGrid] = meshgrid(xGrid, yGrid);
%         hGrid = plot(XGrid, YGrid, ...
%             'Color', [.6 .6 .6], ...
%             'LineStyle', 'none', ...
%             'Marker', '.', ...
%             'MarkerSize', 1, ...
%             'HitTest', 'off');
%         
%     end

% -------------------------------------------------------------------------

    function showhelp()
        
        mes = {' - Drag a marker to change its position', ...
            ' - Double-click on a signal to insert a marker', ...
            ' - Double-click on a marker to delete it', ...
            ' - Right-click on a marker to fine tune its position',...
            ' - Left-click-drag for panning', ...
            ' - Right-click-drag for zooming', ...
            ' - Middle-click for resetting pan/zoom'};
        uiwait(msgbox(mes,'Help','help','modal'))
        
    end

% -------------------------------------------------------------------------

end
