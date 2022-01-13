
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

% Last Modified by GUIDE v2.5 06-Jan-2022 22:56:14

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
% 创建在callback之间可以共享的数据结构
handles.chainNum = 1;
handles.node_count = 0;
handles.mainGUIhand = hObject; % 保存根对象
guidata(hObject, handles);  % 变更用户数据之后需要保存!


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
global scenario;
node_str = list_getCurrentStr(handles.lb_nodes);
if ~isempty(node_str)  % 排除空节点
    node_name = sprintf('const_%d_%s', handles.chainNum, node_str(1));
    const_child = scenario.getConstellationChild(node_name);
    if ~isempty(const_child) 
        set(handles.lb_objsel, 'str', const_child);  % 清除备选项
    else
        % 如果为创建节点,则刷新
        refresh_list(handles.lb_nodes, handles.lb_objall, handles.lb_objsel);
    end
end


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
    msgbox('最多9级节点!');
    return
end
handles.node_count = handles.node_count + 1;
guidata(hObject, handles);  % 变更用户数据之后需要保存!
addstr = {sprintf('%d级节点', handles.node_count)};
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
% 获取当前lb_objall 选中的项目
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
try
    chainNum = handles.chainNum;
    node_str = list_getCurrentStr(handles.lb_nodes);
    savedname = sprintf('const_%d_%s', chainNum,node_str(1));
    objsel = get(handles.lb_objsel,'string');
    scenario.removeByPath(sprintf('Constellation/%s', savedname));
    scenario.newConstellation(savedname, objsel);
    L = length(objsel);
    showStr = strcat('节点创建成功，共有',num2str(L),'个目标');
    set(handles.creatResult,'String',showStr);
catch
    showStr = strcat('节点创建失败，请重新保存节点！');
    set(handles.creatResult,'String',showStr);
end


% --- Executes on button press in pb_chain.
function pb_chain_Callback(hObject, eventdata, handles)
% hObject    handle to pb_chain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scenario
% scenario.removeByPath('Chain/Chain_add');
objs = {};
chainNum = handles.chainNum;
list = scenario.getAllObjWithChildren();
namePre = strsplit(list{1},'/');
namePre = namePre(1:5);
namePre = strcat(namePre{1},'/',namePre{2},'/',namePre{3},'/',namePre{4},...
    '/',namePre{5},'/');
strname = get(handles.chainName,'String');
 
for i=1:handles.node_count
   objs(end+1) = {strcat(namePre,sprintf('Constellation/const_%d_%d',chainNum,i))};
end
if(isempty(strname))
    chainName = strcat('Chain/',sprintf('chain%d',chainNum));
    strname = sprintf('chain%d',chainNum);
else
    chainName = strcat('Chain/',strname);
end
color = [255*255,255*255*255+255*255+255,255*255+255];
set(handles.chainName,'String',[]);
scenario.removeByPath(chainName);
try
    scenario.newChain(strname,objs.',color(mod(handles.chainNum,3)+1));
    chainPath = strcat(namePre,chainName);
    [~,AERTime] = scenario.accessAER(1,chainPath,sprintf('%s.xlsx',strname));
    AEREndTime = AERTime(end);
    if(AEREndTime > scenario.accessEndTime)
        scenario.accessEndTime = AEREndTime;
    end
    if(abs(scenario.accessEndTime - scenario.FXQEndTime)< (50 / 60 / 60 / 24) )
        scenario.flag = 1;
    else
        scenario.flag = 0;
    end
    scenario.chainNum = handles.chainNum;
    handles.chainNum = handles.chainNum + 1;
    guidata(hObject, handles);  % 变更用户数据之后需要保存!
    refresh_lb_nodes(handles.lb_nodes,hObject,handles);
    % closereq(); % 关闭当前窗口
    showStr = strcat('链路创建成功！');
    set(handles.creatResult,'String',showStr);
catch
    showStr = strcat('链路创建失败，请检查各个节点是否存在空节点！');
    set(handles.creatResult,'String',showStr);
end
    

%% 功能相关函数
function refresh_lb_nodes(lb_nodes,hObject,handles)
set(lb_nodes, 'str', {});  % 清除备选项
handles.node_count = 0;
guidata(hObject, handles);  % 变更用户数据之后需要保存!

function refresh_list(lb_nodes, lb_objall, lb_objsel)
global scenario
allobj = scenario.getAllObjWithChildren();
inx = [];
for i = 1 : length(allobj)
    k = strfind(allobj{i},'Constellation');
    if(~isempty(k))
        inx = [inx,i];
    end
end
allobj(inx) = [];

set(lb_objall,'Value',length(allobj), 'str', allobj);
set(lb_objsel, 'str', {});  % 清除备选项


function str=list_getCurrentStr(listbox)
index_selected = get(listbox,'Value');
allstr = get(listbox,'string');
str = char(allstr(index_selected));


function list_add(listbox, addcell)
oldstr = get(listbox,'string');
if isa(oldstr, 'char')
    % 当只有一个项目是返回的char类型而不是cell类型 需要手动转换以防类型错误
    if strcmp(oldstr, '') % 返回空值, 则删除原有空值, 否则将出现空白项目
        oldstr = addcell;
    else
        oldstr = {oldstr};
        oldstr(end+1) = addcell;
    end
else
    oldstr(end+1) = addcell;
end
set(listbox,'Value',length(oldstr), 'str', oldstr);


function list_removeSelected(listbox)
index_selected = get(listbox,'Value');
oldstr = get(listbox,'string');
oldstr(index_selected) = [];
% set(listbox, 'Value', -1);  % 取消选择
set(listbox,'Value',length(oldstr), 'str', oldstr);


% --- Executes on button press in pb_chain.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pb_chain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function chainName_Callback(hObject, eventdata, handles)
% hObject    handle to chainName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chainName as text
%        str2double(get(hObject,'String')) returns contents of chainName as a double


% --- Executes during object creation, after setting all properties.
function chainName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chainName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_deleteChain.
function pb_deleteChain_Callback(hObject, eventdata, handles)
% hObject    handle to pb_deleteChain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scenario
try
    index_selected = get(handles.lb_objall,'Value');
    allobj = get(handles.lb_objall,'string');
    stkpath = allobj(index_selected);
    scenario.removeByPath(stkpath{1});
    scenario.deleteAccess(stkpath{1});
    showStr = strcat('链路删除成功！');
    set(handles.creatResult,'String',showStr);
catch
    showStr = strcat('链路删除失败，请重新选择！');
    set(handles.creatResult,'String',showStr);
end
