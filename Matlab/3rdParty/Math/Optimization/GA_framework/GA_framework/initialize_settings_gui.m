function varargout = initialize_settings_gui(varargin)
% INITIALIZE_SETTINGS_GUI MATLAB code for initialize_settings_gui.fig
%      INITIALIZE_SETTINGS_GUI by itself, creates a new INITIALIZE_SETTINGS_GUI or raises the
%      existing singleton*.
%
%      H = INITIALIZE_SETTINGS_GUI returns the handle to a new INITIALIZE_SETTINGS_GUI or the handle to
%      the existing singleton*.
%
%      INITIALIZE_SETTINGS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INITIALIZE_SETTINGS_GUI.M with the given input arguments.
%
%      INITIALIZE_SETTINGS_GUI('Property','Value',...) creates a new INITIALIZE_SETTINGS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before initialize_settings_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to initialize_settings_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help initialize_settings_gui

% Last Modified by GUIDE v2.5 22-Oct-2012 18:50:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @initialize_settings_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @initialize_settings_gui_OutputFcn, ...
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

% --- Executes just before initialize_settings_gui is made visible.
function initialize_settings_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to initialize_settings_gui (see VARARGIN)

% Choose default command line output for initialize_settings_gui
handles.output = 'Yes';

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

%axes(handles.ga);
%logo = [240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,246,248,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,246,252,250,247,240,240,240,240,240,240,240,240,240,240,247,241,230,249,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,247,230,164,202,238,253,255,251,247,240,240,240,240,240,247,249,102,45,228,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,248,152,8,33,86,142,198,236,253,255,252,246,247,250,108,26,48,53,230,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,159,5,7,32,8,26,75,135,191,238,251,110,27,206,239,61,48,228,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,159,6,115,208,149,87,35,0,130,132,23,214,253,250,237,62,50,230,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,162,3,122,255,255,250,102,59,163,24,179,255,240,250,234,56,54,231,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,176,2,99,246,246,254,174,17,234,170,22,177,255,240,250,233,55,53,228,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,173,7,105,248,247,240,249,222,16,181,255,173,24,176,255,240,251,232,55,46,225,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,176,7,115,251,247,240,240,250,252,53,122,255,255,176,31,178,255,240,251,233,57,43,224,252,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,178,8,114,252,247,240,246,247,192,229,123,63,251,240,255,185,32,178,255,240,250,233,56,44,224,252,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,176,8,113,251,247,240,248,232,238,193,59,117,31,231,248,240,255,181,35,186,255,240,251,232,54,45,226,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,176,8,116,251,247,240,251,214,203,246,254,178,14,1,194,251,240,240,255,182,34,192,254,240,251,232,54,46,226,251,240,240,240,240,240,240,249,244,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,174,8,119,252,247,240,253,198,180,240,246,240,255,169,0,140,255,240,240,240,255,172,38,200,254,240,251,231,52,46,227,251,240,240,240,240,253,199,179,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,174,8,120,253,246,240,254,178,123,240,247,240,240,240,255,153,89,250,240,240,240,240,255,167,45,203,253,240,251,229,49,46,226,252,240,240,254,207,36,190,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,174,7,121,252,246,240,254,165,105,237,248,240,240,240,240,240,251,193,238,246,240,240,240,240,255,179,64,214,251,244,251,228,49,44,224,252,253,208,30,25,232,247,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,178,10,123,253,246,246,254,147,79,230,249,240,240,240,240,240,240,240,249,240,240,240,240,240,240,240,255,187,91,221,250,240,251,229,51,43,227,210,32,0,76,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,185,13,122,253,246,246,254,139,58,229,250,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,253,202,110,228,249,240,251,228,46,40,30,65,28,131,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,183,13,121,253,246,246,253,130,51,220,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,252,211,165,234,247,240,252,221,39,67,201,14,188,252,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,179,11,122,253,246,247,253,121,52,224,252,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,250,232,193,240,246,240,251,222,239,165,20,230,248,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,181,11,128,253,246,247,252,113,59,229,251,240,240,240,240,240,249,255,253,253,255,252,246,240,240,240,240,253,250,240,240,240,240,240,247,238,230,247,240,240,248,255,101,65,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,253,182,14,130,255,246,247,252,112,57,229,251,240,240,240,240,240,253,214,126,77,75,112,186,241,246,240,240,247,125,175,252,240,240,240,240,240,251,229,217,247,240,249,252,47,123,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,251,185,4,119,255,246,247,251,108,59,232,250,240,240,240,240,240,253,164,11,30,96,101,56,4,168,253,240,251,204,2,55,240,246,240,240,240,252,222,73,204,255,250,230,170,10,181,252,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,248,219,51,67,239,251,251,109,48,227,251,240,240,240,240,240,251,193,5,97,239,255,255,250,201,210,248,240,255,108,14,9,180,253,240,240,253,216,45,122,198,125,61,17,8,63,235,249,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,251,230,53,72,238,109,45,225,251,240,240,240,240,246,249,254,81,39,240,249,240,246,247,252,249,240,248,226,19,146,69,73,251,240,253,205,32,1,29,18,48,104,165,221,222,133,239,249,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,251,230,60,21,47,221,252,240,246,249,253,255,249,219,216,31,113,255,240,240,241,239,239,240,240,255,140,21,241,177,5,201,255,207,57,62,124,176,221,247,255,255,235,62,5,86,240,249,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,251,229,101,214,255,254,255,240,216,168,116,52,76,214,27,119,255,240,253,113,23,28,140,255,240,43,61,188,172,16,102,255,217,223,251,255,253,248,246,250,235,59,90,219,48,79,240,249,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,248,252,244,209,157,95,41,18,28,0,54,225,254,62,56,251,247,248,194,155,21,117,255,177,2,26,24,26,20,20,220,252,248,240,240,240,240,249,236,62,89,246,254,225,44,78,232,247,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,250,209,42,8,22,70,135,204,93,66,233,251,253,166,0,133,252,255,255,253,39,116,255,72,66,235,231,233,218,24,127,255,240,240,240,240,249,241,73,88,247,248,240,255,127,0,182,252,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,255,146,21,189,234,252,255,177,85,238,250,240,246,250,124,0,58,131,137,89,0,128,209,4,172,255,247,247,255,121,24,229,248,240,240,249,238,73,93,247,248,240,255,150,11,163,251,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,254,85,80,255,248,240,247,210,238,249,240,240,240,246,251,185,91,49,46,73,139,229,162,89,239,247,240,240,249,219,75,193,251,240,249,239,74,92,247,248,246,255,149,9,163,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,246,241,35,139,255,247,240,240,247,227,240,247,240,240,240,240,252,254,248,247,253,255,248,247,252,246,240,240,240,240,247,252,246,240,250,234,66,101,249,248,246,255,143,7,160,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,250,207,10,200,228,231,249,240,246,235,192,240,249,240,240,240,240,240,246,246,240,240,240,240,240,240,240,240,240,240,240,240,240,250,231,64,109,250,247,246,255,142,9,164,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,254,153,29,206,40,64,236,249,240,248,225,162,224,250,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,249,238,68,119,252,247,246,255,142,9,167,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,254,93,45,49,42,27,72,240,249,240,250,212,108,220,252,240,240,240,240,240,240,240,240,249,240,240,240,240,240,240,240,248,238,88,127,252,246,246,255,143,6,161,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,246,240,45,0,53,231,206,22,78,240,249,240,252,202,88,208,253,240,240,240,240,240,246,237,208,252,240,240,240,240,240,247,244,112,147,252,246,246,255,142,4,156,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,250,211,5,53,227,251,254,204,23,77,240,249,240,253,192,62,203,253,240,240,240,240,246,247,89,180,255,240,240,240,246,244,129,162,253,246,246,255,140,5,155,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,254,158,49,227,251,240,240,254,206,25,77,240,249,240,254,178,42,194,254,240,240,240,240,255,126,11,194,254,240,240,248,183,184,252,240,246,255,140,5,155,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,249,164,217,251,240,240,240,240,254,207,25,80,244,248,240,255,173,38,198,253,240,240,240,252,183,0,24,202,253,247,205,207,251,240,246,254,137,5,157,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,248,240,240,240,240,240,240,254,207,25,82,244,248,240,255,164,38,207,253,240,240,248,224,27,101,56,210,236,227,248,240,246,254,133,4,158,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,254,206,23,82,244,248,240,255,157,39,206,253,240,246,248,53,138,209,182,247,246,240,246,254,134,4,159,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,254,204,23,84,240,248,240,255,149,39,209,253,240,255,108,65,255,250,240,240,246,254,135,4,157,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,254,204,22,85,240,248,240,255,149,36,201,254,253,168,21,229,248,240,246,252,126,3,154,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,254,206,25,84,244,248,240,255,146,29,199,255,216,13,186,252,246,247,116,3,158,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,253,210,31,84,240,248,240,255,147,26,195,254,43,121,255,255,253,94,5,188,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,253,213,31,84,246,248,240,255,150,26,195,112,2,61,119,180,223,96,15,185,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,253,211,28,92,248,248,255,188,13,157,234,163,102,47,12,16,50,7,16,186,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,253,208,27,90,251,181,16,141,252,248,254,255,247,220,171,109,58,13,14,176,250,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,253,212,33,57,18,138,254,246,240,240,240,246,249,253,255,247,222,174,145,232,247,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,253,209,28,133,254,246,240,240,240,240,240,240,240,240,246,249,253,252,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,250,227,246,246,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,248,246,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240;];
%imshow(uint8(logo));

