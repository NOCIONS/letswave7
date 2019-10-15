function GLW_multi_viewer_map(inputfiles)
LW_init();
handles=[];
userdata=[];
datasets_header={};
datasets_data={};
GLW_view_OpeningFcn;

%% GLW_view_OpeningFcn
    function GLW_view_OpeningFcn()
        Init_parameter();
        Fig1_init();
        Fig2_init();
        Init_function();
        GLW_view_UpdataFcn();
        
        try
            set(handles.fig1,'SizeChangedFcn',@Fig1_SizeChangedFcn);
            set(handles.fig2,'SizeChangedFcn',@Fig2_SizeChangedFcn);
        catch
            set(handles.fig1,'resizefcn',@Fig1_SizeChangedFcn);
            set(handles.fig2,'resizefcn',@Fig2_SizeChangedFcn);
        end
        
        set(handles.fig1,'Visible','on');
    end
    function Init_parameter()
        temp=get(0,'MonitorPositions');
        temp=temp(1,:);
        userdata.fig1_pos=[(temp(3)-1350)/2,(temp(4)-680)/2-20,1350,680];
        userdata.fig2_pos=[(temp(3)-1350)/2+465,(temp(4)-680)/2-20,900,680];
        userdata.auto_x=1;
        userdata.auto_y=1;
        userdata.lock_cursor=0;
        userdata.is_polarity=0;
        userdata.is_shade=0;
        userdata.is_cursor=0;
        userdata.cursor_point=[0,10];
        userdata.is_split=0;
        userdata.is_title=0;
        userdata.is_topo=0;
        userdata.is_headplot=0;
        userdata.headplot_colornum=512;
        
        userdata.graph_style=[3,2];
        userdata.shade_x=[0,1];
        userdata.shade_y=[0,10];
        userdata.selected_datasets=[];
        userdata.selected_epochs=[];
        userdata.selected_channels=[];
        userdata.num_rows=1;
        userdata.num_cols=1;
        userdata.mouse_state=0;
        userdata.color_style='jet';
        S=load('GLW_multi_viewer_wave.mat');
        userdata.POS=S.userdata.POS;
        userdata.TRI=S.userdata.TRI;
        userdata.NORM=S.userdata.NORM;
        clear S;
        handles.axes=[];
        handles.title=[];
        handles.shade=[];
        handles.cursor_x=[];
        handles.cursor_y=[];
        handles.cursor_text=[];
        handles.axes_topo=[];
        handles.axes_headplot=[];
        
        
        handles.colorbar_headplot=[];
        handles.axes_headplot=[];
        handles.title_headplot=[];
        handles.surface_headplot=[];
        handles.dot_headplot=[];
        
        
        handles.colorbar_topo=[];
        handles.axes_topo=[];
        handles.title_topo=[];
        handles.surface_topo=[];
        handles.line_topo=[];
        handles.dot_topo=[];
        
        
        %inputfiles.file_path='/Users/huanggan/Documents/MATLAB/letswave_bank/EEGlab';
        %inputfiles.file_str{1}='cwt ep eeglab_data';
        file_index=0;
        for k=1:length(inputfiles.file_str)
            [p, n, ~]=fileparts(fullfile(inputfiles.file_path,inputfiles.file_str{k}));
            userdata.datasets_path=p;
            header=CLW_load_header(fullfile(p,n));
            if header.datasize(5)>1
                file_index=file_index+1;
                userdata.datasets_filename{file_index}=n;
                datasets_header(file_index).header=header;
                datasets_data(file_index).data=CLW_load_data(fullfile(p,n));
                if ~isreal(datasets_data(file_index).data)
                    datasets_data(file_index).data=abs(datasets_data(file_index).data);
                end
                chan_used=find([datasets_header(file_index).header.chanlocs.topo_enabled]==1, 1);
                if isempty(chan_used)
                    datasets_header(file_index).header=CLW_elec_autoload(datasets_header(file_index).header);
                end
                datasets_header(file_index).header=CLW_make_spl(datasets_header(file_index).header);
            end
        end
    end
    function Fig1_init()
        icon=load('icon.mat');
        handles.fig1=figure('Visible','off','Color',0.94*[1,1,1],...
            'numbertitle','off','name','multiviewer_maps','MenuBar','none',...
            'position',userdata.fig1_pos,'DockControls','off');
               
        %toolbar1
        handles.toolbar1 = uitoolbar(handles.fig1);
        handles.toolbar1_split = uitoggletool(handles.toolbar1);
        set(handles.toolbar1_split,'TooltipString','Split');
        set(handles.toolbar1_split,'CData',icon.icon_split);
        set(handles.toolbar1_split,'State','off');
        set(handles.toolbar1,'Visible','off');
        
        handles.panel_edit=uipanel(handles.fig1,'BorderType','none');
        set(handles.panel_edit,'units','pixels');
        set(handles.panel_edit,'position',[1,1,350,680]);
        
        handles.dataset_text=uicontrol(handles.panel_edit,...
            'style','text','String','Datasets:','HorizontalAlignment','left');
        Set_position(handles.dataset_text,[5,656,60,20]);
        
        handles.dataset_listbox=uicontrol(handles.panel_edit,...
            'style','listbox','Min',1,'Max',1);
        Set_position(handles.dataset_listbox,[5,500,300,160]);
        set(handles.dataset_listbox,'String',userdata.datasets_filename);
        handles.dataset_add=uicontrol(handles.panel_edit,...
            'CData',icon.icon_dataset_add,'style','pushbutton','TooltipString','add dataset');
        handles.dataset_del=uicontrol(handles.panel_edit,...
            'CData',icon.icon_dataset_del,'style','pushbutton','TooltipString','delete selected dataset');
        handles.dataset_up=uicontrol(handles.panel_edit,...
            'CData',icon.icon_dataset_up,'style','pushbutton','TooltipString','dataset up');
        handles.dataset_down=uicontrol(handles.panel_edit,...
            'CData',icon.icon_dataset_down,'style','pushbutton','TooltipString','dataset down');
        Set_position(handles.dataset_add,[310,634,26,26]');
        Set_position(handles.dataset_del,[310,590,26,26]);
        Set_position(handles.dataset_up,[310,545,26,26]);
        Set_position(handles.dataset_down,[310,501,26,26]);
        
        handles.epoch_text=uicontrol(handles.panel_edit,...
            'style','text','String','Epochs:','HorizontalAlignment','left');
        Set_position(handles.epoch_text,[5,475,60,20]);
        handles.epoch_listbox=uicontrol(handles.panel_edit,...
            'style','listbox','Min',1,'Max',3);
        Set_position(handles.epoch_listbox,[5,103,70,375]);
        
        handles.channel_text=uicontrol(handles.panel_edit,...
            'style','text','String','Channels:','HorizontalAlignment','left');
        Set_position(handles.channel_text,[80,475,60,20]);
        handles.channel_listbox=uicontrol(handles.panel_edit,...
            'style','listbox','Min',1,'Max',3);
        Set_position(handles.channel_listbox,[80,103,100,375]);
        if ~isempty(datasets_header)
            set(handles.channel_listbox,'String',{datasets_header(1).header.chanlocs.labels});
        end
        
        handles.graph_row_text=uicontrol(handles.panel_edit,...
            'style','text','String','Separate graphs (rows) :','HorizontalAlignment','left');
        Set_position(handles.graph_row_text,[5,80,200,20]);
        handles.graph_row_popup=uicontrol(handles.panel_edit,...
            'style','popup','String',{'datasets','epochs','channels'});
        Set_position(handles.graph_row_popup,[5,58,175,22]);
        
        handles.graph_col_text=uicontrol(handles.panel_edit,...
            'style','text','String','Separate graphs (columns) :','HorizontalAlignment','left');
        Set_position(handles.graph_col_text,[5,32,200,20]);
        handles.graph_col_popup=uicontrol(handles.panel_edit,...
            'style','popup','String',{'datasets','epochs','channels'});
        Set_position(handles.graph_col_popup,[5,10,175,22]);
        
        handles.index_text=uicontrol(handles.panel_edit,...
            'style','text','String','Index:','HorizontalAlignment','left');
        Set_position(handles.index_text,[190,475,50,20]);
        handles.index_popup=uicontrol(handles.panel_edit,'style','popup');
        set(handles.index_popup,'String',{'pixels'});
        Set_position(handles.index_popup,[190,455,150,20]);
        
        handles.z_text=uicontrol(handles.panel_edit,'style','text',...
            'String','Z:','HorizontalAlignment','left');
        Set_position(handles.z_text,[190,420,50,20]);
        handles.z_edit=uicontrol(handles.panel_edit,'style','edit','String',[]);
        Set_position(handles.z_edit,[210,422,50,20]);
        
        handles.axis_panel=uipanel(handles.panel_edit,'Title','Axis');
        Set_position(handles.axis_panel,[190,230,150,186]);
        
        handles.axis_text_x=uicontrol(handles.axis_panel,...
            'style','text','string','x range:','HorizontalAlignment','left');
        Set_position(handles.axis_text_x,[5,153,120,20]);
        handles.xaxis1_edit=uicontrol(handles.axis_panel,'style','edit');
        Set_position(handles.xaxis1_edit,[5,133,60,20]);
        handles.xaxis2_edit=uicontrol(handles.axis_panel,'style','edit');
        Set_position(handles.xaxis2_edit,[80,133,60,20]);
        handles.xaxis_auto_checkbox=uicontrol(handles.axis_panel,...
            'style','checkbox','String','auto','Value',userdata.auto_x);
        Set_position(handles.xaxis_auto_checkbox,[85,154,80,20]);
        
        handles.axis_text_y=uicontrol(handles.axis_panel,...
            'style','text','string','y range:','HorizontalAlignment','left');
        Set_position(handles.axis_text_y,[5,103,120,20]);
        handles.yaxis1_edit=uicontrol(handles.axis_panel,'style','edit');
        Set_position(handles.yaxis1_edit,[5,83,60,20]);
        handles.yaxis2_edit=uicontrol(handles.axis_panel,'style','edit');
        Set_position(handles.yaxis2_edit,[80,83,60,20]);
        handles.yaxis_auto_checkbox=uicontrol(handles.axis_panel,...
            'style','checkbox','String','auto','Value',userdata.auto_y);
        Set_position(handles.yaxis_auto_checkbox,[85,104,80,20]);
        
        handles.axis_text_c=uicontrol(handles.axis_panel,...
            'style','text','string','color range:','HorizontalAlignment','left');
        Set_position(handles.axis_text_c,[5,50,120,20]);
        handles.caxis1_edit=uicontrol(handles.axis_panel,'style','edit');
        Set_position(handles.caxis1_edit,[5,30,60,20]);
        handles.caxis2_edit=uicontrol(handles.axis_panel,'style','edit');
        Set_position(handles.caxis2_edit,[80,30,60,20]);
        handles.caxis_auto_checkbox=uicontrol(handles.axis_panel,...
            'style','checkbox','String','auto','Value',userdata.auto_y);
        Set_position(handles.caxis_auto_checkbox,[85,52,80,20]);
        
        if verLessThan('matlab','8.4')
            handles.caxis_style_popup=uicontrol(handles.axis_panel,...
                'style','popup','String',{'jet','hsv','hot','cool',...
                'spring','summer','autumn','winter','gray','bone','copper',...
                'pink'},'Value',1);
        else
            handles.caxis_style_popup=uicontrol(handles.axis_panel,...
                'style','popup','String',{'parula','jet','hsv','hot','cool',...
                'spring','summer','autumn','winter','gray','bone','copper',...
                'pink'},'Value',2);
        end
        Set_position(handles.caxis_style_popup,[3,5,140,20]);
        
        handles.cursor_panel=uipanel(handles.panel_edit,'Title','Cursor');
        Set_position(handles.cursor_panel,[190,135,150,90]);
        handles.cursor_text_x=uicontrol(handles.cursor_panel,'style','text','string','x:');
        Set_position(handles.cursor_text_x,[5,52,20,20]);
        handles.cursor_edit_x=uicontrol(handles.cursor_panel,'style','edit');
        Set_position(handles.cursor_edit_x,[35,55,100,20]);
        handles.cursor_text_y=uicontrol(handles.cursor_panel,'style','text','string','y:');
        Set_position(handles.cursor_text_y,[5,22,20,20]);
        handles.cursor_edit_y=uicontrol(handles.cursor_panel,'style','edit');
        Set_position(handles.cursor_edit_y,[35,25,100,20]);
        handles.cursor_auto_checkbox=uicontrol(handles.cursor_panel,...
            'style','checkbox','String','Locked','Value',userdata.lock_cursor);
        Set_position(handles.cursor_auto_checkbox,[65,5,80,20]);
        
        
        handles.interval_panel=uipanel(handles.panel_edit,'Title','Explore interval');
        Set_position(handles.interval_panel,[190,10,150,120]);
        handles.interval_text_x=uicontrol(handles.interval_panel,...
            'style','text','string','x:','HorizontalAlignment','left');
        handles.interval1_edit_x=uicontrol(handles.interval_panel,'style','edit');
        handles.interval2_edit_x=uicontrol(handles.interval_panel,'style','edit');
        handles.interval_text_y=uicontrol(handles.interval_panel,...
            'style','text','string','y:','HorizontalAlignment','left');
        handles.interval1_edit_y=uicontrol(handles.interval_panel,'style','edit');
        handles.interval2_edit_y=uicontrol(handles.interval_panel,'style','edit');
        handles.interval_plot_button=uicontrol(handles.interval_panel,'style','pushbutton','String','Topograph of Mean');
        handles.interval_button=uicontrol(handles.interval_panel,'style','pushbutton','String','Table');
        
        Set_position(handles.interval_text_x,[5,78,20,20]);
        Set_position(handles.interval1_edit_x,[20,78,55,20]);
        Set_position(handles.interval2_edit_x,[87,78,55,20]);
        Set_position(handles.interval_text_y,[5,52,20,20]);
        Set_position(handles.interval1_edit_y,[20,52,55,20]);
        Set_position(handles.interval2_edit_y,[87,52,55,20]);
        Set_position(handles.interval_plot_button,[5,27,135,26]);
        Set_position(handles.interval_button,[5,2,135,26]);
        
        set(handles.interval1_edit_x,'String',num2str(userdata.shade_x(1)));
        set(handles.interval2_edit_x,'String',num2str(userdata.shade_x(2)));
        set(handles.interval1_edit_y,'String',num2str(userdata.shade_y(1)));
        set(handles.interval2_edit_y,'String',num2str(userdata.shade_y(2)));
        set(handles.graph_row_popup,'Value',userdata.graph_style(1));
        set(handles.graph_col_popup,'Value',userdata.graph_style(2));
        
        
        set(handles.dataset_listbox,'backgroundcolor',[1,1,1]);
        set(handles.epoch_listbox,'backgroundcolor',[1,1,1]);
        set(handles.channel_listbox,'backgroundcolor',[1,1,1]);
        set(handles.graph_row_popup,'backgroundcolor',[1,1,1]);
        set(handles.graph_col_popup,'backgroundcolor',[1,1,1]);
        set(handles.index_popup,'backgroundcolor',[1,1,1]);
        set(handles.z_edit,'backgroundcolor',[1,1,1]);
        set(handles.xaxis1_edit,'backgroundcolor',[1,1,1]);
        set(handles.xaxis2_edit,'backgroundcolor',[1,1,1]);
        set(handles.yaxis1_edit,'backgroundcolor',[1,1,1]);
        set(handles.yaxis2_edit,'backgroundcolor',[1,1,1]);
        set(handles.caxis1_edit,'backgroundcolor',[1,1,1]);
        set(handles.caxis2_edit,'backgroundcolor',[1,1,1]);
        set(handles.cursor_edit_x,'backgroundcolor',[1,1,1]);
        set(handles.cursor_edit_y,'backgroundcolor',[1,1,1]);
        set(handles.interval1_edit_x,'backgroundcolor',[1,1,1]);
        set(handles.interval2_edit_x,'backgroundcolor',[1,1,1]);
        set(handles.interval1_edit_y,'backgroundcolor',[1,1,1]);
        set(handles.interval2_edit_y,'backgroundcolor',[1,1,1]);
        set(handles.caxis_style_popup,'backgroundcolor',[1,1,1]);
    end
    function Fig2_init()
        icon=load('icon.mat');
        handles.fig2=figure('Visible','off','position',userdata.fig2_pos,...
            'numbertitle','off','name','multiviewer_maps',...
            'DockControls','off','PaperPositionMode','auto');
         if ~verLessThan('matlab','9.4')
            addToolbarExplorationButtons(handles.fig2);
        end
        %toolbar2
        handles.toolbar2 = uitoolbar(handles.fig1);
        handles.toolbar2_split = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_split,'TooltipString','Split');
        set(handles.toolbar2_split,'CData',icon.icon_split);
        set(handles.toolbar2_split,'State','on');
        
        handles.toolbar2_save = uipushtool(handles.toolbar2,'Separator','on');
        set(handles.toolbar2_save,'TooltipString','Save the figure');
        set(handles.toolbar2_save,'CData',...
            get(findall(handles.fig2,'Tag','Standard.SaveFigure'),'CData'));
        %set(findall(handles.fig2,'ToolTipString','Save Figure'),'Parent',handles.toolbar2);
        handles.toolbar2_zoomin=findall(handles.fig2,'Tag','Exploration.ZoomIn');
        handles.toolbar2_zoomout=findall(handles.fig2,'Tag','Exploration.ZoomOut');
        handles.toolbar2_pan=findall(handles.fig2,'Tag','Exploration.Pan');
        handles.toolbar2_rotate=findall(handles.fig2,'Tag','Exploration.Rotate');
        set(handles.toolbar2_zoomin,'Parent',handles.toolbar2);
        set(handles.toolbar2_zoomout,'Parent',handles.toolbar2);
        set(handles.toolbar2_pan,'Parent',handles.toolbar2);
        set(handles.toolbar2_rotate,'Parent',handles.toolbar2);
        
        
        handles.toolbar2_polarity = uitoggletool(handles.toolbar2,'Separator','on');
        set(handles.toolbar2_polarity,'TooltipString','change polarity');
        set(handles.toolbar2_polarity,'CData',icon.icon_polarity);
        if userdata.is_polarity
            set(handles.toolbar2_polarity,'State','on');
        else
            set(handles.toolbar2_polarity,'State','off');
        end
        
        handles.toolbar2_shade = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_shade,'TooltipString','enable interval selection');
        set(handles.toolbar2_shade,'CData',icon.icon_shade);
        if userdata.is_shade
            set(handles.toolbar2_shade,'State','on');
        else
            set(handles.toolbar2_shade,'State','off');
        end
        
        handles.toolbar2_cursor = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_cursor,'TooltipString','cursor');
        set(handles.toolbar2_cursor,'CData',icon.icon_cursor);
        if userdata.is_cursor
            set(handles.toolbar2_cursor,'State','on');
        else
            set(handles.toolbar2_cursor,'State','off');
        end
        
        
        handles.toolbar2_title = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_title,'TooltipString','title');
        set(handles.toolbar2_title,'CData',icon.icon_title);
        if userdata.is_title
            set(handles.toolbar2_title,'State','on');
        else
            set(handles.toolbar2_title,'State','off');
        end
        
        handles.toolbar2_topo = uitoggletool(handles.toolbar2,'Separator','on');
        set(handles.toolbar2_topo,'TooltipString','topograph(4 limited)');
        set(handles.toolbar2_topo,'CData',icon.icon_topo);
        
        handles.toolbar2_headplot = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_headplot,'TooltipString','headplot(4 limited)');
        set(handles.toolbar2_headplot,'CData',icon.icon_head);
        
        handles.panel_fig=uipanel(handles.fig1,'BorderType','none');
        set(handles.fig2,'MenuBar','none');
    end
    function Init_function()
        set(handles.fig1,'WindowButtonDownFcn',@Fig_BtnDown);
        set(handles.fig1,'WindowButtonMotionFcn',@Fig_BtnMotion);
        set(handles.fig1,'WindowButtonUpFcn',@Fig_BtnUp);
        h = zoom(handles.fig1);h.ActionPostCallback = @Fig_axis_Changed;
        h = pan(handles.fig1); h.ActionPostCallback = @Fig_axis_Changed;
        
        set(handles.toolbar1_split,'ClickedCallback',{@Fig_split});
        set(handles.dataset_add,'Units','normalized','Callback',@Edit_dataset_Add);
        set(handles.dataset_del,'Units','normalized','Callback',@Edit_dataset_Del);
        set(handles.dataset_up,'Units','normalized','Callback',@Edit_dataset_Up);
        set(handles.dataset_down,'Units','normalized','Callback',@Edit_dataset_Down);
        set(handles.dataset_listbox,'Callback',@GLW_view_UpdataFcn);
        set(handles.epoch_listbox,'Callback',@GLW_view_UpdataFcn);
        set(handles.channel_listbox,'Callback',@GLW_view_UpdataFcn);
        set(handles.graph_row_popup,'Callback',{@GLW_view_UpdataFcn,1});
        set(handles.graph_col_popup,'Callback',{@GLW_view_UpdataFcn,2});
        set(handles.index_popup,'Callback',@GLW_view_UpdataFcn);
        set(handles.z_edit,'Callback',@GLW_view_UpdataFcn);
        set(handles.xaxis_auto_checkbox,'Callback',@Edit_xaxis_auto_checkbox_Changed);
        set(handles.xaxis1_edit,'Callback',@Edit_xaxis_Changed);
        set(handles.xaxis2_edit,'Callback',@Edit_xaxis_Changed);
        set(handles.yaxis_auto_checkbox,'Callback',@Edit_yaxis_auto_checkbox_Changed);
        set(handles.yaxis1_edit,'Callback',@Edit_yaxis_Changed);
        set(handles.yaxis2_edit,'Callback',@Edit_yaxis_Changed);
        set(handles.caxis_auto_checkbox,'Callback',@Edit_caxis_auto_checkbox_Changed);
        set(handles.caxis1_edit,'Callback',@Edit_caxis_Changed);
        set(handles.caxis2_edit,'Callback',@Edit_caxis_Changed);
        set(handles.caxis_style_popup,'Callback',@Popup_colormap_Changed);
        
        set(handles.cursor_edit_x,'Callback',@Edit_cursor_Changed);
        set(handles.cursor_edit_y,'Callback',@Edit_cursor_Changed);
        set(handles.cursor_auto_checkbox,'Callback',@Edit_cursor_auto_checkbox_Changed);
        
        set(handles.interval1_edit_x,'Callback',@Edit_interval_Changed);
        set(handles.interval1_edit_y,'Callback',@Edit_interval_Changed);
        set(handles.interval2_edit_x,'Callback',@Edit_interval_Changed);
        set(handles.interval2_edit_y,'Callback',@Edit_interval_Changed);
        set(handles.interval_plot_button,'Callback',@Edit_interval_plot);
        set(handles.interval_button,'Callback',@Edit_interval_table);
        
        set(handles.fig2,'WindowButtonDownFcn',@Fig_BtnDown);
        set(handles.fig2,'WindowButtonMotionFcn',@Fig_BtnMotion);
        set(handles.fig2,'WindowButtonUpFcn',@Fig_BtnUp);
        h = zoom(handles.fig2);h.ActionPostCallback = @Fig_axis_Changed;
        h = pan(handles.fig2); h.ActionPostCallback = @Fig_axis_Changed;
        
        set(handles.toolbar2_save,'ClickedCallback',{@Fig_save});
        set(handles.toolbar2_split,'ClickedCallback',{@Fig_split});
        set(handles.toolbar2_polarity,'ClickedCallback',{@Fig_polarity});
        set(handles.toolbar2_shade,'ClickedCallback',{@Fig_shade});
        set(handles.toolbar2_cursor,'ClickedCallback',{@Fig_cursor});
        set(handles.toolbar2_title,'ClickedCallback',{@Fig_title});
        set(handles.toolbar2_topo,'ClickedCallback',{@Fig_topo});
        set(handles.toolbar2_headplot,'ClickedCallback',{@Fig_headplot});
        
        set(handles.fig1,'CloseRequestFcn',@Fig1_CloseReq_Callback);
        set(handles.fig2,'CloseRequestFcn',@Fig2_CloseReq_Callback);
    end

