function obj = editModelObject(obj)
%% editModelObject GUI for editing model object descriptions.
%
%   Graphical user interface to edit the descriptions of the in- and outputs
%   as well as the description of the whole model object. Furthermore you
%   can edit what data should be treated as in- and output.
%
%
%       [obj] = editModelObject(obj)
%
%
%   EDITMODELOBJECT input:
%
%       obj - (class) dataSet object
%
%
%   EDITMODELOBJECT output:
%
%       obj - (class) dataSet object
%
%
%   See also dataSet, editDataSet, loadDataSet, saveDataSet.
%
%
%   LMNtool - Local Model Network Toolbox
%   Julian Belz, 21-November-2011
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles


% check if there is data defined already
if isempty(obj.input) || isempty(obj.output)
    msgbox(['There is no data defined yet. To edit the dataSet-object ',...
        'define obj.input and obj.output first!'],'Error','error');
    return;
end

% Some definitions for the figure itself
bgcolor  = [0.7 0.7 0.7];
scrsize  = get(0,'screensize');
width    = 500;
numberOfDataSeries = size(obj.input,2)+size(obj.output,2);
height   = 60+(1+numberOfDataSeries)*30-5+25+15+10;
% Some definitions for the components of the figure
posfh    = [(scrsize(3)-width)/2,...
    (scrsize(4)-height)/2,...
    width height];
xVar         = 15;
textName     = [xVar height-25 155 15];
editName     = [xVar height-50 210 20];
textEingang  = [270 editName(2) 45 15];
textAusgang  = [335 editName(2) 50 15];
textzEingang = [410 editName(2) 50 15];
textVar      = [xVar height-80 150 15];
ResetButton  = [130 15 100 30];
OkButton     = [15 15 100 30];
yStartVar    = height-105;
xCB1         = 280;
xCB2         = 355;
xCB3         = 430;
cbwidth      = 20;
cbheight     = 20;


% Main Figure
fh = figure('Visible','off',...
    'Units','pixels',...
    'MenuBar','none',...
    'ToolBar','figure',...
    'Position',posfh,...
    'Tag','mainFigure',...
    'Color',bgcolor);


% Description of the first edit field
htextName = uicontrol(fh,...
    'Style','text',...
    'Position',textName,...
    'HorizontalAlignment','left',...
    'String','Dataset description:');

heditName = uicontrol(fh,...
    'Style','edit',...
    'Position',editName,...
    'String',obj.info.dataSetDescription);

htextEingang = uicontrol(fh,...
    'Style','text',...
    'Position',textEingang,...
    'String','xInput');

htextAusgang = uicontrol(fh,...
    'Style','text',...
    'Position',textAusgang,...
    'String','Output');

htextzEingang = uicontrol(fh,...
    'Style','text',...
    'Position',textzEingang,...
    'String','zInput');

htextVar = uicontrol(fh,...
    'Style','text',...
    'Position',textVar,...
    'HorizontalAlignment','left',...
    'String','Input descriptions:');

% Loop over all data series
hEditVar = cell(numberOfDataSeries,1);
hCB1     = hEditVar;
hCB2     = hEditVar;
hCB3     = hEditVar;
for jj = 0:numberOfDataSeries-1
    % Fields to change the description of the corresponding in- or output
    hEditVar{jj+1,1} = uicontrol(fh,...
        'Style','edit',...
        'Position',[xVar, yStartVar-jj*30,...
        editName(3), editName(4)],...
        'String','');
    
    % Check-Boxes
    hCB1{jj+1,1} = uicontrol(fh,'Style','checkbox',...
        'String','',...
        'Value',0,'Position',[xCB1, yStartVar-jj*30,...
        cbwidth, cbheight],...
        'Callback',@cb_callback);
    
    hCB2{jj+1,1} = uicontrol(fh,'Style','checkbox',...
        'String','',...
        'Value',0,'Position',[xCB2, yStartVar-jj*30,...
        cbwidth cbheight],...
        'Callback',@cb_callback);
    
    hCB3{jj+1,1} = uicontrol(fh,'Style','checkbox',...
        'String','',...
        'Value',0,'Position',[xCB3, yStartVar-jj*30,...
        cbwidth cbheight],...
        'Callback',@cb_callback);
end

% Make sure the x- and z-input-delays as well as the x- and z-output-delays
% are set
obj = obj.getXinputDelay;
obj = obj.getZinputDelay;
obj = obj.getXoutputDelay;
obj = obj.getZoutputDelay;

% set data-matrix with all inputs and outputs
data         = [obj.unscaledInput obj.unscaledOutput];

% pre-define colum indices
xInputColum  = 1:size(obj.input,2);
zInputColum  = xInputColum;
xOutputColum = (size(obj.input,2)+1):(size(obj.input,2)+size(obj.output,2));
zOutputColum = xOutputColum;

% 
for jj = 1:size(obj.input,2)
    if isempty(obj.xInputDelay{jj})
        xInputColum(jj) = [];
    end
    if isempty(obj.zInputDelay{jj})
        zInputColum(jj) = [];
    end
