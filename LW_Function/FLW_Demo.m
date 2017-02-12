classdef FLW_Demo<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1_in_1_out)
        % 2 for the function with N_in_1_out, like merge, ANOVA
        % 3 for the function with 1_in_N_out, like segmentation_separate
        % 4 for the function with N_in_M_out, like math_multiple, t-test
        FLW_TYPE=1;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_Demo(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'Demo','demo',...
                'Just make a demo for how to the FLW file.');
            %to be edited...
            
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
        %      option=struct('suffix','demo','is_save',1);
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
            
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.suffix='demo';
            option.is_save=0;
            option=CLW_check_input(option,{'suffix','is_save'},varargin);
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