%% GLW_view_UpdataFcn
    function GLW_view_UpdataFcn(~, ~,graph_changed_idx)
        selected_datasets=get(handles.dataset_listbox,'Value');
        selected_epochs=get(handles.epoch_listbox,'Value');
        selected_channels=get(handles.channel_listbox,'Value');
        
        graph_style(1)=get(handles.graph_row_popup,'Value');
        graph_style(2)=get(handles.graph_col_popup,'Value');
        if nargin==3
            if(graph_style(1)==graph_style(2))
                graph_style(3-graph_changed_idx)=min(setdiff(1:3,graph_style(1)));
                if graph_changed_idx==2
                    set(handles.graph_row_popup,'Value',graph_style(1));
                else
                    set(handles.graph_col_popup,'Value',graph_style(2));
                end
            end
            temp=setdiff(1:3,graph_style);
            switch(temp)
                case 1
                    value=get(handles.dataset_listbox,'value');
                    set(handles.dataset_listbox,'value',value(1));
                    set(handles.dataset_listbox,'Max',1);
                    set(handles.epoch_listbox,'Max',3);
                    set(handles.channel_listbox,'Max',3);
                case 2
                    value=get(handles.epoch_listbox,'value');
                    set(handles.epoch_listbox,'value',value(1));
                    set(handles.dataset_listbox,'Max',3);
                    set(handles.epoch_listbox,'Max',1);
                    set(handles.channel_listbox,'Max',3);
                case 3
                    value=get(handles.channel_listbox,'value');
                    set(handles.channel_listbox,'value',value(1));
                    set(handles.dataset_listbox,'Max',3);
                    set(handles.epoch_listbox,'Max',3);
                    set(handles.channel_listbox,'Max',1);
            end
        end
        userdata.graph_style=graph_style;
        
        if isempty(selected_datasets)
            selected_datasets=userdata.selected_datasets;
            set(handles.dataset_listbox,'Value',selected_datasets);
        end
        if isempty(selected_epochs)
            selected_epochs=userdata.selected_epochs;
            set(handles.epoch_listbox,'Value',selected_epochs);
        end
        if isempty(selected_channels)
            selected_channels=userdata.selected_channels;
            set(handles.channel_listbox,'Value',selected_channels);
        end
        
        if ~isequal(userdata.selected_datasets,selected_datasets)
            header=datasets_header(selected_datasets(1)).header;
            channel_cursor= {header.chanlocs.labels};
            for k=selected_datasets(2:end)
                header.datasize=min(header.datasize,datasets_header(k).header.datasize);
                channel_cursor=intersect(channel_cursor,{datasets_header(k).header.chanlocs.labels},'stable');
                if isempty(channel_cursor)
                    CreateStruct.Interpreter = 'none';
                    CreateStruct.WindowStyle = 'modal';
                    msgbox('no common channels!','Error','error',CreateStruct);
                    set(handles.dataset_listbox,'Value',userdata.selected_datasets);
                    return;
                end
            end
            userdata.selected_datasets=selected_datasets;
            
            %set epochs
            st=cell(header.datasize(1),1);
            for k=1:header.datasize(1)
                st{k}=num2str(k);
            end
            set(handles.epoch_listbox,'String',st);
            userdata.selected_epochs=intersect(selected_epochs,1:header.datasize(1));
            if isempty(userdata.selected_epochs)
                userdata.selected_epochs=1;
            end
            set(handles.epoch_listbox,'Value',userdata.selected_epochs);
            
            %set channels
            header.datasize(2)=length(channel_cursor);
            [~,ia] = intersect(channel_cursor,{header.chanlocs.labels});
            header.chanlocs=header.chanlocs(ia);
            
            userdata.channel_index=zeros(length(userdata.selected_datasets),length(channel_cursor));
            for k=userdata.selected_datasets
                for l=1:length(channel_cursor)
                    userdata.channel_index(k,l)=find(strcmp(channel_cursor(l),{datasets_header(k).header.chanlocs.labels}),1,'first');
                end
            end
            channel_cursor_old=get(handles.channel_listbox,'String');
            [~,userdata.selected_channels,~]=intersect(channel_cursor,channel_cursor_old(selected_channels),'stable');
            userdata.selected_channels=sort(userdata.selected_channels);
            if isempty(userdata.selected_channels)
                userdata.selected_channels=1;
            end
            set(handles.channel_listbox,'String',channel_cursor);
            set(handles.channel_listbox,'Value',userdata.selected_channels);
            
            if header.datasize(3)>1;
                set(handles.index_text,'Visible','on');
                set(handles.index_popup,'Visible','on');
                if isfield(header,'index_labels');
                    set(handles.index_popup,'String',header.index_labels(1:header.datasize(3)));
                    selected_index=get(handles.index_popup,'Value');
                    userdata.selected_index=intersect(selected_index,1:header.datasize(3));
                    if isempty(userdata.selected_index)
                        userdata.selected_index=1;
                        set(handles.index_popup,'Value',userdata.selected_index);
                    end
                else
                    st=cell(header.datasize(3),1);
                    for i=1:header.datasize(3);
                        st{i}=num2str(i);
                    end
                    set(handles.index_popup,'String',st);
                    set(handles.index_popup,'Value',1);
                end
            else
                set(handles.index_text,'Visible','off');
                set(handles.index_popup,'Visible','off');
            end
            %z
            if header.datasize(4)>1;
                set(handles.z_text,'Visible','on');
                set(handles.z_edit,'Visible','on');
                z_value=get(handles.z_edit,'String');
                if isempty(z_value)
                    set(handles.z_edit,'String',num2str(header.zstart));
                end
            else
                set(handles.z_text,'Visible','off');
                set(handles.z_edit,'Visible','off');
            end
        else
            userdata.selected_epochs=selected_epochs;
            userdata.selected_channels=selected_channels;
        end
        Fig_Update;
    end

