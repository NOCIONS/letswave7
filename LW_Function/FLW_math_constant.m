classdef FLW_math_constant<CLW_generic
    properties
        FLW_TYPE=1;
        h_operation_pop;
        h_constant_txt;
        h_constant_edt;
        h_log_pop;
    end
    
    methods
        function obj = FLW_math_constant(batch_handle)
            obj@CLW_generic(batch_handle,'math constant','add_c',...
                'Compute simple mathematical operations using one dataset and a constant value.');
            
            uicontrol('style','text','position',[35,470,200,20],...
                'string','Operation:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_operation_pop=uicontrol('style','popupmenu',...
                'String',{'Add (A+constant)','Subtract (A-constant)','Multiple (A*constant)',...
                'Divide (A/constant)','Power (A^constant)','Opposite number (-A)','Absolute value (|A|)','logarithm (log(A))'},...
                 'backgroundcolor',[1,1,1],'value',1,'callback',@obj.method_change,...
                 'position',[35,440,300,30],'parent',obj.h_panel);
            
            obj.h_constant_txt=uicontrol('style','text','position',[35,410,150,19],...
                'string','Constant:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_constant_edt=uicontrol('style','edit','backgroundcolor',[1,1,1],...
                'String','1','position',[40,390,100,19],'parent',obj.h_panel);
            obj.h_log_pop=uicontrol('style','popupmenu','backgroundcolor',[1,1,1],...
                'value',1,'String',{'log -Natural logarithm',...
                'log2 -Base 2 logarithm','log10 -Base 10 logarithm'},...
                'position',[35,390,200,19],'parent',obj.h_panel,...
                'callback',@obj.method_change,'visible','off');
            
        end
         
        function method_change(obj,varargin)
            index=get(obj.h_operation_pop,'value');
            if index<6
                set(obj.h_constant_txt,'enable','on');
                set(obj.h_constant_edt,'enable','on');
            else
                set(obj.h_constant_txt,'enable','off');
                set(obj.h_constant_edt,'enable','off');
            end
            
            if index==8
                set(obj.h_log_pop,'visible','on');
            else
                set(obj.h_log_pop,'visible','off');
            end
            
            
            str=get(obj.h_suffix_edit,'string');
            if sum(strcmp(str,{'add_c','sub_c','mul_c','div_c','pow_c','opp','abs','log','log2','log10'}))==1
                switch(index)
                    case 1
                        set(obj.h_suffix_edit,'string','add_c');
                    case 2
                        set(obj.h_suffix_edit,'string','sub_c');
                    case 3
                        set(obj.h_suffix_edit,'string','mul_c');
                    case 4
                        set(obj.h_suffix_edit,'string','div_c');
                    case 5
                        set(obj.h_suffix_edit,'string','pow_c');
                    case 6
                        set(obj.h_suffix_edit,'string','opp');
                    case 7
                        set(obj.h_suffix_edit,'string','abs');
                    case 8
                        temp=get(obj.h_log_pop,'value');
                        switch(temp)
                            case 1
                        set(obj.h_suffix_edit,'string','log');
                            case 2
                        set(obj.h_suffix_edit,'string','log2');
                            case 3
                        set(obj.h_suffix_edit,'string','log10');
                        end
                end
            end
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            idx=get(obj.h_operation_pop,'value');
            switch(idx)
                case 1
                    option.operation='add';
                case 2
                    option.operation='sub';
                case 3
                    option.operation='mul';
                case 4
                    option.operation='div';
                case 5
                    option.operation='pow';
                case 6
                    option.operation='opp';
                case 7
                    option.operation='abs';
                case 8
                    option.operation='log';
            end
            if idx==8
                option.value=get(obj.h_log_pop,'value');
            else
                option.value=str2num(get(obj.h_constant_edt,'string'));
            end
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            switch option.operation
                case 'add'
                    set(obj.h_operation_pop,'value',1);
                case 'sub'
                    set(obj.h_operation_pop,'value',2);
                case 'mul'
                    set(obj.h_operation_pop,'value',3);
                case 'div'
                    set(obj.h_operation_pop,'value',4);
                case 'pow'
                    set(obj.h_operation_pop,'value',5);
                case 'opp'
                    set(obj.h_operation_pop,'value',6);
                case 'abs'
                    set(obj.h_operation_pop,'value',7);
                case 'log'
                    set(obj.h_operation_pop,'value',8);
                case 'log2'
                    set(obj.h_operation_pop,'value',8);
                case 'log10'
                    set(obj.h_operation_pop,'value',8);
            end
            
            if get(obj.h_operation_pop,'value')
                set(obj.h_log_pop,'value',option.value);
                set(obj.h_log_pop,'visible','on');
            else
                set(obj.h_constant_edt,'string',num2str(option.value));
                set(obj.h_log_pop,'visible','off');
            end
            
            
            if option.operation<6
                set(obj.h_constant_txt,'enable','on');
                set(obj.h_constant_edt,'enable','on');
            else
                set(obj.h_constant_txt,'enable','off');
                set(obj.h_constant_edt,'enable','off');
            end
            
            str=get(obj.h_suffix_edit,'string');
            if sum(strcmp(str,{'add_c','sub_c','mul_c','div_c','pow_c','opp','abs','log','log2','log10'}))==1
                switch(get(obj.h_operation_pop,'value'))
                    case 1
                        set(obj.h_suffix_edit,'string','add_c');
                    case 2
                        set(obj.h_suffix_edit,'string','sub_c');
                    case 3
                        set(obj.h_suffix_edit,'string','mul_c');
                    case 4
                        set(obj.h_suffix_edit,'string','div_c');
                    case 5
                        set(obj.h_suffix_edit,'string','pow_c');
                    case 6
                        set(obj.h_suffix_edit,'string','opp');
                    case 7
                        set(obj.h_suffix_edit,'string','abs');
                    case 8
                        temp=get(obj.h_log_pop,'value');
                        switch(temp)
                            case 1
                                set(obj.h_suffix_edit,'string','log');
                            case 2
                                set(obj.h_suffix_edit,'string','log2');
                            case 3
                                set(obj.h_suffix_edit,'string','log10');
                        end
                end
            end
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''operation'',''',option.operation,''','];
            frag_code=[frag_code,'''value'',',num2str(option.value),','];
            str=get_Script@CLW_generic(obj,frag_code,option);
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
            option.filter_type='add';
            option.value=1;
            option.suffix='add_c';
            option.is_save=0;
            option=CLW_check_input(option,{'operation','value','suffix','is_save'},varargin);
            
            header=FLW_math_constant.get_header(lwdata_in.header,option);
            data=lwdata_in.data;
            switch option.operation
                case 'add'
                    data=data+option.value;
                case 'sub'
                    data=data-option.value;
                case 'mul'
                    data=data*option.value;
                case 'div'
                    data=data/option.value;
                case 'pow'
                    data=data.^option.value;
                case 'opp'
                    data=-data;
                case 'abs'
                    data=abs(data);
                case 'log'
                    switch option.value
                        case 1
                            data=log(data);
                        case 2
                            data=log2(data);
                        case 3
                            data=log10(data);
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