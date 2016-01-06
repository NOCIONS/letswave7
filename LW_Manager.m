function LW_Manager()
clc;
CLW_set_path;
handles=[];
Manager_Init();

    function Manager_Init()
        handles.fig=figure('Position',[100 50 500 670],...
            'name','Letswave7','NumberTitle','off');
       %% init menu
        set(handles.fig,'MenuBar','none');
        set(handles.fig,'DockControls','off');
        menu_name={'File','Edit','Process','Toolbox','Static','View',...
            'Plugins','Addition1','Addition2','Addition3'};
        for k=1:length(menu_name)
            str=['menu_',menu_name{k},'.xml'];
            if ~exist(str,'file')
                continue;
            end
            s= xml2struct(str);
            if ~isfield(s,'LW_Manager')||~isfield(s.LW_Manager,'menu')
                continue;                
            end
            root = uimenu(handles.fig,'Label',s.LW_Manager.Attributes.Label);
            s=s.LW_Manager.menu;
            if ~iscell(s); s={s};end
            for k1=1:length(s)
                mh = uimenu(root,'Label',s{k1}.Attributes.Label);
                if isfield(s{k1},'submenu')
                    ss=s{k1}.submenu;
                    if ~iscell(ss) ss={ss};end
                    for k2=1:length(ss)
                        eh = uimenu(mh,'Label',ss{k2}.Attributes.Label);
                        if isfield(ss{k2},'subsubmenu')
                            sss=ss{k2}.subsubmenu;
                            if ~iscell(sss) sss={sss};end
                            for k3=1:length(sss)
                                if isfield(sss{k3}.Attributes,'callback') 
                                    uimenu(eh,'Label',sss{k3}.Attributes.Label,...
                                        'callback',@(obj,event)menu_callback(sss{k3}.Attributes.callback));
                                else
                                    uimenu(eh,'Label',sss{k3}.Attributes.Label,...
                                        'enable', 'off');
                                end
                             end
                        else
                            if isfield(ss{k2}.Attributes,'callback') 
                                set(eh,'callback',@(obj,event)menu_callback(ss{k2}.Attributes.callback));
                            else
                                set(eh,'enable', 'off');
                            end
                        end
                    end
                else
                    if isfield(s{k1}.Attributes,'callback')
                        set(mh,'callback',@(obj,event)menu_callback(s{k1}.Attributes.callback));
                    else
                        set(mh,'enable', 'off');
                    end
                end
            end
        end
        hcmenu = uicontextmenu;
        uimenu(hcmenu,'Label','view','Callback',{@(obj,events)dataset_view()});
        uimenu(hcmenu,'Label','rename','Callback',{@(obj,events)menu_callback('GLW_rename')});
        uimenu(hcmenu,'Label','delete','Callback',{@(obj,events)menu_callback('GLW_delete')});
        uimenu(hcmenu,'Label','send to workspace','Callback',{@(obj,events)sendworkspace_btn_Callback});
        uimenu(hcmenu,'Label','read from workspace','Callback',{@(obj,events)readworkspace_btn_Callback});
        
        %% init the controler
        icon=load('icon.mat');
        handles.refresh_btn=uicontrol('style','pushbutton','CData',icon.icon_refresh,'position',[3,635,32,32]);
        handles.path_btn=uicontrol('style','pushbutton','CData',icon.icon_open_path,'position',[38,635,32,32]);
        handles.path_edit=uicontrol('style','edit','string',pwd,'HorizontalAlignment','left','position',[73,637,420,28]);
        uicontrol('style','text','string','Selected:','HorizontalAlignment','left','position',[5,600,80,28]);
        handles.isfilter_checkbox=uicontrol('style','checkbox','string','Filter','position',[80,608,100,28]);
        handles.affix_selected_listbox=uicontrol('style','listbox','string','Filter','position',[5,292,120,320]);
        uicontrol('style','text','string','Banned:','HorizontalAlignment','left','position',[5,255,80,28]);
        handles.affix_baned_listbox=uicontrol('style','listbox','string','Filter','position',[5,20,120,247]);
        uicontrol('style','text','string','Datasets:','HorizontalAlignment','left','position',[140,600,80,28]);
        handles.file_listbox=uicontrol('style','listbox','string','Filter','position',[140,40,355,572]);
        handles.info_text_epoch=uicontrol('style','text','string','Epoch:','position',[140,15,100,19],'HorizontalAlignment','left');
        handles.info_text_channel=uicontrol('style','text','string','Channel:','position',[200,15,100,19],'HorizontalAlignment','left');
        handles.info_text_X=uicontrol('style','text','string','X:','position',[280,15,100,19],'HorizontalAlignment','left');
        handles.info_text_Y=uicontrol('style','text','string','Y:','position',[350,15,100,19],'HorizontalAlignment','left');
        handles.info_text_Z=uicontrol('style','text','string','Z:','position',[400,15,100,19],'HorizontalAlignment','left');
        handles.info_text_Index=uicontrol('style','text','string','Index:','position',[440,15,100,19],'HorizontalAlignment','left');
        handles.tip_text=uicontrol('style','text','string','tips:','position',[2,-1,490,19],'HorizontalAlignment','left');
        set(handles.affix_selected_listbox,'max',2,'min',0);
        set(handles.affix_baned_listbox,'max',2,'min',0);
        set(handles.file_listbox,'max',2,'min',0);
        set(handles.file_listbox,'uicontextmenu',hcmenu);
        
        try
            set(get(handles.fig,'children'),'units','normalized');
        end
        
        set(handles.path_edit,'String',pwd);
        set(handles.path_edit,'Userdata',pwd);
        
        set(handles.fig,'CloseRequestFcn',{@(obj,events)fig_Close()});
        set(handles.refresh_btn,'Callback',{@(obj,events)update_handles()});
        set(handles.path_btn,'Callback',{@(obj,events)path_btn_Callback()});
        set(handles.path_edit,'Callback',{@(obj,events)path_edit_Callback()});
        set(handles.isfilter_checkbox,'Callback',{@(obj,events)update_handles()});
        set(handles.affix_selected_listbox,'Callback',{@(obj,events)affix_listbox_Callback()});
        set(handles.affix_baned_listbox,'Callback',{@(obj,events)affix_listbox_Callback()});
        set(handles.file_listbox,'Callback',{@(obj,events)file_listbox_Callback()});
        set(handles.file_listbox,'KeyPressFcn',@key_Press)
        
        update_handles();
        handles.batch={};
        %% init timer
        handles.timer = timer('BusyMode','drop','ExecutionMode','fixedRate','TimerFcn',{@(obj,events)on_Timer()});
        start(handles.timer);
    end

    function file_listbox_Callback()
        persistent t;
        persistent file_selected;
        if isempty(t)
            t=clock;
            t(1)=t(1)-1;
        end
        if  ~isequal(file_selected,get(handles.file_listbox,'value'))
            t(1)=t(1)-1;
        end
        file_selected=get(handles.file_listbox,'value');
        if strcmp(get(gcf,'SelectionType'),'normal')
            e=etime(clock,t);
            t=clock;
            if e<1.5
                menu_callback('GLW_rename');
            else
                file_listbox_select_changed();
            end
        end
        if strcmp(get(gcf,'SelectionType'),'open')
            dataset_view();
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

    function affix_listbox_Callback()
        set(handles.isfilter_checkbox,'value',1);
        update_handles;
    end

    function path_edit_Callback()
        st=get(handles.path_edit,'String');
        if exist(st,'dir')
            update_handles;
        else
            st=get(handles.path_edit,'userdata');
            set(handles.path_edit,'String',st);
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

    function option=get_selectfile()
        option=[];
        str=get(handles.file_listbox,'userdata');
        idx=get(handles.file_listbox,'value');
        if isempty(idx) || isempty(str)
            warndlg('Please select some files!','Warning','modal');
            return;
        end
        option.file_str  = [str(idx)];
        option.file_path = get(handles.path_edit,'userdata');
    end

    function sendworkspace_btn_Callback()
        option=get_selectfile();
        if isempty(option)
            return;
        end
        for k=1:length(option.file_str)
            [lwdata(k).header,lwdata(k).data]=...
                CLW_load(fullfile(option.file_path,option.file_str{k}));
        end
        assignin('base','lwdata',lwdata);
    end

    function readworkspace_btn_Callback()
        option=get_selectfile();
        if isempty(option)
            return;
        end
        if isempty(option)|| length(option.file_str)>1
            disp('Please select one file');
            return;
        end
        
        try
            lwdata=evalin('base','lwdata');
        catch
            disp('lwdata variable not found,in workspace');
            return;
        end
        lwdata=lwdata(1);
        if isfield(lwdata,'header')&&isfield(lwdata,'data')
            t=questdlg('Are you sure?');
            if strcmpi(t,'Yes');
                lwdata.header.name=option.file_str{1};
                CLW_save(lwdata,'path',option.file_path);
            end
        else
            if ~isfield(lwdata,'header')
            disp('!!! Header field not found');
            end
            if ~isfield(lwdata,'data')
            disp('!!! Data field not found');
            end
        end
    end

    function menu_callback(fun_name)
        option=get_selectfile();
        if isempty(option)
            return;
        end
        if(fun_name(1)=='F')
            option.fun_name = fun_name;
            handles.batch{end+1}=LW_Batch(option);
        else
            eval([fun_name,'(option);']);
            update_handles();
        end
    end

    function key_Press(~,events)
        switch events.Key
            case 'delete'
                menu_callback('GLW_delete');
            case 'r'
                menu_callback('GLW_rename');
            case 'v'
                dataset_view();
            case 'f5'
                update_handles();
        end
    end

    function dataset_view()
        option=get_selectfile();
        if isempty(option)
            return;
        end
        inputfiles=[];
        for k=1:length(option.file_str)
            inputfiles{k}=fullfile(option.file_path,option.file_str{k});
        end
        GLW_multi_viewer(inputfiles);
    end

    function on_Timer()
        if ~isempty(handles.batch)
            index=[];
            for k=1:length(handles.batch)
                if ishandle(handles.batch{k})
                    index=[index,k];
                end
            end
            if length(index)~=length(handles.batch)
                handles.batch=[handles.batch{index}];
                update_handles();
            end
        end
    end

    function fig_Close()
        try
            stop(handles.timer);
            delete(handles.timer);
        end
        closereq;
    end

    function update_handles()
        st=get(handles.path_edit,'String');
        if exist(st,'dir')~=7
            return;
        end
        set(handles.path_edit,'userdata',st);
        cd(st);
        filename1=dir([st,filesep,'*.lw6']);
        filename2=dir([st,filesep,'*.lw5']);
        filename={filename1.name,filename2.name};
        filelist=cell(1,length(filename));
        filelist_affix=cell(1,length(filename));
        for k=1:length(filename)
            filelist_affix{k}=textscan(filename{k}(1:end-4),'%s');
            filelist_affix{k}=filelist_affix{k}{1}';
            switch(filename{k}(end))
                case '6'
                    filelist{k}=filename{k}(1:end-4);
                case '5'
                    filelist{k}=['<HTML><BODY color="blue">',filename{k}];
            end
        end
        affix=sort(unique([filelist_affix{:}]));
        str=get(handles.affix_selected_listbox,'String');
        idx=get(handles.affix_selected_listbox,'value');
        if isempty(str)
            selected_str=[];
        else
            selected_str=str(idx);
        end
        
        str=get(handles.affix_baned_listbox,'String');
        idx=get(handles.affix_baned_listbox,'value');
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
        
        is_filter=get(handles.isfilter_checkbox,'value');
        if is_filter==1
            set(handles.affix_selected_listbox,'string',affix);
            [~,selected_idx]=intersect(affix,selected_str,'stable');
            set(handles.affix_selected_listbox,'value',selected_idx);
            
            if isempty(selected_idx)
                selected_file_index=1:length(filelist);
            else
                selected_file_index=[];
                for k=1:length(filelist)
                    if isempty(setdiff(affix(selected_idx),filelist_affix{k}))
                        selected_file_index=[selected_file_index,k];
                    end
                end
            end
            
            if isempty(selected_file_index)
                set(handles.file_listbox,'String',{});
                set(handles.file_listbox,'userdata',{});
                set(handles.file_listbox,'value',[]);
                set(handles.affix_baned_listbox,'String',{});
                set(handles.affix_baned_listbox,'value',[]);
            else
                affix_baned=sort(unique([filelist_affix{selected_file_index}]));
                affix_baned=setdiff(affix_baned,affix(selected_idx));
                [~,baned_idx]=intersect(affix_baned,baned_str,'stable');
                set(handles.affix_baned_listbox,'String',affix_baned);
                set(handles.affix_baned_listbox,'value',baned_idx);
                
                band_file_index=[];
                for j=selected_file_index
                    if isempty(intersect(affix_baned(baned_idx),filelist_affix{j}))
                        band_file_index=[band_file_index,j];
                    end
                end
                [~,idx]=intersect(filelist(band_file_index),file_str,'stable');
                set(handles.file_listbox,'String',filelist(band_file_index));
                set(handles.file_listbox,'userdata',{filename{band_file_index}});
                set(handles.file_listbox,'value',idx);
            end
        else
            set(handles.affix_selected_listbox,'string',affix);
            set(handles.affix_selected_listbox,'value',[]);
            set(handles.affix_baned_listbox,'string',affix);
            set(handles.affix_baned_listbox,'value',[]);
            set(handles.file_listbox,'string',filelist);
            set(handles.file_listbox,'userdata',filename);
            [~,idx]=intersect(filelist,file_str,'stable');
            set(handles.file_listbox,'value',idx);
        end
        file_listbox_select_changed();
    end
end