end
%%%%%%%%%%%%%%%%%%%
% The following loop is only necessary for dynamic models where delayed
% outputs are considered. This small GUI to rename inputs, etc. is only
% able to deal with static models so far.
% for jj = 1:size(obj.output,2)
%     if isempty(obj.xOutputDelay{jj})
%         xOutputColum(jj) = [];
%     end
%     if isempty(obj.zOutputDelay{jj})
%         zOutputColum(jj) = [];
%     end
% end
%%%%%%%%%%%%%%%%%%
info = [obj.info.inputDescription obj.info.outputDescription];

% Put current descriptions in the corresponding fields
zuruecksetzen;

hButtonOK = uicontrol('Parent',fh,...
    'Style','Pushbutton',...
    'String','Accept',...
    'Enable','on',...
    'Position',OkButton,...
    'Callback',@uebernehmen);

hButtonReset = uicontrol('Parent',fh,...
    'Style','Pushbutton',...
    'String','Reset values',...
    'Enable','on',...
    'Position',ResetButton,...
    'Callback',@zuruecksetzen);

set([htextName,htextEingang,htextAusgang,htextVar,...
    hCB1{:},hCB2{:},hButtonOK,hButtonReset,htextzEingang],...
    'BackgroundColor',bgcolor)

set([heditName,hEditVar{:}],'BackgroundColor',[1 1 1])

set([hButtonReset,hButtonOK,hCB2{:},hCB1{:},hEditVar{:},...
    htextVar,htextAusgang,htextEingang,heditName],...
    'Units','normalized')
set(fh,'Visible','on');

% Functions

    function cb_callback(hObject,eventdata)
        size(eventdata);
        cb1 = false;
        cb2 = false;
        cb3 = false;
        % Get row of the checkbox, which called this function
        [~,~,element1] = intersect(hObject,cell2mat(hCB1));
        [~,~,element2] = intersect(hObject,cell2mat(hCB2));
        [~,~,element3] = intersect(hObject,cell2mat(hCB3));
        
        if ~isempty(element1)
            element = element1;
            cb1     = true;
        elseif ~isempty(element2)
            element = element2;
            cb2     = true;
        else
            element = element3;
            cb3     = true;
        end
        
        cbFlag = get(hObject,'Value'); % Value = 0 or = 1
        if cbFlag && cb1
            % cbFlag - 1 = 0 or = -1
            set(hCB2{element},'Value',0);
            set(hCB3{element},'Value',1);
        elseif cbFlag && cb3
            set(hCB2{element},'Value',0);
            set(hCB1{element},'Value',1);
        elseif ~cbFlag && cb1
            set(hCB2{element},'Value',1);
            set(hCB3{element},'Value',0);
        elseif cb2
            set([hCB1{element} hCB3{element}],'Value',...
                abs(cbFlag-1));
        end
    end % end cb_callback

    function uebernehmen(hObject,eventdata)
        size(hObject);
        size(eventdata);
        % Change dataSet object description
        obj.info.dataSetDescription   = get(heditName,'String');
        xInput     = [];
        Output     = [];
        zInput     = [];
        for ii = 1:numberOfDataSeries
            cb1 = get(hCB1{ii},'Value');
            cb2 = get(hCB2{ii},'Value');
            cb3 = get(hCB3{ii},'Value');
            
            % Determine if current row should be an in- or output
            if cb1
                xInput = [xInput ii]; %#ok<AGROW>
                if cb3
                    zInput = [zInput true]; %#ok<AGROW>
                else
                    zInput = [zInput false];  %#ok<AGROW>
                end
            elseif cb2
                Output = [Output ii]; %#ok<AGROW>
            end
            
            % Set descriptions of the in- and outputs
            info{ii}    = get(hEditVar{ii},'String');
        end
        obj.input       = data(:,xInput);
        obj.output      = data(:,Output);
        obj.zInputDelay = cell(1,size(obj.input,2));
        obj.zInputDelay(logical(zInput)) = {0};
        obj.info.inputDescription   = info(1,xInput);
        obj.info.outputDescription  = info(1,Output);
        close(fh);
    end % end uebernehmen

    function zuruecksetzen(varargin)
        size(varargin);
        set(heditName,'String',obj.info.dataSetDescription);
        for ii = 0:numberOfDataSeries-1
            set(hEditVar{ii+1,1},'String',info{ii+1});
            
            if ~isempty(xInputColum) &&...
                    ~isempty(xOutputColum)
                tmpIn  = intersect(ii+1,xInputColum);
                tmpOut = intersect(ii+1,xOutputColum);
                tmpZ   = intersect(ii+1,zInputColum);
                if isempty(tmpIn) && isempty(tmpOut)
                    invalue  = 0;
                    outvalue = 0;
                elseif isempty(tmpIn)
                    outvalue = 1;
                    invalue  = 0;
                else
                    outvalue = 0;
                    invalue  = 1;
                end
            else
                invalue  = 0;
                outvalue = 0;
            end
            
            set(hCB1{ii+1,1},'Value',invalue);
            set(hCB2{ii+1,1},'Value',outvalue);
            
            if ~exist('tmpZ','var') || isempty(tmpZ)
                set(hCB3{ii+1,1},'Value',0);
            else
                set(hCB3{ii+1,1},'Value',1);
            end
        end
        
    end % end zuruecksetzen

waitfor(fh); % This statement makes sure, that all changes are not saved 
             % until the figure is closed.
             
end % end edit