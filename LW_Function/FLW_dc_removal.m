classdef FLW_dc_removal<CLW_generic
    properties
        FLW_TYPE=1;
        h_dc_chx;
    end
    
    methods
        function obj = FLW_dc_removal(batch_handle)
            obj@CLW_generic(batch_handle,'dc removal','dc',...
                'Just make a dc_removal for how to the FLW file.');
            obj.h_dc_chx=uicontrol('style','checkbox',...
                'String','apply linear detrend in addition to DC removal','value',1,...
                'position',[35,440,300,30],'parent',obj.h_panel);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.linear_detrend=get(obj.h_dc_chx,'value');
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            get(h_dc_chx,'value',option.linear_detrend);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''linear_detrend'',',...
                num2str(option.linear_detrend),','];
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
            option.linear_detrend=0;
            option.suffix='dc';
            option.is_save=0;
            option=CLW_check_input(option,{'linear_detrend','suffix','is_save'},varargin);
            header=FLW_dc_removal.get_header(lwdata_in.header,option);
            
            data=lwdata_in.data;
            data=permute(data,[6,1,2,3,4,5]);
            if option.linear_detrend==1
                for k3=1:size(data,3)
                    for k4=1:size(data,4)
                        for k5=1:size(data,5)
                            for k6=1:size(data,6)
                                data(:,:,k3,k4,k5,k6)=detrend(data(:,:,k3,k4,k5,k6),'linear');
                            end
                        end
                    end
                end
            else
                for k3=1:size(data,3)
                    for k4=1:size(data,4)
                        for k5=1:size(data,5)
                            for k6=1:size(data,6)
                                data(:,:,k3,k4,k5,k6)=detrend(data(:,:,k3,k4,k5,k6),'constant');
                            end
                        end
                    end
                end
            end
            data=ipermute(data,[6,1,2,3,4,5]);
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end