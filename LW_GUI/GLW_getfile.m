function varargout = GLW_getfile(varargin)
% GLW_GETFILE MATLAB code for GLW_getfile.fig
%      GLW_GETFILE, by itself, creates a new GLW_GETFILE or raises the existing
%      singleton*.
%
%      H = GLW_GETFILE returns the handle to a new GLW_GETFILE or the handle to
%      the existing singleton*.
%
%      GLW_GETFILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_GETFILE.M with the given input arguments.
%
%      GLW_GETFILE('Property','Value',...) creates a new GLW_GETFILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_getfile_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_getfile_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_getfile

% Last Modified by GUIDE v2.5 27-Nov-2015 15:00:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_getfile_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_getfile_OutputFcn, ...
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


% --- Executes just before GLW_getfile is made visible.
function GLW_getfile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_getfile (see VARARGIN)

% Choose default command line output for GLW_getfile
handles.file_str = 0;
handles.file_path = 0;
handles.virtual_filelist=[];
if ~isempty(varargin)
    handles.virtual_filelist=cellstr(varargin{1});
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GLW_getfile wait for user response (see UIRESUME)
filepath=pwd;
set(handles.path_edit,'String',pwd);
set(handles.path_edit,'Userdata',pwd);
update(handles);
set(handles.figure1,'WindowStyle','modal');
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GLW_getfile_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.file_str;
varargout{2} = handles.file_path;
delete(hObject);

% --- Executes on selection change in affix_selected_listbox.
function affix_selected_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to affix_selected_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns affix_selected_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from affix_selected_listbox
set(handles.isfilter_checkbox,'value',1);
update(handles);

% --- Executes during object creation, after setting all properties.
function affix_selected_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to affix_selected_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function file_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function path_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function path_edit_Callback(hObject, eventdata, handles)
% hObject    handle to path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of path_edit as text
%        str2double(get(hObject,'String')) returns contents of path_edit as a double
st=get(handles.path_edit,'String');
if exist(st,'dir')
    update(handles);
else
    st=get(handles.path_edit,'userdata');
    set(handles.path_edit,'String',st);
end

% --- Executes on button press in path_btn.
function path_btn_Callback(hObject, eventdata, handles)
% hObject    handle to path_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
st=get(handles.path_edit,'String');
st=uigetdir(st);
if ~isequal(st,0) && exist(st,'dir')==7
    set(handles.path_edit,'String',st);
    update(handles);
end

% --- Executes on button press in refresh_btn.
function refresh_btn_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update(handles);

% --- Executes on selection change in affix_baned_listbox.
function affix_baned_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to affix_baned_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns affix_baned_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from affix_baned_listbox

set(handles.isfilter_checkbox,'value',1);
update(handles);

% --- Executes during object creation, after setting all properties.
function affix_baned_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to affix_baned_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in file_listbox.
function file_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to file_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns file_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from file_listbox
if strcmp(get(gcf,'SelectionType'),'open')
    OK_btn_Callback(hObject, eventdata, handles);
end

% --- Executes on button press in OK_btn.
function OK_btn_Callback(hObject, eventdata, handles)
% hObject    handle to OK_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx=get(handles.file_listbox,'value');
file_str=[];
file_path=0;
if ~isempty(idx)
    str=get(handles.file_listbox,'String');
    str=strrep(str,'<HTML><BODY color="red">','');
    file_path=get(handles.path_edit,'userdata');
    if ~isempty(str)
        for k=1:length(idx)
            file_str{k}=char(str(idx(k)));
        end
    end
end
handles.file_str  = file_str;
handles.file_path = file_path;
guidata(hObject, handles);
close(handles.figure1);

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.figure1);

% --- Executes on button press in isfilter_checkbox.
function isfilter_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isfilter_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isfilter_checkbox
update(handles);


function affix=find_affix(filelist)
if isempty(filelist)
    affix={};
else
    st=textscan(strjoin(filelist,' '),'%s');
    affix=sort(unique(st{1}));
end

function update(handles)
st=get(handles.path_edit,'String');
if exist(st,'dir')~=7
    return;
end
set(handles.path_edit,'userdata',st);
d=dir([st,filesep,'*.lw6']);
filelist=cell(1,length(d));
for k=1:length(d)
    filelist{k}=d(k).name(1:end-4);
end
if strcmp(fullfile(st,'0'),fullfile(pwd,'0'))
    for k=1:length(handles.virtual_filelist)
        if ~strcmp(handles.virtual_filelist{k},filelist)
            filelist{end+1}=handles.virtual_filelist{k};
        end
    end
end

affix=find_affix(filelist);

idx=get(handles.affix_selected_listbox,'value');
str=get(handles.affix_selected_listbox,'String');
if isempty(str)
    selected_str=[];
else
    selected_str=str(idx);
end

idx=get(handles.affix_baned_listbox,'value');
str=get(handles.affix_baned_listbox,'String');
if isempty(str)
    baned_str=[];
else
    baned_str=str(idx);
end

idx=get(handles.file_listbox,'value');
str=get(handles.file_listbox,'String');
str=strrep(str,'<HTML><BODY color="red">','');
if isempty(str)
    file_str=[];
else
    file_str=str(idx);
end

is_filter=get(handles.isfilter_checkbox,'value');
if is_filter==1
    set(handles.affix_selected_listbox,'string',affix);
    [~,selected_idx]=intersect(affix,selected_str,'stable');
    set(handles.affix_selected_listbox,'value',selected_idx);
    
    if isempty(selected_idx)
        selected_file_index=1:length(filelist);
    else
        selected_file_index=[];
        for k=1:length(filelist)
            st=textscan(filelist{k},'%s');
            st=unique(st{1});
            if isempty(setdiff(affix(selected_idx),st))
                selected_file_index=[selected_file_index,k];
            end
        end
    end
    
    if isempty(selected_file_index)
        set(handles.file_listbox,'String',{});
        set(handles.file_listbox,'value',[]);
        set(handles.affix_baned_listbox,'String',{});
        set(handles.affix_baned_listbox,'value',[]);
    else
        affix_baned=find_affix(filelist(selected_file_index));
        affix_baned=setdiff(affix_baned,affix(selected_idx));
        [~,baned_idx]=intersect(affix_baned,baned_str,'stable');
        set(handles.affix_baned_listbox,'String',affix_baned);
        set(handles.affix_baned_listbox,'value',baned_idx);
        
        band_file_index=[];
        for j=selected_file_index
            st=textscan(filelist{j},'%s');
            st=unique(st{1});
            if isempty(intersect(affix_baned(baned_idx),st))
                band_file_index=[band_file_index,j];
            end
        end
        set(handles.file_listbox,'String',filelist(band_file_index));
        [~,idx]=intersect(filelist(band_file_index),file_str,'stable');
        set(handles.file_listbox,'value',idx);
    end
else
    set(handles.affix_selected_listbox,'string',affix);
    set(handles.affix_selected_listbox,'value',[]);
    set(handles.affix_baned_listbox,'string',affix);
    set(handles.affix_baned_listbox,'value',[]);
    set(handles.file_listbox,'string',filelist);
    [~,idx]=intersect(filelist,file_str,'stable');
    set(handles.file_listbox,'value',idx);
end

st=get(handles.path_edit,'userdata');
if strcmp(fullfile(st,'0'),fullfile(pwd,'0'))
    filelist=get(handles.file_listbox,'String');
    for k=1:length(filelist)
        if sum(strcmp(handles.virtual_filelist,filelist{k}))
            filelist{k}=['<HTML><BODY color="red">',filelist{k}];
        end
    end
end
set(handles.file_listbox,'String',filelist);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.figure1);
