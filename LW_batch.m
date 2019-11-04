function h_fig=LW_batch(varargin)
%LW_batch
batch={};
handle=[];
Batch_Init();
if nargout~=0
    h_fig=handle.fig;
end

%% Batch_init
    function Batch_Init()
        %% create figure
        temp=load('version.txt');
        temp=floor(temp/1000000);
        handle.fig = figure('position',[100,100,520,605],'Resize','off',...
            'name',['Letswave7--Batch (ver.',num2str(temp),')'],'numbertitle','off','color',0.94*[1,1,1]);
        
        %% initialize the toolbar
        set(handle.fig,'MenuBar','none');
        set(handle.fig,'DockControls','off');
        icon=load('icon.mat');
        handle.toolbar = uitoolbar(handle.fig);
        %open toolbar
        handle.toolbar_open = uipushtool(handle.toolbar);
        set(handle.toolbar_open,'CData',icon.icon_open);
        set(handle.toolbar_open,'TooltipString','open the script');
        set(handle.toolbar_open,'ClickedCallback',{@open_script});
        %save toolbar
        handle.toolbar_save = uipushtool(handle.toolbar);
        set(handle.toolbar_save,'CData',icon.icon_save);
        set(handle.toolbar_save,'TooltipString','save script');
        set(handle.toolbar_save,'ClickedCallback',{@save_script});
        %delete toolbar
        handle.toolbar_del = uipushtool(handle.toolbar);
        set(handle.toolbar_del,'CData',icon.icon_delete);
        set(handle.toolbar_del,'TooltipString','delete function');
        set(handle.toolbar_del,'ClickedCallback',{@del_function});
        %show toolbar
        handle.toolbar_show = uipushtool(handle.toolbar,'separator','on');
        set(handle.toolbar_show,'CData',icon.icon_script);
        set(handle.toolbar_show,'TooltipString','show script');
        set(handle.toolbar_show,'ClickedCallback',{@show_script});
        %run toolbar
        handle.toolbar_run = uipushtool(handle.toolbar,'Interruptible','off');
        set(handle.toolbar_run,'CData',icon.icon_run);
        set(handle.toolbar_run,'TooltipString','run script');
        set(handle.toolbar_run,'ClickedCallback',{@run_script});
        %btn_run
        handle.btn_run=uicontrol('style','pushbutton','string','Run',...
            'TooltipString','run script','callback',{@run_script},...
            'position',[2,5,518,40]);
        
        %% initialize the menu
        menu_name={'Edit','Process','Statistics'};
        root = uimenu(handle.fig,'Label','File','BusyAction','cancel');
        mh = uimenu(root,'Label','load', 'callback',@(obj,event)add_function('FLW_load'));
        for k=1:length(menu_name)
            str=['menu_',menu_name{k},'.xml'];
            if ~exist(str,'file')
                continue;
            end
            s= xml2struct(str);
            if ~isfield(s,'LW_Manager')||~isfield(s.LW_Manager,'menu')
                continue;
            end
            root = uimenu(handle.fig,'Label',s.LW_Manager.Attributes.Label,'BusyAction','cancel');
            s=s.LW_Manager.menu;
            if ~iscell(s); s={s};end
            for k1=1:length(s)
                mh = uimenu(root,'Label',s{k1}.Attributes.Label);
                if isfield(s{k1},'submenu')
                    ss=s{k1}.submenu;
                    if ~iscell(ss); ss={ss};end
                    for k2=1:length(ss)
                        eh = uimenu(mh,'Label',ss{k2}.Attributes.Label);
                        if isfield(ss{k2},'subsubmenu')
                            sss=ss{k2}.subsubmenu;
                            if ~iscell(sss); sss={sss};end
                            for k3=1:length(sss)
                                if isfield(sss{k3}.Attributes,'callback') && strcmp(sss{k3}.Attributes.callback(1:3),'FLW')
                                    uimenu(eh,'Label',sss{k3}.Attributes.Label,...
                                        'callback',@(obj,event)add_function(sss{k3}.Attributes.callback));
                                else
                                    uimenu(eh,'Label',sss{k3}.Attributes.Label,...
                                        'enable', 'off');
                                end
                            end
                        else
                            if isfield(ss{k2}.Attributes,'callback') && strcmp(ss{k2}.Attributes.callback(1:3),'FLW')
                                set(eh,'callback',@(obj,event)add_function(ss{k2}.Attributes.callback));
                            else
                                set(eh,'enable', 'off');
                            end
                        end
                    end
                else
                    if isfield(s{k1}.Attributes,'callback') && strcmp(s{k1}.Attributes.callback(1:3),'FLW')
                        set(mh,'callback',@(obj,event)add_function(s{k1}.Attributes.callback));
                    else
                        set(mh,'enable', 'off');
                    end
                end
            end
        end
        
        %add batch
        load('batch_plugins.mat','batch_list','plugins_list');
        root_batch = uimenu(handle.fig,'Label','Batch');
        for k=1:length(batch_list)
            mh = uimenu(root_batch,'Label',batch_list{k}(1:end-10));
            set(mh,'callback',@(obj,event)add_script(batch_list{k}));
        end
        root_plugins = uimenu(handle.fig,'Label','Plugins');
        for k=1:length(plugins_list)
            str=fullfile(fileparts(which(mfilename)),'Plugins',plugins_list{k},'menu.xml');
            
            if ~exist(str,'file')
                continue;
            end
            %convert xml to struct
            s= xml2struct(str);
            if ~isfield(s,'LW_Plugins')||~isfield(s.LW_Plugins,'menu')
                continue;                
            end
            %build titlebar menu (labels and callback)
            root = uimenu(root_plugins,'Label',plugins_list{k});
            s=s.LW_Plugins.menu;
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
                                        'callback',@(obj,event)add_function(sss{k3}.Attributes.callback));
                                else
                                    uimenu(eh,'Label',sss{k3}.Attributes.Label,...
                                        'enable', 'off');
                                end
                             end
                        else
                            if isfield(ss{k2}.Attributes,'callback') 
                                set(eh,'callback',@(obj,event)add_function(ss{k2}.Attributes.callback));
                            else
                                set(eh,'enable', 'off');
                            end
                        end
                    end
                else
                    if isfield(s{k1}.Attributes,'callback')
                        set(mh,'callback',@(obj,event)add_function(s{k1}.Attributes.callback));
                    else
                        set(mh,'enable', 'off');
                    end
                end
            end
        end
        
        
        %path_edit
        handle.path_edit=uicontrol('style','edit','String',pwd,'userdata',pwd,...
            'HorizontalAlignment','left','position',[3,578,487,25],'backgroundcolor',1*[1,1,1],...
            'Callback',{@(obj,events)path_edit_Callback()});
        %path_btn
        handle.path_btn=uicontrol('style','pushbutton','CData',icon.icon_open_path,...
            'position',[493,578,25,25],'Callback',{@(obj,events)path_btn_Callback()});
        
        %% initialize run panel
        handle.run_panel=uipanel(handle.fig,'units','pixels','backgroundcolor',0.94*[1,1,1],...
            'position',[99,1,421,570],'BorderType','etchedin','visible','off');
        handle.run_txt=uicontrol(handle.run_panel,'style','text',...
            'units','normalized','backgroundcolor',0.94*[1,1,1],...
            'position',[0,0,1,0.99],'string','check each step     .',...
            'HorizontalAlignment','right','fontweight','bold');
        handle.run_ax=uicontrol(handle.run_panel,'style','text',...
            'units','normalized','backgroundcolor',0*[1,1,1],...
            'position',[0.02,0.93,0.94,0.03],'string','');
        set(handle.run_ax,'units','pixels');
        pos=get(handle.run_ax,'position');
        pos=pos+[1,1,-2,-2];
        handle.run_frame=uicontrol(handle.run_panel,'style','text',...
            'units','pixels','backgroundcolor',0.94*[1,1,1],...
            'position',pos,'string','');
        set(handle.run_ax,'units','normalized');
        set(handle.run_frame,'units','normalized');
        pos=get(handle.run_frame,'position');
        handle.run_slider=uicontrol(handle.run_panel,'style','text',...
            'units','normalized','backgroundcolor',[255,71,38]/255,...
            'position',pos,'string','');
        handle.run_edit=uicontrol('parent',handle.run_panel,'min',0,'max',2,...
            'style','listbox','value',[],'position',[10,50,395,470],...
            'HorizontalAlignment','left','backgroundcolor',[1,1,1]);
        handle.run_close_btn=uicontrol('parent',handle.run_panel,...
            'string','close','style','pushbutton','position',[5,5,405,40],...
            'callback',@close_script);
        
        %% initialize tab panel
        handle.tab_panel=uipanel(handle.fig,'BorderType','none',...
            'units','pixels','position',[1,45,100,528]);
        handle.tab_idx=0;
        handle.tab_idx_show=1;
        handle.tab_up=uicontrol(handle.tab_panel,'style','pushbutton',...
            'position',[49,1,20,20],'callback',@scroll_up);
        handle.tab_down=uicontrol(handle.tab_panel,'style','pushbutton',...
            'position',[70,1,20,20],'callback',@scroll_down);
        set(handle.tab_up,'CData',icon.icon_dataset_up,'visible','off');
        set(handle.tab_down,'CData',icon.icon_dataset_down,'visible','off');
        handle.h_parent=[];
        if ~isempty(varargin)
            if length(varargin)>=2
                handle.h_parent=varargin{2};
                pos=get (handle.h_parent,'position');
                pos(3:4)=[520,605];
                pos(1)=pos(1)+300;
                set(handle.fig,'position',pos);
            end
            option=varargin{1};
            set(handle.path_edit,'String',pwd);
            if isfield(option,'file_path')
                set(handle.path_edit,'String',option.file_path);
                add_function('FLW_load');
                for k=1:length(option.file_str)
                    batch{1}.add_file(fullfile(option.file_path,option.file_str{k}));
                end
                if isfield(option,'fun_name')
                    add_function(option.fun_name);
                    CheckTab(1,2);
                end
            end
            if isfield(option,'script_name')
                [pathstr,~,~]=fileparts(which('LW_manager.m'));
                option1=load(fullfile(pathstr,'plugins',option.script_name),'-mat');
                option1=option1.option;
                idx=handle.tab_idx;
                batch_num=length(batch);
                for k=1:length(option1)
                    if ~(k==1 && strcmp(option1{k}.function,'FLW_load') && length(batch)==1)
                        eval(['batch{end+1}=',option1{k}.function,'(handle);']);
                        set(batch{end}.h_tab,'Callback',{@SelectionChg});
                        batch{end}.set_option(option1{k});
                    end
                end
                if ~isempty(idx)
                    I=[1:idx,batch_num+1:length(batch),idx+1:batch_num];
                    batch=batch(I);
                end
                tab_order_check();
                if isempty(idx)&& ~isempty(batch)
                    %set(handle.tabgp,'SelectedTab',batch{1}.h_tab);
                    handle.tab_idx=1;
                end
            end
            handle.is_close=1;
        else
            handle.is_close=0;
        end
        
        %         add_function('FLW_selection');
        %         batch{1}.add_file(fullfile(pwd,'data_1'));
        %         %batch{1}.add_file(fullfile(pwd,'chan-select data_1'));
        %         handle.tab_idx=2;
        %         tab_updated(2);
    end

    function path_edit_Callback()
        st=get(handle.path_edit,'String');
        if exist(st,'dir')
            set(handle.path_edit,'userdata',st);
            cd(st);
        else
            st=get(handle.path_edit,'userdata');
            set(handle.path_edit,'String',st);
        end
    end

    function path_btn_Callback()
        st=get(handle.path_edit,'String');
        st=uigetdir(st);
        if ~isequal(st,0) && exist(st,'dir')==7
            set(handle.path_edit,'String',st);
            set(handle.path_edit,'userdata',st);
            cd(st);
        end
    end

