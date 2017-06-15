classdef FLW_averaged_STFT<CLW_generic
    properties
        FLW_TYPE=1;
        
        h_hanning_width;
        h_sliding_step;
        h_low_frequency;
        h_high_frequency;
        h_num_frequency_lines;
        h_output_pop;
        h_show_progress;
    end
    
    methods
        function obj = FLW_averaged_STFT(batch_handle)
            obj@CLW_generic(batch_handle,'avg_STFT','avg stft',...
                ['Compute the averaging results of the Short-Time Fourier Transform.',...
                ' This operation equals to the operation stft and avg, but save the memory greatly.']);
            
            uicontrol('style','text','position',[30,450,140,20],...
                'string','Hanning windows width(s):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_hanning_width=uicontrol('style','edit','string','0.2',...
                'position',[180,453,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,420,140,20],...
                'string','Sliding step (bins):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_sliding_step=uicontrol('style','edit','string','1',...
                'position',[180,423,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,390,140,20],...
                'string','Lower frequency:','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_low_frequency=uicontrol('style','edit','string','1',...
                'position',[180,393,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,360,140,20],...
                'string','Higher frequency:','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_high_frequency=uicontrol('style','edit','string','30',...
                'position',[180,363,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,330,140,20],...
                'string','Number of lines:','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_num_frequency_lines=uicontrol('style','edit','string','30',...
                'position',[180,333,100,20],'parent',obj.h_panel);
            
            
            
            uicontrol('style','text','position',[30,300,140,20],...
                'string','Output:','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_output_pop=uicontrol('style','popupmenu',...
                'String',{'amplitude','power','phase angle','real part',...
                'imagery part','complex'},'value',1,...
                'position',[180,303,100,20],'parent',obj.h_panel);
            
            obj.h_show_progress=uicontrol('style','checkbox',...
                'string','show_process','value',1,...
                'position',[130,260,130,20],'parent',obj.h_panel);
            
            set(obj.h_hanning_width,'backgroundcolor',[1,1,1]);
            set(obj.h_sliding_step,'backgroundcolor',[1,1,1]);
            set(obj.h_low_frequency,'backgroundcolor',[1,1,1]);
            set(obj.h_high_frequency,'backgroundcolor',[1,1,1]);
            set(obj.h_num_frequency_lines,'backgroundcolor',[1,1,1]);
            set(obj.h_output_pop,'backgroundcolor',[1,1,1]);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.hanning_width=str2num(get(obj.h_hanning_width,'string'));
            option.sliding_step=round(str2num(get(obj.h_sliding_step,'string')));
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
            set(obj.h_hanning_width,'string',num2str(option.hanning_width));
            set(obj.h_sliding_step,'string',num2str(option.sliding_step));
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
            frag_code=[frag_code,'''hanning_width'',',...
                num2str(option.hanning_width),','];
            frag_code=[frag_code,'''sliding_step'',',...
                num2str(option.sliding_step),','];
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
            
            winsize=round((option.hanning_width/header_out.xstep-1)/2)*2+1;
            noverlap=winsize-option.sliding_step;
            header_out.xstep=option.sliding_step*header_in.xstep;
            header_out.xstart=header_in.xstart+(winsize-1)/2*header_in.xstep;
            header_out.datasize(6)=floor((header_out.datasize(6)-noverlap)/(winsize-noverlap));
            
            f=linspace(option.low_frequency,option.high_frequency,option.num_frequency_lines);
            header_out.ystep=f(2)-f(1);
            header_out.ystart=f(1);
            header_out.datasize(5)=length(f);
            header_out.datasize(4)=1;
            header_out.datasize(1)=1;
            
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
            option.hanning_width=0.2;
            option.sliding_step=1;
            option.low_frequency=1;
            option.high_frequency=30;
            option.num_frequency_lines=30;
            option.output='amplitude';
            option.show_progress=1;
            
            option.suffix='avg stft';
            option.is_save=0;
            option=CLW_check_input(option,{'output','hanning_width',...
                'sliding_step','low_frequency','high_frequency',...
                'show_progress','num_frequency_lines','suffix','is_save'},varargin);
            header=FLW_averaged_STFT.get_header(lwdata_in.header,option);
            
            
            t=header.xstart+(0:header.datasize(6)-1)*header.xstep;
            f=header.ystart+(0:header.datasize(5)-1)*header.ystep;
            Fs=1/header.xstep;
            winsize=round((option.hanning_width/header.xstep-1)/2)*2+1;
            x_step=round(option.sliding_step);
            w = window('hann',winsize);
            
            nfft = round(Fs/header.ystep) * max(1,2^(nextpow2(winsize/round(Fs/header.ystep))));
            f_full = Fs/2*linspace(0,1,round(nfft/2)+1);
            f_idx=zeros(1,length(f));
            for k=1:length(f)
                [~,f_idx(k)]=min(abs(f_full-f(k)));
            end
            data=zeros(header.datasize);
            
            if option.show_progress==1
                fig=figure('numbertitle','off','name','STFT progress',...
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
                pause(0.001);
                tic;
                t1=toc;
            end
            for epoch_index=1:lwdata_in.header.datasize(1)
                for t_index=1:header.datasize(6)
                    temp = lwdata_in.data(epoch_index,:,:,1,1,(t_index-1)*x_step+(1:winsize));
                    temp = permute(temp,[6,1,2,3,4,5]);
                    temp = bsxfun(@times,w,temp);
                    temp = detrend(temp,'constant');
                    temp = fft(temp,nfft,1);
                    temp = temp(f_idx,:,:,:,:,:);
                    temp = permute(temp,[2,3,4,5,1,6]);
                    
                    switch option.output
                        case 'amplitude'
                            temp=abs(temp)*2;
                        case 'power'
                            temp=abs(temp*2).^2;
                        case 'phase angle'
                            temp=angle(temp);
                        case 'real part'
                            temp=real(temp);
                        case 'imagery part'
                            temp=imag(temp);
                    end
                    
                    data(1,:,:,:,:,t_index)=data(1,:,:,:,:,t_index)+temp;
                    t=toc;
                    if option.show_progress==1 && ishandle(fig) && t-t1>0.2
                        t1=t;
                        N=(t_index+(epoch_index-1)*header.datasize(6))/(header.datasize(6)*lwdata_in.header.datasize(1));
                        set(run_slider,'Position',[0 0 N 1]);
                        set(h_text,'string',[num2str(N*100,'%0.0f'),'% ( ',num2str(t/N*(1-N),'%0.0f'),' second left)']);
                        pause(0.001);
                    end
                end
            end
            
            if option.show_progress==1 && ishandle(fig)
                set(run_slider,'Position',[0 0 1 1]);
                set(h_text,'string','finished and saving.');
                pause(0.001);
            end
            
            data=data/winsize/mean(w);
            data=data/lwdata_in.header.datasize(1);
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
            if option.show_progress==1 && ishandle(fig)
                close(fig);
            end
        end
    end
end