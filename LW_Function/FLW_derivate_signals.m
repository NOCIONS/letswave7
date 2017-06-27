classdef FLW_derivate_signals<CLW_generic
    properties
        FLW_TYPE=1;
    end
    
    methods
        function obj = FLW_derivate_signals(batch_handle)
            obj@CLW_generic(batch_handle,'derived','deriv',...
                ['Compute the signal derivative. The derivative ',...
                'is computed by subtracting from each sample of the',...
                ' dataset the value measured at the preceding sample ',...
                'of the dataset (y_i=x_i-x_{i-1}).']);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            header_out.datasize(6)=header_out.datasize(6)-1;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.suffix='deriv';
            option.is_save=0;
            option=CLW_check_input(option,{'suffix','is_save'},varargin);
            
            header=FLW_derivate_signals.get_header(lwdata_in.header,option);
            option=header.history(end).option;
            data=lwdata_in.data;
            data=data(:,:,:,:,:,2:end)-data(:,:,:,:,:,1:end-1);
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end