%% Fig_function
    function Fig_Update()
        switch(userdata.graph_style(1))
            case 1
                userdata.num_rows=length(userdata.selected_datasets);
            case 2
                userdata.num_rows=length(userdata.selected_epochs);
            case 3
                userdata.num_rows=length(userdata.selected_channels);
        end
        switch(userdata.graph_style(2))
            case 1
                userdata.num_cols=length(userdata.selected_datasets);
            case 2
                userdata.num_cols=length(userdata.selected_epochs);
            case 3
                userdata.num_cols=length(userdata.selected_channels);
        end
        userdata.str_dataset=get(handles.dataset_listbox,'String');
        userdata.str_epoch=get(handles.epoch_listbox,'String');
        userdata.str_channel=get(handles.channel_listbox,'String');
        
        Fig_ax;
        Fig_image;
        Edit_xaxis_auto_checkbox_Changed;
        Edit_yaxis_auto_checkbox_Changed;
        Edit_caxis_auto_checkbox_Changed;
        Fig_title;
        Fig_shade;
        Fig_polarity;
        Fig_cursor;
        if strcmp(get(handles.toolbar2_topo,'State'),'on')
            Fig_topo;
        elseif strcmp(get(handles.toolbar2_headplot,'State'),'on')
            Fig_headplot;
        else
            Fig2_SizeChangedFcn();
        end
    end
    function Fig_ax()
        for col_pos=1:userdata.num_cols
            for row_pos=1:userdata.num_rows
                ax_idx=(col_pos-1)*userdata.num_rows+row_pos;
                if length(handles.axes)<ax_idx
                    handles.axes(ax_idx)=axes('Parent',handles.panel_fig,...
                        'Position',[0,0,0.1,0.1]);
                    set(handles.axes(ax_idx),'tag','image');
                    handles.image(ax_idx)=image(0,'parent',handles.axes(ax_idx));
                end
                hold(handles.axes(ax_idx),'on');
            end
        end
        set(handles.axes,'box','off');
        set(handles.axes,'Units','pixels');
        set(handles.axes,'FontName','Arial');
        set(handles.axes,'FontUnits','pixels');
        set(handles.axes,'FontSize',9);
        set(handles.axes,'TickDir','out');
        set(handles.axes,'TickLength',[0.005 0.005]);
        set(handles.axes(1:userdata.num_cols*userdata.num_rows),'Visible','on');
        set(handles.axes(userdata.num_cols*userdata.num_rows+1:end),'Visible','off');
        a=findall(handles.fig1,'Type','axes');
        for k=1:length(a)
            colormap(a(k),userdata.color_style);
        end
        a=findall(handles.fig2,'Type','axes');
        for k=1:length(a)
            colormap(a(k),userdata.color_style);
        end
