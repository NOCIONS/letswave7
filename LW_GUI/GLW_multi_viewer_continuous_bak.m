function GLW_multi_viewer_continuous(inputfiles)
handles=[];
userdata=[];
header=[];
data=[];
event_code=[];
event_table=[];
GLW_view_OpeningFcn;



%% init_parameter()
    function init_parameter()
        temp=get(0,'Screensize');
        userdata.fig_pos=[(temp(3)-1350)/2,(temp(4)-680)/2-50,1350,680];
        userdata.yscale_lock=1;
        userdata.is_filter=0;
        userdata.is_filter_low=1;
        userdata.is_filter_high=1;
        userdata.is_filter_notch=0;
        userdata.filter_high=1;
        userdata.filter_low=30;
        userdata.filter_notch=1;
        userdata.filter_order=2;
        userdata.is_category_selected=1;
        userdata.is_mouse_down=0;
        userdata.slide_dist=0;
        userdata.is_overwrited=1;
        userdata.prefix='ep_edit';
        userdata.N=0;
        userdata.t=0;
        userdata.Fs=0;
        userdata.x_range=0;
        userdata.y_range=0;
        userdata.color=[0,0.447,0.741;
            0.85,0.325,0.098;
            0.929,0.694,0.125;
            0.494,0.184,0.556;
            0.466,0.674,0.188;
            0.301,0.745,0.933;
            0.635,0.078,0.1840];
        userdata.color_event=[];
        userdata.y=[];
        
        [p, n, ~]=fileparts(fullfile(inputfiles.file_path,inputfiles.file_str{1}));
        userdata.filename=n;
        [header, data]=CLW_load(fullfile(p,n));
        
        userdata.N=header.datasize(6);
        userdata.t=header.xstart+(0:userdata.N-1)*header.xstep;
        userdata.Fs=1/header.xstep;
        data=permute(data(:,:,:,1,1,:),[6,2,1,3,4,5]);%X*ch*ep*index
        make_event(header.events);
    end
    function make_event(events)
        N=size(events,2);
        event_code=unique({events.code});
        event_table=zeros(3,N);
        for k=1:length(event_code)
            event_table(1,strcmp({events.code},event_code{k}))=k;
        end
        event_table(2:3,:)=[events.latency;events.epoch;];
    end

