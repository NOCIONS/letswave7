classdef FLW_export_EEGLAB
    properties
        h_fig;
        h_file_list;
        h_export_btn;
        h_script_btn;
        h_toolbar;
    end
    
    methods
        function obj = FLW_export_EEGLAB()
            obj=obj.init_handles();
            userdata.file_path={};
            userdata.file_name={};
            set(obj.h_file_list,'userdata',userdata);
            set(obj.h_export_btn,'enable','off');
            set(obj.h_script_btn,'enable','off');
            
            set(obj.h_script_btn,'Callback',@obj.get_script);
            set(obj.h_export_btn,'Callback',@obj.export_file);
            uiwait(obj.h_fig);
        end
        
        
        function obj=init_handles(obj)
            obj.h_fig=figure('name','Import Data','NumberTitle','off');
            pos=get(obj.h_fig,'Position');
            pos(3:4)=[300 510];
            set(obj.h_fig,'Position',pos);
            set(obj.h_fig,'MenuBar','none');
            set(obj.h_fig,'DockControls','off');
            
            filename=dir('*.lw6');
            filename={filename.name};
            idx=[];
            for k=1:length(filename)
                header = CLW_load_header(filename{k});
                if sum(header.datasize(3:5))~=3
                    idx=[idx,k];
                end
            end
            idx=setdiff(1:length(filename),idx);
            filename=filename(idx);
            
            icon=load('icon.mat');
            obj.h_file_list=uicontrol('style','listbox','string','',...
                'HorizontalAlignment','left',...
                'Fontsize',14,'value',[],'max',10,'units','normalized',...
                'position',[0,0.08,1,0.92],'string',filename);
            
            
            obj.h_export_btn=uicontrol('style','pushbutton','string','Export',...
                'HorizontalAlignment','Center',...
                'Fontsize',14,'units','normalized','position',[0,0,0.8,0.08]);
            
            obj.h_script_btn=uicontrol('style','pushbutton',...
                'HorizontalAlignment','Center','CData',icon.icon_script,...
                'units','normalized','position',[0.8,0,0.2,0.08]);
            
        end
        
        function get_script(obj,varargin)
            userdata=get(obj.h_file_list, 'userdata');
            script={};
            script{end+1}='LW_Init();';
            if ~isempty(userdata.file_path)
                for k=1:length(userdata.file_path)
                    script{end+1}=['FLW_import_data.get_lwdata(',...
                        '''filename'',''',userdata.file_name{k},''','...
                        '''pathname'',''',userdata.file_path{k},''','...
                        '''is_save'',''','1'');'];
                    script{end+1}='';
                end
            end
            CLW_show_script(script);
        end
        
        function obj=export_file(obj,varargin)
            userdata=get(obj.h_file_list, 'userdata');
            if ~isempty(userdata.file_path)
                str=get( obj.h_file_list, 'String' );
                for k=1:length(userdata.file_path)
                    str{k}=['<html><b>',userdata.file_name{k},'&nbsp;&nbsp;(processing...)</b></html>'];
                    set( obj.h_file_list,'String',str);
                    pause(0.01);
                    option.filename=userdata.file_name{k};
                    option.pathname=userdata.file_path{k};
                    option.is_save=1;
                    FLW_import_data.get_lwdata(option);
                    
                    str{k}=['<html><p style="color:red">',userdata.file_name{k},'&nbsp;&nbsp;(Done)</p></html>'];
                    set( obj.h_file_list,'String',str);
                    pause(0.01);
                end
            end
        end
        
        
    end
    
    methods (Static = true)
        function get_lwdata(varargin)
            option.filename=[];
            option.pathname='';
            option=CLW_check_input(option,{'filename','pathname'},varargin);
            if isempty(option.filename)
                error('the filename is empty');
            end
            
            str=fullfile(option.pathname,option.filename);
            [~,name,~] = fileparts(str);
            
            
            
            lwdata_out.data=permute(single(ft_read_data(str)),[3,1,4,5,6,2]);
            %epoch,channel,index,Z,Y,X
            %channel,X,epoch,1,1,1
            
            hdr=ft_read_header(str);
            trg=ft_read_event(str);
            lwdata_out.header=[];
            lwdata_out.header.filetype='time_amplitude';
            lwdata_out.header.name= name;
            lwdata_out.header.tags='';
            lwdata_out.header.datasize=[hdr.nTrials hdr.nChans 1 1 1 hdr.nSamples];
            lwdata_out.header.xstart=(hdr.nSamplesPre/hdr.Fs)*-1;
            lwdata_out.header.ystart=0;
            lwdata_out.header.zstart=0;
            lwdata_out.header.xstep=1/hdr.Fs;
            lwdata_out.header.ystep=1;
            lwdata_out.header.zstep=1;
            lwdata_out.header.history=[];
            lwdata_out.header.source=str;
            
            chanloc.labels='';
            chanloc.topo_enabled=0;
            chanloc.SEEG_enabled=0;
            for chanpos=1:hdr.nChans;
                chanloc.labels=hdr.label{chanpos};
                lwdata_out.header.chanlocs(chanpos)=chanloc;
            end
            
            
            numevents=size(trg,2);
            if numevents==0;
                lwdata_out.header.events=[];
            else
                for eventpos=1:numevents
                    event.code='unknown';
                    if isempty(trg(eventpos).value);
                        event.code=trg(eventpos).type;
                    else
                        event.code=trg(eventpos).value;
                    end
                    if isnumeric(event.code);
                        event.code=num2str(event.code);
                    end
                    event.latency=(trg(eventpos).sample*lwdata_out.header.xstep)+lwdata_out.header.xstart;
                    event.epoch=1;
                    lwdata_out.header.events(eventpos)=event;
                end
            end
            
            if option.is_save
                lwdata_out.header=CLW_check_header(lwdata_out.header);
                CLW_save(lwdata_out);
            end
        end
    end
end