%% scroll_up
    function scroll_up(varargin)
        if handle.tab_idx_show==1
            return;
        end
        if handle.tab_idx_show>5
            handle.tab_idx_show=handle.tab_idx_show-5;
        else
            handle.tab_idx_show=1;
        end
        tab_updated(handle.tab_idx);
    end

%% scroll_down
    function scroll_down(varargin)
        if handle.tab_idx_show+15<length(batch)
            handle.tab_idx_show=handle.tab_idx_show+5;
        end
        tab_updated();
    end

%% add_function
    function add_function(filename)
        handle.is_close=0;
        eval(['batch{end+1}=',filename,'(handle);']);
        set(batch{end}.h_tab,'Callback',{@SelectionChg});
        if handle.tab_idx~=0
            batch=batch([1:handle.tab_idx,end,handle.tab_idx+1:end-1]);
        end
        tab_order_check();
        if length(batch)>25
            set(handle.tab_up,'visible','on');
            set(handle.tab_down,'visible','on');
        end
    end

%% del_function
    function del_function(varargin)
        handle.is_close=0;
        batch_num=length(batch);
        if batch_num==0
            return;
        end
        idx=handle.tab_idx;
        cnt_type=batch{idx}.FLW_TYPE;
        if idx==1
            pre_type=2;
        else
            pre_type=batch{idx-1}.FLW_TYPE;
        end
        if idx==batch_num
            post_type=0;
        else
            post_type=batch{idx+1}.FLW_TYPE;
        end
        switch pre_type
            case 0
                seq=[1:idx-1,idx+1:batch_num];
            case 1
                if cnt_type==0 && ismember(post_type,[2,3,4])
                    choice=questdlg('Do you want to delete all the section?','Yes','No');
                    if strcmp(choice,'Yes')
                        seq=[1:idx-1,idx+2:batch_num];
                    else
                        return;
                    end
                else
                    seq=[1:idx-1,idx+1:batch_num];
                end
            case {2,3,4}
                if cnt_type==0 && post_type==0
                    seq=[1:idx-1,idx+1:batch_num];
                else
                    choice=questdlg('Do you want to delete all the section?','Yes');
                    if strcmp(choice,'Yes')
                        idx1=batch_num+1;
                        for k=idx+1:batch_num
                            if batch{k}.FLW_TYPE==0
                                idx1=k;
                                break;
                            end
                        end
                        seq=[1:idx-1,idx1:batch_num];
                    else
                        return;
                    end
                end
        end
        for k=setdiff(1:batch_num,seq)
            delete(batch{k}.h_tab);
            delete(batch{k}.h_panel);
        end
        batch=batch(seq);
        if isempty(seq)
            handle.tab_idx=0;
        else
            if idx-1==0
                handle.tab_idx=1;
                batch{handle.tab_idx}.is_selected=1;
                %set(handle.tabgp,'selectedTab',batch{1}.h_tab);
            else
                handle.tab_idx=idx-1;
                batch{handle.tab_idx}.is_selected=1;
                %set(handle.tabgp,'selectedTab',batch{idx-1}.h_tab);
            end
        end
        tab_order_check();
    end

