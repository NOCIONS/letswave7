function GLW_multi_viewer_continuous(inputfiles)%
handles=[];
userdata=[];
header=[];
data=[];
events=[];
GLW_view_OpeningFcn;

%% GLW_view_OpeningFcn
    function GLW_view_OpeningFcn()
        Init_parameter();
        Init_fig();
        Init_epoch();
        Init_channel();
        Init_filter();
        Init_range();
        Init_ax_fig();
        Init_ax_slider();
        Init_event_code();
        Init_event_table();
        Init_event_btn();
        GLW_view_UpdataFcn();
        GLW_event_slider_UpdataFcn();
        GLW_event_table_UpdataFcn();
        Init_function();
        set(handles.fig,'Visible','on');
    end
    function Init_parameter()
        [p, n, e]=fileparts(fullfile(inputfiles.file_path,inputfiles.file_str{1}));
        userdata.filename=n;
        userdata.filepath=p;
        [header, data]=CLW_load(fullfile(p,[n,e]));
        
        userdata.N=header.datasize(6);
        userdata.t=header.xstart+(0:userdata.N-1)*header.xstep;
        
        userdata.Fs=1/header.xstep;
        temp=get(0,'MonitorPositions');
        temp=temp(1,:);
        userdata.fig_pos=[(temp(3)-1350)/2,(temp(4)-680)/2,1350,680];
        userdata.yscale_lock=1;
        userdata.is_filter=0;
        userdata.is_filter_low=1;
        userdata.is_filter_high=1;
        userdata.is_filter_notch=0;
        userdata.filter_high=min(1,userdata.Fs/10);
        userdata.filter_low=min(30,userdata.Fs/2);
        userdata.filter_notch=1;
        userdata.filter_order=2;
        userdata.is_category_selected=1;
        userdata.is_mouse_down=0;
        userdata.slide_dist=0;
        userdata.x_range=10;
        userdata.x1=0;
        userdata.x2=10;
        userdata.y_range=0;
        userdata.color=[0,0.447,0.741;
            0.85,0.325,0.098;
            0.929,0.694,0.125;
            0.494,0.184,0.556;
            0.466,0.674,0.188;
            0.301,0.745,0.933;
            0.635,0.078,0.1840];
        events.max=16;
        events.color=[];
        userdata.y=[];
        userdata.is_event_locked=1;
        
        Auto_x_range();
        userdata.x1=userdata.t(1);
        userdata.x2=userdata.t(1)+userdata.x_range;
        data=permute(data(:,:,:,1,1,:),[6,2,1,3,4,5]);%X*ch*ep*index
        
        events.stack=cell(21,1);
        events.stack_idx=1;
        events.table=header.events;
        events.stack{events.stack_idx}=events.table;
        [events.code_all,~,events.code_idx]=unique({events.table.code});
        events.code=unique(events.code_idx([events.table.epoch]==1));
        events.code_sel=1:length(events.code);
        events.selected_code={};
        
        if length(events.code_all)<=events.max
            events.color=jet((length(events.code_all)-1)*10+1);
            events.color=events.color(1:10:end,:);
            if length(events.code_all)<=1
                events.color=[0,0,1];
            end
        else
            events.color=jet(length(events.code_all));
            x=1:length(events.code_all);
            c=ceil(max(x)/events.max);
            y=mod((x-1)*c,events.max*c)+ceil((x-0.5)/events.max-1)+1;
            [~,~,y]=unique(y);
            events.color=events.color(y,:);
        end
        events.table_idx=[];
        events.table_sel_idx=[];
        
        handles.fig=[];
        handles.panel_left=[];
        handles.panel_mid=[];
        handles.panel_right_up=[];
        handles.panel_right_down=[];
        handles.line_event=[];
        handles.line_event_marker=[];
        handles.line_event_slide=[];
        handles.line_marker=[];
    end
    function Init_fig()
        handles.fig=figure('Visible','on','Color',0.94*[1,1,1]);
        set(handles.fig,'MenuBar','none');
        set(handles.fig,'numbertitle','off','name',[userdata.filename,' (multiviewer_continous)']);
        set(handles.fig,'DockControls','off');
        set(handles.fig,'position',userdata.fig_pos);
        
        handles.panel_left=uipanel(handles.fig,'BorderType','none');
        Set_position(handles.panel_left,[3,3,160,675]);
        
        handles.panel_mid=uipanel(handles.fig);
        Set_position(handles.panel_mid,[165,5,930,35]);
        
        handles.panel_right_up=uipanel(handles.fig,'Title','Events:');
        Set_position(handles.panel_right_up,[1100,185,250,490]);
        handles.panel_right_down=uipanel(handles.fig,'Title','Events type:');
        Set_position(handles.panel_right_down,[1100,3,250,180]);
        
    end
    function Init_epoch()
        handles.epoch_text=uicontrol(handles.panel_left,'style','text',...
            'String','Epochs:','HorizontalAlignment','left');
        Set_position(handles.epoch_text,[5,650,60,20]);
        
        
        st=cell(header.datasize(1),1);
        for k=1:header.datasize(1)
            st{k}=num2str(k);
        end
        handles.epoch_listbox=uicontrol(handles.panel_left,...
            'style','listbox','String',st,'value',1);
        Set_position(handles.epoch_listbox,[5,170,55,485]);
        set(handles.epoch_listbox,'backgroundcolor',[1,1,1]);
    end
    function Init_channel()
        handles.channel_text=uicontrol(handles.panel_left,...
            'style','text','String','Channels:','Units','pixels');
        Set_position(handles.channel_text,[70,650,60,20]);
        
        handles.channel_listbox=uicontrol(handles.panel_left,...
            'style','listbox','Min',1,'Max',3);
        set(handles.channel_listbox,'String',{header.chanlocs.labels});
        set(handles.channel_listbox,'value',1:header.datasize(2));
        Set_position(handles.channel_listbox,[70,170,85,485]);
        
        set(handles.channel_listbox,'backgroundcolor',[1,1,1]);
    end
    function Init_filter()
        handles.filter_panel=uipanel(handles.panel_left,...
            'Title','Online Butterworth Filter');
        Set_position(handles.filter_panel,[5,5,150,155]);
        
        handles.filter_checkbox=uicontrol(handles.filter_panel,...
            'style','checkbox','String','Enable',...
            'Value',userdata.is_filter);
        Set_position(handles.filter_checkbox,[5,120,105,20]);
        
        handles.filter_lowpass_checkbox=uicontrol(handles.filter_panel,...
            'style','checkbox','String','Low Pass',...
            'Value',userdata.is_filter_low);
        Set_position(handles.filter_lowpass_checkbox,[5,95,80,20]);
        handles.filter_lowpass_edit=uicontrol(handles.filter_panel,...
            'style','edit','String',num2str(userdata.filter_low));
        Set_position(handles.filter_lowpass_edit,[80,95,50,20]);
        
        handles.filter_highpass_checkbox=uicontrol(handles.filter_panel,...
            'style','checkbox','String','High Pass',...
            'Value',userdata.is_filter_high);
        Set_position(handles.filter_highpass_checkbox,[5,67,80,20]);
        handles.filter_highpass_edit=uicontrol(handles.filter_panel,...
            'style','edit','String',num2str(userdata.filter_high));
        Set_position(handles.filter_highpass_edit,[80,67,50,20]);
        
        handles.filter_notch_checkbox=uicontrol(handles.filter_panel,...
            'style','checkbox','String','Notch',...
            'Value',userdata.is_filter_notch);
        Set_position(handles.filter_notch_checkbox,[5,35,80,20]);
        handles.filter_notch_popup=uicontrol(handles.filter_panel,...
            'style','popup','String',{'50','60'},'Value',userdata.filter_notch);
        Set_position(handles.filter_notch_popup,[80,35,70,25]);
        
        handles.filter_order_text=uicontrol(handles.filter_panel,'style','text');
        set(handles.filter_order_text,'String','order:');
        Set_position(handles.filter_order_text,[0,5,80,20]);
        handles.filter_order_popup=uicontrol(handles.filter_panel,...
            'style','popup','value',userdata.filter_order,...
            'String',{'1','2','3','4','5','6','7','8','9','10'});
        Set_position(handles.filter_order_popup,[80,5,70,25]);
        
        if ispc
            Set_position(handles.filter_notch_popup,[80,35,50,25]);
            Set_position(handles.filter_order_popup,[80,5,50,25]);
        end
        
        set(handles.filter_lowpass_checkbox,'Enable','off');
        set(handles.filter_lowpass_edit,'Enable','off');
        set(handles.filter_highpass_checkbox,'Enable','off');
        set(handles.filter_highpass_edit,'Enable','off');
        set(handles.filter_notch_checkbox,'Enable','off');
        set(handles.filter_notch_popup,'Enable','off');
        set(handles.filter_order_text,'Enable','off');
        set(handles.filter_order_popup,'Enable','off');
        
        set(handles.filter_lowpass_edit,'backgroundcolor',[1,1,1]);
        set(handles.filter_highpass_edit,'backgroundcolor',[1,1,1]);
        set(handles.filter_notch_popup,'backgroundcolor',[1,1,1]);
        set(handles.filter_order_popup,'backgroundcolor',[1,1,1]);
    end
    function Init_range()
        %% x_range
        handles.x_range_text=uicontrol(handles.panel_mid,'style','text',...
            'String','X-range:','HorizontalAlignment','left');
        Set_position(handles.x_range_text,[15,2,60,20]);
        
        handles.x_pre_btn=uicontrol(handles.panel_mid,...
            'style','pushbutton','String','<<');
        Set_position(handles.x_pre_btn,[65,6,18,18]);
        
        handles.x1_edit=uicontrol(handles.panel_mid,'style','edit');
        Set_position(handles.x1_edit,[88,5,65,20]);
        
        handles.x_range1_text=uicontrol(handles.panel_mid,'style','text',...
            'String','-','HorizontalAlignment','left');
        Set_position(handles.x_range1_text,[154,2,60,20]);
        
        handles.x2_edit=uicontrol(handles.panel_mid,'style','edit');
        Set_position(handles.x2_edit,[160,5,65,20]);
        
        handles.x_next_btn=uicontrol(handles.panel_mid,...
            'style','pushbutton','String','>>');
        Set_position(handles.x_next_btn,[230,6,18,18]);
        
        %% x_scale
        handles.x_scale_text=uicontrol(handles.panel_mid,'style','text',...
            'String','X-scale:','HorizontalAlignment','left');
        Set_position(handles.x_scale_text,[290,2,60,20]);
        
        handles.x_scale_small_btn=uicontrol(handles.panel_mid,...
            'style','pushbutton','String','-');
        Set_position(handles.x_scale_small_btn,[330,6,18,18]);
        
        handles.x_scale_edit=uicontrol(handles.panel_mid,...
            'style','edit');
        Set_position(handles.x_scale_edit,[350,5,100,20]);
        
        handles.x_scale_large_btn=uicontrol(handles.panel_mid,...
            'style','pushbutton','String','+');
        Set_position(handles.x_scale_large_btn,[452,6,18,18]);
        
        set(handles.x1_edit,'string',num2str(userdata.x1));
        set(handles.x2_edit,'string',num2str(userdata.x2));
        set(handles.x_scale_edit,'string',num2str(userdata.x_range))
        
        %% y_scale
        handles.y_text=uicontrol(handles.panel_mid,'style','text',...
            'String','Yscale:','HorizontalAlignment','left');
        Set_position(handles.y_text,[480,2,60,20]);
        
        handles.y_scale_small_btn=uicontrol(handles.panel_mid,...
            'style','pushbutton','String','-');
        Set_position(handles.y_scale_small_btn,[520,6,18,18]);
        
        handles.y_scale_edit=uicontrol(handles.panel_mid,'style','edit');
        Set_position(handles.y_scale_edit,[540,5,100,20]);
        
        handles.y_scale_large_btn=uicontrol(handles.panel_mid,...
            'style','pushbutton','String','+');
        Set_position(handles.y_scale_large_btn,[642,6,18,18]);
        
        handles.y_auto_checkbox=uicontrol(handles.panel_mid,...
            'style','checkbox','String','auto',...
            'Value',userdata.yscale_lock);
        Set_position(handles.y_auto_checkbox,[670,5,60,20]);
        
        %% index
        handles.index_text=uicontrol(handles.panel_mid,'style','text',...
            'String','Index:','HorizontalAlignment','left');
        Set_position(handles.index_text,[763,2,50,20]);
        handles.index_popup=uicontrol(handles.panel_mid,'style','popup');
        Set_position(handles.index_popup,[793,5,100,20]);
        
        if header.datasize(3)==1
            set(handles.index_text,'Visible','off');
            set(handles.index_popup,'Visible','off');
        else
            if isfield(header,'index_labels')
                set(handles.index_popup,'String',header.index_labels);
            else
                st=cell(1,header.datasize(3));
                for k=1:header.datasize(3)
                    st{k}=num2str(k);
                end
                set(handles.index_popup,'String',st);
            end
            set(handles.index_popup,'value',1);
        end
        set(handles.x1_edit,'backgroundcolor',[1,1,1]);
        set(handles.x2_edit,'backgroundcolor',[1,1,1]);
        set(handles.x_scale_edit,'backgroundcolor',[1,1,1]);
        set(handles.y_scale_edit,'backgroundcolor',[1,1,1]);
    end
    function Init_ax_fig()
        %% ax_fig
        handles.ax_fig=axes('yaxislocation','right','xlim',[userdata.x1,userdata.x2]);
        Set_position(handles.ax_fig,[170,100,880,557]);
        hold on;box on;grid on;
        for k=1:header.datasize(2)
            handles.line(k)=line(1,1,'Parent',handles.ax_fig);
            if k<=30
            handles.linetext(k)=uicontrol('Parent',handles.fig,'Style','text','String','32',...
                                'FontSize',10,'ForegroundColor',[1,1,1],'BackgroundColor',[0,0,0]);
            end
        end
        set(handles.line,'LineWidth',1,'Visible','off');
        set(handles.linetext,'Visible','off');
        handles.line_marker=line(1,1,'linestyle','--','linewidth',2,...
            'color',[0.8,0.8,0.8],'Parent',handles.ax_fig,'Visible','off');
        handles.line_event=scatter(handles.ax_fig,1,0,64,[1,0,0],'v','filled','Visible','off');
    end
    function Init_ax_slider()
        handles.ax_slide=axes();
        hold on;
        Set_position(handles.ax_slide,[165,45,930,30]);
        handles.rect_bg_slide=rectangle('position',[userdata.t(1),-5,userdata.t(end),10],...
            'EdgeColor',0.94*[1,1,1],'facecolor',0.94*[1,1,1],'Parent',handles.ax_slide);
        handles.line_slide=line(userdata.t([1,end]),[0,0],'linewidth',4,...
            'color',[0.7,0.7,0.7],'Parent',handles.ax_slide);
        handles.rect_slide=rectangle('position',[userdata.t(1),-1,userdata.x_range,2],...
            'facecolor',[0.3,0.3,0.3],'Parent',handles.ax_slide);
        handles.line_event_slide=scatter(handles.ax_slide,userdata.t(1),0,30,events.color(1,:),'filled');
        set(handles.ax_slide,'xlim',userdata.t([1,end]),'ylim',[-5,5]);
        x_tick=get(handles.ax_slide,'xtick');
        text(userdata.t(1),-3,num2str(userdata.t(1)));
        text(userdata.t(end),-3,num2str(userdata.t(end)),'HorizontalAlignment','right');
        
        for k=1:length(x_tick)
            if min(abs(x_tick(k)-userdata.t(1)),abs(x_tick(k)-userdata.t(end)))>=(x_tick(2)-x_tick(1))/2
                line([x_tick(k),x_tick(k)],[-0.5,0.5],'color',[0,0,0],'Parent',handles.ax_slide);
                text(x_tick(k),-3,num2str(x_tick(k)),'HorizontalAlignment','center','Parent',handles.ax_slide);
            end
        end
        axis off;
        
    end
    function Init_event_table()
        columnname = {'Code','latency','Epoch'};
        columnformat = {'char','numeric','numeric'};
        handles.event_table = uitable(handles.panel_right_up,...
            'ColumnName', columnname,'ColumnFormat', columnformat,...
            'ColumnWidth',{80,60,40});
        set(handles.event_table,'ColumnEditable', [false false false]);
        Set_position(handles.event_table,[0,80,250,397]);
    end
    function Init_event_code()
        handles.category_listbox=uicontrol(handles.panel_right_down,...
            'style','listbox','Min',1,'Max',3,...
            'string',events.code_all(events.code),'value',events.code_sel);
        Set_position(handles.category_listbox,[0,0,200,167]);
        set(handles.category_listbox,'backgroundcolor',[1,1,1]);
        
        handles.category_checkbox=uicontrol(handles.panel_right_down,...
            'style','checkbox','String','All',...
            'Value',userdata.is_category_selected);
        Set_position(handles.category_checkbox,[205,150,40,20]);
        icon=load('icon.mat');
        handles.category_del_btn=uicontrol(handles.panel_right_down,...
            'style','pushbutton','CData',icon.icon_delete,...
            'tooltipstring','remove event type');
        Set_position(handles.category_del_btn,[208,50,32,32]);
        handles.category_rename_btn=uicontrol(handles.panel_right_down,...
            'style','pushbutton','CData',icon.icon_rename,...
            'tooltipstring','rename event type');
        Set_position(handles.category_rename_btn,[208,5,32,32]);
    end
    function Init_event_btn()
        icon=load('icon.mat');
        handles.events_lock_btn=uicontrol(handles.panel_right_up,...
            'style','pushbutton','CData',icon.icon_lock,...
            'tooltipstring','event editable');
        handles.events_add_btn=uicontrol(handles.panel_right_up,...
            'style','pushbutton','CData',icon.icon_dataset_add,...
            'tooltipstring','add event');
        handles.events_del_btn=uicontrol(handles.panel_right_up,...
            'style','pushbutton','CData',icon.icon_dataset_del,...
            'tooltipstring','delete event');
        
        handles.events_undo_btn=uicontrol(handles.panel_right_up,...
            'style','pushbutton','CData',icon.icon_undo,...
            'tooltipstring','undo','enable','off');
        handles.events_redo_btn=uicontrol(handles.panel_right_up,...
            'style','pushbutton','CData',icon.icon_redo,...
            'tooltipstring','redo','enable','off');
        handles.events_GUI2workspace_btn=uicontrol(handles.panel_right_up,...
            'style','pushbutton','CData',icon.icon_sendtoworkspace,...
            'tooltipstring','send events to workspace');
        handles.events_workspace2GUI_btn=uicontrol(handles.panel_right_up,...
            'style','pushbutton','CData',icon.icon_loadfromworkspace,...
            'tooltipstring','load events from workspace');
        
        handles.events_save_checkbox=uicontrol(handles.panel_right_up,...
            'style','checkbox','Value',0,'String','overwrite dataset');
        handles.events_prefix_text=uicontrol(handles.panel_right_up,'style','text',...
            'HorizontalAlignment','left','String','Prefix:');
        handles.events_prefix_edt=uicontrol(handles.panel_right_up,'style','edit',...
            'String','ep_edit','HorizontalAlignment','left');
        set(handles.events_prefix_edt,'backgroundcolor',[1,1,1]);
        handles.events_recovery_btn=uicontrol(handles.panel_right_up,...
            'style','pushbutton','CData',icon.icon_open_path,...
            'tooltipstring','recovery the events');
        handles.events_save_btn=uicontrol(handles.panel_right_up,...
            'style','pushbutton','CData',icon.icon_save,...
            'tooltipstring','save the events');
        
        
        Set_position(handles.events_lock_btn,[2,45,32,32]);
        Set_position(handles.events_add_btn,[37,45,32,32]);
        Set_position(handles.events_del_btn,[72,45,32,32]);
        Set_position(handles.events_undo_btn,[107,45,32,32]);
        Set_position(handles.events_redo_btn,[142,45,32,32]);
        Set_position(handles.events_GUI2workspace_btn,[177,45,32,32]);
        Set_position(handles.events_workspace2GUI_btn,[212,45,32,32]);
        
        Set_position(handles.events_save_checkbox,[2,24,140,20]);
        Set_position(handles.events_prefix_text,[2,2,80,20]);
        Set_position(handles.events_prefix_edt,[42,3,80,25]);
        Set_position(handles.events_save_btn,[125,1,80,40]);
        Set_position(handles.events_recovery_btn,[205,1,40,40]);
    end

    function Init_function()
        %% left panel
        set(handles.epoch_listbox,          'Callback',@GLW_view_epoch_UpdataFcn);
        set(handles.channel_listbox,        'Callback',@GLW_view_UpdataFcn);
        set(handles.filter_checkbox,        'Callback',@Filter_changed);
        set(handles.filter_lowpass_checkbox,'Callback',@Filter_changed);
        set(handles.filter_lowpass_edit,    'Callback',@Filter_changed);
        set(handles.filter_highpass_checkbox,'Callback',@Filter_changed);
        set(handles.filter_highpass_edit,   'Callback',@Filter_changed);
        set(handles.filter_notch_checkbox,  'Callback',@Filter_changed);
        set(handles.filter_notch_popup,     'Callback',@Filter_changed);
        set(handles.filter_order_text,      'Callback',@Filter_changed);
        set(handles.filter_order_popup,     'Callback',@Filter_changed);
        
        %% mid panel
        set(handles.x1_edit,                'callback',@X_range_changed);
        set(handles.x2_edit,                'callback',@X_range_changed);
        set(handles.x_pre_btn,              'callback',@X_pre_callback);
        set(handles.x_next_btn,             'callback',@X_next_callback);
        set(handles.x_scale_small_btn,      'callback',@X_scale_small_callback);
        set(handles.x_scale_large_btn,      'callback',@X_scale_large_callback);
        set(handles.x_scale_edit,           'callback',@X_scale_callback);
        set(handles.y_scale_small_btn,      'callback',@Y_scale_small_callback);
        set(handles.y_scale_large_btn,      'callback',@Y_scale_large_callback);
        set(handles.y_scale_edit,           'callback',@Y_scale_callback);
        set(handles.y_auto_checkbox,        'callback',@Y_auto_callback);
        set(handles.index_popup,            'Callback',@GLW_view_UpdataFcn);
        
        temp=get(handles.ax_slide,'Children');
        set(temp,'buttonDownFcn',@Slider_BtnDown);
        set(handles.fig,'WindowButtonUpFcn',@Slider_BtnUp);
        
        %% right panel
        if verLessThan('matlab','8.4')
            set(handles.panel_right_up,         'ResizeFcn',@Panel_right_SizeChangedFcn);
        else
            set(handles.panel_right_up,         'SizeChangedFcn',@Panel_right_SizeChangedFcn);
        end
        set(handles.event_table,                'CellSelectionCallback',@Event_table_Selected);
        set(handles.event_table,                'CellEditCallback',@Event_table_Edited);
        set(handles.events_lock_btn,            'Callback',@Events_lock_btn_callback);
        set(handles.events_GUI2workspace_btn,   'Callback',@Events_GUI2workspace_btn_callback);
        set(handles.events_workspace2GUI_btn,   'Callback',@Events_workspace2GUI_btn_callback);
        set(handles.category_listbox,           'Callback',@Category_listbox_Changed);
        set(handles.category_checkbox,          'Callback',@Category_checkbox_Changed);
        set(handles.category_del_btn,           'Callback',@Category_del_btn_callback);
        set(handles.category_rename_btn,        'Callback',@Category_rename_btn_callback);
        set(handles.events_undo_btn,            'Callback',@Events_undo_btn_callback);
        set(handles.events_redo_btn,            'Callback',@Events_redo_btn_callback);
        set(handles.events_recovery_btn,        'Callback',@Events_recovery_btn_callback);
        set(handles.events_add_btn,             'Callback',@Events_add_btn_callback);
        set(handles.events_del_btn,             'Callback',@Events_del_btn_callback);
        
        set(handles.events_save_checkbox,       'Callback',@Events_save_checkbox_callback);
        set(handles.events_save_btn,            'Callback',@Events_save_btn_callback);
    end

