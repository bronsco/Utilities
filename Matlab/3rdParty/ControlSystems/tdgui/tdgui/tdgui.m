function varargout = tdgui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tdgui_OpeningFcn, ...
                   'gui_OutputFcn',  @tdgui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tdgui is made visible.
function tdgui_OpeningFcn(hObject, eventdata, handles, varargin)
clear global;
% Display Github logo on GUI
axes(handles.imgaxis)
imshow('github.png');

% Choose default command line output for tdgui
handles.output = hObject;

% Initialize used variaables
handles.tdguidata.num='[5]';
handles.tdguidata.den='[10 1]';

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = tdgui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function den_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function num_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function num_Callback(hObject, ~, handles)

% Read numerator coefficients
num=str2num(get(hObject,'String'));
if isnan(num)
    num=[5];
    set(hObject,'String',num2str(num));
    errordlg('Numerator must be a scalar or row vector','Error');
end

%Save numerator data
handles.tdguidata.num=num2str(num);

% Update handles structure
guidata(hObject, handles);

function den_Callback(hObject, ~, handles)

% Read denominator coefficients
den=str2num(get(hObject,'String'));
if isnan(den)
    den=[10 1];
    set(hObject,'String',str2num(den));
    errordlg('Denominator must be a scalar or row vector','Error');
end

% Save denominator data
handles.tdguidata.den=num2str(den);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in calculate.
function calculate_Callback(hObject, ~, handles)

%Read transfer function coefficients
num=str2num(handles.tdguidata.num);
den=str2num(handles.tdguidata.den);

% Display Transfer function
Wp=tf(num,den);
g=evalc('Wp');
set(handles.transferfunction,'String',g);

% Plot unit step reponse
axes(handles.stepaxis);
[y,t]=step(Wp);
plot(t,y),...
    xlabel('Time'),...
    ylabel('Response'),...
    title('Unit Step Response');

% Plot impulse reponse
axes(handles.impulseaxis);
[y,t]=impulse(Wp);
plot(t,y),...
    xlabel('Time'),...
    ylabel('Response'),...
    title('Impulse Response');

function transferfunction_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function transferfunction_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