%% run_script
    function run_script(varargin)
        uistack(handle.run_panel,'top');
        uistack(handle.run_txt,'top');
        uistack(handle.run_ax,'top');
        uistack(handle.run_frame,'top');
        uistack(handle.run_slider,'top');
        uistack(handle.run_edit,'top');
        uistack(handle.run_close_btn,'top');
        
        set(handle.btn_run,'visible','off');
        set(findobj(handle.fig),'busyaction','cancel');
        set(handle.run_slider,'backgroundcolor',[255,71,38]/255);
        set(handle.run_txt,'string','check each operation...     .');
        set(handle.run_panel,'visible','on');
        option=[];
        lwdata=[];
        lwdataset=[];
        str_N=36;
        if ispc
            str_N=32;
        end
        str=cell(str_N,1);
        str_index=0;
        try
            [batch_idx,script_idx,script]=get_script();
            n=length(batch_idx);
            for k=1:n
                pos=get(handle.run_frame,'position');
                pos(3)=pos(3)*k/n;
                set(handle.run_slider,'Position',pos);
                set(handle.run_txt,'string',...
                    ['step: ',num2str(k),'/',num2str(n),'     .']);
                color=get(batch{batch_idx(k)}.h_tab,'foregroundcolor');
                html_pre=['<html><font color=rgb(',num2str(ceil(color(1)*255)),',',num2str(ceil(color(2)*255)),',',num2str(ceil(color(3)*255)),')>'];
                html_post=['</font></html>'];
                
                str{mod(str_index,str_N)+1}=[html_pre,'step: ',num2str(k),'/',num2str(n),html_post];
                str_index=str_index+1;
                str{mod(str_index,str_N)+1}=[html_pre,script{script_idx(k)},html_post];
                str_index=str_index+1;
                str{mod(str_index,str_N)+1}=[html_pre,script{script_idx(k)+1},html_post];
                str_index=str_index+1;
                set(handle.run_edit,'string',str(mod((1:str_N)+str_index*(str_index>str_N)-1,str_N)+1));
                drawnow;
                tab_updated(batch_idx(k));
                if strcmp( class(batch{batch_idx(k)}),'FLW_load')
                    option=[];
                    lwdata=[];
                    lwdataset=[];
                end
                T=evalc(script{script_idx(k)});
                if ~isempty(handle.h_parent)
                    try
                        set(handle.h_parent,'userdata',1);
                    end
                end
                if ~isempty(T)
                    idx=find(T==sprintf('\n'));
                    for k=1:length(idx)
                        if k==1
                            if idx(k)==1
                                continue;
                            end
                            str{mod(str_index,str_N)+1}=[html_pre,T(1:idx(k)-1),html_post];
                            str_index=str_index+1;
                        else
                            if idx(k-1)==idx(k)
                                continue;
                            end
                            str{mod(str_index,str_N)+1}=[html_pre,T(idx(k-1)+1:idx(k)-1),html_post];
                            str_index=str_index+1;
                        end
                        set(handle.run_edit,'string',str(mod((1:str_N)+str_index*(str_index>str_N)-1,str_N)+1));
                        drawnow;
                    end
                end
                
                if strcmp(script{script_idx(k)+1},'lwdata= FLW_compute_ICA.get_lwdata(lwdata,option);')...
                || strcmp(script{script_idx(k)+1},'lwdataset= FLW_compute_ICA_merged.get_lwdataset(lwdataset,option);')
                    str{mod(str_index,str_N)+1}=[html_pre,'Runing ICA...',html_post];
                    str_index=str_index+1;
                    set(handle.run_edit,'string',str(mod((1:str_N)+str_index*(str_index>str_N)-1,str_N)+1));
                    drawnow;
                    tic;
                    T=evalc(script{script_idx(k)+1});
                    temp=toc;
                    str{mod(str_index,str_N)+1}=[html_pre,'Done (',num2str(temp),' second has been consumed).',html_post];
                    str_index=str_index+1;
                    str{mod(str_index,str_N)+1}='';
                    str_index=str_index+1;
                    set(handle.run_edit,'string',str(mod((1:str_N)+str_index*(str_index>str_N)-1,str_N)+1));
                    drawnow;
                    continue;
                end
                T=evalc(script{script_idx(k)+1});
                idx=find(T==sprintf('\n'));
                for k=1:length(idx)
                    if k==1
                        if idx(k)==1
                            continue;
                        end
                        str{mod(str_index,str_N)+1}=[html_pre,T(1:idx(k)-1),html_post];
                        str_index=str_index+1;
                    else
                        if idx(k-1)==idx(k)
                            continue;
                        end
                        str{mod(str_index,str_N)+1}=[html_pre,T(idx(k-1)+1:idx(k)-1),html_post];
                        str_index=str_index+1;
                    end
                    set(handle.run_edit,'string',str(mod((1:str_N)+str_index*(str_index>str_N)-1,str_N)+1));
                    drawnow;
                end
                str{mod(str_index,str_N)+1}='';
                str_index=str_index+1;
                set(handle.run_edit,'string',str(mod((1:str_N)+str_index*(str_index>str_N)-1,str_N)+1));
                drawnow;
            end
            set(handle.run_txt,'string','finished.     .');
            set(handle.run_slider,'backgroundcolor',[0,1,0]);
            if ~isempty(handle.h_parent)
                try
                    set(handle.h_parent,'userdata',1);
                end
            end
            pause(0.5);
            if(handle.is_close)
                closereq();
            end
        catch exception
            msgString = getReport(exception);
            msgString = regexprep(msgString, '<.*?>', '');
            idx=find(msgString==sprintf('\n'));
            for k=1:length(idx)
                if k==1
                    if idx(k)==1
                        continue;
                    end
                    str{mod(str_index,str_N)+1}=msgString(1:idx(k)-1);
                    str_index=str_index+1;
                else
                    if idx(k-1)==idx(k)
                        continue;
                    end
                    str{mod(str_index,str_N)+1}=msgString(idx(k-1)+1:idx(k)-1);
                    str_index=str_index+1;
                end
            end
            set(handle.run_edit,'string',str(mod((1:str_N)+str_index*(str_index>str_N)-1,str_N)+1));
            drawnow;
                    
