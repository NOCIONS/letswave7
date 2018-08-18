function [FileName,PathName] = GLW_getfile(varargin)
%[FileName,PathName] = GLW_getfile({obj.virtual_filelist.filename})
handles=[];
handles.file_str = 0;
handles.file_path = 0;
handles.virtual_filelist=[];
if ~isempty(varargin)
    handles.virtual_filelist=cellstr(varargin{1});
end
GLW_getfile_Init();
set(handles.fig,'WindowStyle','modal');
uiwait(handles.fig);
FileName=handles.file_str;
PathName=handles.file_path;

    function GLW_getfile_Init()
        handles.fig=figure('Position',[100 50 500 670],'color',[0.7,0.7,0.7],...
            'name','Select Files','NumberTitle','off');
        set(handles.fig,'MenuBar','none');
        set(handles.fig,'DockControls','off');
        
        icon=load('icon.mat');
        handles.refresh_btn=uicontrol('style','pushbutton',...
            'CData',icon.icon_refresh,'position',[472,638,26,26]);
        handles.path_btn=uicontrol('style','pushbutton',...
            'CData',icon.icon_open_path,'position',[446,638,26,26]);
        handles.path_edit=uicontrol('style','edit',...
            'HorizontalAlignment','left','position',[3,637,443,28]);
        uicontrol('style','text','BackgroundColor',[0.7,0.7,0.7],...
            'string','Selected:','HorizontalAlignment',...
            'left','position',[5,600,80,28]);
        handles.isfilter_checkbox=uicontrol('style','checkbox',...
            'BackgroundColor',[0.7,0.7,0.7],...
            'string','Filter','position',[80,608,100,28]);
        handles.suffix_selected_listbox=uicontrol('style','listbox',...
            'string','Filter','position',[5,292,120,320]);
        uicontrol('style','text','BackgroundColor',[0.7,0.7,0.7],...
            'string','Banned:','HorizontalAlignment','left','position',[5,255,80,28]);
        handles.suffix_baned_listbox=uicontrol('style','listbox',...
            'string','Filter','position',[5,5,120,262]);
        uicontrol('style','text','BackgroundColor',[0.7,0.7,0.7],...
            'string','Datasets:','HorizontalAlignment','left',...
            'position',[140,600,80,28]);
        handles.file_listbox=uicontrol('style','listbox',...
            'string','Filter','position',[140,70,355,542]);
        handles.info_text_epoch=uicontrol('style','text','BackgroundColor',[0.7,0.7,0.7],...
            'string','Epoch:','position',[140,45,100,19],...
            'HorizontalAlignment','left');
        handles.info_text_channel=uicontrol('style','text','BackgroundColor',[0.7,0.7,0.7],...
            'string','Channel:','position',[200,45,100,19],...
            'HorizontalAlignment','left');
        handles.info_text_X=uicontrol('style','text','BackgroundColor',[0.7,0.7,0.7],...
            'string','X:','position',[280,45,100,19],...
            'HorizontalAlignment','left');
        handles.info_text_Y=uicontrol('style','text','BackgroundColor',[0.7,0.7,0.7],...
            'string','Y:','position',[350,45,100,19],...
            'HorizontalAlignment','left');
        handles.info_text_Z=uicontrol('style','text','BackgroundColor',[0.7,0.7,0.7],...
            'string','Z:','position',[400,45,100,19],...
            'HorizontalAlignment','left');
        handles.info_text_Index=uicontrol('style','text','BackgroundColor',[0.7,0.7,0.7],...
            'string','Index:','position',[440,45,100,19],...
            'HorizontalAlignment','left');
        handles.OK_btn=uicontrol('style','pushbutton',...
            'string','OK','position',[140,5,170,35]);
        handles.Cancle_btn=uicontrol('style','pushbutton',...
            'string','Cancel','position',[325,5,170,35]);
        set(handles.suffix_selected_listbox,'max',2,'min',0);
        set(handles.suffix_baned_listbox,'max',2,'min',0);
        set(handles.file_listbox,'max',2,'min',0);
        set(handles.path_edit,'BackgroundColor',[1,1,1]);
        set(handles.suffix_selected_listbox,'BackgroundColor',[1,1,1]);
        set(handles.suffix_baned_listbox,'BackgroundColor',[1,1,1]);
        set(handles.file_listbox,'BackgroundColor',[1,1,1]);
        st=get(handles.fig,'children');
        for k=1:length(st)
            try
                set(st(k),'units','normalized');
            end
        end
        set(handles.path_edit,'String',pwd);
        set(handles.path_edit,'Userdata',pwd);
        
        set(handles.refresh_btn,'Callback',{@(obj,events)update_handles()});
        set(handles.path_btn,'Callback',{@(obj,events)path_btn_Callback()});
        set(handles.path_edit,'Callback',{@(obj,events)path_edit_Callback()});
        set(handles.isfilter_checkbox,'Callback',{@(obj,events)update_handles()});
        set(handles.suffix_selected_listbox,'Callback',{@(obj,events)suffix_listbox_Callback()});
        set(handles.suffix_baned_listbox,'Callback',{@(obj,events)suffix_listbox_Callback()});
        set(handles.file_listbox,'Callback',{@(obj,events)file_listbox_Callback()});
        set(handles.OK_btn,'Callback',{@(obj,events)OK_btn_Callback()});
        set(handles.Cancle_btn,'Callback',{@(obj,events)fig_Close()});
        set(handles.fig,'CloseRequestFcn',{@(obj,events)fig_Close()});
        
        update_handles();
    end
    function file_listbox_Callback()
        if strcmp(get(gcf,'SelectionType'),'normal')
            file_listbox_select_changed();
            return;
        end
        if strcmp(get(gcf,'SelectionType'),'open')
            OK_btn_Callback();
        end
    end
    function file_listbox_select_changed()
        str=get(handles.file_listbox,'userdata');
        idx=get(handles.file_listbox,'value');
        if isempty(str)|| isempty(idx)
            filename='<empty>';
            set(handles.info_text_epoch,'string','epoch:');
            set(handles.info_text_channel,'string','channel:');
            set(handles.info_text_X,'string','X:');
            set(handles.info_text_Y,'string','Y:');
            set(handles.info_text_Z,'string','Z:');
            set(handles.info_text_Index,'string','Index:');
        else
            filename=str{idx(1)};
            try
            header = CLW_load_header(filename);
            set(handles.info_text_epoch,'string',['Epoch:',num2str(header.datasize(1))]);
            set(handles.info_text_channel,'string',['Channel:',num2str(header.datasize(2))]);
            set(handles.info_text_X,'string',['X:',num2str(header.datasize(6))]);
            set(handles.info_text_Y,'string',['Y:',num2str(header.datasize(5))]);
            set(handles.info_text_Z,'string',['Z:',num2str(header.datasize(4))]);
            set(handles.info_text_Index,'string',['Index:',num2str(header.datasize(3))]);
            catch
            set(handles.info_text_epoch,'string',['Epoch:Error']);
            set(handles.info_text_channel,'string',['Channel:Error']);
            set(handles.info_text_X,'string',['X:Error']);
            set(handles.info_text_Y,'string',['Y:Error']);
            set(handles.info_text_Z,'string',['Z:Error']);
            set(handles.info_text_Index,'string',['Index:Error']);
            end
        end
    end
    function suffix_listbox_Callback()
        set(handles.isfilter_checkbox,'value',1);
        update_handles;
    end
    function path_edit_Callback()
        str=get(handles.path_edit,'String');
        if exist(str,'dir')
            set(handles.path_edit,'String',str);
            update_handles;
            return;
        end
        [filepath,~,~] = fileparts(str);
        if exist(filepath,'dir')
            set(handles.path_edit,'String',filepath);
            update_handles;
        else
            filepath=get(handles.path_edit,'userdata');
            set(handles.path_edit,'String',filepath);
        end
    end
    function path_btn_Callback()
        st=get(handles.path_edit,'String');
        st=uigetdir(st);
        if ~isequal(st,0) && exist(st,'dir')==7
            set(handles.path_edit,'String',st);
            update_handles;
        end
    end
    function fig_Close()
        closereq;
        %close(handles.fig);
    end
    function OK_btn_Callback()
        idx=get(handles.file_listbox,'value');
        file_str=[];
        file_path=0;
        if ~isempty(idx)
            str=get(handles.file_listbox,'userdata');
            file_path=get(handles.path_edit,'userdata');
            if ~isempty(str)
                for k=1:length(idx)
                    [p,n,e]=fileparts(char(str(idx(k))));
                    file_str{k}=[n,e];
                end
            end
        end
        handles.file_str  = file_str;
        handles.file_path = file_path;
        closereq;
    end
    function update_handles()
        st=get(handles.path_edit,'String');
        if exist(st,'dir')~=7
            return;
        end
        set(handles.path_edit,'userdata',st);
        %cd(st);
        filename1=dir([st,filesep,'*.lw6']);
        filename2=dir([st,filesep,'*.lw5']);
        filename={filename1.name,filename2.name};
        filelist=cell(1,length(filename));
        filelist_suffix=cell(1,length(filename));
        for k=1:length(filename)
            filelist_suffix{k}=textscan(filename{k}(1:end-4),'%s');
            filelist_suffix{k}=filelist_suffix{k}{1}';
            switch(filename{k}(end))
                case '6'
                    filelist{k}=filename{k}(1:end-4);
                case '5'
                    filelist{k}=['<HTML><BODY color="blue">',filename{k}];
            end
        end
        if strcmp(fullfile(st,'0'),fullfile(pwd,'0'))
            for k=1:length(handles.virtual_filelist)
                if ~strcmp(handles.virtual_filelist{k},filelist)
                    filelist{end+1}=handles.virtual_filelist{k};
                    filename{end+1}=handles.virtual_filelist{k};
                    filelist_suffix{end+1}=textscan(filename{end}(1:end-4),'%s');
                    filelist_suffix{end}=filelist_suffix{end}{1}';
                end
            end
        end
        
        suffix=sort(unique([filelist_suffix{:}]));
        str=get(handles.suffix_selected_listbox,'String');
        idx=get(handles.suffix_selected_listbox,'value');
        if isempty(str)
            selected_str=[];
        else
            selected_str=str(idx);
        end
        
        str=get(handles.suffix_baned_listbox,'String');
        idx=get(handles.suffix_baned_listbox,'value');
        if isempty(str)
            baned_str=[];
        else
            baned_str=str(idx);
        end
        
        str=get(handles.file_listbox,'String');
        idx=get(handles.file_listbox,'value');
        if isempty(str)
            file_str=[];
        else
            file_str=str(idx);
        end
        if isempty(suffix)
            set(handles.isfilter_checkbox,'value',0);
        end
        
        is_filter=get(handles.isfilter_checkbox,'value');
        if is_filter==1
            set(handles.suffix_selected_listbox,'string',suffix);
            [~,selected_idx]=intersect(suffix,selected_str,'stable');
            set(handles.suffix_selected_listbox,'value',selected_idx);
            
            if isempty(selected_idx)
                selected_file_index=1:length(filelist);
            else
                selected_file_index=[];
                for k=1:length(filelist)
                    if isempty(setdiff(suffix(selected_idx),filelist_suffix{k}))
                        selected_file_index=[selected_file_index,k];
                    end
                end
            end
            
            if isempty(selected_file_index)
                set(handles.file_listbox,'String',{});
                set(handles.file_listbox,'userdata',{});
                set(handles.file_listbox,'value',[]);
                set(handles.suffix_baned_listbox,'String',{});
                set(handles.suffix_baned_listbox,'value',[]);
            else
                suffix_baned=sort(unique([filelist_suffix{selected_file_index}]));
                suffix_baned=setdiff(suffix_baned,suffix(selected_idx));
                [~,baned_idx]=intersect(suffix_baned,baned_str,'stable');
                set(handles.suffix_baned_listbox,'String',suffix_baned);
                set(handles.suffix_baned_listbox,'value',baned_idx);
                
                band_file_index=[];
                for j=selected_file_index
                    if isempty(intersect(suffix_baned(baned_idx),filelist_suffix{j}))
                        band_file_index=[band_file_index,j];
                    end
                end
                [~,idx]=intersect(filelist(band_file_index),file_str,'stable');
                set(handles.file_listbox,'String',filelist(band_file_index));
                set(handles.file_listbox,'userdata',{filename{band_file_index}});
                set(handles.file_listbox,'value',idx);
            end
        else
            set(handles.suffix_selected_listbox,'string',suffix);
            set(handles.suffix_selected_listbox,'value',[]);
            set(handles.suffix_baned_listbox,'string',suffix);
            set(handles.suffix_baned_listbox,'value',[]);
            set(handles.file_listbox,'string',filelist);
            set(handles.file_listbox,'userdata',filename);
            [~,idx]=intersect(filelist,file_str,'stable');
            set(handles.file_listbox,'value',idx);
        end
        
        file_listbox_select_changed();
        st=get(handles.path_edit,'userdata');
        filelist=get(handles.file_listbox,'String');
        if strcmp(fullfile(st,'0'),fullfile(pwd,'0'))
            for k=1:length(filelist)
                if sum(strcmp(handles.virtual_filelist,filelist{k}))
                    filelist{k}=['<HTML><BODY color="red">',filelist{k}];
                end
            end
        end
        set(handles.file_listbox,'String',filelist);
    end

end
