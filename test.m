function h_fig=test(varargin)
%LW_Batch
clc;
batch={};
handle=[];
Batch_Init();
h_fig=handle.fig;

    function Batch_Init()
        handle.fig = figure('position',[100,100,500,605],'Resize','off',...
            'name','Letswave Batch','numbertitle','off');
        
        %% initialize the toolbar and menu
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
        
        
        
        %% initialize run panel
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
        
        %% initialize tab panel
        handle.tab_panel=uipanel(handle.fig,...%'BorderType','none',...
            'units','pixels','position',[1,1,100,570]);
        handle.tab_idx=0;
        
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

    %% add_function
    function add_function(filename)
        handle.is_close=0;
        batch{end+1}=FLW_addfun(handle);
        
        
%         temp=get(handle.tabgp,'SelectedTab');
%         eval(['batch{end+1}=',filename,'(handle.tabgp);']);
%         if ~isempty(temp)
%             index=get(temp,'userdata');
%             batch=batch([1:index,end,index+1:end-1]);
%         end
%         tab_order_check();
%         if isempty(temp)%to prevent no file loaded.
%             set(handle.tabgp,'selectedTab',batch{1}.h_tab);
%         end
    end
end