%             temp=cellstr(msgString);
%             for k=1:length(temp)
%                 str{mod(str_index,str_N)+1}=temp{k};
%                 str_index=str_index+1;
%             end
            %str=[str,cellstr(msgString)];
            set(handle.run_edit,'String',str,'ForegroundColor','red');
            set(handle.run_slider,'backgroundcolor',[1,0,0]);
            set(handle.run_txt,'string','Error.     .');
            rethrow(exception);
        end
    end

%% open_script
    function open_script(varargin)
        handle.is_close=0;
        [FileName,PathName] = uigetfile(...
            {'*.lw6;*.lw_script','Files(*.lw6,*.lw_script)';...
            '*.lw_script','script Files(*.lw_script)';...
            '*.lw6','lw6 Files(*.lw6)'});
        if PathName==0
            return;
        end
        [~,~,e]=fileparts(fullfile(PathName,FileName));
        option=[];
        if strcmp(e,'.lw_script')
            load(fullfile(PathName,FileName),'-mat');
        else %lw6
            header = CLW_load_header(fullfile(PathName,FileName));
            option={header.history.option};
        end
        
        %idx=get(get(handle.tabgp,'SelectedTab'),'userdata');
        idx=handle.tab_idx;
        batch_num=length(batch);
        for k=1:length(option)
            eval(['batch{end+1}=',option{k}.function,'(handle);']);
            set(batch{end}.h_tab,'Callback',{@SelectionChg});
            batch{end}.set_option(option{k});
        end
        if ~isempty(idx)
            I=[1:idx,batch_num+1:length(batch),idx+1:batch_num];
            batch=batch(I);
        end
        tab_order_check();
        if isempty(idx)&& ~isempty(batch)
            %set(handle.tabgp,'SelectedTab',batch{1}.h_tab);
            handle.tab_idx=1;
        end
    end

