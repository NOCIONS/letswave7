function remove_idx=GLW_spatial_filter(lwdataset_in,option)
handles=[];
userdata=[];
remove_idx=nan;
GLW_view_OpeningFcn();
set(handles.fig,'windowstyle','modal');
uiwait(handles.fig);

    function GLW_view_OpeningFcn()
        Init_parameter();
        Init_fig();
        Init_function();
        GLW_dataset_UpdataFcn();
        set(handles.fig,'Visible','on');
    end

    function Init_parameter()
        ch_n=lwdataset_in(1).header.datasize(2);
        for k=2:length(lwdataset_in)
            if ch_n~=lwdataset_in(1).header.datasize(2)
                error('the dataset should have the same channel number!');
            end
        end
            
        temp=get(0,'MonitorPositions');
        temp=temp(1,:);
        userdata.fig_pos=[(temp(3)-1350)/2,(temp(4)-680)/2,1350,680];
        userdata.unmix_matrix=option.unmix_matrix;
        userdata.mix_matrix=option.mix_matrix;
        
        header=lwdataset_in(1).header;
        chan_used=find([header.chanlocs.topo_enabled]==1, 1);
        if isempty(chan_used)
            header=CLW_elec_autoload(header);
        end
        userdata.header=header;
    end

    function Init_topo()
        header=userdata.header;
        chanlocs=header.chanlocs([header.chanlocs.topo_enabled]==1);
        [doty,dotx]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
        set(handles.ax_topo,'Xlim',[-0.55,0.55]);
        set(handles.ax_topo,'Ylim',[-0.5,0.6]);
        hold(handles.ax_topo,'on');
        axis(handles.ax_topo,'square');
        [xq,yq] = meshgrid(linspace(-0.5,0.5,267),linspace(-0.5,0.5,267));
        delta = (xq(2)-xq(1))/2;
        headx = 0.5*[sin(linspace(0,2*pi,100)),NaN,sin(-2*pi*10/360),0,sin(2*pi*10/360),NaN,...
            0.1*cos(2*pi/360*linspace(80,360-80,100))-1,NaN,...
            -0.1*cos(2*pi/360*linspace(80,360-80,100))+1];
        heady = 0.5*[cos(linspace(0,2*pi,100)),NaN,cos(-2*pi*10/360),1.1,cos(2*pi*10/360),NaN,...
            0.2*sin(2*pi/360*linspace(80,360-80,100)),NaN,0.2*sin(2*pi/360*linspace(80,360-80,100))];
        handles.surface_topo=surface(xq-delta,yq-delta,zeros(size(xq)),xq,...
                        'EdgeColor','none','FaceColor','flat','parent',handles.ax_topo);
        handles.line_topo=line(headx,heady,'Color',[0,0,0],'Linewidth',2,'parent',handles.ax_topo);
        handles.dot_topo=line(dotx,doty,'Color',[0,0,0],'Linestyle','none','Marker','.','Markersize',8,'parent',handles.ax_topo);
        colormap 'jet';
        set(handles.ax_topo,'Visible','off');
    end

    function Update_topo()
        [xq,yq] = meshgrid(linspace(-0.5,0.5,267),linspace(-0.5,0.5,267));
        chan_used=find([userdata.header.chanlocs.topo_enabled]==1);
        if isempty(chan_used)
            set( handles.surface_topo,'CData',nan(67,67));
        else
            chanlocs=userdata.header.chanlocs(chan_used);
            [y,x]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
            component_idx=get(handles.IC_listbox,'value');
            vq = griddata(x,y,userdata.mix_matrix(chan_used,component_idx),xq,yq,'cubic');
            set( handles.surface_topo,'CData',vq);
        end
    end

    function Init_fig()
        handles.fig=figure('Visible','off','Resize','off','Color',0.94*[1,1,1]);
        set(handles.fig,'MenuBar','none');
        set(handles.fig,'numbertitle','off','name','manually remove component for spatial filter');
        set(handles.fig,'DockControls','off');
        set(handles.fig,'position',userdata.fig_pos);
        
        handles.dataset_text=uicontrol(handles.fig,'style','text',...
            'String','Dataset:','HorizontalAlignment','left');
        handles.dataset_listbox=uicontrol(handles.fig,...
            'style','listbox','Min',1,'Max',1);
        handles.epoch_text=uicontrol(handles.fig,'style','text',...
            'String','Epochs:','HorizontalAlignment','left');
        handles.epoch_listbox=uicontrol(handles.fig,...
            'style','listbox','Min',1,'Max',1);
        handles.channel_text=uicontrol(handles.fig,'style','text',...
            'String','Channels:','HorizontalAlignment','left');
        handles.channel_listbox=uicontrol(handles.fig,...
            'style','listbox','Min',1,'Max',1);
        handles.IC_text=uicontrol(handles.fig,'style','text',...
            'String','Component:','HorizontalAlignment','left');
        handles.IC_listbox=uicontrol(handles.fig,...
            'style','listbox','Min',1,'Max',1,'Foregroundcolor',[0    0.4470    0.7410]);
        
        handles.component_text=uicontrol(handles.fig,'style','text',...
            'String','Time course for the selected component:','HorizontalAlignment','left');
        handles.result_text=uicontrol(handles.fig,'style','text',...
            'String','Time course for the signal before and after spatial filter:','HorizontalAlignment','left');
        
        handles.remove_component_text=uicontrol(handles.fig,'style','text',...
            'String','Components to remove:','HorizontalAlignment','left');
        handles.remove_component_listbox=uicontrol(handles.fig,...
            'style','listbox','Min',1,'Max',3,'Foregroundcolor',[0.8500    0.3250    0.0980]);
        handles.OK_btn=uicontrol(handles.fig,'style','pushbutton','string','OK');
        handles.Cancel_btn=uicontrol(handles.fig,'style','pushbutton','string','Cancel');
        handles.Assign_btn=uicontrol(handles.fig,...
            'style','pushbutton','string','Assign electrode coordinates');
        
        
        handles.ax_fft=axes();box on;
        title('FFT and topograph of the component','HorizontalAlignment','left',...
            'units','normalized','Position',[0.02,0.05]);
        xlabel('Hz');
        handles.ax_topo=axes();box on;
        handles.ax_component=axes();box on;
        handles.ax_result=axes();box on;
        handles.line_component=line(1:100,randn(1,100),'Parent',handles.ax_component);
        handles.line_before=line(1:100,randn(1,100),'Parent',handles.ax_result);
        handles.line_after=line(1:100,randn(1,100),'Parent',handles.ax_result);
        handles.line_fft=line(1:100,randn(1,100),'Parent',handles.ax_fft);
        set(handles.line_fft,'color',[0    0.4470    0.7410]);
        set(handles.line_component,'color',[0    0.4470    0.7410],'linewidth',2);
        set(handles.line_before,'color',[0,0,0],'linewidth',2);
        set(handles.line_after,'color',[0.8500    0.3250    0.0980],'linewidth',2);
        legend('before spatial filter','after spatial filter');
        
        set(handles.dataset_listbox,'backgroundcolor',[1,1,1]);
        set(handles.epoch_listbox,'backgroundcolor',[1,1,1]);
        set(handles.channel_listbox,'backgroundcolor',[1,1,1]);
        set(handles.IC_listbox,'backgroundcolor',[1,1,1]);
        set(handles.remove_component_listbox,'backgroundcolor',[1,1,1]);
        
        
        Set_position(handles.dataset_text,[8,660,60,20]);
        Set_position(handles.dataset_listbox,[8,562,320,100]);
        
        Set_position(handles.epoch_text,[8,542,60,20]);
        Set_position(handles.epoch_listbox,[8,190,100,355]);
        Set_position(handles.channel_text,[118,542,60,20]);
        Set_position(handles.channel_listbox,[118,220,100,325]);
        Set_position(handles.IC_text,[228,542,60,20]);
        Set_position(handles.IC_listbox,[228,220,100,325]);
        Set_position(handles.Assign_btn,[118,185,210,30]);
        
        Set_position(handles.ax_topo,[220,100,80,80]);
        Set_position(handles.ax_fft,[18,33,310,150]);
        Set_position(handles.result_text,[360,660,400,20]);
        Set_position(handles.ax_result,[360,220,800,440]);
        Set_position(handles.component_text,[360,184,400,20]);
        Set_position(handles.ax_component,[360,33,800,150]);
        
        Set_position(handles.remove_component_text,[1178,660,167,20]);
        Set_position(handles.remove_component_listbox,[1178,100,167,560]);
        Set_position(handles.OK_btn,[1175,50,170,45]);
        Set_position(handles.Cancel_btn,[1175,8,170,45]);
        
        temp=get(0,'MonitorPositions');
        temp=temp(1,:);
        if temp(3)<1350 ||temp(4)<680-100
            if  temp(3)/temp(4)<1350/680
                w=min(1350,temp(3));
                h=w/1350*680;
            else
                h=min(temp(4)-50,680);
                w=h/680*1350;
            end
                x=(temp(3)-w)/2;
                y=max(50,(temp(4)-h)/2);
            userdata.fig_pos=[x,y,w,h];
            set(handles.fig,'position',userdata.fig_pos);
        end
        str=cell(length(lwdataset_in),1);
        for k=1:length(lwdataset_in)
            str{k}=lwdataset_in(k).header.name;
        end
        set(handles.dataset_listbox,'string',str);
        
        str=cell(lwdataset_in(1).header.datasize(1),1);
        for k=1:lwdataset_in(1).header.datasize(1)
            str{k}=num2str(k);
        end
        set(handles.epoch_listbox,'string',str);
        
        str=cell(lwdataset_in(1).header.datasize(2),1);
        for k=1:lwdataset_in(1).header.datasize(2)
            str{k}=lwdataset_in(1).header.chanlocs(k).labels;
        end
        set(handles.channel_listbox,'string',str);
        
        str=cell(size(userdata.unmix_matrix,1),1);
        for k=1:size(userdata.unmix_matrix,1)
            str{k}=['comp ',num2str(k)];
        end
        set(handles.IC_listbox,'string',str);
        set(handles.remove_component_listbox,'string',str);
        Init_topo();
    end

    function Init_function()
        set(handles.dataset_listbox,'Callback',@GLW_dataset_UpdataFcn);
        set(handles.epoch_listbox,'Callback',@GLW_my_view_UpdataFcn);
        set(handles.channel_listbox,'Callback',@GLW_channel_UpdataFcn);
        set(handles.IC_listbox,'Callback',@GLW_component_UpdataFcn);
        set(handles.remove_component_listbox,'Callback',@GLW_component_remove_UpdataFcn);
        set(handles.Assign_btn,'Callback',@Assgin_electrode);
        set(handles.OK_btn,'Callback',@OK_btn_callback);
        set(handles.Cancel_btn,'Callback',@Cancel_btn_callback);
    end

    function OK_btn_callback(~,~)
        remove_idx=get(handles.remove_component_listbox,'value');
        closereq;
    end

    function Cancel_btn_callback(~,~)
        closereq;
    end

    function Assgin_electrode(~,~)
        [p,~,~] = fileparts(which('letswave7'));
        DefaultName=fullfile(p,'res','electrodes','spherical_locations','Standard-10-20-Cap81.locs');
        [filename,pathname] = uigetfile({'*.*'},'Select the electrode assgin file',DefaultName);
        if isequal(filename,0)
        else
            chanlocs=readlocs(fullfile(pathname,filename));
            chanloc_labels={chanlocs.labels};
            channel_labels={userdata.header.chanlocs.labels};
            header_chanlocs=userdata.header.chanlocs;
            for chanpos=1:length(channel_labels)
                header_chanlocs(chanpos).topo_enabled=0;
                a=find(strcmpi(channel_labels{chanpos},chanloc_labels)==1);
                if isempty(a)
                else
                    header_chanlocs(chanpos).theta=chanlocs(a).theta;
                    header_chanlocs(chanpos).radius=chanlocs(a).radius;
                    header_chanlocs(chanpos).sph_theta=chanlocs(a).sph_theta;
                    header_chanlocs(chanpos).sph_phi=chanlocs(a).sph_phi;
                    header_chanlocs(chanpos).sph_theta_besa=chanlocs(a).sph_theta_besa;
                    header_chanlocs(chanpos).sph_phi_besa=chanlocs(a).sph_phi_besa;
                    header_chanlocs(chanpos).X=chanlocs(a).X;
                    header_chanlocs(chanpos).Y=chanlocs(a).Y;
                    header_chanlocs(chanpos).Z=chanlocs(a).Z;
                    header_chanlocs(chanpos).topo_enabled=1;
                    header_chanlocs(chanpos).SEEG_enabled=0;
                end
            end
            userdata.header.chanlocs=header_chanlocs;
            chanlocs=userdata.header.chanlocs([userdata.header.chanlocs.topo_enabled]==1);
            [doty,dotx]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
            set(handles.dot_topo,'XData',dotx,'YData',doty);
            Update_topo();
        end
    end

    function GLW_dataset_UpdataFcn(~,~)
        dataset_idx=get(handles.dataset_listbox,'value');
        epoch_idx=get(handles.epoch_listbox,'value');
        header=lwdataset_in(dataset_idx).header;
        
        if epoch_idx>header.datasize(1)
            epoch_idx=header.datasize(1);
            set(handles.epoch_listbox,'value',epoch_idx);
        end
        str=cell(header.datasize(1),1);
        for k=1:header.datasize(1)
            str{k}=num2str(k);
        end
        set(handles.epoch_listbox,'string',str);
        userdata.t=(0:header.datasize(6)-1)*header.xstep+header.xstart;
        userdata.t_fft=(0:header.datasize(6)-1)/(header.xstep*header.datasize(6)); 
        
        if userdata.t_fft(end)/2>50
            set(handles.ax_fft,'xlim',[0,50]);
        else
            set(handles.ax_fft,'xlim',[0,userdata.t_fft(ceil((end+1)/2))]);
        end
        
        set(handles.line_before,'XData',userdata.t,'YData',zeros(size(userdata.t)));
        set(handles.line_component,'XData',userdata.t,'YData',zeros(size(userdata.t)));
        set(handles.line_fft,'XData',userdata.t_fft,'YData',ones(size(userdata.t)));
        set(handles.line_after,'XData',userdata.t,'YData',zeros(size(userdata.t)));
        set(handles.ax_component,'xlim',[userdata.t(1),userdata.t(end)]);
        set(handles.ax_result,'xlim',[userdata.t(1),userdata.t(end)]);
        
        GLW_my_view_UpdataFcn();
    end

    function GLW_my_view_UpdataFcn(~,~)
        dataset_idx=get(handles.dataset_listbox,'value');
        epoch_idx=get(handles.epoch_listbox,'value');
        channel_idx=get(handles.channel_listbox,'value');
        component_idx=get(handles.IC_listbox,'value');
        component_remove_idx=get(handles.remove_component_listbox,'value');
        
        remix_matrix=userdata.mix_matrix;
        remix_matrix(:,component_remove_idx)=0;   
        Update_topo();
        set(handles.line_before,'YData',...
            squeeze(lwdataset_in(dataset_idx).data(epoch_idx,channel_idx,1,1,1,:)));
        set(handles.line_component,'YData',...
            userdata.unmix_matrix(component_idx,:)*squeeze(lwdataset_in(dataset_idx).data(epoch_idx,:,1,1,1,:)));
        set(handles.line_fft,'YData',...
            log(abs(fft(get(handles.line_component,'YData'),[],2))));
        set(handles.line_after,'YData',...
            remix_matrix(channel_idx,:)*userdata.unmix_matrix*squeeze(lwdataset_in(dataset_idx).data(epoch_idx,:,1,1,1,:)));
        
    end

    function GLW_channel_UpdataFcn(~,~)
        dataset_idx=get(handles.dataset_listbox,'value');
        epoch_idx=get(handles.epoch_listbox,'value');
        channel_idx=get(handles.channel_listbox,'value');
        component_remove_idx=get(handles.remove_component_listbox,'value');
        
        remix_matrix=userdata.mix_matrix;
        remix_matrix(:,component_remove_idx)=0;
        set(handles.line_before,'YData',...
            squeeze(lwdataset_in(dataset_idx).data(epoch_idx,channel_idx,1,1,1,:)));
        set(handles.line_after,'YData',...
            remix_matrix(channel_idx,:)*userdata.unmix_matrix*squeeze(lwdataset_in(dataset_idx).data(epoch_idx,:,1,1,1,:)));
    end

    function GLW_component_UpdataFcn(~,~)
        dataset_idx=get(handles.dataset_listbox,'value');
        epoch_idx=get(handles.epoch_listbox,'value');
        component_idx=get(handles.IC_listbox,'value');
          
        Update_topo();
        set(handles.line_component,'YData',...
            userdata.unmix_matrix(component_idx,:)*squeeze(lwdataset_in(dataset_idx).data(epoch_idx,:,1,1,1,:)));
        set(handles.line_fft,'YData',...
            log(abs(fft(get(handles.line_component,'YData'),[],2))));
    end

    function GLW_component_remove_UpdataFcn(~,~)
        dataset_idx=get(handles.dataset_listbox,'value');
        epoch_idx=get(handles.epoch_listbox,'value');
        channel_idx=get(handles.channel_listbox,'value');
        component_remove_idx=get(handles.remove_component_listbox,'value');
        remix_matrix=userdata.mix_matrix;
        remix_matrix(:,component_remove_idx)=0;
        set(handles.line_after,'YData',...
            remix_matrix(channel_idx,:)*userdata.unmix_matrix*squeeze(lwdataset_in(dataset_idx).data(epoch_idx,:,1,1,1,:)));
    end


    function Set_position(obj,position)
        set(obj,'Units','pixels');
        set(obj,'Position',position);
        set(obj,'Units','normalized');
    end
end
