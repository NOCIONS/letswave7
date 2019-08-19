classdef FLW_average_epochs<CLW_generic
    properties
        FLW_TYPE=1;
        h_method_pop;
    end
    methods
        function obj = FLW_average_epochs(batch_handle)
            obj@CLW_generic(batch_handle,'average_epoch','avg',...
                'Get the average/stdev/median of the data.');
            
            uicontrol('style','text','position',[35,470,200,20],...
                'string','Operation','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_method_pop=uicontrol('style','popupmenu',...
                'String',{'average','stdev','median'},'value',1,...
                'backgroundcolor',1*[1,1,1],'callback',@obj.item_Changed,...
                'position',[35,440,150,30],'parent',obj.h_panel);
        end
        
        function item_Changed(obj,varargin)
            st_value=get(obj.h_method_pop,'value');
            str=get(obj.h_suffix_edit,'string');
            if sum(strcmp(str,{'avg','std','median'}))
                switch(st_value)
                    case 1
                        set(obj.h_suffix_edit,'string','avg');
                    case 2
                        set(obj.h_suffix_edit,'string','std');
                    case 3
                        set(obj.h_suffix_edit,'string','median');
                end
            end
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            str=get(obj.h_method_pop,'String');
            str_value=get(obj.h_method_pop,'value');
            option.operation=str{str_value};
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            switch option.operation
                case 'average'
                    set(obj.h_method_pop,'value',1);
                case 'stdev'
                    set(obj.h_method_pop,'value',2);
                case 'median'
                    set(obj.h_method_pop,'value',3);
            end
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''operation'',''',option.operation,''','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            header_out.datasize(1)=1;
            if~isempty(header_out.events)
                [header_out.events.epoch]=deal(1);
            end
            header_out=CLW_events_duplicate_check(header_out);
            if isfield(header_out,'epochdata');
                header_out=rmfield(header_out,'epochdata');
            end
            
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.operation='average';
            option.suffix='avg';
            option.is_save=0;
            option=CLW_check_input(option,{'operation','suffix','is_save'},varargin);
            header=FLW_average_epochs.get_header(lwdata_in.header,option);
            data=zeros(header.datasize);
            switch option.operation
                case 'stdev'
                    data(1,:,:,:,:,:)=std(lwdata_in.data,0,1);
                case 'median'
                    data(1,:,:,:,:,:)=median(lwdata_in.data,1);
                otherwise
                    data(1,:,:,:,:,:)=mean(lwdata_in.data,1);
            end
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end