%% add_script
    function add_script(varargin)
            script_name=varargin{1};
            [pathstr,~,~]=fileparts(which('LW_manager.m'));
            load(fullfile(pathstr,'plugins',script_name),'-mat','option');
            idx=handle.tab_idx;
            batch_num=length(batch);
            for k=1:length(option)
                if ~(k==1 && strcmp(option{k}.function,'FLW_load') && length(batch)==1)
                    eval(['batch{end+1}=',option{k}.function,'(handle);']);
                    set(batch{end}.h_tab,'Callback',{@SelectionChg});
                    batch{end}.set_option(option{k});
                end
            end
            if ~isempty(idx)
                I=[1:idx,batch_num+1:length(batch),idx+1:batch_num];
                batch=batch(I);
            end
            tab_order_check();
            if isempty(idx)&& ~isempty(batch)
                %set(handle.tabgp,'SelectedTab',batch{1}.h_tab);
                handle.tab_idx=1;
            end
    end

%% show_script
    function show_script(varargin)
        [~,~,script]=get_script();
        CLW_show_script(script);
    end

%% close_script
    function close_script(varargin)
        set(handle.btn_run,'visible','on');
        set(handle.run_panel,'visible','off');
    end

%% save_script
    function save_script(varargin)
        [FileName,PathName] = uiputfile('*.lw_script','Save script as');
        if PathName==0
            return;
        end
        option={};
        for k=1:length(batch)
            option{k}=batch{k}.get_option;
        end
        save(fullfile(PathName,FileName),'option');
    end

