classdef FLW_hilbert<CLW_generic
    properties
        FLW_TYPE=1;
        
        h_output_pop;
    end
    
    methods
        function obj = FLW_hilbert(batch_handle)
            obj@CLW_generic(batch_handle,'Hilbert','hilbert',...
                'Compute the Hilbert transform.');
            
            uicontrol('style','text','position',[35,470,200,20],...
                'string','Output','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_output_pop=uicontrol('style','popupmenu',...
                'String',{'amplitude','power','phase angle','real part',...
                'imagery part','complex'},'value',3,...
                'position',[35,440,200,30],'parent',obj.h_panel);
            set(obj.h_output_pop,'backgroundcolor',[1,1,1]);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            str=get(obj.h_output_pop,'String');
            str_value=get(obj.h_output_pop,'value');
            option.output=str{str_value};
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            switch option.output
                case 'amplitude'
                    set(obj.h_output_pop,'value',1);
                case 'power'
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
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''output'',''',...
                option.output,''','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            if ~strcmpi(header_in.filetype,'time_amplitude');
                warning('!!! WARNING : input data is not of format time_amplitude!');
            end
            header_out=header_in;
            switch option.output
                case 'amplitude'
                    header_out.filetype='time_amplitude';
                case 'power'
                    header_out.filetype='time_power';
                case 'phase angle'
                    header_out.filetype='time_phase';
                case 'real part'
                    header_out.filetype='time_realpart';
                case 'imagery part'
                    header_out.filetype='time_imagpart';
                case 'complex'
                    header_out.filetype='time_complex';
            end
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.output='amplitude';
            
            option.suffix='hilbert';
            option.is_save=0;
            option=CLW_check_input(option,{'output','suffix','is_save'},varargin);
            header=FLW_hilbert.get_header(lwdata_in.header,option);
            option=header.history(end).option;
            
            data=permute(lwdata_in.data,[6,1,2,3,4,5]);
            [ds(1),ds(2),ds(3),ds(4),ds(5),ds(6)]=size(data);
            data=reshape(data,ds(1),[]);
            data=hilbert(data);
            data=reshape(data,ds(1),ds(2),ds(3),ds(4),ds(5),ds(6));
            data=ipermute(data,[6,1,2,3,4,5]);
            switch option.output
                case 'amplitude'
                    data=abs(data);
                case 'power'
                    data=abs(data).^2;
                case 'phase angle'
                    data=angle(data);
                case 'real part'
                    data=real(data);
                case 'imagery part'
                    data=imag(data);
            end
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end