%% init_panel_left
    function init_panel_left()
        %% epoch
        handles.epoch_text=uicontrol(handles.panel_edit,'style','text','String','Epochs:');
        set(handles.epoch_text,'Units','pixels');
        set(handles.epoch_text,'HorizontalAlignment','left');
        set(handles.epoch_text,'Position',[5,650,60,20]);
        set(handles.epoch_text,'Units','normalized');
        handles.epoch_listbox=uicontrol(handles.panel_edit,'style','listbox','Callback',@GLW_view_UpdataFcn);
        set(handles.epoch_listbox,'Units','pixels');
        set(handles.epoch_listbox,'Position',[5,170,55,485]);
        set(handles.epoch_listbox,'Units','normalized');
        st=cell(header.datasize(1),1);
        for k=1:header.datasize(1)
            st{k}=num2str(k);
        end
        set(handles.epoch_listbox,'String',st);
        set(handles.epoch_listbox,'value',1);
        
        %% channel
        handles.channel_text=uicontrol(handles.panel_edit,'style','text','String','Channels:');
        set(handles.channel_text,'Units','pixels');
        set(handles.channel_text,'HorizontalAlignment','left');
        set(handles.channel_text,'Position',[70,650,60,20]);
        set(handles.channel_text,'Units','normalized');
        
        handles.channel_listbox=uicontrol(handles.panel_edit,'style','listbox','Callback',@GLW_view_UpdataFcn);
        set(handles.channel_listbox,'Min',1);
        set(handles.channel_listbox,'Max',3);
        set(handles.channel_listbox,'Units','pixels');
        set(handles.channel_listbox,'Position',[70,170,85,485]);
        set(handles.channel_listbox,'Units','normalized');
        set(handles.channel_listbox,'String',{header.chanlocs.labels});
        set(handles.channel_listbox,'value',1:header.datasize(2));
       
        %% filter_panel
         handles.filter_panel=uipanel(handles.panel_edit);
        set(handles.filter_panel,'Title','Online Butterworth Filter');
        set(handles.filter_panel,'Units','pixels');
        set(handles.filter_panel,'Position',[5,5,150,155]);
        set(handles.filter_panel,'Units','normalized');
        
        handles.filter_checkbox=uicontrol(handles.filter_panel,'style','checkbox');
        set(handles.filter_checkbox,'String','Enable');
        set(handles.filter_checkbox,'Units','pixels');
        set(handles.filter_checkbox,'Position',[5,120,105,20]);
        set(handles.filter_checkbox,'Units','normalized');
        set(handles.filter_checkbox,'Value',userdata.is_filter);
        set(handles.filter_checkbox,'Callback',@edit_filter_Changed);
        
        handles.filter_lowpass_checkbox=uicontrol(handles.filter_panel,'style','checkbox');
        set(handles.filter_lowpass_checkbox,'String','Low Pass');
        set(handles.filter_lowpass_checkbox,'Units','pixels');
        set(handles.filter_lowpass_checkbox,'Position',[5,95,80,20]);
        set(handles.filter_lowpass_checkbox,'Units','normalized');
        set(handles.filter_lowpass_checkbox,'Value',userdata.is_filter_low);
        set(handles.filter_lowpass_checkbox,'Callback',@edit_filter_Changed);
        handles.filter_lowpass_edit=uicontrol(handles.filter_panel,'style','edit');
        set(handles.filter_lowpass_edit,'String',num2str(userdata.filter_low));
        set(handles.filter_lowpass_edit,'Units','pixels');
        set(handles.filter_lowpass_edit,'Position',[80,95,50,20]);
        set(handles.filter_lowpass_edit,'Units','normalized');
        set(handles.filter_lowpass_edit,'Callback',@edit_filter_Changed);
        
        handles.filter_highpass_checkbox=uicontrol(handles.filter_panel,'style','checkbox');
        set(handles.filter_highpass_checkbox,'String','High Pass');
        set(handles.filter_highpass_checkbox,'Units','pixels');
        set(handles.filter_highpass_checkbox,'Position',[5,67,80,20]);
        set(handles.filter_highpass_checkbox,'Units','normalized');
        set(handles.filter_highpass_checkbox,'Value',userdata.is_filter_high);
        set(handles.filter_highpass_checkbox,'Callback',@edit_filter_Changed);
        handles.filter_highpass_edit=uicontrol(handles.filter_panel,'style','edit');
        set(handles.filter_highpass_edit,'String',num2str(userdata.filter_high));
        set(handles.filter_highpass_edit,'Units','pixels');
        set(handles.filter_highpass_edit,'Position',[80,67,50,20]);
        set(handles.filter_highpass_edit,'Units','normalized');
        set(handles.filter_highpass_edit,'Callback',@edit_filter_Changed);
        
        handles.filter_notch_checkbox=uicontrol(handles.filter_panel,'style','checkbox');
        set(handles.filter_notch_checkbox,'String','Notch');
        set(handles.filter_notch_checkbox,'Units','pixels');
        set(handles.filter_notch_checkbox,'Position',[5,35,80,20]);
        set(handles.filter_notch_checkbox,'Units','normalized');
        set(handles.filter_notch_checkbox,'Value',userdata.is_filter_notch);
        set(handles.filter_notch_checkbox,'Callback',@edit_filter_Changed);
        handles.filter_notch_popup=uicontrol(handles.filter_panel,'style','popup','String',{'50','60'});
        set(handles.filter_notch_popup,'Value',userdata.filter_notch);
        set(handles.filter_notch_popup,'Units','pixels');
        set(handles.filter_notch_popup,'Position',[80,35,70,25]);
        set(handles.filter_notch_popup,'Units','normalized');
        set(handles.filter_notch_popup,'Callback',@edit_filter_Changed);
        
        handles.filter_order_text=uicontrol(handles.filter_panel,'style','text');
        set(handles.filter_order_text,'String','order:');
        set(handles.filter_order_text,'Units','pixels');
        set(handles.filter_order_text,'Position',[0,5,80,20]);
        set(handles.filter_order_text,'Units','normalized');
        set(handles.filter_order_text,'Callback',@edit_filter_Changed);
        handles.filter_order_popup=uicontrol(handles.filter_panel,...
            'style','popup','String',{'1','2','3','4','5','6','7','8','9','10'});
        set(handles.filter_order_popup,'Units','pixels');
        set(handles.filter_order_popup,'Position',[80,5,70,25]);
        set(handles.filter_order_popup,'Units','normalized');
        set(handles.filter_order_popup,'value',userdata.filter_order);
        set(handles.filter_order_popup,'Callback',@edit_filter_Changed);
        
        set(handles.filter_lowpass_checkbox,'Enable','off');
        set(handles.filter_lowpass_edit,'Enable','off');
        set(handles.filter_highpass_checkbox,'Enable','off');
        set(handles.filter_highpass_edit,'Enable','off');
        set(handles.filter_notch_checkbox,'Enable','off');
        set(handles.filter_notch_popup,'Enable','off');
        set(handles.filter_order_text,'Enable','off');
        set(handles.filter_order_popup,'Enable','off');
    end

