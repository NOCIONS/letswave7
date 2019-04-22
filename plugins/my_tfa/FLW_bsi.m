classdef FLW_bsi<CLW_generic
    properties
        FLW_TYPE=1;
        h_channels_list_left;
        h_channels_list_right;
        h_window_width;
        h_sliding_step;
        h_low_frequency;
        h_high_frequency;
        h_show_progress;
        h_not_equal_txt;
    end
    
    methods
        function obj = FLW_bsi(batch_handle)
            obj@CLW_generic(batch_handle,'bsi','bsi',...
                'Calculate the Brain Symmetry Index.');
            uicontrol('style','text','position',[90,495,250,20],...
                'string','Pool Channels',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            uicontrol('style','text','position',[10,475,250,20],...
                'string','Left hemisphere:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            uicontrol('style','text','position',[130,475,250,20],...
                'string','Right hemisphere:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_channels_list_left=uicontrol('style','listbox',...
                'string',{'Cz'},'Value',1,'min',0,'max',2,...
                'position',[10,145,100,330],'parent',obj.h_panel);
            obj.h_channels_list_right=uicontrol('style','listbox',...
                'string',{'Cz'},'Value',1,'min',0,'max',2,...
                'position',[130,145,100,330],'parent',obj.h_panel);
            
           uicontrol('style','text','position',[30,450,140,20],...
                'string','Windows width(s):','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_window_width=uicontrol('style','edit','string','0.2',...
                'position',[180,453,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,420,140,20],...
                'string','Sliding step (bins):','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_sliding_step=uicontrol('style','edit','string','1',...
                'position',[180,423,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,390,140,20],...
                'string','Lower frequency:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_low_frequency=uicontrol('style','edit','string','1',...
                'position',[180,393,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,360,140,20],...
                'string','Higher frequency:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_high_frequency=uicontrol('style','edit','string','30',...
                'position',[180,363,100,20],'parent',obj.h_panel);
            
            
            obj.h_show_progress=uicontrol('style','checkbox',...
                'string','show_process','value',1,...
                'position',[130,260,130,20],'parent',obj.h_panel);
            
            obj.h_not_equal_txt=uicontrol('style','text','visible','off',...
                'position',[0,125,400,20],'foregroundcolor',[1,0,0],...
                'string','The datasets share different channel property.',...
                'HorizontalAlignment','center','parent',obj.h_panel);
            
            
        
            set(obj.h_channels_list_left,'backgroundcolor',[1,1,1]);
            set(obj.h_channels_list_right,'backgroundcolor',[1,1,1]);
            set(obj.h_window_width,'backgroundcolor',[1,1,1]);
            set(obj.h_sliding_step,'backgroundcolor',[1,1,1]);
            set(obj.h_low_frequency,'backgroundcolor',[1,1,1]);
            set(obj.h_high_frequency,'backgroundcolor',[1,1,1]);
            set(obj.h_show_progress,'backgroundcolor',[1,1,1]);
            set(obj.h_not_equal_txt,'backgroundcolor',0.93*[1,1,1]);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            selected=get(obj.h_channels_list,'Value');
            st=get(obj.h_channels_list,'String');
            option.channels=st(selected);
            option.name=get(obj.h_channel_name_edt,'string');
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_channel_name_edt,'String',option.name);
            set(obj.h_channels_list,'String',option.channels);
            set(obj.h_channels_list,'value',1:length(option.channels));
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            
            frag_code=[frag_code,'''name'',''',...
                strrep(option.name,'''',''''''),''','];
            
            frag_code=[frag_code,'''channels'',{{'];
            for k=1:length(option.channels)
                frag_code=[frag_code,'''',strrep(option.channels{k},'''',''''''),''''];
                if k~=length(option.channels)
                    frag_code=[frag_code,','];
                end
            end
            frag_code=[frag_code,'}},'];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function GUI_update(obj,batch_pre)
            channels=get(obj.h_channels_list,'String');
            if isempty(channels)
                channels=[];
            else
                channels=channels(get(obj.h_channels_list,'Value'));
            end
            
            lwdataset=batch_pre.lwdataset;
            channel_labels={lwdataset(1).header.chanlocs.labels};
            set(obj.h_not_equal_txt,'visible','off');
             for dataset_pos=2:length(lwdataset)
                channel_labels1={lwdataset(dataset_pos).header.chanlocs.labels};
                channel_labels2= intersect(channel_labels,channel_labels1,'stable');
                if length(channel_labels2)<length(channel_labels)
                    set(obj.h_not_equal_txt,'string','The datasets share different channel property.');
                    set(obj.h_not_equal_txt,'visible','on');
                end
                channel_labels=channel_labels2;
            end
            if isempty(channel_labels)
                error('***No common channels.***')
            end
            set(obj.h_channels_list,'String',channel_labels);
            
            [~,~,idx] = intersect(channels,channel_labels,'stable');
            set(obj.h_channels_list,'value',idx);
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            channel_labels={header_in.chanlocs.labels};
            [~,idx] = intersect(channel_labels, option.channels,'stable');
            option.channels_idx=idx;
            header_out.datasize(2)=header_out.datasize(2)+1;
            header_out.chanlocs(end+1).labels=option.name;
            
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.channels=[];
            option.name='Avg';
            option.suffix='chan_interp';
            option.is_save=0;
            option=CLW_check_input(option,{'channels',...
                'name',...
                'suffix','is_save'},varargin);
            header=FLW_new_channel_averaged.get_header(lwdata_in.header,option);
            data=lwdata_in.data;
            idx=header.history(end).option.channels_idx;
            if isempty(idx)
                data(:,end+1,:,:,:,:)=0;
            else
                data(:,end+1,:,:,:,:)=mean(data(:,idx,:,:,:,:),2);
            end
            try
                rmfield(header.history(end).option,'channels_idx');
            end
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end