%         for k=userdata.num_cols*userdata.num_rows+1:length(handles.axes)
%             set(get(handles.axes(k),'Children'),'Visible','off');
%         end
    end
    function Fig_image()
        userdata.minmax_axis=[];
        for dataset_index=1:length(userdata.selected_datasets)
            header=datasets_header(userdata.selected_datasets(dataset_index)).header;
            [index_pos,z_pos]=Get_iz_pos(header);
            for epoch_index=1:length(userdata.selected_epochs)
                for channel_index=1:length(userdata.selected_channels)
                    switch(userdata.graph_style(1))
                        case 1
                            row_pos=dataset_index;
                        case 2
                            row_pos=epoch_index;
                        case 3
                            row_pos=channel_index;
                    end
                    switch(userdata.graph_style(2))
                        case 1
                            col_pos=dataset_index;
                        case 2
                            col_pos=epoch_index;
                        case 3
                            col_pos=channel_index;
                    end
                    ax_idx=(col_pos-1)*userdata.num_rows+row_pos;
                    dataset_pos=userdata.selected_datasets(dataset_index);
                    epoch_pos=userdata.selected_epochs(epoch_index);
                    channel_pos=userdata.channel_index(dataset_pos,userdata.selected_channels(channel_index));
                    
                    
                    x_start=datasets_header(dataset_pos).header.xstart;
                    x_step=datasets_header(dataset_pos).header.xstep;
                    x=(0:size(datasets_data(dataset_pos).data,6)-1)*x_step+x_start;
                    
                    y_start=datasets_header(dataset_pos).header.ystart;
                    y_step=datasets_header(dataset_pos).header.ystep;
                    y=(0:size(datasets_data(dataset_pos).data,5)-1)*y_step+y_start;
                    C=squeeze(datasets_data(dataset_pos).data(epoch_pos,channel_pos,index_pos,z_pos,:,:));
                    
                    if isempty(userdata.minmax_axis)
                        userdata.minmax_axis=[min(x),max(x),min(y),max(y),min(C(:)),max(C(:))];
                    else
                        userdata.minmax_axis=[min([x,userdata.minmax_axis(1)]),max([x,userdata.minmax_axis(2)]),...
                            min([y,userdata.minmax_axis(3)]),max([y,userdata.minmax_axis(4)]),...
                            min([C(:)',userdata.minmax_axis(5)]),max([C(:)',userdata.minmax_axis(6)])];
                    end
                    if userdata.minmax_axis(1)==userdata.minmax_axis(2)
                        userdata.minmax_axis(1)=userdata.minmax_axis(1)-1;
                        userdata.minmax_axis(2)=userdata.minmax_axis(2)+1;
                    end
                    if userdata.minmax_axis(3)==userdata.minmax_axis(4)
                        userdata.minmax_axis(3)=userdata.minmax_axis(3)-1;
                        userdata.minmax_axis(4)=userdata.minmax_axis(4)+1;
                    end
                    if userdata.minmax_axis(5)==userdata.minmax_axis(6)
                        userdata.minmax_axis(5)=userdata.minmax_axis(5)-1;
                        userdata.minmax_axis(6)=userdata.minmax_axis(6)+1;
                    end
                    set(handles.image(ax_idx),'XData',x,'YData',y,'CData',C);
                end
            end
        end
        set(handles.image,'CDataMapping','scaled');
        set(handles.image(1:userdata.num_rows*userdata.num_cols),'Visible','on');
        set(handles.image(userdata.num_rows*userdata.num_cols+1:end),'Visible','off');
    end
    function Fig_title(~, ~)
        userdata.is_title=strcmp(get(handles.toolbar2_title,'State'),'on');
        if userdata.is_title
            str=cell(3,1);
            if userdata.num_cols>3
                if length(userdata.selected_datasets)==1
                    str{1}={''};
                else
                    str{1}=userdata.str_dataset(userdata.selected_datasets);
                end
                
                if length(userdata.selected_epochs)==1
                    str{2}={''};
                else
                    str{2}=userdata.str_epoch(userdata.selected_epochs);
                end
                
                if length(userdata.selected_channels)==1
                    str{3}={''};
                else
                    str{3}=userdata.str_channel(userdata.selected_channels);
                end
            else
                str{1}=userdata.str_dataset(userdata.selected_datasets);
                str{2}=strcat('epoch:  ',userdata.str_epoch(userdata.selected_epochs));
                str{3}=strcat('channels:  ',userdata.str_channel(userdata.selected_channels));
            end
            for dataset_index=1:length(userdata.selected_datasets)
                for epoch_index=1:length(userdata.selected_epochs)
                    for channel_index=1:length(userdata.selected_channels)
                        switch(userdata.graph_style(1))
                            case 1
                                row_pos=dataset_index;
                            case 2
                                row_pos=epoch_index;
                            case 3
                                row_pos=channel_index;
                        end
                        switch(userdata.graph_style(2))
                            case 1
                                col_pos=dataset_index;
                            case 2
                                col_pos=epoch_index;
                            case 3
                                col_pos=channel_index;
                        end
                        ax_idx=(col_pos-1)*userdata.num_rows+row_pos;
                        if length(handles.title)<ax_idx
                            handles.title(ax_idx)=title(handles.axes(ax_idx),' ');
                        end
                        title_str={};
                        if ~isempty(str{1}{dataset_index})
                            title_str{end+1}=[' ',str{1}{dataset_index}];
                        end
                        if ~isempty(str{3}{channel_index})
                            title_str{end+1}=[' ',str{3}{channel_index}];
                        end
                        if ~isempty(str{2}{epoch_index})
                            title_str{end+1}=[' ',str{2}{epoch_index}];
                        end
                        set(handles.title(ax_idx),'String',title_str);
                    end
                end
            end
            set(handles.title,'Units','normalized',...
                'position',[0.01,0.98,0], 'Interpreter', 'none',...
                'HorizontalAlignment','left','VerticalAlignment','top'...
                ,'FontSize',10,'FontWeight','bold','color',[1,1,0.99]);
            set(handles.title(1:userdata.num_rows*userdata.num_cols),'Visible','on');
            set(handles.title(userdata.num_rows*userdata.num_cols+1:end),'Visible','off');
        else
            if ~isempty(handles.title)
                set(handles.title,'Visible','off');
            end
        end
    end
    function Fig_shade(~, ~)
        userdata.is_shade=strcmp(get(handles.toolbar2_shade,'State'),'on');
        if userdata.is_shade
            zoom off;
            pan off;
            rotate3d off;
            set(handles.toolbar2_zoomin,'State','off');
            set(handles.toolbar2_zoomout,'State','off');
            set(handles.toolbar2_pan,'State','off');
            set(handles.toolbar2_rotate,'State','off');
            for ax_idx=length(handles.shade)+1:userdata.num_cols*userdata.num_rows
                handles.shade(ax_idx)=fill(userdata.shade_x([1,2,2,1]),...
                    userdata.shade_y([1,1,2,2]),[0.8,0.8,0.8],...
                    'EdgeColor','None','FaceAlpha',0.3,...
                    'Parent',handles.axes(ax_idx));
            end
            set(handles.shade(1:userdata.num_rows*userdata.num_cols),'Visible','on');
            set(handles.shade(userdata.num_rows*userdata.num_cols+1:end),'Visible','off');
            Fig_shade_Update();
        else
            if ~isempty(handles.shade)
                set(handles.shade,'Visible','off');
            end
        end
    end
    function Fig_cursor(~, ~)
        userdata.is_cursor=strcmp(get(handles.toolbar2_cursor,'State'),'on');
        if userdata.is_cursor
            zoom off;
            pan off;
            rotate3d off;
            set(handles.toolbar2_zoomin,'State','off');
            set(handles.toolbar2_zoomout,'State','off');
            set(handles.toolbar2_pan,'State','off');
            set(handles.toolbar2_rotate,'State','off');
            for col_pos=1:userdata.num_cols
                for row_pos=1:userdata.num_rows
                    ax_idx=(col_pos-1)*userdata.num_rows+row_pos;
                    if length(handles.cursor_x)<ax_idx
                        handles.cursor_x(ax_idx)=line(userdata.cursor_point([1,1]),userdata.minmax_axis([3,4]),...
                            'Parent',handles.axes(ax_idx));
                        handles.cursor_y(ax_idx)=line(userdata.minmax_axis([1,2]),userdata.cursor_point([2,2]),...
                            'Parent',handles.axes(ax_idx));
                        handles.cursor_text(ax_idx)=text(userdata.cursor_point(1),userdata.cursor_point(2),' 0.1',...
                            'HorizontalAlignment','left','VerticalAlignment','top','Parent',handles.axes(ax_idx));
                    end
                end
            end
            
            set(handles.cursor_x,'color',[1,1,1],'Linewidth',0.1);
            set(handles.cursor_y,'color',[1,1,1],'Linewidth',0.1);
            set(handles.cursor_text,'color',[1,1,1],'Linewidth',0.1);
            set(handles.cursor_x(1:userdata.num_rows*userdata.num_cols),'Visible','on');
            set(handles.cursor_x(userdata.num_rows*userdata.num_cols+1:end),'Visible','off');
            set(handles.cursor_y(1:userdata.num_rows*userdata.num_cols),'Visible','on');
            set(handles.cursor_y(userdata.num_rows*userdata.num_cols+1:end),'Visible','off');
            set(handles.cursor_text(1:userdata.num_rows*userdata.num_cols),'Visible','on');
            set(handles.cursor_text(userdata.num_rows*userdata.num_cols+1:end),'Visible','off');
            Fig_cursor_Update();
        else
            if ~isempty(handles.cursor_x)
                set(handles.cursor_x,'Visible','off');
                set(handles.cursor_y,'Visible','off');
                set(handles.cursor_text,'Visible','off');
            end
        end
        set(handles.cursor_edit_x,'String',num2str(userdata.cursor_point(1)));
        set(handles.cursor_edit_y,'String',num2str(userdata.cursor_point(2)));
    end
    function Fig_polarity(~, ~)
        userdata.is_polarity=strcmp(get(handles.toolbar2_polarity,'State'),'on');
        if userdata.is_polarity
            set(handles.axes,'YDir','reverse');
        else
            set(handles.axes,'YDir','normal');
        end
    end
    function Fig_topo(~,~)
        userdata.is_topo=strcmp(get(handles.toolbar2_topo,'State'),'on');
        if userdata.is_topo
            if userdata.is_headplot
                set(handles.toolbar2_headplot,'State','off');
                userdata.is_headplot=0;
                if ~isempty(handles.colorbar_headplot)
                    set(handles.colorbar_headplot,'Visible','off');
                    set(handles.axes_headplot,'Visible','off');
                    set(handles.title_headplot,'Visible','off');
                    set(handles.surface_headplot,'Visible','off');
                    set(handles.dot_headplot,'Visible','off');
                end
            end
            
            [xq,yq] = meshgrid(linspace(-0.5,0.5,67),linspace(-0.5,0.5,67));
            delta = (xq(2)-xq(1))/2;
            ax_num=min(length(userdata.selected_datasets)*length(userdata.selected_epochs),4);
            for ax_idx=1:ax_num
                if length(handles.axes_topo)<ax_idx
                    handles.axes_topo(ax_idx)=axes('Parent',handles.panel_fig,'units','pixels');
                    colormap(handles.axes_topo(ax_idx),userdata.color_style);
                    caxis(handles.axes_topo(ax_idx),userdata.last_axis(5:6));
                    set(handles.axes_topo(ax_idx),'Xlim',[-0.55,0.55]);
                    set(handles.axes_topo(ax_idx),'Ylim',[-0.5,0.6]);
                    axis(handles.axes_topo(ax_idx),'square');
                    hold(handles.axes_topo(ax_idx),'on')
                    handles.title_topo(ax_idx)=title(handles.axes_topo(ax_idx),'hello','Interpreter','none');
                    handles.surface_topo(ax_idx)=surface(xq-delta,yq-delta,zeros(size(xq)),xq,...
                        'EdgeColor','none','FaceColor','flat','parent',handles.axes_topo(ax_idx));
                    headx = 0.5*[sin(linspace(0,2*pi,100)),NaN,sin(-2*pi*10/360),0,sin(2*pi*10/360),NaN,...
                        0.1*cos(2*pi/360*linspace(80,360-80,100))-1,NaN,...
                        -0.1*cos(2*pi/360*linspace(80,360-80,100))+1];
                    heady = 0.5*[cos(linspace(0,2*pi,100)),NaN,cos(-2*pi*10/360),1.1,cos(2*pi*10/360),NaN,...
                        0.2*sin(2*pi/360*linspace(80,360-80,100)),NaN,0.2*sin(2*pi/360*linspace(80,360-80,100))];
                    handles.line_topo(ax_idx)=line(headx,heady,'Color',[0,0,0],'Linewidth',2,'parent',handles.axes_topo(ax_idx));
                    handles.dot_topo(ax_idx)=line(headx,heady,'Color',[0,0,0],'Linestyle','none','Marker','.','Markersize',8,'parent',handles.axes_topo(ax_idx));
                    set(handles.surface_topo(ax_idx),'ButtonDownFcn',{@Fig_topo_Popup});
                    set(handles.line_topo(ax_idx),'ButtonDownFcn',{@Fig_topo_Popup});
                    set(handles.dot_topo(ax_idx),'ButtonDownFcn',{@Fig_topo_Popup});
                end
                dataset_index=ceil(ax_idx/length(userdata.selected_epochs));
                epoch_index=mod(ax_idx-1,length(userdata.selected_epochs))+1;
                set(handles.title_topo(ax_idx),'String',...
                    [char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']']);
            end
            if isempty(handles.colorbar_topo)
                handles.colorbar_topo=colorbar;
                set(handles.colorbar_topo,'units','pixels');
                set(handles.colorbar_topo,'FontName','Arial');
                set(handles.colorbar_topo,'FontSize',6);
            else
                set(handles.colorbar_topo,'Visible','on');
            end
            set(handles.axes_topo,'Visible','off');
            set(handles.title_topo(1:ax_num),'Visible','on');
            set(handles.title_topo(ax_num+1:end),'Visible','off');
            set(handles.surface_topo(1:ax_num),'Visible','on');
            set(handles.surface_topo(ax_num+1:end),'Visible','off');
            set(handles.line_topo(1:ax_num),'Visible','on');
            set(handles.line_topo(ax_num+1:end),'Visible','off');
            set(handles.dot_topo(1:ax_num),'Visible','on');
            set(handles.dot_topo(ax_num+1:end),'Visible','off');
            ax_idx=0;
            for dataset_index=1:length(userdata.selected_datasets)
                if(ax_idx>ax_num)
                    break;
                end
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                chan_used=find([header.chanlocs.topo_enabled]==1);
                chanlocs=header.chanlocs(chan_used);
                [y,x]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
                for epoch_index=1:length(userdata.selected_epochs)
                    ax_idx=ax_idx+1;
                    if(ax_idx>ax_num)
                        break;
                    end
                    set( handles.dot_topo(ax_idx),'XData',x);
                    set( handles.dot_topo(ax_idx),'YData',y);
                end
            end
            Fig_topo_Update();
        else
            if ~isempty(handles.colorbar_topo)
                set(handles.colorbar_topo,'Visible','off');
                set(handles.axes_topo,'Visible','off');
                set(handles.title_topo,'Visible','off');
                set(handles.surface_topo,'Visible','off');
                set(handles.line_topo,'Visible','off');
                set(handles.dot_topo,'Visible','off');
            end
        end
        Fig2_SizeChangedFcn();
    end
    function Fig_headplot(~,~)
        userdata.is_headplot=strcmp(get(handles.toolbar2_headplot,'State'),'on');
        if userdata.is_headplot
            if userdata.is_topo
                set(handles.toolbar2_topo,'State','off');
                userdata.is_topo=0;
                if ~isempty(handles.colorbar_topo)
                    set(handles.colorbar_topo,'Visible','off');
                    set(handles.axes_topo,'Visible','off');
                    set(handles.title_topo,'Visible','off');
                    set(handles.surface_topo,'Visible','off');
                    set(handles.line_topo,'Visible','off');
                    set(handles.dot_topo,'Visible','off');
                end
            end
            ax_num=min(length(userdata.selected_datasets)...
                *length(userdata.selected_epochs),4);
            for ax_idx=1:ax_num
                if length(handles.axes_headplot)<ax_idx
                    handles.axes_headplot(ax_idx)=axes('Parent',...
                        handles.panel_fig,'units','pixels');
                    colormap(handles.axes_headplot(ax_idx),jet(userdata.headplot_colornum));
                    caxis(handles.axes_headplot(ax_idx),userdata.last_axis(5:6));
                    axis(handles.axes_headplot(ax_idx),'image');
                    handles.title_headplot(ax_idx)=title(...
                        handles.axes_headplot(ax_idx),'hello',...
                        'Interpreter','none');
                    light('Position',[-125  125  80],'Style','infinite')
                    light('Position',[125  125  80],'Style','infinite')
                    light('Position',[125 -125 80],'Style','infinite')
                    light('Position',[-125 -125 80],'Style','infinite')
                    lighting phong;
                    
                    P=linspace(1,userdata.headplot_colornum,length(userdata.POS))';
                    handles.surface_headplot(ax_idx) = ...
                        patch('Vertices',userdata.POS,'Faces',userdata.TRI,...
                        'FaceVertexCdata',P,'FaceColor','interp', ...
                        'EdgeColor','none');
                    set(handles.surface_headplot(ax_idx),'DiffuseStrength',.6,...
                        'SpecularStrength',0,'AmbientStrength',.3,...
                        'SpecularExponent',5,'vertexnormals', userdata.NORM);
                    axis(handles.axes_headplot(ax_idx),[-125 125 -125 125 -125 125]);
                    view([0 90]);
                    handles.dot_headplot(ax_idx)=line(1,1,1,'Color',[0,0,0],...
                        'Linestyle','none','Marker','.','Markersize',6,...
                        'parent',handles.axes_headplot(ax_idx));
                    set(handles.surface_headplot(ax_idx),'ButtonDownFcn',{@Fig_headplot_Popup});
                    set(handles.dot_headplot(ax_idx),'ButtonDownFcn',{@Fig_headplot_Popup});
                end
                dataset_index=ceil(ax_idx/length(userdata.selected_epochs));
                epoch_index=mod(ax_idx-1,length(userdata.selected_epochs))+1;
                set(handles.title_headplot(ax_idx),'String',...
                    [char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']']);
            end
            if isempty(handles.colorbar_headplot)
                handles.colorbar_headplot=colorbar;
                set(handles.colorbar_headplot,'units','pixels');
                set(handles.colorbar_headplot,'FontName','Arial');
                set(handles.colorbar_headplot,'FontSize',6);
            else
                set(handles.colorbar_headplot,'Visible','on');
            end
            set(handles.axes_headplot,'Visible','off');
            set(handles.title_headplot(1:ax_num),'Visible','on');
            set(handles.title_headplot(ax_num+1:end),'Visible','off');
            set(handles.surface_headplot(1:ax_num),'Visible','on');
            set(handles.surface_headplot(ax_num+1:end),'Visible','off');
            set(handles.dot_headplot(1:ax_num),'Visible','on');
            set(handles.dot_headplot(ax_num+1:end),'Visible','off');
            ax_idx=0;
            for dataset_index=1:length(userdata.selected_datasets)
                if(ax_idx>ax_num)
                    break;
                end
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                for epoch_index=1:length(userdata.selected_epochs)
                    ax_idx=ax_idx+1;
                    if(ax_idx>ax_num)
                        break;
                    end
                    set( handles.dot_headplot(ax_idx),'XData',header.spl.newElect(:,1));
                    set( handles.dot_headplot(ax_idx),'YData',header.spl.newElect(:,2));
                    set( handles.dot_headplot(ax_idx),'ZData',header.spl.newElect(:,3));
                end
            end
            Fig_headplot_Update();
        else
            if ~isempty(handles.colorbar_headplot)
                set(handles.colorbar_headplot,'Visible','off');
                set(handles.axes_headplot,'Visible','off');
                set(handles.title_headplot,'Visible','off');
                set(handles.surface_headplot,'Visible','off');
                set(handles.dot_headplot,'Visible','off');
            end
        end
        Fig2_SizeChangedFcn();
    end
    function Fig_save(~,~)
        [FileName,PathName,FilterIndex] = uiputfile(...
            {'*.tif','TIFF image (*.tif)';...
            '*.jpg','JPEG image (*.jpg)';...
            '*.bmp','Bitmap file (*.bmp)';...
            '*.png','Protable Network Graphics file (*.png)';...
            '*.eps','EPS file (*.eps)';...
            '*.pdf','Portable Document Format (*.pdf)'},...
            'Save As','new figure');
        
