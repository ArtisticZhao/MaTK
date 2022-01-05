
%% GUI
function varargout = createChain(varargin)
% CREATECHAIN MATLAB code for createChain.fig
%      CREATECHAIN, by itself, creates a new CREATECHAIN or raises the existing
%      singleton*.
%
%      H = CREATECHAIN returns the handle to a new CREATECHAIN or the handle to
%      the existing singleton*.
%
%      CREATECHAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATECHAIN.M with the given input arguments.
%
%      CREATECHAIN('Property','Value',...) creates a new CREATECHAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createChain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createChain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createChain

% Last Modified by GUIDE v2.5 05-Jan-2022 13:58:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createChain_OpeningFcn, ...
                   'gui_OutputFcn',  @createChain_OutputFcn, ...
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


% --- Executes just before createChain is made visible.
function createChain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createChain (see VARARGIN)

% Choose default command line output for createChain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createChain wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% ������callback֮����Թ�������ݽṹ
handles.node_count = 0;
handles.mainGUIhand = hObject; % ���������
guidata(hObject, handles);  % ����û�����֮����Ҫ����!


% --- Outputs from this function are returned to the command line.
function varargout = createChain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lb_nodes.
function lb_nodes_Callback(hObject, eventdata, handles)
% hObject    handle to lb_nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lb_nodes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_nodes
refresh_list(handles.lb_nodes, handles.lb_objall, handles.lb_objsel);


% --- Executes during object creation, after setting all properties.
function lb_nodes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_newNode.
function pb_newNode_Callback(hObject, eventdata, handles)
% hObject    handle to pb_newNode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.node_count == 9
    msgbox('���9���ڵ�!');
    return
end
handles.node_count = handles.node_count + 1;
guidata(hObject, handles);  % ����û�����֮����Ҫ����!
addstr = {sprintf('%d���ڵ�', handles.node_count)};
list_add(handles.lb_nodes, addstr);
set(handles.lb_nodes, 'Value', handles.node_count);
refresh_list(handles.lb_nodes, handles.lb_objall, handles.lb_objsel);

% --- Executes on selection change in lb_objall.
function lb_objall_Callback(hObject, eventdata, handles)
% hObject    handle to lb_objall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lb_objall contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_objall


% --- Executes during object creation, after setting all properties.
function lb_objall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_objall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lb_objsel.
function lb_objsel_Callback(hObject, eventdata, handles)
% hObject    handle to lb_objsel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lb_objsel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_objsel


% --- Executes during object creation, after setting all properties.
function lb_objsel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_objsel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_remove.
function pb_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pb_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_removeSelected(handles.lb_objsel);

% --- Executes on button press in pb_add.
function pb_add_Callback(hObject, eventdata, handles)
% hObject    handle to pb_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ��ȡ��ǰlb_objall ѡ�е���Ŀ
index_selected = get(handles.lb_objall,'Value');
allobj = get(handles.lb_objall,'string');
stkpath = allobj(index_selected);
list_add(handles.lb_objsel, stkpath);


% --- Executes on button press in pb_save.
function pb_save_Callback(hObject, eventdata, handles)
% hObject    handle to pb_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scenario
node_str = list_getCurrentStr(handles.lb_nodes);
savedname = sprintf('const_%s', node_str(1));
objsel = get(handles.lb_objsel,'string');
scenario.removeByPath(sprintf('Constellation/%s', savedname));
scenario.newConstellation(savedname, objsel);


% --- Executes on button press in pb_chain.
function pb_chain_Callback(hObject, eventdata, handles)
% hObject    handle to pb_chain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scenario
scenario.removeByPath('Chain/Chain_add');
objs = {};
for i=1:handles.node_count
   objs(end+1) = {sprintf('Constellation/const_%d',i)};
end
scenario.newChain('Chain_add', objs);
scenario.accessAER(60);
closereq(); % �رյ�ǰ����


%% ������غ���
function refresh_list(lb_nodes, lb_objall, lb_objsel)
% TODO: ֮���������Զ���ȡ�Ѿ��½�������!
global scenario
allobj = scenario.getAllObjWithChildren();
set(lb_objall, 'str', allobj);
set(lb_objsel, 'str', {});  % �����ѡ��

function str=list_getCurrentStr(listbox)
index_selected = get(listbox,'Value');
allstr = get(listbox,'string');
str = char(allstr(index_selected));


function list_add(listbox, addcell)
oldstr = get(listbox,'string');
if isa(oldstr, 'char')
    % ��ֻ��һ����Ŀ�Ƿ��ص�char���Ͷ�����cell���� ��Ҫ�ֶ�ת���Է����ʹ���
    if strcmp(oldstr, '') % ���ؿ�ֵ, ��ɾ��ԭ�п�ֵ, ���򽫳��ֿհ���Ŀ
        oldstr = addcell;
    else
        oldstr = {oldstr};
        oldstr(end+1) = addcell;
    end
else
    oldstr(end+1) = addcell;
end
set(listbox, 'str', oldstr);


function list_removeSelected(listbox)
index_selected = get(listbox,'Value');
oldstr = get(listbox,'string');
oldstr(index_selected) = [];
set(listbox, 'Value', -1);  % ȡ��ѡ��
set(listbox, 'str', oldstr);
