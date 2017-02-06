classdef FLW_iFFT<CLW_generic
    properties
        FLW_TYPE=1;
        h_force_real_chx;
    end
    
    methods
        function obj = FLW_iFFT(batch_handle)
            obj@CLW_generic(batch_handle,'iFFT','ifft',...
                'Compute the inverse FFT transform. This requires a dataset with complex FFT values.Due to slight rounding imprecisions, the inverse FFT of the the FFT of a real signal may, in some cases, not return real values. To ensure that the output are real values, check the option to Force the output to be real.');
            
            obj.h_force_real_chx=uicontrol('style','checkbox',...
                'String','force output to be Real','value',1,...
                'position',[35,390,250,30],'parent',obj.h_panel);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.force_real=get(obj.h_force_real_chx,'value');
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_force_real_chx,'value',option.force_real);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''force_real'',',...
                num2str(option.force_real),','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            if ~strcmpi(header_in.filetype,'frequency_complex')
                error('Input data is not of format frequency_complex!');
            end
            header_out=header_in;
            time_header=[];
            for k=length(header_in.history):-1:1
                if strcmpi(header_in.history(k).option.function,'FLW_FFT')
                        time_header=header_in.history(k).option;
                    break;
                end
            end
            if isempty(time_header)
                header_out.xstart=0;
                header_out.xstep=1/(header_in.xstep*header_in.datasize(6));
                header_out.events=[];
            else
                header_out.xstart=time_header.xstart;
                header_out.xstep=time_header.xstep;
                header_out.events=time_header.events;
                header_out.datasize(6)=time_header.datasize(6);
            end
            header_out.filetype='time_amplitude';
            
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.force_real=1;
            option.suffix='iFFT';
            option.is_save=0;
            option=CLW_check_input(option,{'force_real','suffix','is_save'},varargin);
            header=FLW_iFFT.get_header(lwdata_in.header,option);
            
            time_header=[];
            for k=length(lwdata_in.header.history):-1:1
                if strcmpi(lwdata_in.header.history(k).option.function,'FLW_FFT')
                        time_header=lwdata_in.header.history(k).option;
                    break;
                end
            end
            if isempty(time_header)
                option.half_spectrum=0;
            else
                option.half_spectrum=time_header.half_spectrum;
            end
            if option.half_spectrum
                datasize_new=lwdata_in.header.datasize(6);
                datasize_old=header.datasize(6);
                data=zeros(header.datasize);
                data(:,:,:,:,:,1:datasize_new)=lwdata_in.data;
                if mod(datasize_old,2)==1
                    data(:,:,:,:,:,datasize_new+1:datasize_old)=conj(data(:,:,:,:,:,datasize_new:-1:2));
                else
                    data(:,:,:,:,:,datasize_new+1:datasize_old)=conj(data(:,:,:,:,:,datasize_new-1:-1:2));
                end
            else
                data=lwdata_in.data;
            end
            data=data*size(data,6);
            data=ifft(data,[],6);
            if option.force_real
                data=real(data);
            end
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end