%% GLW_view_UpdataFcn
    function GLW_view_epoch_UpdataFcn(~,~)
        GLW_view_UpdataFcn();
        Event_Update();
    end
    function GLW_view_UpdataFcn(~,~)
        ch_num=get(handles.channel_listbox,'value');
        ep_num=get(handles.epoch_listbox,'value');
        idx_num=get(handles.index_popup,'value');
        
        x_idx=find(userdata.t>=userdata.x1 &userdata.t<=userdata.x2);
        if userdata.is_filter
            x_idx=[(-100:-1)+x_idx(1),x_idx,(1:100)+x_idx(end)];
            x_idx(x_idx<1)=1;
            x_idx(x_idx>size(data,1))=size(data,1);
            userdata.y = data(x_idx,ch_num,ep_num,idx_num);
            userdata.y = detrend(userdata.y);
            if userdata.is_filter_low
                [b,a]=butter(userdata.filter_order,userdata.filter_low/(userdata.Fs/2),'low');
                userdata.y=filtfilt(b,a,userdata.y);
            end
            if userdata.is_filter_high
                [b,a]=butter(userdata.filter_order,userdata.filter_high/(userdata.Fs/2),'high');
                userdata.y=filtfilt(b,a,userdata.y);
            end
            if userdata.is_filter_notch
                if userdata.filter_notch==1 %50Hz
                    [b,a]=butter(userdata.filter_order,[48,52]/(userdata.Fs/2),'stop');
                    userdata.y=filtfilt(b,a,userdata.y);
                else %60Hz
                    [b,a]=butter(userdata.filter_order,[58,62]/(userdata.Fs/2),'stop');
                    userdata.y=filtfilt(b,a,userdata.y);
                end
            end
            x_idx=x_idx(101:end-100);
            userdata.y = userdata.y(101:end-100,:);
        else
            userdata.y=data(x_idx,ch_num,ep_num,idx_num);
        end
        if get(handles.y_auto_checkbox,'value')
            Auto_y_range();
            set(handles.y_scale_edit,'string',num2str(userdata.y_range));
        end
        set(handles.ax_fig,'xLim',[userdata.x1,userdata.x2]);
        set(handles.ax_fig,'ylim',[-userdata.y_range*5,userdata.y_range*5]);
        set(handles.line_marker,'ydata',[-userdata.y_range*5,userdata.y_range*5]);
        set(handles.ax_fig,'ytick',linspace(-userdata.y_range*5,userdata.y_range*5,11));
        GLW_event_fig_UpdataFcn();
        set(handles.linetext,'Visible','off');
        set(handles.line(1:length(ch_num)),'Visible','on');
        set(handles.line(length(ch_num)+1:end),'Visible','off');
        set(handles.line(length(ch_num)+1:end),'XData',1,'YData',1);
        temp_range=linspace(-userdata.y_range*5,userdata.y_range*5,length(ch_num)*2+1);
        temp_range=temp_range(end-1:-2:2);
        set(handles.ax_fig,'units','pixel');
        temp=get(handles.ax_fig,'position');
        set(handles.ax_fig,'units','normalized');
        if length(ch_num)<30
            set(handles.linetext(1:length(ch_num)),'Visible','on');
            for k=1:length(ch_num)
                set(handles.linetext(k),'String',header.chanlocs(ch_num(k)).labels);
                c1=get(handles.linetext(k),'extent');
                c3=[temp(1)+5,temp(2)-c1(4)/2+(temp_range(k)/userdata.y_range/10+0.5)*temp(4),c1(3),c1(4)-2];
                set(handles.linetext(k),'Position',c3);
                set(handles.linetext(k),'BackgroundColor',userdata.color(mod(k-1,7)+1,:));
            end
        end
        
        if length(x_idx)>temp(3)
            x=linspace(userdata.t(x_idx(1)),userdata.t(x_idx(end)),temp(3)*2)';
            for k=1:length(ch_num)
                set(handles.line(k),'XData',x);
                set(handles.line(k),'YData',interp1q(userdata.t(x_idx)',userdata.y(:,k)-userdata.y(1,k)+temp_range(k),x));
                set(handles.line(k),'color',userdata.color(mod(k-1,7)+1,:));
            end
        else
            for k=1:length(ch_num)
                set(handles.line(k),'XData',userdata.t(x_idx));
                set(handles.line(k),'YData',userdata.y(:,k)-userdata.y(1,k)+temp_range(k));
                set(handles.line(k),'color',userdata.color(mod(k-1,7)+1,:));
            end
        end
    end
    function GLW_event_table_UpdataFcn(~,~)
        ep_num=get(handles.epoch_listbox,'value');
        code_num=get(handles.category_listbox,'value');
        idx_temp=[];
        for k=code_num
            idx_temp=[idx_temp,find(events.code_idx'==events.code(k) )];
        end
        idx_temp=idx_temp([events.table(idx_temp).epoch]==ep_num);
        idx_temp=sort(idx_temp);
        [~,b]=sort([events.table(idx_temp).latency]);
        idx_temp=idx_temp(b);
        d=cell(length(idx_temp),3);
        if ~isempty(idx_temp)
        d(:,1)={events.table(idx_temp).code};
        d(:,2)={events.table(idx_temp).latency};
        d(:,3)={events.table(idx_temp).epoch};
        end
        set(handles.event_table,'data',d);
        events.table_idx=idx_temp;
    end
    function GLW_event_category_UpdataFcn(~,~)
        if  userdata.is_category_selected
            events.code_sel=1:length(events.code);
        else
            events.code_sel=[];
            for k=1:length(events.selected_code)
                events.code_sel=[events.code_sel,find(events.code==events.selected_code(k))];
            end
        end
        set(handles.category_listbox,'string',events.code_all,'value',events.code_sel);
    end
    function GLW_event_fig_UpdataFcn(~,~)
        ep_num=get(handles.epoch_listbox,'value');
        X=[];
        for k=1:length(events.code_sel)
            idx_temp = find(events.code_idx==events.code(events.code_sel(k)));
            X=[X,idx_temp'];
        end
        X=X([events.table(X).epoch]==ep_num &...
            [events.table(X).latency]>=userdata.x1 &...
            [events.table(X).latency]<=userdata.x2);
        color_idx=events.code_idx(X);
        X=[events.table(X).latency];
        Y=ones(size(X))*userdata.y_range*5;
        set(handles.line_event,'XData',X,'YData',Y,...
            'CData',events.color(color_idx,:),'visible','on');
        
        if isempty(events.code_sel)
            legend off;
        else
            set(handles.line_event_marker,'visible','off');
            for k=1:min([length(handles.line_event_marker),length((events.code_sel)),events.max])
                set(handles.line_event_marker(k),'XData',userdata.x1-1,...
                'YData',0,'color',events.color(events.code(events.code_sel(k)),:));
            end
            for k=length(handles.line_event_marker)+1:min(length((events.code_sel)),events.max)
                handles.line_event_marker(k)=line(userdata.x1-1,0,...
                    'color',events.color(events.code(events.code_sel(k)),:),'Parent',handles.ax_fig);
            end
            set(handles.line_event_marker(1:min(length((events.code_sel)),events.max)),...
                'marker','v','linestyle','none','visible','on');
            legend(handles.ax_fig,handles.line_event_marker(1:min(length((events.code_sel)),events.max)),...
                events.code_all(events.code(events.code_sel(1:min(events.max,end)))),'location','northeast',...
                'Interpreter','none','ButtonDownFcn',{});
        end
    end
    function GLW_event_slider_UpdataFcn(~,~)
        ep_num=get(handles.epoch_listbox,'value');
        X=[];
        for k=1:length(events.code_sel)
            idx_temp = find(events.code_idx==events.code(events.code_sel(k)));
            X=[X,idx_temp'];
        end
        X=X([events.table(X).epoch]==ep_num );
        color_idx=events.code_idx(X);
        X=[events.table(X).latency];
        Y=X*0;
        set(handles.line_event_slide,'XData',X,'YData',Y,'CData',events.color(color_idx,:));
        
        
        
%         for k=length(handles.line_event_slide)+1:length(events.code_sel)
%             handles.line_event_slide(k)=line(1,-6,'markersize',14,...
%                 'marker','.','linestyle','none',...
%                 'color',[0.4,0.4,0.4],'Parent',handles.ax_slide);
%         end
%         for k=length(events.code_sel)+1:length(handles.line_event_slide)
%             set(handles.line_event_slide(k),'visible','off');
%         end
%         
%         ep_num=get(handles.epoch_listbox,'value');
%         for k=1:length(events.code_sel)
%             set(handles.line_event_slide(k),'visible','on');
%             idx_temp= find(strcmp({events.table.code},events.code{events.code_sel(k)}) & [events.table.epoch]==ep_num);
%             set(handles.line_event_slide(k),'XData',[events.table(idx_temp).latency],'YData',zeros(size(idx_temp)));
%             color_idx= strcmp(events.code_all,events.code{events.code_sel(k)});
%             set(handles.line_event_slide(k),'MarkerEdgecolor',events.color(color_idx,:));
%         end
%         order=get(handles.ax_slide,'Children');
%         temp=find(order==handles.rect_slide);
%         set(handles.ax_slide,'Children',order([temp,setdiff(1:length(order),temp)]));
    end

%% function right panel
    function Event_Update(~,~)
        ep_num=get(handles.epoch_listbox,'value');
        [events.code_all,~,events.code_idx]=unique({events.table.code});
        events.code=unique(events.code_idx([events.table.epoch]==ep_num));
        
        if length(events.code_all)<=events.max
            events.color=jet((length(events.code_all)-1)*10+1);
            events.color=events.color(1:10:end,:);
            if length(events.code_all)==1
                events.color=[0,0,1];
            end
        else
            events.color=jet(length(events.code_all));
            x=1:length(events.code_all);
            c=ceil(max(x)/events.max);
            y=mod((x-1)*c,events.max*c)+ceil((x-0.5)/events.max-1)+1;
            [~,~,y]=unique(y);
            events.color=events.color(y,:);
        end
        GLW_event_category_UpdataFcn();
        GLW_event_table_UpdataFcn();
        GLW_event_fig_UpdataFcn();
        GLW_event_slider_UpdataFcn();
    end
    function Event_table_Selected(~,callbackdata)
        events.table_sel_idx=events.table_idx(callbackdata.Indices(:,1));
        if  userdata.is_event_locked
            d=get(handles.event_table,'data');
            if isempty(callbackdata.Indices)
                set(handles.line_marker,'Visible','off');
                return;
            end
            d=d{min(callbackdata.Indices(:,1)),2};
            set(handles.line_marker,'xdata',[d,d]);
            set(handles.line_marker,'ydata',[-userdata.y_range*5,userdata.y_range*5]);
            set(handles.line_marker,'Visible','on');
            temp=d<=userdata.x2-d<=userdata.x1;
            if d>=userdata.x1+temp/5 && d<=userdata.x2-temp/5
                return;
            end
            temp2 = get(handles.rect_slide,'position');
            temp2(1)=d-temp2(3)/2;
            if temp2(1)<userdata.t(1)
                temp2(1)=userdata.t(1);
            end
            if (temp2(1)+temp2(3))>userdata.t(end)
                temp2(1)=userdata.t(end)-temp2(3);
            end
            userdata.x1=temp2(1);
            userdata.x2=temp2(1)+temp2(3);
            set(handles.x1_edit,'string',num2str(temp2(1)));
            set(handles.x2_edit,'string',num2str(temp2(1)+temp2(3)));
            set(handles.rect_slide,'position',temp2);
            GLW_view_UpdataFcn();
        else
            set(handles.line_marker,'Visible','off');
        end
    end
    function Event_table_Edited(~,callbackdata)
        idx=events.table_idx(callbackdata.Indices(1));
        switch(callbackdata.Indices(2))
            case 1
                if isempty(callbackdata.NewData)
                    d=get(handles.event_table,'data');
                    d{callbackdata.Indices(1),callbackdata.Indices(2)}=callbackdata.PreviousData;
                    set(handles.event_table,'Data',d);
                    return;
                else
                    events.table(idx).code=callbackdata.NewData;
                end
            case 2
                if callbackdata.NewData<userdata.t(1) || callbackdata.NewData>userdata.t(end)
                    d=get(handles.event_table,'data');
                    d{callbackdata.Indices(1),callbackdata.Indices(2)}=callbackdata.PreviousData;
                    set(handles.event_table,'Data',d);
                    return;
                else
                    events.table(idx).latency=callbackdata.NewData;
                end
            case 3
                temp=fix(callbackdata.NewData);
                if temp<1 ||temp>header.datasize(1)
                    d=get(handles.event_table,'data');
                    d{callbackdata.Indices(1),callbackdata.Indices(2)}=callbackdata.PreviousData;
                    set(handles.event_table,'Data',d);
                    return;
                else
                    events.table(idx).epoch=temp;
                end
        end
        events.stack_idx=mod(events.stack_idx,21)+1;
        events.stack{events.stack_idx}=events.table;
        events.stack{mod(events.stack_idx,21)+1}=[];
        Event_Update();
        set(handles.events_undo_btn,'enable','on');
        set(handles.events_redo_btn,'enable','off');
    end
    function Events_lock_btn_callback(~,~)
        icon=load('icon.mat');
        userdata.is_event_locked=~userdata.is_event_locked;
        temp=get(handles.events_lock_btn,'position');
        temp(3:4)=temp(3:4)+0.00001;
        set(handles.events_lock_btn,'position',temp);
        if userdata.is_event_locked
            set(handles.events_lock_btn,'CData',icon.icon_lock);
            set(handles.event_table,'ColumnEditable', [false false false]);
        else
            set(handles.events_lock_btn,'CData',icon.icon_unlock);
            set(handles.event_table,'ColumnEditable', [true true true]);
        end
        temp(3:4)=temp(3:4)-0.00001;
        set(handles.events_lock_btn,'position',temp);
    end
    function Events_add_btn_callback(~,~)
        if ~isempty(events.selected_code)
            code=events.selected_code{1};
        else
            if ~isempty(events.code)
                code=events.code{1};
            else
                if ~isempty(events.code_all)
                    code=events.code{1};
                else
                    code='S1';
                end
            end
        end
        events.table(end+1).code=code;
        if userdata.t(1)<=0 && userdata.t(end)>=0
            events.table(end).latency=0;
        else
            events.table(end).latency=userdata.t(1);
        end
        events.table(end).epoch=get(handles.epoch_listbox,'value');
        
        events.stack_idx=mod(events.stack_idx,21)+1;
        events.stack{events.stack_idx}=events.table;
        events.stack{mod(events.stack_idx,21)+1}=[];
        Event_Update();
        set(handles.events_undo_btn,'enable','on');
        set(handles.events_redo_btn,'enable','off');
    end
    function Events_del_btn_callback(~,~)
        idx=setdiff(1:length(events.table),events.table_sel_idx);
        events.table=events.table(idx);
        events.stack_idx=mod(events.stack_idx,21)+1;
        events.stack{events.stack_idx}=events.table;
        events.stack{mod(events.stack_idx,21)+1}=[];
        Event_Update();
        set(handles.events_undo_btn,'enable','on');
        set(handles.events_redo_btn,'enable','off');
    end
    function Events_undo_btn_callback(~,~)
        events.stack_idx=mod(events.stack_idx+19,21)+1;
        events.table=events.stack{events.stack_idx};
        Event_Update();
        set(handles.events_redo_btn,'enable','on');
        if isempty(events.stack{mod(events.stack_idx+19,21)+1})
            set(handles.events_undo_btn,'enable','off');
        end
    end
    function Events_redo_btn_callback(~,~)
        events.stack_idx=mod(events.stack_idx,21)+1;
        events.table=events.stack{events.stack_idx};
        Event_Update();
        set(handles.events_undo_btn,'enable','on');
        if isempty(events.stack{mod(events.stack_idx,21)+1})
            set(handles.events_redo_btn,'enable','off');
        end
    end
    function Events_GUI2workspace_btn_callback(~,~)
        assignin('base','events',events.table);
    end
    function Events_workspace2GUI_btn_callback(~,~)
        try
            temp=evalin('base','events');
        catch
            msgbox('there is no variable ''events'' in the workspace.');
            return
        end
        if all(isfield(temp,{'code','latency','epoch'}))
            names = fieldnames(temp);
            names=names(~strcmp(names,'code'));
            names=names(~strcmp(names,'latency'));
            names=names(~strcmp(names,'epoch'));
            events.table=rmfield(temp,names);
            
            events.stack_idx=mod(events.stack_idx,21)+1;
            events.stack{events.stack_idx}=events.table;
            events.stack{mod(events.stack_idx,21)+1}=[];
            Event_Update();
            set(handles.events_undo_btn,'enable','on');
            set(handles.events_redo_btn,'enable','off');
        end
    end
    function Events_recovery_btn_callback(~,~)
        events.table=header.events;
        events.stack_idx=1;
        events.stack{events.stack_idx}=events.table;
        events.stack{2}=[];
        events.stack{21}=[];
        Event_Update();
        set(handles.events_undo_btn,'enable','off');
        set(handles.events_redo_btn,'enable','off');
    end
    function Events_save_checkbox_callback(~,~)
        value=get(handles.events_save_checkbox,'value');
        if value
            set(handles.events_prefix_text,'enable','off');
            set(handles.events_prefix_edt,'enable','off');
        else
            set(handles.events_prefix_text,'enable','on');
            set(handles.events_prefix_edt,'enable','on');
        end
    end
    function Events_save_btn_callback(~,~)
        set(handles.events_save_btn,'enable','off');
        lwdata.header=header;
        lwdata.header.events=events.table;
        if ~get(handles.events_save_checkbox,'value')
            str=get(handles.events_prefix_edt,'String');
            lwdata.header.name=[str,' ',header.name];
            copyfile(fullfile(userdata.filepath,[header.name,'.mat']),...
                fullfile(userdata.filepath,[lwdata.header.name,'.mat']));
        end
        option.path=userdata.filepath;
        CLW_save_header(lwdata,option);
        set(handles.events_save_btn,'enable','on');
    end
    function Category_listbox_Changed(~,~)
        value=get(handles.category_listbox,'value');
        if ~isempty(setxor(events.code_sel,value))
            events.code_sel=value;
            events.selected_code=events.code(events.code_sel);
            if length(value)<length(events.code)
                userdata.is_category_selected=0;
                set(handles.category_checkbox,'Value',0);
            end
            GLW_event_table_UpdataFcn();
            GLW_event_fig_UpdataFcn();
            GLW_event_slider_UpdataFcn();
        end
    end
    function Category_checkbox_Changed(~,~)
        userdata.is_category_selected=get(handles.category_checkbox,'Value');
        if userdata.is_category_selected
            events.code_sel=1:length(events.code);
            set(handles.category_listbox,'value',events.code_sel);
            GLW_event_table_UpdataFcn();
            GLW_event_slider_UpdataFcn();
            GLW_event_fig_UpdataFcn();
        end
    end
    function Category_del_btn_callback(~,~)
        value=get(handles.category_listbox,'value');
        if isempty(value)
            msgbox('Please select some event types.');
            return;
        end
        
        choice=questdlg({'Are you sure to delete these event types?','It will delete all the events of these type.'},...
            'Delete a event type','OK','Cancle','OK');
        if strcmp(choice,'OK')
            str=events.code(events.code_sel);
            events.selected_code={};
            for k=1:length(str)
                events.table=events.table(~strcmp({events.table.code},str{k}));
            end
            events.stack_idx=mod(events.stack_idx,21)+1;
            events.stack{events.stack_idx}=events.table;
            events.stack{mod(events.stack_idx,21)+1}=[];
            userdata.is_category_selected=1;
            Event_Update();
            set(handles.events_undo_btn,'enable','on');
            set(handles.events_redo_btn,'enable','off');
        end
    end
    function Category_rename_btn_callback(~,~)
        value=get(handles.category_listbox,'value');
        if isempty(value)
            msgbox('Please select one event type.');
            return;
        end
        str_pre=events.code(value(1));
        answer = inputdlg('input the type name','change name of event type',1,str_pre);
        if isempty(answer) || isempty(answer{1})||strcmp(answer{1},str_pre)
            return;
        end
        str_now=answer{1};
        idx=find(strcmp({events.table.code},str_pre));
        for k=idx
            events.table(k).code=str_now;
        end
        idx=find(strcmp({events.selected_code},str_pre));
        for k=idx
            events.selected_code(k)=str_now;
        end
        
        events.stack_idx=mod(events.stack_idx,21)+1;
        events.stack{events.stack_idx}=events.table;
        events.stack{mod(events.stack_idx,21)+1}=[];
        Event_Update();
        set(handles.events_undo_btn,'enable','on');
        set(handles.events_redo_btn,'enable','off');
    end

%% function left panel
    function X_range_changed(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        if isnan(x(1))||isnan(x(2))
            temp=get(handles.rect_slide,'position');
            set(handles.x1_edit, 'String',num2str(temp(1)));
            set(handles.x2_edit, 'String',num2str(temp(1)+temp(3)));
            return;
        end
        x(x<userdata.t(1))=userdata.t(1);
        x(x>userdata.t(end))=userdata.t(end);
        if x(1)==x(2)
            x(1)=x(1)-1;
            x(2)=x(2)+1;
            set(handles.x1_edit,'String',x(1));
            set(handles.x2_edit,'String',x(2));
        end
        if(x(1)>x(2))
            x=x([2,1]);
            set(handles.x1_edit,'String',x(1));
            set(handles.x2_edit,'String',x(2));
        end
        x_scale=x(2)-x(1);
        if x_scale>2*10^4/userdata.Fs
            set(handles.x1_edit, 'String',num2str(userdata.x1));
            set(handles.x2_edit, 'String',num2str(userdata.x2));
            return;
        end
        userdata.x_range=x_scale;
        userdata.x1=x(1);
        userdata.x2=x(2);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        set(handles.x_scale_edit,'String',num2str(x(2)-x(1)));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
        GLW_view_UpdataFcn();
    end
    function X_pre_callback(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        x_scale = str2double(get(handles.x_scale_edit, 'String'));
        if x(1)-x_scale<userdata.t(1)
            x=[userdata.t(1);userdata.t(1)+x_scale];
        else
            x=x-x_scale;
        end
        userdata.x_range=x_scale;
        userdata.x1=x(1);
        userdata.x2=x(2);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
        GLW_view_UpdataFcn();
    end
    function X_next_callback(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        x_scale = str2double(get(handles.x_scale_edit, 'String'));
        if x(2)+x_scale>userdata.t(end)
            x=[userdata.t(end)-x_scale;userdata.t(end)];
        else
            x=x+x_scale;
        end
        userdata.x_range=x_scale;
        userdata.x1=x(1);
        userdata.x2=x(2);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
        GLW_view_UpdataFcn();
    end
    function X_scale_small_callback(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        x_scale = str2double(get(handles.x_scale_edit, 'String'));
        x_scale=x_scale/1.5;
        temp=10^floor(log10(x_scale)-1);
        x_scale=round(x_scale/temp)*temp;
        if x_scale<10/userdata.Fs
            x_scale=min(10/userdata.Fs,userdata.t(end)-userdata.t(1));
        end
        x(2)=x(1)+x_scale;
        if x(2)>userdata.t(end)
            x(2)=userdata.t(end);
            x(1)=userdata.t(end)-x_scale;
        end
        userdata.x_range=x_scale;
        userdata.x1=x(1);
        userdata.x2=x(2);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        set(handles.x_scale_edit,'String',num2str(x_scale));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
        GLW_view_UpdataFcn();
    end
    function X_scale_large_callback(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        x_scale = str2double(get(handles.x_scale_edit, 'String'));
        x_scale=x_scale*1.5;
        temp=10^floor(log10(x_scale)-1);
        x_scale=round(x_scale/temp)*temp;
        if x_scale>userdata.t(end)-userdata.t(1)
            x_scale=userdata.t(end)-userdata.t(1);
        end
        if x_scale>2*10^4/userdata.Fs
            x_scale=2*10^4/userdata.Fs;
        end
        x(2)=x(1)+x_scale;
        if x(2)>userdata.t(end)
            x(2)=userdata.t(end);
            x(1)=userdata.t(end)-x_scale;
        end
        userdata.x_range=x_scale;
        userdata.x1=x(1);
        userdata.x2=x(2);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        set(handles.x_scale_edit,'String',num2str(x_scale));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
        GLW_view_UpdataFcn();
    end
    function X_scale_callback(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        x_scale = str2double(get(handles.x_scale_edit, 'String'));
        if isnan(x_scale)
            temp=get(handles.rect_slide,'position');
            set(handles.x1_edit, 'String',num2str(temp(1)));
            set(handles.x2_edit, 'String',num2str(temp(1)+temp(3)));
            set(handles.x_scale_edit,'string',num2str(userdata.x_range));
            return;
        end
        if x_scale<10/userdata.Fs
            x_scale=min(10/userdata.Fs,userdata.t(end)-userdata.t(1));
        end
        if x_scale>userdata.t(end)-userdata.t(1)
            x_scale=userdata.t(end)-userdata.t(1);
        end
        if x_scale>2*10^4/userdata.Fs
            x_scale=2*10^4/userdata.Fs;
        end
        x(2)=x(1)+x_scale;
        if x(2)>userdata.t(end)
            x(2)=userdata.t(end);
            x(1)=userdata.t(end)-x_scale;
        end
        userdata.x_range=x_scale;
        userdata.x1=x(1);
        userdata.x2=x(2);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        set(handles.x_scale_edit,'String',num2str(x_scale));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
        GLW_view_UpdataFcn();
    end
    function Y_scale_small_callback(~,~)
        y_scale = str2double(get(handles.y_scale_edit, 'String'));
        y_scale=y_scale/1.5;
        temp=10^floor(log10(y_scale)-1);
        userdata.y_range=round(y_scale/temp)*temp;
        set(handles.y_scale_edit,'string',num2str(userdata.y_range));
        set(handles.y_auto_checkbox,'value',0);
        GLW_view_UpdataFcn();
    end
    function Y_scale_large_callback(~,~)
        y_scale = str2double(get(handles.y_scale_edit, 'String'));
        y_scale=y_scale*1.5;
        temp=10^floor(log10(y_scale)-1);
        userdata.y_range=round(y_scale/temp)*temp;
        set(handles.y_scale_edit,'string',num2str(userdata.y_range));
        set(handles.y_auto_checkbox,'value',0);
        GLW_view_UpdataFcn();
    end
    function Y_scale_callback(~,~)
        y_scale= str2double(get(handles.y_scale_edit, 'String'));
        if isnumeric(y_scale) && y_scale>0
            userdata.y_range=y_scale;
            set(handles.y_auto_checkbox,'value',0);
            GLW_view_UpdataFcn();
        else
            set(handles.y_scale_edit,'string',num2str(userdata.y_range));
        end
    end
    function Y_auto_callback(~,~)
        y_auto=get(handles.y_auto_checkbox,'value');
        if y_auto==1
            GLW_view_UpdataFcn();
        end
    end
    function Auto_x_range()
        userdata.x_range=10;
        if (userdata.x_range*userdata.Fs)>userdata.N
            userdata.x_range=min(userdata.N,5000)/userdata.Fs;
        end
    end
    function Auto_y_range()
        ch_num=get(handles.channel_listbox,'value');
        y_max=max([max(userdata.y,[],1)-userdata.y(1,:),...
            userdata.y(1,:)-min(userdata.y,[],1)])*2;
        if y_max==0
            y_max=1;
        end
        userdata.y_range=y_max*length(ch_num)/10;
        temp=10^floor(log10(userdata.y_range));
        userdata.y_range=ceil(userdata.y_range/temp)*temp;
    end
    function Filter_changed(~,~)
        if get(handles.filter_checkbox,'value')
            userdata.is_filter=1;
            if get(handles.filter_lowpass_checkbox,'value')
                userdata.is_filter_low=1;
                userdata.filter_low=str2num(get(handles.filter_lowpass_edit,'String'));
                if userdata.filter_low>userdata.Fs/2
                    userdata.filter_low=userdata.Fs/2;
                    set(handles.filter_lowpass_edit,'String',num2str(userdata.filter_low));
                end
            else
                userdata.is_filter_low=0;
            end
            if get(handles.filter_highpass_checkbox,'value')
                userdata.is_filter_high=1;
                userdata.filter_high=str2num(get(handles.filter_highpass_edit,'String'));
                if userdata.filter_high>userdata.Fs/2
                    userdata.filter_high=userdata.Fs/2;
                    set(handles.filter_highpass_edit,'String',num2str(userdata.filter_high));
                end
            else
                userdata.is_filter_high=0;
            end
            if get(handles.filter_notch_checkbox,'value')
                userdata.is_filter_notch=1;
                userdata.filter_notch=get(handles.filter_notch_checkbox,'value');
            else
                userdata.is_filter_notch=0;
            end
            userdata.filter_order=get(handles.filter_order_popup,'value');
            set(handles.filter_lowpass_checkbox,'Enable','on');
            set(handles.filter_lowpass_edit,'Enable','on');
            set(handles.filter_highpass_checkbox,'Enable','on');
            set(handles.filter_highpass_edit,'Enable','on');
            set(handles.filter_notch_checkbox,'Enable','on');
            set(handles.filter_notch_popup,'Enable','on');
            set(handles.filter_order_text,'Enable','on');
            set(handles.filter_order_popup,'Enable','on');
        else
            userdata.is_filter=0;
            set(handles.filter_lowpass_checkbox,'Enable','off');
            set(handles.filter_lowpass_edit,'Enable','off');
            set(handles.filter_highpass_checkbox,'Enable','off');
            set(handles.filter_highpass_edit,'Enable','off');
            set(handles.filter_notch_checkbox,'Enable','off');
            set(handles.filter_notch_popup,'Enable','off');
            set(handles.filter_order_text,'Enable','off');
            set(handles.filter_order_popup,'Enable','off');
        end
        GLW_view_UpdataFcn();
    end
    function Panel_right_SizeChangedFcn(~,~)
        ch_num=get(handles.channel_listbox,'value');
        temp_range=linspace(-userdata.y_range*5,userdata.y_range*5,length(ch_num)*2+1);
        temp_range=temp_range(end-1:-2:2);
        set(handles.ax_fig,'units','pixel');
        temp=get(handles.ax_fig,'position');
        set(handles.ax_fig,'units','normalized');
        for k=1:min(length(ch_num),30)
            c1=get(handles.linetext(k),'extent');
            c3=[temp(1)+5,temp(2)-c1(4)/2+(temp_range(k)/userdata.y_range/10+0.5)*temp(4),c1(3),c1(4)-2];
            set(handles.linetext(k),'Position',c3);
        end
        
        set(handles.panel_right_up,'Units','pixels');
        temp=get(handles.panel_right_up,'position');
        temp=(temp(3)-60)/18;
        set(handles.event_table,'ColumnWidth',{temp*8,temp*6,temp*4});
        set(handles.panel_right_up,'Units','normalized');
    end
    function Set_position(obj,position)
        set(obj,'Units','pixels');
        set(obj,'Position',position);
        set(obj,'Units','normalized');
    end
    function Slider_BtnDown(~, ~)
        userdata.is_mouse_down=1;
    end
    function Slider_BtnUp(~, ~)
        if userdata.is_mouse_down==1
            temp1 = get (handles.ax_slide, 'CurrentPoint');
            temp2 = get(handles.rect_slide,'position');
            temp2(1)=temp1(1,1)-temp2(3)/2;
            if temp2(1)<userdata.t(1)
                temp2(1)=userdata.t(1);
            end
            if (temp2(1)+temp2(3))>userdata.t(end)
                temp2(1)=userdata.t(end)-temp2(3);
            end
            userdata.x1=temp2(1);
            userdata.x2=temp2(1)+temp2(3);
            set(handles.x1_edit,'string',num2str(temp2(1)));
            set(handles.x2_edit,'string',num2str(temp2(1)+temp2(3)));
            set(handles.rect_slide,'position',temp2);
            GLW_view_UpdataFcn();
            userdata.is_mouse_down=0;
        end
    end
end