classdef FLW_import_data
    properties
        h_fig;
        h_file_list;
        h_add_btn;
        h_del_btn;
        h_import_btn;
        h_script_btn;
        h_toolbar;
    end
    
    methods
        function obj = FLW_import_data()
            obj=obj.init_handles();
            userdata.file_path={};
            userdata.file_name={};
            set(obj.h_file_list,'userdata',userdata);
            set(obj.h_del_btn,'enable','off');
            set(obj.h_import_btn,'enable','off');
            set(obj.h_script_btn,'enable','off');
            
            set(obj.h_add_btn,'ClickedCallback',@obj.add_file);
            set(obj.h_del_btn,'ClickedCallback',@obj.del_file);
            set(obj.h_script_btn,'ClickedCallback',@obj.get_script);
            set(obj.h_import_btn,'ClickedCallback',@obj.import_file);
            uiwait(obj.h_fig);
        end
        
        
        function obj=init_handles(obj)
            obj.h_fig=figure('name','Import Data','NumberTitle','off');
            pos=get(obj.h_fig,'Position');
            pos(3:4)=[300 510];
            set(obj.h_fig,'Position',pos);
            
            set(obj.h_fig,'MenuBar','none');
            set(obj.h_fig,'DockControls','off');
            
            icon=load('icon.mat');
            obj.h_toolbar = uitoolbar(obj.h_fig);
            
            obj.h_add_btn = uipushtool(obj.h_toolbar);
            set(obj.h_add_btn,'TooltipString','add files');
            set(obj.h_add_btn,'CData',icon.icon_dataset_add);
            
            obj.h_del_btn = uipushtool(obj.h_toolbar);
            set(obj.h_del_btn,'TooltipString','remove files');
            set(obj.h_del_btn,'CData',icon.icon_dataset_del);
            
            obj.h_script_btn = uipushtool(obj.h_toolbar);
            set(obj.h_script_btn,'TooltipString','show script');
            set(obj.h_script_btn,'CData',icon.icon_script);
            
            obj.h_import_btn = uipushtool(obj.h_toolbar);
            set(obj.h_import_btn,'TooltipString','import files');
            set(obj.h_import_btn,'CData',icon.icon_import);
            
            
            obj.h_file_list=uicontrol('style','listbox','string','',...
                'HorizontalAlignment','left',...
                'Fontsize',14,'value',[],'max',10);
            set(obj.h_file_list,'units','normalized');
            set(obj.h_file_list,'position',[0,0,1,1]);
            
        end
        
        function obj=add_file(obj,varargin)
            %             filterspec={'*.avr;*.cnt','ANT Neuro, eeprobe/cnt-riff (*.avr, *.cnt)';
            %                 '*.bdf','Biosemi BDF (*.bdf)';
            %                 '*.smr','CED - Cambridge Electronic Design (*.smr)';
            %                 '*.egis;*.ave;*.gave;*.ses;*.raw;*.mff','Electrical Geodesics, Inc. (EGI) (*.egis, *.ave, *.gave, *.ses, *.raw, *.mff)';
            %                 '*.avr;*.swf','BESA (*.avr, *.swf)';
            %                 '*.set','EEGLAB (*.set)';
            %                 '*.eeg;*.cnt;*.avg','NeuroScan (*.eeg, *.cnt, *.avg)';
            %                 '*.nxe','Nexstim (*.nxe)';
            %                 '*.eeg;*.seg;*.dat;*.vhdr;*.vmrk','BrainVision (*.eeg, *.seg, *.dat, *.vhdr, *.vmrk)';
            %                 '*.Poly5','TMSi (*.Poly5)';
            %                 '*.edf;*.gdf','generic standard formats (*.edf, *.gdf)'};
            filterspec={'*.avr;*.cnt','ANT Neuro, eeprobe/cnt-riff (*.avr, *.cnt)';
                        '*.eeg;*.cnt;*.avg','NeuroScan (*.eeg, *.cnt, *.avg)';
                        '*.egis;*.ave;*.gave;*.ses;*.raw;*.mff','Electrical Geodesics, Inc. (EGI) (*.egis, *.ave, *.gave, *.ses, *.raw, *.mff)'};
            [filename,pathname] = uigetfile(filterspec,'File Selector','MultiSelect','on');
            userdata=get(obj.h_file_list, 'userdata');
            if pathname~=0
                if ~iscell(filename)
                    filename={filename};
                end
                for k=1:length(filename)
                    userdata.file_path{end+1}=pathname;
                    userdata.file_name{end+1}=filename{k};
                end
                set(obj.h_file_list,'String',userdata.file_name);
                set(obj.h_file_list,'userdata',userdata);
                
                if ~isempty(userdata.file_name)
                    set(obj.h_del_btn,'enable','on');
                    set(obj.h_import_btn,'enable','on');
                    set(obj.h_script_btn,'enable','on');
                end
            end
        end
        
        function obj=del_file(obj,varargin)
            userdata=get(obj.h_file_list, 'userdata');
            value=get(obj.h_file_list, 'value');
            
            value_diff=setdiff(1:length(userdata.file_name),value);
            userdata.file_path=userdata.file_path(value_diff);
            userdata.file_name=userdata.file_name(value_diff);
            set(obj.h_file_list,'value',[]);
            if isempty(value_diff)
                set(obj.h_del_btn,'enable','off');
                set(obj.h_import_btn,'enable','off');
                set(obj.h_script_btn,'enable','off');
            end
            set(obj.h_file_list,'String',userdata.file_name);
            set(obj.h_file_list,'userdata',userdata);
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
        
        function obj=import_file(obj,varargin)
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
        function lwdata_out=get_lwdata(varargin)
            lwdata_out=[];
            option.filename=[];
            option.pathname='';
            option.is_save=1;
            option=CLW_check_input(option,{'filename','pathname','is_save'},varargin);
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
                CLW_save(lwdata_out);
            end
        end
    end
end