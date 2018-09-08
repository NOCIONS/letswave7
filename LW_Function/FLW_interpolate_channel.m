classdef FLW_interpolate_channel<CLW_generic
    properties
        FLW_TYPE=1;
        h_channel_to_interpolate;
        h_channels_for_interpolation_list;
        h_find_neighbour_btn;
        h_channel_num_edt;
        h_not_equal_txt;
        chanlocs;
    end
    
    methods
        function obj = FLW_interpolate_channel(batch_handle)
            obj@CLW_generic(batch_handle,'chan_interp','chan_interp',...
                'Interpolate channel using the signals from neighbouring channels.');
            uicontrol('style','text','position',[30,495,150,20],...
                'string','Channel to Interpolate:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_channel_to_interpolate=uicontrol('style','listbox',...
                'string',{'Cz'},'Value',1,'min',0,'max',1,...
                'position',[30,145,110,350],'parent',obj.h_panel);
            uicontrol('style','text','position',[160,495,150,20],...
                'string','Channels for Interpolation:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_channels_for_interpolation_list=uicontrol('style','listbox','min',0,'max',2,...
                'position',[165,145,110,350],'parent',obj.h_panel);
            
            if ispc
                uicontrol('style','text','position',[285,435,130,30],...
                    'string','Number of channels used for interpolation:',...
                    'HorizontalAlignment','left','parent',obj.h_panel);
            else
                uicontrol('style','text','position',[290,430,110,30],...
                    'string','Number of channels used for interpolation:',...
                    'HorizontalAlignment','left','parent',obj.h_panel);
            end
            obj.h_channel_num_edt=uicontrol('style','edit',...
                'string','3','position',[290,400,110,30],'parent',obj.h_panel);
            obj.h_find_neighbour_btn=uicontrol('style','pushbutton',...
                'string','<html>Find closest<br>&nbsp;electrodes</html>','callback',@obj.find_neighbour_Callback,...
                'position',[290,300,110,80],'parent',obj.h_panel);
            obj.h_not_equal_txt=uicontrol('style','text','visible','off',...
                'position',[0,125,400,20],'foregroundcolor',[1,0,0],...
                'string','The datasets share different channel property.',...
                'HorizontalAlignment','center','parent',obj.h_panel);
            
            set(obj.h_channel_to_interpolate,'backgroundcolor',[1,1,1]);
            set(obj.h_channels_for_interpolation_list,'backgroundcolor',[1,1,1]);
            set(obj.h_not_equal_txt,'backgroundcolor',0.93*[1,1,1]);
            set(obj.h_channel_num_edt,'backgroundcolor',[1,1,1]);
        end
        
        function find_neighbour_Callback(obj,varargin)
            bad_channel=get(obj.h_channel_to_interpolate,'value');
            channel_num=str2num(get(obj.h_channel_num_edt,'String'));
            
            chan_used=find([obj.chanlocs.topo_enabled]==1, 1);
            if isempty(chan_used)
                header.chanlocs=obj.chanlocs;
                header=CLW_elec_autoload(header);
                chan_locs=header.chanlocs;
            else
                chan_locs=obj.chanlocs;
            end
            N=length(chan_locs);
            if chan_locs(bad_channel).topo_enabled==0
                set(obj.h_channels_for_interpolation_list,'Value',[]);
                set(obj.h_not_equal_txt,'visible','on');
                set(obj.h_not_equal_txt,'visible','on','string','unable to find the closest electrodes.');
                return;
            else
                set(obj.h_not_equal_txt,'visible','off');
            end
            dist=-ones(N,1);
            for i=setdiff(1:N,bad_channel)
                if chan_locs(i).topo_enabled==1
                    dist(i)=sqrt((chan_locs(i).X-chan_locs(bad_channel).X)^2+(chan_locs(i).Y-chan_locs(bad_channel).Y)^2+(chan_locs(i).Z-chan_locs(bad_channel).Z)^2);
                end
            end
            dist((dist==-1))=max(dist);
            [~,idx]=sort(dist);
            channel_idx=idx(1:channel_num);
            set(obj.h_channels_for_interpolation_list,'Value',channel_idx);
            
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            selected=get(obj.h_channel_to_interpolate,'Value');
            st=get(obj.h_channel_to_interpolate,'String');
            option.channel_to_interpolate=st{selected(1)};
            selected=get(obj.h_channels_for_interpolation_list,'Value');
            st=get(obj.h_channels_for_interpolation_list,'String');
            option.channels_for_interpolation_list=st(selected);
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_channel_to_interpolate,'String',option.channel_to_interpolate);
            set(obj.h_channel_to_interpolate,'value',1);
            
            set(obj.h_channels_for_interpolation_list,'String',option.channels_for_interpolation_list);
            set(obj.h_channels_for_interpolation_list,'value',1:length(option.channels_for_interpolation_list));
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            
            frag_code=[frag_code,'''channel_to_interpolate'',''',...
                strrep(option.channel_to_interpolate,'''',''''''),''','];
            
            frag_code=[frag_code,'''channels_for_interpolation_list'',{{'];
            for k=1:length(option.channels_for_interpolation_list)
                frag_code=[frag_code,'''',strrep(option.channels_for_interpolation_list{k},'''',''''''),''''];
                if k~=length(option.channels_for_interpolation_list)
                    frag_code=[frag_code,','];
                end
            end
            frag_code=[frag_code,'}},'];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function GUI_update(obj,batch_pre)
            channel_to_interpolate=get(obj.h_channel_to_interpolate,'String');
            if isempty(channel_to_interpolate)
                channel_to_interpolate_idx=[];
            else
                channel_to_interpolate_idx=channel_to_interpolate(get(obj.h_channel_to_interpolate,'Value'));
            end
            channels_for_interpolation_list=get(obj.h_channels_for_interpolation_list,'String');
            if isempty(channels_for_interpolation_list)
                channels_for_interpolation_idx=[];
            else
                channels_for_interpolation_idx=channels_for_interpolation_list(get(obj.h_channels_for_interpolation_list,'Value'));
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
            set(obj.h_channel_to_interpolate,'String',channel_labels);
            set(obj.h_channels_for_interpolation_list,'String',channel_labels);
            
            [~,idx,~] = intersect({lwdataset(1).header.chanlocs.labels},channel_labels,'stable');
            obj.chanlocs=lwdataset(1).header.chanlocs(idx);
            
            [~,~,idx] = intersect(channel_to_interpolate_idx,channel_labels,'stable');
            if isempty(idx)
                idx=1;
            end
            set(obj.h_channel_to_interpolate,'value',idx);
            [~,~,idx] = intersect(channels_for_interpolation_idx,channel_labels,'stable');
            set(obj.h_channels_for_interpolation_list,'value',idx);
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            channel_labels={header_in.chanlocs.labels};
            [~,channel_to_interpolate_idx] = intersect(channel_labels, option.channel_to_interpolate,'stable');
            [~,channels_for_interpolation_list_idx] = intersect(channel_labels, option.channels_for_interpolation_list,'stable');
            if isempty(channel_to_interpolate_idx)||isempty(channels_for_interpolation_list_idx)
                error('No corresponding reference channel is found');
            end
            option.channel_to_interpolate_idx=channel_to_interpolate_idx;
            option.channels_for_interpolation_list_idx=channels_for_interpolation_list_idx;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.channel_to_interpolate=[];
            option.channels_for_interpolation_list=[];
            option.suffix='chan_interp';
            option.is_save=0;
            option=CLW_check_input(option,{'channel_to_interpolate',...
                'channels_for_interpolation_list',...
                'suffix','is_save'},varargin);
            header=FLW_interpolate_channel.get_header(lwdata_in.header,option);
            data=lwdata_in.data;
            channel_to_interpolate_idx=header.history(end).option.channel_to_interpolate_idx;
            channels_for_interpolation_list_idx=header.history(end).option.channels_for_interpolation_list_idx;
            data(:,channel_to_interpolate_idx,:,:,:,:)=mean(data(:,channels_for_interpolation_list_idx,:,:,:,:),2);
            try
                rmfield(header.history(end).option,'channel_to_interpolate_idx');
            end
            try
                rmfield(header.history(end).option,'channels_for_interpolation_list_idx');
            end
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end