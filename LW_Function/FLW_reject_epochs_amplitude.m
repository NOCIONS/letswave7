classdef FLW_reject_epochs_amplitude<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Mout, like math_multiple, t-test
        FLW_TYPE=1;
        h_select_channels_chk;
        h_channels_listbox;
        h_channels_select_btn;
        h_xaxis_chk;
        h_xstart_edit;
        h_xend_edit;
        h_yaxis_chk;
        h_ystart_edit;
        h_yend_edit;
        h_zaxis_chk;
        h_zstart_edit;
        h_zend_edit;
        h_amplitude_criterion_edit;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_reject_epochs_amplitude(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'Reject epochs (amplitude criterion)','ar-amp',...
                'Reject epochs based on a simple amplitude criterion.');
            %objects
            %select channels
            obj.h_select_channels_chk=uicontrol('style','checkbox',...
                'String','Judge Selected/All Channel(s):','value',0,...
                'callback',@obj.channel_check,...
                'position',[20,480,250,30],'parent',obj.h_panel);
            %channels list_box
            obj.h_channels_listbox=uicontrol('style','listbox',...
                'String','Select channels','min',0,'max',2,...
                'backgroundcolor',[1,1,1],'enable','off',...
                'position',[35,160,180,320],'parent',obj.h_panel);
            %channels select_btn
            obj.h_channels_select_btn=uicontrol('style','pushbutton',...
                'String','All/None','value',0,'enable','off',...
                'callback',@obj.channel_select_all,...
                'position',[35,130,180,30],'parent',obj.h_panel);
            
            uicontrol('style','text',...
                'String','Judge Selected/Whole Interval',...
                'HorizontalAlignment','left',...
                'position',[220,438,200,20],'parent',obj.h_panel);
            
            %xaxis_chk
            obj.h_xaxis_chk=uicontrol('style','checkbox',...
                'String','X-axis ','value',0,...
                 'callback',@obj.item_check,...
                'position',[220,408,150,30],'parent',obj.h_panel);
            %xstart_edit
            obj.h_xstart_edit=uicontrol('style','edit',...
                'String','0','HorizontalAlignment','left',...
                'value',0,'backgroundcolor',[1,1,1],'enable','off',...
                'callback',@obj.item_check,...
                'position',[220,390,80,20],'parent',obj.h_panel);
            %xend_edit
            obj.h_xend_edit=uicontrol('style','edit',...
                'String','','HorizontalAlignment','left',...
                'value',1,'backgroundcolor',[1,1,1],'enable','off',...
                'callback',@obj.item_check,...
                'position',[305,390,80,20],'parent',obj.h_panel);
            %yaxis_chk
            obj.h_yaxis_chk=uicontrol('style','checkbox',...
                'String','Y-axis','value',0,...
                'callback',@obj.item_check,...
                'position',[220,353,150,30],'parent',obj.h_panel);
            %ystart_edit
            obj.h_ystart_edit=uicontrol('style','edit',...
                'String','0','HorizontalAlignment','left',...
                'value',0,'backgroundcolor',[1,1,1],'enable','off',...
                'callback',@obj.item_check,...
                'position',[220,335,80,20],'parent',obj.h_panel);
            %yend_edit
            obj.h_yend_edit=uicontrol('style','edit',...
                'String','','HorizontalAlignment','left',...
                'value',1,'backgroundcolor',[1,1,1],'enable','off',...
                'callback',@obj.item_check,...
                'position',[305,335,80,20],'parent',obj.h_panel);
            %zaxis_chk
            obj.h_zaxis_chk=uicontrol('style','checkbox',...
                'String','Z-axis','value',0,...
                'callback',@obj.item_check,...
                'position',[220,298,150,30],'parent',obj.h_panel);
            %zstart_edit
            obj.h_zstart_edit=uicontrol('style','edit',...
                'String','0','HorizontalAlignment','left',...
                'value',0,'backgroundcolor',[1,1,1],'enable','off',...
                'callback',@obj.item_check,...
                'position',[220,280,80,20],'parent',obj.h_panel);
            %zend_edit
            obj.h_zend_edit=uicontrol('style','edit',...
                'String','','HorizontalAlignment','left',...
                'value',1,'backgroundcolor',[1,1,1],'enable','off',...
                'callback',@obj.item_check,...
                'position',[305,280,80,20],'parent',obj.h_panel);
            %amplitude_criterion_label
            uicontrol('style','text','position',[220,220,150,20],...
                'string','Amplitude criterion:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %amplitude_criterion_edit
            obj.h_amplitude_criterion_edit=uicontrol('style','edit',...
                'String','100','HorizontalAlignment','left',...
                'value',0,'backgroundcolor',[1,1,1],...
                'position',[220,200,80,20],'parent',obj.h_panel);
        end
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            %
            option.xstart=str2num(get(obj.h_xstart_edit,'string'));
            option.ystart=str2num(get(obj.h_ystart_edit,'string'));
            option.zstart=str2num(get(obj.h_zstart_edit,'string'));
            option.xend=str2num(get(obj.h_xend_edit,'string'));
            option.yend=str2num(get(obj.h_yend_edit,'string'));
            option.zend=str2num(get(obj.h_zend_edit,'string'));
            option.xaxis_chk=get(obj.h_xaxis_chk,'value');
            option.yaxis_chk=get(obj.h_yaxis_chk,'value');
            option.zaxis_chk=get(obj.h_zaxis_chk,'value');
            option.amplitude_criterion=str2num(get(obj.h_amplitude_criterion_edit,'string'));
            option.channels_chk=get(obj.h_select_channels_chk,'value');
            str=get(obj.h_channels_listbox,'string');
            str=str(get(obj.h_channels_listbox,'value'));
            option.channels=str;
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            %
            set(obj.h_xstart_edit,'String',num2str(option.xstart));
            set(obj.h_ystart_edit,'String',num2str(option.ystart));
            set(obj.h_zstart_edit,'String',num2str(option.zstart));
            set(obj.h_xend_edit,'String',num2str(option.xend));
            set(obj.h_yend_edit,'String',num2str(option.yend));
            set(obj.h_zend_edit,'String',num2str(option.zend));
            set(obj.h_xaxis_chk,'Value',option.xaxis_chk);
            set(obj.h_yaxis_chk,'Value',option.yaxis_chk);
            set(obj.h_zaxis_chk,'Value',option.zaxis_chk);
            set(obj.h_amplitude_criterion,'String',num2str(option.amplitude_criterion));
            set(obj.h_select_channels_chk,'Value',option.channels_chk);        
            %channels_listbox
            set(obj.h_channels_listbox,'String',str);
            set(obj.h_channels_listbox,'value',1:length(option.channels_listbox));
        end
        
        %get the script for this operation
        %run this function, normally we will get a script 
        %with two lines as following 
        %      option=struct('suffix','demo','is_save',1);
        %      lwdata= FLW_Demo.get_lwdata(lwdata,option);
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            %%%
            if option.xaxis_chk==1
                frag_code=[frag_code,'''xaxis_chk'',',...
                    num2str(option.xaxis_chk),','];
                frag_code=[frag_code,'''xstart'',',...
                    num2str(option.xstart),','];
                frag_code=[frag_code,'''xend'',',...
                    num2str(option.xend),','];
            end
            if option.yaxis_chk==1
                frag_code=[frag_code,'''yaxis_chk'',',...
                    num2str(option.yaxis_chk),','];
                frag_code=[frag_code,'''ystart'',',...
                    num2str(option.ystart),','];
                frag_code=[frag_code,'''yend'',',...
                    num2str(option.yend),','];
            end
            if option.zaxis_chk==1
                frag_code=[frag_code,'''zaxis_chk'',',...
                    num2str(option.zaxis_chk),','];
                frag_code=[frag_code,'''zstart'',',...
                    num2str(option.zstart),','];
                frag_code=[frag_code,'''zend'',',...
                    num2str(option.xend),','];
            end
            frag_code=[frag_code,'''amplitude_criterion'',',...
                num2str(option.amplitude_criterion),','];
            if option.channels_chk==1
                frag_code=[frag_code,'''channels_chk'',',...
                    num2str(option.channels_chk),','];
                frag_code=[frag_code,'''channels'',{{'];
                for k=1:length(option.channels)
                    frag_code=[frag_code,'''',option.channels{k},''''];
                    if k~=length(option.channels)
                        frag_code=[frag_code,','];
                    end
                end
                frag_code=[frag_code,'}},'];
            end
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function channel_check(obj,varargin)
            v=get(obj.h_select_channels_chk,'value');
            if v==1
                set(obj.h_channels_listbox,'enable','on');
                set(obj.h_channels_select_btn,'enable','on');
            else
                set(obj.h_channels_listbox,'enable','off');
                set(obj.h_channels_select_btn,'enable','off');
            end
        end
        function channel_select_all(obj,varargin)
            v=get(obj.h_channels_listbox,'Value');
            if isempty(v)
                str=get(obj.h_channels_listbox,'String');
                v=1:length(str);
            else
                v=[];
            end
            set(obj.h_channels_listbox,'Value',v);
        end
        function item_check(obj,varargin)
            header=obj.lwdataset(1).header;
            v=get(obj.h_xaxis_chk,'value');
            if v==1
                set(obj.h_xstart_edit,'enable','on');
                set(obj.h_xend_edit,'enable','on');
                v_start=str2num(get(obj.h_xstart_edit,'string'));
                v_end=str2num(get(obj.h_xend_edit,'string'));
                if isempty(v_start)
                    v_start=get(obj.h_xstart_edit,'value');
                end
                if isempty(v_end)
                    v_end=get(obj.h_xend_edit,'value');
                end
                temp1=header.xstart;
                temp2=header.xstart+header.datasize(6)*header.xstep;
                if v_start<temp1
                    v_start=temp1;
                end
                if v_end<temp1
                    v_end=temp1;
                end
                if v_start>temp2
                    v_start=temp2;
                end
                if v_end>temp2
                    v_end=temp2;
                end
                if v_start>v_end
                    temp=v_start;
                    v_start=v_end;
                    v_end=temp;
                end
                set(obj.h_xstart_edit,'string',num2str(v_start));
                set(obj.h_xend_edit,'string',num2str(v_end));
                set(obj.h_xstart_edit,'value',v_start);
                set(obj.h_xend_edit,'value',v_end);
            else
                set(obj.h_xstart_edit,'enable','off');
                set(obj.h_xend_edit,'enable','off');
            end
            v=get(obj.h_yaxis_chk,'value');
            if v==1
                set(obj.h_ystart_edit,'enable','on');
                set(obj.h_yend_edit,'enable','on');
                v_start=str2num(get(obj.h_ystart_edit,'string'));
                v_end=str2num(get(obj.h_yend_edit,'string'));
                if isempty(v_start)
                    v_start=get(obj.h_ystart_edit,'value');
                end
                if isempty(v_end)
                    v_end=get(obj.h_yend_edit,'value');
                end
                temp1=header.ystart;
                temp2=header.ystart+header.datasize(5)*header.ystep;
                if v_start<temp1
                    v_start=temp1;
                end
                if v_end<temp1
                    v_end=temp1;
                end
                if v_start>temp2
                    v_start=temp2;
                end
                if v_end>temp2
                    v_end=temp2;
                end
                if v_start>v_end
                    temp=v_start;
                    v_start=v_end;
                    v_end=temp;
                end
                set(obj.h_ystart_edit,'string',num2str(v_start));
                set(obj.h_yend_edit,'string',num2str(v_end));
                set(obj.h_ystart_edit,'value',v_start);
                set(obj.h_yend_edit,'value',v_end);
            else
                set(obj.h_ystart_edit,'enable','off');
                set(obj.h_yend_edit,'enable','off');
            end
            v=get(obj.h_zaxis_chk,'value');
            if v==1
                set(obj.h_zstart_edit,'enable','on');
                set(obj.h_zend_edit,'enable','on');
                v_start=str2num(get(obj.h_zstart_edit,'string'));
                v_end=str2num(get(obj.h_zend_edit,'string'));
                if isempty(v_start)
                    v_start=get(obj.h_zstart_edit,'value');
                end
                if isempty(v_end)
                    v_end=get(obj.h_zend_edit,'value');
                end
                temp1=header.zstart;
                temp2=header.zstart+header.datasize(4)*header.zstep;
                if v_start<temp1
                    v_start=temp1;
                end
                if v_end<temp1
                    v_end=temp1;
                end
                if v_start>temp2
                    v_start=temp2;
                end
                if v_end>temp2
                    v_end=temp2;
                end
                if v_start>v_end
                    temp=v_start;
                    v_start=v_end;
                    v_end=temp;
                end
                set(obj.h_zstart_edit,'string',num2str(v_start));
                set(obj.h_zend_edit,'string',num2str(v_end));
                set(obj.h_zstart_edit,'value',v_start);
                set(obj.h_zend_edit,'value',v_end);
            else
                set(obj.h_zstart_edit,'enable','off');
                set(obj.h_zend_edit,'enable','off');
            end
        end
        
        function GUI_update(obj,batch_pre)
            obj.lwdataset=batch_pre.lwdataset;
            channel_labels={ obj.lwdataset(1).header.chanlocs.labels};
            if length(obj.lwdataset)>1
                for dataset_pos=2:length(obj.lwdataset)
                    channel_labels1={obj.lwdataset(dataset_pos).header.chanlocs.labels};
                    channel_labels2= intersect(channel_labels,channel_labels1,'stable');
                    channel_labels=channel_labels2;
                end
                if isempty(channel_labels)
                    error('***No common channels.***')
                end
            end
            set(obj.h_channels_listbox,'String',channel_labels);
            %xend, yend, zend
            header=obj.lwdataset(1).header;
            if isempty(get(obj.h_xend_edit,'String'))
                set(obj.h_xend_edit,'String',num2str(header.xstart+((header.datasize(6))*header.xstep)));
            end
            if isempty(get(obj.h_yend_edit,'String'))
                set(obj.h_yend_edit,'String',num2str(header.ystart+((header.datasize(5))*header.ystep)));
            end
            if isempty(get(obj.h_zend_edit,'String'))
                set(obj.h_zend_edit,'String',num2str(header.zstart+((header.datasize(4))*header.zstep)));
            end
            header=batch_pre.lwdataset(1).header;
            if header.datasize(6)==1
                set(obj.h_xaxis_chk,'Visible','off');
                set(obj.h_xstart_edit,'Visible','off');
                set(obj.h_xend_edit,'Visible','off');
            else
                set(obj.h_xaxis_chk,'Visible','on');
                set(obj.h_xstart_edit,'Visible','on');
                set(obj.h_xend_edit,'Visible','on');
            end
            if header.datasize(5)==1
                set(obj.h_yaxis_chk,'Visible','off');
                set(obj.h_ystart_edit,'Visible','off');
                set(obj.h_yend_edit,'Visible','off');
            else
                set(obj.h_yaxis_chk,'Visible','on');
                set(obj.h_ystart_edit,'Visible','on');
                set(obj.h_yend_edit,'Visible','on');
            end
            if header.datasize(4)==1
                set(obj.h_zaxis_chk,'Visible','off');
                set(obj.h_zstart_edit,'Visible','off');
                set(obj.h_zend_edit,'Visible','off');
            else
                set(obj.h_zaxis_chk,'Visible','on');
                set(obj.h_zstart_edit,'Visible','on');
                set(obj.h_zend_edit,'Visible','on');
            end
            
            obj.channel_check();
            obj.item_check();
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            %default values
            option.xaxis_chk=0;
            option.yaxis_chk=0;
            option.zaxis_chk=0;
            option.channels_chk=0;
            option.xstart=0;
            option.xend=0;
            option.ystart=0;
            option.yend=0;
            option.zstart=0;
            option.zend=0;
            option.channels={};
            option.amplitude_criterion=100;
            option.suffix='ar-amp';
            option.is_save=0;
            option=CLW_check_input(option,{'xaxis_chk','yaxis_chk','zaxis_chk','channels_chk',...
                'xstart','xend','ystart','yend','zstart','zend','channels','amplitude_criterion',...
                'suffix','is_save'},varargin);
            header=FLW_reject_epochs_amplitude.get_header(lwdata_in.header,option);
            data=lwdata_in.data;
            %%%
            %first step is to identify accepted epochs based on criterion
            %dx1,dx2
            if option.xaxis_chk==1
                %limits : find dx1 and dx2
                dx1=round(((option.xstart-header.xstart)/header.xstep)+1);
                dx2=round(((option.xend-header.xstart)/header.xstep));
                if dx1<1
                    dx1=1;
                end
                if dx2>header.datasize(6)
                    dx2=header.datasize(6);
                end
            else
                %no limits : select all epoch range
                dx1=1;
                dx2=header.datasize(6);
            end
            %dy1,dy2
            if option.yaxis_chk==1
                %limits : find dy1 and dy2
                dy1=round(((option.ystart-header.ystart)/header.ystep)+1);
                dy2=round(((option.yend-header.ystart)/header.ystep));
                if dy1<1
                    dy1=1;
                end
                if dy2>header.datasize(5)
                    dy2=header.datasize(5);
                end
            else
                %no limits : select all epoch range
                dy1=1;
                dy2=header.datasize(5);
            end
            %dz1,dz2
            if option.zaxis_chk==1
                %limits : find dz1 and dz2
                dz1=round(((option.zstart-header.zstart)/header.zstep)+1);
                dz2=round(((option.zend-header.zstart)/header.zstep));
                if dz1<1
                    dz1=1;
                end
                if dz2>header.datasize(4)
                    dz2=header.datasize(4);
                end
            else
                %no limits : select all epoch range
                dz1=1;
                dz2=header.datasize(4);
            end
            disp(['DX1 : ' num2str(dx1) ' DX2 : ' num2str(dx2)]);
            disp(['DY1 : ' num2str(dy1) ' DY2 : ' num2str(dy2)]);
            disp(['DZ1 : ' num2str(dz1) ' DZ2 : ' num2str(dz2)]);
            %channels_idx
            if option.channels_chk==1
                st={header.chanlocs.labels};
                [~,channels_idx]=intersect(st,option.channels);
            else
                channels_idx=1:1:header.datasize(2);
            end
            %check criterion
            j=1;
            accepted_epochs=[];
            for epochpos=1:header.datasize(1)
                tp=data(epochpos,channels_idx,1,dz1:dz2,dy1:dy2,dx1:dx2);
                if max(abs(tp(:)))>option.amplitude_criterion
                else
                    accepted_epochs(j)=epochpos;
                    j=j+1;
                end
            end
            disp(['Selected epochs : ' num2str(accepted_epochs)]);
            %remove epochs
            data=data(accepted_epochs,:,:,:,:,:);
            %update header.datasize
            header.datasize=size(data);
            %fix events
            if isfield(header,'events')
                if isempty(header.events)
                else
                    j=1;
                    delete_events=[];
                    for i=1:length(header.events)
                        a=find(accepted_epochs==header.events(i).epoch);
                        header.events(i).epoch=a;
                        if isempty(a)
                            delete_events(j)=i;
                            j=j+1;
                        end
                    end
                    header.events(delete_events)=[];
                end
            end
            %fix epochdata
            if isfield(header,'epochdata')
                if isempty(header.epochdata)
                else
                    header.epochdata=header.epochdata(accepted_epochs);
                end
            end
            header.history(end).option.accepted_epochs=accepted_epochs;
            %%%
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end