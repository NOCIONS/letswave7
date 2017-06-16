classdef FLW_rereference<CLW_generic
    properties
        FLW_TYPE=1;
        h_reference_list;
        h_reference_btn;
        h_apply_list;
        h_apply_btn;
        h_not_equal_txt;
    end
    
    methods
        function obj = FLW_rereference(batch_handle)
            obj@CLW_generic(batch_handle,'rereference','reref',...
                'Make a rereference for dataset.');
            uicontrol('style','text','position',[35,495,150,20],...
                'string','New reference:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_reference_list=uicontrol('style','listbox','min',0,'max',2,...
                'position',[35,175,150,320],'parent',obj.h_panel);
            obj.h_reference_btn=uicontrol('style','pushbutton',...
                'string','Select All','callback',@obj.reference_Callback,...
                'position',[35,141,150,35],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[235,495,150,20],...
                'string','Apply reference to:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_apply_list=uicontrol('style','listbox','min',0,'max',2,...
                'position',[235,175,150,320],'parent',obj.h_panel);
            obj.h_apply_btn=uicontrol('style','pushbutton',...
                'string','Select All','callback',@obj.apply_Callback,...
                'position',[235,141,150,35],'parent',obj.h_panel);
            obj.h_not_equal_txt=uicontrol('style','text','visible','off',...
                'position',[0,125,400,20],'foregroundcolor',[1,0,0],...
                'string','The datasets share different channel property.',...
                'HorizontalAlignment','center','parent',obj.h_panel);
            
            set(obj.h_reference_list,'backgroundcolor',[1,1,1]);
            set(obj.h_apply_list,'backgroundcolor',[1,1,1]);
        end
        
        function reference_Callback(obj,varargin)
            st=get(obj.h_reference_list,'String');
            set(obj.h_reference_list,'Value',1:length(st));
        end
        
        function apply_Callback(obj,varargin)
            st=get(obj.h_apply_list,'String');
            set(obj.h_apply_list,'Value',1:length(st));
        end       
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            selected=get(obj.h_reference_list,'Value');
            st=get(obj.h_reference_list,'String');
            option.reference_list=st(selected);
            selected=get(obj.h_apply_list,'Value');
            st=get(obj.h_apply_list,'String');
            option.apply_list=st(selected);
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_reference_list,'String',option.reference_list);
            set(obj.h_reference_list,'value',1:length(option.reference_list));
%           
            set(obj.h_apply_list,'String',option.apply_list);
            set(obj.h_apply_list,'value',1:length(option.apply_list));
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            
            frag_code=[frag_code,'''reference_list'',{{'];
            for k=1:length(option.reference_list)
                frag_code=[frag_code,'''',strrep(option.reference_list{k},'''',''''''),''''];
                if k~=length(option.reference_list)
                    frag_code=[frag_code,','];
                end
            end
            frag_code=[frag_code,'}},'];            
            
            frag_code=[frag_code,'''apply_list'',{{'];
            for k=1:length(option.apply_list)
                frag_code=[frag_code,'''',strrep(option.apply_list{k},'''',''''''),''''];
                if k~=length(option.apply_list)
                    frag_code=[frag_code,','];
                end
            end
            frag_code=[frag_code,'}},'];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function GUI_update(obj,batch_pre)
            reference_list=get(obj.h_reference_list,'String');
            if isempty(reference_list)
                reference_idx=[];
            else
                reference_idx=reference_list(get(obj.h_reference_list,'Value'));
            end
            apply_list=get(obj.h_apply_list,'String');
            if isempty(apply_list)
                apply_idx=[];
            else
                apply_idx=apply_list(get(obj.h_apply_list,'Value'));
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
            set(obj.h_reference_list,'String',channel_labels);
            set(obj.h_apply_list,'String',channel_labels);
            
            
            [~,~,idx] = intersect(reference_idx,channel_labels,'stable');
            set(obj.h_reference_list,'value',idx);
            [~,~,idx] = intersect(apply_idx,channel_labels,'stable');
            set(obj.h_apply_list,'value',idx);
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            channel_labels={header_in.chanlocs.labels};
            [~,reference_idx] = intersect(channel_labels, option.reference_list,'stable');
            [~,apply_idx] = intersect(channel_labels, option.apply_list,'stable');
            if isempty(reference_idx)||isempty(apply_idx)
                error('No corresponding reference channel is found');
            end
            option.reference_idx=reference_idx;
            option.apply_idx=apply_idx;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.reference_list=[];
            option.apply_list=[];
            option.suffix='reref';
            option.is_save=0;
            option=CLW_check_input(option,{'reference_list','apply_list',...
                'suffix','is_save'},varargin);
            header=FLW_rereference.get_header(lwdata_in.header,option);
            data=lwdata_in.data;
            reference_idx=header.history(end).option.reference_idx;
            apply_idx=header.history(end).option.apply_idx;
            refdata=mean(data(:,reference_idx,:,:,:,:),2);
            data(:,apply_idx,:,:,:,:)=data(:,apply_idx,:,:,:,:)-...
                refdata(:,ones(length(apply_idx),1),:,:,:,:);
            try
                rmfield(header.history(end).option,'reference_idx');
            end
            try
                rmfield(header.history(end).option,'apply_idx');
            end
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end