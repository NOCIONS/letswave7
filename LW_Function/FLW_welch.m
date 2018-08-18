classdef FLW_welch<CLW_generic
    properties
        FLW_TYPE=1;
        h_window_length;
        h_sliding_step;
    end
    
    methods
        function obj = FLW_welch(batch_handle)
            obj@CLW_generic(batch_handle,'welch','welch',...
                'Compute the power estimate of the input signal, using Welch''s overlapped segment averaging estimator.');
            
            uicontrol('style','text','position',[30,450,140,20],...
                'string','Windows width(s):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_window_length=uicontrol('style','edit','string','2',...
                'position',[180,453,100,20],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[30,420,140,20],...
                'string','Sliding step (s):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_sliding_step=uicontrol('style','edit','string','1',...
                'position',[180,423,100,20],'parent',obj.h_panel);
            
            set(obj.h_window_length,'backgroundcolor',[1,1,1]);
            set(obj.h_sliding_step,'backgroundcolor',[1,1,1]);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.window_length=str2num(get(obj.h_window_length,'string'));
            option.sliding_step=round(str2num(get(obj.h_sliding_step,'string')));
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_window_length,'string',num2str(option.window_length));
            set(obj.h_sliding_step,'string',num2str(option.sliding_step));
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''window_length'',',...
                num2str(option.window_length),','];
            frag_code=[frag_code,'''sliding_step'',',...
                num2str(option.sliding_step),','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            if ~strcmpi(header_in.filetype,'time_amplitude')
                warning('!!! WARNING : input data is not of format time_amplitude!');
            end
            header_out=header_in;
            win_len=floor(option.window_length/header_in.xstep);
            f=linspace(0,1/header_in.xstep,win_len+1);
            header_out.xstart=0;
            header_out.xstep=f(2);
            header_out.datasize(6)=ceil(win_len/2)+1;
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
                'suffix','is_save'},varargin);
            header=FLW_welch.get_header(lwdata_in.header,option);
            option=header.history(end).option;
            
            win_len=floor(option.window_length/lwdata_in.header.xstep);
            win_step=floor(option.sliding_step/lwdata_in.header.xstep);
            win=hamming(win_len);
            U=sum(win)^2;
%             Fs=1/lwdata_in.header.xstep;
%             U=win'*win*Fs;
            data=zeros(header.datasize);
            
            for k1=1:size(data,1)
                for k2=1:size(data,2)
                    for k3=1:size(data,3)
                        for k4=1:size(data,4)
                            for k5=1:size(data,5)
                                x=squeeze(lwdata_in.data(k1,k2,k3,k4,k5,:));
                                temp=zeros(win_len,1);
                                for k=1:win_step:length(x)-win_len+1
                                    Xx=fft(win.*x((1:win_len)+(k-1)));
                                    temp=temp+Xx.*conj(Xx)/U;
                                end
                                temp=temp/ceil((length(x)-win_len+1)/win_step);
                                temp(2:ceil(win_len/2),:)=temp(2:ceil(win_len/2),:).*2;
                                data(k1,k2,k3,k4,k5,:)=temp(1:ceil(win_len/2)+1,:);
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