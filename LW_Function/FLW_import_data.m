classdef FLW_import_data
    properties
        h_fig;
        h_file_list;
        h_add_btn;
        h_del_btn;
        h_import_btn;
        h_script_btn;
        h_toolbar;
        h_parent;
    end

    methods
        function obj = FLW_import_data(varargin)
            if ~isempty(varargin)
                obj.h_parent=varargin{1};
            else
                obj.h_parent=[];
            end
            obj=obj.init_handles();
            userdata.file_path={};
            userdata.file_name={};
            set(obj.h_file_list,'userdata',userdata);
            set(obj.h_del_btn,'enable','off');
            set(obj.h_import_btn,'enable','off');
            set(obj.h_script_btn,'enable','off');

            set(obj.h_add_btn,'Callback',@obj.add_file);
            set(obj.h_del_btn,'Callback',@obj.del_file);
            set(obj.h_script_btn,'Callback',@obj.get_script);
            set(obj.h_import_btn,'Callback',@obj.import_file);
            uiwait(obj.h_fig);
        end

        function obj=init_handles(obj)
            obj.h_fig=figure('name','Import Data','NumberTitle','off','resize','off');
            set(obj.h_fig,'windowstyle','modal');
            pos=get(obj.h_fig,'Position');

            pos(3:4)=[300 510];
            scrsz = get(0,'MonitorPositions');
            scrsz=scrsz(1,:);
            if pos(1)+pos(3)>scrsz(3)
                pos(1)=(scrsz(3)-pos(3))/2;
            end
            if pos(2)+pos(4)+100>scrsz(4)
                pos(2)=(scrsz(4)-pos(4)-100)/2;
            end
            set(obj.h_fig,'Position',pos);

            set(obj.h_fig,'MenuBar','none');
            set(obj.h_fig,'DockControls','off');

            icon=load('icon.mat');
            obj.h_add_btn=uicontrol(obj.h_fig,'style','pushbutton');
            set(obj.h_add_btn,'TooltipString','add files');
            set(obj.h_add_btn,'CData',icon.icon_dataset_add);

            obj.h_del_btn=uicontrol(obj.h_fig,'style','pushbutton');
            set(obj.h_del_btn,'TooltipString','remove files');
            set(obj.h_del_btn,'CData',icon.icon_dataset_del);

            obj.h_script_btn=uicontrol(obj.h_fig,'style','pushbutton');
            set(obj.h_script_btn,'TooltipString','show script');
            set(obj.h_script_btn,'CData',icon.icon_script);

            obj.h_import_btn=uicontrol(obj.h_fig,'style','pushbutton');
            set(obj.h_import_btn,'TooltipString','import files');
            set(obj.h_import_btn,'CData',icon.icon_run);

            set(obj.h_add_btn,'position',[0,pos(4)-29, 30, 30]);
            set(obj.h_del_btn,'position',[29,pos(4)-29, 30, 30]);
            set(obj.h_script_btn,'position',[29*2,pos(4)-29, 30, 30]);
            set(obj.h_import_btn,'position',[29*3,pos(4)-29, 30, 30]);
            obj.h_file_list=uicontrol('style','listbox','string','',...
                'HorizontalAlignment','left','backgroundcolor',[1,1,1],...
                'Fontsize',14,'value',[],'max',10);
            set(obj.h_file_list,'position',[0,0, pos(3), pos(4)-29]);
            set(obj.h_file_list,'units','normalized');

        end

        function obj=add_file(obj,varargin)
            filterspec={'*.set;*.avr;*.cnt;*.eeg;*.bdf;*.raw;*.hdf5;*.edf;*.gdf;*.avg','All support files';
                '*.set','EEGLAB (*.set)';
                '*.avr;*.cnt','ANT Neuro, eeprobe/cnt-riff (*.avr, *.cnt)';
                '*.eeg;*.cnt;*.avg','NeuroScan (*.eeg, *.cnt, *.avg)';
                '*.bdf','Biosemi BDF，eCon BDF (*.bdf)';
                '*.eeg','BrainVision ( *.eeg)';
                '*.raw','Electrical Geodesics, Inc. (EGI) (*.raw)';
                '*.hdf5','g.tec medical engineering GmbH (gtec) (*.hdf5)';
                '*.edf;*.gdf','generic standard formats (*.edf, *.gdf)'};
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
            script{end+1}='LW_init();';
            if ~isempty(userdata.file_path)
                for k=1:length(userdata.file_path)
                    script{end+1}=['FLW_import_data.get_lwdata(',...
                        '''filename'',''',userdata.file_name{k},''','...
                        '''pathname'',''',userdata.file_path{k},''','...
                        '''is_save'',1);'];
                    script{end+1}='';
                end
            end
            CLW_show_script(script);
        end

        function obj=import_file(obj,varargin)
            userdata=get(obj.h_file_list, 'userdata');
            if ~isempty(userdata.file_path)
                set(obj.h_file_list,'String',userdata.file_name);
                str=get( obj.h_file_list, 'String' );
                for k=1:length(userdata.file_path)
                    str{k}=['<html><b>',userdata.file_name{k},'&nbsp;&nbsp;(processing...)</b></html>'];
                    set( obj.h_file_list,'String',str);
                    pause(0.01);
                    option.filename=userdata.file_name{k};
                    option.pathname=userdata.file_path{k};
                    option.is_save=1;
                    FLW_import_data.get_lwdata(option);
                    if ~isempty(obj.h_parent)
                        set(obj.h_parent,'userdata',1);
                    end

                    str{k}=['<html><p style="color:red">',userdata.file_name{k},'&nbsp;&nbsp;(Done)</p></html>'];
                    set( obj.h_file_list,'String',str);
                    set( obj.h_file_list,'value',min(k+3,length(userdata.file_path)));
                    set( obj.h_file_list,'value',min(k+1,length(userdata.file_path)));
                    drawnow;
                    %pause(0.01);
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
            [~,name,ext] = fileparts(str);
            if strcmp(lower(ext),'.bdf')
                fid=fopen(str,'r','ieee-le');
                H1=char(fread(fid,256,'char')');
                if strcmp(H1(115:123),'iRecorder')
                    ext='.econ';
                end
                fclose(fid);
            end
            switch lower(ext)
                case '.econ'
                    hdr = read_bdf(str);
                    dat = read_bdf(str, hdr, 1, hdr.nSamples, 1:hdr.nChans);
                    lwdata_out.data=permute(single(dat),[3,1,4,5,6,2]);

                    lwdata_out.header=[];
                    lwdata_out.header.filetype='time_amplitude';
                    lwdata_out.header.name= name;
                    lwdata_out.header.tags='';
                    lwdata_out.header.datasize=[1 length(hdr.label) 1 1 1 hdr.nSamples];
                    lwdata_out.header.xstart=0;
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
                    for chanpos=1:length(hdr.label)
                        chanloc.labels=hdr.label{chanpos};
                        lwdata_out.header.chanlocs(chanpos)=chanloc;
                    end

                    lwdata_out.header.events=struct('code',{},'latency',{},'epoch',{});
                    for eventpos=1:length(hdr.event)
                        event.code=hdr.event{eventpos}.eventvalue;
                        if isnumeric(event.code)
                            event.code=num2str(event.code);
                        end
                        event.latency=hdr.event{eventpos}.offset_in_sec;
                        event.epoch=1;
                        lwdata_out.header.events(eventpos)=event;
                    end

                case '.edf'
                    [data, header] = Read_EDF_BDF(str);
                    temp=unique(header.samplerate);
                    if length(temp)~=1
                        error('All channels should with the same sampling rate');
                    end
                    lwdata_out.header=[];
                    lwdata_out.header.filetype='time_amplitude';
                    lwdata_out.header.name= name;
                    lwdata_out.header.tags='';
                    lwdata_out.header.datasize=[1 length(header.labels) 1 1 1 length(data{1})];
                    lwdata_out.header.xstart=1/temp;
                    lwdata_out.header.ystart=0;
                    lwdata_out.header.zstart=0;
                    lwdata_out.header.xstep=1/temp;
                    lwdata_out.header.ystep=1;
                    lwdata_out.header.zstep=1;
                    lwdata_out.header.history=[];
                    lwdata_out.header.source=str;

                    chanloc.labels='';
                    chanloc.topo_enabled=0;
                    chanloc.SEEG_enabled=0;
                    for chanpos=1:length(header.labels)
                        chanloc.labels=header.labels{chanpos};
                        lwdata_out.header.chanlocs(chanpos)=chanloc;
                    end

                    numevents=size(header.annotation.event,2);
                    if numevents==0
                        lwdata_out.header.events=[];
                    else
                        for eventpos=1:numevents
                            event.code=header.annotation.event{eventpos};
                            if isnumeric(event.code)
                                event.code=num2str(event.code);
                            end
                            event.latency=header.annotation.starttime(eventpos);
                            event.epoch=1;
                            lwdata_out.header.events(eventpos)=event;
                        end
                    end
                    data=permute(cell2mat(data),[3,2,4,5,6,1]);
                    lwdata_out.data=data;
                case '.hdf5'
                    orig = ghdf5fileimport(str);
                    for i=1:numel(orig.RawData.AcquisitionTaskDescription.ChannelProperties.ChannelProperties)
                        lab = orig.RawData.AcquisitionTaskDescription.ChannelProperties.ChannelProperties(i).ChannelName;
                        typ = orig.RawData.AcquisitionTaskDescription.ChannelProperties.ChannelProperties(1).ChannelType;
                        if isnumeric(lab)
                            hdr.label{i} = num2str(lab);
                        else
                            hdr.label{i} = lab;
                        end
                        if ischar(typ)
                            hdr.chantype{i} = lower(typ);
                        else
                            hdr.chantype{i} = 'unknown';
                        end
                    end
                    hdr.Fs          = orig.RawData.AcquisitionTaskDescription.SamplingFrequency;
                    hdr.nChans      = size(orig.RawData.Samples, 1);
                    hdr.nSamples    = size(orig.RawData.Samples, 2);
                    dat = orig.RawData.Samples(1:hdr.nChans,:);
                    lwdata_out.data=permute(single(dat),[3,1,4,5,6,2]);
                    lwdata_out.header=[];
                    lwdata_out.header.filetype='time_amplitude';
                    lwdata_out.header.name= name;
                    lwdata_out.header.tags='';
                    lwdata_out.header.datasize=[1 hdr.nChans 1 1 1 hdr.nSamples];
                    lwdata_out.header.xstart=0;
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
                    for chanpos=1:hdr.nChans
                        chanloc.labels=hdr.label{chanpos};
                        lwdata_out.header.chanlocs(chanpos)=chanloc;
                    end


                    Time=double(orig.AsynchronData.Time);
                    TypeID=orig.AsynchronData.TypeID;
                    Value=orig.AsynchronData.Value;
                    is_combine=0;
                    for k=1:length(orig.AsynchronData.AsynchronSignalTypes.AsynchronSignalDescription)
                        if strcmpi(orig.AsynchronData.AsynchronSignalTypes.AsynchronSignalDescription(k).IsCombinedSignal,'true')
                            is_combine=1;
                            break;
                        end
                    end
                    if is_combine==1
                        idx=find(Value>32768);
                        Value1=Value/256;
                        idx=find(Value1>128);
                        Value1(idx)=Value1(idx)-256;
                        lwdata_out.header.events=struct('code',{},'latency',{},'epoch',{});
                        for eventpos=1:size(Time,2)
                            event.latency = (Time(eventpos)*lwdata_out.header.xstep)+lwdata_out.header.xstart;
                            event.code = Value1(eventpos);
                            if isnumeric(event.code)
                                if (event.code<0)
                                    event.code=['M',num2str(-event.code)];
                                else
                                    event.code=['S',num2str(event.code)];
                                end
                            end
                            event.epoch=1;
                            lwdata_out.header.events(eventpos)=event;
                        end
                    else
                        dict_ID_Name=struct();
                        for k=1:length(orig.AsynchronData.AsynchronSignalTypes.AsynchronSignalDescription)
                            if  isempty(orig.AsynchronData.AsynchronSignalTypes.AsynchronSignalDescription(k).Description)
                                dict_ID_Name.(['x' num2str(orig.AsynchronData.AsynchronSignalTypes.AsynchronSignalDescription(k).ID)])=...
                                    orig.AsynchronData.AsynchronSignalTypes.AsynchronSignalDescription(k).Name;
                            else
                                dict_ID_Name.(['x' num2str(orig.AsynchronData.AsynchronSignalTypes.AsynchronSignalDescription(k).ID)])=...
                                    orig.AsynchronData.AsynchronSignalTypes.AsynchronSignalDescription(k).Description;
                            end
                        end
                        lwdata_out.header.events=struct('code',{},'latency',{},'epoch',{});
                        for eventpos=1:size(Time,2)
                            event.latency = (Time(eventpos)*lwdata_out.header.xstep)+lwdata_out.header.xstart;
                            event.code = dict_ID_Name.(['x' num2str(TypeID(eventpos))]);
                            if isnumeric(event.code)
                                event.code=num2str(event.code);
                            end
                            event.epoch=1;
                            lwdata_out.header.events(eventpos)=event;
                        end
                    end
                otherwise
                    if lower(ext)=='.bdf'
                        hdr = read_bdf(str);
                    else
                        hdr=ft_read_header(str);
                        trg=ft_read_event(str,'header',hdr);
                        [~,name,~] = fileparts(str);
                        lwdata_out.data=permute(single(ft_read_data(str,'header',hdr)),[3,1,4,5,6,2]);
                        %epoch,channel,index,Z,Y,X
                        %channel,X,epoch,1,1,1

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
                        for chanpos=1:hdr.nChans
                            chanloc.labels=hdr.label{chanpos};
                            lwdata_out.header.chanlocs(chanpos)=chanloc;
                        end


                        numevents=size(trg,2);
                        if numevents==0
                            lwdata_out.header.events=[];
                        else
                            k=0;
                            for eventpos=1:numevents
                                event.code='unknown';
                                if strcmpi('.set',ext)
                                    if isempty(trg(eventpos).value)
                                        event.code=trg(eventpos).type;
                                    else
                                        event.code=trg(eventpos).value;
                                    end
                                    if isnumeric(event.code)
                                        event.code=num2str(event.code);
                                    end
                                    if(lwdata_out.header.datasize(1)==1) %if it is continous data or just a single epoch
                                        event.latency=(trg(eventpos).sample*lwdata_out.header.xstep)+lwdata_out.header.xstart;
                                        event.epoch=1;
                                    else %if it is an epoched dataset
                                        if isempty(trg(eventpos).epoch)
                                            continue;
                                        end
                                        event.epoch = floor(trg(eventpos).sample/lwdata_out.header.datasize(6))+1;
                                        event.latency=((trg(eventpos).sample*lwdata_out.header.xstep)+lwdata_out.header.xstart)-...
                                            (event.epoch-1)*lwdata_out.header.xstep*lwdata_out.header.datasize(6);
                                    end
                                else
                                    if isempty(trg(eventpos).value)
                                        event.code=trg(eventpos).type;
                                    else
                                        event.code=trg(eventpos).value;
                                    end
                                    if isnumeric(event.code)
                                        event.code=num2str(event.code);
                                    end
                                    event.latency=(trg(eventpos).sample*lwdata_out.header.xstep)+lwdata_out.header.xstart;
                                    event.epoch=1;
                                end
                                k=k+1;
                                lwdata_out.header.events(k)=event;
                            end
                        end
                    end
            end

            %             if strcmpi('.edf',ext) %|| strcmpi('.bdf',ext)
            %                 [data, header] = Read_EDF_BDF(str);
            %                 temp=unique(header.samplerate);
            %                 if length(temp)~=1
            %                     error('All channels should with the same sampling rate');
            %                 end
            %                 lwdata_out.header=[];
            %                 lwdata_out.header.filetype='time_amplitude';
            %                 lwdata_out.header.name= name;
            %                 lwdata_out.header.tags='';
            %                 lwdata_out.header.datasize=[1 length(header.labels) 1 1 1 length(data{1})];
            %                 lwdata_out.header.xstart=0;
            %                 lwdata_out.header.ystart=0;
            %                 lwdata_out.header.zstart=0;
            %                 lwdata_out.header.xstep=1/temp;
            %                 lwdata_out.header.ystep=1;
            %                 lwdata_out.header.zstep=1;
            %                 lwdata_out.header.history=[];
            %                 lwdata_out.header.source=str;
            %
            %                 chanloc.labels='';
            %                 chanloc.topo_enabled=0;
            %                 chanloc.SEEG_enabled=0;
            %                 for chanpos=1:length(header.labels)
            %                     chanloc.labels=header.labels{chanpos};
            %                     lwdata_out.header.chanlocs(chanpos)=chanloc;
            %                 end
            %
            %                 numevents=size(header.annotation.event,2);
            %                 if numevents==0
            %                     lwdata_out.header.events=[];
            %                 else
            %                     for eventpos=1:numevents
            %                         event.code=header.annotation.event{eventpos};
            %                         if isnumeric(event.code)
            %                             event.code=num2str(event.code);
            %                         end
            %                         event.latency=header.annotation.starttime(eventpos);
            %                         event.epoch=1;
            %                         lwdata_out.header.events(eventpos)=event;
            %                     end
            %                 end
            %                 data=permute(cell2mat(data),[3,2,4,5,6,1]);
            %                 lwdata_out.data=data;
            %             else
            %                 hdr=ft_read_header(str);
            %                 trg=ft_read_event(str,'header',hdr);
            %                 [~,name,~] = fileparts(str);
            %                 lwdata_out.data=permute(single(ft_read_data(str,'header',hdr)),[3,1,4,5,6,2]);
            %                 %epoch,channel,index,Z,Y,X
            %                 %channel,X,epoch,1,1,1
            %
            %                 lwdata_out.header=[];
            %                 lwdata_out.header.filetype='time_amplitude';
            %                 lwdata_out.header.name= name;
            %                 lwdata_out.header.tags='';
            %                 lwdata_out.header.datasize=[hdr.nTrials hdr.nChans 1 1 1 hdr.nSamples];
            %                 lwdata_out.header.xstart=(hdr.nSamplesPre/hdr.Fs)*-1;
            %                 lwdata_out.header.ystart=0;
            %                 lwdata_out.header.zstart=0;
            %                 lwdata_out.header.xstep=1/hdr.Fs;
            %                 lwdata_out.header.ystep=1;
            %                 lwdata_out.header.zstep=1;
            %                 lwdata_out.header.history=[];
            %                 lwdata_out.header.source=str;
            %
            %                 chanloc.labels='';
            %                 chanloc.topo_enabled=0;
            %                 chanloc.SEEG_enabled=0;
            %                 for chanpos=1:hdr.nChans
            %                     chanloc.labels=hdr.label{chanpos};
            %                     lwdata_out.header.chanlocs(chanpos)=chanloc;
            %                 end
            %
            %
            %                 numevents=size(trg,2);
            %                 if numevents==0
            %                     lwdata_out.header.events=[];
            %                 else
            %                     k=0;
            %                     for eventpos=1:numevents
            %                         event.code='unknown';
            %                         if strcmpi('.set',ext)
            %                             if isempty(trg(eventpos).value)
            %                                 event.code=trg(eventpos).type;
            %                             else
            %                                 event.code=trg(eventpos).value;
            %                             end
            %                             if isnumeric(event.code)
            %                                 event.code=num2str(event.code);
            %                             end
            %                             if(lwdata_out.header.datasize(1)==1) %if it is continous data or just a single epoch
            %                                 event.latency=(trg(eventpos).sample*lwdata_out.header.xstep)+lwdata_out.header.xstart;
            %                                 event.epoch=1;
            %                             else %if it is an epoched dataset
            %                                 if isempty(trg(eventpos).epoch)
            %                                     continue;
            %                                 end
            %                                 event.epoch = floor(trg(eventpos).sample/lwdata_out.header.datasize(6))+1;
            %                                 event.latency=((trg(eventpos).sample*lwdata_out.header.xstep)+lwdata_out.header.xstart)-...
            %                                     (event.epoch-1)*lwdata_out.header.xstep*lwdata_out.header.datasize(6);
            %                             end
            %                         else
            %                             if isempty(trg(eventpos).value)
            %                                 event.code=trg(eventpos).type;
            %                             else
            %                                 event.code=trg(eventpos).value;
            %                             end
            %                             if isnumeric(event.code)
            %                                 event.code=num2str(event.code);
            %                             end
            %                             event.latency=(trg(eventpos).sample*lwdata_out.header.xstep)+lwdata_out.header.xstart;
            %                             event.epoch=1;
            %                         end
            %                         k=k+1;
            %                         lwdata_out.header.events(k)=event;
            %                     end
            %                 end
            %             end

            if option.is_save
                lwdata_out.header=CLW_check_header(lwdata_out.header);
                CLW_save(lwdata_out);
            end

            if nargout>0
                lwdata_out.data=double(lwdata_out.data);
            end
        end
    end
end