% Gets the proper values from the settings input
settings = varargin{1};

set(handles.n_ind,'String',num2str(settings.n_ind));

set(handles.mp,'Value',settings.mp);
str = ['Mutation Probability = ', num2str(get(handles.mp,'Value')*100), '%'];
set(handles.text4,'String',str);

set(handles.cp,'Value',settings.cp);
str = ['Crossover Probability = ', num2str(get(handles.cp,'Value')*100), '%'];
set(handles.text5,'String',str);

set(handles.parents_per_crossover,'String',num2str(settings.parents_per_crossover));

set(handles.parent_children_competition,'Value',settings.parent_children_competition);

set(handles.elitism,'Value',settings.elitism);
str = ['Elitism = ', num2str(get(handles.elitism,'Value')*100), '%'];
set(handles.text7,'String',str);

handles.scaling_functions = {'off','rank','linear','sigma'};
set(handles.scaling,'String',{'Off','Rank based','Linear function','Sigma Scaling'});
value = find(strcmp(settings.scaling,handles.scaling_functions));
set(handles.scaling,'Value',value);

handles.selection_functions = {'roulette','srs','tournament'};
set(handles.selection,'String',{'Roulette Wheel','SRS','Tournaments'});
value = find(strcmp(settings.selection,handles.selection_functions));
set(handles.selection,'Value',value);

