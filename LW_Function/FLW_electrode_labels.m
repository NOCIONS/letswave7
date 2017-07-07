classdef FLW_electrode_labels<CLW_generic
    properties
        FLW_TYPE=1;
        h_lable_tab;
        h_load_btn;
        h_load_lw_btn;
        h_save_btn;
        h_clear_btn;
        h_not_equal_txt;
    end
    
    methods
        function obj = FLW_electrode_labels(batch_handle)
            obj@CLW_generic(batch_handle,'chan labels','chanlabels',...
                'Edit electrode labels');
            obj.h_lable_tab=uitable(obj.h_panel,'position',[25,140,210,370],'data',{'F1',''});
            set(obj.h_lable_tab,'ColumnName', {'Old','New'});
            set(obj.h_lable_tab,'ColumnEditable', logical([0,1]));
            
            obj.h_load_btn=uicontrol('parent',obj.h_panel,...
                'style','pushbutton','string','Load CSV file','position',[240,477,170,35]);
            obj.h_save_btn=uicontrol('parent',obj.h_panel,...
                'style','pushbutton','string','Save CSV file','position',[240,437,170,35]);
            obj.h_load_lw_btn=uicontrol('parent',obj.h_panel,...
                'style','pushbutton','string','Load .lw6 file','position',[240,397,170,35]);
            obj.h_clear_btn=uicontrol('parent',obj.h_panel,...
                'style','pushbutton','string','clear','position',[240,357,170,35]);
            
            obj.h_not_equal_txt=uicontrol('style','text','visible','off',...
                'position',[0,125,400,20],'foregroundcolor',[1,0,0],...
                'string','The datasets share different channel property.',...
                'HorizontalAlignment','center','parent',obj.h_panel);
            
            set(obj.h_load_btn,'callback',@obj.load_csv);
            set(obj.h_save_btn,'callback',@obj.save_csv);
            set(obj.h_load_lw_btn,'callback',@obj.load_header);
            set(obj.h_clear_btn,'callback',@obj.clear_data);
        end
        
        function load_csv(obj,varargin)
            [filename,pathname]=uigetfile({'*.*'});
            if ~isequal(filename,0)
                st=csvimport([pathname filename]);
                data=get(obj.h_lable_tab,'data');
                for k=1:min(length(st),size(data,1))
                    if ~strcmp(data{k,1},st{k})
                        data{k,2}=st{k};
                    end
                end
                set(obj.h_lable_tab,'data',data);
            end
        end
        
        function save_csv(obj,varargin)
            [filename,pathname]=uiputfile({'*.*'});
            if ~isequal(filename,0)
                disp(['Saving : ' pathname filename]);
                data=get(obj.h_lable_tab,'data');
                st=data(:,1);
                st{end+1}='';
                cell2csv([pathname filename],st);
            end
        end
        
        function load_header(obj,varargin)
            [filename,pathname]=uigetfile({'*.lw6'});
            if ~isequal(filename,0)
                header=CLW_load_header([pathname filename]);
                for i=1:length(header.chanlocs)
                    st{i}=header.chanlocs(i).labels;
                end
                data=get(obj.h_lable_tab,'data');
                for k=1:min(length(st),size(data,1))
                    if ~strcmp(data{k,1},st{k})
                        data{k,2}=st{k};
                    end
                end
                set(obj.h_lable_tab,'data',data);
            end
        end
        
        function clear_data(obj,varargin)
            data=get(obj.h_lable_tab,'data');
            for k=1:size(data,1)
                data{k,2}='';
            end
            set(obj.h_lable_tab,'data',data);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            data=get(obj.h_lable_tab,'data');
            idx=find(~strcmp(data(:,2),''));
            option.old_channel=data(idx,1);
            option.new_channel=data(idx,2);
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            for k=1:size(option.old_channel,1)
                data{k,1}=option.old_channel{k};
                data{k,2}=option.new_channel{k};
            end
            set(obj.h_lable_tab,'data',data);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            %%%
            frag_code=[frag_code,'''old_channel'',{{'];
            for k=1:length(option.old_channel)
                frag_code=[frag_code,'''',strrep(option.old_channel{k},'''',''''''),''''];
                if k~=length(option.old_channel)
                    frag_code=[frag_code,','];
                end
            end
            frag_code=[frag_code,'}},']; 
            
            frag_code=[frag_code,'''new_channel'',{{'];
            for k=1:length(option.new_channel)
                frag_code=[frag_code,'''',strrep(option.new_channel{k},'''',''''''),''''];
                if k~=length(option.new_channel)
                    frag_code=[frag_code,','];
                end
            end
            frag_code=[frag_code,'}},']; 
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function GUI_update(obj,batch_pre)
            option=obj.get_option();
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
            data(:,1)=channel_labels;
            for k=1:size(data(:,1),1)
                idx=find(strcmp(data(k,1),option.old_channel), 1);
                if isempty(idx)
                    data{k,2}='';
                else
                    data{k,2}=option.new_channel{idx};
                end
            end
            set(obj.h_lable_tab,'data',data);
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
            
            [~,idx1] = intersect({header_in.chanlocs.labels}, option.old_channel,'stable');
            [~,idx2] = intersect(option.old_channel,{header_in.chanlocs.labels}, 'stable');
            for k=1:length(idx1)
                header_out.chanlocs(idx1(k)).labels=option.new_channel{idx2(k)};
            end
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.old_channel={};
            option.new_channel={};
            option.suffix='chanlabels';
            option.is_save=0;
            option=CLW_check_input(option,{'old_channel','new_channel','suffix','is_save'},varargin);
            
            lwdata_out.header=FLW_electrode_labels.get_header(lwdata_in.header,option);
            lwdata_out.data=lwdata_in.data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end