%% CheckTab
    function CheckTab(old_index,new_index)
        try
            for k=old_index+1:new_index
                set(batch{k-1}.h_txt_cmt,'String',{batch{k-1}.h_title_str,batch{k-1}.h_help_str},'ForegroundColor','black');
                tab_updated(k-1);
                if(k==2)
                    batch{k-1}.header_update([]);
                else
                    batch{k-1}.header_update(batch{k-2});
                end
                tab_updated(k);
                drawnow;
                batch{k}.GUI_update(batch{k-1});
                drawnow;
            end
        catch exception
            msgString = getReport(exception);
            msgString = regexprep(msgString, '<.*?>', '');
            msgString = textwrap(batch{k-1}.h_txt_cmt,cellstr(msgString));
            set(batch{k-1}.h_txt_cmt,'String',msgString,'ForegroundColor','red');
            set(batch{k}.h_txt_cmt,'String',msgString,'ForegroundColor','red');
            rethrow(exception)
        end
    end

%% get_script
    function [batch_idx,script_idx,script]=get_script()
        if ~isempty(batch)
            CheckTab(1,length(batch));
        end
        script_set={};
        script={};
        batch_idx=[];
        script_idx=[];
        for k=1:length(batch)
            script_set{k}=batch{k}.get_Script;
        end
        j=0;
        section_num=[];
        for k=1:length(batch)-1
            if batch{k}.FLW_TYPE==0
                section_num=[section_num,k];
            end
        end
        temp=[section_num(2:end)-section_num(1:end-1)];
        section_num=setdiff(section_num,section_num(temp==1));
        
        script{end+1}='LW_init();';
        for section_pos=1:length(section_num)
            if length(section_num)~=1
                script{end+1}=['% section ',num2str(section_pos)];
            end
            k=section_num(section_pos);
            switch(batch{k+1}.FLW_TYPE)
                case {1,3}
                    for n=1:length(script_set{k})/2
                        script{end+1}=script_set{k}{(n-1)*2+1};
                        script{end+1}=script_set{k}{n*2};
                        batch_idx=[batch_idx,k];
                        script_idx=[script_idx,length(script)-1];
                        for j=k+1:length(batch)
                            if ismember(batch{j}.FLW_TYPE,[1,3])
                                script{end+1}=script_set{j}{1};
                                script{end+1}=script_set{j}{2};
                                batch_idx=[batch_idx,j];
                                script_idx=[script_idx,length(script)-1];
                            else
                                break;
                            end
                        end
                        script{end+1}='';
                    end
                case {2,4}
                    temp=batch{k}.get_Script_set();
                    script{end+1}=temp{1};
                    script{end+1}=temp{2};
                    batch_idx=[batch_idx,k];
                    script_idx=[script_idx,length(script)-1];
                    script{end+1}=script_set{k+1}{1};
                    script{end+1}=script_set{k+1}{2};
                    batch_idx=[batch_idx,k+1];
                    script_idx=[script_idx,length(script)-1];
                    script{end+1}='';
            end
            script{end+1}='';
            script{end+1}='';
        end
    end