%             '*.tif','TIFF no compression image (*.tif)';...
%             '*.pcx','Painbrush 24-bit file (*.pcx)';...
%             '*.pbm','Portable Bitmap file (*.pbm)';...
%             '*.pgm','Portable Graymap file (*.pgm)';...
%             '*.ppm','Portable Pixmap file (*.ppm)';...
%             '*.svg','Scalable Vector Graphics file (*.svg)';...
%             '*.fig','MATLAB Figure (*.fig)';...

        if FilterIndex==0
            return;
        end
        is_split=userdata.is_split;
        if ~is_split
            Fig_split();
        end
        set(handles.panel_fig,'background',[1,1,1]);
        switch  FilterIndex
            case 1 %tiff compressed
                saveas(handles.fig2,fullfile(PathName,FileName));
            case 2 %JPEG image
                saveas(handles.fig2,fullfile(PathName,FileName));
            case 3 %Bitmap file
                saveas(handles.fig2,fullfile(PathName,FileName));
            case 4 %Protable Network Graphics
                saveas(handles.fig2,fullfile(PathName,FileName));
            case 5 %EPS file
                is_headplot=userdata.is_headplot;
                is_shade=userdata.is_shade;
                if is_headplot
                    set(handles.toolbar2_headplot,'State','off');
                    Fig_headplot();
                end
                if is_shade
                    set(handles.toolbar2_shade,'State','off');
                    Fig_shade();
                end
                saveas(handles.fig2,fullfile(PathName,FileName),'epsc');
                if is_shade
                    set(handles.toolbar2_shade,'State','on');
                    Fig_shade();
                end
                if is_headplot
                    set(handles.toolbar2_headplot,'State','on');
                    Fig_headplot();
                end
            case 6 %Portable Document Format
                is_headplot=userdata.is_headplot;
                if is_headplot
                    set(handles.toolbar2_headplot,'State','off');
                    Fig_headplot();
                end
                saveas(handles.fig2,fullfile(PathName,FileName));
                if is_headplot
                    set(handles.toolbar2_headplot,'State','on');
                    Fig_headplot();
                end
        end
        set(handles.panel_fig,'background',0.94*[1,1,1]);
        if ~is_split
            Fig_split();
        end
    end
    function Edit_xaxis_auto_checkbox_Changed(~, ~)
        userdata.auto_x=get(handles.xaxis_auto_checkbox,'Value');
        if  userdata.auto_x==1
            userdata.last_axis(1:2)=userdata.minmax_axis(1:2);
            set(handles.xaxis1_edit,'String',num2str(userdata.last_axis(1)));
            set(handles.xaxis2_edit,'String',num2str(userdata.last_axis(2)));
        end
        set(handles.axes,'XLim',userdata.last_axis(1:2));
        set(handles.cursor_y,'XData',[userdata.last_axis(1),userdata.last_axis(2)]);
        for k=1:userdata.num_cols*userdata.num_rows
            zoom(handles.axes(k),'reset');
        end
    end
    function Edit_yaxis_auto_checkbox_Changed(~, ~)
        userdata.auto_y=get(handles.yaxis_auto_checkbox,'Value');
        if  userdata.auto_y==1
            userdata.last_axis(3:4)=userdata.minmax_axis(3:4);
            set(handles.yaxis1_edit,'String',num2str(userdata.last_axis(3)));
            set(handles.yaxis2_edit,'String',num2str(userdata.last_axis(4)));
        end
        set(handles.axes,'YLim',userdata.last_axis(3:4));
        set(handles.cursor_x,'YData',[userdata.last_axis(3),userdata.last_axis(4)]);
        for k=1:userdata.num_cols*userdata.num_rows
            zoom(handles.axes(k),'reset');
        end
    end
    function Edit_caxis_auto_checkbox_Changed(~, ~)
        userdata.auto_c=get(handles.caxis_auto_checkbox,'Value');
        if  userdata.auto_c==1
            userdata.last_axis(5:6)=userdata.minmax_axis(5:6);
            set(handles.caxis1_edit,'String',num2str(userdata.last_axis(5)));
            set(handles.caxis2_edit,'String',num2str(userdata.last_axis(6)));
            if ~isempty(handles.axes_topo)
                for k=1:length(handles.axes_topo)
                    caxis(handles.axes_topo(k),userdata.last_axis(5:6));
                end
            end
            if ~isempty(handles.axes_headplot)
                for k=1:length(handles.axes_headplot)
                    caxis(handles.axes_headplot(k),userdata.last_axis(5:6));
                end
            end
        end
        set(handles.axes,'CLim',userdata.last_axis(5:6));
    end
    function Edit_cursor_auto_checkbox_Changed(~,~)
        userdata.lock_cursor=get(handles.cursor_auto_checkbox,'Value');
    end
    function Edit_xaxis_Changed(~, ~)
        x(1) = str2double(get(handles.xaxis1_edit, 'String'));
        x(2) = str2double(get(handles.xaxis2_edit, 'String'));
        if x(1)==x(2)
            x(1)=x(1)-1;
            x(2)=x(2)+1;
            set(handles.xaxis1_edit,'String',x(1));
            set(handles.xaxis2_edit,'String',x(2));
        end
        if(x(1)>x(2))
            x=x([2,1]);
            set(handles.xaxis1_edit,'String',x(1));
            set(handles.xaxis2_edit,'String',x(2));
        end
        userdata.last_axis([1,2])=x;
        set(handles.cursor_y,'XData',[userdata.last_axis(1),userdata.last_axis(2)]);
        set(handles.axes,'XLim',userdata.last_axis(1:2));
        userdata.auto_x=0;set(handles.xaxis_auto_checkbox,'Value',userdata.auto_x);
        for k=1:userdata.num_cols*userdata.num_rows
            zoom(handles.axes(k),'reset');
        end
    end
    function Edit_yaxis_Changed(~, ~)
        x(1) = str2double(get(handles.yaxis1_edit, 'String'));
        x(2) = str2double(get(handles.yaxis2_edit, 'String'));
        if x(1)==x(2)
            x(1)=x(1)-1;
            x(2)=x(2)+1;
            set(handles.yaxis1_edit,'String',x(1));
            set(handles.yaxis2_edit,'String',x(2));
        end
        if(x(1)>x(2))
            x=x([2,1]);
            set(handles.yaxis1_edit,'String',x(1));
            set(handles.yaxis2_edit,'String',x(2));
        end
        
        userdata.last_axis([3,4])=x;
        set(handles.axes,'YLim',userdata.last_axis(3:4));
        set(handles.cursor_x,'YData',[userdata.last_axis(3),userdata.last_axis(4)]);
        userdata.auto_y=0;set(handles.yaxis_auto_checkbox,'Value',userdata.auto_y);
        for k=1:userdata.num_cols*userdata.num_rows
            zoom(handles.axes(k),'reset');
        end
    end
    function Edit_caxis_Changed(~, ~)
        x(1) = str2double(get(handles.caxis1_edit, 'String'));
        x(2) = str2double(get(handles.caxis2_edit, 'String'));
        if x(1)==x(2)
            x(1)=x(1)-1;
            x(2)=x(2)+1;
            set(handles.caxis1_edit,'String',x(1));
            set(handles.caxis2_edit,'String',x(2));
        end
        if(x(1)>x(2))
            x=x([2,1]);
            set(handles.caxis1_edit,'String',x(1));
            set(handles.caxis2_edit,'String',x(2));
        end
        
        userdata.last_axis([5,6])=x;
        %caxis(userdata.last_axis(5:6));
        %caxis(handles.axes,userdata.last_axis(5:6));
        set(handles.axes,'CLim',userdata.last_axis(5:6));
        userdata.auto_c=0;set(handles.caxis_auto_checkbox,'Value',userdata.auto_c);
        
        
        if ~isempty(handles.axes_topo)
            for k=1:length(handles.axes_topo)
                caxis(handles.axes_topo(k),userdata.last_axis(5:6));
            end
        end
        if ~isempty(handles.axes_headplot)
            for k=1:length(handles.axes_headplot)
                caxis(handles.axes_headplot(k),userdata.last_axis(5:6));
            end
        end
    end
    function Edit_cursor_Changed(~,~)
        userdata.lock_cursor=1;
        set(handles.cursor_auto_checkbox,'Value',userdata.lock_cursor);
        userdata.cursor_point(1)=str2double(get(handles.cursor_edit_x,'String'));
        userdata.cursor_point(2)=str2double(get(handles.cursor_edit_y,'String'));
        Fig_cursor_Update();
        Fig_topo_Update();
        Fig_headplot_Update();
    end
    function Popup_colormap_Changed(~,~)
        str=get(handles.caxis_style_popup,'string');
        value=get(handles.caxis_style_popup,'value');
        userdata.color_style=str{value};
        a=findall(handles.fig1,'Type','axes');
        for k=1:length(a)
            colormap(a(k),userdata.color_style);
        end
        a=findall(handles.fig2,'Type','axes');
        for k=1:length(a)
            colormap(a(k),userdata.color_style);
        end
    end
    function Edit_interval_Changed(~, ~)
        x(1) = str2num(get(handles.interval1_edit_x,'String'));
        x(2) = str2num(get(handles.interval2_edit_x,'String'));
        y(1) = str2num(get(handles.interval1_edit_y,'String'));
        y(2) = str2num(get(handles.interval2_edit_y,'String'));
        if(x(1)>x(2))
            x=x([2,1]);
            set(handles.interval1_edit_x,'String',x(1));
            set(handles.interval2_edit_x,'String',x(2));
        end
        if(y(1)>y(2))
            y=y([2,1]);
            set(handles.interval1_edit_y,'String',y(1));
            set(handles.interval2_edit_y,'String',y(2));
        end
        userdata.shade_x=x;
        userdata.shade_y=y;
        Fig_shade_Update();
    end
    function Edit_interval_table(~,~)
        x1 = str2num(get(handles.interval1_edit_x,'String'));
        x2 = str2num(get(handles.interval2_edit_x,'String'));
        y1 = str2num(get(handles.interval1_edit_y,'String'));
        y2 = str2num(get(handles.interval2_edit_y,'String'));
        table_idx=1;
        table_data={};
        for dataset_index=1:length(userdata.selected_datasets)
            header=datasets_header(userdata.selected_datasets(dataset_index)).header;
            [index_pos,z_pos]=Get_iz_pos(header);
            dataset_pos=userdata.selected_datasets(dataset_index);
            x_start=datasets_header(dataset_pos).header.xstart;
            x_step=datasets_header(dataset_pos).header.xstep;
            x=(0:size(datasets_data(dataset_pos).data,6)-1)*x_step+x_start;
            x_pos=find(x>x1 & x<x2);
            
            y_start=datasets_header(dataset_pos).header.ystart;
            y_step=datasets_header(dataset_pos).header.ystep;
            y=(0:size(datasets_data(dataset_pos).data,5)-1)*y_step+y_start;
            y_pos=find(y>y1 & y<y2);
            
            for epoch_index=1:length(userdata.selected_epochs)
                epoch_pos=userdata.selected_epochs(epoch_index);
                for channel_index=1:length(userdata.selected_channels)
                    channel_pos=userdata.channel_index(dataset_pos,userdata.selected_channels(channel_index));
                    c=squeeze(datasets_data(dataset_pos).data(epoch_pos,channel_pos,index_pos,z_pos,y_pos,x_pos))';
                    
                    [cmax,b]=max(c(:));
                    xmax=x(x_pos(mod(b-1,length(x_pos))+1));
                    ymax=y(y_pos(ceil(b/length(x_pos))));
                    [cmin,b]=min(c(:));
                    xmin=x(x_pos(mod(b-1,length(x_pos))+1));
                    ymin=y(y_pos(ceil(b/length(x_pos))));
                    cmean=mean(c(:));
                    
                    table_data{table_idx,1}=userdata.str_dataset{dataset_pos};
                    table_data{table_idx,2}=userdata.str_channel{userdata.selected_channels(channel_index)};
                    table_data{table_idx,3}=num2str(epoch_pos);
                    table_data{table_idx,4}=num2str(xmax);
                    table_data{table_idx,5}=num2str(ymax);
                    table_data{table_idx,6}=num2str(cmax);
                    table_data{table_idx,7}=num2str(xmin);
                    table_data{table_idx,8}=num2str(ymin);
                    table_data{table_idx,9}=num2str(cmin);
                    table_data{table_idx,10}=num2str(cmean);
                    table_idx=table_idx+1;
                end
            end
        end
        
        col_headers{1}='dataset';
        col_headers{2}='channel';
        col_headers{3}='epoch';
        col_headers{4}='xmax';
        col_headers{5}='ymax';
        col_headers{6}='cmax';
        col_headers{7}='xmin';
        col_headers{8}='ymin';
        col_headers{9}='cmin';
        col_headers{10}='cmean';
        
        temp=get(0,'MonitorPositions');
        temp=temp(1,:);
        pos=[(temp(3)-800)/2,(temp(4)-400)/2-50,800,400];
        h = figure('name','LW_Table','numbertitle','off','position',pos);
        set(h,'MenuBar','none');
        set(h,'DockControls','off');
        uitable(h,'position',[1,40,pos(3),pos(4)-40],'Data',table_data,...
            'ColumnName',col_headers,'Units','normalized');
        btn=uicontrol('style','pushbutton','position',[1,1,pos(3),39],...
            'string','send the table to workspace','Units','normalized');
        set(btn,'callback',@(src,eventdata)assignin('base','lw_table',table_data));
    end
    function Edit_interval_plot(~,~)
        x1 = str2num(get(handles.interval1_edit_x,'String'));
        x2 = str2num(get(handles.interval2_edit_x,'String'));
        y1 = str2num(get(handles.interval1_edit_y,'String'));
        y2 = str2num(get(handles.interval2_edit_y,'String'));
        
        fig_temp=figure();
        [xq,yq] = meshgrid(linspace(-0.5,0.5,267),linspace(-0.5,0.5,267));
        delta = (xq(2)-xq(1))/2;
        ax_num=length(userdata.selected_datasets)*length(userdata.selected_epochs);
        row_num=length(userdata.selected_datasets);
        col_num=length(userdata.selected_epochs);
        if(col_num>7)
            col_num=7;
            row_num=ceil(ax_num/7);
        end
        for ax_idx=1:ax_num
            axes_topo(ax_idx)=subplot(row_num,col_num,ax_idx);
            
            colormap(axes_topo(ax_idx),userdata.color_style);
            set(axes_topo(ax_idx),'Xlim',[-0.55,0.55]);
            set(axes_topo(ax_idx),'Ylim',[-0.5,0.6]);
            caxis(axes_topo(ax_idx),userdata.last_axis(5:6));
            hold(axes_topo(ax_idx),'on');
            axis(axes_topo(ax_idx),'square');
            surface_topo(ax_idx)=surface(xq-delta,yq-delta,zeros(size(xq)),xq,...
                'EdgeColor','none','FaceColor','flat','parent',axes_topo(ax_idx));
            headx = 0.5*[sin(linspace(0,2*pi,100)),NaN,sin(-2*pi*10/360),0,sin(2*pi*10/360),NaN,...
                0.1*cos(2*pi/360*linspace(80,360-80,100))-1,NaN,...
                -0.1*cos(2*pi/360*linspace(80,360-80,100))+1];
            heady = 0.5*[cos(linspace(0,2*pi,100)),NaN,cos(-2*pi*10/360),1.1,cos(2*pi*10/360),NaN,...
                0.2*sin(2*pi/360*linspace(80,360-80,100)),NaN,0.2*sin(2*pi/360*linspace(80,360-80,100))];
            line_topo(ax_idx)=line(headx,heady,'Color',[0,0,0],'Linewidth',2,'parent',axes_topo(ax_idx));
            dot_topo(ax_idx)=line(headx,heady,'Color',[0,0,0],'Linestyle','none','Marker','.','Markersize',8,'parent',axes_topo(ax_idx));
        end
        colorbar_topo=colorbar;
        p=get(fig_temp,'position');
        set(colorbar_topo,'units','pixels');
        set(colorbar_topo,'position',[p(3)-40,10,10,p(4)-20]);
        set(colorbar_topo,'units','normalized');
        set(axes_topo,'Visible','off');
        ax_idx=0;
        for dataset_index=1:length(userdata.selected_datasets)
            header=datasets_header(userdata.selected_datasets(dataset_index)).header;
            chan_used=find([header.chanlocs.topo_enabled]==1);
            if isempty(chan_used)
                vq=nan(267,267);
                for epoch_index=1:length(userdata.selected_epochs)
                    ax_idx=ax_idx+1;
                    set( surface_topo(ax_idx),'CData',vq);
                    str=[char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']'];
                    title_topo(ax_idx)=title(axes_topo(ax_idx),str,'Interpreter','none');
                end
            else
                t_x=(0:header.datasize(6)-1)*header.xstep+header.xstart;
                t_y=(0:header.datasize(5)-1)*header.ystep+header.ystart;
                chanlocs=header.chanlocs(chan_used);
                [y,x]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
                [index_pos,z_pos]=Get_iz_pos(header);