handles.adaptation_functions = {'off','individual','populational'};
set(handles.adaptation,'String',{'Off','Individual','Populational'});
value = find(strcmp(settings.adaptation,handles.adaptation_functions));
set(handles.adaptation,'Value',value);

handles.multiobjective_functions = {'scalar','piceag'};
set(handles.multiobjective_treatment,'String',{'Scalar Summatory','PICEA-g'});
value = find(strcmp(settings.multiobjective_treatment,handles.multiobjective_functions));
set(handles.multiobjective_treatment,'Value',value);

set(handles.max_pareto,'String',num2str(settings.max_pareto));

if settings.n_ger == inf
    set(handles.max_gen,'Value',false);
    set(handles.n_ger,'String', '200');
    set(handles.n_ger,'Enable', 'off');
else
    set(handles.max_gen,'Value',true);
    set(handles.n_ger,'String', num2str(settings.n_ger));
    set(handles.n_ger,'Enable', 'on');
end

if settings.tenure == inf
    set(handles.max_tenure,'Value',false);
    if settings.n_ger == inf
        set(handles.tenure,'String', '70');
    else
        set(handles.tenure,'String', num2str(round(settings.n_ger/3)));
    end
    set(handles.tenure,'Enable', 'off');
else
    set(handles.max_tenure,'Value',true);
    set(handles.tenure,'String', num2str(round(settings.tenure)));
    set(handles.tenure,'Enable', 'on');
end

if settings.time_lim == inf
    set(handles.max_time,'Value',false);
    set(handles.time_lim,'String', '300');
    set(handles.time_lim,'Enable', 'off');
else
    set(handles.max_time,'Value',true);
    set(handles.time_lim,'String', num2str(settings.time_lim));
    set(handles.time_lim,'Enable', 'on');
end

set(handles.print,'Value',settings.print);

set(handles.realtime_control,'Value',settings.realtime_control);

set(handles.takeover_reinitialize,'Value',settings.takeover_reinitialize);


% saves the original settings to the handles
handles.settings = settings;

