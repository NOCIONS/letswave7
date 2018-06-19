classdef FLW_FFT<CLW_generic
    properties
        FLW_TYPE=1;
        h_output_pop;
        h_half_spectrum_chx;
        h_normalized_pop;
    end
    
    methods
        function obj = FLW_FFT(batch_handle)
            obj@CLW_generic(batch_handle,'FFT','fft',...
                'Compute a discrete Fourier transform (DFT), computed with a fast Fourier transform (FFT) algorithm.');
            
            uicontrol('style','text','position',[35,470,200,20],...
                'string','Output','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_output_pop=uicontrol('style','popupmenu',...
                'String',{'power','amplitude','phase angle','real part',...
                'imagery part','complex'},'value',1,'backgroundcolor',[1,1,1],...
                'position',[35,440,200,30],'parent',obj.h_panel);
            obj.h_half_spectrum_chx=uicontrol('style','checkbox',...
                'String','Output only first half of spectrum','value',1,...
                'position',[35,390,250,30],'parent',obj.h_panel);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            str=get(obj.h_output_pop,'String');
            str_value=get(obj.h_output_pop,'value');
            option.output=str{str_value};
            option.half_spectrum=get(obj.h_half_spectrum_chx,'value');
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            switch option.output
                case 'power'
                    set(obj.h_output_pop,'value',1);
                case 'amplitude'
                    set(obj.h_output_pop,'value',2);
                case 'phase angle'
                    set(obj.h_output_pop,'value',3);
                case 'real part'
                    set(obj.h_output_pop,'value',4);
                case 'imagery part'
                    set(obj.h_output_pop,'value',5);
                case 'complex'
                    set(obj.h_output_pop,'value',6);
            end
            set(obj.h_half_spectrum_chx,'value',option.half_spectrum);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''output'',''',...
                option.output,''','];
            frag_code=[frag_code,'''half_spectrum'',',...
                num2str(option.half_spectrum),','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            if ~strcmpi(header_in.filetype,'time_amplitude')
                warning('!!! WARNING : input data is not of format time_amplitude!');
            end
            header_out=header_in;
            header_out.xstart=0;
            header_out.xstep=1/(header_in.xstep*header_in.datasize(6));
            switch option.output
                case 'amplitude'
                    header_out.filetype='frequency_amplitude';
                case 'power'
                    header_out.filetype='frequency_power';
                case 'phase angle'
                    header_out.filetype='frequency_phase';
                case 'real part'
                    header_out.filetype='frequency_realpart';
                case 'imagery part'
                    header_out.filetype='frequency_imagpart';
                case 'complex'
                    header_out.filetype='frequency_complex';
                    %used for ifft
                    option.events=header_in.events;
                    option.xstart=header_in.xstart;
                    option.xstep=header_in.xstep;
                    option.datasize=header_in.datasize;
            end
            header.events=[];
            if option.half_spectrum==1
                header_out.datasize(6)=ceil((header_out.datasize(6)+1)/2);
            end
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.output='power';
            option.half_spectrum=1;
            
            option.suffix='fft';
            option.is_save=0;
            option=CLW_check_input(option,{'output','half_spectrum',...
                'suffix','is_save'},varargin);
            header=FLW_FFT.get_header(lwdata_in.header,option);
            option=header.history(end).option;
            data=fft(lwdata_in.data,[],6)/lwdata_in.header.datasize(6);
            switch option.output
                case 'power'
                    data=abs(data).^2;
                case 'amplitude'
                    data=abs(data);
                case 'phase angle'
                    data=angle(data);
                case 'real part'
                    data=real(data);
                case 'imagery part'
                    data=imag(data);
            end
            if option.half_spectrum==1
                data=data(:,:,:,:,:,1:ceil((size(data,6)+1)/2));
                switch option.output
                    case 'power'
                        data(:,:,:,:,:,2:ceil(size(data,6)/2))=data(:,:,:,:,:,2:ceil(size(data,6)/2))*2;
                    case 'amplitude'
                        data(:,:,:,:,:,2:ceil(size(data,6)/2))=data(:,:,:,:,:,2:ceil(size(data,6)/2))*sqrt(2);
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