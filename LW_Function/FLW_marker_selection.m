classdef FLW_marker_selection<CLW_generic
    properties
        FLW_TYPE=1;
        h_code_list;
        h_code_btn;
        h_x_start_edit;
        h_x_end_edit;
        h_in_out_group;
        h_in_radio;
        h_out_radio;
    end
    methods
        function obj = FLW_marker_selection(batch_handle)
            obj@CLW_generic(batch_handle,'maker_sel','mksel',...
                'Selection markers with the corresponding markers.');            
            
            uicontrol('style','text','position',[5,500,200,20],...
                'string','Event codes:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_code_list=uicontrol('style','listbox','string',{},...
                'value',[],'max',2,'position',[5,183,200,320],...
                'parent',obj.h_panel);
            obj.h_code_btn=uicontrol('style','pushbutton',...
                'String','Select All','position',[5,130,200,50],...
                'parent',obj.h_panel,'callback',@obj.select_All);
            
            uicontrol('style','text','position',[230,430,200,20],...
                'string','Epoch start:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_x_start_edit=uicontrol('style','edit',...
                'position',[230,400,180,30],'HorizontalAlignment','left',...
                'string','0','parent',obj.h_panel);
            
            uicontrol('style','text','position',[230,350,200,20],...
                'string','Epoch end:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_x_end_edit=uicontrol('style','edit',...
                'position',[230,320,180,30],'HorizontalAlignment','left',...
                'string','1','parent',obj.h_panel);
            
            obj.h_in_out_group=uibuttongroup('Units','pixels','Position',[230,460,180,30],...
                'BorderWidth',0,'parent',obj.h_panel);
            obj.h_in_radio=uicontrol('style','radiobutton','string','include    /',...
                'position',[2,2,100,30],'parent',obj.h_in_out_group);
            obj.h_out_radio=uicontrol('style','radiobutton','string','exclude',...
                'position',[92,2,100,30],'parent',obj.h_in_out_group);
            
            set(obj.h_code_list,'backgroundcolor',[1,1,1]);
            set(obj.h_x_start_edit,'backgroundcolor',[1,1,1]);
            set(obj.h_x_end_edit,'backgroundcolor',[1,1,1]);
        end
        
        function select_All(obj,varargin)
            str=get(obj.h_code_list,'String');
            if ~isempty(str)
                set(obj.h_code_list,'value',1:length(str));
            end
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            str=get(obj.h_code_list,'String');
            str_value=get(obj.h_code_list,'value');
            option.event_labels=str(str_value);
            option.x_start=str2num(get(obj.h_x_start_edit,'string'));
            option.x_end=str2num(get(obj.h_x_end_edit,'string'));
            option.is_include=get(obj.h_in_radio,'value');
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            event_labels=cellstr(option.event_labels);
            set(obj.h_code_list,'String',event_labels);
            set(obj.h_code_list,'value',1:length(event_labels));
            set(obj.h_x_start_edit,'string',num2str(option.x_start));
            set(obj.h_x_end_edit,'string',num2str(option.x_end));
            set(obj.h_in_radio,'value',num2str(option.is_include));
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''event_labels'',{{'];
            for k=1:length(option.event_labels)
                frag_code=[frag_code,'''',option.event_labels{k},''''];
                if k~=length(option.event_labels)
                    frag_code=[frag_code,','];
                end
            end
            frag_code=[frag_code,'}},'];
            frag_code=[frag_code,'''x_start'',',num2str(option.x_start),','];
            frag_code=[frag_code,'''x_end'',',num2str(option.x_end),','];
            frag_code=[frag_code,'''is_include'',',num2str(option.is_include),','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function GUI_update(obj,batch_pre)
            lwdataset=batch_pre.lwdataset;
            str=get(obj.h_code_list,'String');
            str_value=get(obj.h_code_list,'value');
            str_selected=str(str_value);
            st=sort(unique({lwdataset(1).header.events.code}));
            for dataset_pos=2:length(lwdataset)
                st= intersect(st,{lwdataset(dataset_pos).header.events.code});
            end
            if isempty(st)
                error('***No common event code in the datasets.***')
            end
            set(obj.h_code_list,'String',st);
            [~,idx] = intersect(st,str_selected,'stable');
            set(obj.h_code_list,'value',idx);
            if isempty(idx)&& ~isempty(st)
                set(obj.h_code_list,'value',1);
            end
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},...
                'ForegroundColor','black');
        end   
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            events_in=header_in.events;
            if isempty(events_in)
                error(['***No events in dataset ',header_in.name,'***']);
            end
            event_idx=[];
            for event_labels_pos=1:length(option.event_labels)
                event_idx=[event_idx,find(strcmp({events_in.code},...
                    option.event_labels{event_labels_pos}))];
            end
            latency=[events_in(event_idx).latency];
            event_idx=event_idx(latency>option.x_start & latency<option.x_end);
            
            if option.is_include==0
                event_idx=setdiff(1:length(events_in),event_idx);
            end
            if isempty(event_idx)
                error(['***event code ''',...
                    strjoin(option.event_labels,''', '''), ...
                    ''' can not found in dataset ',header_in.name,'***']);
            end
            epoch_idx=unique([events_in(event_idx).epoch]);
            
            header_out=header_in;
            header_out.datasize(1)=epoch_pos;%length(events_out);
            header_out.datasize(6)=dxsize;
            header_out.xstart=option.x_start;
            header_out.events=events_out;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function='FLW_marker_selection';
            header_out.history(end+1).option=option;            
        end
        
        function lwdata_out= get_lwdata(lwdata_in,varargin)
            option.event_labels=[];
            option.x_start=0;
            option.x_end=1;
            option.suffix='ep';
            option.is_save=0;
            option=CLW_check_input(option,{'event_labels','x_start','x_end','x_duration','suffix','is_save'},varargin);
            
            if ~isfield(option,'x_duration')
                option.x_end=option.x_end-option.x_end;
            end
            
            if isempty(option.event_labels)
                error('***No event codes selected!***');
            end
            option.event_labels=cellstr(option.event_labels);
            
            header= FLW_segmentation.get_header(lwdata_in.header,option);
            data=zeros(header.datasize);
            if header.datasize(1)==0
                disp(['event code ''',strjoin(option.event_labels,''', '''), ''' can not found in dataset ',lwdata_in.header.name]);
            else
                events_in=lwdata_in.header.events;
                event_idx=[];
                for event_labels_pos=1:length(option.event_labels)
                    event_idx=[event_idx,find(strcmp({events_in.code},option.event_labels{event_labels_pos}))];
                end
                latency=[events_in(event_idx).latency];
                event_idx=event_idx(latency+option.x_start>=lwdata_in.header.xstart...
                    &latency+option.x_start+option.x_duration-lwdata_in.header.xstep<=...
                    lwdata_in.header.xstart+lwdata_in.header.xstep*lwdata_in.header.datasize(6));
            
                dxsize=fix((option.x_duration)/lwdata_in.header.xstep);
                epoch_pos=0;
                for k=event_idx
                    dx1=fix((((events_in(k).latency+option.x_start)-lwdata_in.header.xstart)/lwdata_in.header.xstep))+1;
                    dx2=(dx1+dxsize)-1;
                    if dx1<1 || dx2>lwdata_in.header.datasize(6)
                        continue;
                    end
                    epoch_pos=epoch_pos+1;
                    data(epoch_pos,:,:,:,:,:)=lwdata_in.data(events_in(k).epoch,:,:,:,:,dx1:dx2);
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