% Update handles structure
guidata(hObject, handles);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes initialize_settings_gui wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = initialize_settings_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% if the user is proceeding with his adjustments, we define the new
% settings
if handles.output

    % Number of individuals
    settings.n_ind = str2num(get(handles.n_ind,'String'));

    % Initial mutation probability
    settings.mp = get(handles.mp,'Value');

    % Initial crossover probability
    settings.cp = get(handles.cp,'Value');

    % Number of parents involved in a crossover operation
    settings.parents_per_crossover = str2num(get(handles.parents_per_crossover,'String'));

    % Parents compete with children
    settings.parent_children_competition = get(handles.parent_children_competition,'Value');

    % Percentage of elitism
    settings.elitism = get(handles.elitism,'Value');

    % Scaling method
    settings.scaling = handles.scaling_functions{get(handles.scaling,'Value')};

    % Selection Method
    settings.selection = handles.selection_functions{get(handles.selection,'Value')};

    % Adaptation of setting
    settings.adaptation = handles.adaptation_functions{get(handles.adaptation,'Value')};
    
    % Multiobjective treatment
    settings.multiobjective_treatment = handles.multiobjective_functions{get(handles.multiobjective_treatment,'Value')};
    
    % Max Pareto
    settings.max_pareto = str2num(get(handles.max_pareto,'String'));


    % Number of generations (Halting criteria)
    if get(handles.max_gen,'Value')
        settings.n_ger = str2num(get(handles.n_ger,'String'));
    else
        settings.n_ger = inf;
    end

    % Max generations without improvement (Halting criteria)
    if get(handles.max_tenure,'Value')
        settings.tenure = str2num(get(handles.tenure,'String'));
    else
        settings.tenure = inf;
    end

    % Time limit (in seconds) (Halting criteria)
    if get(handles.max_time,'Value')
        settings.time_lim = str2num(get(handles.time_lim,'String'));
    else
        settings.time_lim = inf;
    end

    % Will we print the results after each generation
    settings.print = get(handles.print,'Value');
    
    % Do you want to control de evolution in real time
    settings.realtime_control = get(handles.realtime_control,'Value');

    % Auto reinitializes the population if median individual == best
    settings.takeover_reinitialize = get(handles.takeover_reinitialize,'Value');
   
else
    %if the user has pushed the cancel button, we just use the old settings
    settings = handles.settings;
end



varargout{1} = settings;
varargout{2} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    handles.output = 0;
    guidata(hObject, handles);
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    



function n_ind_Callback(hObject, eventdata, handles)
% hObject    handle to n_ind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_ind as text
%        str2double(get(hObject,'String')) returns contents of n_ind as a double

value = str2num(get(hObject,'String'));
if isempty(value)
    % if it is not a valid value, restore the original value
    set(hObject,'String', num2str(handles.settings.n_ind));
else
    % if it is a valid value, converts it to integer to make sure
    set(hObject,'String', num2str(round(str2num(get(hObject,'String')))));
end
    


% --- Executes during object creation, after setting all properties.
function n_ind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_ind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in print.
function print_Callback(hObject, eventdata, handles)
% hObject    handle to print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of print


% --- Executes on slider movement.
function mp_Callback(hObject, eventdata, handles)
% hObject    handle to mp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

str = ['Mutation Probability = ', num2str(get(hObject,'Value')*100), '%'];
set(handles.text4,'String',str);



% --- Executes during object creation, after setting all properties.
function mp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function cp_Callback(hObject, eventdata, handles)
% hObject    handle to cp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

str = ['Crossover Probability = ', num2str(get(hObject,'Value')*100), '%'];
set(handles.text5,'String',str);



% --- Executes during object creation, after setting all properties.
function cp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function parents_per_crossover_Callback(hObject, eventdata, handles)
% hObject    handle to parents_per_crossover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of parents_per_crossover as text
%        str2double(get(hObject,'String')) returns contents of parents_per_crossover as a double

value = str2num(get(hObject,'String'));
if isempty(value)
    % if it is not a valid value, restore the original value
    set(hObject,'String', num2str(handles.settings.parents_per_crossover));
else
    % if it is a valid value, converts it to integer to make sure
    set(hObject,'String', num2str(round(str2num(get(hObject,'String')))));
end


