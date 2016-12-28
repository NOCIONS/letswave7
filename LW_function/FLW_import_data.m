classdef FLW_import_data
    properties
    end
    
    methods
        function obj = FLW_import_data()
            filterspec={'*.avr;*.cnt','ANT Neuro, eeprobe/cnt-riff (*.avr, *.cnt)';
                '*.bdf','Biosemi BDF (*.bdf)';
                '*.smr','CED - Cambridge Electronic Design (*.smr)';
                '*.egis;*.ave;*.gave;*.ses;*.raw;*.mff','Electrical Geodesics, Inc. (EGI) (*.egis, *.ave, *.gave, *.ses, *.raw, *.mff)';
                '*.avr;*.swf','BESA (*.avr, *.swf)';
                '*.set','EEGLAB (*.set)';
                '*.eeg;*.cnt;*.avg','NeuroScan (*.eeg, *.cnt, *.avg)';
                '*.nxe','Nexstim (*.nxe)';
                '*.eeg;*.seg;*.dat;*.vhdr;*.vmrk','BrainVision (*.eeg, *.seg, *.dat, *.vhdr, *.vmrk)';
                '*.Poly5','TMSi (*.Poly5)';
                '*.edf;*.gdf','generic standard formats (*.edf, *.gdf)'};
            [filename,pathname] = uigetfile(filterspec,'File Selector','MultiSelect','on');
            if pathname==0
                option=[];
                uiwait(msgbox('Please select at least one file.','Warning','modal'));
                return;
            end
            if ~iscell(filename)
                filename={filename};
            end
            for k=1:length(filename)
                option.filename=filename{k};
                option.pathname=pathname;
                option.is_save=1;
                obj.get_lwdata(option);
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
            dat=ft_read_data(str);
            hdr=ft_read_header(str);
            trg=ft_read_event(str);
            
            
            out_header=[];
            out_data=[];
            out_header.filetype='time_amplitude';
            out_header.name= name;
            out_header.tags='';
            out_header.datasize=[hdr.nTrials hdr.nChans 1 1 1 hdr.nSamples];
            out_header.xstart=(hdr.nSamplesPre/hdr.Fs)*-1;
            out_header.ystart=0;
            out_header.zstart=0;
            out_header.xstep=1/hdr.Fs;
            out_header.ystep=1;
            out_header.zstep=1;
            out_header.history=[];
            
            chanloc.labels='';
            chanloc.topo_enabled=0;
            chanloc.SEEG_enabled=0;
            for chanpos=1:hdr.nChans;
                chanloc.labels=hdr.label{chanpos};
                out_header.chanlocs(chanpos)=chanloc;
            end
            
            
            numevents=size(trg,2);
            if numevents==0;
                out_header.events=[];
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
                    event.latency=(trg(eventpos).sample*out_header.xstep)+out_header.xstart;
                    event.epoch=1;
                    out_header.events(eventpos)=event;
                end
            end
            
            out_data=zeros(out_header.datasize);
            for chanpos=1:out_header.datasize(2);
                for epochpos=1:out_header.datasize(1);
                    out_data(epochpos,chanpos,1,1,1,:)=squeeze(dat(chanpos,:,epochpos));
                end
            end
            
            lwdata_out.header=out_header;
            lwdata_out.data=out_data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end