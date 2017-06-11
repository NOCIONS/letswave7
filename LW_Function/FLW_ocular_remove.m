classdef FLW_ocular_remove<CLW_generic
    properties
        FLW_TYPE=1;
        h_channel_list;
        h_not_equal_txt
    end
    
    methods
        function obj = FLW_ocular_remove(batch_handle)
            obj@CLW_generic(batch_handle,'ocular_rm','oc_rm',...
                'remove the ocular artifact by the tranditional method (Gratton, Coles, and Donchin, 1983).');
            obj.h_channel_list=uicontrol('style','listbox','min',0,'max',2,...
                'position',[110,140,140,360],'parent',obj.h_panel); 
            uicontrol('style','text','position',[105,500,200,20],...
                'string','Select the ocular to channel:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_not_equal_txt=uicontrol('style','text','visible','off',...
                'position',[0,125,400,20],'foregroundcolor',[1,0,0],...
                'string','The datasets share different channel property.',...
                'HorizontalAlignment','center','parent',obj.h_panel);
            set(obj.h_channel_list,'backgroundcolor',[1,1,1]);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            channel_list=get(obj.h_channel_list,'String');
            option.ocular_channel=channel_list(get(obj.h_channel_list,'Value'));
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_channel_list,'String',option.ocular_channel);
            set(obj.h_channel_list,'value',1:length(option.ocular_channel));
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            
            frag_code=[frag_code,'''ocular_channel'',{{'];
            for k=1:length(option.ocular_channel)
                frag_code=[frag_code,'''',strrep(option.ocular_channel{k},'''',''''''),''''];
                if k~=length(option.ocular_channel)
                    frag_code=[frag_code,','];
                end
            end
            frag_code=[frag_code,'}},'];    
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        
        function GUI_update(obj,batch_pre)
            channel_list=get(obj.h_channel_list,'String');
            if isempty(channel_list)
                channel_idx=[];
            else
                channel_idx=channel_list(get(obj.h_channel_list,'Value'));
            end
            
            lwdataset=batch_pre.lwdataset;
            channel_labels={lwdataset(1).header.chanlocs.labels};
            set(obj.h_not_equal_txt,'visible','off');
             for dataset_pos=2:length(lwdataset)
                channel_labels1={lwdataset(dataset_pos).header.chanlocs.labels};
                channel_labels2= intersect(channel_labels,channel_labels1,'stable');
                if length(channel_labels2)<length(channel_labels)
                    set(obj.h_not_equal_txt,'visible','on');
                end
                channel_labels=channel_labels2;
            end
            if isempty(channel_labels)
                error('***No common channels.***')
            end
            set(obj.h_channel_list,'String',channel_labels);
            
            [~,~,idx] = intersect(channel_idx,channel_labels,'stable');
            set(obj.h_channel_list,'value',idx);
            
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
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
            option.suffix='oc_rm';
            option.ocular_channel='';
            option.is_save=0;
            option=CLW_check_input(option,{'ocular_channel','suffix','is_save'},varargin);
            header=FLW_ocular_remove.get_header(lwdata_in.header,option);
            [~,channel_idx] = intersect({header.chanlocs.labels}, ...
                option.ocular_channel,'stable');
           
            if isempty(channel_idx)
                error('no ocular channel has been selected.');
            else
                data=lwdata_in.data;
                for k2=1:header.datasize(2)
                    y=reshape(data(:,k2,:,:,:,:),1,[]);
                    for ch_idx=1:length(channel_idx)
                        X(ch_idx,:)=reshape(lwdata_in.data(:,channel_idx(ch_idx),:,:,:,:),1,[]);
                    end
                    X(ch_idx+1,:)=1;
                    b = regress(y',X');
                    for ch_idx=1:length(channel_idx)
                        data(:,k2,:,:,:,:)=data(:,k2,:,:,:,:)-b(ch_idx)*lwdata_in.data(:,channel_idx(ch_idx),:,:,:,:);
                    end
                end
            end
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end