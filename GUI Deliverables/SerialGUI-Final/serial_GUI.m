function varargout = serial_GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @serial_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @serial_GUI_OutputFcn, ...
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


% --- Executes just before serial_GUI is made visible.
function serial_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
  if ~isempty(instrfind)
       fclose(instrfind);
       delete(instrfind);
    end
serialPorts = instrhwinfo('serial');
nPorts = length(serialPorts.SerialPorts);
set(handles.portList, 'String', ...
    [{'Select a port'} ; serialPorts.SerialPorts ]);
set(handles.portList, 'Value', 2);   
set(handles.history_box, 'String', cell(1));

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.sendbutton, 'Enable', 'Off');

% UIWAIT makes serial_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = serial_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in portList.
function portList_Callback(hObject, eventdata, handles)
% hObject    handle to portList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns portList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from portList


% --- Executes during object creation, after setting all properties.
function portList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to portList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function history_box_Callback(hObject, eventdata, handles)
% hObject    handle to history_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of history_box as text
%        str2double(get(hObject,'String')) returns contents of history_box as a double


% --- Executes during object creation, after setting all properties.
function history_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to history_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tx_send_Callback(hObject, eventdata, handles)
TxText = get(handles.Tx_send, 'String');
fprintf(handles.serConn, TxText);

currList = get(handles.history_box, 'String');

set(handles.history_box, 'String', ...
    [currList ; ['Sent @ ' datestr(now) ': ' TxText] ]);
set(handles.history_box, 'Value', length(currList) + 1 );

set(hObject, 'String', '');



% --- Executes on button press in rxButton.
function rxButton_Callback(hObject, eventdata, handles)
set(handles.rxButton, 'Enable', 'Off');
set(handles.sendbutton, 'Enable', 'Off');
loopvar = get(handles.nor, 'String');
loopcount=str2num(loopvar);
loopcount=loopcount+6;
for i = 1:1:loopcount
    while(get(handles.serConn,'BytesAvailable')~=0)
    RxText = fscanf(handles.serConn);
    currList = get(handles.history_box, 'String');
    if length(RxText) < 1
        RxText = 'Waiting for text';
        set(handles.history_box, 'String', ...
            [currList ; [RxText ] ]);
    else
        set(handles.history_box, 'String', ...
            [currList ; [ RxText ] ]);
    end
    set(handles.history_box, 'Value', length(currList) + 1 );
   fileID=fopen(fullfile(pwd,'data.csv'),'a+');
   fileID1=fopen(fullfile(pwd,'data.txt'),'a+');
   % fileID = fopen('data.csv','a+'); 
   % fileID1 = fopen('data.txt','a+'); 
    fprintf(fileID,RxText);
    fclose(fileID);
    fprintf(fileID1,RxText);
    fclose(fileID1);
    
    end
    pause(3);
     pause(4);
 end
 set(handles.rxButton, 'Enable', 'On');
 set(handles.sendbutton, 'Enable', 'On');


function baudRateText_Callback(hObject, eventdata, handles)
% hObject    handle to baudRateText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baudRateText as text
%        str2double(get(hObject,'String')) returns contents of baudRateText as a double


% --- Executes during object creation, after setting all properties.
function baudRateText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baudRateText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in connectButton.
function connectButton_Callback(hObject, eventdata, handles) 
if ~isempty(instrfind)
       fclose(instrfind);
       delete(instrfind);
    end
if strcmp(get(hObject,'String'),'Connect') % currently disconnected
    serPortn = get(handles.portList, 'Value');
    if serPortn == 1
        errordlg('Select valid COM port');
    else
        serList = get(handles.portList,'String');
        serPort = serList{serPortn};
        serConn = serial(serPort, 'TimeOut', 4, ...
                   'BaudRate', str2num(get(handles.baudRateText, 'String')));
        
        try
            fopen(serConn);
            handles.serConn = serConn;
            
            % enable Tx text field and Rx button
          %  set(handles.Tx_send, 'Enable', 'On');
            set(handles.sendbutton, 'Enable', 'On');
            
            set(hObject, 'String','Disconnect')
        catch e
            errordlg(e.message);
        end
        
    end
else
    set(handles.sendbutton, 'Enable', 'Off');
    set(handles.rxButton, 'Enable', 'Off');
    
    set(hObject, 'String','Connect')
    fclose(handles.serConn);
end
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'serConn')
    fclose(handles.serConn);
end
% Hint: delete(hObject) closes the figure
delete(hObject);



function startpos_Callback(hObject, eventdata, handles)
% hObject    handle to startpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startpos as text
%        str2double(get(hObject,'String')) returns contents of startpos as a double


% --- Executes during object creation, after setting all properties.
function startpos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endpos_Callback(hObject, eventdata, handles)
% hObject    handle to endpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endpos as text
%        str2double(get(hObject,'String')) returns contents of endpos as a double


% --- Executes during object creation, after setting all properties.
function endpos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nor_Callback(hObject, eventdata, handles)
% hObject    handle to nor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nor as text
%        str2double(get(hObject,'String')) returns contents of nor as a double


% --- Executes during object creation, after setting all properties.
function nor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sendbutton.
function sendbutton_Callback(hObject, eventdata, handles)
% hObject    handle to sendbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TxText = get(handles.startpos, 'String');
TxText1 = get(handles.endpos, 'String');
TxText2 = get(handles.nor, 'String');
TxText3 = ['S',' ',TxText1,' ',TxText,' ',TxText2]
fprintf(handles.serConn, TxText3);
pause(1);
fprintf(handles.serConn,'G');
set(handles.sendbutton, 'Enable', 'Off');
set(handles.rxButton, 'Enable', 'On');
 
% --- Executes on button press in starttestbutton.
function starttestbutton_Callback(hObject, eventdata, handles)
% hObject    handle to starttestbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf(handles.serConn,'G');