% --- Executes during object creation, after setting all properties.
function parents_per_crossover_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parents_per_crossover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function elitism_Callback(hObject, eventdata, handles)
% hObject    handle to elitism (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

str = ['Elitism = ', num2str(get(hObject,'Value')*100), '%'];
set(handles.text7,'String',str);



% --- Executes during object creation, after setting all properties.
function elitism_CreateFcn(hObject, eventdata, handles)
% hObject    handle to elitism (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in scaling.
function scaling_Callback(hObject, eventdata, handles)
% hObject    handle to scaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scaling contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scaling


% --- Executes during object creation, after setting all properties.
function scaling_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in adaptation.
function adaptation_Callback(hObject, eventdata, handles)
% hObject    handle to adaptation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns adaptation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from adaptation


% --- Executes during object creation, after setting all properties.
function adaptation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to adaptation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in max_gen.
function max_gen_Callback(hObject, eventdata, handles)
% hObject    handle to max_gen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of max_gen

if get(hObject,'Value')
    set(handles.n_ger, 'Enable', 'on');
else
    set(handles.n_ger, 'Enable', 'off');
end


% --- Executes on button press in max_tenure.
function max_tenure_Callback(hObject, eventdata, handles)
% hObject    handle to max_tenure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of max_tenure

if get(hObject,'Value')
    set(handles.tenure, 'Enable', 'on');
else
    set(handles.tenure, 'Enable', 'off');
end


% --- Executes on button press in max_time.
function max_time_Callback(hObject, eventdata, handles)
% hObject    handle to max_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of max_time

if get(hObject,'Value')
    set(handles.time_lim, 'Enable', 'on');
else
    set(handles.time_lim, 'Enable', 'off');
end


function n_ger_Callback(hObject, eventdata, handles)
% hObject    handle to n_ger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_ger as text
%        str2double(get(hObject,'String')) returns contents of n_ger as a double


% --- Executes during object creation, after setting all properties.
function n_ger_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_ger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tenure_Callback(hObject, eventdata, handles)
% hObject    handle to tenure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tenure as text
%        str2double(get(hObject,'String')) returns contents of tenure as a double


% --- Executes during object creation, after setting all properties.
function tenure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tenure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in parent_children_competition.
function parent_children_competition_Callback(hObject, eventdata, handles)
% hObject    handle to parent_children_competition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of parent_children_competition



function time_lim_Callback(hObject, eventdata, handles)
% hObject    handle to time_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_lim as text
%        str2double(get(hObject,'String')) returns contents of time_lim as a double


% --- Executes during object creation, after setting all properties.
function time_lim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)
% hObject    handle to go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = 1;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = 0;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on selection change in selection.
function selection_Callback(hObject, eventdata, handles)
% hObject    handle to selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selection


% --- Executes during object creation, after setting all properties.
function selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on n_ind and none of its controls.
function n_ind_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to n_ind (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ga_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ga (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ga


% --- Executes on button press in realtime_control.
function realtime_control_Callback(hObject, eventdata, handles)
% hObject    handle to realtime_control (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of realtime_control


% --- Executes on button press in takeover_reinitialize.
function takeover_reinitialize_Callback(hObject, eventdata, handles)
% hObject    handle to takeover_reinitialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of takeover_reinitialize


% --- Executes on selection change in multiobjective_treatment.
function multiobjective_treatment_Callback(hObject, eventdata, handles)
% hObject    handle to multiobjective_treatment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns multiobjective_treatment contents as cell array
%        contents{get(hObject,'Value')} returns selected item from multiobjective_treatment

% Finds out what the user chose
options = get(hObject,'String');
option = options{get(hObject,'Value')};
% If it is an specific algorithm, we block the options which are
%                                       special of that approach
if (strcmp(option,'PICEA-g'))&&(strcmp(questdlg('Do you want to load other default PICEA-g parameters?','PICEA-g','Yes','No','I don''t know','Yes'),'No')==0)    
    set(handles.elitism,'Value',1);
    set(handles.text7, 'String', 'Default PICEA-g Elitism = 100%');
    set(handles.parent_children_competition, 'Value', 1);
    
else
    % If the option is not special, we make sure the parameters are free
    set(handles.elitism,'Value',handles.settings.elitism);
    set(handles.text7, 'String', ['Elitism = ', num2str(get(handles.elitism,'Value')*100),'%']);
    set(handles.parent_children_competition, 'Value', handles.settings.parent_children_competition);
end

% --- Executes during object creation, after setting all properties.
function multiobjective_treatment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to multiobjective_treatment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_pareto_Callback(hObject, eventdata, handles)
% hObject    handle to max_pareto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_pareto as text
%        str2double(get(hObject,'String')) returns contents of max_pareto as a double

value = str2num(get(hObject,'String'));
if isempty(value)
    % if it is not a valid value, restore the original value
    set(hObject,'String', num2str(handles.settings.max_pareto));
else
    % if it is a valid value, converts it to integer to make sure
    set(hObject,'String', num2str(round(str2num(get(hObject,'String')))));
end



% --- Executes during object creation, after setting all properties.
function max_pareto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_pareto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
