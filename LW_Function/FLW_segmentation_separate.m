classdef FLW_segmentation_separate<CLW_generic
    properties
        FLW_TYPE=3;
        h_code_list;
        h_code_btn;
        h_x_start_edit;
        h_x_end_edit;
        h_x_duration_edit;
    end
    methods
        function obj = FLW_segmentation_separate(batch_handle)
            obj@CLW_generic(batch_handle,'segmentation separate','ep',...
                'Segment the data into epochs. One file per event code');            
            set(obj.h_is_save_chx,'enable','off');           
            
            uicontrol('style','text','position',[5,490,200,20],...
                'string','Event codes','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_code_list=uicontrol('style','listbox','string',{},...
                'value',[],'max',2,'position',[5,190,200,300],...
                'parent',obj.h_panel);
            obj.h_code_btn=uicontrol('style','pushbutton',...
                'String','Select All','position',[5,130,200,50],...
                'parent',obj.h_panel,'callback',@obj.select_All);
            
           uicontrol('style','text','position',[230,430,200,20],...
                'string','Epoch start:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_x_start_edit=uicontrol('style','edit',...
                'position',[230,400,180,30],'HorizontalAlignment','left',...
                'string','0','parent',obj.h_panel,'callback',@obj.item_start_changed);
            
            uicontrol('style','text','position',[230,350,200,20],...
                'string','Epoch end:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_x_end_edit=uicontrol('style','edit',...
                'position',[230,320,180,30],'HorizontalAlignment','left',...
                'string','1','parent',obj.h_panel,'callback',@obj.item_start_changed);
            
            uicontrol('style','text','position',[230,270,200,20],...
                'string','Epoch duration:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_x_duration_edit=uicontrol('style','edit',...
                'position',[230,240,180,30],'HorizontalAlignment','left',...
                'string','1','parent',obj.h_panel,'callback',@obj.item_dur_changed);
            
            set(obj.h_code_list,'backgroundcolor',[1,1,1]);
            set(obj.h_x_start_edit,'backgroundcolor',[1,1,1]);
            set(obj.h_x_end_edit,'backgroundcolor',[1,1,1]);
            set(obj.h_x_duration_edit,'backgroundcolor',[1,1,1]);
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
            option.event_labels=cellstr(str(str_value)');
            option.x_start=str2num(get(obj.h_x_start_edit,'string'));
            option.x_end=str2num(get(obj.h_x_end_edit,'string'));
            option.x_duration=str2num(get(obj.h_x_duration_edit,'string'));
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            event_labels=cellstr(option.event_labels);
            set(obj.h_code_list,'String',event_labels);
            set(obj.h_code_list,'value',1:length(event_labels));
            set(obj.h_x_start_edit,'string',num2str(option.x_start));
            set(obj.h_x_end_edit,'string',num2str(option.x_end));
            set(obj.h_x_duration_edit,'string',num2str(option.x_duration));
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
            frag_code=[frag_code,'''x_duration'',',num2str(option.x_duration),','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function item_start_changed(obj,varargin)
            xstart=str2num(get(obj.h_x_start_edit,'string'));
            xend=str2num(get(obj.h_x_end_edit,'string'));
            set(obj.h_x_duration_edit,'string',num2str(xend-xstart));
        end
        
        function item_dur_changed(obj,varargin)
            x_duration=str2num(get(obj.h_x_duration_edit,'string'));
            xstart=str2num(get(obj.h_x_start_edit,'string'));
            set(obj.h_x_end_edit,'string',num2str(xstart+x_duration));
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
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
        
        function header_update(obj,batch_pre)
            obj.virtual_filelist=batch_pre.virtual_filelist;%??
            lwdataset=batch_pre.lwdataset;
            option=get_option(obj);
            obj.lwdataset=[];
            for data_pos=1:length(lwdataset)
                %obj.lwdataset=[obj.lwdataset, obj.get_headerset(lwdataset(data_pos).header,option)];
                %evalc is used to block the information in Command Window 
                evalc('obj.lwdataset=[obj.lwdataset, obj.get_headerset(lwdataset(data_pos).header,option)];');
            end
            if option.is_save
                for data_pos=1:length(obj.lwdataset)
                    obj.virtual_filelist(end+1)=struct(...
                        'filename',obj.lwdataset(data_pos).header.name,...
                        'header',obj.lwdataset(data_pos).header);
                end
            end
        end
                
    end
    
    methods (Static = true)
        function lwdataset_out= get_headerset(header_in,option)
            lwdataset_out=[];
            for event_labels=option.event_labels
                option1=option;
                option1.event_labels=event_labels;
                if isempty(option1.suffix)
                    option1.suffix=char(option1.event_labels);
                else
                    option1.suffix=[option1.suffix,'_',char(option1.event_labels)];
                end
                lwdataset_out(end+1).header=FLW_segmentation.get_header(header_in,option1);
            end
        end
        
        function lwdataset_out= get_lwdataset(lwdata_in,varargin)
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
            
            lwdataset_out=struct('header',[],'data',[]);
            for k=1:size(option.event_labels,2)
                event_labels=option.event_labels(k);
                option1=option;
                option1.event_labels=event_labels;
                if isempty(option1.suffix)
                    option1.suffix=char(option1.event_labels);
                else
                    option1.suffix=[option1.suffix,'_',char(option1.event_labels)];
                end
                lwdataset_out(k)=FLW_segmentation.get_lwdata(lwdata_in,option1);
            end
        end
    end
end