classdef FLW_average_epochs<CLW_generic
    properties
        FLW_TYPE=1;
            
        h_method_pop;
    end
    methods
        function obj = FLW_average_epochs(tabgp)
            obj@CLW_generic(tabgp,'average','avg',...
                'Get the average/stdev/median of the data.');
            
            uicontrol('style','text','position',[35,520,200,20],...
                'string','Operation','HorizontalAlignment','left',...
                'parent',obj.h_tab);
            obj.h_method_pop=uicontrol('style','popupmenu',...
                'String',{'average','stdev','median'},'value',1,...
                'position',[35,490,150,30],'parent',obj.h_tab);
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
            [header_out.events.epoch]=deal(1);
            header_out=CLW_events_duplicate_check(header_out);
            if isfield(header_out,'epochdata');
                header_out=rmfield(header_out,'epochdata');
            end
            
            if ~isempty(option.affix)
                header_out.name=[option.affix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.operation='average';
            option.affix='avg';
            option.is_save=0;
            option=CLW_check_input(option,{'operation','affix','is_save'},varargin);
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