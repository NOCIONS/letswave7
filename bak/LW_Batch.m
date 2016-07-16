function h_fig=LW_Batch(varargin)
%LW_Batch
clc;
batch={};
handle=[];
LW_Init();
Batch_Init();
h_fig=handle.fig;

    function Batch_Init()
        handle.fig = figure('position',[100,100,500,605],'Resize','off',...
            'name','Letswave Batch','numbertitle','off');
        set(handle.fig,'MenuBar','none');
        set(handle.fig,'DockControls','off');
        icon=load('icon.mat');
        handle.toolbar = uitoolbar(handle.fig);
        
        handle.toolbar_open = uipushtool(handle.toolbar);
        set(handle.toolbar_open,'CData',icon.icon_open);
        set(handle.toolbar_open,'TooltipString','open the script');
        set(handle.toolbar_open,'ClickedCallback',{@open_script});
        
        handle.toolbar_save = uipushtool(handle.toolbar);
        set(handle.toolbar_save,'CData',icon.icon_save);
        set(handle.toolbar_save,'TooltipString','save script');
        set(handle.toolbar_save,'ClickedCallback',{@save_script});
        
        handle.toolbar_del = uipushtool(handle.toolbar);
        set(handle.toolbar_del,'CData',icon.icon_delete);
        set(handle.toolbar_del,'TooltipString','delete function');
        set(handle.toolbar_del,'ClickedCallback',{@del_function});
        
        handle.toolbar_show = uipushtool(handle.toolbar,'separator','on');
        set(handle.toolbar_show,'CData',icon.icon_script);
        set(handle.toolbar_show,'TooltipString','show script');
        set(handle.toolbar_show,'ClickedCallback',{@show_script});
        
        handle.toolbar_run = uipushtool(handle.toolbar,'Interruptible','off');
        set(handle.toolbar_run,'CData',icon.icon_run);
        set(handle.toolbar_run,'TooltipString','run script');
        set(handle.toolbar_run,'ClickedCallback',{@run_script});
        
        
        menu_name={'Edit','Process','Toolbox','Static',...
            'Plugins','Addition1','Addition2','Addition3'};
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
        handle.path_edit=uicontrol('style','edit',...
            'HorizontalAlignment','left','position',[2,578,470,25]);
        handle.path_btn=uicontrol('style','pushbutton','CData',icon.icon_open_path,...
            'position',[475,578,25,25]);
        handle.tabgp = uitabgroup(handle.fig,'TabLocation','left',...
            'selectionChangedFcn',@SelectionChg,'units','pixels',...
            'position',[1,1,499,570]);
        
        handle.run_panel=uipanel(handle.fig,'units','pixels',...
            'position',[62,1,447,570],'BorderType','none','visible','off');%
        handle.run_ax=axes('parent',handle.run_panel,'position',[0.02,0.93,0.94,0.03]);
        title(handle.run_ax,'check each step','Units','normalized',...
            'Position',[1 1.2],'HorizontalAlignment','right');
        axis(handle.run_ax,'off');
        handle.run_slider=rectangle('Position',[0 0 0.1 1],'FaceColor',[255,71,38]/255,'LineStyle','none');
        handle.run_frame=rectangle('Position',[0 0 1 1]);
        set(handle.run_ax,'xlim',[0,1]);
        set(handle.run_ax,'ylim',[0,1]);
        handle.run_edit=uicontrol('parent',handle.run_panel,'min',0,'max',2,...
            'style','listbox','value',[],'position',[10,60,420,430],...
            'HorizontalAlignment','left','backgroundcolor',[1,1,1]);
        handle.run_close_btn=uicontrol('parent',handle.run_panel,...
            'string','close','style','pushbutton','position',[10,10,420,40],...
            'callback',@close_script);
        
        if ~isempty(varargin)
            option=varargin{1};
            set(handle.path_edit,'String',option.file_path);
            add_function('FLW_load');
            for k=1:length(option.file_str)
                batch{1}.add_file(fullfile(option.file_path,option.file_str{k}));
            end
            add_function(option.fun_name);
            CheckTab(1,2);
            handle.is_close=1;
        else
            handle.is_close=0;
        end
    end

    function add_function(filename)
        handle.is_close=0;
        temp=get(handle.tabgp,'SelectedTab');
        eval(['batch{end+1}=',filename,'(handle.tabgp);']);
        if ~isempty(temp)
            index=get(temp,'userdata');
            batch=batch([1:index,end,index+1:end-1]);
        end
        tab_order_check();
        if isempty(temp)%to prevent no file loaded.
            set(handle.tabgp,'selectedTab',batch{1}.h_tab);
        end
    end

    function del_function(varargin)
        handle.is_close=0;
        batch_num=length(batch);
        if batch_num==0
            return;
        end
        is_load_pre=0;
        is_load_post=0;
        idx=get(get(handle.tabgp,'SelectedTab'),'userdata');
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
        end
        batch=batch(seq);
        tab_order_check();
        if ~isempty(seq)
            if idx-1==0
                set(handle.tabgp,'selectedTab',batch{1}.h_tab);
            else
                set(handle.tabgp,'selectedTab',batch{idx-1}.h_tab);
            end
        end
    end

    function show_script(varargin)
        [~,~,script]=get_script();
        CLW_show_script(script);
    end

    function run_script(varargin)
        set(findobj(handle.fig),'busyaction','cancel');
        set(handle.run_slider,'FaceColor',[255,71,38]/255);
        title(handle.run_ax,'check each operation...');
        set(handle.run_panel,'visible','on');
        [batch_idx,script_idx,script]=get_script();
        n=length(batch_idx);
        option=[];
        lwdata=[];
        lwdataset=[];
        str={};
        try
        for k=1:n
            title(handle.run_ax,['step: ',num2str(k),'/',num2str(n)]);
            set(handle.run_slider,'Position',[0 0 k/n 1]);
            color=get(batch{batch_idx(k)}.h_tab,'foregroundcolor');
            html_pre=['<html><font color=rgb(',num2str(ceil(color(1)*255)),',',num2str(ceil(color(2)*255)),',',num2str(ceil(color(3)*255)),')>'];
            html_post=['</font></html>'];
            str = [str,{[html_pre,'step: ',num2str(k),'/',num2str(n),html_post]},...
                {[html_pre,script{script_idx(k)},html_post]},...
                {[html_pre,script{script_idx(k)+1},html_post]}];
            set(handle.run_edit,'string',str);
            ListboxTop=get(handle.run_edit,'ListboxTop');
            set(handle.run_edit,'ListboxTop',min(ListboxTop+2,length(str)));
            drawnow;
            set(handle.run_edit,'ListboxTop',min(ListboxTop+3,length(str)));
            drawnow;
            set(handle.tabgp,'selectedTab',batch{batch_idx(k)}.h_tab);
            if strcmp( class(batch{batch_idx(k)}),'FLW_load')
                option=[];
                lwdata=[];
                lwdataset=[];
            end
            T=evalc(script{script_idx(k)});
            if ~isempty(T)
                C = strsplit(T,sprintf('\n'));
                for k=1:length(C)
                    if ~isempty(C{k})
                        str = [str,{[html_pre,C{k},html_post]}];
                        set(handle.run_edit,'string',str);
                        ListboxTop=get(handle.run_edit,'ListboxTop');
                        set(handle.run_edit,'ListboxTop',min(ListboxTop+1,length(str)));
                        drawnow;
                        set(handle.run_edit,'ListboxTop',min(ListboxTop+2,length(str)));
                        drawnow;
                    end
                end
            end
            T=evalc(script{script_idx(k)+1});
            if ~isempty(T)
                C = strsplit(T,sprintf('\n'));
                for k=1:length(C)
                    if ~isempty(C{k})
                        str = [str,{[html_pre,C{k},html_post]}];
                        set(handle.run_edit,'string',str);
                        ListboxTop=get(handle.run_edit,'ListboxTop');
                        set(handle.run_edit,'ListboxTop',min(ListboxTop+1,length(str)));
                        drawnow;
                        set(handle.run_edit,'ListboxTop',min(ListboxTop+2,length(str)));
                        drawnow;
                    end
                end
            end
            str = [str,{''}];
            set(handle.run_edit,'string',str);
            ListboxTop=get(handle.run_edit,'ListboxTop');
            set(handle.run_edit,'ListboxTop',min(ListboxTop+1,length(str)));
            drawnow;
        end
        catch exception
            msgString = getReport(exception);
            msgString = regexprep(msgString, '<.*?>', '');
            str=[str,cellstr(msgString)];
            set(handle.run_edit,'String',str,'ForegroundColor','red');
            set(handle.run_slider,'FaceColor',[0,1,0]);
            title(handle.run_ax,'Finished.');
            rethrow(exception);
        end
        set(handle.run_slider,'FaceColor',[0,1,0]);
        title(handle.run_ax,'finished');
        
        pause(0.5);
        if(handle.is_close)
            closereq();
        end
    end

    function close_script(varargin)
        set(handle.run_panel,'visible','off');
    end

    function open_script(varargin)
        handle.is_close=0;
        [FileName,PathName] = uigetfile(...
            {'*.lw_script','script Files(*.lw_script)';...
            '*.lw6','lw6 Files(*.lw6)';...
            '*.lw6;*.lw_script','Files(*.lw6,*.lw_script)'});
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
        
        idx=get(get(handle.tabgp,'SelectedTab'),'userdata');
        batch_num=length(batch);
        for k=1:length(option)
            eval(['batch{end+1}=',option{k}.function,'(handle.tabgp);']);
            batch{end}.set_option(option{k});
        end
        if ~isempty(idx)
            I=[1:idx,batch_num+1:length(batch),idx+1:batch_num];
            batch=batch(I);
            t=get(handle.tabgp,'children');
            set(handle.tabgp,'children',t(I));
        end
        tab_order_check();
        if isempty(idx)&& ~isempty(batch)
            set(handle.tabgp,'SelectedTab',batch{1}.h_tab);
        end
    end
 
    function save_script(varargin)
        [FileName,PathName] = uiputfile('*.lw_script','Save script As');
        if PathName==0
            return;
        end
        option={};
        for k=1:length(batch)
            option{k}=batch{k}.get_option;
        end
        save(fullfile(PathName,FileName),'option');
    end

    function SelectionChg(varargin)
        handle.is_close=0;
        try
            old_index=get(varargin{2}.OldValue,'userdata');
        catch
            old_index=1;
        end
        new_index=get(varargin{2}.NewValue,'userdata');
        CheckTab(old_index,new_index);
    end

    function CheckTab(old_index,new_index)
        try
            for k=old_index+1:new_index
                set(batch{k-1}.h_txt_cmt,'String',{batch{k-1}.h_title_str,batch{k-1}.h_help_str},'ForegroundColor','black');
                set(handle.tabgp,'selectedTab',batch{k-1}.h_tab);
                if(k==2)
                    batch{k-1}.header_update([]);
                else
                    batch{k-1}.header_update(batch{k-2});
                end
                set(handle.tabgp,'selectedTab',batch{k}.h_tab);
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
        
        script{end+1}='LW_Init();';
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
                batch{end+1}=FLW_load(handle.tabgp);
                set(batch{end}.h_tab,'userdata',index_num);
                index_num=index_num+1;
                set(batch{tab_pos}.h_tab,'userdata',index_num);
            end
        end
        seq=zeros(index_num,1);
        t=get(handle.tabgp,'children');
        for k=1:length(t)
            seq(k)=get(batch{k}.h_tab,'userdata');
        end
        [~,I] = sort(seq);
        batch=batch(I);
        
        seq=zeros(index_num,1);
        t=get(handle.tabgp,'children');
        for k=1:length(t)
            seq(k)=get(t(k),'userdata');
        end
        [~,I] = sort(seq);
        set(handle.tabgp,'children',t(I));
        
        color=[     0    0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840];
        color_num=0;
        for k=1:length(batch)
            if(batch{k}.FLW_TYPE==0)
                color_num=mod(color_num,7)+1;
            end
            set(batch{k}.h_tab,'foregroundcolor',color(color_num,:));
        end
    end
end