function varargout = mainWindow(varargin)
% MAINWINDOW MATLAB code for mainWindow.fig
%      MAINWINDOW, by itself, creates a new MAINWINDOW or raises the existing
%      singleton*.
%
%      H = MAINWINDOW returns the handle to a new MAINWINDOW or the handle to
%      the existing singleton*.
%
%      MAINWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINWINDOW.M with the given input arguments.
%
%      MAINWINDOW('Property','Value',...) creates a new MAINWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainWindow

% Last Modified by GUIDE v2.5 19-Dec-2021 21:22:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @mainWindow_OutputFcn, ...
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


% --- Executes just before mainWindow is made visible.
function mainWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainWindow (see VARARGIN)

% Choose default command line output for mainWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global OM
OM = actxserver('AgStkObjects11.AgStkObjectRoot');
global scenario
scenario = Scenario(OM);


% --- Outputs from this function are returned to the command line.
function varargout = mainWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pb_animation_playforward.
function pb_animation_playforward_Callback(hObject, eventdata, handles)
% hObject    handle to pb_animation_playforward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scenario
% scenario.startRecordToFile('C:\MyTemp\test.wmv');
scenario.animationPlay();

% --- Executes on button press in pb_animation_stop.
function pb_animation_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pb_animation_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scenario
scenario.animationPause();
% scenario.stopRecordToFile();

% --- Executes on button press in pb_newScenario.
function pb_newScenario_Callback(hObject, eventdata, handles)
% hObject    handle to pb_newScenario (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scenario
% scenario.newAndConfigScenario('Test');
scenario.loadScenario('C:\\Users\\lilacsat\\Documents\\STK 11 (x64)\\test1\\Scenario.sc');


% --- Executes on button press in pb_add_sat.
function pb_add_sat_Callback(hObject, eventdata, handles)
% hObject    handle to pb_add_sat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scenario
scenario.setPeriod('1 Jul 2007 12:00:00.000', '1 Jul 2007 17:00:00.000');
scenario.removeAll();
% (obj, name, color, semimajor_axis_km, eccentricity, inclination_deg, RANN, argument_of_perigee_deg, ture_anomaly_deg)
scenario.insertSatByOrbitalElements('S1', 65280, 7215.65, 2.86383e-16, 60, 57, 0, 135);
scenario.insertSatByOrbitalElements('S2', 65280, 7215.65, 0, 60, 57, 0, 120);
scenario.insertSatByOrbitalElements('S3', 65280, 7215.65, 0, 60, 72, 0, 123);
scenario.insertSatByOrbitalElements('S4', 65280, 7215.65, 0, 60, 72, 0, 113);
scenario.insertSatByOrbitalElements('S5', 65280, 7215.65, 0, 60, 64, 0, 63);
scenario.insertSatByOrbitalElements('ck', 65280, 7215.65, 0, 60, 64, 0, 110);
scenario.insertMissileByEFile('FXQ',55280, 'gj/1.e', 'gj/X47B_UCAV_Cert_v48.mdl');
scenario.insertFacilityByGeo('Xiamen', 16776960, 24.4798, 118.082, 0);
% Const_Sat
objs = {'/Application/STK/Scenario/Scenario/Satellite/S5/Sensor/Sensor';
    '/Application/STK/Scenario/Scenario/Satellite/S4/Sensor/Sensor';
    '/Application/STK/Scenario/Scenario/Satellite/S3/Sensor/Sensor';
    '/Application/STK/Scenario/Scenario/Satellite/S2/Sensor/Sensor';
    '/Application/STK/Scenario/Scenario/Satellite/S1/Sensor/Sensor';
    '/Application/STK/Scenario/Scenario/Satellite/ck/Sensor/Sensor';
    };
scenario.newConstellation('Const_Sat', objs)
% Const_M
objs = {'/Application/STK/Scenario/Scenario/Missile/FXQ/Sensor/SA';
    '/Application/STK/Scenario/Scenario/Missile/FXQ/Sensor/SB';
    };
scenario.newConstellation('Const_M', objs)
% Chain
objs = {'/Application/STK/Scenario/Scenario/Constellation/Const_Sat';
    '/Application/STK/Scenario/Scenario/Constellation/Const_M';
    };
scenario.newChain('Chain', objs);

% --- Executes on button press in pb_test.
function pb_test_Callback(hObject, eventdata, handles)
% hObject    handle to pb_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scenario
% scenario.root.ExecuteCommand('Zoom * Object */Facility/Xiamen 20.0');
% [latitude, longitude, altitude]=scenario.missileGetLLA('/Application/STK/Scenario/Scenario/Missile/FXQ')
 scenario.root.ExecuteCommand('VO * Annotation Time Show On ShowTimeStep Off');
scenario.getCurrentTime()


