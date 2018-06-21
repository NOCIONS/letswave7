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
            set(obj.h_export_btn,'enable','off');
            set(obj.h_script_btn,'enable','off');
            
            set(obj.h_script_btn,'Callback',@obj.get_script);
            set(obj.h_export_btn,'Callback',@obj.export_file);
            set(obj.h_file_list,'Callback',@obj.on_select_chg);
            set(obj.h_fig,'windowstyle','modal');
            uiwait(obj.h_fig);
        end
        
        function obj=init_handles(obj)
            obj.h_fig=figure('name','Export Data to EEGLab','NumberTitle','off');
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
            for k=1:length(filename)
                filename{k}=filename{k}(1:end-4);
            end
            
            icon=load('icon.mat');
            obj.h_file_list=uicontrol('style','listbox','string','',...
                'HorizontalAlignment','left','value',[],'backgroundcolor',[1,1,1],...
                'max',10,'units','normalized','position',[0,0.08,1,0.92],...
                'string',filename,'userdata',filename);
            
            
            obj.h_export_btn=uicontrol('style','pushbutton','string','Export',...
                'HorizontalAlignment','Center',...
                'units','normalized','position',[0,0,0.8,0.08]);
            
            obj.h_script_btn=uicontrol('style','pushbutton',...
                'HorizontalAlignment','Center','CData',icon.icon_script,...
                'units','normalized','position',[0.8,0,0.2,0.08]);
            
        end
        
        function obj=on_select_chg(obj,varargin)
            v=get(obj.h_file_list,'value');
            userdata=get(obj.h_file_list,'userdata');
            set(obj.h_file_list,'string',userdata);
            if isempty(v)
                set(obj.h_export_btn,'enable','off');
                set(obj.h_script_btn,'enable','off');
            else
                set(obj.h_export_btn,'enable','on');
                set(obj.h_script_btn,'enable','on');
            end
            
        end
        
        function get_script(obj,varargin)
            userdata=get(obj.h_file_list, 'userdata');
            value=get(obj.h_file_list, 'value');
            script={};
            script{end+1}='LW_init();';
            for k=value
                script{end+1}=['FLW_export_EEGLAB.get_lwdata(',...
                    '''filename'',''',userdata{k},'.lw6',''','...
                    '''pathname'',''',cd,''');'];
            end
            CLW_show_script(script);
        end
        
        function obj=export_file(obj,varargin)
            userdata=get(obj.h_file_list, 'userdata');
            value=get(obj.h_file_list, 'value');
            str=userdata;
            for k=value
                str{k}=['<html><b>',userdata{k},'&nbsp;&nbsp;(processing...)</b></html>'];
                set( obj.h_file_list,'String',str);
                pause(0.01);
                option.filename=[userdata{k},'.lw6'];
                option.pathname=cd;
                FLW_export_EEGLAB.get_lwdata(option);
                
                str{k}=['<html><p style="color:red">',userdata{k},'&nbsp;&nbsp;(Done)</p></html>'];
                set( obj.h_file_list,'String',str);
                pause(0.01);
            end
            set(obj.h_file_list, 'value',[]);
            set(obj.h_export_btn,'enable','off');
            set(obj.h_script_btn,'enable','off');
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
            [p,n]=fileparts(str);
            EEG.setname=n;
            EEG.filename=[];
            EEG.filepath=[];
            header = CLW_load_header(str);
            EEG.nbchan=header.datasize(2);
            EEG.trials=header.datasize(1);
            EEG.pnts=header.datasize(6);
            EEG.srate=1/header.xstep;
            EEG.times=header.xstart+(0:EEG.pnts-1)*header.xstep;
            EEG.xmin=EEG.times(1);
            EEG.xmax=EEG.times(end);
            load(fullfile(p,[n,'.mat']),'data','-MAT');
            data=permute(single(data),[2,6,1,3,4,5]);
            EEG.data=data;clear data;
            EEG.chanlocs=rmfield(header.chanlocs,'SEEG_enabled');
            EEG.chanlocs=rmfield(header.chanlocs,'topo_enabled');
            EEG.event=header.events;
            if ~isempty(EEG.event)
                [EEG.event.type] = EEG.event.code;
                temp=num2cell([EEG.event.latency]/header.xstep);
                [EEG.event.latency]=deal(temp{:});
                EEG.event = rmfield(EEG.event,'code');
            end
            
            EEG.icawinv=[];
            EEG.icaweights=[];
            EEG.icasphere=[];
            EEG.icaweights=[];
            EEG.icaweights=[];
            EEG.icaweights=[];
            EEG.icaweights=[];
            
            
            save([n,'.set'],'EEG');
            %EEG.epoch=[];
        end
    end
end