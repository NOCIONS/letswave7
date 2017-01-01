function GLW_multi_viewer_continuous(inputfile)
handles=[];
userdata=[];
datasets_header={};
datasets_data={};
GLW_view_OpeningFcn;

%% init_parameter()
    function init_parameter()
        userdata.fig_pos=[110,100,1024,620];
    end

%% fig_init
    function fig_init()
        handles.fig=figure('Visible','on','Color',0.94*[1,1,1]);
        set(handles.fig,'MenuBar','none');
        set(handles.fig,'DockControls','off');
        set(handles.fig,'position',userdata.fig_pos);
        
        
        handles.panel_edit=uipanel(handles.fig);%,'BorderType','none'
        set(handles.panel_edit,'Units','pixels');
        set(handles.panel_edit,'Position',[3,3,350,600]);
        
        %epoch
        handles.epoch_text=uicontrol(handles.panel_edit,'style','text','String','Epochs:');
        set(handles.epoch_text,'Units','pixels');
        set(handles.epoch_text,'HorizontalAlignment','left');
        set(handles.epoch_text,'Position',[5,575,60,20]);
        set(handles.epoch_text,'Units','normalized');
        handles.epoch_listbox=uicontrol(handles.panel_edit,'style','listbox','Callback',@GLW_view_UpdataFcn);
        set(handles.epoch_listbox,'Units','pixels');
        set(handles.epoch_listbox,'Position',[5,205,40,375]);
        set(handles.epoch_listbox,'Units','normalized');
        
        %channel
        handles.channel_text=uicontrol(handles.panel_edit,'style','text','String','Channels:');
        set(handles.channel_text,'Units','pixels');
        set(handles.channel_text,'HorizontalAlignment','left');
        set(handles.channel_text,'Position',[50,575,60,20]);
        set(handles.channel_text,'Units','normalized');
        handles.channel_listbox=uicontrol(handles.panel_edit,'style','listbox','Callback',@GLW_view_UpdataFcn);
        set(handles.channel_listbox,'Min',1);
        set(handles.channel_listbox,'Max',3);
        set(handles.channel_listbox,'Units','pixels');
        set(handles.channel_listbox,'Position',[50,205,75,375]);
        set(handles.channel_listbox,'Units','normalized');
        
        %event
        handles.event_text=uicontrol(handles.panel_edit,'style','text','String','Events:');
        set(handles.event_text,'Units','pixels');
        set(handles.event_text,'HorizontalAlignment','left');
        set(handles.event_text,'Position',[130,575,60,20]);
        set(handles.event_text,'Units','normalized');
        handles.event_listbox=uicontrol(handles.panel_edit,'style','listbox','Callback',@GLW_view_UpdataFcn);
        set(handles.event_listbox,'Min',1);
        set(handles.event_listbox,'Max',3);
        set(handles.event_listbox,'Units','pixels');
        set(handles.event_listbox,'Position',[130,205,200,375]);
        set(handles.event_listbox,'Units','normalized');
        
    end


%% GLW_my_view_OpeningFcn
    function GLW_view_OpeningFcn()
        init_parameter();
        fig_init();
    end

%% GLW_my_view_OpeningFcn
    function GLW_view_UpdataFcn()
    end

end