%                 [~,x_pos]=min(abs(t_x-userdata.cursor_point(1)));
%                 [~,y_pos]=min(abs(t_y-userdata.cursor_point(2)));
                
                
            dataset_pos=userdata.selected_datasets(dataset_index);
            x_start=datasets_header(dataset_pos).header.xstart;
            x_step=datasets_header(dataset_pos).header.xstep;
            x_temp=(0:size(datasets_data(dataset_pos).data,6)-1)*x_step+x_start;
            x_pos= x_temp>x1 & x_temp<x2;
            
            y_start=datasets_header(dataset_pos).header.ystart;
            y_step=datasets_header(dataset_pos).header.ystep;
            y_temp=(0:size(datasets_data(dataset_pos).data,5)-1)*y_step+y_start;
            y_pos= y_temp>y1 & y_temp<y2;
            
            
            data=squeeze(mean(mean(datasets_data(dataset_pos).data...
                (:,chan_used,index_pos,z_pos,y_pos,x_pos),5),6));
            for epoch_index=1:length(userdata.selected_epochs)
                    ax_idx=ax_idx+1;
                    vq = griddata(x,y,data(userdata.selected_epochs(epoch_index),:),xq,yq,'cubic');
                    set( surface_topo(ax_idx),'CData',vq);
                    set( dot_topo(ax_idx),'XData',x);
                    set( dot_topo(ax_idx),'YData',y);
                    str=[char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']'];
                    title_topo(ax_idx)=title(axes_topo(ax_idx),str,'Interpreter','none');
                end
            end
        end
        set(title_topo,'Visible','on');
    end
    function Fig_split(~, ~)
        userdata.is_split=~userdata.is_split;
        if userdata.is_split==1
            set(handles.toolbar1,'Visible','on');
            set(handles.toolbar2,'parent',handles.fig2);
            userdata.fig1_pos=get(handles.fig1,'Position');
            userdata.fig2_pos=userdata.fig1_pos;
            userdata.fig2_pos(1)=userdata.fig1_pos(1)+365;
            userdata.fig2_pos(3)=userdata.fig2_pos(3)-365;
            set(handles.fig2,'Position',userdata.fig2_pos);
            userdata.fig1_pos(3)=350;
            set(handles.fig1,'Position',userdata.fig1_pos);
            
            set(handles.toolbar1_split,'State','on');
            set(handles.toolbar2_split,'State','on');
            set(handles.fig2,'visible','on');
            set(handles.panel_fig,'parent',handles.fig2);
            set(handles.panel_fig,'Units','normalized');
            set(handles.panel_fig,'Position',[0,0,1,1]);
        else
            set(handles.toolbar1,'Visible','off');
            set(handles.toolbar2,'parent',handles.fig1);
            set(handles.panel_fig,'parent',handles.fig1);
            set(handles.fig2,'visible','off');
            set(handles.toolbar1_split,'State','off');
            set(handles.toolbar2_split,'State','off');
            userdata.fig1_pos=get(handles.fig1,'Position');
            userdata.fig2_pos=get(handles.fig2,'Position');
            userdata.fig1_pos(1)=userdata.fig2_pos(1)-365;
            userdata.fig1_pos(3)=userdata.fig2_pos(3)+365;
            userdata.fig1_pos(4)=userdata.fig2_pos(4);
            set(handles.fig1,'Position',userdata.fig1_pos);
            figure(handles.fig1);
        end
        Fig1_SizeChangedFcn;
        Fig2_SizeChangedFcn;
    end
    function Fig_BtnDown(~, ~)
        persistent shade_x_temp;
        persistent shade_y_temp;
        temp = get(gca,'CurrentPoint');
        if (temp(1,1)>userdata.last_axis(1) && temp(1,1)<userdata.last_axis(2)...
                && temp(1,2)>userdata.last_axis(3) && temp(1,2)<userdata.last_axis(4))
            switch get(gcf,'SelectionType')
                case 'normal'
                    if userdata.is_shade==1
                        userdata.mouse_state=1;
                        shade_x_temp=userdata.shade_x;
                        shade_y_temp=userdata.shade_y;
                        userdata.shade_x(1)=temp(1,1);
                        userdata.shade_x(2)=temp(1,1);
                        userdata.shade_y(1)=temp(1,2);
                        userdata.shade_y(2)=temp(1,2);
                        set(handles.interval1_edit_x,'String',num2str(userdata.shade_x(1)));
                        set(handles.interval2_edit_x,'String',num2str(userdata.shade_x(2)));
                        set(handles.interval1_edit_y,'String',num2str(userdata.shade_y(1)));
                        set(handles.interval2_edit_y,'String',num2str(userdata.shade_y(2)));
                        Fig_shade_Update();
                    end
                case 'open'
                    userdata.lock_cursor=1;
                    set(handles.cursor_auto_checkbox,'Value',userdata.lock_cursor);
                    userdata.cursor_point=[temp(1,1),temp(1,2)];
                    set(handles.cursor_edit_x,'String',num2str(userdata.cursor_point(1)));
                    set(handles.cursor_edit_y,'String',num2str(userdata.cursor_point(2)));
                    Fig_cursor_Update();
                    Fig_topo_Update();
                    Fig_headplot_Update();
                    if userdata.is_shade==1
                        userdata.mouse_state=0;
                        userdata.shade_x=shade_x_temp;
                        userdata.shade_y=shade_y_temp;
                        set(handles.interval1_edit_x,'String',num2str(userdata.shade_x(1)));
                        set(handles.interval2_edit_x,'String',num2str(userdata.shade_x(2)));
                        set(handles.interval1_edit_y,'String',num2str(userdata.shade_y(1)));
                        set(handles.interval2_edit_y,'String',num2str(userdata.shade_y(2)));
                        Fig_shade_Update();
                    end
                case 'alt'
                    userdata.lock_cursor=0;
                    set(handles.cursor_auto_checkbox,'Value',userdata.lock_cursor);
                    userdata.cursor_point=[temp(1,1),temp(1,2)];
                    set(handles.cursor_edit_x,'String',num2str(userdata.cursor_point(1)));
                    set(handles.cursor_edit_y,'String',num2str(userdata.cursor_point(2)));
                    Fig_cursor_Update();
                    Fig_topo_Update();
            end
        end
    end
    function Fig_BtnMotion(~, ~)
        is_inaxis=0;
        for ax_id=1:userdata.num_cols*userdata.num_rows
            col_pos=ceil(ax_id/userdata.num_rows);
            row_pos=mod(ax_id-1,userdata.num_rows)+1;
            temp=get(handles.axes((col_pos-1)*userdata.num_rows+row_pos),'CurrentPoint');
            temp=temp(1,[1,2]);
            if(temp(1)-userdata.last_axis(1))*(temp(1)-userdata.last_axis(2))<0 &&...
                    (temp(2)-userdata.last_axis(3))*(temp(2)-userdata.last_axis(4))<0
                is_inaxis=1;
                userdata.current_point=temp;
                userdata.current_ax=col_pos;
                break;
            end
        end
        if(is_inaxis==0)
            return;
        end
        if userdata.is_shade==1
            if(userdata.mouse_state==1)
                userdata.shade_x(2)=userdata.current_point(1);
                if userdata.shade_x(2)<userdata.last_axis(1)
                    userdata.shade_x(2)=userdata.last_axis(1);
                end
                if userdata.shade_x(2)>userdata.last_axis(2)
                    userdata.shade_x(2)=userdata.last_axis(2);
                end
                
                userdata.shade_y(2)=userdata.current_point(2);
                if userdata.shade_y(2)<userdata.last_axis(3)
                    userdata.shade_y(2)=userdata.last_axis(3);
                end
                if userdata.shade_y(2)>userdata.last_axis(4)
                    userdata.shade_y(2)=userdata.last_axis(4);
                end
                Fig_shade_Update();
                if userdata.shade_x(1)>userdata.shade_x(2)
                    set(handles.interval1_edit_x,'String',num2str(userdata.shade_x(2)));
                    set(handles.interval2_edit_x,'String',num2str(userdata.shade_x(1)));
                else
                    set(handles.interval1_edit_x,'String',num2str(userdata.shade_x(1)));
                    set(handles.interval2_edit_x,'String',num2str(userdata.shade_x(2)));
                end
                
                if userdata.shade_y(1)>userdata.shade_y(2)
                    set(handles.interval1_edit_y,'String',num2str(userdata.shade_y(2)));
                    set(handles.interval2_edit_y,'String',num2str(userdata.shade_y(1)));
                else
                    set(handles.interval1_edit_y,'String',num2str(userdata.shade_y(1)));
                    set(handles.interval2_edit_y,'String',num2str(userdata.shade_y(2)));
                end
            end
        end
        if ~userdata.lock_cursor
            userdata.cursor_point=userdata.current_point;
            set(handles.cursor_edit_x,'String',num2str(userdata.cursor_point(1)));
            set(handles.cursor_edit_y,'String',num2str(userdata.cursor_point(2)));
            Fig_cursor_Update();
            Fig_topo_Update();
            Fig_headplot_Update();
        end
    end
    function Fig_BtnUp(~, ~)
        if userdata.is_shade==1
            if(userdata.mouse_state==1)
                temp = get(gca,'CurrentPoint');
                point1=temp(1,[1,2]);
                userdata.shade_x(2)=point1(1);
                if userdata.shade_x(2)<userdata.last_axis(1)
                    userdata.shade_x(2)=userdata.last_axis(1);
                end
                if userdata.shade_x(2)>userdata.last_axis(2)
                    userdata.shade_x(2)=userdata.last_axis(2);
                end
                
                userdata.shade_y(2)=point1(2);
                if userdata.shade_y(2)<userdata.last_axis(3)
                    userdata.shade_y(2)=userdata.last_axis(3);
                end
                if userdata.shade_y(2)>userdata.last_axis(4)
                    userdata.shade_y(2)=userdata.last_axis(4);
                end
            end
            userdata.mouse_state=0;
            if userdata.shade_x(1)>userdata.shade_x(2)
                userdata.shade_x=userdata.shade_x([2,1]);
            end
            if userdata.shade_y(1)>userdata.shade_y(2)
                userdata.shade_y=userdata.shade_y([2,1]);
            end
            Fig_shade_Update();
            set(handles.interval1_edit_x,'String',num2str(userdata.shade_x(1)));
            set(handles.interval2_edit_x,'String',num2str(userdata.shade_x(2)));
            set(handles.interval1_edit_y,'String',num2str(userdata.shade_y(1)));
            set(handles.interval2_edit_y,'String',num2str(userdata.shade_y(2)));
        end
    end
    function Fig1_SizeChangedFcn(~, ~)
        userdata.fig1_pos=get(handles.fig1,'Position');
        p_edit=get(handles.panel_edit,'Position');
        if userdata.is_split==1
            p_edit(3)=userdata.fig1_pos(3);
        else
            p_edit(3)=350;
            if userdata.fig1_pos(3)-365>0
                set(handles.panel_fig,'Units','Pixels');
                p_fig=[365,1,userdata.fig1_pos(3)-365,userdata.fig1_pos(4)];
                set(handles.panel_fig,'Position',p_fig);
                Fig2_SizeChangedFcn;
                set(handles.panel_fig,'visible','on');
            else
                set(handles.panel_fig,'visible','off');
            end
        end
        p_edit(4)=userdata.fig1_pos(4);
        set(handles.panel_edit,'Position',p_edit);
    end
    function Fig2_SizeChangedFcn(~, ~)
        set(handles.panel_fig,'Units','Pixels');
        userdata.fig_pos=get(handles.panel_fig,'Position');
        set(handles.panel_fig,'Units','normalized');
        fig_width=userdata.fig_pos(3);
        if userdata.is_topo
            ax_num=min(length(userdata.selected_datasets)*length(userdata.selected_epochs),4);
            topo_length=min((fig_width-200)/ax_num,100);
            for ax_idx=1:ax_num
                set(handles.axes_topo(ax_idx),'Position',...
                    [(ax_idx-1)*fig_width/ax_num,...
                    userdata.fig_pos(4)-topo_length-30,...
                    (fig_width-20)/ax_num,topo_length]);
            end
            set(handles.colorbar_topo,'Position',...
                [fig_width-35,userdata.fig_pos(4)-topo_length-30,10,topo_length+10]);
            fig_height=userdata.fig_pos(4)-topo_length-30;
        elseif userdata.is_headplot
            ax_num=min(length(userdata.selected_datasets)*length(userdata.selected_epochs),4);
            headplot_length=min((fig_width-200)/ax_num,100);
            for ax_idx=1:ax_num
                set(handles.axes_headplot(ax_idx),'Position',...
                    [(ax_idx-1)*fig_width/ax_num,...
                    userdata.fig_pos(4)-headplot_length-30,...
                    (fig_width-20)/ax_num,headplot_length]);
            end
            set(handles.colorbar_headplot,'Position',...
                [fig_width-35,userdata.fig_pos(4)-headplot_length-30,10,headplot_length+10]);
            fig_height=userdata.fig_pos(4)-headplot_length-30;
        else
            fig_height=userdata.fig_pos(4);
        end
        horz_margin=20;
        vert_margin=20;
        width=max((fig_width)/userdata.num_cols,horz_margin*2+10);
        height=max((fig_height)/userdata.num_rows,vert_margin*2+10);
        for col_pos=1:userdata.num_cols
            for row_pos=1:userdata.num_rows
                x_pos=horz_margin+width*(col_pos-1)+horz_margin/2;
                y_pos=fig_height+vert_margin-height*row_pos+vert_margin/2;
                set(handles.axes((col_pos-1)*userdata.num_rows+row_pos),...
                    'position',[x_pos,y_pos,width-horz_margin*2,height-vert_margin*2]);
            end
        end
        Fig_cursor_Update();
    end
    function Fig_axis_Changed(~, event)
        if strcmp(get(event.Axes,'Tag'),'image')
            userdata.last_axis(1:2) = get(event.Axes,'XLim');
            userdata.last_axis(3:4) = get(event.Axes,'YLim');
            set(handles.xaxis1_edit, 'String', num2str(userdata.last_axis(1)));
            set(handles.xaxis2_edit, 'String', num2str(userdata.last_axis(2)));
            set(handles.yaxis1_edit, 'String', num2str(userdata.last_axis(3)));
            set(handles.yaxis2_edit, 'String', num2str(userdata.last_axis(4)));
            set(handles.axes,'XLim',userdata.last_axis(1:2));
            set(handles.axes,'YLim',userdata.last_axis(3:4));
            if userdata.is_shade
                Fig_shade_Update();
            end
            if ~isempty(handles.axes_topo)
                for k=1:length(handles.axes_topo)
                    caxis(handles.axes_topo(k),userdata.last_axis(3:4));
                end
            end
            if ~isempty(handles.axes_headplot)
                for k=1:length(handles.axes_headplot)
                    caxis(handles.axes_headplot(k),userdata.last_axis(3:4));
                end
            end
            userdata.auto_x=0;set(handles.xaxis_auto_checkbox,'Value',userdata.auto_x);
            userdata.auto_y=0;set(handles.yaxis_auto_checkbox,'Value',userdata.auto_y);
        else
            set(event.Axes,'XLim',[-0.55,0.55]);
            set(event.Axes,'YLim',[-0.5,0.6]);
        end
    end
    function Fig_cursor_Update()
        if(userdata.is_cursor)
            set(handles.cursor_x,'XData',[userdata.cursor_point(1),userdata.cursor_point(1)]);
            set(handles.cursor_x,'YData',[userdata.last_axis(3),userdata.last_axis(4)]);
            set(handles.cursor_y,'YData',[userdata.cursor_point(2),userdata.cursor_point(2)]);
            set(handles.cursor_y,'XData',[userdata.last_axis(1),userdata.last_axis(2)]);
            set(handles.cursor_text,'Position',userdata.cursor_point);
            
            for dataset_index=1:length(userdata.selected_datasets)
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                [index_pos,z_pos]=Get_iz_pos(header);
                for epoch_index=1:length(userdata.selected_epochs)
                    for channel_index=1:length(userdata.selected_channels)
                        switch(userdata.graph_style(1))
                            case 1
                                row_pos=dataset_index;
                            case 2
                                row_pos=epoch_index;
                            case 3
                                row_pos=channel_index;
                        end
                        switch(userdata.graph_style(2))
                            case 1
                                col_pos=dataset_index;
                            case 2
                                col_pos=epoch_index;
                            case 3
                                col_pos=channel_index;
                        end
                        ax_idx=(col_pos-1)*userdata.num_rows+row_pos;
                        dataset_pos=userdata.selected_datasets(dataset_index);
                        epoch_pos=userdata.selected_epochs(epoch_index);
                        channel_pos=userdata.channel_index(dataset_pos,userdata.selected_channels(channel_index));
                        
                        
                        x_start=datasets_header(dataset_pos).header.xstart;
                        x_step=datasets_header(dataset_pos).header.xstep;
                        x=(0:size(datasets_data(dataset_pos).data,6)-1)*x_step+x_start;
                        [x_a,x_idx]=(min(abs(userdata.cursor_point(1)-x)));
                        if x_a>x_step
                            set(handles.cursor_text(ax_idx),'string',' ');
                            continue;
                        end
                        
                        y_start=datasets_header(dataset_pos).header.ystart;
                        y_step=datasets_header(dataset_pos).header.ystep;
                        y=(0:size(datasets_data(dataset_pos).data,5)-1)*y_step+y_start;
                        [y_a,y_idx]=(min(abs(userdata.cursor_point(2)-y)));
                        if y_a>y_step
                            set(handles.cursor_text(ax_idx),'string',' ');
                            continue;
                        end
                        C=squeeze(datasets_data(dataset_pos).data(epoch_pos,channel_pos,index_pos,z_pos,y_idx,x_idx));
                        set(handles.cursor_text(ax_idx),'string',[' ',num2str(C)]);
                    end
                end
            end
        end
    end
    function Fig_shade_Update()
        set(handles.shade,'XData',[userdata.shade_x(1),userdata.shade_x(2),userdata.shade_x(2),userdata.shade_x(1)]);
        set(handles.shade,'YData',[userdata.shade_y(1),userdata.shade_y(1),userdata.shade_y(2),userdata.shade_y(2)]);
    end
    function Fig_topo_Update()
        if userdata.is_topo
            ax_num=min(length(userdata.selected_datasets)*length(userdata.selected_epochs),4);
            ax_idx=0;
            [xq,yq] = meshgrid(linspace(-0.5,0.5,67),linspace(-0.5,0.5,67));
            for dataset_index=1:length(userdata.selected_datasets)
                if(ax_idx>ax_num)
                    break;
                end
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                t_x=(0:header.datasize(6)-1)*header.xstep+header.xstart;
                t_y=(0:header.datasize(5)-1)*header.ystep+header.ystart;
                chan_used=find([header.chanlocs.topo_enabled]==1);
                if isempty(chan_used)
                    vq=nan(67,67);
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        if(ax_idx>ax_num)
                            break;
                        end
                        set( handles.surface_topo(ax_idx),'CData',vq);
                    end
                else
                    chanlocs=header.chanlocs(chan_used);
                    [y,x]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
                    [index_pos,z_pos]=Get_iz_pos(header);
                    [~,x_pos]=min(abs(t_x-userdata.cursor_point(1)));
                    [~,y_pos]=min(abs(t_y-userdata.cursor_point(2)));
                    data=squeeze(datasets_data(userdata.selected_datasets(dataset_index)).data...
                        (:,chan_used,index_pos,z_pos,y_pos,x_pos));
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        if(ax_idx>ax_num)
                            break;
                        end
                        vq = griddata(x,y,data(userdata.selected_epochs(epoch_index),:),xq,yq,'cubic');
                        set( handles.surface_topo(ax_idx),'CData',vq);
                    end
                end
            end
        end
    end
    function Fig_topo_Popup(~,~)
        if strcmp(get(gcf,'SelectionType'),'open')
            fig_temp=figure();
            [xq,yq] = meshgrid(linspace(-0.5,0.5,267),linspace(-0.5,0.5,267));
            delta = (xq(2)-xq(1))/2;
            ax_num=length(userdata.selected_datasets)*length(userdata.selected_epochs);
            row_num=length(userdata.selected_datasets);
            col_num=length(userdata.selected_epochs);
            if(col_num>7)
                col_num=7;
                row_num=ceil(ax_num/7);
            end
            for ax_idx=1:ax_num
                axes_topo(ax_idx)=subplot(row_num,col_num,ax_idx);
                colormap(axes_topo(ax_idx),userdata.color_style);
                set(axes_topo(ax_idx),'Xlim',[-0.55,0.55]);
                set(axes_topo(ax_idx),'Ylim',[-0.5,0.6]);
                caxis(axes_topo(ax_idx),userdata.last_axis(5:6));
                hold(axes_topo(ax_idx),'on');
                axis(axes_topo(ax_idx),'square');
                surface_topo(ax_idx)=surface(xq-delta,yq-delta,zeros(size(xq)),xq,...
                    'EdgeColor','none','FaceColor','flat','parent',axes_topo(ax_idx));
                headx = 0.5*[sin(linspace(0,2*pi,100)),NaN,sin(-2*pi*10/360),0,sin(2*pi*10/360),NaN,...
                    0.1*cos(2*pi/360*linspace(80,360-80,100))-1,NaN,...
                    -0.1*cos(2*pi/360*linspace(80,360-80,100))+1];
                heady = 0.5*[cos(linspace(0,2*pi,100)),NaN,cos(-2*pi*10/360),1.1,cos(2*pi*10/360),NaN,...
                    0.2*sin(2*pi/360*linspace(80,360-80,100)),NaN,0.2*sin(2*pi/360*linspace(80,360-80,100))];
                line_topo(ax_idx)=line(headx,heady,'Color',[0,0,0],'Linewidth',2,'parent',axes_topo(ax_idx));
                dot_topo(ax_idx)=line(headx,heady,'Color',[0,0,0],'Linestyle','none','Marker','.','Markersize',8,'parent',axes_topo(ax_idx));
            end
            colorbar_topo=colorbar;
            p=get(fig_temp,'position');
            set(colorbar_topo,'units','pixels');
            set(colorbar_topo,'position',[p(3)-40,10,10,p(4)-20]);
            set(colorbar_topo,'units','normalized');
            set(axes_topo,'Visible','off');
            ax_idx=0;
            for dataset_index=1:length(userdata.selected_datasets)
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                chan_used=find([header.chanlocs.topo_enabled]==1);
                if isempty(chan_used)
                    vq=nan(267,267);
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        set( surface_topo(ax_idx),'CData',vq);
                        str=[char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']'];
                        title_topo(ax_idx)=title(axes_topo(ax_idx),str,'Interpreter','none');
                    end
                else
                    t_x=(0:header.datasize(6)-1)*header.xstep+header.xstart;
                    t_y=(0:header.datasize(5)-1)*header.ystep+header.ystart;
                    chanlocs=header.chanlocs(chan_used);
                    [y,x]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
                    [index_pos,z_pos]=Get_iz_pos(header);
                    [~,x_pos]=min(abs(t_x-userdata.cursor_point(1)));
                    [~,y_pos]=min(abs(t_y-userdata.cursor_point(2)));
                    data=squeeze(datasets_data(userdata.selected_datasets(dataset_index)).data...
                        (:,chan_used,index_pos,z_pos,y_pos,x_pos));
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        vq = griddata(x,y,data(userdata.selected_epochs(epoch_index),:),xq,yq,'cubic');
                        set( surface_topo(ax_idx),'CData',vq);
                        set( dot_topo(ax_idx),'XData',x);
                        set( dot_topo(ax_idx),'YData',y);
                        str=[char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']'];
                        title_topo(ax_idx)=title(axes_topo(ax_idx),str,'Interpreter','none');
                    end
                end
            end
            set(title_topo,'Visible','on');
        end
    end
    function Fig_headplot_Update(~,~)
        if userdata.is_headplot
            ax_num=min(length(userdata.selected_datasets)*length(userdata.selected_epochs),4);
            ax_idx=0;
            for dataset_index=1:length(userdata.selected_datasets)
                if(ax_idx>ax_num)
                    break;
                end
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                t_x=(0:header.datasize(6)-1)*header.xstep+header.xstart;
                t_y=(0:header.datasize(5)-1)*header.ystep+header.ystart;
                if isempty(header.spl.indices)
                    P=zeros(length(userdata.POS),1);
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        if(ax_idx>ax_num)
                            break;
                        end
                        set(handles.surface_headplot(ax_idx),'FaceVertexCdata',P);
                    end
                else
                    [index_pos,z_pos]=Get_iz_pos(header);
                    [~,x_pos]=min(abs(t_x-userdata.cursor_point(1)));
                    [~,y_pos]=min(abs(t_y-userdata.cursor_point(2)));
                    data=squeeze(datasets_data(userdata.selected_datasets(dataset_index)).data...
                        (:,header.spl.indices,index_pos,z_pos,y_pos,x_pos));
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        if(ax_idx>ax_num)
                            break;
                        end
                        values=data(userdata.selected_epochs(epoch_index),:);
                        meanval = mean(values);
                        P=header.spl.GG*[values(:)- meanval;0]+meanval;
                        set( handles.surface_headplot(ax_idx),'FaceVertexCdata',P);
                    end
                end
            end
        end
    end
    function Fig_headplot_Popup(~,~)
        if strcmp(get(gcf,'SelectionType'),'open')
            fig_temp=figure();
            ax_num=length(userdata.selected_datasets)*length(userdata.selected_epochs);
            row_num=length(userdata.selected_datasets);
            col_num=length(userdata.selected_epochs);
            if(col_num>7)
                col_num=7;
                row_num=ceil(ax_num/7);
            end
            for ax_idx=1:ax_num
                axes_headplot(ax_idx)=subplot(row_num,col_num,ax_idx);
                colormap(axes_headplot(ax_idx),userdata.color_style);
                caxis(axes_headplot(ax_idx),userdata.last_axis(5:6));
                axis(axes_headplot(ax_idx),'image');
                title_headplot(ax_idx)=title(axes_headplot(ax_idx),'hello',...
                    'Interpreter','none');
                light('Position',[-125  125  80],'Style','infinite')
                light('Position',[125  125  80],'Style','infinite')
                light('Position',[125 -125 80],'Style','infinite')
                light('Position',[-125 -125 80],'Style','infinite')
                lighting phong;
                
                P=linspace(1,userdata.headplot_colornum,length(userdata.POS))';
                surface_headplot(ax_idx) = ...
                    patch('Vertices',userdata.POS,'Faces',userdata.TRI,...
                    'FaceVertexCdata',P,'FaceColor','interp', ...
                    'EdgeColor','none');
                set(surface_headplot(ax_idx),'DiffuseStrength',.6,...
                    'SpecularStrength',0,'AmbientStrength',.3,...
                    'SpecularExponent',5,'vertexnormals', userdata.NORM);
                axis(axes_headplot(ax_idx),[-125 125 -125 125 -125 125]);
                view([0 90]);
                dot_headplot(ax_idx)=line(1,1,1,'Color',[0,0,0],...
                    'Linestyle','none','Marker','.','Markersize',ceil(10/sqrt(ax_num)),...
                    'parent',axes_headplot(ax_idx));
            end
            colorbar_headplot=colorbar;
            p=get(fig_temp,'position');
            set(colorbar_headplot,'units','pixels');
            set(colorbar_headplot,'position',[p(3)-40,10,10,p(4)-20]);
            set(colorbar_headplot,'units','normalized');
            set(axes_headplot,'Visible','off');
            
            ax_idx=0;
            for dataset_index=1:length(userdata.selected_datasets)
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                t_x=(0:header.datasize(6)-1)*header.xstep+header.xstart;
                t_y=(0:header.datasize(5)-1)*header.ystep+header.ystart;
                if isempty(header.spl.indices)
                    P=zeros(length(userdata.POS),1);
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        if(ax_idx>ax_num)
                            break;
                        end
                        set( surface_headplot(ax_idx),'FaceVertexCdata',P);
                    end
                else
                    [index_pos,z_pos]=Get_iz_pos(header);
                    [~,x_pos]=min(abs(t_x-userdata.cursor_point(1)));
                    [~,y_pos]=min(abs(t_y-userdata.cursor_point(2)));
                    data=squeeze(datasets_data(userdata.selected_datasets(dataset_index)).data...
                        (:,header.spl.indices,index_pos,z_pos,y_pos,x_pos));
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        set( dot_headplot(ax_idx),'XData',header.spl.newElect(:,1));
                        set( dot_headplot(ax_idx),'YData',header.spl.newElect(:,2));
                        set( dot_headplot(ax_idx),'ZData',header.spl.newElect(:,3));
                        str=[char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']'];
                        title_headplot(ax_idx)=title(axes_headplot(ax_idx),str,'Interpreter','none');
                        values=data(userdata.selected_epochs(epoch_index),:);
                        meanval = mean(values); values = values - meanval;
                        P=header.spl.GG * [values(:);0]+meanval;
                        set( surface_headplot(ax_idx),'FaceVertexCdata',P);
                    end
                end
            end
            set(title_headplot,'Visible','on');
        end
    end
    function Set_position(obj,position)
        set(obj,'Units','pixels');
        set(obj,'Position',position);
        set(obj,'Units','normalized');
    end
    function [index_pos,z_pos]=Get_iz_pos(header)
        if strcmp(get(handles.index_popup,'Visible'),'off')
            index_pos=1;
        else
            index_pos=get(handles.index_popup,'Value');
        end
        if strcmp(get(handles.z_edit,'Visible'),'off')
            z_pos=1;
        else
            z=str2num(get(handles.z_edit,'String'));
            z_pos=round((z-header.zstart)/header.zstep)+1;
            if z_pos<1
                z_pos=1;
            end;
            if z_pos>header.datasize(4)
                z_pos=header.datasize(4);
            end
            set(handles.z_edit,'String',num2str((z_pos-1)*header.zstep+header.zstart));
        end
    end
    function Edit_dataset_Add(~, ~)
        [FileName,PathName] = GLW_getfile();
        %[FileName,PathName] = uigetfile({'*.lw6','Select the lw6 file'},'MultiSelect','on');
        userdata.datasets_path=PathName;
        if PathName~=0;
            FileName=cellstr(FileName);
            for k=1:length(FileName)
                userdata.datasets_filename{end+1}=FileName{k}(1:end-4);
                [datasets_header(end+1).header, datasets_data(end+1).data]=CLW_load(fullfile(PathName,FileName{k}));
                chan_used=find([datasets_header(end).header.chanlocs.topo_enabled]==1, 1);
                if isempty(chan_used)
                    datasets_header(end).header=CLW_elec_autoload(datasets_header(end).header);
                end
                datasets_header(end).header=CLW_make_spl(datasets_header(end).header);
            end
            set(handles.dataset_listbox,'String',userdata.datasets_filename);
        end
    end
    function Edit_dataset_Del(~, ~)
        index=get(handles.dataset_listbox,'value');
        if length(index)==length(datasets_header)
            CreateStruct.Interpreter = 'none';
            CreateStruct.WindowStyle = 'modal';
            msgbox('Unable to delete all datasets','Error','error',CreateStruct);
            return;
        else
            index_remain=setdiff(1:length(datasets_header),index);
            userdata.datasets_filename={userdata.datasets_filename{index_remain}};
            datasets_header=datasets_header(index_remain);
            datasets_data=datasets_data(index_remain);
            set(handles.dataset_listbox,'String',userdata.datasets_filename);
            set(handles.dataset_listbox,'value',1);
            userdata.selected_datasets=2;
            GLW_view_UpdataFcn();
        end
    end
    function Edit_dataset_Up(~, ~)
        index=get(handles.dataset_listbox,'value');
        if index(1)==1
            return;
        else
            index_unselected=setdiff(1:length(datasets_header),index);
            index_order=zeros(1,length(datasets_header));
            index_order(index-1)=index;
            for k=1:length(index_order)
                if index_order(k)==0
                    index_order(k)=index_unselected(1);
                    index_unselected=index_unselected(2:end);
                end
            end
            userdata.datasets_filename={userdata.datasets_filename{index_order}};
            datasets_header=datasets_header(index_order);
            datasets_data=datasets_data(index_order);
            set(handles.dataset_listbox,'String',userdata.datasets_filename);
            set(handles.dataset_listbox,'value',index-1);
            userdata.selected_datasets=index-1;
        end
    end
    function Edit_dataset_Down(~, ~)
        index=get(handles.dataset_listbox,'value');
        if index(end)==length(datasets_header)
            return;
        else
            index_unselected=setdiff(1:length(datasets_header),index);
            index_order=zeros(1,length(datasets_header));
            index_order(index+1)=index;
            for k=1:length(index_order)
                if index_order(k)==0
                    index_order(k)=index_unselected(1);
                    index_unselected=index_unselected(2:end);
                end
            end
            userdata.datasets_filename={userdata.datasets_filename{index_order}};
            datasets_header=datasets_header(index_order);
            datasets_data=datasets_data(index_order);
            set(handles.dataset_listbox,'String',userdata.datasets_filename);
            set(handles.dataset_listbox,'value',index+1);
            userdata.selected_datasets=index+1;
        end
    end
    function Fig1_CloseReq_Callback(~, ~)
        closereq;
        if ishandle(handles.fig2)
            close(handles.fig2);
        end
    end
    function Fig2_CloseReq_Callback(~, ~)
        closereq;
        if ishandle(handles.fig1)
            close(handles.fig1);
        end
    end
end