%% SelectionChg
    function SelectionChg(varargin)
        old_idx=handle.tab_idx;
        new_idx=get(varargin{1},'userdata');
        for k=1:length(batch)
            batch{k}.is_selected=0;
        end
        batch{new_idx}.is_selected=1;
        tab_updated(new_idx);
        CheckTab(old_idx,new_idx);
    end

%% tab_order_check
    function tab_order_check()
        if isempty(batch)
            return;
        end
        batch_num=length(batch);
        
        pre_type=2;
        index_num=0;
        for tab_pos=1:batch_num
            is_load=0;
            switch batch{tab_pos}.FLW_TYPE
                case 0
                case 1
                    if ismember(pre_type,[2,3,4])
                        is_load=1;
                    end
                case {2,3,4}
                    if pre_type~=0
                        is_load=1;
                    end
            end
            pre_type=batch{tab_pos}.FLW_TYPE;
            index_num=index_num+1;
            set(batch{tab_pos}.h_tab,'userdata',index_num);
            if(is_load)
                batch{end+1}=FLW_load(handle);
                set(batch{end}.h_tab,'Callback',{@SelectionChg});
                set(batch{end}.h_tab,'userdata',index_num);
                index_num=index_num+1;
                set(batch{tab_pos}.h_tab,'userdata',index_num);
            end
        end
        seq=zeros(index_num,1);
        for k=1:length(batch)
            seq(k)=get(batch{k}.h_tab,'userdata');
        end
        [~,I] = sort(seq);
        batch=batch(I);
        
        handle.tab_idx=0;
        for k=1:length(batch)
            if handle.tab_idx==0
                if batch{k}.is_selected==1
                    handle.tab_idx=k;
                end
            else
                batch{k}.is_selected=0;
            end
        end
        tab_updated(handle.tab_idx);
    end

