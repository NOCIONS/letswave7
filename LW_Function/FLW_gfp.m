classdef FLW_gfp<CLW_generic
    properties
        FLW_TYPE=1;
    end
    
    methods
        function obj = FLW_gfp(batch_handle)
            obj@CLW_generic(batch_handle,'gfp','gfp',...
                'Compute the global field power.');
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
            channel_labels={header_in.chanlocs.labels};
            header_out.datasize(2)=1;
            header_out.chanlocs(end+1).labels='GFP';
            header_out.chanlocs=header_out.chanlocs(end);
            
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.suffix='gfp';
            option.is_save=0;
            option=CLW_check_input(option,{'suffix','is_save'},varargin);
            header=FLW_gfp.get_header(lwdata_in.header,option);
            data=sqrt(var(lwdata_in.data,1,2));
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end