%% init_panel_mid
    function init_panel_mid() 
        %% range_panel
        handles.range_panel=uipanel(handles.fig);
        set(handles.range_panel,'Units','pixels');
        set(handles.range_panel,'Position',[165,5,930,35]);
        set(handles.range_panel,'Units','normalized');
        
        
        handles.xrange_text=uicontrol(handles.range_panel,'style','text','String','X-range:');
        set(handles.xrange_text,'Units','pixels');
        set(handles.xrange_text,'HorizontalAlignment','left');
        set(handles.xrange_text,'Position',[15,2,60,20]);
        set(handles.xrange_text,'Units','normalized');
        
        handles.xpre_btn=uicontrol(handles.range_panel,'style','pushbutton','String','<<');
        set(handles.xpre_btn,'Units','pixels');
        set(handles.xpre_btn,'Position',[65,6,18,18]);
        set(handles.xpre_btn,'Units','normalized');
        
        handles.x1_edit=uicontrol(handles.range_panel,'style','edit');
        set(handles.x1_edit,'Units','pixels');
        set(handles.x1_edit,'Position',[88,5,65,20]);
        set(handles.x1_edit,'Units','normalized');
        
        handles.xrange1_text=uicontrol(handles.range_panel,'style','text','String','-');
        set(handles.xrange1_text,'Units','pixels');
        set(handles.xrange1_text,'HorizontalAlignment','left');
        set(handles.xrange1_text,'Position',[154,2,60,20]);
        set(handles.xrange1_text,'Units','normalized');
        
        handles.x2_edit=uicontrol(handles.range_panel,'style','edit');
        set(handles.x2_edit,'Units','pixels');
        set(handles.x2_edit,'Position',[160,5,65,20]);
        set(handles.x2_edit,'Units','normalized');
        
        handles.xnext_btn=uicontrol(handles.range_panel,'style','pushbutton','String','>>');
        set(handles.xnext_btn,'Units','pixels');
        set(handles.xnext_btn,'Position',[230,6,18,18]);
        set(handles.xnext_btn,'Units','normalized');
        
        handles.xscale_text=uicontrol(handles.range_panel,'style','text','String','X-scale:');
        set(handles.xscale_text,'Units','pixels');
        set(handles.xscale_text,'HorizontalAlignment','left');
        set(handles.xscale_text,'Position',[290,2,60,20]);
        set(handles.xscale_text,'Units','normalized');
        
        handles.xscale_small_btn=uicontrol(handles.range_panel,'style','pushbutton','String','-');
        set(handles.xscale_small_btn,'Units','pixels');
        set(handles.xscale_small_btn,'Position',[330,6,18,18]);
        set(handles.xscale_small_btn,'Units','normalized');
        
        handles.xscale_edit=uicontrol(handles.range_panel,'style','edit','Callback',@edit_xscale_Changed);
        set(handles.xscale_edit,'Units','pixels');
        set(handles.xscale_edit,'Position',[350,5,100,20]);
        set(handles.xscale_edit,'Units','normalized');
        
        handles.xscale_large_btn=uicontrol(handles.range_panel,'style','pushbutton','String','+');
        set(handles.xscale_large_btn,'Units','pixels');
        set(handles.xscale_large_btn,'Position',[452,6,18,18]);
        set(handles.xscale_large_btn,'Units','normalized');
        
        handles.y_text=uicontrol(handles.range_panel,'style','text','String','Yscale:');
        set(handles.y_text,'Units','pixels');
        set(handles.y_text,'HorizontalAlignment','left');
        set(handles.y_text,'Position',[480,2,60,20]);
        set(handles.y_text,'Units','normalized');
        
        
        handles.yscale_small_btn=uicontrol(handles.range_panel,'style','pushbutton','String','-');
        set(handles.yscale_small_btn,'Units','pixels');
        set(handles.yscale_small_btn,'Position',[520,6,18,18]);
        set(handles.yscale_small_btn,'Units','normalized');
        
        handles.yscale_edit=uicontrol(handles.range_panel,'style','edit');
        set(handles.yscale_edit,'Units','pixels');
        set(handles.yscale_edit,'Position',[540,5,100,20]);
        set(handles.yscale_edit,'Units','normalized');
        
        handles.yscale_large_btn=uicontrol(handles.range_panel,'style','pushbutton','String','+');
        set(handles.yscale_large_btn,'Units','pixels');
        set(handles.yscale_large_btn,'Position',[642,6,18,18]);
        set(handles.yscale_large_btn,'Units','normalized');
        
        handles.y_auto_checkbox=uicontrol(handles.range_panel,'style','checkbox');
        set(handles.y_auto_checkbox,'String','auto');
        set(handles.y_auto_checkbox,'Units','pixels');
        set(handles.y_auto_checkbox,'Position',[670,5,60,20]);
        set(handles.y_auto_checkbox,'Units','normalized');
        set(handles.y_auto_checkbox,'Value',userdata.yscale_lock);
        
        
        handles.index_text=uicontrol(handles.range_panel,'style','text','String','Index:');
        set(handles.index_text,'Units','pixels');
        set(handles.index_text,'HorizontalAlignment','left');
        set(handles.index_text,'Position',[763,2,50,20]);
        set(handles.index_text,'Units','normalized');
        handles.index_popup=uicontrol(handles.range_panel,'style','popup','Callback',@GLW_view_UpdataFcn);
        set(handles.index_popup,'Units','pixels');
        set(handles.index_popup,'Position',[793,5,100,20]);
        set(handles.index_popup,'Units','normalized');
        
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
        
        %% x_range
        auto_x_range();
        set(handles.x1_edit,'string',num2str(userdata.t(1)));
        set(handles.x2_edit,'string',num2str(userdata.x_range+userdata.t(1)));
        set(handles.xscale_edit,'string',num2str(userdata.x_range));
        
        %% ax_fig
        handles.ax_fig=axes('Units','pixels','position',[170,100,880,557]);
        set(handles.ax_fig,'Units','normalized');
        set(handles.ax_fig,'yaxislocation','right');
        box on;grid on;
        for k=1:header.datasize(2)
            handles.line(k)=line(1,1,'Parent',handles.ax_fig);
        end
        set(handles.line,'LineWidth',1);
        set(handles.line(1:end),'Visible','off');
        set(handles.ax_fig,'xlim',userdata.t(1)+[0,userdata.x_range]);
        
        %% ax_event
        if length(event_code)<=64
            userdata.color_event=jet((length(event_code)-1)*10+1);
            userdata.color_event=userdata.color_event(1:10:end,:);
        else
            userdata.color_event=jet(length(event_code));
        end
        for k=1:length(event_code)
            idx_temp=find(event_table(1,:)==k);
            handles.line_event(k)=line(event_table(2,idx_temp),zeros(1,length(idx_temp)),'Parent',handles.ax_fig);
            set(handles.line_event(k),'marker','v','linestyle','none');
            set(handles.line_event(k),'MarkerEdgecolor',userdata.color_event(k,:));
            set(handles.line_event(k),'Markerfacecolor',userdata.color_event(k,:));
        end
        handles.legend_event=legend(handles.line_event,event_code,'location','northeast');
        GLW_view_UpdataFcn();
        
        %% ax_slide
        handles.ax_slide=axes('Units','pixels','position',[165,45,930,30]);
        set(handles.ax_slide,'Units','normalized');
        handles.line_slide=line(userdata.t([1,end]),[0,0],'Parent',handles.ax_slide);
        handles.rect_slide=rectangle('position',[userdata.t(1),-1,userdata.x_range,2],...
            'facecolor',[0,0,1],'Parent',handles.ax_slide);
        set(handles.ax_slide,'xlim',userdata.t([1,end]));
        set(handles.ax_slide,'ylim',[-5,5]);
        axis off;
        
        set(handles.rect_slide,'buttonDownFcn',@fig_BtnDown);
        set(handles.fig,'WindowButtonMotionFcn',@fig_BtnMotion);
        set(handles.fig,'WindowButtonUpFcn',@fig_BtnUp);
        set(handles.x1_edit,'callback',@x_range_chg);
        set(handles.x2_edit,'callback',@x_range_chg);
        set(handles.xpre_btn,'callback',@xpre_callback);
        set(handles.xnext_btn,'callback',@xnext_callback);
        set(handles.xscale_small_btn,'callback',@xscale_small_callback);
        set(handles.xscale_large_btn,'callback',@xscale_large_callback);
        set(handles.xscale_edit,'callback',@xscale_callback);
        set(handles.yscale_small_btn,'callback',@yscale_small_callback); 
        set(handles.yscale_large_btn,'callback',@yscale_large_callback); 
        set(handles.yscale_edit,'callback',@yscale_callback);
        set(handles.y_auto_checkbox,'callback',@y_auto_callback);
        
    end