%% tab_updated
    function tab_updated(idx)
        handle.tab_idx=idx;
        color=[     0    0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840];
        color_num=0;
        if length(batch)<=24
            for k=1:length(batch)
                if(idx==k)
                    set(batch{k}.h_tab,'position',[2,525-20*k,98,20]);
                    set(batch{k}.h_tab,'FontWeight','bold');
                    set(batch{k}.h_panel,'visible','on');
                else
                    set(batch{k}.h_tab,'position',[10,525-20*k,90,20]);
                    set(batch{k}.h_tab,'FontWeight','normal');
                    set(batch{k}.h_panel,'visible','off');
                end
                if(batch{k}.FLW_TYPE==0)
                    color_num=mod(color_num,7)+1;
                end
                set(batch{k}.h_tab,'foregroundcolor',color(color_num,:));
            end
        else
            for k=1:length(batch)
                set(batch{k}.h_tab,'visible','off');
            end
            for k=handle.tab_idx_show:min(handle.tab_idx_show+24,length(batch))
                set(batch{k}.h_tab,'visible','on');
                if(idx==k)
                    set(batch{k}.h_tab,'position',...
                        [2,523-20*(k+1-handle.tab_idx_show),98,20]);
                    set(batch{k}.h_tab,'FontWeight','bold');
                    set(batch{k}.h_panel,'visible','on');
                else
                    set(batch{k}.h_tab,'position',...
                        [10,523-20*(k+1-handle.tab_idx_show),90,20]);
                    set(batch{k}.h_tab,'FontWeight','normal');
                    set(batch{k}.h_panel,'visible','off');
                end
                if(batch{k}.FLW_TYPE==0)
                    color_num=mod(color_num,7)+1;
                end
                set(batch{k}.h_tab,'foregroundcolor',color(color_num,:));
            end
        end
    end
end