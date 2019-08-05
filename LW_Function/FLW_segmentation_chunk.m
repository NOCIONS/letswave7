classdef FLW_segmentation_chunk<CLW_generic
    properties
        FLW_TYPE=1;
        h_onset_edt;
        h_duration_edt;
        h_interval_edt;
    end
    
    methods
        function obj = FLW_segmentation_chunk(batch_handle)
            obj@CLW_generic(batch_handle,'chunk','chunk',...
                'Segment epochs into successive chunks of data.');
            
            uicontrol('style','text','position',[35,470,300,20],...
                'string','Onset of first chunk in epoch(s):','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_onset_edt=uicontrol('style','edit',...
                'String','0','backgroundcolor',[1,1,1],...
                'position',[55,445,200,25],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[35,410,300,20],...
                'string','Duration of each chunk:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_duration_edt=uicontrol('style','edit',...
                'String','1','backgroundcolor',[1,1,1],...
                'position',[55,385,200,25],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[35,350,400,20],...
                'string','Interval between the onset of successive chunk(s):','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_interval_edt=uicontrol('style','edit',...
                'String','1','backgroundcolor',[1,1,1],...
                'position',[55,325,200,25],'parent',obj.h_panel);
            
            set (obj.h_onset_edt,'backgroundcolor',[1,1,1]);
            set (obj.h_duration_edt,'backgroundcolor',[1,1,1]);
            set (obj.h_interval_edt,'backgroundcolor',[1,1,1]);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.chunk_onset=str2num(get(obj.h_onset_edt,'String'));
            option.chunk_duration=str2num(get(obj.h_duration_edt,'String'));
            option.chunk_interval=str2num(get(obj.h_interval_edt,'String'));
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_onset_edt,'String',num2str(option.chunk_onset));
            set(obj.h_duration_edt,'String',num2str(option.chunk_duration));
            set(obj.h_interval_edt,'String',num2str(option.chunk_interval));
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''chunk_onset'',',...
                num2str(option.chunk_onset),','];
            frag_code=[frag_code,'''chunk_duration'',',...
                num2str(option.chunk_duration),','];
            frag_code=[frag_code,'''chunk_interval'',',...
                num2str(option.chunk_interval),','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
         function GUI_update(obj,batch_pre)
            obj.lwdataset=batch_pre.lwdataset;
            chunk_onset=str2num(get(obj.h_onset_edt,'String'));
            xstart=obj.lwdataset(1).header.xstart;
            for data_pos=2:length(obj.lwdataset)
                xstart=max(xstart,obj.lwdataset(data_pos).header.xstart);
            end
            if chunk_onset<xstart
                set(obj.h_onset_edt,'string',num2str(xstart));
            end
            
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
         end
        
         
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            header_out.events=[];
            x_end=(max(option.chunk_onset,header_in.xstart)+option.chunk_duration):...
                option.chunk_interval: ...
                header_in.xstart+((header_in.datasize(6)-1)*header_in.xstep);
            x=header_in.xstart+((1:header_in.datasize(6))-1)*header_in.xstep;
            x_dur=floor((option.chunk_duration)/header_in.xstep);
            header_out.datasize(1)=header_out.datasize(1)*length(x_end);
            header_out.datasize(6)=x_dur;
            header_out.x_start=0;
            if isfield(header_in,'events') && ~isempty(header_in.events)
                new_events=header_in.events(1);
                k=1;
                ke=1;
                for epoch_pos=1:header_in.datasize(1)
                    for chunk_pos=1:length(x_end)
                        x2=find(x_end(chunk_pos)>x,1,'last');
                        x1=x2-x_dur+1;
                        for event_pos=1:length(header_in.events)
                            if header_in.events(event_pos).epoch==epoch_pos &&...
                                    header_in.events(event_pos).latency>=x(x1) &&...
                                    header_in.events(event_pos).latency<=x(x2)
                                new_events(ke)=header_in.events(event_pos);
                                new_events(ke).epoch=k;
                                new_events(ke).latency=...
                                    header_in.events(event_pos).latency-x(x1);
                                ke=ke+1;
                            end
                        end
                        k=k+1;
                    end
                end
                header_out.events=new_events;
            else
                header_out.events=[];
            end
            
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.chunk_onset=0;
            option.chunk_duration=1;
            option.chunk_interval=1;
            
            option.suffix='chunk';
            option.is_save=0;
            option=CLW_check_input(option,{'chunk_onset','chunk_duration',...
                'chunk_interval','suffix','is_save'},varargin);
            header=FLW_segmentation_chunk.get_header(lwdata_in.header,option);
            option=header.history(end).option;
            
            x_end=(max(option.chunk_onset,lwdata_in.header.xstart)+option.chunk_duration):...
                option.chunk_interval: ...
                lwdata_in.header.xstart+((lwdata_in.header.datasize(6)-1)*lwdata_in.header.xstep);
            x=lwdata_in.header.xstart+((1:lwdata_in.header.datasize(6))-1)*lwdata_in.header.xstep;
            x_dur=floor((option.chunk_duration)/lwdata_in.header.xstep);
            
            data=zeros(header.datasize);
            k=1;
            for epoch_pos=1:lwdata_in.header.datasize(1)
                for chunk_pos=1:length(x_end)
                    x2=find(x_end(chunk_pos)>x,1,'last');
                    x1=x2-x_dur+1;
                    data(k,:,:,:,:,:)=lwdata_in.data(epoch_pos,:,:,:,:,x1:x2);
                    k=k+1;
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