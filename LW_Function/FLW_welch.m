classdef FLW_welch<CLW_generic
    properties
        FLW_TYPE=1;
        h_window_length;
        h_sliding_step;
        h_low_frequency;
        h_high_frequency;
        h_num_frequency_lines;
    end
    
    methods
        function obj = FLW_welch(batch_handle)
            obj@CLW_generic(batch_handle,'welch','welch',...
                'Compute the power spectral density (PSD) estimate of the input signal, using Welch''s overlapped segment averaging estimator.');
            
            uicontrol('style','text','position',[30,450,140,20],...
                'string','Hanning windows width(s):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_window_length=uicontrol('style','edit','string','0.2',...
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
          
            
            set(obj.h_window_length,'backgroundcolor',[1,1,1]);
            set(obj.h_sliding_step,'backgroundcolor',[1,1,1]);
            set(obj.h_low_frequency,'backgroundcolor',[1,1,1]);
            set(obj.h_high_frequency,'backgroundcolor',[1,1,1]);
            set(obj.h_num_frequency_lines,'backgroundcolor',[1,1,1]);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.window_length=str2num(get(obj.h_window_length,'string'));
            option.sliding_step=round(str2num(get(obj.h_sliding_step,'string')));
            option.low_frequency=str2num(get(obj.h_low_frequency,'string'));
            option.high_frequency=str2num(get(obj.h_high_frequency,'string'));
            option.num_frequency_lines=str2num(get(obj.h_num_frequency_lines,'string'));
            
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_window_length,'string',num2str(option.window_length));
            set(obj.h_sliding_step,'string',num2str(option.sliding_step));
            set(obj.h_low_frequency,'string',num2str(option.low_frequency));
            set(obj.h_high_frequency,'string',num2str(option.high_frequency));
            set(obj.h_num_frequency_lines,'string',num2str(option.num_frequency_lines));
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''window_length'',',...
                num2str(option.window_length),','];
            frag_code=[frag_code,'''sliding_step'',',...
                num2str(option.sliding_step),','];
            frag_code=[frag_code,'''low_frequency'',',...
                num2str(option.low_frequency),','];
            frag_code=[frag_code,'''high_frequency'',',...
                num2str(option.high_frequency),','];
            frag_code=[frag_code,'''num_frequency_lines'',',...
                num2str(option.num_frequency_lines),','];
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
            header_out.xstep=f(2)-f(1);
            header_out.xstart=f(1);
            header_out.datasize(6)=length(f);
            
            header_out.events=[];
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.suffix='welch';
            option.is_save=0;
            option=CLW_check_input(option,{'window_length','sliding_step',...
                'low_frequency','high_frequency','num_frequency_lines',...
                'suffix','is_save'},varargin);
            header=FLW_welch.get_header(lwdata_in.header,option);
            option=header.history(end).option;
            
            winsize=ceil(option.window_length/lwdata_in.header.xstep);
            f=linspace(option.low_frequency,option.high_frequency,option.num_frequency_lines);
            fs=1/lwdata_in.header.xstep;
            data=zeros(header.datasize);
            for k1=1:size(data,1)
                for k2=1:size(data,2)
                    for k3=1:size(data,3)
                        for k4=1:size(data,4)
                            for k5=1:size(data,5)
                                data(k1,k2,k3,k4,k5,:)=...
                                    pwelch(squeeze(lwdata_in.data(k1,k2,k3,k4,k5,:)),winsize,option.sliding_step,f,fs);
                            end
                        end
                    end
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