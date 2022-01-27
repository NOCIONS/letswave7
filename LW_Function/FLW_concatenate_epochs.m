classdef FLW_concatenate_epochs<CLW_generic
    properties
        FLW_TYPE=1;
    end
    
    methods
        function obj = FLW_concatenate_epochs(batch_handle)
            obj@CLW_generic(batch_handle,'concat epoch','concat',...
                'Concatenate epochs.');
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
            dur=header_in.datasize(6)*header_in.xstep;
            header_out=header_in;
            header_out.datasize(6)=header_in.datasize(6)*header_in.datasize(1);
            header_out.datasize(1)=1;
            if isfield(header_out,'events')
                events=header_out.events;
                for k=1:length(events)
                    events(k).latency=events(k).latency+dur*(events(k).epoch-1);
                    events(k).epoch=1;
                end
                header_out.events=events;
            end

            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.suffix='concat';
            option.is_save=0;
            option=CLW_check_input(option,{'suffix','is_save'},varargin);
            header=FLW_concatenate_epochs.get_header(lwdata_in.header,option);
            option=header.history(end).option;
            data=permute(lwdata_in.data,[7,2,3,4,5,6,1]);
            data=data(:,:,:,:,:,:);
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end