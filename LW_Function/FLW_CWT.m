classdef FLW_CWT<CLW_generic
    properties
        FLW_TYPE=1;
        
        h_wavelet_name;
        h_low_frequency;
        h_high_frequency;
        h_num_frequency_lines;
        h_output_pop;
        h_show_progress;
    end
    
    methods
        function obj = FLW_CWT(batch_handle)
            obj@CLW_generic(batch_handle,'CWT','cwt',...
                'Compute a time-frequency transform using the Continuous Wavelet Transform.');
            
            uicontrol('style','text','position',[30,420,140,20],...
                'string','Mother wavelet short name:','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_wavelet_name=uicontrol('style','edit','string','cmor1-1.5',...
                'backgroundcolor',[1,1,1],...
                'position',[180,423,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,390,140,20],...
                'string','Lower frequency:','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_low_frequency=uicontrol('style','edit','string','1',...
                'backgroundcolor',[1,1,1],...
                'position',[180,393,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,360,140,20],...
                'string','Higher frequency:','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_high_frequency=uicontrol('style','edit','string','30',...
                'backgroundcolor',[1,1,1],...
                'position',[180,363,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,330,140,20],...
                'string','Number of lines:','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_num_frequency_lines=uicontrol('style','edit','string','100',...
                'backgroundcolor',[1,1,1],...
                'position',[180,333,100,20],'parent',obj.h_panel);
            
            
            uicontrol('style','text','position',[30,300,140,20],...
                'string','Output:','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_output_pop=uicontrol('style','popupmenu',...
                'String',{'amplitude','power','phase angle','real part',...
                'imagery part','complex'},'value',1,...
                'backgroundcolor',[1,1,1],...
                'position',[180,303,100,20],'parent',obj.h_panel);
            
            
            obj.h_show_progress=uicontrol('style','checkbox',...
                'string','show_process','value',1,...
                'position',[130,260,130,20],'parent',obj.h_panel);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.wavelet_name=get(obj.h_wavelet_name,'string');
            option.low_frequency=str2num(get(obj.h_low_frequency,'string'));
            option.high_frequency=str2num(get(obj.h_high_frequency,'string'));
            option.num_frequency_lines=str2num(get(obj.h_num_frequency_lines,'string'));
            
            str=get(obj.h_output_pop,'String');
            str_value=get(obj.h_output_pop,'value');
            option.output=str{str_value};
            option.show_progress=get(obj.h_show_progress,'value');
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_show_progress,'value',option.show_progress);
            set(obj.h_wavelet_name,'string',option.wavelet_name);
            set(obj.h_low_frequency,'string',num2str(option.low_frequency));
            set(obj.h_high_frequency,'string',num2str(option.high_frequency));
            set(obj.h_num_frequency_lines,'string',num2str(option.num_frequency_lines));
            
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
            frag_code=[frag_code,'''wavelet_name'',''',...
                option.wavelet_name,''','];
            frag_code=[frag_code,'''low_frequency'',',...
                num2str(option.low_frequency),','];
            frag_code=[frag_code,'''high_frequency'',',...
                num2str(option.high_frequency),','];
            frag_code=[frag_code,'''num_frequency_lines'',',...
                num2str(option.num_frequency_lines),','];
            frag_code=[frag_code,'''output'',''',...
                option.output,''','];
            frag_code=[frag_code,'''show_progress'',',...
                num2str(option.show_progress),','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            if ~strcmpi(header_in.filetype,'time_amplitude')
                warning('!!! WARNING : input data is not of format time_amplitude!');
            end
            header_out=header_in;
            
            f=linspace(option.low_frequency,option.high_frequency,option.num_frequency_lines);
            header_out.ystep=f(2)-f(1);
            header_out.ystart=f(1);
            header_out.datasize(5)=length(f);
            header_out.datasize(4)=1;
            
            switch option.output
                case 'amplitude'
                    header_out.filetype='time_frequency_amplitude';
                case 'power'
                    header_out.filetype='time_frequency_power';
                case 'phase angle'
                    header_out.filetype='time_frequency_phase';
                case 'real part'
                    header_out.filetype='time_frequency_realpart';
                case 'imagery part'
                    header_out.filetype='time_frequency_imagpart';
                case 'complex'
                    header_out.filetype='time_frequency_complex';
            end
            header_out.events=[];
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.wavelet_name='cmor1-1.5';
            option.low_frequency=1;
            option.high_frequency=30;
            option.num_frequency_lines=100;
            option.output='amplitude';
            option.show_progress=1;
            
            option.suffix='cwt';
            option.is_save=0;
            option=CLW_check_input(option,{'output','wavelet_name',...
                'low_frequency','high_frequency','num_frequency_lines',...
                'show_progress','suffix','is_save'},varargin);
            header=FLW_CWT.get_header(lwdata_in.header,option);
            
            central_freq=centfrq(option.wavelet_name);
            frequencies=header.ystart+(0:header.datasize(5)-1)*header.ystep;
            scales=(central_freq/header.xstep)./frequencies;
            
            data=zeros(header.datasize);
            if option.show_progress
                fig=figure('numbertitle','off','name','CWT progress',...
                    'MenuBar','none','DockControls','off');
                pos=get(fig,'position');
                pos(3:4)=[400,100];
                set(fig,'position',pos);
                hold on;
                run_slider=rectangle('Position',[0 0 eps 1],'FaceColor',[255,71,38]/255,'LineStyle','none');
                rectangle('Position',[0 0 1 1]);
                xlim([0,1]);
                ylim([-1,2]);
                axis off;
                h_text=text(1,-0.5,'starting...','HorizontalAlignment','right','Fontsize',12,'FontWeight','bold');
                drawnow;
                tic;
                t1=toc;
            end
            for epochpos=1:header.datasize(1)
                for channelpos=1:header.datasize(2)
                    for indexpos=1:header.datasize(3)
                        data(epochpos,channelpos,indexpos,1,:,:)=cwt(lwdata_in.data(epochpos,channelpos,indexpos,1,1,:),scales,option.wavelet_name);
                        t=toc;
                        if option.show_progress==1 && ishandle(fig) && t-t1>0.2
                            t1=t;
                            N=(((epochpos-1)*header.datasize(2)+channelpos-1)...
                                *header.datasize(3)+indexpos)/...
                                (header.datasize(3)*header.datasize(2)*header.datasize(1));
                            set(run_slider,'Position',[0 0 N 1]);
                            set(h_text,'string',[num2str(N*100,'%0.0f'),'% ( ',num2str(t/N*(1-N),'%0.0f'),' second left)']);
                            pause(0.001);
                        end
                    end
                end
            end
            
            if option.show_progress && ishandle(fig)
                set(run_slider,'Position',[0 0 1 1]);
                set(h_text,'string','finished and saving.');
                drawnow;
            end
            
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
            if option.show_progress && ishandle(fig)
                close(fig);
            end
        end
    end
end