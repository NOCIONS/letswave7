classdef FLW_arrange<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Nout, like math_multiple
        FLW_TYPE=1;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_arrange(tabgp)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,affix_name,help_str)
            obj@CLW_generic(tabgp,'Arrange','arrange',...
                'Arrange the signal by channel/epoch/index.');
            uicontrol('style','text','position',[35,520,200,20],...
                'string','Arrange Items:','HorizontalAlignment','left',...
                'parent',obj.h_tab);
            obj.h_arrange_items_pop=uicontrol('style','popupmenu',...
                'String',{'epoch','channel','index'},...
                'callback',@obj.item_Changed,'position',[35,490,150,30],...
                'parent',obj.h_tab);
            
        end
        
         function item_Changed(obj,varargin)
            st_value=get(obj.h_arrange_items_pop,'value');
            str=get(obj.h_affix_edit,'string');
            if sum(strcmp(str,{'sel_epoch','sel_channel','sel_index'}))
                switch(st_value)
                    case 1
                        set(obj.h_affix_edit,'string','sel_epoch');
                    case 2
                        set(obj.h_affix_edit,'string','sel_channel');
                    case 3
                        set(obj.h_affix_edit,'string','sel_index');
                end
            end
        end
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            %to be edited...
            
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            %to be edited...
            
        end
        
        %get the script for this operation
        %run this function, normally we will get a script 
        %with two lines as following 
        %      option=struct('affix','demo','is_save',1);
        %      lwdata= FLW_Demo.get_lwdata(lwdata,option);
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            %to be edited...
            
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            %to be edited...
            
            if ~isempty(option.affix)
                header_out.name=[option.affix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.affix='demo';
            option.is_save=0;
            option=CLW_check_input(option,{'affix','is_save'},varargin);
            header=FLW_Demo.get_header(lwdata_in.header,option);
            
            data=lwdata_in.data;
            %to be edited...
            
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end