%% GLW_view_UpdataFcn
    function GLW_view_UpdataFcn(~,~)
        ch_num=get(handles.channel_listbox,'value');
        ep_num=get(handles.epoch_listbox,'value');
        idx_num=get(handles.index_popup,'value');
        userdata.y=data(:,ch_num,ep_num,idx_num);
        userdata.y = detrend(userdata.y);  
        if userdata.is_filter
            userdata.y = [ones(100,1)*userdata.y(1,:);userdata.y;ones(100,1)*userdata.y(end,:)];
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
            userdata.y = userdata.y(101:end-100,:);
        end
        y_avg=(max(userdata.y,[],1)+min(userdata.y,[],1))/2;
        if get(handles.y_auto_checkbox,'value')
            auto_y_range();
            set(handles.yscale_edit,'string',num2str(userdata.y_range));
        end
        set(handles.ax_fig,'ylim',[-userdata.y_range*5,userdata.y_range*5]);
        set(handles.ax_fig,'ytick',linspace(-userdata.y_range*5,userdata.y_range*5,11));
        for k=1:length(event_code)
            idx_temp=find(event_table(1,:)==k & event_table(3,:)==ep_num);
            set(handles.line_event(k),'XData',event_table(2,idx_temp));
            set(handles.line_event(k),'YData',userdata.y_range*5*ones(1,length(idx_temp)));
        end
        
        set(handles.line(1:length(ch_num)),'Visible','on');
        set(handles.line(length(ch_num)+1:end),'Visible','off');
        set(handles.line(1:length(ch_num)),'XData',userdata.t);
        temp=linspace(-userdata.y_range*5,userdata.y_range*5,length(ch_num)*2+1);
        temp=temp(2:2:end);
        for k=1:length(ch_num)
            set(handles.line(k),'YData',userdata.y(:,k)-y_avg(k)+temp(k));
            set(handles.line(k),'color',userdata.color(mod(k-1,7)+1,:));
        end
    end

    function fig_BtnDown(~, ~)
        temp1 = get (handles.ax_slide, 'CurrentPoint');
        temp2 = get(handles.rect_slide,'position');
        userdata.slide_dist=temp2(1)-temp1(1,1);
        userdata.is_mouse_down=1;
    end
    function fig_BtnMotion(~, ~)
        if userdata.is_mouse_down
            temp1 = get (handles.ax_slide, 'CurrentPoint');
            temp2 = get(handles.rect_slide,'position');
            temp2(1)=userdata.slide_dist+temp1(1,1);
            if temp2(1)<userdata.t(1)
                temp2(1)=userdata.t(1);
            end
            if (temp2(1)+temp2(3))>userdata.t(end)
                temp2(1)=userdata.t(end)-temp2(3);
            end
            set(handles.ax_fig,'xlim',[temp2(1),temp2(1)+temp2(3)]);
            set(handles.x1_edit,'string',num2str(temp2(1)));
            set(handles.x2_edit,'string',num2str(temp2(1)+temp2(3)));
            set(handles.rect_slide,'position',temp2);
        end
    end
    function fig_BtnUp(~, ~)
        userdata.is_mouse_down=0;
    end
    function x_range_chg(~,~)
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
        userdata.x_range=x(2)-x(1);
        set(handles.ax_fig,'XLim',x);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        set(handles.xscale_edit,'String',num2str(x(2)-x(1)));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
    end
    function xpre_callback(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        x_scale = str2double(get(handles.xscale_edit, 'String'));
        if x(1)-x_scale<userdata.t(1)
            x=[userdata.t(1);userdata.t(1)+x_scale];
        else
            x=x-x_scale;
        end
        userdata.x_range=x_scale;
        set(handles.ax_fig,'XLim',x);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        %set(handles.xscale_edit,'String',num2str(x_scale));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
    end
    function xnext_callback(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        x_scale = str2double(get(handles.xscale_edit, 'String'));
        if x(2)+x_scale>userdata.t(end)
            x=[userdata.t(end)-x_scale;userdata.t(end)];
        else
            x=x+x_scale;
        end
        userdata.x_range=x_scale;
        set(handles.ax_fig,'XLim',x);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        %set(handles.xscale_edit,'String',num2str(x_scale));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
    end
    function xscale_small_callback(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        x_scale = str2double(get(handles.xscale_edit, 'String'));
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
        set(handles.ax_fig,'XLim',x);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        set(handles.xscale_edit,'String',num2str(x_scale));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
    end
    function xscale_large_callback(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        x_scale = str2double(get(handles.xscale_edit, 'String'));
        x_scale=x_scale*1.5;
        temp=10^floor(log10(x_scale)-1);
        x_scale=round(x_scale/temp)*temp;
        if x_scale>userdata.t(end)-userdata.t(1)
            x_scale=userdata.t(end)-userdata.t(1);
        end
        x(2)=x(1)+x_scale;
        if x(2)>userdata.t(end)
            x(2)=userdata.t(end);
            x(1)=userdata.t(end)-x_scale;
        end
        userdata.x_range=x_scale;
        set(handles.ax_fig,'XLim',x);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        set(handles.xscale_edit,'String',num2str(x_scale));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
    end
    function xscale_callback(~,~)
        x(1) = str2double(get(handles.x1_edit, 'String'));
        x(2) = str2double(get(handles.x2_edit, 'String'));
        x_scale = str2double(get(handles.xscale_edit, 'String'));
        if isnan(x_scale)
            temp=get(handles.rect_slide,'position');
            set(handles.x1_edit, 'String',num2str(temp(1)));
            set(handles.x2_edit, 'String',num2str(temp(1)+temp(3)));
            set(handles.xscale_edit,'string',num2str(userdata.x_range));
            return;
        end
        if x_scale<10/userdata.Fs
            x_scale=min(10/userdata.Fs,userdata.t(end)-userdata.t(1));
        end
        if x_scale>userdata.t(end)-userdata.t(1)
            x_scale=userdata.t(end)-userdata.t(1);
        end
        x(2)=x(1)+x_scale;
        if x(2)>userdata.t(end)
            x(2)=userdata.t(end);
            x(1)=userdata.t(end)-x_scale;
        end
        userdata.x_range=x_scale;
        set(handles.ax_fig,'XLim',x);
        set(handles.x1_edit, 'String',num2str(x(1)));
        set(handles.x2_edit, 'String',num2str(x(2)));
        set(handles.xscale_edit,'String',num2str(x_scale));
        set(handles.rect_slide,'position',[x(1),-1,x(2)-x(1),2]);
    end
    function yscale_small_callback(~,~)
        y_scale = str2double(get(handles.yscale_edit, 'String'));
        y_scale=y_scale/1.5;
        temp=10^floor(log10(y_scale)-1);
        userdata.y_range=round(y_scale/temp)*temp;
        set(handles.yscale_edit,'string',num2str(userdata.y_range));
        set(handles.y_auto_checkbox,'value',0);
        GLW_view_UpdataFcn();
    end
    function yscale_large_callback(~,~)
        y_scale = str2double(get(handles.yscale_edit, 'String'));
        y_scale=y_scale*1.5;
        temp=10^floor(log10(y_scale)-1);
        userdata.y_range=round(y_scale/temp)*temp;
        set(handles.yscale_edit,'string',num2str(userdata.y_range));
        set(handles.y_auto_checkbox,'value',0);
        GLW_view_UpdataFcn();
    end
    function yscale_callback(~,~)
        y_scale= str2double(get(handles.yscale_edit, 'String'));
        if isnumeric(y_scale) && y_scale>0
            userdata.y_range=y_scale;
            set(handles.y_auto_checkbox,'value',0);
            GLW_view_UpdataFcn();
        else
            set(handles.yscale_edit,'string',num2str(userdata.y_range));
        end
    end
    function y_auto_callback(~,~)
        y_auto=get(handles.y_auto_checkbox,'value');
        if y_auto==1
            GLW_view_UpdataFcn();
        end
    end
    function auto_x_range()
        userdata.x_range=10;
        if (userdata.x_range*userdata.Fs)>userdata.N
            userdata.x_range=userdata.N/userdata.Fs;
        end
    end
    function auto_y_range()
        ch_num=get(handles.channel_listbox,'value');
        y_max=max(max(userdata.y,[],1)-min(userdata.y,[],1));
        userdata.y_range=y_max*length(ch_num)/10;
        temp=10^floor(log10(userdata.y_range));
        userdata.y_range=ceil(userdata.y_range/temp)*temp;
    end
    function edit_filter_Changed(~,~)
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

%% init_panel_right
    function init_panel_right()
         %% event
        handles.event_panel=uipanel(handles.fig);
        set(handles.event_panel,'Title','Events:');
        set(handles.event_panel,'Units','pixels');
        set(handles.event_panel,'Position',[1100,3,250,675]);
        set(handles.event_panel,'Units','normalized');
        set(handles.event_panel,'SizeChangedFcn',@event_panel_SizeChangedFcn);
        
        d=cell(size(event_table,2),3);
        d(:,1)=event_code(event_table(1,:)');
        d(:,2)=num2cell(event_table(2,:));
        d(:,3)=num2cell(event_table(3,:));
        
        columnname = {'Code','latency','Epoch'};
        columnformat = {event_code,'numeric','numeric'};
        handles.event_table = uitable(handles.event_panel,'Data',d,...
            'ColumnName', columnname,'ColumnFormat', columnformat,...
            'ColumnWidth',{80,60,40},'ColumnEditable', [true true true]);
        set(handles.event_table,'Units','pixels');
        set(handles.event_table,'Position',[1,270,248,390]);
        set(handles.event_table,'Units','normalized');
        
        
        handles.select_checkbox=uicontrol(handles.event_panel,'style','checkbox');
        set(handles.select_checkbox,'String','Select all:');
        set(handles.select_checkbox,'Units','pixels');
        set(handles.select_checkbox,'Position',[5,210,80,20]);
        set(handles.select_checkbox,'Units','normalized');
        set(handles.select_checkbox,'Value',userdata.is_category_selected);
        set(handles.select_checkbox,'Callback',@edit_category_Changed);
        
        handles.category_listbox=uicontrol(handles.event_panel,'style','listbox','Callback',@GLW_view_UpdataFcn);
        set(handles.category_listbox,'Min',1);
        set(handles.category_listbox,'Max',3);
        set(handles.category_listbox,'Units','pixels');
        set(handles.category_listbox,'Position',[5,40,120,170]);
        set(handles.category_listbox,'Units','normalized');
        
        
        icon=load('icon.mat');
        
        handles.events_add_btn=uicontrol(handles.event_panel,...
            'style','pushbutton','CData',icon.icon_dataset_add,...
            'position',[25,235,32,32]);
        set(handles.events_add_btn,'Units','normalized');
        handles.events_del_btn=uicontrol(handles.event_panel,...
            'style','pushbutton','CData',icon.icon_dataset_del,...
            'position',[82,235,32,32]);
        set(handles.events_del_btn,'Units','normalized');
        handles.events_undo_btn=uicontrol(handles.event_panel,...
            'style','pushbutton','CData',icon.icon_undo,...
            'position',[139,235,32,32]);
        set(handles.events_undo_btn,'Units','normalized');
        handles.events_redo_btn=uicontrol(handles.event_panel,...
            'style','pushbutton','CData',icon.icon_redo,...
            'position',[196,235,32,32]);
        set(handles.events_redo_btn,'Units','normalized');
        
        
        handles.category_add_btn=uicontrol(handles.event_panel,...
            'style','pushbutton','CData',icon.icon_dataset_add,...
            'position',[5,5,32,32]);
        set(handles.category_add_btn,'Units','normalized');
        handles.category_del_btn=uicontrol(handles.event_panel,...
            'style','pushbutton','CData',icon.icon_dataset_del,...
            'position',[42,5,32,32]);
        set(handles.category_del_btn,'Units','normalized');
        handles.category_rename_btn=uicontrol(handles.event_panel,...
            'style','pushbutton','string','rename',...
            'position',[77,5,50,32]);
        set(handles.category_rename_btn,'Units','normalized');
        
        
        handles.GUI2workspace_btn=uicontrol(handles.event_panel,...
            'style','pushbutton','String','Send to workspace',...
            'position',[130,165,115,40]);
        set(handles.GUI2workspace_btn,'Units','normalized');
        handles.workspace2GUI_btn=uicontrol(handles.event_panel,...
            'style','pushbutton','String','Read from workspace',...
            'position',[130,120,115,40]);
        set(handles.workspace2GUI_btn,'Units','normalized');
        
        
        handles.save_checkbox=uicontrol(handles.event_panel,'style','checkbox');
        set(handles.save_checkbox,'String','overwrite the dataset:');
        set(handles.save_checkbox,'Units','pixels');
        set(handles.save_checkbox,'Position',[130,100,80,20]);
        set(handles.save_checkbox,'Units','normalized');
        set(handles.save_checkbox,'Value',userdata.is_overwrited);
        set(handles.save_checkbox,'Callback',@edit_category_Changed);
        
        
        handles.prefix_text=uicontrol(handles.event_panel,'style','text');
        set(handles.prefix_text,'HorizontalAlignment','left');
        set(handles.prefix_text,'String','Prefix:');
        set(handles.prefix_text,'Units','pixels');
        set(handles.prefix_text,'Position',[130,80,80,20]);
        set(handles.prefix_text,'Units','normalized');
        
        
        
        handles.prefix_edt=uicontrol(handles.event_panel,'style','edit');
        set(handles.prefix_edt,'String',userdata.prefix);
        set(handles.prefix_edt,'HorizontalAlignment','left');
        set(handles.prefix_edt,'Units','pixels');
        set(handles.prefix_edt,'Position',[130,60,115,25]);
        set(handles.prefix_edt,'Units','normalized');
        set(handles.prefix_edt,'Callback',@edit_filter_Changed);
        
        
        
        handles.save_btn=uicontrol(handles.event_panel,...
            'style','pushbutton','String','Save',...
            'position',[130,5,115,50]);
        set(handles.save_btn,'Units','normalized');
    end
     
    function event_panel_SizeChangedFcn(~,~)
        set(handles.event_panel,'Units','pixels');
        temp=get(handles.event_panel,'position');
        temp=(temp(3)-76)/18;
        set(handles.event_table,'ColumnWidth',{temp*8,temp*6,temp*4});
        set(handles.event_panel,'Units','normalized');
    end
%% GLW_view_OpeningFcn
    function GLW_view_OpeningFcn()
        init_parameter();
        handles.fig=figure('Visible','on','Color',0.94*[1,1,1]);
        set(handles.fig,'MenuBar','none');
        set(handles.fig,'numbertitle','off','name',[userdata.filename,' (multiviewer_continous)']);
        set(handles.fig,'DockControls','off');
        set(handles.fig,'position',userdata.fig_pos);
        
        handles.panel_edit=uipanel(handles.fig,'BorderType','none');
        set(handles.panel_edit,'Units','pixels');
        set(handles.panel_edit,'Position',[3,3,160,675]);
        set(handles.panel_edit,'Units','normalized');
        init_panel_left();
        init_panel_mid();
        init_panel_right();
    end


end