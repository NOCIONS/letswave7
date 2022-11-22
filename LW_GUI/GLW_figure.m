function GLW_figure(option)

handles=[];
icon=load('icon.mat');
datasets_header={};
datasets_data={};

S=load('headmodel.mat');
POS=S.POS;
TRI=S.TRI;
NORM=S.NORM;
clear S;
GLW_figure_openingFcn;

%% init figure
    function GLW_figure_openingFcn()
        init_parameter();
        init_framework();
        init_panel_fig();
        init_panel_fig_sub();
        init_panel_axis();
        init_panel_content_manager();
        init_panel_curve();
        init_panel_line();
        init_panel_rect();
        init_panel_text();
        init_panel_image();
        init_panel_topo();
        init_panel_lissajous();
        set(handles.fig2,'visible','on');
        set(handles.fig1,'visible','on');
        drawnow();
        init_function();
        init_data();
        fig_redraw();
        fig1_callback();
    end
    function init_parameter()
        handles.ax=[];
        handles.ax_child=struct([]);
        get_fig_default();
    end
    function init_framework()
        handles.fig2=figure('name','Figure','PaperPositionMode','auto','Color',[1,1,1],'visible','off','Renderer','painters');
        handles.fig1=figure('name','Config','Color',0.94*[1,1,1],'visible','off');
        % to avoid some display problem only happened in Matlab2016b, strange
        if ~verLessThan('matlab','8.4')
            set(handles.fig1,'visible','on');
        end
        handles.toolbar= uitoolbar(handles.fig1);
        
        handles.open_btn=uipushtool(handles.toolbar,'CData',icon.icon_open,'TooltipString','open a file');
        handles.save_btn=uipushtool(handles.toolbar,'CData',icon.icon_save,'TooltipString','save the file');
        handles.data_btn=uipushtool(handles.toolbar,'CData',icon.icon_data_manage,'TooltipString','data management');
        handles.export_btn=uipushtool(handles.toolbar,'CData',icon.icon_figure_save,'TooltipString','export the figure');
        handles.script_btn=uipushtool(handles.toolbar,'CData',icon.icon_script,'TooltipString','script');
        handles.fig_btn=uitoggletool(handles.toolbar,'CData',icon.icon_figure,'TooltipString','figure','separator','on');
        handles.axis_btn=uitoggletool(handles.toolbar,'CData',icon.icon_axis,'TooltipString','axis');
        handles.content_btn=uitoggletool(handles.toolbar,'CData',icon.icon_content,'TooltipString','content');
        
        handles.subfig_listbox_txt=uicontrol(handles.fig1,'style','text','String','Subfigure:');
        handles.subfig_listbox=uicontrol(handles.fig1,'style','listbox','Min',1,'Max',1,'backgroundcolor',[1,1,1]);
        handles.content_listbox_txt=uicontrol(handles.fig1,'style','text','String','Content:');
        handles.content_listbox=uicontrol(handles.fig1,'style','listbox','Min',1,'Max',1,'backgroundcolor',[1,1,1]);
        
        set(handles.fig1,'numbertitle','off','MenuBar','none','DockControls','off');
        set(handles.fig2,'numbertitle','off','MenuBar','none','DockControls','off');
        set(handles.subfig_listbox_txt,'HorizontalAlignment','left');
        set(handles.content_listbox_txt,'HorizontalAlignment','left');
        
        set(handles.fig2,'position',option.fig2_pos);
        if (option.fig2_pos(4)>=650)
            fig1_pos=get(handles.fig2,'outerposition');
            if ispc
                fig1_pos([1,3])=[option.fig2_pos(1)+option.fig2_pos(3)-5,224+20];
            else
                fig1_pos([1,3])=[option.fig2_pos(1)+option.fig2_pos(3)+5,224];
            end
            set(handles.fig1,'outerposition',fig1_pos);
            fig1_pos=get(handles.fig1,'position');
        else
            fig1_pos=get(handles.fig1,'position');
            if fig1_pos(4)<600
                fig1_pos(4)=650;
            end
            fig1_pos(2)=max(option.fig2_pos(2)-option.fig2_pos(4)/2,0);
            if ispc
                fig1_pos([1,3])=[option.fig2_pos(1)+option.fig2_pos(3)-5,224+5];
            else
                fig1_pos([1,3])=[option.fig2_pos(1)+option.fig2_pos(3)+5,224];
            end
            set(handles.fig1,'position',fig1_pos);
        end
        Set_position(handles.subfig_listbox_txt,[3,fig1_pos(4)-20,80,20]);
        Set_position(handles.subfig_listbox,[3,520,80,fig1_pos(4)-520-20]);
        Set_position(handles.content_listbox_txt,[89,fig1_pos(4)-20,132,20]);
        Set_position(handles.content_listbox,[89,520,132,fig1_pos(4)-520-20]);
    end
    function init_panel_fig()
        handles.panel_fig=uipanel(handles.fig1,'bordertype','none');
        handles.fig_txt=uicontrol(handles.panel_fig,'style','text','String','Figure Position:');
        handles.fig_pos_refresh_btn=uicontrol(handles.panel_fig,'style','pushbutton');
        handles.fig_x_txt=uicontrol(handles.panel_fig,'style','text','String','x: ');
        handles.fig_y_txt=uicontrol(handles.panel_fig,'style','text','String','y: ');
        handles.fig_w_txt=uicontrol(handles.panel_fig,'style','text','String','w: ');
        handles.fig_h_txt=uicontrol(handles.panel_fig,'style','text','String','h: ');
        handles.fig_x_edt=uicontrol(handles.panel_fig,'style','edit','String','1','backgroundcolor',[1,1,1]);
        handles.fig_y_edt=uicontrol(handles.panel_fig,'style','edit','String','1','backgroundcolor',[1,1,1]);
        handles.fig_w_edt=uicontrol(handles.panel_fig,'style','edit','String','200','backgroundcolor',[1,1,1]);
        handles.fig_h_edt=uicontrol(handles.panel_fig,'style','edit','String','200','backgroundcolor',[1,1,1]);
        
        handles.fig_sub_txt=uicontrol(handles.panel_fig,'style','text','String','Subfigure:');
        handles.sub_add_txt=uicontrol(handles.panel_fig,'style','text','String','Type:');
        handles.sub_add_pop=uicontrol(handles.panel_fig,'style','popupmenu','String',{'Curve','Image','Topograph'},'value',1,'backgroundcolor',[1,1,1]);
        handles.sub_add=uicontrol(handles.panel_fig,'style','pushbutton');
        handles.sub_del=uicontrol(handles.panel_fig,'style','pushbutton');
        handles.sub_up=uicontrol(handles.panel_fig,'style','pushbutton');
        handles.sub_down=uicontrol(handles.panel_fig,'style','pushbutton');
        
        set(handles.fig_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.fig_pos_refresh_btn,'CData',icon.icon_refresh,'TooltipString','refresh the figure position');
        set(handles.fig_x_txt,'HorizontalAlignment','right');
        set(handles.fig_y_txt,'HorizontalAlignment','right');
        set(handles.fig_w_txt,'HorizontalAlignment','right');
        set(handles.fig_h_txt,'HorizontalAlignment','right');
        set(handles.fig_sub_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.sub_add,'CData',icon.icon_dataset_add,'TooltipString','add');
        set(handles.sub_del,'CData',icon.icon_dataset_del,'TooltipString','remove');
        set(handles.sub_up,'CData',icon.icon_dataset_up,'TooltipString','up');
        set(handles.sub_down,'CData',icon.icon_dataset_down,'TooltipString','down');
        set(handles.sub_add_txt,'HorizontalAlignment','left');
        
        Set_position(handles.panel_fig,[0,0,224,520]);
        Set_position(handles.fig_txt,[3,480,120,20]);
        Set_position(handles.fig_pos_refresh_btn,[200,480,24,24]);
        Set_position(handles.fig_x_txt,[1,450,40,20]);
        Set_position(handles.fig_x_edt,[41,450,70,20]);
        Set_position(handles.fig_y_txt,[111,450,40,20]);
        Set_position(handles.fig_y_edt,[151,450,70,20]);
        Set_position(handles.fig_w_txt,[1,420,40,20]);
        Set_position(handles.fig_w_edt,[41,420,70,20]);
        Set_position(handles.fig_h_txt,[111,420,40,20]);
        Set_position(handles.fig_h_edt,[151,420,70,20]);
        
        Set_position(handles.fig_sub_txt,[3,380,220,20]);
        Set_position(handles.sub_add_txt,[5,347,40,20]);
        Set_position(handles.sub_add_pop,[45,350,180,20]);
        if ispc
            Set_position(handles.sub_add,[5,295,50,40]);
            Set_position(handles.sub_del,[62,295,50,40]);
            Set_position(handles.sub_up,[118,295,50,40]);
            Set_position(handles.sub_down,[175,295,50,40]);
        else
            Set_position(handles.sub_add,[4,300,50,40]);
            Set_position(handles.sub_del,[59,300,50,40]);
            Set_position(handles.sub_up,[114,300,50,40]);
            Set_position(handles.sub_down,[169,300,50,40]);
        end
    end
    function init_panel_fig_sub()
        handles.panel_fig_sub=uipanel(handles.panel_fig,'bordertype','none','visible','off');
        handles.sub_title_chx=uicontrol(handles.panel_fig_sub,'style','checkbox','String','Title:');
        handles.sub_title_edt=uicontrol(handles.panel_fig_sub,'style','edit','backgroundcolor',[1,1,1]);
        handles.sub_font_txt=uicontrol(handles.panel_fig_sub,'style','text','String','Font:');
        handles.sub_font_pop=uicontrol(handles.panel_fig_sub,'style','popupmenu','backgroundcolor',[1,1,1]);
        handles.sub_size_txt=uicontrol(handles.panel_fig_sub,'style','text','String','Font size:');
        handles.sub_size_edt=uicontrol(handles.panel_fig_sub,'style','edit','backgroundcolor',[1,1,1]);
        handles.sub_position_txt=uicontrol(handles.panel_fig_sub,'style','text','String','Position:');
        handles.sub_position_chk=uicontrol(handles.panel_fig_sub,'style','checkbox','String','auto');
        handles.sub_col_txt=uicontrol(handles.panel_fig_sub,'style','text','String','Col:');
        handles.sub_row_txt=uicontrol(handles.panel_fig_sub,'style','text','String','Row:');
        handles.sub_col_edt=uicontrol(handles.panel_fig_sub,'style','edit','String','1','backgroundcolor',[1,1,1]);
        handles.sub_row_edt=uicontrol(handles.panel_fig_sub,'style','edit','String','1','backgroundcolor',[1,1,1]);
        handles.sub_update_btn=uicontrol(handles.panel_fig_sub,'style','pushbutton','String','Update');
        handles.sub_x_txt=uicontrol(handles.panel_fig_sub,'style','text','String','x: ');
        handles.sub_y_txt=uicontrol(handles.panel_fig_sub,'style','text','String','y: ');
        handles.sub_w_txt=uicontrol(handles.panel_fig_sub,'style','text','String','w: ');
        handles.sub_h_txt=uicontrol(handles.panel_fig_sub,'style','text','String','h: ');
        handles.sub_x_edt=uicontrol(handles.panel_fig_sub,'style','edit','String','1','backgroundcolor',[1,1,1]);
        handles.sub_y_edt=uicontrol(handles.panel_fig_sub,'style','edit','String','1','backgroundcolor',[1,1,1]);
        handles.sub_w_edt=uicontrol(handles.panel_fig_sub,'style','edit','String','200','backgroundcolor',[1,1,1]);
        handles.sub_h_edt=uicontrol(handles.panel_fig_sub,'style','edit','String','200','backgroundcolor',[1,1,1]);
        
        a=find(strcmpi(listfonts,'Arial')==1);
        set(handles.sub_font_pop,'String',listfonts,'value',a(1));
        set(handles.sub_x_txt,'HorizontalAlignment','right');
        set(handles.sub_y_txt,'HorizontalAlignment','right');
        set(handles.sub_w_txt,'HorizontalAlignment','right');
        set(handles.sub_h_txt,'HorizontalAlignment','right');
        set(handles.sub_position_txt,'HorizontalAlignment','left');
        set(handles.sub_col_txt,'HorizontalAlignment','left');
        set(handles.sub_row_txt,'HorizontalAlignment','left');
        set(handles.sub_font_txt,'HorizontalAlignment','left');
        set(handles.sub_size_txt,'HorizontalAlignment','left');
        set(handles.sub_col_txt,'HorizontalAlignment','right');
        set(handles.sub_row_txt,'HorizontalAlignment','right');
        if ispc
            Set_position(handles.panel_fig_sub,[0,0,224,280]);
            Set_position(handles.sub_title_chx,[5,250,70,20]);
            Set_position(handles.sub_title_edt,[75,250,150,20]);
            Set_position(handles.sub_font_txt,[5,220,146,20]);
            Set_position(handles.sub_font_pop,[75,220,150,20]);
            Set_position(handles.sub_size_txt,[5,185,146,20]);
            Set_position(handles.sub_size_edt,[75,185,150,20]);
            Set_position(handles.sub_position_txt,[5,155,146,20]);
            Set_position(handles.sub_position_chk,[75,155,150,20]);
            Set_position(handles.sub_x_txt,[1,125,40,20]);
            Set_position(handles.sub_x_edt,[41,125,70,20]);
            Set_position(handles.sub_y_txt,[111,125,40,20]);
            Set_position(handles.sub_y_edt,[151,125,70,20]);
            Set_position(handles.sub_w_txt,[1,95,40,20]);
            Set_position(handles.sub_w_edt,[41,95,70,20]);
            Set_position(handles.sub_h_txt,[111,95,40,20]);
            Set_position(handles.sub_h_edt,[151,95,70,20]);
            Set_position(handles.sub_col_txt,[1,65,40,20]);
            Set_position(handles.sub_col_edt,[41,65,70,20]);
            Set_position(handles.sub_row_txt,[111,65,40,20]);
            Set_position(handles.sub_row_edt,[151,65,70,20]);
            Set_position(handles.sub_update_btn,[5,25,220,30]);
        else
            Set_position(handles.panel_fig_sub,[0,0,224,280]);
            Set_position(handles.sub_title_chx,[5,250,70,20]);
            Set_position(handles.sub_title_edt,[73,250,146,20]);
            Set_position(handles.sub_font_txt,[5,220,146,20]);
            Set_position(handles.sub_font_pop,[73,220,146,20]);
            Set_position(handles.sub_size_txt,[5,190,146,20]);
            Set_position(handles.sub_size_edt,[73,190,146,20]);
            Set_position(handles.sub_position_txt,[5,160,146,20]);
            Set_position(handles.sub_position_chk,[73,160,146,20]);
            Set_position(handles.sub_x_txt,[1,130,40,20]);
            Set_position(handles.sub_x_edt,[41,130,70,20]);
            Set_position(handles.sub_y_txt,[111,130,40,20]);
            Set_position(handles.sub_y_edt,[151,130,70,20]);
            Set_position(handles.sub_w_txt,[1,100,40,20]);
            Set_position(handles.sub_w_edt,[41,100,70,20]);
            Set_position(handles.sub_h_txt,[111,100,40,20]);
            Set_position(handles.sub_h_edt,[151,100,70,20]);
            Set_position(handles.sub_col_txt,[1,70,40,20]);
            Set_position(handles.sub_col_edt,[41,70,70,20]);
            Set_position(handles.sub_row_txt,[111,70,40,20]);
            Set_position(handles.sub_row_edt,[151,70,70,20]);
            Set_position(handles.sub_update_btn,[5,30,220,30]);
        end
    end
    function init_panel_axis()
        handles.panel_axis=uipanel(handles.fig1,'bordertype','none','visible','off');
        handles.axis_reverse_chk=uicontrol(handles.panel_axis,'style','checkbox','string','XY-axis reverse');
        handles.axis_visible_chk=uicontrol(handles.panel_axis,'style','checkbox','string','visible');
        handles.axis_box_chk=uicontrol(handles.panel_axis,'style','checkbox','string','Box');
        handles.axis_legend_chk=uicontrol(handles.panel_axis,'style','checkbox','string','Legend');
        handles.axis_legend_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        
        handles.xaxis_txt=uicontrol(handles.panel_axis,'style','text','String','X axis:');
        handles.xaxis_limit_chk=uicontrol(handles.panel_axis,'style','checkbox','string','x-lim:');
        handles.xaxis_limit1_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        handles.xaxis_limit2_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        handles.xaxis_location_txt=uicontrol(handles.panel_axis,'style','text','string','Location:');
        handles.xaxis_hide_chx=uicontrol(handles.panel_axis,'style','checkbox','string','hide');
        handles.xaxis_location_pop=uicontrol(handles.panel_axis,'style','popupmenu','backgroundcolor',[1,1,1],'string',{'bottom','top','origin'});
        handles.xaxis_tick_chk=uicontrol(handles.panel_axis,'style','checkbox','string','auto ticks');
        handles.xaxis_tick_interval_txt=uicontrol(handles.panel_axis,'style','text','string','interval:');
        handles.xaxis_tick_interval_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        handles.xaxis_tick_anchor_txt=uicontrol(handles.panel_axis,'style','text','string','anchor:');
        handles.xaxis_tick_anchor_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        handles.xaxis_minor_tick_chk=uicontrol(handles.panel_axis,'style','checkbox','string','minor tick');
        handles.xaxis_grid_chk=uicontrol(handles.panel_axis,'style','checkbox','string','grid');
        handles.xaxis_minor_grid_chk=uicontrol(handles.panel_axis,'style','checkbox','string','minor grid');
        handles.xaxis_label_chk=uicontrol(handles.panel_axis,'style','checkbox','string','label:');
        handles.xaxis_label_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        
        handles.yaxis_txt=uicontrol(handles.panel_axis,'style','text','String','Y axis:');
        handles.yaxis_limit_chk=uicontrol(handles.panel_axis,'style','checkbox','string','y-lim:');
        handles.yaxis_limit1_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        handles.yaxis_limit2_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        handles.yaxis_location_txt=uicontrol(handles.panel_axis,'style','text','string','Location:');
        handles.yaxis_hide_chx=uicontrol(handles.panel_axis,'style','checkbox','string','hide');
        handles.yaxis_location_pop=uicontrol(handles.panel_axis,'style','popupmenu','backgroundcolor',[1,1,1],'string',{'left','right','origin'});
        handles.yaxis_tick_chk=uicontrol(handles.panel_axis,'style','checkbox','string','auto ticks');
        handles.yaxis_tick_interval_txt=uicontrol(handles.panel_axis,'style','text','string','interval:');
        handles.yaxis_tick_interval_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        handles.yaxis_tick_anchor_txt=uicontrol(handles.panel_axis,'style','text','string','anchor:');
        handles.yaxis_tick_anchor_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        handles.yaxis_minor_tick_chk=uicontrol(handles.panel_axis,'style','checkbox','string','minor tick');
        handles.yaxis_grid_chk=uicontrol(handles.panel_axis,'style','checkbox','string','grid');
        handles.yaxis_minor_grid_chk=uicontrol(handles.panel_axis,'style','checkbox','string','minor grid');
        handles.yaxis_label_chk=uicontrol(handles.panel_axis,'style','checkbox','string','label:');
        handles.yaxis_label_edt=uicontrol(handles.panel_axis,'style','edit','backgroundcolor',[1,1,1]);
        handles.yaxis_reverse_chk=uicontrol(handles.panel_axis,'style','checkbox','string','reverse');
        
        if verLessThan('matlab','8.4')
            set(handles.xaxis_location_pop,'string',{'bottom','top'});
            set(handles.yaxis_location_pop,'string',{'left','right'});
        end
        set(handles.xaxis_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.xaxis_location_txt,'HorizontalAlignment','left');
        set(handles.xaxis_tick_interval_txt,'HorizontalAlignment','left');
        set(handles.xaxis_tick_anchor_txt,'HorizontalAlignment','left');
        set(handles.yaxis_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.yaxis_location_txt,'HorizontalAlignment','left');
        set(handles.yaxis_tick_interval_txt,'HorizontalAlignment','left');
        set(handles.yaxis_tick_anchor_txt,'HorizontalAlignment','left');
        
        Set_position(handles.panel_axis,            [0,0,224,520]);
        Set_position(handles.axis_reverse_chk,      [5,490,120,20]);
        Set_position(handles.axis_box_chk,          [5,470,80,20]);
        Set_position(handles.axis_visible_chk,     [85,470,80,20]);
        Set_position(handles.axis_legend_chk,       [5,450,80,20]);
        Set_position(handles.axis_legend_edt,       [85,450,135,20]);
        
        Set_position(handles.xaxis_txt,             [3,420,120,20]);
        Set_position(handles.xaxis_limit_chk,       [5,400,55,20]);
        Set_position(handles.xaxis_limit1_edt,      [60,400,75,20]);
        Set_position(handles.xaxis_limit2_edt,      [145,400,75,20]);
        if ispc
            Set_position(handles.xaxis_location_txt,    [5,367,60,20]);
            Set_position(handles.xaxis_location_pop,    [65,370,100,20]);
        else
            Set_position(handles.xaxis_location_txt,    [5,367,50,20]);
            Set_position(handles.xaxis_location_pop,    [55,370,120,20]);
        end
        Set_position(handles.xaxis_hide_chx,        [175,370,50,20]);
        Set_position(handles.xaxis_tick_chk,        [5,340,90,20]);
        Set_position(handles.xaxis_minor_tick_chk,  [110,340,80,20]);
        Set_position(handles.xaxis_tick_interval_txt,[5,310,90,20]);
        Set_position(handles.xaxis_tick_anchor_txt, [120,310,90,20]);
        if ispc
            Set_position(handles.xaxis_tick_interval_edt,[50,310,60,20]);
            Set_position(handles.xaxis_tick_anchor_edt, [165,310,60,20]);
        else
            Set_position(handles.xaxis_tick_interval_edt,[45,310,60,20]);
            Set_position(handles.xaxis_tick_anchor_edt, [160,310,60,20]);
        end
        Set_position(handles.xaxis_grid_chk,        [5,280,80,20]);
        Set_position(handles.xaxis_minor_grid_chk,  [100,280,80,20]);
        Set_position(handles.xaxis_label_chk,       [5,250,55,20]);
        Set_position(handles.xaxis_label_edt,       [60,250,160,20]);
        
        Set_position(handles.yaxis_txt,             [3,190,120,20]);
        Set_position(handles.yaxis_limit_chk,       [5,170,55,20]);
        Set_position(handles.yaxis_limit1_edt,      [60,170,75,20]);
        Set_position(handles.yaxis_limit2_edt,      [145,170,75,20]);
        
        if ispc
            Set_position(handles.yaxis_location_txt,    [5,137,60,20]);
            Set_position(handles.yaxis_location_pop,    [65,140,100,20]);
        else
            Set_position(handles.yaxis_location_txt,    [5,137,50,20]);
            Set_position(handles.yaxis_location_pop,    [55,140,120,20]);
        end
        Set_position(handles.yaxis_hide_chx,        [175,140,50,20]);
        Set_position(handles.yaxis_tick_chk,        [5,110,90,20]);
        Set_position(handles.yaxis_minor_tick_chk,  [110,110,80,20]);
        Set_position(handles.yaxis_tick_interval_txt,[5,80,90,20]);
        Set_position(handles.yaxis_tick_anchor_txt, [120,80,90,20]);
        
        if ispc
            Set_position(handles.yaxis_tick_interval_edt,[50,80,60,20]);
            Set_position(handles.yaxis_tick_anchor_edt, [165,80,60,20]);
        else
            Set_position(handles.yaxis_tick_interval_edt,[45,80,60,20]);
            Set_position(handles.yaxis_tick_anchor_edt, [160,80,60,20]);
        end
        Set_position(handles.yaxis_grid_chk,        [5,50,60,20]);
        Set_position(handles.yaxis_minor_grid_chk,  [70,50,90,20]);
        Set_position(handles.yaxis_reverse_chk,     [160,50,60,20]);
        Set_position(handles.yaxis_label_chk,       [5,20,55,20]);
        Set_position(handles.yaxis_label_edt,       [60,20,160,20]);
    end
    function init_panel_content_manager()
        handles.panel_content_manager=uipanel(handles.fig1,'bordertype','none','visible','off');
        handles.content_add_txt=uicontrol(handles.panel_content_manager,'style','text','String','Content type:');
        %         handles.content_add_pop=uicontrol(handles.panel_content_manager,'style','popupmenu','backgroundcolor',[1,1,1],...
        %             'String',{'curve','lissajous','average','all_epoch','all_channel','std','line','rect','text'},'value',1);
        handles.content_add_pop=uicontrol(handles.panel_content_manager,'style','popupmenu','backgroundcolor',[1,1,1],...
            'String',{'curve','lissajous','line','rect','text'},'value',1);
        handles.content_add=uicontrol(handles.panel_content_manager,'style','pushbutton');
        handles.content_del=uicontrol(handles.panel_content_manager,'style','pushbutton');
        handles.content_up=uicontrol(handles.panel_content_manager,'style','pushbutton');
        handles.content_down=uicontrol(handles.panel_content_manager,'style','pushbutton');
        
        set(handles.content_add,'CData',icon.icon_dataset_add,'TooltipString','add');
        set(handles.content_del,'CData',icon.icon_dataset_del,'TooltipString','remove');
        set(handles.content_up,'CData',icon.icon_dataset_up,'TooltipString','up');
        set(handles.content_down,'CData',icon.icon_dataset_down,'TooltipString','down');
        set(handles.content_add_txt,'HorizontalAlignment','left');
        
        if ispc
            Set_position(handles.panel_content_manager,     [0,440,224,80]);
            Set_position(handles.content_add_txt,           [5,47,90,20]);
            Set_position(handles.content_add_pop,           [95,52,129,20]);
            Set_position(handles.content_add,               [5,1,50,40]);
            Set_position(handles.content_del,               [62,1,50,40]);
            Set_position(handles.content_up,                [118,1,50,40]);
            Set_position(handles.content_down,              [175,1,50,40]);
        else
            Set_position(handles.panel_content_manager,     [0,450,224,70]);
            Set_position(handles.content_add_txt,           [5,44,70,20]);
            Set_position(handles.content_add_pop,           [75,44,149,20]);
            Set_position(handles.content_add,               [4,1,50,40]);
            Set_position(handles.content_del,               [59,1,50,40]);
            Set_position(handles.content_up,                [114,1,50,40]);
            Set_position(handles.content_down,              [169,1,50,40]);
        end
    end
    function init_panel_curve()
        handles.panel_curve=uipanel(handles.fig1,'bordertype','none','visible','off');
        handles.panel_curve_config_txt=uicontrol(handles.panel_curve,'style','text','String','Config:');
        handles.panel_curve_color_btn=uicontrol(handles.panel_curve,'style','pushbutton','String','color','FontWeight','bold');
        handles.panel_curve_color_txt=uicontrol(handles.panel_curve,'style','text','String','Color: ');
        handles.panel_curve_width_txt=uicontrol(handles.panel_curve,'style','text','String','Width: ');
        handles.panel_curve_width_edt=uicontrol(handles.panel_curve,'style','edit','String','2','backgroundcolor',[1,1,1]);
        handles.panel_curve_style_txt=uicontrol(handles.panel_curve,'style','text','String','Line Style: ');
        handles.panel_curve_style_pop=uicontrol(handles.panel_curve,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'Solid','Dshed','Dotted','Dash-dotted','No Line'},'value',1);
        handles.panel_curve_marker_txt=uicontrol(handles.panel_curve,'style','text','String','Marker: ');
        handles.panel_curve_marker_pop=uicontrol(handles.panel_curve,'style','popupmenu','backgroundcolor',[1,1,1],...
            'String',{'No Marker','Circle','Plus sign','Asterisk','Point','Cross','Square','Cross','Diamond',...
            'Upward-pointing triangle','Downward-pointing triangle','Right-pointing triangle','Right-pointing triangle',...
            'Pentagram','Hexagram'},'value',1);
        
        handles.panel_curve_source_txt=uicontrol(handles.panel_curve,'style','text','String','Data Source:');
        handles.panel_curve_source_pop=uicontrol(handles.panel_curve,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_curve_source_epoch_pop=uicontrol(handles.panel_curve,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_curve_source_channel_pop=uicontrol(handles.panel_curve,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_curve_source_index_pop=uicontrol(handles.panel_curve,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_curve_source_y_edt=uicontrol(handles.panel_curve,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_curve_source_z_edt=uicontrol(handles.panel_curve,'style','edit','backgroundcolor',[1,1,1]);
        
        handles.panel_curve_source_epoch_txt=uicontrol(handles.panel_curve,'style','text','String','epoch: ');
        handles.panel_curve_source_channel_txt=uicontrol(handles.panel_curve,'style','text','String','channel: ');
        handles.panel_curve_source_index_txt=uicontrol(handles.panel_curve,'style','text','String','index: ');
        handles.panel_curve_source_y_txt=uicontrol(handles.panel_curve,'style','text','String','y: ');
        handles.panel_curve_source_z_txt=uicontrol(handles.panel_curve,'style','text','String','z: ');
        
        set(handles.panel_curve_config_txt,'HorizontalAlignment','left','fontweight','bold');
        c=get(handles.panel_curve_color_btn,'fontsize');
        set(handles.panel_curve_color_btn,'fontsize',c+2);
        set(handles.panel_curve_color_txt,'HorizontalAlignment','left');
        set(handles.panel_curve_width_txt,'HorizontalAlignment','left');
        set(handles.panel_curve_style_txt,'HorizontalAlignment','left');
        set(handles.panel_curve_marker_txt,'HorizontalAlignment','left');
        set(handles.panel_curve_source_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.panel_curve_source_epoch_txt,'HorizontalAlignment','left');
        set(handles.panel_curve_source_channel_txt,'HorizontalAlignment','left');
        set(handles.panel_curve_source_index_txt,'HorizontalAlignment','left');
        set(handles.panel_curve_source_y_txt,'HorizontalAlignment','left');
        set(handles.panel_curve_source_z_txt,'HorizontalAlignment','left');
        
        Set_position(handles.panel_curve,[0,0,224,440]);
        if ispc
            Set_position(handles.panel_curve_config_txt,[5,400,80,20]);
            Set_position(handles.panel_curve_color_txt,[5,370,75,20]);
            Set_position(handles.panel_curve_color_btn,[80,370,145,30]);
            Set_position(handles.panel_curve_width_txt,[5,338,75,20]);
            Set_position(handles.panel_curve_width_edt,[80,340,145,25]);
            Set_position(handles.panel_curve_style_txt,[5,305,75,20]);
            Set_position(handles.panel_curve_style_pop,[80,310,145,25]);
            Set_position(handles.panel_curve_marker_txt,[5,277,75,20]);
            Set_position(handles.panel_curve_marker_pop,[80,280,145,25]);
            
            Set_position(handles.panel_curve_source_txt,[5,220,150,20]);
            Set_position(handles.panel_curve_source_pop,[5,200,220,20]);
            Set_position(handles.panel_curve_source_epoch_txt,[5,165,75,20]);
            Set_position(handles.panel_curve_source_epoch_pop,[80,167,145,20]);
            Set_position(handles.panel_curve_source_channel_txt,[5,135,75,20]);
            Set_position(handles.panel_curve_source_channel_pop,[80,137,145,20]);
            Set_position(handles.panel_curve_source_index_txt,[5,105,75,20]);
            Set_position(handles.panel_curve_source_index_pop,[80,107,145,20]);
            Set_position(handles.panel_curve_source_y_txt,[5,73,75,20]);
            Set_position(handles.panel_curve_source_y_edt,[80,70,145,25]);
            Set_position(handles.panel_curve_source_z_txt,[5,40,75,20]);
            Set_position(handles.panel_curve_source_z_edt,[80,42,145,25]);
        else
            Set_position(handles.panel_curve_config_txt,[5,400,80,20]);
            Set_position(handles.panel_curve_color_txt,[5,370,80,20]);
            Set_position(handles.panel_curve_color_btn,[83,370,136,30]);
            Set_position(handles.panel_curve_width_txt,[5,337,80,20]);
            Set_position(handles.panel_curve_width_edt,[85,340,130,20]);
            Set_position(handles.panel_curve_style_txt,[5,305,80,20]);
            Set_position(handles.panel_curve_style_pop,[81,310,141,20]);
            Set_position(handles.panel_curve_marker_txt,[5,277,80,20]);
            Set_position(handles.panel_curve_marker_pop,[81,280,141,20]);
            
            Set_position(handles.panel_curve_source_txt,[5,220,150,20]);
            Set_position(handles.panel_curve_source_pop,[2,200,225,20]);
            Set_position(handles.panel_curve_source_epoch_txt,[5,170,50,20]);
            Set_position(handles.panel_curve_source_epoch_pop,[81,170,141,20]);
            Set_position(handles.panel_curve_source_channel_txt,[5,140,50,20]);
            Set_position(handles.panel_curve_source_channel_pop,[81,140,141,20]);
            Set_position(handles.panel_curve_source_index_txt,[5,110,50,20]);
            Set_position(handles.panel_curve_source_index_pop,[81,110,141,20]);
            Set_position(handles.panel_curve_source_y_txt,[5,80,30,20]);
            Set_position(handles.panel_curve_source_y_edt,[85,80,130,20]);
            Set_position(handles.panel_curve_source_z_txt,[5,50,30,20]);
            Set_position(handles.panel_curve_source_z_edt,[85,50,130,20]);
        end
    end
    function init_panel_line()
        handles.panel_line=uipanel(handles.fig1,'bordertype','none','visible','off');
        handles.panel_line_config_txt=uicontrol(handles.panel_line,'style','text','String','Config:');
        handles.panel_line_color_btn=uicontrol(handles.panel_line,...
            'style','pushbutton','String','color','FontWeight','bold');
        c=get(handles.panel_line_color_btn,'fontsize');
        set(handles.panel_line_color_btn,'fontsize',c+2);
        
        handles.panel_line_from_txt=uicontrol(handles.panel_line,...
            'style','text','String','From: ');
        handles.panel_line_to_txt=uicontrol(handles.panel_line,...
            'style','text','String','To: ');
        handles.panel_line_x1_txt=uicontrol(handles.panel_line,...
            'style','text','String','x1: ');
        handles.panel_line_x2_txt=uicontrol(handles.panel_line,...
            'style','text','String','x2: ');
        handles.panel_line_y1_txt=uicontrol(handles.panel_line,...
            'style','text','String','y1: ');
        handles.panel_line_y2_txt=uicontrol(handles.panel_line,...
            'style','text','String','y2: ');
        
        handles.panel_line_x1_edt=uicontrol(handles.panel_line,...
            'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_line_y1_edt=uicontrol(handles.panel_line,...
            'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_line_x2_edt=uicontrol(handles.panel_line,...
            'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_line_y2_edt=uicontrol(handles.panel_line,...
            'style','edit','backgroundcolor',[1,1,1]);
        
        handles.panel_line_color_txt=uicontrol(handles.panel_line,...
            'style','text','String','Color: ');
        handles.panel_line_width_txt=uicontrol(handles.panel_line,...
            'style','text','String','Width: ');
        handles.panel_line_width_edt=uicontrol(handles.panel_line,...
            'style','edit','String','2','backgroundcolor',[1,1,1]);
        handles.panel_line_style_txt=uicontrol(handles.panel_line,'style','text','String','Line Style: ');
        handles.panel_line_style_pop=uicontrol(handles.panel_line,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'Solid','Dshed','Dotted','Dash-dotted','No Line'},'value',1);
        handles.panel_line_marker_txt=uicontrol(handles.panel_line,'style','text','String','Marker: ');
        handles.panel_line_marker_pop=uicontrol(handles.panel_line,'style','popupmenu','backgroundcolor',[1,1,1],...
            'String',{'No Marker','Circle','Plus sign','Asterisk','Point','Cross','Square','Cross','Diamond',...
            'Upward-pointing triangle','Downward-pointing triangle','Right-pointing triangle','Right-pointing triangle',...
            'Pentagram','Hexagram'},'value',1);
        
        set(handles.panel_line_config_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.panel_line_color_txt,'HorizontalAlignment','left');
        set(handles.panel_line_width_txt,'HorizontalAlignment','left');
        set(handles.panel_line_style_txt,'HorizontalAlignment','left');
        set(handles.panel_line_marker_txt,'HorizontalAlignment','left');
        
        set(handles.panel_line_from_txt,'HorizontalAlignment','left');
        set(handles.panel_line_to_txt,'HorizontalAlignment','left');
        set(handles.panel_line_x1_txt,'HorizontalAlignment','left');
        set(handles.panel_line_x2_txt,'HorizontalAlignment','left');
        set(handles.panel_line_y1_txt,'HorizontalAlignment','left');
        set(handles.panel_line_y2_txt,'HorizontalAlignment','left');
        
        Set_position(handles.panel_line,[0,0,224,440]);
        if ispc
            Set_position(handles.panel_line_config_txt,[5,400,55,20]);
            Set_position(handles.panel_line_color_txt,[5,370,75,20]);
            Set_position(handles.panel_line_color_btn,[80,370,145,30]);
            Set_position(handles.panel_line_width_txt,[5,335,75,20]);
            Set_position(handles.panel_line_width_edt,[80,335,145,25]);
            Set_position(handles.panel_line_style_txt,[5,305,75,20]);
            Set_position(handles.panel_line_style_pop,[80,310,145,20]);
            Set_position(handles.panel_line_marker_txt,[5,275,75,20]);
            Set_position(handles.panel_line_marker_pop,[80,280,145,20]);
            
            Set_position(handles.panel_line_from_txt,[5,245,110,20]);
            Set_position(handles.panel_line_x1_txt,[13,220,20,20]);
            Set_position(handles.panel_line_x1_edt,[35,220,80,20]);
            Set_position(handles.panel_line_y1_txt,[125,220,20,20]);
            Set_position(handles.panel_line_y1_edt,[145,220,80,20]);
            
            Set_position(handles.panel_line_to_txt,[5,185,110,20]);
            Set_position(handles.panel_line_x2_txt,[13,160,20,20]);
            Set_position(handles.panel_line_x2_edt,[35,160,80,20]);
            Set_position(handles.panel_line_y2_txt,[125,160,20,20]);
            Set_position(handles.panel_line_y2_edt,[145,160,80,20]);
        else
            
            Set_position(handles.panel_line_config_txt,[5,400,55,20]);
            Set_position(handles.panel_line_color_txt,[5,370,55,20]);
            Set_position(handles.panel_line_color_btn,[83,370,136,30]);
            Set_position(handles.panel_line_width_txt,[5,340,55,20]);
            Set_position(handles.panel_line_width_edt,[85,340,130,20]);
            Set_position(handles.panel_line_style_txt,[5,310,80,20]);
            Set_position(handles.panel_line_style_pop,[81,310,141,20]);
            Set_position(handles.panel_line_marker_txt,[5,280,80,20]);
            Set_position(handles.panel_line_marker_pop,[81,280,141,20]);
            
            Set_position(handles.panel_line_from_txt,[5,245,110,20]);
            Set_position(handles.panel_line_x1_txt,[13,220,20,20]);
            Set_position(handles.panel_line_x1_edt,[35,220,80,20]);
            Set_position(handles.panel_line_y1_txt,[120,220,20,20]);
            Set_position(handles.panel_line_y1_edt,[140,220,80,20]);
            
            Set_position(handles.panel_line_to_txt,[5,185,110,20]);
            Set_position(handles.panel_line_x2_txt,[13,160,20,20]);
            Set_position(handles.panel_line_x2_edt,[35,160,80,20]);
            Set_position(handles.panel_line_y2_txt,[120,160,20,20]);
            Set_position(handles.panel_line_y2_edt,[140,160,80,20]);
        end
    end
    function init_panel_rect()
        handles.panel_rect=uipanel(handles.fig1,'bordertype','none','visible','off');
        handles.panel_rect_config_txt=uicontrol(handles.panel_rect,'style','text','String','Config:');
        handles.panel_rect_facecolor_txt=uicontrol(handles.panel_rect,...
            'style','text','String','Face Color: ');
        handles.panel_rect_facecolor_btn=uicontrol(handles.panel_rect,...
            'style','pushbutton','String','color','FontWeight','bold');
        c=get(handles.panel_rect_facecolor_btn,'fontsize');
        set(handles.panel_rect_facecolor_btn,'fontsize',c+2);
        
        handles.panel_rect_edgecolor_txt=uicontrol(handles.panel_rect,...
            'style','text','String','Edge Color: ');
        handles.panel_rect_edgecolor_btn=uicontrol(handles.panel_rect,...
            'style','pushbutton','String','color','FontWeight','bold');
        c=get(handles.panel_rect_edgecolor_btn,'fontsize');
        set(handles.panel_rect_edgecolor_btn,'fontsize',c+2);
        
        handles.panel_rect_pos_txt=uicontrol(handles.panel_rect,...
            'style','text','String','Position: ');
        handles.panel_rect_x_txt=uicontrol(handles.panel_rect,...
            'style','text','String','x: ');
        handles.panel_rect_y_txt=uicontrol(handles.panel_rect,...
            'style','text','String','y: ');
        handles.panel_rect_w_txt=uicontrol(handles.panel_rect,...
            'style','text','String','w: ');
        handles.panel_rect_h_txt=uicontrol(handles.panel_rect,...
            'style','text','String','h: ');
        
        handles.panel_rect_x_edt=uicontrol(handles.panel_rect,...
            'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_rect_y_edt=uicontrol(handles.panel_rect,...
            'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_rect_w_edt=uicontrol(handles.panel_rect,...
            'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_rect_h_edt=uicontrol(handles.panel_rect,...
            'style','edit','backgroundcolor',[1,1,1]);
        
        handles.panel_rect_width_txt=uicontrol(handles.panel_rect,...
            'style','text','String','Edge Width : ');
        handles.panel_rect_width_edt=uicontrol(handles.panel_rect,...
            'style','edit','String','2','backgroundcolor',[1,1,1]);
        handles.panel_rect_facealpha_txt=uicontrol(handles.panel_rect,...
            'style','text','String','Face Opacity: ');
        handles.panel_rect_facealpha_edt=uicontrol(handles.panel_rect,...
            'style','edit','String','1','backgroundcolor',[1,1,1]);
        handles.panel_rect_edgealpha_txt=uicontrol(handles.panel_rect,...
            'style','text','String','Edge Opacity: ');
        handles.panel_rect_edgealpha_edt=uicontrol(handles.panel_rect,...
            'style','edit','String','1','backgroundcolor',[1,1,1]);
        
        set(handles.panel_rect_config_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.panel_rect_facecolor_txt,'HorizontalAlignment','left');
        set(handles.panel_rect_edgecolor_txt,'HorizontalAlignment','left');
        set(handles.panel_rect_width_txt,'HorizontalAlignment','left');
        set(handles.panel_rect_facealpha_txt,'HorizontalAlignment','left');
        set(handles.panel_rect_edgealpha_txt,'HorizontalAlignment','left');
        
        set(handles.panel_rect_pos_txt,'HorizontalAlignment','left');
        set(handles.panel_rect_x_txt,'HorizontalAlignment','right');
        set(handles.panel_rect_y_txt,'HorizontalAlignment','right');
        set(handles.panel_rect_w_txt,'HorizontalAlignment','right');
        set(handles.panel_rect_h_txt,'HorizontalAlignment','right');
        if ispc
            Set_position(handles.panel_rect,[0,0,224,440]);
            Set_position(handles.panel_rect_config_txt,[5,400,80,20]);
            Set_position(handles.panel_rect_facecolor_txt,[5,370,85,20]);
            Set_position(handles.panel_rect_facecolor_btn,[95,370,130,30]);
            Set_position(handles.panel_rect_facealpha_txt,[5,340,90,20]);
            Set_position(handles.panel_rect_facealpha_edt,[95,337,130,25]);
            Set_position(handles.panel_rect_edgecolor_txt,[5,305,80,20]);
            Set_position(handles.panel_rect_edgecolor_btn,[95,300,130,30]);
            Set_position(handles.panel_rect_edgealpha_txt,[5,270,90,20]);
            Set_position(handles.panel_rect_edgealpha_edt,[95,270,130,25]);
            Set_position(handles.panel_rect_width_txt,[5,240,80,20]);
            Set_position(handles.panel_rect_width_edt,[95,240,130,25]);
            
            Set_position(handles.panel_rect_pos_txt,[5,205,110,20]);
            Set_position(handles.panel_rect_x_txt,[3,175,40,20]);
            Set_position(handles.panel_rect_x_edt,[45,175,65,20]);
            Set_position(handles.panel_rect_y_txt,[110,175,45,20]);
            Set_position(handles.panel_rect_y_edt,[160,175,65,20]);
            Set_position(handles.panel_rect_w_txt,[3,150,40,20]);
            Set_position(handles.panel_rect_w_edt,[45,150,65,20]);
            Set_position(handles.panel_rect_h_txt,[110,150,45,20]);
            Set_position(handles.panel_rect_h_edt,[160,150,65,20]);
        else
            Set_position(handles.panel_rect,[0,0,224,440]);
            Set_position(handles.panel_rect_config_txt,[5,400,80,20]);
            Set_position(handles.panel_rect_facecolor_txt,[5,370,75,20]);
            Set_position(handles.panel_rect_facecolor_btn,[83,370,136,30]);
            Set_position(handles.panel_rect_facealpha_txt,[5,340,75,20]);
            Set_position(handles.panel_rect_facealpha_edt,[85,340,130,25]);
            Set_position(handles.panel_rect_edgecolor_txt,[5,300,75,20]);
            Set_position(handles.panel_rect_edgecolor_btn,[83,300,136,30]);
            Set_position(handles.panel_rect_edgealpha_txt,[5,270,75,20]);
            Set_position(handles.panel_rect_edgealpha_edt,[85,270,130,25]);
            Set_position(handles.panel_rect_width_txt,[5,240,75,20]);
            Set_position(handles.panel_rect_width_edt,[85,240,130,25]);
            
            Set_position(handles.panel_rect_pos_txt,[5,205,110,20]);
            Set_position(handles.panel_rect_x_txt,[3,175,40,20]);
            Set_position(handles.panel_rect_x_edt,[45,175,60,20]);
            Set_position(handles.panel_rect_y_txt,[110,175,45,20]);
            Set_position(handles.panel_rect_y_edt,[160,175,60,20]);
            Set_position(handles.panel_rect_w_txt,[3,150,40,20]);
            Set_position(handles.panel_rect_w_edt,[45,150,60,20]);
            Set_position(handles.panel_rect_h_txt,[110,150,45,20]);
            Set_position(handles.panel_rect_h_edt,[160,150,60,20]);
        end
    end
    function init_panel_text()
        handles.panel_text=uipanel(handles.fig1,'bordertype','none','visible','off');
        handles.panel_text_config_txt=uicontrol(handles.panel_text,'style','text','String','Config:');
        
        % string
        handles.panel_text_text_txt=uicontrol(handles.panel_text,...
            'style','text','String','text:');
        handles.panel_text_text_edt=uicontrol(handles.panel_text,...
            'style','edit','String','some text','max',100,'min',1,'backgroundcolor',[1,1,1]);
        
        % bold & italic
        handles.panel_text_bold_chk=uicontrol(handles.panel_text,...
            'style','checkbox','String','Bold','FontWeight','bold');
        handles.panel_text_italic_chk=uicontrol(handles.panel_text,...
            'style','checkbox','String','Italic','FontAngle','italic');
        
        % color
        handles.panel_text_color_txt=uicontrol(handles.panel_text,...
            'style','text','String','Color: ');
        handles.panel_text_color_btn=uicontrol(handles.panel_text,...
            'style','pushbutton','String','color','FontWeight','bold');
        c=get(handles.panel_text_color_btn,'fontsize');
        set(handles.panel_text_color_btn,'fontsize',c+2);
        
        % font
        handles.panel_text_font_txt=uicontrol(handles.panel_text,...
            'style','text','String','Font:');
        handles.panel_text_font_pop=uicontrol(handles.panel_text,'style','popupmenu','backgroundcolor',[1,1,1]);
        a=find(strcmpi(listfonts,'Arial')==1);
        set(handles.panel_text_font_pop,'String',listfonts,'value',a(1));
        
        % size
        handles.panel_text_size_txt=uicontrol(handles.panel_text,...
            'style','text','String','Size: ');
        handles.panel_text_size_edt=uicontrol(handles.panel_text,...
            'style','edit','String','10','backgroundcolor',[1,1,1]);
        
        % position
        handles.panel_text_x_txt=uicontrol(handles.panel_text,...
            'style','text','String','x: ');
        handles.panel_text_y_txt=uicontrol(handles.panel_text,...
            'style','text','String','y: ');
        
        handles.panel_text_x_edt=uicontrol(handles.panel_text,...
            'style','edit','String','0','backgroundcolor',[1,1,1]);
        handles.panel_text_y_edt=uicontrol(handles.panel_text,...
            'style','edit','String','0','backgroundcolor',[1,1,1]);
        
        set(handles.panel_text_config_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.panel_text_text_txt,'HorizontalAlignment','left');
        set(handles.panel_text_text_edt,'HorizontalAlignment','left');
        set(handles.panel_text_color_txt,'HorizontalAlignment','left');
        set(handles.panel_text_font_txt,'HorizontalAlignment','left');
        set(handles.panel_text_size_txt,'HorizontalAlignment','left');
        set(handles.panel_text_x_txt,'HorizontalAlignment','left');
        set(handles.panel_text_y_txt,'HorizontalAlignment','left');
        
        if ispc
            Set_position(handles.panel_text,[0,0,224,440]);
            Set_position(handles.panel_text_config_txt,[5,400,55,20]);
            Set_position(handles.panel_text_text_txt,[5,380,30,20]);
            Set_position(handles.panel_text_text_edt,[5,270,220,110]);
            Set_position(handles.panel_text_x_txt,[5,240,65,20]);
            Set_position(handles.panel_text_x_edt,[70,240,155,23]);
            Set_position(handles.panel_text_y_txt,[5,210,55,20]);
            Set_position(handles.panel_text_y_edt,[70,210,155,23]);
            Set_position(handles.panel_text_color_txt,[5,170,55,20]);
            Set_position(handles.panel_text_color_btn,[70,170,155,30]);
            Set_position(handles.panel_text_font_txt,[5,140,55,20]);
            Set_position(handles.panel_text_font_pop,[70,140,155,20]);
            Set_position(handles.panel_text_size_txt,[5,105,55,20]);
            Set_position(handles.panel_text_size_edt,[70,105,155,23]);
            Set_position(handles.panel_text_bold_chk,[5,75,50,20]);
            Set_position(handles.panel_text_italic_chk,[110,75,50,20]);
        else
            Set_position(handles.panel_text,[0,0,224,440]);
            Set_position(handles.panel_text_config_txt,[5,400,55,20]);
            Set_position(handles.panel_text_text_txt,[5,380,30,20]);
            Set_position(handles.panel_text_text_edt,[5,270,225,110]);
            Set_position(handles.panel_text_x_txt,[5,240,55,20]);
            Set_position(handles.panel_text_x_edt,[85,240,130,20]);
            Set_position(handles.panel_text_y_txt,[5,210,55,20]);
            Set_position(handles.panel_text_y_edt,[85,210,130,20]);
            Set_position(handles.panel_text_color_txt,[5,170,55,20]);
            Set_position(handles.panel_text_color_btn,[83,170,136,30]);
            Set_position(handles.panel_text_font_txt,[5,140,55,20]);
            Set_position(handles.panel_text_font_pop,[81,140,141,20]);
            Set_position(handles.panel_text_size_txt,[5,110,55,20]);
            Set_position(handles.panel_text_size_edt,[85,110,130,20]);
            
            Set_position(handles.panel_text_bold_chk,[13,80,50,20]);
            Set_position(handles.panel_text_italic_chk,[110,80,50,20]);
        end
    end
    function init_panel_image()
        handles.panel_image=uipanel(handles.fig1,'bordertype','none','visible','off');
        
        %source
        handles.panel_image_source_txt=uicontrol(handles.panel_image,...
            'style','text','String','Source:','Fontweight','bold');
        handles.panel_image_source_pop=uicontrol(handles.panel_image,...
            'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_image_source_epoch_pop=uicontrol(handles.panel_image,...
            'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_image_source_channel_pop=uicontrol(handles.panel_image,...
            'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_image_source_index_pop=uicontrol(handles.panel_image,...
            'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_image_source_z_edt=uicontrol(handles.panel_image,...
            'style','edit','backgroundcolor',[1,1,1]);
        
        handles.panel_image_source_epoch_txt=uicontrol(handles.panel_image,...
            'style','text','String','epoch: ');
        handles.panel_image_source_channel_txt=uicontrol(handles.panel_image,...
            'style','text','String','channel: ');
        handles.panel_image_source_index_txt=uicontrol(handles.panel_image,...
            'style','text','String','index: ');
        handles.panel_image_source_z_txt=uicontrol(handles.panel_image,...
            'style','text','String','z: ');
        
        % color
        handles.panel_image_color_txt=uicontrol(handles.panel_image,...
            'style','text','String','Color: ','Fontweight','bold');
        handles.panel_image_colorbar_chk=uicontrol(handles.panel_image,...
            'style','checkbox','String','colorbar');
        handles.panel_image_colormap_txt=uicontrol(handles.panel_image,...
            'style','text','String','colormap: ');
        if verLessThan('matlab','8.4')
            handles.panel_image_colormap_pop=uicontrol(handles.panel_image,...
                'style','popupmenu','String',{'jet','hsv','hot','cool',...
                'spring','summer','autumn','winter','gray','bone','copper',...
                'pink'},'value',1,'backgroundcolor',[1,1,1]);
        else
            handles.panel_image_colormap_pop=uicontrol(handles.panel_image,...
                'style','popupmenu','String',{'parula','jet','hsv','hot','cool',...
                'spring','summer','autumn','winter','gray','bone','copper',...
                'pink'},'Value',1,'backgroundcolor',[1,1,1]);
        end
        handles.panel_image_clim_chk=uicontrol(handles.panel_image,...
            'style','checkbox','String','range: ');
        handles.panel_image_clim1_edt=uicontrol(handles.panel_image,...
            'style','edit','String','0','backgroundcolor',[1,1,1]);
        handles.panel_image_clim2_edt=uicontrol(handles.panel_image,...
            'style','edit','String','1','backgroundcolor',[1,1,1]);
        handles.panel_image_clim3_txt=uicontrol(handles.panel_image,...
            'style','text','String','-');
        
        %contour
        handles.panel_image_contour_chk=uicontrol(handles.panel_image,...
            'style','checkbox','String','enable');
        handles.panel_image_contour_txt=uicontrol(handles.panel_image,...
            'style','text','String','Contour:','Fontweight','bold');
        handles.panel_image_contour_color_txt=uicontrol(handles.panel_image,...
            'style','text','String','color: ');
        handles.panel_image_contour_color_btn=uicontrol(handles.panel_image,...
            'style','pushbutton','String','color','FontWeight','bold');
        c=get(handles.panel_image_contour_color_btn,'fontsize');
        set(handles.panel_image_contour_color_btn,'fontsize',c+2);
        
        
        handles.panel_image_contour_level_txt=uicontrol(handles.panel_image,...
            'style','text','String','level: ');
        handles.panel_image_contour_level_chk=uicontrol(handles.panel_image,...
            'style','checkbox','String','auto ');
        handles.panel_image_contour_start_txt=uicontrol(handles.panel_image,...
            'style','text','String','start: ');
        handles.panel_image_contour_end_txt=uicontrol(handles.panel_image,...
            'style','text','String','end: ');
        handles.panel_image_contour_step_txt=uicontrol(handles.panel_image,...
            'style','text','String','step: ');
        handles.panel_image_contour_start_edt=uicontrol(handles.panel_image,...
            'style','edit');
        handles.panel_image_contour_end_edt=uicontrol(handles.panel_image,...
            'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_image_contour_step_edt=uicontrol(handles.panel_image,...
            'style','edit','backgroundcolor',[1,1,1]);
        
        handles.panel_image_contour_width_txt=uicontrol(handles.panel_image,...
            'style','text','String','width: ');
        handles.panel_image_contour_style_txt=uicontrol(handles.panel_image,...
            'style','text','String','style: ');
        handles.panel_image_contour_width_edt=uicontrol(handles.panel_image,...
            'style','edit','String','2','backgroundcolor',[1,1,1]);
        handles.panel_image_contour_style_pop=uicontrol(handles.panel_image,...
            'style','popupmenu','backgroundcolor',[1,1,1],'String',{'Solid','Dshed','Dotted','Dash-dotted'},'value',1);
        
        set(handles.panel_image_source_txt,'HorizontalAlignment','left');
        set(handles.panel_image_source_epoch_txt,'HorizontalAlignment','left');
        set(handles.panel_image_source_channel_txt,'HorizontalAlignment','left');
        set(handles.panel_image_source_index_txt,'HorizontalAlignment','left');
        set(handles.panel_image_source_z_txt,'HorizontalAlignment','left');
        
        set(handles.panel_image_color_txt,'HorizontalAlignment','left');
        set(handles.panel_image_colormap_txt,'HorizontalAlignment','left');
        set(handles.panel_image_clim_chk,'HorizontalAlignment','left');
        set(handles.panel_image_clim3_txt,'HorizontalAlignment','left');
        
        set(handles.panel_image_contour_txt,'HorizontalAlignment','left');
        set(handles.panel_image_contour_color_txt,'HorizontalAlignment','left');
        set(handles.panel_image_contour_width_txt,'HorizontalAlignment','left');
        set(handles.panel_image_contour_style_txt,'HorizontalAlignment','left');
        
        set(handles.panel_image_contour_level_txt,'HorizontalAlignment','left');
        set(handles.panel_image_contour_start_txt,'HorizontalAlignment','left');
        set(handles.panel_image_contour_end_txt,'HorizontalAlignment','right');
        set(handles.panel_image_contour_step_txt,'HorizontalAlignment','left');
        
        if ispc
            Set_position(handles.panel_image,[0,0,224,440]);
            Set_position(handles.panel_image_source_txt,        [5,410,55,20]);
            Set_position(handles.panel_image_source_pop,        [5,390,220,20]);
            
            Set_position(handles.panel_image_source_epoch_txt,  [5,357,54,20]);
            Set_position(handles.panel_image_source_epoch_pop,  [60,360,60,20]);
            Set_position(handles.panel_image_source_channel_txt,[5,327,54,20]);
            Set_position(handles.panel_image_source_channel_pop,[60,330,60,20]);
            Set_position(handles.panel_image_source_index_txt,  [125,357,39,20]);
            Set_position(handles.panel_image_source_index_pop,  [165,360,60,20]);
            Set_position(handles.panel_image_source_z_txt,      [125,325,39,20]);
            Set_position(handles.panel_image_source_z_edt,      [165,325,60,23]);
            
            Set_position(handles.panel_image_color_txt,         [5,290,60,20]);
            Set_position(handles.panel_image_colorbar_chk,      [70,290,100,20]);
            Set_position(handles.panel_image_colormap_txt,      [5,263,65,20]);
            Set_position(handles.panel_image_colormap_pop,      [70,265,155,20]);
            Set_position(handles.panel_image_clim_chk,          [5,230,64,20]);
            Set_position(handles.panel_image_clim1_edt,        [70,230,72,20]);
            Set_position(handles.panel_image_clim3_txt,        [143,230,8,20]);
            Set_position(handles.panel_image_clim2_edt,        [153,230,72,20]);
            
            Set_position(handles.panel_image_contour_txt,      [5,190,60,20]);
            Set_position(handles.panel_image_contour_chk,      [70,190,155,20]);
            Set_position(handles.panel_image_contour_color_txt,[5,157,45,20]);
            Set_position(handles.panel_image_contour_color_btn,[70,155,155,30]);
            Set_position(handles.panel_image_contour_width_txt,[5,125,45,20]);
            Set_position(handles.panel_image_contour_width_edt,[70,125,155,23]);
            Set_position(handles.panel_image_contour_style_txt,[5,95,45,20]);
            Set_position(handles.panel_image_contour_style_pop,[70,95,155,20]);
            
            Set_position(handles.panel_image_contour_level_txt,[5,65,45,20]);
            Set_position(handles.panel_image_contour_level_chk,[70,65,110,20]);
            Set_position(handles.panel_image_contour_start_txt,[5,35,35,20]);
            Set_position(handles.panel_image_contour_start_edt,[45,35,70,20]);
            Set_position(handles.panel_image_contour_end_txt,  [115,35,35,20]);
            Set_position(handles.panel_image_contour_end_edt,  [150,35,70,20]);
            Set_position(handles.panel_image_contour_step_txt, [5,5,35,20]);
            Set_position(handles.panel_image_contour_step_edt, [45,5,70,20]);
        else
            Set_position(handles.panel_image,[0,0,224,440]);
            Set_position(handles.panel_image_source_txt,        [5,425,55,20]);
            Set_position(handles.panel_image_source_pop,        [1,405,220,20]);
            Set_position(handles.panel_image_source_epoch_txt,  [5,375,55,20]);
            Set_position(handles.panel_image_source_epoch_pop,  [81,375,141,20]);
            Set_position(handles.panel_image_source_channel_txt,[5,345,55,20]);
            Set_position(handles.panel_image_source_channel_pop,[81,345,141,20]);
            Set_position(handles.panel_image_source_index_txt,  [5,315,55,20]);
            Set_position(handles.panel_image_source_index_pop,  [81,315,141,20]);
            Set_position(handles.panel_image_source_z_txt,      [5,285,55,20]);
            Set_position(handles.panel_image_source_z_edt,      [85,285,130,20]);
            
            Set_position(handles.panel_image_color_txt,         [5,255,50,20]);
            Set_position(handles.panel_image_colorbar_chk,      [60,255,100,20]);
            Set_position(handles.panel_image_colormap_txt,      [5,235,50,20]);
            Set_position(handles.panel_image_colormap_pop,      [81,235,141,20]);
            Set_position(handles.panel_image_clim_chk,          [2,205,58,20]);
            Set_position(handles.panel_image_clim1_edt,        [60,205,70,20]);
            Set_position(handles.panel_image_clim3_txt,        [135,205,10,20]);
            Set_position(handles.panel_image_clim2_edt,        [145,205,70,20]);
            
            Set_position(handles.panel_image_contour_txt,      [5,175,55,20]);
            Set_position(handles.panel_image_contour_chk,      [60,175,110,20]);
            Set_position(handles.panel_image_contour_color_txt,[5,150,45,20]);
            Set_position(handles.panel_image_contour_color_btn,[83,150,136,30]);
            Set_position(handles.panel_image_contour_width_txt,[5,120,45,20]);
            Set_position(handles.panel_image_contour_width_edt,[85,120,130,20]);
            Set_position(handles.panel_image_contour_style_txt,[5,90,45,20]);
            Set_position(handles.panel_image_contour_style_pop,[81,90,141,20]);
            
            Set_position(handles.panel_image_contour_level_txt,[5,60,45,20]);
            Set_position(handles.panel_image_contour_level_chk,[60,60,110,20]);
            Set_position(handles.panel_image_contour_start_txt,[13,32,35,20]);
            Set_position(handles.panel_image_contour_start_edt,[45,32,70,20]);
            Set_position(handles.panel_image_contour_end_txt,  [115,32,35,20]);
            Set_position(handles.panel_image_contour_end_edt,  [150,32,70,20]);
            Set_position(handles.panel_image_contour_step_txt, [13,5,35,20]);
            Set_position(handles.panel_image_contour_step_edt, [45,5,70,20]);
        end
    end
    function init_panel_topo()
        handles.panel_topo=uipanel(handles.fig1,'bordertype','none','visible','off');
        
        handles.panel_topo_source_txt=uicontrol(handles.panel_topo,'style','text','String','Data Source:');
        handles.panel_topo_source_pop=uicontrol(handles.panel_topo,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_topo_source_epoch_txt=uicontrol(handles.panel_topo,'style','text','String','epoch:');
        handles.panel_topo_source_epoch_pop=uicontrol(handles.panel_topo,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_topo_source_index_txt=uicontrol(handles.panel_topo,'style','text','String','index:');
        handles.panel_topo_source_index_pop=uicontrol(handles.panel_topo,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_topo_source_x_txt=uicontrol(handles.panel_topo,'style','text','String','x: ');
        handles.panel_topo_source_x1_edt=uicontrol(handles.panel_topo,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_topo_source_x2_edt=uicontrol(handles.panel_topo,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_topo_source_y_txt=uicontrol(handles.panel_topo,'style','text','String','y: ');
        handles.panel_topo_source_y1_edt=uicontrol(handles.panel_topo,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_topo_source_y2_edt=uicontrol(handles.panel_topo,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_topo_source_z_txt=uicontrol(handles.panel_topo,'style','text','String','z: ');
        handles.panel_topo_source_z1_edt=uicontrol(handles.panel_topo,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_topo_source_z2_edt=uicontrol(handles.panel_topo,'style','edit','backgroundcolor',[1,1,1]);
        
        handles.panel_topo_property_txt=uicontrol(handles.panel_topo,'style','text','String','Property: ');
        handles.panel_topo_dim_bg=uibuttongroup(handles.panel_topo,'BorderType','none');
        handles.panel_topo_dim_2D=uicontrol(handles.panel_topo_dim_bg,...
            'Style','radiobutton','String','2D');
        handles.panel_topo_dim_3D=uicontrol(handles.panel_topo_dim_bg,...
            'Style','radiobutton','String','3D');
        
        handles.panel_topo_headrad_txt=uicontrol(handles.panel_topo,'style','text','String','head radius:');
        handles.panel_topo_headrad_edt=uicontrol(handles.panel_topo,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_topo_shrink_txt=uicontrol(handles.panel_topo,'style','text','String','shrink:');
        handles.panel_topo_shrink_edt=uicontrol(handles.panel_topo,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_topo_clim_chk=uicontrol(handles.panel_topo,...
            'style','checkbox','String','range: ');
        handles.panel_topo_clim1_edt=uicontrol(handles.panel_topo,...
            'style','edit','String','0','backgroundcolor',[1,1,1]);
        handles.panel_topo_clim2_edt=uicontrol(handles.panel_topo,...
            'style','edit','String','1','backgroundcolor',[1,1,1]);
        handles.panel_topo_clim1_txt=uicontrol(handles.panel_topo,...
            'style','text','String','from:');
        handles.panel_topo_clim2_txt=uicontrol(handles.panel_topo,...
            'style','text','String','to:');
        
        handles.panel_topo_view_txt=uicontrol(handles.panel_topo,...
            'style','text','String','view:');
        handles.panel_topo_view_pop=uicontrol(handles.panel_topo,'style','popupmenu','backgroundcolor',[1,1,1],'String',...
            {'custom','front','back','left','right','frontright','backright','frontleft','backleft','top'});
        handles.panel_topo_view_az_txt=uicontrol(handles.panel_topo,...
            'style','text','String','azimuth:');
        handles.panel_topo_view_az_edt=uicontrol(handles.panel_topo,...
            'style','edit','String','0','backgroundcolor',[1,1,1]);
        handles.panel_topo_view_el_txt=uicontrol(handles.panel_topo,...
            'style','text','String','vertical elevation:');
        handles.panel_topo_view_el_edt=uicontrol(handles.panel_topo,...
            'style','edit','String','0','backgroundcolor',[1,1,1]);
        
        handles.panel_topo_surface_chk=uicontrol(handles.panel_topo,'style','checkbox','String','surface');
        handles.panel_topo_contour_chk=uicontrol(handles.panel_topo,'style','checkbox','String','contour');
        handles.panel_topo_contour_color_btn=uicontrol(handles.panel_topo,...
            'style','pushbutton','String','color','FontWeight','bold');
        c=get(handles.panel_topo_contour_color_btn,'fontsize');
        set(handles.panel_topo_contour_color_btn,'fontsize',c+2);
        
        handles.panel_topo_elec_txt=uicontrol(handles.panel_topo,'style','text','String','Electrodes:');
        handles.panel_topo_elec_chk=uicontrol(handles.panel_topo,'style','checkbox','String','display');
        handles.panel_topo_elec_label_chk=uicontrol(handles.panel_topo,'style','checkbox','String','label');
        handles.panel_topo_elec_exclude_txt=uicontrol(handles.panel_topo,'style','text','String','exclude:');
        handles.panel_topo_elec_exclude_listbox=uicontrol(handles.panel_topo,'style','listbox','Min',1,'Max',10,'backgroundcolor',[1,1,1]);
        handles.panel_topo_elec_marker_txt=uicontrol(handles.panel_topo,'style','text','String','marker:');
        handles.panel_topo_elec_marker_listbox=uicontrol(handles.panel_topo,'style','listbox','Min',0,'Max',10,'backgroundcolor',[1,1,1]);
        handles.panel_topo_elec_markersize_txt=uicontrol(handles.panel_topo,'style','text','String','size:');
        handles.panel_topo_elec_markersize_edt=uicontrol(handles.panel_topo,'style','edit','backgroundcolor',[1,1,1]);
        
        handles.panel_topo_colorbar_chk=uicontrol(handles.panel_topo,...
            'style','checkbox','String','colorbar');
        handles.panel_topo_colormap_txt=uicontrol(handles.panel_topo,...
            'style','text','String','colormap: ');
        if verLessThan('matlab','8.4')
            handles.panel_topo_colormap_pop=uicontrol(handles.panel_topo,...
                'style','popupmenu','String',{'jet','hsv','hot','cool',...
                'spring','summer','autumn','winter','gray','bone','copper',...
                'pink'},'value',1,'backgroundcolor',[1,1,1]);
        else
            handles.panel_topo_colormap_pop=uicontrol(handles.panel_topo,...
                'style','popupmenu','String',{'parula','jet','hsv','hot','cool',...
                'spring','summer','autumn','winter','gray','bone','copper',...
                'pink'},'Value',1,'backgroundcolor',[1,1,1]);
        end
        
        set(handles.panel_topo_source_pop,'String',{'1','2','3'});
        set(handles.panel_topo_source_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.panel_topo_source_epoch_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_source_index_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_source_x_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_source_y_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_source_z_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_property_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.panel_topo_shrink_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_headrad_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_elec_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.panel_topo_elec_exclude_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_elec_marker_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_elec_markersize_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_colormap_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_view_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_view_az_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_view_el_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_clim1_txt,'HorizontalAlignment','left');
        set(handles.panel_topo_clim2_txt,'HorizontalAlignment','left');
        
        Set_position(handles.panel_topo,[0,0,224,520]);
        Set_position(handles.panel_topo_source_txt,[5,495,150,20]);
        Set_position(handles.panel_topo_source_pop,[5,475,220,20]);
        Set_position(handles.panel_topo_source_epoch_txt,[5,444,30,20]);
        Set_position(handles.panel_topo_source_epoch_pop,[35,444,70,20]);
        Set_position(handles.panel_topo_source_index_txt,[5,419,30,20]);
        Set_position(handles.panel_topo_source_index_pop,[35,419,70,20]);
        if ispc
            Set_position(handles.panel_topo_source_x_txt,[108,444,10,20]);
            Set_position(handles.panel_topo_source_x1_edt,[123,444,45,20]);
            Set_position(handles.panel_topo_source_x2_edt,[175,444,45,20]);
            Set_position(handles.panel_topo_source_y_txt,[108,419,10,20]);
            Set_position(handles.panel_topo_source_y1_edt,[123,419,45,20]);
            Set_position(handles.panel_topo_source_y2_edt,[175,419,45,20]);
        else
            Set_position(handles.panel_topo_source_x_txt,[108,448,10,20]);
            Set_position(handles.panel_topo_source_x1_edt,[123,448,45,20]);
            Set_position(handles.panel_topo_source_x2_edt,[175,448,45,20]);
            Set_position(handles.panel_topo_source_y_txt,[108,421,10,20]);
            Set_position(handles.panel_topo_source_y1_edt,[123,421,45,20]);
            Set_position(handles.panel_topo_source_y2_edt,[175,421,45,20]);
        end
        Set_position(handles.panel_topo_source_z_txt,[108,395,10,20]);
        Set_position(handles.panel_topo_source_z1_edt,[123,395,45,20]);
        Set_position(handles.panel_topo_source_z2_edt,[175,395,45,20]);
        
        Set_position(handles.panel_topo_elec_txt,[90,375,100,20]);
        Set_position(handles.panel_topo_elec_chk,[90,360,75,20]);
        Set_position(handles.panel_topo_elec_label_chk,[165,360,75,20]);
        Set_position(handles.panel_topo_elec_markersize_txt,[90,340,40,20]);
        Set_position(handles.panel_topo_elec_markersize_edt,[130,340,90,20]);
        Set_position(handles.panel_topo_elec_exclude_txt,[90,320,62,20]);
        Set_position(handles.panel_topo_elec_marker_txt,[158,320,62,20]);
        Set_position(handles.panel_topo_elec_exclude_listbox,[90,2,62,320]);
        Set_position(handles.panel_topo_elec_marker_listbox,[158,2,62,320]);
        
        Set_position(handles.panel_topo_property_txt,[5,375,80,20]);
        Set_position(handles.panel_topo_dim_bg,[2,357,80,20]);
        Set_position(handles.panel_topo_dim_2D,[0,0,40,20]);
        Set_position(handles.panel_topo_dim_3D,[40,0,40,20]);
        
        Set_position(handles.panel_topo_view_txt,[5,330,80,20]);
        Set_position(handles.panel_topo_view_pop,[5,313,75,20]);
        Set_position(handles.panel_topo_view_az_txt,[5,290,80,20]);
        Set_position(handles.panel_topo_view_az_edt,[5,273,75,20]);
        Set_position(handles.panel_topo_view_el_txt,[5,250,80,20]);
        Set_position(handles.panel_topo_view_el_edt,[5,233,80,20]);
        
        Set_position(handles.panel_topo_headrad_txt,[5,330,75,20]);
        Set_position(handles.panel_topo_headrad_edt,[5,313,75,20]);
        Set_position(handles.panel_topo_shrink_txt,[5,290,75,20]);
        Set_position(handles.panel_topo_shrink_edt,[5,273,75,20]);
        Set_position(handles.panel_topo_contour_chk,[5,250,75,20]);
        Set_position(handles.panel_topo_contour_color_btn,[5,220,80,30]);
        
        Set_position(handles.panel_topo_clim_chk,[5,195,75,20]);
        Set_position(handles.panel_topo_clim1_txt,[5,175,75,20]);
        Set_position(handles.panel_topo_clim1_edt,[5,155,75,20]);
        Set_position(handles.panel_topo_clim2_txt,[5,135,75,20]);
        Set_position(handles.panel_topo_clim2_edt,[5,115,75,20]);
        
        Set_position(handles.panel_topo_surface_chk,[5,80,80,20]);
        Set_position(handles.panel_topo_colorbar_chk,[5,60,80,20]);
        Set_position(handles.panel_topo_colormap_txt,[5,40,80,20]);
        Set_position(handles.panel_topo_colormap_pop,[5,20,80,20]);
        
    end
    function init_panel_lissajous()
        handles.panel_lissajous=uipanel(handles.fig1,'bordertype','none','visible','off');
        handles.panel_lissajous_config_txt=uicontrol(handles.panel_lissajous,'style','text','String','Config:');
        handles.panel_lissajous_color_btn=uicontrol(handles.panel_lissajous,'style','pushbutton','String','color','FontWeight','bold');
        handles.panel_lissajous_color_txt=uicontrol(handles.panel_lissajous,'style','text','String','Color: ');
        handles.panel_lissajous_width_txt=uicontrol(handles.panel_lissajous,'style','text','String','Width: ');
        handles.panel_lissajous_width_edt=uicontrol(handles.panel_lissajous,'style','edit','String','2','backgroundcolor',[1,1,1]);
        handles.panel_lissajous_style_txt=uicontrol(handles.panel_lissajous,'style','text','String','Line Style: ');
        handles.panel_lissajous_style_pop=uicontrol(handles.panel_lissajous,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'Solid','Dshed','Dotted','Dash-dotted','No Line'},'value',1);
        handles.panel_lissajous_marker_txt=uicontrol(handles.panel_lissajous,'style','text','String','Marker: ');
        handles.panel_lissajous_marker_pop=uicontrol(handles.panel_lissajous,'style','popupmenu','backgroundcolor',[1,1,1],...
            'String',{'No Marker','Circle','Plus sign','Asterisk','Point','Cross','Square','Cross','Diamond',...
            'Upward-pointing triangle','Downward-pointing triangle','Right-pointing triangle','Right-pointing triangle',...
            'Pentagram','Hexagram'},'value',1);
        
        handles.panel_lissajous_source1_txt=uicontrol(handles.panel_lissajous,'style','text','String','X Axis Data Source:');
        handles.panel_lissajous_source1_pop=uicontrol(handles.panel_lissajous,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_lissajous_source1_epoch_pop=uicontrol(handles.panel_lissajous,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_lissajous_source1_channel_pop=uicontrol(handles.panel_lissajous,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_lissajous_source1_index_pop=uicontrol(handles.panel_lissajous,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_lissajous_source1_y_edt=uicontrol(handles.panel_lissajous,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_lissajous_source1_z_edt=uicontrol(handles.panel_lissajous,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_lissajous_source1_epoch_txt=uicontrol(handles.panel_lissajous,'style','text','String','epoch: ');
        handles.panel_lissajous_source1_channel_txt=uicontrol(handles.panel_lissajous,'style','text','String','channel: ');
        handles.panel_lissajous_source1_index_txt=uicontrol(handles.panel_lissajous,'style','text','String','index: ');
        handles.panel_lissajous_source1_y_txt=uicontrol(handles.panel_lissajous,'style','text','String','y: ');
        handles.panel_lissajous_source1_z_txt=uicontrol(handles.panel_lissajous,'style','text','String','z: ');
        
        
        handles.panel_lissajous_source2_txt=uicontrol(handles.panel_lissajous,'style','text','String','Y Axis Data Source:');
        handles.panel_lissajous_source2_pop=uicontrol(handles.panel_lissajous,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_lissajous_source2_epoch_pop=uicontrol(handles.panel_lissajous,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_lissajous_source2_channel_pop=uicontrol(handles.panel_lissajous,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_lissajous_source2_index_pop=uicontrol(handles.panel_lissajous,'style','popupmenu','backgroundcolor',[1,1,1],'String',{'1','2','3'});
        handles.panel_lissajous_source2_y_edt=uicontrol(handles.panel_lissajous,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_lissajous_source2_z_edt=uicontrol(handles.panel_lissajous,'style','edit','backgroundcolor',[1,1,1]);
        handles.panel_lissajous_source2_epoch_txt=uicontrol(handles.panel_lissajous,'style','text','String','epoch: ');
        handles.panel_lissajous_source2_channel_txt=uicontrol(handles.panel_lissajous,'style','text','String','channel: ');
        handles.panel_lissajous_source2_index_txt=uicontrol(handles.panel_lissajous,'style','text','String','index: ');
        handles.panel_lissajous_source2_y_txt=uicontrol(handles.panel_lissajous,'style','text','String','y: ');
        handles.panel_lissajous_source2_z_txt=uicontrol(handles.panel_lissajous,'style','text','String','z: ');
        
        set(handles.panel_lissajous_config_txt,'HorizontalAlignment','left','fontweight','bold');
        c=get(handles.panel_lissajous_color_btn,'fontsize');
        set(handles.panel_lissajous_color_btn,'fontsize',c+2);
        set(handles.panel_lissajous_color_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_width_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_style_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_marker_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_source1_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.panel_lissajous_source1_epoch_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_source1_channel_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_source1_index_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_source1_y_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_source1_z_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_source2_txt,'HorizontalAlignment','left','fontweight','bold');
        set(handles.panel_lissajous_source2_epoch_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_source2_channel_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_source2_index_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_source2_y_txt,'HorizontalAlignment','left');
        set(handles.panel_lissajous_source2_z_txt,'HorizontalAlignment','left');
        
        if ispc
            Set_position(handles.panel_lissajous,[0,0,224,440]);
            Set_position(handles.panel_lissajous_config_txt,[5,420,65,20]);
            Set_position(handles.panel_lissajous_color_txt,[5,390,65,20]);
            Set_position(handles.panel_lissajous_color_btn,[70,390,145,30]);
            Set_position(handles.panel_lissajous_width_txt,[5,360,65,20]);
            Set_position(handles.panel_lissajous_width_edt,[70,360,145,23]);
            Set_position(handles.panel_lissajous_style_txt,[5,327,65,20]);
            Set_position(handles.panel_lissajous_style_pop,[70,330,145,20]);
            Set_position(handles.panel_lissajous_marker_txt,[5,297,65,20]);
            Set_position(handles.panel_lissajous_marker_pop,[70,300,145,20]);
            
            Set_position(handles.panel_lissajous_source1_txt,[5,257,150,20]);
            Set_position(handles.panel_lissajous_source1_pop,[5,240,220,20]);
            Set_position(handles.panel_lissajous_source1_epoch_txt,[5,207,54,20]);
            Set_position(handles.panel_lissajous_source1_epoch_pop,[60,210,75,20]);
            Set_position(handles.panel_lissajous_source1_channel_txt,[5,177,54,20]);
            Set_position(handles.panel_lissajous_source1_channel_pop,[60,180,75,20]);
            Set_position(handles.panel_lissajous_source1_index_txt,[5,147,54,20]);
            Set_position(handles.panel_lissajous_source1_index_pop,[60,150,75,20]);
            Set_position(handles.panel_lissajous_source1_y_txt,[150,205,20,20]);
            Set_position(handles.panel_lissajous_source1_y_edt,[170,205,55,23]);
            Set_position(handles.panel_lissajous_source1_z_txt,[150,175,20,20]);
            Set_position(handles.panel_lissajous_source1_z_edt,[170,175,55,23]);
            
            Set_position(handles.panel_lissajous_source2_txt,[5,120,150,20]);
            Set_position(handles.panel_lissajous_source2_pop,[5,100,220,20]);
            Set_position(handles.panel_lissajous_source2_epoch_txt,[5,67,54,20]);
            Set_position(handles.panel_lissajous_source2_epoch_pop,[60,70,75,20]);
            Set_position(handles.panel_lissajous_source2_channel_txt,[5,37,54,20]);
            Set_position(handles.panel_lissajous_source2_channel_pop,[60,40,75,20]);
            Set_position(handles.panel_lissajous_source2_index_txt,[5,7,54,20]);
            Set_position(handles.panel_lissajous_source2_index_pop,[60,10,75,20]);
            Set_position(handles.panel_lissajous_source2_y_txt,[150,65,20,20]);
            Set_position(handles.panel_lissajous_source2_y_edt,[170,65,55,23]);
            Set_position(handles.panel_lissajous_source2_z_txt,[150,35,20,20]);
            Set_position(handles.panel_lissajous_source2_z_edt,[170,35,55,23]);
        else
            Set_position(handles.panel_lissajous,[0,0,224,450]);
            Set_position(handles.panel_lissajous_config_txt,[5,420,55,20]);
            Set_position(handles.panel_lissajous_color_txt,[5,390,55,20]);
            Set_position(handles.panel_lissajous_color_btn,[83,390,136,30]);
            Set_position(handles.panel_lissajous_width_txt,[5,360,55,20]);
            Set_position(handles.panel_lissajous_width_edt,[85,360,130,20]);
            Set_position(handles.panel_lissajous_style_txt,[5,330,80,20]);
            Set_position(handles.panel_lissajous_style_pop,[81,330,141,20]);
            Set_position(handles.panel_lissajous_marker_txt,[5,300,80,20]);
            Set_position(handles.panel_lissajous_marker_pop,[81,300,141,20]);
            
            Set_position(handles.panel_lissajous_source1_txt,[5,260,150,20]);
            Set_position(handles.panel_lissajous_source1_pop,[5,240,220,20]);
            Set_position(handles.panel_lissajous_source1_epoch_txt,[5,210,40,20]);
            Set_position(handles.panel_lissajous_source1_epoch_pop,[50,210,85,20]);
            Set_position(handles.panel_lissajous_source1_channel_txt,[5,180,40,20]);
            Set_position(handles.panel_lissajous_source1_channel_pop,[50,180,85,20]);
            Set_position(handles.panel_lissajous_source1_index_txt,[5,150,40,20]);
            Set_position(handles.panel_lissajous_source1_index_pop,[50,150,85,20]);
            Set_position(handles.panel_lissajous_source1_y_txt,[150,210,10,20]);
            Set_position(handles.panel_lissajous_source1_y_edt,[165,210,55,20]);
            Set_position(handles.panel_lissajous_source1_z_txt,[150,180,10,20]);
            Set_position(handles.panel_lissajous_source1_z_edt,[165,180,55,20]);
            
            Set_position(handles.panel_lissajous_source2_txt,[5,120,150,20]);
            Set_position(handles.panel_lissajous_source2_pop,[5,100,220,20]);
            Set_position(handles.panel_lissajous_source2_epoch_txt,[5,70,40,20]);
            Set_position(handles.panel_lissajous_source2_epoch_pop,[50,70,85,20]);
            Set_position(handles.panel_lissajous_source2_channel_txt,[5,40,40,20]);
            Set_position(handles.panel_lissajous_source2_channel_pop,[50,40,85,20]);
            Set_position(handles.panel_lissajous_source2_index_txt,[5,10,40,20]);
            Set_position(handles.panel_lissajous_source2_index_pop,[50,10,85,20]);
            Set_position(handles.panel_lissajous_source2_y_txt,[150,70,10,20]);
            Set_position(handles.panel_lissajous_source2_y_edt,[165,70,55,20]);
            Set_position(handles.panel_lissajous_source2_z_txt,[150,40,10,20]);
            Set_position(handles.panel_lissajous_source2_z_edt,[165,40,55,20]);
        end
    end
    function init_data()
        name=cell(length(option.inputfiles),1);
        for k=1:length(option.inputfiles)
            [~,name{k},~] = fileparts(option.inputfiles{k});
            [datasets_header(k).header, datasets_data(k).data]=CLW_load(option.inputfiles{k});
            if ~isreal(datasets_data(k).data)
                datasets_data(k).data=abs(datasets_data(k).data);
            end
            chan_used=find([datasets_header(k).header.chanlocs.topo_enabled]==1, 1);
            if isempty(chan_used)
                datasets_header(k).header=CLW_elec_autoload(datasets_header(k).header);
            end
            datasets_header(k).header=CLW_make_spl(datasets_header(k).header);
        end
        set(handles.panel_curve_source_pop,'string',name);
        set(handles.panel_image_source_pop,'string',name);
        set(handles.panel_topo_source_pop,'string',name);
        set(handles.panel_lissajous_source1_pop,'string',name);
        set(handles.panel_lissajous_source2_pop,'string',name);
    end
    function init_function()
        set(handles.fig1,'CloseRequestFcn',@fig1_closeReq_callback);
        set(handles.fig2,'CloseRequestFcn',@fig2_closeReq_callback);
        set(handles.fig2,'WindowButtonMotionFcn',@get_fig_pos);
        try
            set(handles.fig2,'SizeChangedFcn',@get_fig_pos);
        catch
            set(handles.fig2,'resizefcn',@get_fig_pos);
        end
        
        set(handles.open_btn,'ClickedCallback',{@open_btn_callback});
        set(handles.save_btn,'ClickedCallback',{@save_btn_callback});
        set(handles.data_btn,'ClickedCallback',{@data_btn_callback});
        set(handles.export_btn,'ClickedCallback',{@export_btn_callback});
        set(handles.script_btn,'ClickedCallback',{@script_btn_callback});
        set(handles.fig_btn,'ClickedCallback',{@fig1_callback,1});
        set(handles.axis_btn,'ClickedCallback',{@fig1_callback,2});
        set(handles.content_btn,'ClickedCallback',{@fig1_callback,3});
        
        set(handles.fig_pos_refresh_btn,'callback',@get_fig_pos);
        set(handles.subfig_listbox,'callback',@subfig_listbox_callback);
        set(handles.content_listbox,'callback',@content_listbox_callback);
        
        %panel_fig
        set(handles.fig_x_edt,'callback',@set_fig_pos);
        set(handles.fig_y_edt,'callback',@set_fig_pos);
        set(handles.fig_w_edt,'callback',@set_fig_pos);
        set(handles.fig_h_edt,'callback',@set_fig_pos);
        
        set(handles.sub_add,'callback',@sub_add_callback);
        set(handles.sub_del,'callback',@sub_del_callback);
        set(handles.sub_up,'callback',@sub_up_callback);
        set(handles.sub_down,'callback',@sub_down_callback);
        
        set(handles.sub_x_edt,'callback',@set_sub_pos);
        set(handles.sub_y_edt,'callback',@set_sub_pos);
        set(handles.sub_w_edt,'callback',@set_sub_pos);
        set(handles.sub_h_edt,'callback',@set_sub_pos);
        set(handles.sub_title_chx,'callback',@sub_title_chx_callback);
        set(handles.sub_title_edt,'callback',@sub_title_edt_callback);
        set(handles.sub_font_pop,'callback',@sub_font_pop_callback);
        set(handles.sub_size_edt,'callback',@sub_size_edt_callback);
        set(handles.sub_position_chk,'callback',@sub_position_chk_callback);
        set(handles.sub_col_edt,'callback',@sub_col_edt_callback);
        set(handles.sub_row_edt,'callback',@sub_row_edt_callback);
        set(handles.sub_update_btn,'callback',@sub_update_btn_callback);
        
        %panel_axis
        set(handles.axis_reverse_chk,'callback',@axis_reverse_chk_callback);
        set(handles.axis_box_chk,'callback',@axis_box_chk_callback);
        set(handles.axis_visible_chk,'callback',@axis_visible_chk_callback);
        set(handles.axis_legend_chk,'callback',@axis_legend_chk_callback);
        set(handles.axis_legend_edt,'callback',@axis_legend_edt_callback);
        
        set(handles.xaxis_limit_chk,'callback',@xaxis_limit_chk_callback);
        set(handles.xaxis_limit1_edt,'callback',@xaxis_limit_edt_callback);
        set(handles.xaxis_limit2_edt,'callback',@xaxis_limit_edt_callback);
        set(handles.xaxis_hide_chx,'callback',@xaxis_hide_chx_callback);
        set(handles.xaxis_location_pop,'callback',@xaxis_location_pop_callback);
        set(handles.xaxis_tick_chk,'callback',@xaxis_tick_chk_callback);
        set(handles.xaxis_tick_interval_edt,'callback',@xaxis_tick_chk_callback);
        set(handles.xaxis_tick_anchor_edt,'callback',@xaxis_tick_chk_callback);
        set(handles.xaxis_minor_tick_chk,'callback',@xaxis_minor_tick_chk_callback);
        set(handles.xaxis_grid_chk,'callback',@xaxis_grid_chk_callback);
        set(handles.xaxis_minor_grid_chk,'callback',@xaxis_minor_grid_chk_callback);
        set(handles.xaxis_label_chk,'callback',@xaxis_label_chk_callback);
        set(handles.xaxis_label_edt,'callback',@xaxis_label_edt_callback);
        set(handles.yaxis_limit_chk,'callback',@yaxis_limit_chk_callback);
        set(handles.yaxis_limit1_edt,'callback',@yaxis_limit_edt_callback);
        set(handles.yaxis_limit2_edt,'callback',@yaxis_limit_edt_callback);
        set(handles.yaxis_hide_chx,'callback',@yaxis_hide_chx_callback);
        set(handles.yaxis_location_pop,'callback',@yaxis_location_pop_callback);
        set(handles.yaxis_tick_chk,'callback',@yaxis_tick_chk_callback);
        set(handles.yaxis_tick_interval_edt,'callback',@yaxis_tick_chk_callback);
        set(handles.yaxis_tick_anchor_edt,'callback',@yaxis_tick_chk_callback);
        set(handles.yaxis_minor_tick_chk,'callback',@yaxis_minor_tick_chk_callback);
        set(handles.yaxis_grid_chk,'callback',@yaxis_grid_chk_callback);
        set(handles.yaxis_minor_grid_chk,'callback',@yaxis_minor_grid_chk_callback);
        set(handles.yaxis_label_chk,'callback',@yaxis_label_chk_callback);
        set(handles.yaxis_label_edt,'callback',@yaxis_label_edt_callback);
        set(handles.yaxis_reverse_chk,'callback',@yaxis_reverse_chk_callback);
        
        %panel_content
        set(handles.content_add, 'callback',@content_add_callback);
        set(handles.content_del, 'callback',@content_del_callback);
        set(handles.content_up,  'callback',@content_up_callback);
        set(handles.content_down,'callback',@content_down_callback);
        
        %panel_curve
        set(handles.panel_curve_source_pop,'callback',@curve_source_pop_callback);
        set(handles.panel_curve_source_epoch_pop,'callback',@curve_source_epoch_pop_callback);
        set(handles.panel_curve_source_channel_pop,'callback',@curve_source_channel_pop_callback);
        set(handles.panel_curve_source_index_pop,'callback',@curve_source_index_pop_callback);
        set(handles.panel_curve_source_z_edt,'callback',@curve_source_z_edt_callback);
        set(handles.panel_curve_source_y_edt,'callback',@curve_source_y_edt_callback);
        set(handles.panel_curve_color_btn,'callback',@curve_color_btn_callback);
        set(handles.panel_curve_width_edt,'callback',@curve_width_edt_callback);
        set(handles.panel_curve_style_pop,'callback',@curve_style_pop_callback);
        set(handles.panel_curve_marker_pop,'callback',@curve_marker_pop_callback);
        
        %panel_line
        set(handles.panel_line_color_btn,'callback',@line_color_btn_callback);
        set(handles.panel_line_width_edt,'callback',@line_width_edt_callback);
        set(handles.panel_line_style_pop,'callback',@line_style_pop_callback);
        set(handles.panel_line_marker_pop,'callback',@line_marker_pop_callback);
        set(handles.panel_line_x1_edt,'callback',@line_xy_edt_callback);
        set(handles.panel_line_x2_edt,'callback',@line_xy_edt_callback);
        set(handles.panel_line_y1_edt,'callback',@line_xy_edt_callback);
        set(handles.panel_line_y2_edt,'callback',@line_xy_edt_callback);
        
        %panel_rect
        set(handles.panel_rect_facecolor_btn,'callback',@rect_facecolor_btn_callback);
        set(handles.panel_rect_edgecolor_btn,'callback',@rect_edgecolor_btn_callback);
        set(handles.panel_rect_width_edt,'callback',@rect_width_edt_callback);
        set(handles.panel_rect_facealpha_edt,'callback',@rect_feacalpha_edt_callback);
        set(handles.panel_rect_edgealpha_edt,'callback',@rect_edgealpha_edt_callback);
        set(handles.panel_rect_x_edt,'callback',@rect_xy_edt_callback);
        set(handles.panel_rect_y_edt,'callback',@rect_xy_edt_callback);
        set(handles.panel_rect_w_edt,'callback',@rect_xy_edt_callback);
        set(handles.panel_rect_h_edt,'callback',@rect_xy_edt_callback);
        
        %panel_text
        set(handles.panel_text_color_btn,'callback',@text_color_btn_callback);
        set(handles.panel_text_text_edt,'callback',@text_text_edt_callback);
        set(handles.panel_text_bold_chk,'callback',@text_bold_chk_callback);
        set(handles.panel_text_italic_chk,'callback',@text_italic_chk_callback);
        set(handles.panel_text_font_pop,'callback',@text_font_pop_callback);
        set(handles.panel_text_size_edt,'callback',@text_size_edt_callback);
        set(handles.panel_text_x_edt,'callback',@text_xy_edt_callback);
        set(handles.panel_text_y_edt,'callback',@text_xy_edt_callback);
        
        %panel_image
        set(handles.panel_image_source_pop,'callback',@image_source_pop_callback);
        set(handles.panel_image_source_epoch_pop,'callback',@image_source_epoch_pop_callback);
        set(handles.panel_image_source_channel_pop,'callback',@image_source_channel_pop_callback);
        set(handles.panel_image_source_index_pop,'callback',@image_source_index_pop_callback);
        set(handles.panel_image_source_z_edt,'callback',@image_source_z_edt_callback);
        
        set(handles.panel_image_colorbar_chk,'callback',@image_colorbar_chk_callback);
        set(handles.panel_image_colormap_pop,'callback',@image_colormap_pop_callback);
        set(handles.panel_image_clim_chk,'callback',@image_clim_chk_callback);
        set(handles.panel_image_clim1_edt,'callback',@image_clim_edt_callback);
        set(handles.panel_image_clim2_edt,'callback',@image_clim_edt_callback);
        
        set(handles.panel_image_contour_chk,'callback',@image_contour_chk_callback);
        set(handles.panel_image_contour_color_btn,'callback',@image_contour_color_btn_callback);
        set(handles.panel_image_contour_width_edt,'callback',@image_contour_width_edt_callback);
        set(handles.panel_image_contour_style_pop,'callback',@image_contour_style_pop_callback);
        set(handles.panel_image_contour_level_chk,'callback',@image_contour_level_chk_callback);
        set(handles.panel_image_contour_start_edt,'callback',@image_contour_start_edt_callback);
        set(handles.panel_image_contour_end_edt,'callback',@image_contour_end_edt_callback);
        set(handles.panel_image_contour_step_edt,'callback',@image_contour_step_edt_callback);
        
        %panel_topo
        set(handles.panel_topo_source_pop,'callback',@topo_source_pop_callback);
        set(handles.panel_topo_source_epoch_pop,'callback',@topo_source_epoch_pop_callback);
        set(handles.panel_topo_source_index_pop,'callback',@topo_source_index_pop_callback);
        set(handles.panel_topo_source_z1_edt,'callback',@topo_source_z_edt_callback);
        set(handles.panel_topo_source_y1_edt,'callback',@topo_source_y_edt_callback);
        set(handles.panel_topo_source_x1_edt,'callback',@topo_source_x_edt_callback);
        set(handles.panel_topo_source_z2_edt,'callback',@topo_source_z_edt_callback);
        set(handles.panel_topo_source_y2_edt,'callback',@topo_source_y_edt_callback);
        set(handles.panel_topo_source_x2_edt,'callback',@topo_source_x_edt_callback);
        set(handles.panel_topo_elec_chk,'callback',@topo_elec_chk_callback);
        set(handles.panel_topo_elec_label_chk,'callback',@topo_elec_label_chk_callback);
        set(handles.panel_topo_elec_markersize_edt,'callback',@topo_elec_markersize_edt_callback);
        set(handles.panel_topo_elec_exclude_listbox,'callback',@topo_elec_exclude_listbox_callback);
        set(handles.panel_topo_elec_marker_listbox,'callback',@topo_elec_marker_listbox_callback);
        if verLessThan('matlab','8.4')
            set(handles.panel_topo_dim_bg,'SelectionChangeFcn',@topo_dim_bg_callback);
        else
            set(handles.panel_topo_dim_bg,'SelectionChangedFcn',@topo_dim_bg_callback);
        end
        set(handles.panel_topo_view_pop,'callback',@topo_view_pop_callback);
        set(handles.panel_topo_view_az_edt,'callback',@topo_view_az_edt_callback);
        set(handles.panel_topo_view_el_edt,'callback',@topo_view_el_edt_callback);
        set(handles.panel_topo_headrad_edt,'callback',@topo_headrad_edt_callback);
        set(handles.panel_topo_shrink_edt,'callback',@topo_shrink_edt_callback);
        set(handles.panel_topo_clim_chk,'callback',@topo_clim_chk_callback);
        set(handles.panel_topo_clim1_edt,'callback',@topo_clim_edt_callback);
        set(handles.panel_topo_clim2_edt,'callback',@topo_clim_edt_callback);
        set(handles.panel_topo_surface_chk,'callback',@topo_surface_chk_callback);
        set(handles.panel_topo_colorbar_chk,'callback',@topo_colorbar_chk_callback);
        set(handles.panel_topo_colormap_pop,'callback',@topo_colormap_pop_callback);
        set(handles.panel_topo_contour_chk,'callback',@topo_contour_chk_callback);
        set(handles.panel_topo_contour_color_btn,'callback',@topo_contour_color_btn_callback);
        
        %panel_lissajous
        set(handles.panel_lissajous_color_btn,'callback',@lissajous_color_btn_callback);
        set(handles.panel_lissajous_width_edt,'callback',@lissajous_width_edt_callback);
        set(handles.panel_lissajous_style_pop,'callback',@lissajous_style_pop_callback);
        set(handles.panel_lissajous_marker_pop,'callback',@lissajous_marker_pop_callback);
        set(handles.panel_lissajous_source1_pop,'callback',@lissajous_source1_pop_callback);
        set(handles.panel_lissajous_source1_epoch_pop,'callback',@lissajous_source1_epoch_pop_callback);
        set(handles.panel_lissajous_source1_channel_pop,'callback',@lissajous_source1_channel_pop_callback);
        set(handles.panel_lissajous_source1_index_pop,'callback',@lissajous_source1_index_pop_callback);
        set(handles.panel_lissajous_source1_z_edt,'callback',@lissajous_source1_z_edt_callback);
        set(handles.panel_lissajous_source1_y_edt,'callback',@lissajous_source1_y_edt_callback);
        set(handles.panel_lissajous_source2_pop,'callback',@lissajous_source2_pop_callback);
        set(handles.panel_lissajous_source2_epoch_pop,'callback',@lissajous_source2_epoch_pop_callback);
        set(handles.panel_lissajous_source2_channel_pop,'callback',@lissajous_source2_channel_pop_callback);
        set(handles.panel_lissajous_source2_index_pop,'callback',@lissajous_source2_index_pop_callback);
        set(handles.panel_lissajous_source2_z_edt,'callback',@lissajous_source2_z_edt_callback);
        set(handles.panel_lissajous_source2_y_edt,'callback',@lissajous_source2_y_edt_callback);
    end

%% redraw function
    function fig_redraw()
        temp_cnt_subfig=option.cnt_subfig;
        temp_cnt_content=option.cnt_content;
        %delete all
        for k=1:length(handles.ax)
            delete(handles.ax(k));
        end
        handles.ax=[];
        handles.ax_child=[];
        set(handles.fig2,'name','Figure','PaperPositionMode','auto','Color',[1,1,1],...
            'numbertitle','off','MenuBar','none','DockControls','off','position',option.fig2_pos);
        for k=1:length(option.ax)
            option.cnt_subfig=k;
            axis_redraw();
            drawnow;
        end
        
        option.cnt_subfig=temp_cnt_subfig;
        option.cnt_content=temp_cnt_content;
    end
    function axis_redraw()
        get_axis_default();
        handles.ax(option.cnt_subfig)=axes('parent',handles.fig2);
        Set_position(handles.ax(option.cnt_subfig),option.ax{option.cnt_subfig}.pos);
        hold(handles.ax(option.cnt_subfig),'on');
        
        if ~strcmpi(option.ax{option.cnt_subfig}.style,'Topograph')
            set(handles.ax(option.cnt_subfig),...
                'fontname',option.ax{option.cnt_subfig}.fontname,...
                'fontsize',option.ax{option.cnt_subfig}.fontsize,...
                'box',option.ax{option.cnt_subfig}.box,...
                'visible',option.ax{option.cnt_subfig}.visible,...
                'XAxisLocation',option.ax{option.cnt_subfig}.XAxisLocation,...
                'XMinorTick',option.ax{option.cnt_subfig}.XMinorTick,...
                'XGrid',option.ax{option.cnt_subfig}.XGrid,...
                'XMinorGrid',option.ax{option.cnt_subfig}.XMinorGrid,...
                'YAxisLocation',option.ax{option.cnt_subfig}.YAxisLocation,...
                'YMinorTick',option.ax{option.cnt_subfig}.YMinorTick,...
                'YGrid',option.ax{option.cnt_subfig}.YGrid,...
                'YMinorGrid',option.ax{option.cnt_subfig}.YMinorGrid);            
            if verLessThan('matlab','8.4')
            else
                l=get(handles.ax(option.cnt_subfig),'xaxis');
                set(l,'visible',option.ax{option.cnt_subfig}.xaxis_visible);
                l=get(handles.ax(option.cnt_subfig),'yaxis');
                set(l,'visible',option.ax{option.cnt_subfig}.yaxis_visible);
            end
            l=get(handles.ax(option.cnt_subfig),'xlabel');
            set(l,'visible',option.ax{option.cnt_subfig}.xlabel_visible);
            set(l,'string',option.ax{option.cnt_subfig}.xlabel);
            l=get(handles.ax(option.cnt_subfig),'ylabel');
            set(l,'visible',option.ax{option.cnt_subfig}.ylabel_visible);
            set(l,'string',option.ax{option.cnt_subfig}.ylabel);
            set(handles.ax(option.cnt_subfig),'YDir',option.ax{option.cnt_subfig}.YDir);
        else
            set(handles.ax(option.cnt_subfig),...
                'fontname',option.ax{option.cnt_subfig}.fontname,...
                'fontsize',option.ax{option.cnt_subfig}.fontsize);  
        end
        
        
        handles.ax_child{option.cnt_subfig}=[];
        handles.ax_child{option.cnt_subfig}.handle=cell(0,1);
        for k=1:length(option.ax{option.cnt_subfig}.content)
            option.cnt_content=k;
            content_redraw();
        end
        
        t=get(handles.ax(option.cnt_subfig),'title');
        set(t,'string',option.ax{option.cnt_subfig}.name,'visible',option.ax{option.cnt_subfig}.title_visible);
        if ~strcmpi(option.ax{option.cnt_subfig}.style,'Topograph')
            if strcmpi(option.ax{option.cnt_subfig}.XlimMode,'manual')
                set(handles.ax(option.cnt_subfig),'Xlim',option.ax{option.cnt_subfig}.Xlim);
            end
            if strcmpi(option.ax{option.cnt_subfig}.XTickMode,'manual')
                value1=option.ax{option.cnt_subfig}.xaxis_tick_interval;
                value2=option.ax{option.cnt_subfig}.xaxis_tick_anchor;
                option.ax{option.cnt_subfig}.Xlim=get(handles.ax(option.cnt_subfig),'Xlim');
                idx=ceil((option.ax{option.cnt_subfig}.Xlim(1)-value2)/value1)*value1+value2:value1:option.ax{option.cnt_subfig}.Xlim(2);
                set(handles.ax(option.cnt_subfig),'XTick',idx);
            end
            if strcmpi(option.ax{option.cnt_subfig}.YlimMode,'manual')
                set(handles.ax(option.cnt_subfig),'Ylim',option.ax{option.cnt_subfig}.Ylim);
            end
            if strcmpi(option.ax{option.cnt_subfig}.YTickMode,'manual')
                value1=option.ax{option.cnt_subfig}.yaxis_tick_interval;
                value2=option.ax{option.cnt_subfig}.yaxis_tick_anchor;
                option.ax{option.cnt_subfig}.Ylim=get(handles.ax(option.cnt_subfig),'Ylim');
                idx=ceil((option.ax{option.cnt_subfig}.Ylim(1)-value2)/value1)*value1+value2:value1:option.ax{option.cnt_subfig}.Ylim(2);
                set(handles.ax(option.cnt_subfig),'YTick',idx);
            end
        end
        if strcmpi(option.ax{option.cnt_subfig}.style,'Curve') ...
                && strcmpi(option.ax{option.cnt_subfig}.legend,'on')
            idx=[];
            name={};
            for k=1:length(option.ax{option.cnt_subfig}.content)
                if strcmpi(option.ax{option.cnt_subfig}.content{k}.type,'curve')...
                        ||strcmpi(option.ax{option.cnt_subfig}.content{k}.type,'lissajous')
                    idx=[idx,k];
                    name=[name,option.ax{option.cnt_subfig}.content{k}.name];
                end
            end
            if isempty(idx)
                legend(handles.ax(option.cnt_subfig),'off');
            else
                legend([handles.ax_child{option.cnt_subfig}.handle(idx).line],name);
            end
        end
    end
    function content_redraw()
        switch option.ax{option.cnt_subfig}.content{option.cnt_content}.type
            case 'curve'
                content_curve_redraw();
            case 'lissajous'
                content_lissajous_redraw();
            case 'line'
                content_line_redraw();
            case 'rect'
                content_rect_redraw();
            case 'text'
                content_text_redraw();
            case 'image'
                content_image_redraw();
            case 'topo'
                content_topo_redraw();
        end
    end
    function content_curve_redraw()
        get_content_curve_default();
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line=...
            line('Parent',handles.ax(option.cnt_subfig));
        curve_update();
    end
    function content_lissajous_redraw()
        get_content_lissajous_default();
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line=...
            line('Parent',handles.ax(option.cnt_subfig));
        lissajous_update();
    end
    function content_line_redraw()
        get_content_line_default();
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line=...
            line('Parent',handles.ax(option.cnt_subfig));
        line_update();
    end
    function content_rect_redraw()
        get_content_rect_default();
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).rect=...
            fill([0,0],[1,1],[1,1,1],'Parent',handles.ax(option.cnt_subfig));
        rect_update();
    end
    function content_text_redraw()
        get_content_text_default();
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text=text('parent',handles.ax(option.cnt_subfig));
        text_update();
    end
    function content_image_redraw()
        get_content_image_default();
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).img=...
            imagesc('Parent',handles.ax(option.cnt_subfig));
        [~,handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour]=...
            contour(handles.ax(option.cnt_subfig),randn(2,2));
        image_update();
    end
    function content_topo_redraw()
        get_content_topo_default();
        content_topo2D_redraw();
        content_topo3D_redraw();
        topo_update();
    end
    function content_topo2D_redraw()
        %2D
        radiuscircle = 0.5;
        pnts   = linspace(0,2*pi,200);
        xc     = sin(pnts)*radiuscircle;
        yc     = cos(pnts)*radiuscircle;
        base  = radiuscircle-.0046;
        basex = 0.18*radiuscircle;                   % nose width
        tip   = 1.15*radiuscircle;
        tiphw = .04*radiuscircle;                    % nose tip half width
        tipr  = .01*radiuscircle;                    % nose tip rounding
        q = .04;                                     % ear lengthening
        EarX  = [.497-.005  .510  .518  .5299 .5419  .54    .547   .532   .510   .489-.005];
        EarY  = [q+.0555 q+.0775 q+.0783 q+.0746 q+.0555 -.0055 -.0932 -.1313 -.1384 -.1199];
        top=1;
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).surf_2D=surf('Parent',handles.ax(option.cnt_subfig),'edgecolor', 'none');
        [~,handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour]=contour3(handles.ax(option.cnt_subfig),randn(2,2));
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line1=plot3(handles.ax(option.cnt_subfig),xc,yc,ones(size(xc))*top, 'k', 'linewidth', 2);
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line2=plot3(handles.ax(option.cnt_subfig),EarX,EarY,ones(size(EarX))*top,'color','k','LineWidth',2);
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line3=plot3(handles.ax(option.cnt_subfig),-EarX,EarY,ones(size(EarY))*top,'color','k','LineWidth',2);
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line4=plot3(handles.ax(option.cnt_subfig),...
            [basex;tiphw;0;-tiphw;-basex],[base;tip-tipr;tip;tip-tipr;base],...
            top*ones(size([basex;tiphw;0;-tiphw;-basex])),'color','k','LineWidth',2);
        
    end
    function content_topo3D_redraw()
        P=linspace(1,64,length(POS))';
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).surf_3D=patch('Parent',handles.ax(option.cnt_subfig),...
            'Vertices',POS,'Faces',TRI,'FaceVertexCdata',P,'FaceColor','interp','EdgeColor','none','DiffuseStrength',.6,...
            'SpecularStrength',0,'AmbientStrength',.3,'SpecularExponent',5,'vertexnormals', NORM);
        %for all
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode=plot3(handles.ax(option.cnt_subfig), 0,0,-1, 'k.', 'markersize', 0.001);
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker1=plot3(handles.ax(option.cnt_subfig), 0,0,-1, 'y.', 'markersize', 4,'visible','off');
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker2=plot3(handles.ax(option.cnt_subfig), 0,0,-1, 'r.', 'markersize', 2,'visible','off');
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text=[];
        
        view(handles.ax(option.cnt_subfig),[0 0 1]);
        axis(handles.ax(option.cnt_subfig),'off','image');
        set(handles.ax(option.cnt_subfig), 'ydir', 'normal');
    end

%% script_function
    function get_fig_default()
        option=option_setup(option,'inputfiles',[]);
        scrsz = get(0,'MonitorPositions');
        scrsz=scrsz(1,:);
        pos=[(scrsz(3)-950)/2,max((scrsz(4)-650-200)/2,100),700,650];
        %pos=[100,200,700,650];
        option=option_setup(option,'fig2_pos',pos);
        option=option_setup(option,'ax',[]);
        option=option_setup(option,'ax_auto_position',0);
        option=option_setup(option,'ax_auto_col',1);
        option=option_setup(option,'ax_auto_row',1);
        option=option_setup(option,'cnt_panel',1);
        option=option_setup(option,'cnt_subfig',0);
        option=option_setup(option,'cnt_content',0);
        option=option_setup(option,'subfig_order',1);
    end
    function get_axis_default()
        opt=option.ax{option.cnt_subfig};
        opt=option_setup(opt,'title_visible','on');
        opt=option_setup(opt,'fontname','Helvetica');
        opt=option_setup(opt,'fontsize',10);
        opt=option_setup(opt,'axis_reverse',0);
        opt=option_setup(opt,'box','off');
        opt=option_setup(opt,'visible','on');
        opt=option_setup(opt,'legend','off');
        
        opt=option_setup(opt,'XlimMode','auto');
        opt=option_setup(opt,'Xlim',[0,1]);
        opt=option_setup(opt,'XAxisLocation','bottom');
        opt=option_setup(opt,'XMinorTick','off');
        opt=option_setup(opt,'XTickMode','auto');
        opt=option_setup(opt,'xaxis_tick_anchor',[]);
        opt=option_setup(opt,'xaxis_tick_interval',[]);
        opt=option_setup(opt,'xaxis_visible','on');
        opt=option_setup(opt,'XGrid','off');
        opt=option_setup(opt,'XMinorGrid','off');
        opt=option_setup(opt,'xlabel','xlabel');
        opt=option_setup(opt,'xlabel_visible','off');
        opt=option_setup(opt,'YlimMode','auto');
        opt=option_setup(opt,'Ylim',[0,1]);
        opt=option_setup(opt,'YAxisLocation','left');
        opt=option_setup(opt,'YMinorTick','off');
        opt=option_setup(opt,'YTickMode','auto');
        opt=option_setup(opt,'yaxis_tick_anchor',[]);
        opt=option_setup(opt,'yaxis_tick_interval',[]);
        opt=option_setup(opt,'yaxis_visible','on');
        opt=option_setup(opt,'YGrid','off');
        opt=option_setup(opt,'YMinorGrid','off');
        opt=option_setup(opt,'ylabel','ylabel');
        opt=option_setup(opt,'ylabel_visible','off');
        opt=option_setup(opt,'YDir','normal');
        
        opt=option_setup(opt,'colorbar','off');
        opt=option_setup(opt,'colormap','jet');
        opt=option_setup(opt,'climMode','auto');
        opt=option_setup(opt,'clim',[0,1]);
        opt=option_setup(opt,'content',[]);
        opt=option_setup(opt,'content_order',1);
        option.ax{option.cnt_subfig}=opt;
        
        if verLessThan('matlab','8.4')
            option.ax{option.cnt_subfig}.xaxis_visible='on';
            option.ax{option.cnt_subfig}.yaxis_visible='on';
        end
    end
    function get_content_curve_default()
        c=[     0    0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840];
        opt=option.ax{option.cnt_subfig}.content{option.cnt_content};
        opt=option_setup(opt,'ep',1);
        opt=option_setup(opt,'ch',[]);
        opt=option_setup(opt,'idx',1);
        opt=option_setup(opt,'z',0);
        opt=option_setup(opt,'y',0);
        opt=option_setup(opt,'dataset',1);
        
        opt=option_setup(opt,'linewidth',2);
        opt=option_setup(opt,'style','-');
        opt=option_setup(opt,'marker','none');
        opt=option_setup(opt,'color',c(mod(option.ax{option.cnt_subfig}.content_order,7)+1,:));
        
        option.ax{option.cnt_subfig}.content{option.cnt_content}=opt;
    end
    function get_content_line_default()
        opt=option.ax{option.cnt_subfig}.content{option.cnt_content};
        opt=option_setup(opt,'x',[]);
        opt=option_setup(opt,'y',[]);
        opt=option_setup(opt,'linewidth',2);
        opt=option_setup(opt,'style','-');
        opt=option_setup(opt,'marker','none');
        opt=option_setup(opt,'color',[0,0,0]);
        option.ax{option.cnt_subfig}.content{option.cnt_content}=opt;
    end
    function get_content_rect_default()
        opt=option.ax{option.cnt_subfig}.content{option.cnt_content};
        opt=option_setup(opt,'x',[]);
        opt=option_setup(opt,'y',[]);
        opt=option_setup(opt,'w',[]);
        opt=option_setup(opt,'h',[]);
        opt=option_setup(opt,'FaceColor',[0.5,0.5,0.5]);
        opt=option_setup(opt,'EdgeColor',[0.25,0.25,0.25]);
        opt=option_setup(opt,'FaceAlpha',0.5);
        opt=option_setup(opt,'EdgeAlpha',1);
        opt=option_setup(opt,'linewidth',0.5);
        option.ax{option.cnt_subfig}.content{option.cnt_content}=opt;
    end
    function get_content_text_default()
        opt=option.ax{option.cnt_subfig}.content{option.cnt_content};
        opt=option_setup(opt,'pos',[]);
        opt=option_setup(opt,'string','text');
        opt=option_setup(opt,'Color',[0,0,0]);
        opt=option_setup(opt,'FontName','Helvetica');
        opt=option_setup(opt,'FontSize',10);
        opt=option_setup(opt,'FontWeight','normal');
        opt=option_setup(opt,'FontAngle','normal');
        option.ax{option.cnt_subfig}.content{option.cnt_content}=opt;
    end
    function get_content_image_default()
        opt=option.ax{option.cnt_subfig}.content{option.cnt_content};
        opt=option_setup(opt,'ep',1);
        opt=option_setup(opt,'ch',[]);
        opt=option_setup(opt,'idx',1);
        opt=option_setup(opt,'z',0);
        opt=option_setup(opt,'dataset',1);
        opt=option_setup(opt,'contour_enable','off');
        opt=option_setup(opt,'contour_linecolor',[0,0,0]);
        opt=option_setup(opt,'contour_linewidth',1);
        opt=option_setup(opt,'contour_style','-');
        opt=option_setup(opt,'contour_LevelListMode','auto');
        opt=option_setup(opt,'contour_level_start',0);
        opt=option_setup(opt,'contour_level_end',1);
        opt=option_setup(opt,'contour_level_step',1);
        option.ax{option.cnt_subfig}.content{option.cnt_content}=opt;
    end
    function get_content_topo_default()
        opt=option.ax{option.cnt_subfig}.content{option.cnt_content};
        opt=option_setup(opt,'ep',1);
        opt=option_setup(opt,'idx',1);
        opt=option_setup(opt,'z',[0,0]);
        opt=option_setup(opt,'y',[0,0]);
        opt=option_setup(opt,'x',[0,0]);
        opt=option_setup(opt,'dataset',1);
        
        opt=option_setup(opt,'dim','2D');
        opt=option_setup(opt,'shrink',1);
        opt=option_setup(opt,'headrad',[]);
        opt=option_setup(opt,'surface','on');
        opt=option_setup(opt,'contour','off');
        opt=option_setup(opt,'contour_edgecolor',[0,0,0]);
        opt=option_setup(opt,'view',[0,90]);
        
        opt=option_setup(opt,'electrodes','on');
        opt=option_setup(opt,'maplimits',[]);
        opt=option_setup(opt,'dotsize',5);
        opt=option_setup(opt,'mark',[]);
        opt=option_setup(opt,'exclude',[]);
        option.ax{option.cnt_subfig}.content{option.cnt_content}=opt;
    end
    function get_content_lissajous_default()
        c=[     0    0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840];
        opt=option.ax{option.cnt_subfig}.content{option.cnt_content};
        opt=option_setup(opt,'source1_ep',1);
        opt=option_setup(opt,'source1_ch',[]);
        opt=option_setup(opt,'source1_idx',1);
        opt=option_setup(opt,'source1_z',0);
        opt=option_setup(opt,'source1_y',0);
        opt=option_setup(opt,'source1_dataset',1);
        
        opt=option_setup(opt,'source2_ep',1);
        opt=option_setup(opt,'source2_ch',[]);
        opt=option_setup(opt,'source2_idx',1);
        opt=option_setup(opt,'source2_z',0);
        opt=option_setup(opt,'source2_y',0);
        opt=option_setup(opt,'source2_dataset',1);
        
        opt=option_setup(opt,'linewidth',2);
        opt=option_setup(opt,'style','-');
        opt=option_setup(opt,'marker','none');
        opt=option_setup(opt,'color',c(mod(option.ax{option.cnt_subfig}.content_order,7)+1,:));
        
        option.ax{option.cnt_subfig}.content{option.cnt_content}=opt;
    end
    function opt=option_setup(opt,item,value) %#ok<INUSD>
        if ~isfield(opt,item)
            str=['opt.',item,'=value;'];
            eval(str);
        end
    end

    function script=get_script()
        script={};
        script{end+1}='LW_init();option=[];';
        script=get_fig_script(script);
        for idx_s=1:length(option.ax)
            script=get_axis_script(script,idx_s);
            for idx_c=1:length(option.ax{idx_s}.content)
                switch(option.ax{idx_s}.content{idx_c}.type)
                    case 'curve'
                        script=get_curve_script(script,idx_s,idx_c);
                    case 'line'
                        script=get_line_script(script,idx_s,idx_c);
                    case 'rect'
                        script=get_rect_script(script,idx_s,idx_c);
                    case 'text'
                        script=get_text_script(script,idx_s,idx_c);
                    case 'image'
                        script=get_image_script(script,idx_s,idx_c);
                    case 'topo'
                        script=get_topo_script(script,idx_s,idx_c);
                    case 'lissajous'
                        script=get_lissajous_script(script,idx_s,idx_c);
                end
            end
        end
        script{end+1}='GLW_figure(option);';
        
    end
    function script=get_fig_script(script)
        script{end+1}='% option for figure';
        for k=1:length(option.inputfiles)
            script{end+1}=['option.inputfiles{',num2str(k),'}=''',option.inputfiles{k},''';'];
        end
        if sum(option.fig2_pos~=[5,100,700,650])
            script{end+1}=['option.fig2_pos=',num2str_array(option.fig2_pos),';'];
        end
    end
    function script=get_axis_script(script,idx_s)
        str1=['option.ax{',num2str(idx_s),'}.'];
        script{end+1}='';
        script{end+1}=['% option.axis{',num2str(idx_s),'}: ',option.ax{idx_s}.name];
        script{end+1}=[str1,'name=''',option.ax{idx_s}.name,''';'];
        script{end+1}=[str1,'pos=',num2str_array(option.ax{idx_s}.pos),';'];
        script{end+1}=[str1,'style=''',option.ax{idx_s}.style,''';'];
        
        if ~strcmpi(option.ax{idx_s}.title_visible,'on')
            script{end+1}=[str1,'title_visible=''off'';'];
        end
        if ~strcmpi(option.ax{idx_s}.fontname,'Helvetica')
            script{end+1}=[str1,'fontname=''',option.ax{idx_s}.fontname,''';'];
        end
        if option.ax{idx_s}.fontsize~=10
            script{end+1}=[str1,'fontsize=',num2str(option.ax{idx_s}.fontsize),';'];
        end
        if option.ax{idx_s}.axis_reverse~=0
            script{end+1}=[str1,'axis_reverse=1;'];
        end
        if ~strcmpi(option.ax{idx_s}.box,'off')
            script{end+1}=[str1,'box=''on'';'];
        end
        if ~strcmpi(option.ax{idx_s}.visible,'on')
            script{end+1}=[str1,'visible=''off'';'];
        end
        if ~strcmpi(option.ax{idx_s}.legend,'off')
            script{end+1}=[str1,'legend=''on'';'];
        end
        if ~strcmpi(option.ax{idx_s}.XlimMode,'auto')
            script{end+1}=[str1,'XlimMode=''Manual'';'];
            script{end+1}=[str1,'Xlim=',num2str_array(option.ax{idx_s}.Xlim),';'];
        end
        if ~strcmpi(option.ax{idx_s}.XAxisLocation,'bottom')
            script{end+1}=[str1,'XAxisLocation=''',option.ax{idx_s}.XAxisLocation,''';'];
        end
        if ~strcmpi(option.ax{idx_s}.XMinorTick,'off')
            script{end+1}=[str1,'XMinorTick=''on'';'];
        end
        if ~strcmpi(option.ax{idx_s}.XTickMode,'auto')
            script{end+1}=[str1,'XTickMode=''Manual'';'];
            script{end+1}=[str1,'xaxis_tick_anchor=',num2str(option.ax{idx_s}.xaxis_tick_anchor),';'];
            script{end+1}=[str1,'xaxis_tick_interval=',num2str(option.ax{idx_s}.xaxis_tick_interval),';'];
        end
        if ~strcmpi(option.ax{idx_s}.xaxis_visible,'on')
            script{end+1}=[str1,'xaxis_visible=''off'';'];
        end
        if ~strcmpi(option.ax{idx_s}.XGrid,'off')
            script{end+1}=[str1,'XGrid=''on'';'];
        end
        if ~strcmpi(option.ax{idx_s}.XMinorGrid,'off')
            script{end+1}=[str1,'XMinorGrid=''on'';'];
        end
        if ~strcmpi(option.ax{idx_s}.xlabel_visible,'off')
            script{end+1}=[str1,'xlabel_visible=''on'';'];
            script{end+1}=[str1,'xlabel=''',option.ax{idx_s}.xlabel,''';'];
        end
        
        if ~strcmpi(option.ax{idx_s}.YlimMode,'auto')
            script{end+1}=[str1,'YlimMode=''Manual'';'];
            script{end+1}=[str1,'Ylim=',num2str_array(option.ax{idx_s}.Ylim),';'];
        end
        if ~strcmpi(option.ax{idx_s}.YAxisLocation,'left')
            script{end+1}=[str1,'YAxisLocation=''',option.ax{idx_s}.YAxisLocation,''';'];
        end
        if ~strcmpi(option.ax{idx_s}.YMinorTick,'off')
            script{end+1}=[str1,'YMinorTick=''on'';'];
        end
        if ~strcmpi(option.ax{idx_s}.YTickMode,'auto')
            script{end+1}=[str1,'YTickMode=''Manual'';'];
            script{end+1}=[str1,'yaxis_tick_anchor=',num2str(option.ax{idx_s}.yaxis_tick_anchor),';'];
            script{end+1}=[str1,'yaxis_tick_interval=',num2str(option.ax{idx_s}.yaxis_tick_interval),';'];
        end
        if ~strcmpi(option.ax{idx_s}.yaxis_visible,'on')
            script{end+1}=[str1,'yaxis_visible=''off'';'];
        end
        if ~strcmpi(option.ax{idx_s}.YGrid,'off')
            script{end+1}=[str1,'YGrid=''on'';'];
        end
        if ~strcmpi(option.ax{idx_s}.YMinorGrid,'off')
            script{end+1}=[str1,'YMinorGrid=''on'';'];
        end
        if ~strcmpi(option.ax{idx_s}.ylabel_visible,'off')
            script{end+1}=[str1,'ylabel_visible=''on'';'];
            script{end+1}=[str1,'ylabel=''',option.ax{idx_s}.ylabel,''';'];
        end
        if ~strcmpi(option.ax{idx_s}.YDir,'normal')
            script{end+1}=[str1,'YDir=''reverse'';'];
        end
        if ~strcmpi(option.ax{idx_s}.colorbar,'off')
            script{end+1}=[str1,'colorbar=''on'';'];
        end
        if ~strcmpi(option.ax{idx_s}.colormap,'jet')
            script{end+1}=[str1,'colormap=''',option.ax{idx_s}.colormap,''';'];
        end
        if ~strcmpi(option.ax{idx_s}.climMode,'auto')
            script{end+1}=[str1,'climMode=''Manual'';'];
            script{end+1}=[str1,'clim=',num2str_array(option.ax{idx_s}.clim),';'];
        end
    end
    function script=get_curve_script(script,idx_s,idx_c)
        str1=['option.ax{',num2str(idx_s),'}.content{',num2str(idx_c),'}.'];
        script{end+1}='';
        script{end+1}=['% option.axis{',num2str(idx_s),'}.content{',num2str(idx_c),'}: ',option.ax{idx_s}.content{idx_c}.name];
        script{end+1}=[str1,'name=''',option.ax{idx_s}.content{idx_c}.name,''';'];
        script{end+1}=[str1,'type=''',option.ax{idx_s}.content{idx_c}.type,''';'];
        
        if length(datasets_header)~=1
            script{end+1}=[str1,'dataset=',num2str(option.ax{idx_s}.content{idx_c}.dataset),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(1)~=1
            script{end+1}=[str1,'ep=',num2str(option.ax{idx_s}.content{idx_c}.ep),';'];
        end
        script{end+1}=[str1,'ch=''',option.ax{idx_s}.content{idx_c}.ch,''';'];
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(3)~=1
            script{end+1}=[str1,'idx=',num2str(option.ax{idx_s}.content{idx_c}.idx),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(4)~=1
            script{end+1}=[str1,'z=',num2str(option.ax{idx_s}.content{idx_c}.z),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(5)~=1
            script{end+1}=[str1,'y=',num2str(option.ax{idx_s}.content{idx_c}.y),';'];
        end
        if option.ax{idx_s}.content{idx_c}.linewidth~=2
            script{end+1}=[str1,'linewidth=',num2str(option.ax{idx_s}.content{idx_c}.linewidth),';'];
        end
        if ~strcmp(option.ax{idx_s}.content{idx_c}.style,'-')
            script{end+1}=[str1,'style=''',option.ax{idx_s}.content{idx_c}.style,''';'];
        end
        if ~strcmp(option.ax{idx_s}.content{idx_c}.marker,'none')
            script{end+1}=[str1,'marker=''',option.ax{idx_s}.content{idx_c}.marker,''';'];
        end
        %if sum(option.ax{idx_s}.content{idx_c}.color~=[0,0,0])
        script{end+1}=[str1,'color=',num2str_array(option.ax{idx_s}.content{idx_c}.color),';'];
        %end
    end
    function script=get_line_script(script,idx_s,idx_c)
        str1=['option.ax{',num2str(idx_s),'}.content{',num2str(idx_c),'}.'];
        script{end+1}='';
        script{end+1}=['% option.axis{',num2str(idx_s),'}.content{',num2str(idx_c),'}: ',option.ax{idx_s}.content{idx_c}.name];
        script{end+1}=[str1,'name=''',option.ax{idx_s}.content{idx_c}.name,''';'];
        script{end+1}=[str1,'type=''',option.ax{idx_s}.content{idx_c}.type,''';'];
        
        script{end+1}=[str1,'x=',num2str_array(option.ax{idx_s}.content{idx_c}.x),';'];
        script{end+1}=[str1,'y=',num2str_array(option.ax{idx_s}.content{idx_c}.y),';'];
        if option.ax{idx_s}.content{idx_c}.linewidth~=2
            script{end+1}=[str1,'linewidth=',num2str(option.ax{idx_s}.content{idx_c}.linewidth),';'];
        end
        if ~strcmp(option.ax{idx_s}.content{idx_c}.style,'-')
            script{end+1}=[str1,'style=''',option.ax{idx_s}.content{idx_c}.style,''';'];
        end
        if ~strcmp(option.ax{idx_s}.content{idx_c}.marker,'none')
            script{end+1}=[str1,'marker=''',option.ax{idx_s}.content{idx_c}.marker,''';'];
        end
        if sum(option.ax{idx_s}.content{idx_c}.color~=[0,0,0])
            script{end+1}=[str1,'color=',num2str_array(option.ax{idx_s}.content{idx_c}.color),';'];
        end
    end
    function script=get_rect_script(script,idx_s,idx_c)
        str1=['option.ax{',num2str(idx_s),'}.content{',num2str(idx_c),'}.'];
        script{end+1}='';
        script{end+1}=['% option.axis{',num2str(idx_s),'}.content{',num2str(idx_c),'}: ',option.ax{idx_s}.content{idx_c}.name];
        script{end+1}=[str1,'name=''',option.ax{idx_s}.content{idx_c}.name,''';'];
        script{end+1}=[str1,'type=''',option.ax{idx_s}.content{idx_c}.type,''';'];
        
        script{end+1}=[str1,'x=',num2str(option.ax{idx_s}.content{idx_c}.x),';'];
        script{end+1}=[str1,'y=',num2str(option.ax{idx_s}.content{idx_c}.y),';'];
        script{end+1}=[str1,'w=',num2str(option.ax{idx_s}.content{idx_c}.w),';'];
        script{end+1}=[str1,'h=',num2str(option.ax{idx_s}.content{idx_c}.h),';'];
        if sum(option.ax{idx_s}.content{idx_c}.FaceColor~=[0.5,0.5,0.5])
            script{end+1}=[str1,'FaceColor=',num2str_array(option.ax{idx_s}.content{idx_c}.FaceColor),';'];
        end
        if sum(option.ax{idx_s}.content{idx_c}.EdgeColor~=[0.25,0.25,0.25])
            script{end+1}=[str1,'EdgeColor=',num2str_array(option.ax{idx_s}.content{idx_c}.EdgeColor),';'];
        end
        if option.ax{idx_s}.content{idx_c}.FaceAlpha~=0.5
            script{end+1}=[str1,'FaceAlpha=',num2str(option.ax{idx_s}.content{idx_c}.FaceAlpha),';'];
        end
        if option.ax{idx_s}.content{idx_c}.EdgeAlpha~=1
            script{end+1}=[str1,'EdgeAlpha=',num2str(option.ax{idx_s}.content{idx_c}.EdgeAlpha),';'];
        end
        if option.ax{idx_s}.content{idx_c}.linewidth~=0.5
            script{end+1}=[str1,'linewidth=',num2str(option.ax{idx_s}.content{idx_c}.linewidth),';'];
        end
    end
    function script=get_text_script(script,idx_s,idx_c)
        str1=['option.ax{',num2str(idx_s),'}.content{',num2str(idx_c),'}.'];
        script{end+1}='';
        script{end+1}=['% option.axis{',num2str(idx_s),'}.content{',num2str(idx_c),'}: ',option.ax{idx_s}.content{idx_c}.name];
        script{end+1}=[str1,'name=''',option.ax{idx_s}.content{idx_c}.name,''';'];
        script{end+1}=[str1,'type=''',option.ax{idx_s}.content{idx_c}.type,''';'];
        
        script{end+1}=[str1,'pos=',num2str_array(option.ax{idx_s}.content{idx_c}.pos),';'];
        script{end+1}=[str1,'string=',str_array2str(option.ax{idx_s}.content{idx_c}.string),';'];
        if sum(option.ax{idx_s}.content{idx_c}.Color~=[0,0,0])
            script{end+1}=[str1,'Color=',num2str_array(option.ax{idx_s}.content{idx_c}.Color),';'];
        end
        if ~strcmpi(option.ax{idx_s}.content{idx_c}.FontName,'Helvetica')
            script{end+1}=[str1,'FontName=''',option.ax{idx_s}.content{idx_c}.FontName,''';'];
        end
        if option.ax{idx_s}.content{idx_c}.FontSize~=10
            script{end+1}=[str1,'FontSize=',num2str(option.ax{idx_s}.content{idx_c}.FontSize),';'];
        end
        if ~strcmpi(option.ax{idx_s}.content{idx_c}.FontWeight,'normal')
            script{end+1}=[str1,'FontWeight=''',option.ax{idx_s}.content{idx_c}.FontWeight,''';'];
        end
        if ~strcmpi(option.ax{idx_s}.content{idx_c}.FontAngle,'normal')
            script{end+1}=[str1,'FontAngle=''',option.ax{idx_s}.content{idx_c}.FontAngle,''';'];
        end
    end
    function script=get_image_script(script,idx_s,idx_c)
        str1=['option.ax{',num2str(idx_s),'}.content{',num2str(idx_c),'}.'];
        script{end+1}='';
        script{end+1}=['% option.axis{',num2str(idx_s),'}.content{',num2str(idx_c),'}: ',option.ax{idx_s}.content{idx_c}.name];
        script{end+1}=[str1,'name=''',option.ax{idx_s}.content{idx_c}.name,''';'];
        script{end+1}=[str1,'type=''',option.ax{idx_s}.content{idx_c}.type,''';'];
        
        
        if length(datasets_header)~=1
            script{end+1}=[str1,'dataset=',num2str(option.ax{idx_s}.content{idx_c}.dataset),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(1)~=1
            script{end+1}=[str1,'ep=',num2str(option.ax{idx_s}.content{idx_c}.ep),';'];
        end
        script{end+1}=[str1,'ch=''',option.ax{idx_s}.content{idx_c}.ch,''';'];
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(3)~=1
            script{end+1}=[str1,'idx=',num2str(option.ax{idx_s}.content{idx_c}.idx),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(4)~=1
            script{end+1}=[str1,'z=',num2str(option.ax{idx_s}.content{idx_c}.z),';'];
        end
        
        if ~strcmpi(option.ax{idx_s}.content{idx_c}.contour_enable,'off')
            script{end+1}=[str1,'contour_enable=''on'';'];
        end
        if sum(option.ax{idx_s}.content{idx_c}.contour_linecolor~=[0,0,0])
            script{end+1}=[str1,'contour_linecolor=',num2str_array(option.ax{idx_s}.content{idx_c}.contour_linecolor),';'];
        end
        if option.ax{idx_s}.content{idx_c}.contour_linewidth~=1
            script{end+1}=[str1,'contour_linewidth=',num2str(option.ax{idx_s}.content{idx_c}.contour_linewidth),';'];
        end
        if ~strcmp(option.ax{idx_s}.content{idx_c}.contour_style,'-')
            script{end+1}=[str1,'contour_style=''',option.ax{idx_s}.content{idx_c}.contour_style,''';'];
        end
        if ~strcmpi(option.ax{idx_s}.content{idx_c}.contour_LevelListMode,'auto')
            script{end+1}=[str1,'contour_LevelListMode=''Manual'';'];
            script{end+1}=[str1,'contour_level_start=',num2str(option.ax{idx_s}.content{idx_c}.contour_level_start),';'];
            script{end+1}=[str1,'contour_level_end=',num2str(option.ax{idx_s}.content{idx_c}.contour_level_end),';'];
            script{end+1}=[str1,'contour_level_step=',num2str(option.ax{idx_s}.content{idx_c}.contour_level_step),';'];
        end
    end
    function script=get_topo_script(script,idx_s,idx_c)
        str1=['option.ax{',num2str(idx_s),'}.content{',num2str(idx_c),'}.'];
        script{end+1}='';
        script{end+1}=['% option.axis{',num2str(idx_s),'}.content{',num2str(idx_c),'}: ',option.ax{idx_s}.content{idx_c}.name];
        script{end+1}=[str1,'name=''',option.ax{idx_s}.content{idx_c}.name,''';'];
        script{end+1}=[str1,'type=''',option.ax{idx_s}.content{idx_c}.type,''';'];
        
        if length(datasets_header)~=1
            script{end+1}=[str1,'dataset=',num2str(option.ax{idx_s}.content{idx_c}.dataset),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(1)~=1
            script{end+1}=[str1,'ep=',num2str(option.ax{idx_s}.content{idx_c}.ep),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(3)~=1
            script{end+1}=[str1,'idx=',num2str(option.ax{idx_s}.content{idx_c}.idx),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(4)~=1
            script{end+1}=[str1,'z=',num2str_array(option.ax{idx_s}.content{idx_c}.z),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(5)~=1
            script{end+1}=[str1,'y=',num2str_array(option.ax{idx_s}.content{idx_c}.y),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.dataset).header.datasize(6)~=1
            script{end+1}=[str1,'x=',num2str_array(option.ax{idx_s}.content{idx_c}.x),';'];
        end
        if strcmp(option.ax{idx_s}.content{idx_c}.dim,'2D')
            script{end+1}=[str1,'dim=''2D'';'];
            if option.ax{idx_s}.content{idx_c}.shrink~=1
                script{end+1}=[str1,'shrink=',num2str(option.ax{idx_s}.content{idx_c}.shrink),';'];
            end
            if ~isempty(option.ax{idx_s}.content{idx_c}.headrad)
                script{end+1}=[str1,'headrad=',num2str(option.ax{idx_s}.content{idx_c}.headrad),';'];
            end
            if ~strcmpi(option.ax{idx_s}.content{idx_c}.surface,'on')
                script{end+1}=[str1,'surface=''off'';'];
            end
            if ~strcmpi(option.ax{idx_s}.content{idx_c}.contour,'off')
                script{end+1}=[str1,'contour=''on'';'];
                if sum(option.ax{idx_s}.content{idx_c}.contour_edgecolor~=[0,0,0])
                    script{end+1}=[str1,'contour_edgecolor=',num2str_array(option.ax{idx_s}.content{idx_c}.contour_edgecolor),';'];
                end
            end
        else
            script{end+1}=[str1,'dim=''3D'';'];
            if sum(option.ax{idx_s}.content{idx_c}.view~=[0,90])
                script{end+1}=[str1,'view=',num2str_array(option.ax{idx_s}.content{idx_c}.view),';'];
            end
        end
        
        if ~isempty(option.ax{idx_s}.content{idx_c}.maplimits)
            script{end+1}=[str1,'maplimits=',num2str_array(option.ax{idx_s}.content{idx_c}.maplimits),';'];
        end
        if ~strcmpi(option.ax{idx_s}.content{idx_c}.electrodes,'on')
            script{end+1}=[str1,'electrodes=''off'';'];
        else
            if option.ax{idx_s}.content{idx_c}.dotsize~=5
                script{end+1}=[str1,'dotsize=',num2str(option.ax{idx_s}.content{idx_c}.dotsize),';'];
            end
            if ~isempty(option.ax{idx_s}.content{idx_c}.mark)
                script{end+1}=[str1,'mark=',str_array2str(option.ax{idx_s}.content{idx_c}.mark),';'];
            end
        end
        if ~isempty(option.ax{idx_s}.content{idx_c}.exclude)
            script{end+1}=[str1,'exclude=',str_array2str(option.ax{idx_s}.content{idx_c}.exclude),';'];
        end
    end
    function script=get_lissajous_script(script,idx_s,idx_c)
        str1=['option.ax{',num2str(idx_s),'}.content{',num2str(idx_c),'}.'];
        script{end+1}='';
        script{end+1}=['% option.axis{',num2str(idx_s),'}.content{',num2str(idx_c),'}: ',option.ax{idx_s}.content{idx_c}.name];
        script{end+1}=[str1,'name=''',option.ax{idx_s}.content{idx_c}.name,''';'];
        script{end+1}=[str1,'type=''',option.ax{idx_s}.content{idx_c}.type,''';'];
        
        if length(datasets_header)~=1
            script{end+1}=[str1,'source1_dataset=',num2str(option.ax{idx_s}.content{idx_c}.source1_dataset),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.source1_dataset).header.datasize(1)~=1
            script{end+1}=[str1,'source1_ep=',num2str(option.ax{idx_s}.content{idx_c}.source1_ep),';'];
        end
        script{end+1}=[str1,'source1_ch=''',option.ax{idx_s}.content{idx_c}.source1_ch,''';'];
        if datasets_header(option.ax{idx_s}.content{idx_c}.source1_dataset).header.datasize(3)~=1
            script{end+1}=[str1,'source1_idx=',num2str(option.ax{idx_s}.content{idx_c}.source1_idx),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.source1_dataset).header.datasize(4)~=1
            script{end+1}=[str1,'source1_z=',num2str(option.ax{idx_s}.content{idx_c}.source1_z),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.source1_dataset).header.datasize(5)~=1
            script{end+1}=[str1,'source1_y=',num2str(option.ax{idx_s}.content{idx_c}.source1_y),';'];
        end
        
        if length(datasets_header)~=1
            script{end+1}=[str1,'source2_dataset=',num2str(option.ax{idx_s}.content{idx_c}.source2_dataset),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.source2_dataset).header.datasize(1)~=1
            script{end+1}=[str1,'source2_ep=',num2str(option.ax{idx_s}.content{idx_c}.source1_ep),';'];
        end
        script{end+1}=[str1,'source2_ch=''',option.ax{idx_s}.content{idx_c}.source2_ch,''';'];
        if datasets_header(option.ax{idx_s}.content{idx_c}.source2_dataset).header.datasize(3)~=1
            script{end+1}=[str1,'source2_idx=',num2str(option.ax{idx_s}.content{idx_c}.source2_idx),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.source2_dataset).header.datasize(4)~=1
            script{end+1}=[str1,'source2_z=',num2str(option.ax{idx_s}.content{idx_c}.source2_z),';'];
        end
        if datasets_header(option.ax{idx_s}.content{idx_c}.source2_dataset).header.datasize(5)~=1
            script{end+1}=[str1,'source2_y=',num2str(option.ax{idx_s}.content{idx_c}.source2_y),';'];
        end
        
        
        if option.ax{idx_s}.content{idx_c}.linewidth~=2
            script{end+1}=[str1,'linewidth=',num2str(option.ax{idx_s}.content{idx_c}.linewidth),';'];
        end
        if ~strcmp(option.ax{idx_s}.content{idx_c}.style,'-')
            script{end+1}=[str1,'style=''',option.ax{idx_s}.content{idx_c}.style,''';'];
        end
        if ~strcmp(option.ax{idx_s}.content{idx_c}.marker,'none')
            script{end+1}=[str1,'marker=''',option.ax{idx_s}.content{idx_c}.marker,''';'];
        end
        if sum(option.ax{idx_s}.content{idx_c}.color~=[0,0,0])
            script{end+1}=[str1,'color=',num2str_array(option.ax{idx_s}.content{idx_c}.color),';'];
        end
    end
    function str=num2str_array(data)
        str='[';
        for k=1:length(data)
            str=[str,num2str(data(k))];
            if k~=length(data)
                str=[str,','];
            else
                str=[str,']'];
            end
        end
    end
    function str=str_array2str(data)
        str='{';
        for k=1:length(data)
            if iscell(data)
                str=[str,'''',data{k},''''];
            else
                str=[str,'''',data(k,:),''''];
            end
            if k~=length(data)
                str=[str,','];
            else
                str=[str,'}'];
            end
        end
    end

%% panel_fig function
    function fig1_callback(~,~,callback_index)
        if nargin==3
            option.cnt_panel=callback_index;
        end
        subfig_str=cell(length(option.ax),1);
        for k=1:length(option.ax)
            subfig_str{k}=option.ax{k}.name;
        end
        if ~isempty(option.ax)
            option.cnt_subfig=min(length(option.ax),max(1,option.cnt_subfig));
            set(handles.subfig_listbox,'string',subfig_str,'value',option.cnt_subfig);
            content_str=cell(length(option.ax{option.cnt_subfig}.content),1);
            for k=1:length(option.ax{option.cnt_subfig}.content)
                content_str{k}=option.ax{option.cnt_subfig}.content{k}.name;
            end
            set(handles.content_listbox,'string',content_str,'value',1);
            if ~isempty(option.ax{option.cnt_subfig}.content)
                option.cnt_content=max(option.cnt_content,1);
                set(handles.content_listbox,'value',option.cnt_content);
            end
        else
            set(handles.subfig_listbox,'string',{});
            set(handles.content_listbox,'string',{});
        end
        set(handles.fig_btn,'State','off');
        set(handles.axis_btn,'State','off');
        set(handles.content_btn,'State','off');
        set(handles.panel_fig,'visible','off');
        set(handles.panel_fig_sub,'visible','off');
        set(handles.panel_axis,'visible','off');
        set(handles.panel_content_manager,'visible','off');
        set(handles.panel_curve,'visible','off');
        set(handles.panel_line,'visible','off');
        set(handles.panel_rect,'visible','off');
        set(handles.panel_text,'visible','off');
        set(handles.panel_image,'visible','off');
        set(handles.panel_topo,'visible','off');
        set(handles.panel_lissajous,'visible','off');
        
        switch(option.cnt_panel)
            case 1
                set(handles.fig_btn,'State','on');
                set(handles.panel_fig,'visible','on');
                get_fig_pos();
                if ~isempty(option.ax)
                    set(handles.panel_fig_sub,'visible','on');
                    panel_fig_sub_callback();
                end
            case 2
                set(handles.axis_btn,'State','on');
                if ~isempty(option.ax) &&...
                        ~strcmpi(option.ax{option.cnt_subfig}.style,'Topograph')
                    set(handles.panel_axis,'visible','on');
                    axis_callback();
                end
            case 3
                set(handles.content_btn,'State','on');
                if ~isempty(option.ax)
                    content_callback();
                    if ~isempty( option.ax{option.cnt_subfig}.content)
                        switch option.ax{option.cnt_subfig}.content{option.cnt_content}.type
                            case 'curve'
                                set(handles.panel_curve,'visible','on');
                                curve_callback();
                            case 'line'
                                set(handles.panel_line,'visible','on');
                                line_callback();
                            case 'rect'
                                set(handles.panel_rect,'visible','on');
                                rect_callback();
                            case 'text'
                                set(handles.panel_text,'visible','on');
                                text_callback();
                            case 'image'
                                set(handles.panel_image,'visible','on');
                                image_callback();
                            case 'topo'
                                set(handles.panel_topo,'visible','on');
                                topo_callback();
                            case 'lissajous'
                                set(handles.panel_lissajous,'visible','on');
                                lissajous_callback();
                        end
                    end
                end
        end
    end
    function fig1_closeReq_callback(~, ~)
        closereq;
        if ishandle(handles.fig2)
            close(handles.fig2);
        end
    end
    function fig2_closeReq_callback(~, ~)
        closereq;
        if ishandle(handles.fig1)
            close(handles.fig1);
        end
    end
    function open_btn_callback(~,~)
        [FileName,PathName] = uigetfile(...
            {'*.lw_figure','Figure Files(*.lw_figure)'});
        if PathName==0
            return;
        end
        load(fullfile(PathName,FileName),'-mat');
        init_data();
        fig_redraw();
        fig1_callback();
    end
    function save_btn_callback(~,~)
        [FileName,PathName] = uiputfile('*.lw_figure','Save figure as');
        if PathName==0
            return;
        end
        get_fig_pos();
        save(fullfile(PathName,FileName),'option');
    end
    function data_btn_callback(~,~)
        temp=CLW_figure_data(option.inputfiles);
        if ~isempty(temp)
            option.inputfiles=temp;
            init_data();
            fig_redraw();
            fig1_callback();
        end
    end
    function export_btn_callback(~,~)
        [FileName,PathName,FilterIndex] = uiputfile(...
            {'*.fig','Figure (*.fig)';...
            '*.tif','TIFF image (*.tif)';...
            '*.jpg','JPEG image (*.jpg)';...
            '*.bmp','Bitmap file (*.bmp)';...
            '*.png','Protable Network Graphics file (*.png)';...
            '*.eps','EPS file (*.eps)';...
            '*.pdf','Portable Document Format (*.pdf)'},...
            'Save As','new figure');
        if FilterIndex==0
            return;
        end
        if (FilterIndex==6)
            saveas(handles.fig2,fullfile(PathName,FileName),'epsc');
            return;
        end
        if (FilterIndex==1)
            set(handles.fig2,'CloseRequestFcn','closereq');
            try
                set(handles.fig2,'SizeChangedFcn','');
            catch
                set(handles.fig2,'resizefcn','');
            end
            set(handles.fig2,'numbertitle','on','MenuBar','figure','DockControls','on');
            set(handles.fig2,'WindowButtonMotionFcn','');
            try
                savefig(handles.fig2,fullfile(PathName,FileName));
            catch
                saveas(handles.fig2,fullfile(PathName,FileName),'fig')
            end
            
            set(handles.fig2,'CloseRequestFcn',@fig2_closeReq_callback);
            try
                set(handles.fig2,'SizeChangedFcn',@get_fig_pos);
            catch
                set(handles.fig2,'resizefcn',@get_fig_pos);
            end
            set(handles.fig2,'numbertitle','off','MenuBar','none','DockControls','off');
            set(handles.fig2,'WindowButtonMotionFcn',@get_fig_pos);
            return;
        end
        saveas(handles.fig2,fullfile(PathName,FileName));
    end
    function script_btn_callback(~,~)
        script=get_script();
        CLW_show_script(script);
    end
    function panel_fig_sub_callback(~,~)
        set(handles.sub_title_edt,'string',option.ax{option.cnt_subfig}.name);
        if strcmp(option.ax{option.cnt_subfig}.title_visible,'on')
            set(handles.sub_title_chx,'value',1);
            set(handles.sub_title_edt,'enable','on');
        else
            set(handles.sub_title_chx,'value',0);
            set(handles.sub_title_edt,'enable','off');
        end
        a=find(strcmpi(listfonts,option.ax{option.cnt_subfig}.fontname)==1);
        set(handles.sub_font_pop,'value',a(1));
        set(handles.sub_size_edt,'string',num2str(option.ax{option.cnt_subfig}.fontsize));
        sub_position_chk_callback();
    end
    function subfig_listbox_callback(~,~)
        subfig_value=get(handles.subfig_listbox,'value');
        if ~isempty(option.ax)
            if isempty(subfig_value)
                set(handles.subfig_listbox,'value',option.cnt_subfig)
            else
                option.cnt_subfig=subfig_value;
                option.cnt_content=min(option.cnt_content,length(option.ax{option.cnt_subfig}.content));
                fig1_callback();
            end
        end
    end
    function content_listbox_callback(~,~)
        content_value=get(handles.content_listbox,'value');
        if ~isempty(option.ax{option.cnt_subfig}.content)
            if isempty(content_value)
                set(handles.content_listbox,'value',option.cnt_content)
            else
                option.cnt_content=content_value;
                fig1_callback();
            end
        end
    end
    function sub_add_callback(~,~)
        n=length(option.ax);
        pos=[(mod(n,6)+1)/10,1-mod(n,6)/10-1/3-0.1,1/3,1/3];
        
        sub_style_value=get(handles.sub_add_pop,'value');
        sub_style_str=get(handles.sub_add_pop,'string');
        sub_style_str=sub_style_str{sub_style_value};
        option.cnt_subfig=length(option.ax)+1;
        option.ax{option.cnt_subfig}.name=[sub_style_str,num2str(option.subfig_order)];
        option.subfig_order=option.subfig_order+1;
        option.ax{option.cnt_subfig}.style=sub_style_str;
        get_axis_default();
        
        handles.ax(option.cnt_subfig)=axes('parent',handles.fig2,'position',pos);
        get_sub_pos();
        handles.ax_child{option.cnt_subfig}=[];
        handles.ax_child{option.cnt_subfig}.handle=cell(0,1);
        hold(handles.ax(option.cnt_subfig),'on');
        t=get(handles.ax(option.cnt_subfig),'title');
        set(t,'string',option.ax{option.cnt_subfig}.name);
        switch(sub_style_str)
            case 'Curve'
            case 'Image'
                option.cnt_content=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.name=['image',num2str(option.ax{option.cnt_subfig}.content_order)];
                option.ax{option.cnt_subfig}.content_order=option.ax{option.cnt_subfig}.content_order+1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.type='image';
                get_content_image_default();
                
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).img=imagesc('Parent',handles.ax(option.cnt_subfig));
                [~,handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour]=contour(handles.ax(option.cnt_subfig),randn(2,2),randn(2,2),randn(2,2),'LineColor','k','visible','off');
                
            case 'Topograph'
                option.cnt_content=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.name=['topo',num2str(option.ax{option.cnt_subfig}.content_order)];
                option.ax{option.cnt_subfig}.content_order=option.ax{option.cnt_subfig}.content_order+1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.type='topo';
                get_content_topo_default();
                
                %2D
                radiuscircle = 0.5;
                pnts   = linspace(0,2*pi,200);
                xc     = sin(pnts)*radiuscircle;
                yc     = cos(pnts)*radiuscircle;
                base  = radiuscircle-.0046;
                basex = 0.18*radiuscircle;                   % nose width
                tip   = 1.15*radiuscircle;
                tiphw = .04*radiuscircle;                    % nose tip half width
                tipr  = .01*radiuscircle;                    % nose tip rounding
                q = .04;                                     % ear lengthening
                EarX  = [.497-.005  .510  .518  .5299 .5419  .54    .547   .532   .510   .489-.005];
                EarY  = [q+.0555 q+.0775 q+.0783 q+.0746 q+.0555 -.0055 -.0932 -.1313 -.1384 -.1199];
                top=1;
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).surf_2D=surf('Parent',handles.ax(option.cnt_subfig),'edgecolor', 'none');
                [~,handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour]=contour3(handles.ax(option.cnt_subfig),randn(2,2));
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line1=plot3(handles.ax(option.cnt_subfig),xc,yc,ones(size(xc))*top, 'k', 'linewidth', 2);
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line2=plot3(handles.ax(option.cnt_subfig),EarX,EarY,ones(size(EarX))*top,'color','k','LineWidth',2);
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line3=plot3(handles.ax(option.cnt_subfig),-EarX,EarY,ones(size(EarY))*top,'color','k','LineWidth',2);
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line4=plot3(handles.ax(option.cnt_subfig),...
                    [basex;tiphw;0;-tiphw;-basex],[base;tip-tipr;tip;tip-tipr;base],...
                    top*ones(size([basex;tiphw;0;-tiphw;-basex])),'color','k','LineWidth',2);
                
                %3D
                P=linspace(1,64,length(POS))';
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).surf_3D=patch('Parent',handles.ax(option.cnt_subfig),...
                    'Vertices',POS,'Faces',TRI,'FaceVertexCdata',P,'FaceColor','interp','EdgeColor','none','DiffuseStrength',.6,...
                    'SpecularStrength',0,'AmbientStrength',.3,'SpecularExponent',5,'vertexnormals', NORM);
                
                %for all
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode=plot3(handles.ax(option.cnt_subfig), 0,0,-1, 'k.', 'markersize', 0.001);
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker1=plot3(handles.ax(option.cnt_subfig), 0,0,-1, 'y.', 'markersize', 4,'visible','off');
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker2=plot3(handles.ax(option.cnt_subfig), 0,0,-1, 'r.', 'markersize', 2,'visible','off');
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text=[];
                view(handles.ax(option.cnt_subfig),[0 0 1]);
                axis(handles.ax(option.cnt_subfig),'off','image');
                set(handles.ax(option.cnt_subfig), 'ydir', 'normal');
        end
        fig1_callback();
        switch(sub_style_str)
            case 'Image'
                image_update();
            case 'Topograph'
                topo_update();
        end
    end
    function sub_del_callback(~,~)
        if isempty(handles.ax)
            return;
        end
        delete(handles.ax(option.cnt_subfig));
        handles.ax=handles.ax(setdiff(1:end,option.cnt_subfig));
        handles.ax_child=handles.ax_child(setdiff(1:end,option.cnt_subfig));
        option.ax=option.ax(setdiff(1:end,option.cnt_subfig));
        option.cnt_subfig=min(option.cnt_subfig,length(handles.ax));
        fig1_callback();
    end
    function sub_up_callback(~,~)
        if isempty(handles.ax)
            return;
        end
        str=get(handles.subfig_listbox,'string');
        if option.cnt_subfig==1
            return;
        else
            index=[1:option.cnt_subfig-2,option.cnt_subfig,option.cnt_subfig-1,option.cnt_subfig+1:length(handles.ax)];
            handles.ax=handles.ax(index);
            handles.ax_child=handles.ax_child(index);
            option.ax=option.ax(index);
            set(handles.subfig_listbox,'string',str(index));
            option.cnt_subfig=option.cnt_subfig-1;
            set(handles.subfig_listbox,'value',option.cnt_subfig);
            fig_redraw;
        end
    end
    function sub_down_callback(~,~)
        if isempty(handles.ax)
            return;
        end
        str=get(handles.subfig_listbox,'string');
        if option.cnt_subfig==length(handles.ax)
            return;
        else
            index=[1:option.cnt_subfig-1,option.cnt_subfig+1,option.cnt_subfig,option.cnt_subfig+2:length(handles.ax)];
            handles.ax=handles.ax(index);
            handles.ax_child=handles.ax_child(index);
            option.ax=option.ax(index);
            set(handles.subfig_listbox,'string',str(index));
            option.cnt_subfig=option.cnt_subfig+1;
            set(handles.subfig_listbox,'value',option.cnt_subfig);
            fig_redraw;
        end
    end

    function sub_title_chx_callback(~,~)
        idx=get(handles.sub_title_chx,'value');
        t=get(handles.ax(option.cnt_subfig),'title');
        if idx==1
            set(t,'visible','on');
            option.ax{option.cnt_subfig}.title_visible='on';
            set(t,'string',option.ax{option.cnt_subfig}.name);
            set(handles.sub_title_edt,'enable','on','string',option.ax{option.cnt_subfig}.name);
        else
            set(t,'visible','off');
            option.ax{option.cnt_subfig}.title_visible='off';
            set(handles.sub_title_edt,'enable','off');
        end
    end
    function sub_title_edt_callback(~,~)
        idx=get(handles.sub_title_chx,'value');
        t=get(handles.ax(option.cnt_subfig),'title');
        option.ax{option.cnt_subfig}.name=get(handles.sub_title_edt,'string');
        set(t,'string',get(handles.sub_title_edt,'string'));
        
        string=get(handles.subfig_listbox,'string');
        string{option.cnt_subfig}= option.ax{option.cnt_subfig}.name;
        set(handles.subfig_listbox,'string',string);
    end
    function sub_font_pop_callback(~,~)
        t=get(handles.ax(option.cnt_subfig),'title');
        str=get(handles.sub_font_pop,'string');
        value=get(handles.sub_font_pop,'value');
        set(t,'fontname',str{value});
        option.ax{option.cnt_subfig}.fontname=str{value};
    end
    function sub_size_edt_callback(~,~)
        fontsize=str2num(get(handles.sub_size_edt,'string'));
        option.ax{option.cnt_subfig}.fontsize=fontsize;
        set(handles.ax(option.cnt_subfig),'fontsize',fontsize);
    end
    function sub_position_chk_callback(~,~)
        if get(handles.sub_position_chk,'value')
            option.ax_auto_position=1;
            sub_row_edt_callback();
            set(handles.sub_col_txt,'visible','on');
            set(handles.sub_col_edt,'visible','on');
            set(handles.sub_row_txt,'visible','on');
            set(handles.sub_row_edt,'visible','on');
            set(handles.sub_update_btn,'visible','on');
            set(handles.sub_x_txt,'visible','off');
            set(handles.sub_y_txt,'visible','off');
            set(handles.sub_w_txt,'visible','off');
            set(handles.sub_h_txt,'visible','off');
            set(handles.sub_x_edt,'visible','off');
            set(handles.sub_y_edt,'visible','off');
            set(handles.sub_w_edt,'visible','off');
            set(handles.sub_h_edt,'visible','off');
        else
            option.ax_auto_position=0;
            get_sub_pos();
            set(handles.sub_col_txt,'visible','off');
            set(handles.sub_col_edt,'visible','off');
            set(handles.sub_row_txt,'visible','off');
            set(handles.sub_row_edt,'visible','off');
            set(handles.sub_update_btn,'visible','off');
            set(handles.sub_x_txt,'visible','on');
            set(handles.sub_y_txt,'visible','on');
            set(handles.sub_w_txt,'visible','on');
            set(handles.sub_h_txt,'visible','on');
            set(handles.sub_x_edt,'visible','on');
            set(handles.sub_y_edt,'visible','on');
            set(handles.sub_w_edt,'visible','on');
            set(handles.sub_h_edt,'visible','on');
        end
    end
    function sub_col_edt_callback(~,~)
        n=length(handles.ax);
        n_row=str2num(get(handles.sub_row_edt,'string'));
        n_col=str2num(get(handles.sub_col_edt,'string'));
        if n_row*n_col<n
            n_row=ceil(n/n_col);
            set(handles.sub_row_edt,'string',num2str(n_row));
        end
    end
    function sub_row_edt_callback(~,~)
        n=length(handles.ax);
        n_row=str2num(get(handles.sub_row_edt,'string'));
        n_col=str2num(get(handles.sub_col_edt,'string'));
        if n_row*n_col<n
            n_col=ceil(n/n_row);
            set(handles.sub_col_edt,'string',num2str(n_col));
        end
    end
    function sub_update_btn_callback(~,~)
        sub_row_edt_callback();
        n=length(handles.ax);
        n_row=str2num(get(handles.sub_row_edt,'string'));
        n_col=str2num(get(handles.sub_col_edt,'string'));
        
        option.ax_auto_position=1;
        option.ax_auto_col=n_col;
        option.ax_auto_row=n_row;
        for k=1:n
            subplot(n_row,n_col,k,handles.ax(k));
            set(handles.ax(k),'unit','pixels');
            option.ax{k}.pos=get(handles.ax(k),'Position');
            set(handles.ax(k),'unit','normalized');
        end
    end

    function get_fig_pos(~,~)
        option.fig2_pos=get(handles.fig2,'Position');
        set(handles.fig_x_edt,'string',num2str(option.fig2_pos(1)));
        set(handles.fig_y_edt,'string',num2str(option.fig2_pos(2)));
        set(handles.fig_w_edt,'string',num2str(option.fig2_pos(3)));
        set(handles.fig_h_edt,'string',num2str(option.fig2_pos(4)));
        for k=setdiff(1:length(handles.ax),option.cnt_subfig)
            set(handles.ax(k),'unit','pixels');
            option.ax{k}.pos=get(handles.ax(k),'Position');
            set(handles.ax(k),'unit','normalized');
        end
        get_sub_pos();
    end
    function set_fig_pos(~,~)
        try
            option.fig2_pos(1)=str2num(get(handles.fig_x_edt,'string'));
            option.fig2_pos(2)=str2num(get(handles.fig_y_edt,'string'));
            option.fig2_pos(3)=str2num(get(handles.fig_w_edt,'string'));
            option.fig2_pos(4)=str2num(get(handles.fig_h_edt,'string'));
            set(handles.fig2,'Position',option.fig2_pos);
        catch
            get_fig_pos();
        end
    end
    function get_sub_pos(~,~)
        if ~isempty(handles.ax)
            set(handles.ax(option.cnt_subfig),'unit','pixels');
            option.ax{option.cnt_subfig}.pos=get(handles.ax(option.cnt_subfig),'Position');
            set(handles.ax(option.cnt_subfig),'unit','normalized');
            set(handles.sub_x_edt,'string',num2str(option.ax{option.cnt_subfig}.pos(1)));
            set(handles.sub_y_edt,'string',num2str(option.ax{option.cnt_subfig}.pos(2)));
            set(handles.sub_w_edt,'string',num2str(option.ax{option.cnt_subfig}.pos(3)));
            set(handles.sub_h_edt,'string',num2str(option.ax{option.cnt_subfig}.pos(4)));
        end
    end
    function set_sub_pos(~,~)
        try
            option.ax{option.cnt_subfig}.pos(1)=str2num(get(handles.sub_x_edt,'string'));
            option.ax{option.cnt_subfig}.pos(2)=str2num(get(handles.sub_y_edt,'string'));
            option.ax{option.cnt_subfig}.pos(3)=str2num(get(handles.sub_w_edt,'string'));
            option.ax{option.cnt_subfig}.pos(4)=str2num(get(handles.sub_h_edt,'string'));
            Set_position(handles.ax(option.cnt_subfig),option.ax{option.cnt_subfig}.pos);
        catch
            get_sub_pos();
        end
    end

%% panel_axis function
    function axis_callback()
        if ~strcmpi(option.ax{option.cnt_subfig}.style,'Curve')
            set(handles.axis_reverse_chk,'visible','off');
            set(handles.axis_box_chk,'visible','off');
            set(handles.axis_visible_chk,'visible','off');
            set(handles.axis_legend_chk,'visible','off');
            set(handles.axis_legend_edt,'visible','off');
        else
            set(handles.axis_reverse_chk,'visible','on');
            set(handles.axis_box_chk,'visible','on');
            set(handles.axis_visible_chk,'visible','on');
            set(handles.axis_legend_chk,'visible','on');
            set(handles.axis_reverse_chk,'value',option.ax{option.cnt_subfig}.axis_reverse);
            if strcmpi(option.ax{option.cnt_subfig}.box,'on')
                set (handles.axis_box_chk,'value',1);
            else
                set (handles.axis_box_chk,'value',0);
            end
            
            if strcmpi(option.ax{option.cnt_subfig}.visible,'on')
                set (handles.axis_visible_chk,'value',1);
            else
                set (handles.axis_visible_chk,'value',0);
            end
            
            if strcmpi(option.ax{option.cnt_subfig}.legend,'on')
                set (handles.axis_legend_chk,'value',1);
                if ~isempty(option.ax{option.cnt_subfig}.content)
                    set(handles.axis_legend_edt,'visible','on',...
                        'string',option.ax{option.cnt_subfig}.content{option.cnt_content}.name);
                end
            else
                set(handles.axis_legend_chk,'value',0);
                set(handles.axis_legend_edt,'visible','off');
            end
        end
        
        %x-axis
        if ~strcmpi(option.ax{option.cnt_subfig}.XlimMode,'auto')
            set (handles.xaxis_limit_chk,'value',1);
            set (handles.xaxis_limit1_edt,'enable','on');
            set (handles.xaxis_limit2_edt,'enable','on');
        else
            set (handles.xaxis_limit_chk,'value',0);
            option.ax{option.cnt_subfig}.Xlim=get(handles.ax(option.cnt_subfig),'Xlim');
            set (handles.xaxis_limit1_edt,'enable','off');
            set (handles.xaxis_limit2_edt,'enable','off');
        end
        set (handles.xaxis_limit1_edt,'string',num2str(option.ax{option.cnt_subfig}.Xlim(1)));
        set (handles.xaxis_limit2_edt,'string',num2str(option.ax{option.cnt_subfig}.Xlim(2)));
        switch option.ax{option.cnt_subfig}.XAxisLocation
            case 'bottom'
                set (handles.xaxis_location_pop,'value',1);
            case 'top'
                set (handles.xaxis_location_pop,'value',2);
            case 'origin'
                if verLessThan('matlab','8.4')
                    set (handles.xaxis_location_pop,'value',1);
                else
                    set (handles.xaxis_location_pop,'value',3);
                end
        end
        if strcmp(option.ax{option.cnt_subfig}.XMinorTick,'on')
            set(handles.xaxis_minor_tick_chk,'value',1);
        else
            set(handles.xaxis_minor_tick_chk,'value',0);
        end
        if isempty(option.ax{option.cnt_subfig}.xaxis_tick_anchor)
            temp=get(handles.ax(option.cnt_subfig),'XTick');
            option.ax{option.cnt_subfig}.xaxis_tick_interval=temp(2)-temp(1);
            option.ax{option.cnt_subfig}.xaxis_tick_anchor=temp(1);
        end
        set(handles.xaxis_tick_interval_edt,'String',num2str(option.ax{option.cnt_subfig}.xaxis_tick_interval));
        set(handles.xaxis_tick_anchor_edt,'String',num2str(option.ax{option.cnt_subfig}.xaxis_tick_anchor));
        l=get(handles.ax(option.cnt_subfig),'xaxis');
        if strcmp(option.ax{option.cnt_subfig}.xaxis_visible,'on')
            set(handles.xaxis_hide_chx,'value',0);
            set(handles.xaxis_location_txt,'enable','on');
            set(handles.xaxis_location_pop,'enable','on');
            set(handles.xaxis_tick_chk,'enable','on');
            
            if strcmpi(option.ax{option.cnt_subfig}.XTickMode,'manual')
                set(handles.xaxis_tick_chk,'value',0)
                set(handles.xaxis_tick_interval_txt,'enable','on');
                set(handles.xaxis_tick_interval_edt,'enable','on');
                set(handles.xaxis_tick_anchor_txt,'enable','on');
                set(handles.xaxis_tick_anchor_edt,'enable','on');
            else
                set(handles.xaxis_tick_chk,'value',1)
                set(handles.xaxis_tick_interval_txt,'enable','off');
                set(handles.xaxis_tick_interval_edt,'enable','off');
                set(handles.xaxis_tick_anchor_txt,'enable','off');
                set(handles.xaxis_tick_anchor_edt,'enable','off');
            end
            set(handles.xaxis_minor_tick_chk,'enable','on');
        else
            set(handles.xaxis_hide_chx,'value',1);
            set(handles.xaxis_location_txt,'enable','off');
            set(handles.xaxis_location_pop,'enable','off');
            set(handles.xaxis_tick_chk,'enable','off');
            set(handles.xaxis_tick_interval_edt,'enable','off');
            set(handles.xaxis_tick_anchor_edt,'enable','off');
            set(handles.xaxis_minor_tick_chk,'enable','off');
            set(handles.xaxis_tick_interval_txt,'enable','off');
            set(handles.xaxis_tick_anchor_txt,'enable','off');
        end
        
        if verLessThan('matlab','8.4')
            set(handles.xaxis_hide_chx,'visible','off');
        end
        if strcmp(option.ax{option.cnt_subfig}.XGrid,'on')
            set(handles.xaxis_grid_chk,'value',1);
        else
            set(handles.xaxis_grid_chk,'value',0);
        end
        if strcmp(option.ax{option.cnt_subfig}.XMinorGrid,'on')
            set(handles.xaxis_minor_grid_chk,'value',1);
        else
            set(handles.xaxis_minor_grid_chk,'value',0);
        end
        set(handles.xaxis_label_edt,'string',option.ax{option.cnt_subfig}.xlabel);
        l=get(handles.ax(option.cnt_subfig),'xlabel');
        set(l,'string',option.ax{option.cnt_subfig}.xlabel);
        if strcmp(option.ax{option.cnt_subfig}.xlabel_visible,'on')
            set(l,'visible','on');
            set(handles.xaxis_label_chk,'value',1);
            set(handles.xaxis_label_edt,'enable','on');
        else
            set(l,'visible','off');
            set(handles.xaxis_label_chk,'value',0);
            set(handles.xaxis_label_edt,'enable','off');
        end
        
        %y-axis
        if ~strcmpi(option.ax{option.cnt_subfig}.YlimMode,'auto')
            set (handles.yaxis_limit_chk,'value',1);
            set (handles.yaxis_limit1_edt,'enable','on');
            set (handles.yaxis_limit2_edt,'enable','on');
        else
            set (handles.yaxis_limit_chk,'value',0);
            option.ax{option.cnt_subfig}.Ylim=get(handles.ax(option.cnt_subfig),'Ylim');
            set (handles.yaxis_limit1_edt,'enable','off');
            set (handles.yaxis_limit2_edt,'enable','off');
        end
        set (handles.yaxis_limit1_edt,'string',num2str(option.ax{option.cnt_subfig}.Ylim(1)));
        set (handles.yaxis_limit2_edt,'string',num2str(option.ax{option.cnt_subfig}.Ylim(2)));
        switch option.ax{option.cnt_subfig}.YAxisLocation
            case 'bottom'
                set (handles.yaxis_location_pop,'value',1);
            case 'top'
                set (handles.yaxis_location_pop,'value',2);
            case 'origin'
                if verLessThan('matlab','8.4')
                    set (handles.yaxis_location_pop,'value',1);
                else
                    set (handles.yaxis_location_pop,'value',3);
                end
        end
        if strcmp(option.ax{option.cnt_subfig}.YMinorTick,'on')
            set(handles.yaxis_minor_tick_chk,'value',1);
        else
            set(handles.yaxis_minor_tick_chk,'value',0);
        end
        if isempty(option.ax{option.cnt_subfig}.yaxis_tick_anchor)
            temp=get(handles.ax(option.cnt_subfig),'YTick');
            option.ax{option.cnt_subfig}.yaxis_tick_interval=temp(2)-temp(1);
            option.ax{option.cnt_subfig}.yaxis_tick_anchor=temp(1);
        end
        set(handles.yaxis_tick_interval_edt,'String',num2str(option.ax{option.cnt_subfig}.yaxis_tick_interval));
        set(handles.yaxis_tick_anchor_edt,'String',num2str(option.ax{option.cnt_subfig}.yaxis_tick_anchor));
        l=get(handles.ax(option.cnt_subfig),'yaxis');
        
        if strcmp(option.ax{option.cnt_subfig}.yaxis_visible,'on')
            set(handles.yaxis_hide_chx,'value',0);
            set(handles.yaxis_location_txt,'enable','on');
            set(handles.yaxis_location_pop,'enable','on');
            set(handles.yaxis_tick_chk,'enable','on');
            
            if strcmpi(option.ax{option.cnt_subfig}.YTickMode,'manual')
                set(handles.yaxis_tick_chk,'value',0)
                set(handles.yaxis_tick_interval_txt,'enable','on');
                set(handles.yaxis_tick_interval_edt,'enable','on');
                set(handles.yaxis_tick_anchor_txt,'enable','on');
                set(handles.yaxis_tick_anchor_edt,'enable','on');
            else
                set(handles.yaxis_tick_chk,'value',1)
                set(handles.yaxis_tick_interval_txt,'enable','off');
                set(handles.yaxis_tick_interval_edt,'enable','off');
                set(handles.yaxis_tick_anchor_txt,'enable','off');
                set(handles.yaxis_tick_anchor_edt,'enable','off');
            end
            set(handles.yaxis_minor_tick_chk,'enable','on');
        else
            set(handles.yaxis_hide_chx,'value',1);
            set(handles.yaxis_location_txt,'enable','off');
            set(handles.yaxis_location_pop,'enable','off');
            set(handles.yaxis_tick_chk,'enable','off');
            set(handles.yaxis_tick_interval_edt,'enable','off');
            set(handles.yaxis_tick_anchor_edt,'enable','off');
            set(handles.yaxis_minor_tick_chk,'enable','off');
            set(handles.yaxis_tick_interval_txt,'enable','off');
            set(handles.yaxis_tick_anchor_txt,'enable','off');
        end
        if verLessThan('matlab','8.4')
            set(handles.yaxis_hide_chx,'visible','off');
        end
        if strcmp(option.ax{option.cnt_subfig}.YGrid,'on')
            set(handles.yaxis_grid_chk,'value',1);
        else
            set(handles.yaxis_grid_chk,'value',0);
        end
        if strcmp(option.ax{option.cnt_subfig}.YMinorGrid,'on')
            set(handles.yaxis_minor_grid_chk,'value',1);
        else
            set(handles.yaxis_minor_grid_chk,'value',0);
        end
        
        if strcmpi(option.ax{option.cnt_subfig}.YDir,'reverse')
            set(handles.yaxis_reverse_chk,'value',1);
        else
            set(handles.yaxis_reverse_chk,'value',0);
        end
        
        set(handles.yaxis_label_edt,'string',option.ax{option.cnt_subfig}.ylabel);
        l=get(handles.ax(option.cnt_subfig),'ylabel');
        set(l,'string',option.ax{option.cnt_subfig}.ylabel);
        
        if strcmp(option.ax{option.cnt_subfig}.ylabel_visible,'on')
            set(l,'visible','on');
            set(handles.yaxis_label_chk,'value',1);
            set(handles.yaxis_label_edt,'enable','on');
        else
            set(l,'visible','off');
            set(handles.yaxis_label_chk,'value',0);
            set(handles.yaxis_label_edt,'enable','off');
        end
    end
    function axis_reverse_chk_callback(~,~)
        option.ax{option.cnt_subfig}.axis_reverse=get(handles.axis_reverse_chk,'value');
        if option.ax{option.cnt_subfig}.axis_reverse
            view(handles.ax(option.cnt_subfig),[90 -90]);
        else
            view(handles.ax(option.cnt_subfig),[0,90]);
        end
    end
    function axis_box_chk_callback(~,~)
        if get(handles.axis_box_chk,'value')==1
            option.ax{option.cnt_subfig}.box='on';
            set(handles.ax(option.cnt_subfig),'Box','on');
        else
            option.ax{option.cnt_subfig}.box='off';
            set(handles.ax(option.cnt_subfig),'Box','off');
        end
    end
    function axis_visible_chk_callback(~,~)
        if get(handles.axis_visible_chk,'value')==1
            option.ax{option.cnt_subfig}.visible='on';
            set(handles.ax(option.cnt_subfig),'visible','on');
        else
            option.ax{option.cnt_subfig}.visible='off';
            set(handles.ax(option.cnt_subfig),'visible','off');
        end
    end
    function axis_legend_chk_callback(~,~)
        if get(handles.axis_legend_chk,'value')==1
            if ~isempty(option.ax{option.cnt_subfig}.content)
                set(handles.axis_legend_edt,'visible','on',...
                    'string',option.ax{option.cnt_subfig}.content{option.cnt_content}.name);
            end
            option.ax{option.cnt_subfig}.legend='on';
            idx=[];
            name={};
            for k=1:length(option.ax{option.cnt_subfig}.content)
                if strcmpi(option.ax{option.cnt_subfig}.content{k}.type,'curve')...
                        ||strcmpi(option.ax{option.cnt_subfig}.content{k}.type,'lissajous')
                    idx=[idx,k];
                    name=[name,option.ax{option.cnt_subfig}.content{k}.name];
                end
            end
            if isempty(idx)
                legend(handles.ax(option.cnt_subfig),'off');
            else
                legend([handles.ax_child{option.cnt_subfig}.handle(idx).line],name);
            end
        else
            option.ax{option.cnt_subfig}.legend='off';
            legend(handles.ax(option.cnt_subfig),'off');
            set(handles.axis_legend_edt,'visible','off');
        end
    end
    function axis_legend_edt_callback(~,~)
        option.ax{option.cnt_subfig}.content{option.cnt_content}.name=get(handles.axis_legend_edt,'string');
        content_str=cell(length(option.ax{option.cnt_subfig}.content),1);
        for k=1:length(option.ax{option.cnt_subfig}.content)
            content_str{k}=option.ax{option.cnt_subfig}.content{k}.name;
        end
        set(handles.content_listbox,'string',content_str);
        
        idx=[];
        name={};
        for k=1:length(option.ax{option.cnt_subfig}.content)
            if strcmpi(option.ax{option.cnt_subfig}.content{k}.type,'curve')...
                    ||strcmpi(option.ax{option.cnt_subfig}.content{k}.type,'lissajous')
                idx=[idx,k];
                name=[name,option.ax{option.cnt_subfig}.content{k}.name];
            end
        end
        if isempty(idx)
            legend(handles.ax(option.cnt_subfig),'off');
        else
            legend([handles.ax_child{option.cnt_subfig}.handle(idx).line],name);
        end
    end

    function xaxis_limit_chk_callback(~,~)
        if get(handles.xaxis_limit_chk,'value')==1
            option.ax{option.cnt_subfig}.XlimMode='manual';
            set(handles.ax(option.cnt_subfig),'XlimMode','manual');
            set(handles.xaxis_limit1_edt,'enable','on');
            set(handles.xaxis_limit2_edt,'enable','on');
            xaxis_limit_edt_callback();
        else
            option.ax{option.cnt_subfig}.XlimMode='auto';
            set(handles.ax(option.cnt_subfig),'XlimMode','auto');
            set(handles.xaxis_limit1_edt,'enable','off');
            set(handles.xaxis_limit2_edt,'enable','off');
        end
        content_xyaxis_update();
    end
    function xaxis_limit_edt_callback(~,~)
        if strcmpi(option.ax{option.cnt_subfig}.XlimMode,'manual')
            value_from=str2num(get(handles.xaxis_limit1_edt,'string'));
            value_to=str2num(get(handles.xaxis_limit2_edt,'string'));
            if value_to<value_from
                value_to=str2num(get(handles.xaxis_limit1_edt,'string'));
                value_from=str2num(get(handles.xaxis_limit2_edt,'string'));
            end
            if value_to==value_from
                value_from=value_from-1;
                value_to=value_to+1;
            end
            set(handles.ax(option.cnt_subfig),'xlim',[value_from,value_to]);
            option.ax{option.cnt_subfig}.Xlim=[value_from,value_to];
        end
        if strcmpi(option.ax{option.cnt_subfig}.XTickMode,'manual')
            value1=option.ax{option.cnt_subfig}.xaxis_tick_interval;
            value2=option.ax{option.cnt_subfig}.xaxis_tick_anchor;
            idx=ceil((option.ax{option.cnt_subfig}.Xlim(1)-value2)/value1)*value1+value2:value1:option.ax{option.cnt_subfig}.Xlim(2);
            set(handles.ax(option.cnt_subfig),'XTick',idx);
        end
    end
    function xaxis_hide_chx_callback(~,~)
        l=get(handles.ax(option.cnt_subfig),'xaxis');
        if get(handles.xaxis_hide_chx,'value')
            option.ax{option.cnt_subfig}.xaxis_visible='off';
            set(l,'visible','off');
            set(handles.xaxis_location_txt,'enable','off');
            set(handles.xaxis_location_pop,'enable','off');
            set(handles.xaxis_tick_chk,'enable','off');
            set(handles.xaxis_tick_interval_edt,'enable','off');
            set(handles.xaxis_tick_anchor_edt,'enable','off');
            set(handles.xaxis_minor_tick_chk,'enable','off');
            set(handles.xaxis_tick_interval_txt,'enable','off');
            set(handles.xaxis_tick_anchor_txt,'enable','off');
        else
            option.ax{option.cnt_subfig}.xaxis_visible='on';
            set(l,'visible','on');
            set(handles.xaxis_location_txt,'enable','on');
            set(handles.xaxis_location_pop,'enable','on');
            set(handles.xaxis_tick_chk,'enable','on');
            if strcmpi(option.ax{option.cnt_subfig}.XTickMode,'manual')
                set(handles.xaxis_tick_chk,'value',0)
                set(handles.xaxis_tick_interval_edt,'enable','on');
                set(handles.xaxis_tick_anchor_edt,'enable','on');
                set(handles.xaxis_tick_interval_txt,'enable','on');
                set(handles.xaxis_tick_anchor_txt,'enable','on');
            else
                set(handles.xaxis_tick_chk,'value',1)
                set(handles.xaxis_tick_interval_edt,'enable','off');
                set(handles.xaxis_tick_anchor_edt,'enable','off');
                set(handles.xaxis_tick_interval_txt,'enable','off');
                set(handles.xaxis_tick_anchor_txt,'enable','off');
            end
            set(handles.xaxis_minor_tick_chk,'enable','on');
        end
    end
    function xaxis_location_pop_callback(~,~)
        temp=get(handles.xaxis_location_pop,'value');
        switch temp
            case 1
                option.ax{option.cnt_subfig}.XAxisLocation='bottom';
                set(handles.ax(option.cnt_subfig),'XAxisLocation','bottom');
            case 2
                option.ax{option.cnt_subfig}.XAxisLocation='top';
                set(handles.ax(option.cnt_subfig),'XAxisLocation','top');
            case 3
                option.ax{option.cnt_subfig}.XAxisLocation='origin';
                set(handles.ax(option.cnt_subfig),'XAxisLocation','origin');
        end
    end
    function xaxis_tick_chk_callback(~,~)
        if get(handles.xaxis_tick_chk,'value')==0
            set(handles.ax(option.cnt_subfig),'XTickMode','Manual');
            option.ax{option.cnt_subfig}.XTickMode='Manual';
            
            interval=str2num(get(handles.xaxis_tick_interval_edt,'string'));
            anchor=str2num(get(handles.xaxis_tick_anchor_edt,'string'));
            if ~isempty(interval)&& isfinite(interval)&& interval>0 && ~isempty(anchor) && isfinite(anchor)
                option.ax{option.cnt_subfig}.xaxis_tick_interval=interval;
                option.ax{option.cnt_subfig}.xaxis_tick_anchor=anchor;
                xaxis_limit_edt_callback();
            else
                set(handles.xaxis_tick_interval_edt,'string',num2str(option.ax{option.cnt_subfig}.xaxis_tick_interval));
                set(handles.xaxis_tick_anchor_edt,'string',num2str(option.ax{option.cnt_subfig}.xaxis_tick_anchor));
            end
            set(handles.xaxis_tick_interval_edt,'enable','on');
            set(handles.xaxis_tick_anchor_edt,'enable','on');
            set(handles.xaxis_tick_interval_txt,'enable','on');
            set(handles.xaxis_tick_anchor_txt,'enable','on');
        else
            option.ax{option.cnt_subfig}.XTickMode='auto';
            set(handles.ax(option.cnt_subfig),'XTickMode','auto');
            set(handles.xaxis_tick_interval_edt,'enable','off');
            set(handles.xaxis_tick_anchor_edt,'enable','off');
            set(handles.xaxis_tick_interval_txt,'enable','off');
            set(handles.xaxis_tick_anchor_txt,'enable','off');
        end
    end
    function xaxis_minor_tick_chk_callback(~,~)
        if get(handles.xaxis_minor_tick_chk,'value')==1
            option.ax{option.cnt_subfig}.XMinorTick='on';
            set(handles.ax(option.cnt_subfig),'XMinorTick','on');
        else
            option.ax{option.cnt_subfig}.XMinorTick='off';
            set(handles.ax(option.cnt_subfig),'XMinorTick','off');
        end
    end
    function xaxis_grid_chk_callback(~,~)
        if get(handles.xaxis_grid_chk,'value')==1
            option.ax{option.cnt_subfig}.XGrid='on';
            set(handles.ax(option.cnt_subfig),'XGrid','on');
        else
            option.ax{option.cnt_subfig}.XGrid='off';
            set(handles.ax(option.cnt_subfig),'XGrid','off');
        end
    end
    function xaxis_minor_grid_chk_callback(~,~)
        if get(handles.xaxis_minor_grid_chk,'value')==1
            option.ax{option.cnt_subfig}.XMinorGrid='on';
            set(handles.ax(option.cnt_subfig),'XMinorGrid','on');
        else
            option.ax{option.cnt_subfig}.XMinorGrid='off';
            set(handles.ax(option.cnt_subfig),'XMinorGrid','off');
        end
    end
    function xaxis_label_chk_callback(~,~)
        l=get(handles.ax(option.cnt_subfig),'xlabel');
        if get(handles.xaxis_label_chk,'value')==1
            option.ax{option.cnt_subfig}.xlabel_visible='on';
            set(l,'visible','on');
            set(handles.xaxis_label_edt,'enable','on');
        else
            option.ax{option.cnt_subfig}.xlabel_visible='off';
            set(l,'visible','off');
            set(handles.xaxis_label_edt,'enable','off');
        end
    end
    function xaxis_label_edt_callback(~,~)
        l=get(handles.ax(option.cnt_subfig),'xlabel');
        str=get(handles.xaxis_label_edt,'string');
        option.ax{option.cnt_subfig}.xlabel=str;
        set(l,'string',str);
    end

    function yaxis_limit_chk_callback(~,~)
        if get(handles.yaxis_limit_chk,'value')==1
            option.ax{option.cnt_subfig}.YlimMode='manual';
            set(handles.ax(option.cnt_subfig),'YlimMode','manual');
            set(handles.yaxis_limit1_edt,'enable','on');
            set(handles.yaxis_limit2_edt,'enable','on');
            yaxis_limit_edt_callback();
        else
            option.ax{option.cnt_subfig}.YlimMode='auto';
            set(handles.ax(option.cnt_subfig),'YlimMode','auto');
            set(handles.yaxis_limit1_edt,'enable','off');
            set(handles.yaxis_limit2_edt,'enable','off');
        end
        content_xyaxis_update();
    end
    function yaxis_limit_edt_callback(~,~)
        if strcmpi(option.ax{option.cnt_subfig}.YlimMode,'manual')
            value_from=str2num(get(handles.yaxis_limit1_edt,'string'));
            value_to=str2num(get(handles.yaxis_limit2_edt,'string'));
            if value_to<value_from
                value_to=str2num(get(handles.yaxis_limit1_edt,'string'));
                value_from=str2num(get(handles.yaxis_limit2_edt,'string'));
            end
            if value_to==value_from
                value_from=value_from-1;
                value_to=value_to+1;
            end
            set(handles.ax(option.cnt_subfig),'ylim',[value_from,value_to]);
            option.ax{option.cnt_subfig}.Ylim=[value_from,value_to];
        end
        if strcmpi(option.ax{option.cnt_subfig}.YTickMode,'manual')
            value1=option.ax{option.cnt_subfig}.yaxis_tick_interval;
            value2=option.ax{option.cnt_subfig}.yaxis_tick_anchor;
            idx=ceil((option.ax{option.cnt_subfig}.Ylim(1)-value2)/value1)*value1+value2:value1:option.ax{option.cnt_subfig}.Ylim(2);
            set(handles.ax(option.cnt_subfig),'YTick',idx);
        end
    end
    function yaxis_hide_chx_callback(~,~)
        l=get(handles.ax(option.cnt_subfig),'yaxis');
        if get(handles.yaxis_hide_chx,'value')
            option.ax{option.cnt_subfig}.yaxis_visible='off';
            set(l,'visible','off');
            set(handles.yaxis_location_txt,'enable','off');
            set(handles.yaxis_location_pop,'enable','off');
            set(handles.yaxis_tick_chk,'enable','off');
            set(handles.yaxis_tick_interval_edt,'enable','off');
            set(handles.yaxis_tick_anchor_edt,'enable','off');
            set(handles.yaxis_minor_tick_chk,'enable','off');
            set(handles.yaxis_tick_interval_txt,'enable','off');
            set(handles.yaxis_tick_anchor_txt,'enable','off');
        else
            option.ax{option.cnt_subfig}.yaxis_visible='on';
            set(l,'visible','on');
            set(handles.yaxis_location_txt,'enable','on');
            set(handles.yaxis_location_pop,'enable','on');
            set(handles.yaxis_tick_chk,'enable','on');
            if strcmpi(option.ax{option.cnt_subfig}.YTickMode,'manual')
                set(handles.yaxis_tick_chk,'value',0)
                set(handles.yaxis_tick_interval_edt,'enable','on');
                set(handles.yaxis_tick_anchor_edt,'enable','on');
                set(handles.yaxis_tick_interval_txt,'enable','on');
                set(handles.yaxis_tick_anchor_txt,'enable','on');
            else
                set(handles.yaxis_tick_chk,'value',1)
                set(handles.yaxis_tick_interval_edt,'enable','off');
                set(handles.yaxis_tick_anchor_edt,'enable','off');
                set(handles.yaxis_tick_interval_txt,'enable','off');
                set(handles.yaxis_tick_anchor_txt,'enable','off');
            end
            set(handles.yaxis_minor_tick_chk,'enable','on');
        end
    end
    function yaxis_location_pop_callback(~,~)
        temp=get(handles.yaxis_location_pop,'value');
        switch temp
            case 1
                option.ax{option.cnt_subfig}.YAxisLocation='left';
                set(handles.ax(option.cnt_subfig),'YAxisLocation','left');
            case 2
                option.ax{option.cnt_subfig}.YAxisLocation='right';
                set(handles.ax(option.cnt_subfig),'YAxisLocation','right');
            case 3
                option.ax{option.cnt_subfig}.YAxisLocation='origin';
                set(handles.ax(option.cnt_subfig),'YAxisLocation','origin');
        end
    end
    function yaxis_tick_chk_callback(~,~)
        if get(handles.yaxis_tick_chk,'value')==0
            set(handles.ax(option.cnt_subfig),'YTickMode','Manual');
            option.ax{option.cnt_subfig}.YTickMode='Manual';
            option.ax{option.cnt_subfig}.yaxis_tick_interval=str2num(get(handles.yaxis_tick_interval_edt,'string'));
            option.ax{option.cnt_subfig}.yaxis_tick_anchor=str2num(get(handles.yaxis_tick_anchor_edt,'string'));
            yaxis_limit_edt_callback();
            set(handles.yaxis_tick_interval_edt,'enable','on');
            set(handles.yaxis_tick_anchor_edt,'enable','on');
            set(handles.yaxis_tick_interval_txt,'enable','on');
            set(handles.yaxis_tick_anchor_txt,'enable','on');
        else
            option.ax{option.cnt_subfig}.XTickMode='auto';
            set(handles.ax(option.cnt_subfig),'YTickMode','auto');
            set(handles.yaxis_tick_interval_edt,'enable','off');
            set(handles.yaxis_tick_anchor_edt,'enable','off');
            set(handles.yaxis_tick_interval_txt,'enable','off');
            set(handles.yaxis_tick_anchor_txt,'enable','off');
        end
    end
    function yaxis_minor_tick_chk_callback(~,~)
        if get(handles.yaxis_minor_tick_chk,'value')==1
            option.ax{option.cnt_subfig}.YMinorTick='on';
            set(handles.ax(option.cnt_subfig),'YMinorTick','on');
        else
            option.ax{option.cnt_subfig}.YMinorTick='off';
            set(handles.ax(option.cnt_subfig),'YMinorTick','off');
        end
    end
    function yaxis_grid_chk_callback(~,~)
        if get(handles.yaxis_grid_chk,'value')==1
            option.ax{option.cnt_subfig}.YGrid='on';
            set(handles.ax(option.cnt_subfig),'YGrid','on');
        else
            option.ax{option.cnt_subfig}.YGrid='off';
            set(handles.ax(option.cnt_subfig),'YGrid','off');
        end
    end
    function yaxis_minor_grid_chk_callback(~,~)
        if get(handles.yaxis_minor_grid_chk,'value')==1
            option.ax{option.cnt_subfig}.YMinorGrid='on';
            set(handles.ax(option.cnt_subfig),'YMinorGrid','on');
        else
            option.ax{option.cnt_subfig}.YMinorGrid='off';
            set(handles.ax(option.cnt_subfig),'YMinorGrid','off');
        end
    end
    function yaxis_label_chk_callback(~,~)
        l=get(handles.ax(option.cnt_subfig),'ylabel');
        if get(handles.yaxis_label_chk,'value')==1
            option.ax{option.cnt_subfig}.ylabel_visible='on';
            set(l,'visible','on');
            set(handles.yaxis_label_edt,'enable','on');
        else
            option.ax{option.cnt_subfig}.ylabel_visible='off';
            set(l,'visible','off');
            set(handles.yaxis_label_edt,'enable','off');
        end
    end
    function yaxis_label_edt_callback(~,~)
        l=get(handles.ax(option.cnt_subfig),'ylabel');
        str=get(handles.yaxis_label_edt,'string');
        option.ax{option.cnt_subfig}.ylabel=str;
        set(l,'string',str);
    end
    function yaxis_reverse_chk_callback(~,~)
        if get(handles.yaxis_reverse_chk,'value')==0
            option.ax{option.cnt_subfig}.YDir='normal';
            set(handles.ax(option.cnt_subfig),'YDir','normal');
        else
            option.ax{option.cnt_subfig}.YDir='reverse';
            set(handles.ax(option.cnt_subfig),'YDir','reverse');
        end
    end
    function content_xyaxis_update()
        if strcmpi(option.ax{option.cnt_subfig}.XlimMode,'auto')
            set (handles.xaxis_limit1_edt,'string',num2str(option.ax{option.cnt_subfig}.Xlim(1)));
            set (handles.xaxis_limit2_edt,'string',num2str(option.ax{option.cnt_subfig}.Xlim(2)));
        end
        if strcmpi(option.ax{option.cnt_subfig}.YlimMode,'auto')
            set (handles.yaxis_limit1_edt,'string',num2str(option.ax{option.cnt_subfig}.Ylim(1)));
            set (handles.yaxis_limit2_edt,'string',num2str(option.ax{option.cnt_subfig}.Ylim(2)));
        end
    end

%% panel_content function
    function content_callback(~,~)
        if strcmpi(option.ax{option.cnt_subfig}.style,'Topograph')
            set(handles.panel_content_manager,'visible','off');
        else
            set(handles.panel_content_manager,'visible','on');
        end
        value_content=get(handles.content_add_pop,'value');
        str_content=get(handles.content_add_pop,'string');
        str_content=str_content{value_content};
        switch(option.ax{option.cnt_subfig}.style)
            case 'Curve'
                %set(handles.content_add_pop,'String',{'curve','lissajous','average','all_epoch','all_channel','std','line','rect','text'});
                set(handles.content_add_pop,'String',{'curve','lissajous','line','rect','text'});
            case 'Image'
                set(handles.content_add_pop,'String',{'line','rect','text'});
            case 'Topograph'
        end
        str=get(handles.content_add_pop,'String');
        [~,~,value_content]=intersect(str_content,str,'stable');
        if isempty(value_content)
            value_content=1;
        end
        set(handles.content_add_pop,'value',value_content);
    end
    function content_add_callback(~,~)
        value_content=get(handles.content_add_pop,'value');
        str_content=get(handles.content_add_pop,'string');
        str_content=str_content{value_content};
        option.cnt_content=length(option.ax{option.cnt_subfig}.content)+1;
        option.ax{option.cnt_subfig}.content{option.cnt_content}.name=[str_content,num2str(option.ax{option.cnt_subfig}.content_order)];
        option.ax{option.cnt_subfig}.content{option.cnt_content}.type=str_content;
        
        switch(str_content)
            case 'curve'
                get_content_curve_default();
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line=line(...
                    'Parent',handles.ax(option.cnt_subfig));
            case 'lissajous'
                get_content_lissajous_default();
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line=line('Parent',handles.ax(option.cnt_subfig));
            case 'line'
                get_content_line_default();
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line=line('Parent',handles.ax(option.cnt_subfig));
            case 'rect'
                get_content_rect_default();
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).rect=fill(...
                    [0,1,0],[0,1,0],[0.5,0.5,0.5],'Parent',handles.ax(option.cnt_subfig));
            case 'text'
                get_content_text_default();
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text=text('parent',handles.ax(option.cnt_subfig));
            case 'average'
                get_content_average_default();
                handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line=line(...
                    'Parent',handles.ax(option.cnt_subfig));
        end
        option.ax{option.cnt_subfig}.content_order=option.ax{option.cnt_subfig}.content_order+1;
        
        if strcmpi(option.ax{option.cnt_subfig}.legend,'on')
            idx=[];
            name={};
            for k=1:length(option.ax{option.cnt_subfig}.content)
                if strcmpi(option.ax{option.cnt_subfig}.content{k}.type,'curve')...
                        ||strcmpi(option.ax{option.cnt_subfig}.content{k}.type,'lissajous')
                    idx=[idx,k];
                    name=[name,option.ax{option.cnt_subfig}.content{k}.name];
                end
            end
            if isempty(idx)
                legend(handles.ax(option.cnt_subfig),'off');
            else
                legend([handles.ax_child{option.cnt_subfig}.handle(idx).line],name);
            end
        end
        fig1_callback();
        legend(handles.ax(option.cnt_subfig),'off');
        axis_legend_chk_callback();
    end
    function content_del_callback(~,~)
        if isempty(option.ax{option.cnt_subfig}.content)
            return;
        end
        if ~strcmpi(option.ax{option.cnt_subfig}.style,'Curve') && option.cnt_content==1
            return;
        end
        value_curve=option.cnt_content;
        switch(option.ax{option.cnt_subfig}.content{value_curve}.type)
            case 'curve'
                delete(handles.ax_child{option.cnt_subfig}.handle(value_curve).line);
            case 'lissajous'
                delete(handles.ax_child{option.cnt_subfig}.handle(value_curve).line);
            case 'line'
                delete(handles.ax_child{option.cnt_subfig}.handle(value_curve).line);
            case 'average'
                delete(handles.ax_child{option.cnt_subfig}.handle(value_curve).line);
            case 'rect'
                delete(handles.ax_child{option.cnt_subfig}.handle(value_curve).rect);
            case 'text'
                delete(handles.ax_child{option.cnt_subfig}.handle(value_curve).text);
        end
        handles.ax_child{option.cnt_subfig}.handle(value_curve)=[];
        option.ax{option.cnt_subfig}.content(value_curve)=[];
        option.cnt_content=min(option.cnt_content,length(option.ax{option.cnt_subfig}.content));
        fig1_callback();
        legend(handles.ax(option.cnt_subfig),'off');
        axis_legend_chk_callback();
    end
    function content_up_callback(~,~)
        if option.cnt_content==1
            return;
        end
        if ~strcmpi(option.ax{option.cnt_subfig}.style,'Curve') && option.cnt_content==2
            return;
        end
        
        value_curve=option.cnt_content;
        index=[1:value_curve-2,value_curve,value_curve-1,value_curve+1:length(option.ax{option.cnt_subfig}.content)];
        option.ax{option.cnt_subfig}.content=option.ax{option.cnt_subfig}.content(index);
        handles.ax_child{option.cnt_subfig}.handle=handles.ax_child{option.cnt_subfig}.handle(index);
        temp=get(handles.ax(option.cnt_subfig),'Children');
        value_curve=length(option.ax{option.cnt_subfig}.content)-value_curve;
        temp=temp([1:value_curve,value_curve+2,value_curve+1,value_curve+3:end]);
        set(handles.ax(option.cnt_subfig),'Children',temp);
        option.cnt_content=option.cnt_content-1;
        fig1_callback();
        legend(handles.ax(option.cnt_subfig),'off');
        axis_legend_chk_callback();
    end
    function content_down_callback(~,~)
        if option.cnt_content==length(option.ax{option.cnt_subfig}.content)
            return;
        end
        if ~strcmpi(option.ax{option.cnt_subfig}.style,'Curve') && option.cnt_content==1
            return;
        end
        
        value_curve=option.cnt_content;
        index=[1:value_curve-1,value_curve+1,value_curve,value_curve+2:length(option.ax{option.cnt_subfig}.content)];
        option.ax{option.cnt_subfig}.content=option.ax{option.cnt_subfig}.content(index);
        handles.ax_child{option.cnt_subfig}.handle=handles.ax_child{option.cnt_subfig}.handle(index);
        temp=get(handles.ax(option.cnt_subfig),'Children');
        value_curve=length(option.ax{option.cnt_subfig}.content)-value_curve;
        temp=temp([1:value_curve-1,value_curve+1,value_curve,value_curve+2:end]);
        set(handles.ax(option.cnt_subfig),'Children',temp);
        option.cnt_content=option.cnt_content+1;
        fig1_callback();
        
        legend(handles.ax(option.cnt_subfig),'off');
        axis_legend_chk_callback();
    end

%% panel_curve function
    function curve_callback()
        curve_update();
        c=option.ax{option.cnt_subfig}.content{option.cnt_content}.color;
        set(handles.panel_curve_color_btn,'foregroundcolor',c);
        set(handles.panel_curve_color_btn,'string',['[',num2str(c(1),'%0.2g'),',',num2str(c(2),'%0.2g'),',',num2str(c(3),'%0.2g'),']']);
        set(handles.panel_curve_width_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth));
        switch option.ax{option.cnt_subfig}.content{option.cnt_content}.style
            case '-'
                set(handles.panel_curve_style_pop,'value',1);
            case '--'
                set(handles.panel_curve_style_pop,'value',2);
            case ':'
                set(handles.panel_curve_style_pop,'value',3);
            case '-.'
                set(handles.panel_curve_style_pop,'value',4);
            case 'none'
                set(handles.panel_curve_style_pop,'value',5);
        end
        switch option.ax{option.cnt_subfig}.content{option.cnt_content}.marker
            case 'none'
                set(handles.panel_curve_marker_pop,'value',1);
            case 'o'
                set(handles.panel_curve_marker_pop,'value',2);
            case '+'
                set(handles.panel_curve_marker_pop,'value',3);
            case '*'
                set(handles.panel_curve_marker_pop,'value',4);
            case '.'
                set(handles.panel_curve_marker_pop,'value',5);
            case 'x'
                set(handles.panel_curve_marker_pop,'value',6);
            case 's'
                set(handles.panel_curve_marker_pop,'value',7);
            case 'd'
                set(handles.panel_curve_marker_pop,'value',8);
            case '^'
                set(handles.panel_curve_marker_pop,'value',9);
            case 'v'
                set(handles.panel_curve_marker_pop,'value',10);
            case '>'
                set(handles.panel_curve_marker_pop,'value',11);
            case '<'
                set(handles.panel_curve_marker_pop,'value',12);
            case 'p'
                set(handles.panel_curve_marker_pop,'value',13);
            case 'h'
                set(handles.panel_curve_marker_pop,'value',14);
        end
        
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset;
        set(handles.panel_curve_source_pop,'value',k);
        
        if datasets_header(k).header.datasize(1)==1
            set(handles.panel_curve_source_epoch_txt,'visible','off');
            set(handles.panel_curve_source_epoch_pop,'visible','off');
        else
            set(handles.panel_curve_source_epoch_txt,'visible','on');
            set(handles.panel_curve_source_epoch_pop,'visible','on');
            set(handles.panel_curve_source_epoch_pop,'string',cellstr(num2str([1:datasets_header(k).header.datasize(1)]')));
            set(handles.panel_curve_source_epoch_pop,'value',option.ax{option.cnt_subfig}.content{option.cnt_content}.ep);
        end
        
        if datasets_header(k).header.datasize(2)==1
            set(handles.panel_curve_source_channel_txt,'visible','off');
            set(handles.panel_curve_source_channel_pop,'visible','off');
        else
            set(handles.panel_curve_source_channel_txt,'visible','on');
            set(handles.panel_curve_source_channel_pop,'visible','on');
            set(handles.panel_curve_source_channel_pop,'string',{datasets_header(k).header.chanlocs.labels});
            ch_idx=1;
            for l=1:length({datasets_header(k).header.chanlocs.labels})
                if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.ch,...
                        datasets_header(k).header.chanlocs(l).labels)
                    ch_idx=l;
                    break;
                end
            end
            set(handles.panel_curve_source_channel_pop,'value',ch_idx);
        end
        
        if datasets_header(k).header.datasize(3)==1
            set(handles.panel_curve_source_index_txt,'visible','off');
            set(handles.panel_curve_source_index_pop,'visible','off');
        else
            set(handles.panel_curve_source_index_txt,'visible','on');
            set(handles.panel_curve_source_index_pop,'visible','on');
            set(handles.panel_curve_source_index_pop,'string',datasets_header(k).header.index_labels);
            set(handles.panel_curve_source_index_pop,'value',option.ax{option.cnt_subfig}.content{option.cnt_content}.idx);
        end
        if datasets_header(k).header.datasize(4)==1
            set(handles.panel_curve_source_z_txt,'visible','off');
            set(handles.panel_curve_source_z_edt,'visible','off');
        else
            set(handles.panel_curve_source_z_txt,'visible','on');
            set(handles.panel_curve_source_z_edt,'visible','on');
            set(handles.panel_curve_source_z_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.z));
        end
        
        if datasets_header(k).header.datasize(5)==1
            set(handles.panel_curve_source_y_txt,'visible','off');
            set(handles.panel_curve_source_y_edt,'visible','off');
        else
            set(handles.panel_curve_source_y_txt,'visible','on');
            set(handles.panel_curve_source_y_edt,'visible','on');
            set(handles.panel_curve_source_y_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.y));
        end
    end
    function curve_update()
        if ~strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.type,'curve')
            return;
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset=min(length(datasets_header),...
            option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset);
        header=datasets_header(option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset).header;
        x=(0:header.datasize(6)-1)*header.xstep+header.xstart;
        i_pos=1;
        y_pos=1;
        z_pos=1;
        if header.datasize(5)~=1
            y_pos=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.y-header.ystart)/header.ystep)+1);
            if y_pos<1
                y_pos=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.y=header.ystart;
            end
            if y_pos>header.datasize(5)
                y_pos=header.datasize(5);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.y=header.ystart+(header.datasize(5)-1)*header.ystep;
            end
        end
        if header.datasize(4)~=1
            z_pos=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.z-header.zstart)/header.zstep)+1);
            if z_pos<1
                z_pos=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.z=header.zstart;
            end
            if z_pos>header.datasize(4)
                z_pos=header.datasize(4);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.z=header.zstart+(header.datasize(4)-1)*header.zstep;
            end
        end
        if header.datasize(3)~=1
            i_pos=option.ax{option.cnt_subfig}.content{option.cnt_content}.idx;
            if i_pos>header.datasize(3)
                i_pos=header.datasize(3);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=i_pos;
            end
        end
        ch_idx=1;
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset;
        for l=1:length({datasets_header(k).header.chanlocs.labels})
            if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.ch,...
                    datasets_header(k).header.chanlocs(l).labels)
                ch_idx=l;
                break;
            end
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ch=datasets_header(k).header.chanlocs(ch_idx).labels;
        y=squeeze(datasets_data(k).data(...
            option.ax{option.cnt_subfig}.content{option.cnt_content}.ep,...
            ch_idx,i_pos,z_pos,y_pos,:));
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line,...
            'XData',x,'YData',y,...
            'linewidth',option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth,...
            'linestyle',option.ax{option.cnt_subfig}.content{option.cnt_content}.style,...
            'marker',option.ax{option.cnt_subfig}.content{option.cnt_content}.marker,...
            'color',option.ax{option.cnt_subfig}.content{option.cnt_content}.color);
        content_xyaxis_update();
    end
    function curve_color_btn_callback(~,~)
        c = uisetcolor(option.ax{option.cnt_subfig}.content{option.cnt_content}.color);
        option.ax{option.cnt_subfig}.content{option.cnt_content}.color=c;
        curve_callback();
    end
    function curve_width_edt_callback(~,~)
        c=str2num(get(handles.panel_curve_width_edt,'string'));
        if ~isempty(c) && isfinite(c) && c>0
            option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth=c;
        end
        curve_callback();
    end
    function curve_style_pop_callback(~,~)
        c=get(handles.panel_curve_style_pop,'value');
        switch c
            case 1
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='-';
            case 2
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='--';
            case 3
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style=':';
            case 4
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='-.';
            case 5
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='none';
        end
        curve_callback();
    end
    function curve_marker_pop_callback(~,~)
        c=get(handles.panel_curve_marker_pop,'value');
        switch c
            case 1
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='none';
            case 2
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='o';
            case 3
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='+';
            case 4
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='*';
            case 5
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='.';
            case 6
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='x';
            case 7
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='s';
            case 8
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='d';
            case 9
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='^';
            case 10
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='v';
            case 11
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='>';
            case 12
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='<';
            case 13
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='p';
            case 14
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='h';
        end
        curve_callback();
    end
    function curve_source_pop_callback(~,~)
        % dataset
        k=get(handles.panel_curve_source_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset=k;
        header=datasets_header(k).header;
        
        % epoch
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ep=...
            min(option.ax{option.cnt_subfig}.content{option.cnt_content}.ep,header.datasize(1));
        
        % channel
        set(handles.panel_curve_source_channel_pop,'string',{datasets_header(k).header.chanlocs.labels});
        ch_idx=1;
        for l=1:length({datasets_header(k).header.chanlocs.labels})
            if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.ch,...
                    datasets_header(k).header.chanlocs(l).labels)
                ch_idx=l;
                break;
            end
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ch=...
            datasets_header(k).header.chanlocs(ch_idx).labels;
        
        % index
        if datasets_header(k).header.datasize(3)==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=1;
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=...
                min(option.ax{option.cnt_subfig}.content{option.cnt_content}.idx,header.datasize(3));
        end
        curve_callback();
    end
    function curve_source_epoch_pop_callback(~,~)
        k=get(handles.panel_curve_source_epoch_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ep=k;
        curve_callback();
    end
    function curve_source_channel_pop_callback(~,~)
        k=get(handles.panel_curve_source_channel_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ch=...
            datasets_header(option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset).header.chanlocs(k).labels;
        curve_callback();
    end
    function curve_source_index_pop_callback(~,~)
        k=get(handles.panel_curve_source_index_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=k;
        curve_callback();
    end
    function curve_source_z_edt_callback(~,~)
        temp=str2double(get(handles.panel_curve_source_z_edt,'String'));
        if ~isempty(temp) && isfinite(temp)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.z=temp;
        end
        curve_callback();
    end
    function curve_source_y_edt_callback(~,~)
        temp=str2double(get(handles.panel_curve_source_y_edt,'String'));
        if ~isempty(temp) && isfinite(temp)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.y=temp;
        end
        curve_callback();
    end

%% panel_line function
    function line_callback()
        line_update();
        c=option.ax{option.cnt_subfig}.content{option.cnt_content}.color;
        set(handles.panel_line_color_btn,'foregroundcolor',c);
        set(handles.panel_line_color_btn,'string',['[',num2str(c(1),'%0.2g'),',',num2str(c(2),'%0.2g'),',',num2str(c(3),'%0.2g'),']']);
        set(handles.panel_line_width_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth));
        switch option.ax{option.cnt_subfig}.content{option.cnt_content}.style
            case '-'
                set(handles.panel_line_style_pop,'value',1);
            case '--'
                set(handles.panel_line_style_pop,'value',2);
            case ':'
                set(handles.panel_line_style_pop,'value',3);
            case '-.'
                set(handles.panel_line_style_pop,'value',4);
            case 'none'
                set(handles.panel_line_style_pop,'value',5);
        end
        switch option.ax{option.cnt_subfig}.content{option.cnt_content}.marker
            case 'none'
                set(handles.panel_line_marker_pop,'value',1);
            case 'o'
                set(handles.panel_line_marker_pop,'value',2);
            case '+'
                set(handles.panel_line_marker_pop,'value',3);
            case '*'
                set(handles.panel_line_marker_pop,'value',4);
            case '.'
                set(handles.panel_line_marker_pop,'value',5);
            case 'x'
                set(handles.panel_line_marker_pop,'value',6);
            case 's'
                set(handles.panel_line_marker_pop,'value',7);
            case 'd'
                set(handles.panel_line_marker_pop,'value',8);
            case '^'
                set(handles.panel_line_marker_pop,'value',9);
            case 'v'
                set(handles.panel_line_marker_pop,'value',10);
            case '>'
                set(handles.panel_line_marker_pop,'value',11);
            case '<'
                set(handles.panel_line_marker_pop,'value',12);
            case 'p'
                set(handles.panel_line_marker_pop,'value',13);
            case 'h'
                set(handles.panel_line_marker_pop,'value',14);
        end
        set(handles.panel_line_x1_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.x(1)));
        set(handles.panel_line_y1_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.y(1)));
        set(handles.panel_line_x2_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.x(2)));
        set(handles.panel_line_y2_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.y(2)));
    end
    function line_update()
        if ~strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.type,'line')
            return;
        end
        if isempty(option.ax{option.cnt_subfig}.content{option.cnt_content}.x)
            x=get(handles.ax(option.cnt_subfig),'XLim');
            option.ax{option.cnt_subfig}.content{option.cnt_content}.x=[mean(x),mean(x)];
            y=get(handles.ax(option.cnt_subfig),'YLim');
            option.ax{option.cnt_subfig}.content{option.cnt_content}.y=y;
        end
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line,...
            'XData',option.ax{option.cnt_subfig}.content{option.cnt_content}.x,...
            'YData',option.ax{option.cnt_subfig}.content{option.cnt_content}.y,...
            'linewidth',option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth,...
            'color',option.ax{option.cnt_subfig}.content{option.cnt_content}.color,...
            'linestyle',option.ax{option.cnt_subfig}.content{option.cnt_content}.style,...
            'marker',option.ax{option.cnt_subfig}.content{option.cnt_content}.marker);
        content_xyaxis_update();
    end
    function line_color_btn_callback(~,~)
        option.ax{option.cnt_subfig}.content{option.cnt_content}.color=...
            uisetcolor(option.ax{option.cnt_subfig}.content{option.cnt_content}.color);
        line_callback();
    end
    function line_width_edt_callback(~,~)
        c=str2num(get(handles.panel_line_width_edt,'string'));
        if ~isempty(c) && isfinite(c) && c>0
            option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth=c;
        end
        line_callback();
    end
    function line_style_pop_callback(~,~)
        c=get(handles.panel_line_style_pop,'value');
        switch c
            case 1
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='-';
            case 2
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='--';
            case 3
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style=':';
            case 4
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='-.';
            case 5
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='none';
        end
        line_callback();
    end
    function line_marker_pop_callback(~,~)
        c=get(handles.panel_line_marker_pop,'value');
        switch c
            case 1
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='none';
            case 2
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='o';
            case 3
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='+';
            case 4
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='*';
            case 5
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='.';
            case 6
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='x';
            case 7
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='s';
            case 8
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='d';
            case 9
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='^';
            case 10
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='v';
            case 11
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='>';
            case 12
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='<';
            case 13
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='p';
            case 14
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='h';
        end
        line_callback();
    end
    function line_xy_edt_callback(~,~)
        x1=str2num(get(handles.panel_line_x1_edt,'string'));
        y1=str2num(get(handles.panel_line_y1_edt,'string'));
        x2=str2num(get(handles.panel_line_x2_edt,'string'));
        y2=str2num(get(handles.panel_line_y2_edt,'string'));
        option.ax{option.cnt_subfig}.content{option.cnt_content}.x=[x1,x2];
        option.ax{option.cnt_subfig}.content{option.cnt_content}.y=[y1,y2];
        line_callback();
    end

%% panel_rect function
    function rect_callback()
        rect_update();
        c=option.ax{option.cnt_subfig}.content{option.cnt_content}.FaceColor;
        set(handles.panel_rect_facecolor_btn,'foregroundcolor',c);
        set(handles.panel_rect_facecolor_btn,'string',['[',num2str(c(1),'%0.2g'),',',num2str(c(2),'%0.2g'),',',num2str(c(3),'%0.2g'),']']);
        c=option.ax{option.cnt_subfig}.content{option.cnt_content}.EdgeColor;
        set(handles.panel_rect_edgecolor_btn,'foregroundcolor',c);
        set(handles.panel_rect_edgecolor_btn,'string',['[',num2str(c(1),'%0.2g'),',',num2str(c(2),'%0.2g'),',',num2str(c(3),'%0.2g'),']']);
        
        set(handles.panel_rect_width_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth));
        set(handles.panel_rect_facealpha_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.FaceAlpha));
        set(handles.panel_rect_edgealpha_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.EdgeAlpha));
        
        set(handles.panel_rect_x_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.x));
        set(handles.panel_rect_y_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.y));
        set(handles.panel_rect_w_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.w));
        set(handles.panel_rect_h_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.h));
    end
    function rect_update()
        if ~strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.type,'rect')
            return;
        end
        if isempty(option.ax{option.cnt_subfig}.content{option.cnt_content}.x)
            x=get(handles.ax(option.cnt_subfig),'XLim');
            y=get(handles.ax(option.cnt_subfig),'YLim');
            w=(x(2)-x(1))/2;x(1)=x(1)+w/2;x(2)=x(1)+w;
            h=(y(2)-y(1))/2;y(1)=y(1)+h/2;y(2)=y(1)+h;
            option.ax{option.cnt_subfig}.content{option.cnt_content}.x=x(1);
            option.ax{option.cnt_subfig}.content{option.cnt_content}.y=y(1);
            option.ax{option.cnt_subfig}.content{option.cnt_content}.w=w;
            option.ax{option.cnt_subfig}.content{option.cnt_content}.h=h;
        else
            x(1)=option.ax{option.cnt_subfig}.content{option.cnt_content}.x;
            x(2)=option.ax{option.cnt_subfig}.content{option.cnt_content}.x...
                +option.ax{option.cnt_subfig}.content{option.cnt_content}.w;
            y(1)=option.ax{option.cnt_subfig}.content{option.cnt_content}.y;
            y(2)=option.ax{option.cnt_subfig}.content{option.cnt_content}.y...
                +option.ax{option.cnt_subfig}.content{option.cnt_content}.h;
        end
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).rect,...
            'XData',[x(1),x(2),x(2),x(1),x(1)],...
            'YData',[y(1),y(1),y(2),y(2),y(1)],...
            'FaceColor',option.ax{option.cnt_subfig}.content{option.cnt_content}.FaceColor,...
            'FaceAlpha',option.ax{option.cnt_subfig}.content{option.cnt_content}.FaceAlpha,...
            'EdgeColor',option.ax{option.cnt_subfig}.content{option.cnt_content}.EdgeColor);
        
        
        c=option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth;
        if c==0
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).rect,'EdgeAlpha',0);
        else
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).rect,'LineWidth',c,...
                'EdgeAlpha',option.ax{option.cnt_subfig}.content{option.cnt_content}.EdgeAlpha);
        end
        content_xyaxis_update();
    end
    function rect_facecolor_btn_callback(~,~)
        option.ax{option.cnt_subfig}.content{option.cnt_content}.FaceColor= ...
            uisetcolor(option.ax{option.cnt_subfig}.content{option.cnt_content}.FaceColor);
        rect_callback();
    end
    function rect_edgecolor_btn_callback(~,~)
        option.ax{option.cnt_subfig}.content{option.cnt_content}.EdgeColor=...
            uisetcolor(option.ax{option.cnt_subfig}.content{option.cnt_content}.EdgeColor);
        rect_callback();
    end
    function rect_width_edt_callback(~,~)
        c=str2num(get(handles.panel_rect_width_edt,'string'));
        if ~isempty(c) && isfinite(c) && c>0
            option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth=c;
        end
        rect_callback();
    end
    function rect_feacalpha_edt_callback(~,~)
        c=str2num(get(handles.panel_rect_facealpha_edt,'string'));
        if ~isempty(c) && isfinite(c)
            if c>1
                c=1;
            else
                if c<0
                    c=0;
                end
            end
            option.ax{option.cnt_subfig}.content{option.cnt_content}.FaceAlpha=c;
        end
        rect_callback();
    end
    function rect_edgealpha_edt_callback(~,~)
        c=str2num(get(handles.panel_rect_edgealpha_edt,'string'));
        if ~isempty(c) && isfinite(c)
            if c>1
                c=1;
            else
                if c<0
                    c=0;
                end
            end
            option.ax{option.cnt_subfig}.content{option.cnt_content}.EdgeAlpha=c;
        end
        rect_callback();
    end
    function rect_xy_edt_callback(~,~)
        x=str2num(get(handles.panel_rect_x_edt,'string'));
        y=str2num(get(handles.panel_rect_y_edt,'string'));
        w=str2num(get(handles.panel_rect_w_edt,'string'));
        h=str2num(get(handles.panel_rect_h_edt,'string'));
        if ~isempty(x) && ~isempty(y) && ~isempty(w) && ~isempty(h) ...
                && isfinite(x) && isfinite(y) && isfinite(w) && isfinite(h)
            if w<=0
                w=option.ax{option.cnt_subfig}.content{option.cnt_content}.w;
            end
            if h<=0
                h=option.ax{option.cnt_subfig}.content{option.cnt_content}.h;
            end
            option.ax{option.cnt_subfig}.content{option.cnt_content}.x=x;
            option.ax{option.cnt_subfig}.content{option.cnt_content}.y=y;
            option.ax{option.cnt_subfig}.content{option.cnt_content}.w=w;
            option.ax{option.cnt_subfig}.content{option.cnt_content}.h=h;
        end
        rect_callback();
    end

%% panel_text function
    function text_callback()
        text_update();
        set(handles.panel_text_text_edt,'String',option.ax{option.cnt_subfig}.content{option.cnt_content}.string);
        if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.FontWeight,'normal')
            set(handles.panel_text_bold_chk,'value',0);
        else
            set(handles.panel_text_bold_chk,'value',1);
        end
        
        if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.FontAngle,'normal')
            set(handles.panel_text_italic_chk,'value',0);
        else
            set(handles.panel_text_italic_chk,'value',1);
        end
        
        a=find(strcmpi(listfonts,option.ax{option.cnt_subfig}.content{option.cnt_content}.FontName)==1);
        set(handles.panel_text_font_pop,'value',a);
        
        set(handles.panel_text_size_edt,'String',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.FontSize));
        
        c=option.ax{option.cnt_subfig}.content{option.cnt_content}.Color;
        set(handles.panel_text_color_btn,'foregroundcolor',c);
        set(handles.panel_text_color_btn,'string',['[',num2str(c(1),'%0.2g'),',',num2str(c(2),'%0.2g'),',',num2str(c(3),'%0.2g'),']']);
        
        set(handles.panel_text_x_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.pos(1)));
        set(handles.panel_text_y_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.pos(2)));
        content_xyaxis_update();
    end
    function text_update()
        if ~strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.type,'text')
            return;
        end
        if isempty(option.ax{option.cnt_subfig}.content{option.cnt_content}.pos)
            x=mean(get(handles.ax(option.cnt_subfig),'XLim'));
            y=mean(get(handles.ax(option.cnt_subfig),'YLim'));
            option.ax{option.cnt_subfig}.content{option.cnt_content}.pos=[x,y];
        end
        
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text,...
            'position',option.ax{option.cnt_subfig}.content{option.cnt_content}.pos,...
            'string',option.ax{option.cnt_subfig}.content{option.cnt_content}.string,...
            'Color',option.ax{option.cnt_subfig}.content{option.cnt_content}.Color,...
            'FontName',option.ax{option.cnt_subfig}.content{option.cnt_content}.FontName,...
            'FontWeight',option.ax{option.cnt_subfig}.content{option.cnt_content}.FontWeight,...
            'FontSize',option.ax{option.cnt_subfig}.content{option.cnt_content}.FontSize,...
            'FontAngle',option.ax{option.cnt_subfig}.content{option.cnt_content}.FontAngle);
    end
    function text_color_btn_callback(~,~)
        c = uisetcolor(option.ax{option.cnt_subfig}.content{option.cnt_content}.Color);
        option.ax{option.cnt_subfig}.content{option.cnt_content}.Color=c;
        text_callback();
    end
    function text_text_edt_callback(~,~)
        c=get(handles.panel_text_text_edt,'string');
        str={};
        for k=1:size(c,1)
            if iscell(c(k))
                str(k)=c(k,:);
            else
                str(k)={c(k,:)};
            end
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.string=str;
        text_callback();
    end
    function text_bold_chk_callback(~,~)
        c=get(handles.panel_text_bold_chk,'value');
        if c==0
            option.ax{option.cnt_subfig}.content{option.cnt_content}.FontWeight='normal';
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.FontWeight='bold';
        end
        text_callback();
    end
    function text_italic_chk_callback(~,~)
        c=get(handles.panel_text_italic_chk,'value');
        if c==0
            option.ax{option.cnt_subfig}.content{option.cnt_content}.FontAngle='normal';
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.FontAngle='italic';
        end
        text_callback();
    end
    function text_font_pop_callback(~,~)
        str=get(handles.panel_text_font_pop,'string');
        c=get(handles.panel_text_font_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.FontName=str{c};
        text_callback();
    end
    function text_size_edt_callback(~,~)
        c=str2num(get(handles.panel_text_size_edt,'string'));
        if ~isempty(c) && isfinite(c)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.FontSize=c;
        end
        text_callback();
    end
    function text_xy_edt_callback(~,~)
        c_x=str2num(get(handles.panel_text_x_edt,'string'));
        c_y=str2num(get(handles.panel_text_y_edt,'string'));
        if ~isempty(c_x) && ~isempty(c_y) && isfinite(c_x) && isfinite(c_y)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.pos=[c_x,c_y];
        end
        text_callback();
    end

%% panel_image function
    function image_callback()
        image_update();
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset;
        set(handles.panel_image_source_pop,'value',k);
        
        if datasets_header(k).header.datasize(1)==1
            set(handles.panel_image_source_epoch_txt,'visible','off');
            set(handles.panel_image_source_epoch_pop,'visible','off');
        else
            set(handles.panel_image_source_epoch_txt,'visible','on');
            set(handles.panel_image_source_epoch_pop,'visible','on');
            set(handles.panel_image_source_epoch_pop,'string',cellstr(num2str([1:datasets_header(k).header.datasize(1)]')));
            set(handles.panel_image_source_epoch_pop,'value',option.ax{option.cnt_subfig}.content{option.cnt_content}.ep);
        end
        
        if datasets_header(k).header.datasize(2)==1
            set(handles.panel_image_source_channel_txt,'visible','off');
            set(handles.panel_image_source_channel_pop,'visible','off');
        else
            set(handles.panel_image_source_channel_txt,'visible','on');
            set(handles.panel_image_source_channel_pop,'visible','on');
            set(handles.panel_image_source_channel_pop,'string',{datasets_header(k).header.chanlocs.labels});
            ch_idx=1;
            for l=1:length({datasets_header(k).header.chanlocs.labels})
                if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.ch,...
                        datasets_header(k).header.chanlocs(l).labels)
                    ch_idx=l;
                    break;
                end
            end
            set(handles.panel_image_source_channel_pop,'value',ch_idx);
        end
        
        
        if datasets_header(k).header.datasize(3)==1
            set(handles.panel_image_source_index_txt,'visible','off');
            set(handles.panel_image_source_index_pop,'visible','off');
        else
            set(handles.panel_image_source_index_txt,'visible','on');
            set(handles.panel_image_source_index_pop,'visible','on');
            set(handles.panel_image_source_index_pop,'string',datasets_header(k).header.index_labels);
            set(handles.panel_image_source_index_pop,'value',option.ax{option.cnt_subfig}.content{option.cnt_content}.idx);
        end
        if datasets_header(k).header.datasize(4)==1
            set(handles.panel_image_source_z_txt,'visible','off');
            set(handles.panel_image_source_z_edt,'visible','off');
        else
            set(handles.panel_image_source_z_txt,'visible','on');
            set(handles.panel_image_source_z_edt,'visible','on');
            set(handles.panel_image_source_z_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.z));
        end
        
        if strcmpi(option.ax{option.cnt_subfig}.colorbar,'on')
            set (handles.panel_image_colorbar_chk,'value',1);
        else
            set (handles.panel_image_colorbar_chk,'value',0);
        end
        if verLessThan('matlab','8.4')
            str_colormap={'jet','hsv','hot','cool','spring','summer','autumn',...
                'winter','gray','bone','copper','pink'};
            color_idx=1;
        else
            str_colormap={'parula','jet','hsv','hot','cool','spring','summer',...
                'autumn','winter','gray','bone','copper','pink'};
            color_idx=2;
        end
        for l=1:length(str_colormap)
            if strcmpi(option.ax{option.cnt_subfig}.colormap,str_colormap(l))
                color_idx=l;
                break;
            end
        end
        set(handles.panel_image_colormap_pop,'value',color_idx);
        
        if ~strcmpi(option.ax{option.cnt_subfig}.climMode,'auto')
            set (handles.panel_image_clim_chk,'value',1);
            set (handles.panel_image_clim1_edt,'enable','on');
            set (handles.panel_image_clim2_edt,'enable','on');
        else
            set (handles.panel_image_clim_chk,'value',0);
            set (handles.panel_image_clim1_edt,'enable','off');
            set (handles.panel_image_clim2_edt,'enable','off');
        end
        c=option.ax{option.cnt_subfig}.clim;
        set(handles.panel_image_clim1_edt,'string',num2str(c(1)));
        set(handles.panel_image_clim2_edt,'string',num2str(c(2)));
        
        if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_enable,'on')
            set(handles.panel_image_contour_chk,'value',1);
            set(handles.panel_image_contour_color_txt,'enable','on')
            set(handles.panel_image_contour_color_btn,'enable','on')
            set(handles.panel_image_contour_width_txt,'enable','on')
            set(handles.panel_image_contour_width_edt,'enable','on')
            set(handles.panel_image_contour_style_txt,'enable','on')
            set(handles.panel_image_contour_style_pop,'enable','on')
            set(handles.panel_image_contour_level_txt,'enable','on')
            set(handles.panel_image_contour_level_chk,'enable','on')
            if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_LevelListMode,'auto')
                set(handles.panel_image_contour_level_chk,'value',1);
                set(handles.panel_image_contour_start_txt,'enable','off')
                set(handles.panel_image_contour_start_edt,'enable','off')
                set(handles.panel_image_contour_end_txt,'enable','off')
                set(handles.panel_image_contour_end_edt,'enable','off')
                set(handles.panel_image_contour_step_txt,'enable','off')
                set(handles.panel_image_contour_step_edt,'enable','off')
            else
                set(handles.panel_image_contour_level_chk,'value',0);
                set(handles.panel_image_contour_start_txt,'enable','on')
                set(handles.panel_image_contour_start_edt,'enable','on')
                set(handles.panel_image_contour_end_txt,'enable','on')
                set(handles.panel_image_contour_end_edt,'enable','on')
                set(handles.panel_image_contour_step_txt,'enable','on')
                set(handles.panel_image_contour_step_edt,'enable','on')
            end
        else
            set(handles.panel_image_contour_chk,'value',0);
            set(handles.panel_image_contour_color_txt,'enable','off')
            set(handles.panel_image_contour_color_btn,'enable','off')
            set(handles.panel_image_contour_width_txt,'enable','off')
            set(handles.panel_image_contour_width_edt,'enable','off')
            set(handles.panel_image_contour_style_txt,'enable','off')
            set(handles.panel_image_contour_style_pop,'enable','off')
            set(handles.panel_image_contour_level_txt,'enable','off')
            set(handles.panel_image_contour_level_chk,'enable','off')
            set(handles.panel_image_contour_start_txt,'enable','off')
            set(handles.panel_image_contour_start_edt,'enable','off')
            set(handles.panel_image_contour_end_txt,'enable','off')
            set(handles.panel_image_contour_end_edt,'enable','off')
            set(handles.panel_image_contour_step_txt,'enable','off')
            set(handles.panel_image_contour_step_edt,'enable','off')
        end
        c=option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_linecolor;
        set(handles.panel_image_contour_color_btn,'foregroundcolor',c);
        set(handles.panel_image_contour_color_btn,'string',['[',num2str(c(1),'%0.2g'),',',num2str(c(2),'%0.2g'),',',num2str(c(3),'%0.2g'),']']);
        
        w=option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_linewidth;
        set(handles.panel_image_contour_width_edt,'string',num2str(w));
        
        c=option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_style;
        switch c
            case '-'
                set(handles.panel_image_contour_style_pop,'value',1);
            case '--'
                set(handles.panel_image_contour_style_pop,'value',2);
            case ':'
                set(handles.panel_image_contour_style_pop,'value',3);
            case '-.'
                set(handles.panel_image_contour_style_pop,'value',4);
        end
        set(handles.panel_image_contour_start_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_start));
        set(handles.panel_image_contour_end_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_end));
        set(handles.panel_image_contour_step_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_step));
    end
    function image_update()
        if ~strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.type,'image')
            return;
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset=min(length(datasets_header),...
            option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset);
        
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset;
        header=datasets_header(k).header;
        
        x=(0:header.datasize(6)-1)*header.xstep+header.xstart;
        y=(0:header.datasize(5)-1)*header.ystep+header.ystart;
        
        i_pos=1;
        z_pos=1;
        if header.datasize(4)~=1
            z_pos=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.z-header.zstart)/header.zstep)+1);
            if z_pos<1
                z_pos=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.z=header.zstart;
            end
            if z_pos>header.datasize(4)
                z_pos=header.datasize(4);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.z=header.zstart+(header.datasize(4)-1)*header.zstep;
            end
        end
        if header.datasize(3)~=1
            i_pos=option.ax{option.cnt_subfig}.content{option.cnt_content}.idx;
            if i_pos>header.datasize(3)
                i_pos=header.datasize(3);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=i_pos;
            end
        end
        ch_idx=1;
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset;
        for l=1:length({datasets_header(k).header.chanlocs.labels})
            if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.ch,...
                    datasets_header(k).header.chanlocs(l).labels)
                ch_idx=l;
                break;
            end
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ch=datasets_header(k).header.chanlocs(ch_idx).labels;
        z=squeeze(datasets_data(k)...
            .data(option.ax{option.cnt_subfig}.content{option.cnt_content}.ep,...
            ch_idx,i_pos,z_pos,:,:));
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).img,...
            'XData',x,'YData',y,'CData',z);
        
        if strcmpi(option.ax{option.cnt_subfig}.colorbar,'on')
            if verLessThan('matlab','8.4')
                colorbar('peer',handles.ax(option.cnt_subfig));
            else
                colorbar(handles.ax(option.cnt_subfig));
            end
        else
            if verLessThan('matlab','8.4')
                colorbar('off','peer',handles.ax(option.cnt_subfig));
            else
                colorbar(handles.ax(option.cnt_subfig),'off');
            end
        end
        Set_position(handles.ax(option.cnt_subfig),option.ax{option.cnt_subfig}.pos);
        colormap(handles.ax(option.cnt_subfig),option.ax{option.cnt_subfig}.colormap);
        
        if  strcmp(option.ax{option.cnt_subfig}.XlimMode,'auto')
            temp=[min(x(:)),max(x(:))];
            option.ax{option.cnt_subfig}.Xlim=temp;
            set(handles.ax(option.cnt_subfig),'xlim',temp);
            set(handles.xaxis_limit1_edt,'string',num2str(temp(1)));
            set(handles.xaxis_limit2_edt,'string',num2str(temp(2)));
        end
        if  strcmp(option.ax{option.cnt_subfig}.YlimMode,'auto')
            temp=[min(y(:)),max(y(:))];
            if(temp(1)==temp(2))
                temp(1)=temp(1)-0.5;
                temp(2)=temp(2)+0.5;
            end
            option.ax{option.cnt_subfig}.Ylim=temp;
            set(handles.ax(option.cnt_subfig),'ylim',temp);
            set(handles.yaxis_limit1_edt,'string',num2str(temp(1)));
            set(handles.yaxis_limit2_edt,'string',num2str(temp(2)));
        end
        if strcmp(option.ax{option.cnt_subfig}.climMode,'auto')
            temp=[min(z(:)),max(z(:))];
            option.ax{option.cnt_subfig}.clim=temp;
            set(handles.ax(option.cnt_subfig),'clim',temp);
        else
            set(handles.ax(option.cnt_subfig),'clim',option.ax{option.cnt_subfig}.clim);
        end
        if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_enable,'on')
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour,...
                'XData',x,'YData',y,'zData',z,'visible','on',...
                'LineColor',option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_linecolor,...
                'LineWidth',option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_linewidth,...
                'LineStyle',option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_style,...
                'LevelListMode',option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_LevelListMode);
            if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_LevelListMode,'auto')
                c=get(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour,'LevelList');
                option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_start=c(1);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_end=c(end);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_step=c(2)-c(1);
            else
                c1=option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_start;
                c2=option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_end;
                c3=option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_step;
                set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour,'LevelList',c1:c3:c2);
            end
        else
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour,'visible','off');
        end
    end
    function image_source_pop_callback(~,~)
        % dataset
        k=get(handles.panel_image_source_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset=k;
        header=datasets_header(k).header;
        
        % epoch
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ep=...
            min(option.ax{option.cnt_subfig}.content{option.cnt_content}.ep,header.datasize(1));
        
        % channel
        set(handles.panel_image_source_channel_pop,'string',{datasets_header(k).header.chanlocs.labels});
        ch_idx=1;
        for l=1:length({datasets_header(k).header.chanlocs.labels})
            if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.ch,...
                    datasets_header(k).header.chanlocs(l).labels)
                ch_idx=l;
                break;
            end
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ch=datasets_header(k).header.chanlocs(ch_idx).labels;
        
        % index
        if datasets_header(k).header.datasize(3)==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=1;
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=...
                min(option.ax{option.cnt_subfig}.content{option.cnt_content}.idx,header.datasize(3));
        end
        image_callback();
    end
    function image_source_epoch_pop_callback(~,~)
        k=get(handles.panel_image_source_epoch_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ep=k;
        image_callback();
    end
    function image_source_channel_pop_callback(~,~)
        k=get(handles.panel_image_source_channel_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ch=...
            datasets_header(option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset).header.chanlocs(k).labels;
        image_callback();
    end
    function image_source_index_pop_callback(~,~)
        k=get(handles.panel_image_source_index_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=k;
        image_callback();
    end
    function image_source_z_edt_callback(~,~)
        temp=str2double(get(handles.panel_image_source_z_edt,'String'));
        if ~isempty(temp) && isfinite(temp)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.z=temp;
        end
        image_callback();
    end
    function image_colorbar_chk_callback(~,~)
        if get(handles.panel_image_colorbar_chk,'value')==1
            option.ax{option.cnt_subfig}.colorbar='on';
        else
            option.ax{option.cnt_subfig}.colorbar='off';
        end
        image_callback();
    end
    function image_colormap_pop_callback(~,~)
        str=get(handles.panel_image_colormap_pop,'string');
        value=get(handles.panel_image_colormap_pop,'value');
        option.ax{option.cnt_subfig}.colormap=str{value};
        if verLessThan('matlab','8.4')
            for k=1:length(option.ax)
                if ~strcmpi(option.ax{k}.style,'Curve')
                    option.ax{k}.colormap=str{value};
                end
            end
        end
        image_callback();
    end
    function image_clim_chk_callback(~,~)
        if get(handles.panel_image_clim_chk,'value')==1
            option.ax{option.cnt_subfig}.climMode='manual';
        else
            option.ax{option.cnt_subfig}.climMode='auto';
        end
        image_callback();
    end
    function image_clim_edt_callback(~,~)
        c(1)=str2num(get(handles.panel_image_clim1_edt,'string'));
        c(2)=str2num(get(handles.panel_image_clim2_edt,'string'));
        option.ax{option.cnt_subfig}.clim=c;
        image_callback();
    end
    function image_contour_chk_callback(~,~)
        if get(handles.panel_image_contour_chk,'value')==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_enable='on';
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_enable='off';
        end
        image_callback();
    end
    function image_contour_color_btn_callback(~,~)
        option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_linecolor =...
            uisetcolor(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_linecolor);
        image_callback();
    end
    function image_contour_width_edt_callback(~,~)
        temp=str2num(get(handles.panel_image_contour_width_edt,'string'));
        if ~isempty(temp) && isfinite(temp) && temp>0
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_linewidth=temp;
        end
        image_callback();
    end
    function image_contour_style_pop_callback(~,~)
        c=get(handles.panel_image_contour_style_pop,'value');
        switch(c)
            case 1
                option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_style='-';
            case 2
                option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_style='--';
            case 3
                option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_style=':';
            case 4
                option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_style='-.';
        end
        image_callback();
    end
    function image_contour_level_chk_callback(~,~)
        if get(handles.panel_image_contour_level_chk,'value')==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_LevelListMode='auto';
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_LevelListMode='manual';
        end
        image_callback();
    end
    function image_contour_start_edt_callback(~,~)
        c=str2num(get(handles.panel_image_contour_start_edt,'string'));
        if ~isempty(c) && isfinite(c)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_start=c;
        end
        image_callback();
    end
    function image_contour_end_edt_callback(~,~)
        c=str2num(get(handles.panel_image_contour_end_edt,'string'));
        if ~isempty(c) && isfinite(c)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_end=c;
        end
        image_callback();
    end
    function image_contour_step_edt_callback(~,~)
        c=str2num(get(handles.panel_image_contour_step_edt,'string'));
        if ~isempty(c) && isfinite(c) && c>0
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_level_step=c;
        end
        image_callback();
    end

%% panel_topo function
    function topo_callback()
        topo_update();
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset;
        set(handles.panel_topo_source_pop,'value',k);
        
        if datasets_header(k).header.datasize(1)==1
            set(handles.panel_topo_source_epoch_txt,'visible','off');
            set(handles.panel_topo_source_epoch_pop,'visible','off');
        else
            set(handles.panel_topo_source_epoch_txt,'visible','on');
            set(handles.panel_topo_source_epoch_pop,'visible','on');
            set(handles.panel_topo_source_epoch_pop,'string',cellstr(num2str([1:datasets_header(k).header.datasize(1)]')));
            set(handles.panel_topo_source_epoch_pop,'value',option.ax{option.cnt_subfig}.content{option.cnt_content}.ep);
        end
        
        if datasets_header(k).header.datasize(3)==1
            set(handles.panel_topo_source_index_txt,'visible','off');
            set(handles.panel_topo_source_index_pop,'visible','off');
        else
            set(handles.panel_topo_source_index_txt,'visible','on');
            set(handles.panel_topo_source_index_pop,'visible','on');
            set(handles.panel_topo_source_index_pop,'string',datasets_header(k).header.index_labels);
            set(handles.panel_topo_source_index_pop,'value',option.ax{option.cnt_subfig}.content{option.cnt_content}.idx);
        end
        
        if datasets_header(k).header.datasize(4)==1
            set(handles.panel_topo_source_z_txt,'visible','off');
            set(handles.panel_topo_source_z1_edt,'visible','off');
            set(handles.panel_topo_source_z2_edt,'visible','off');
        else
            set(handles.panel_topo_source_z_txt,'visible','on');
            set(handles.panel_topo_source_z1_edt,'visible','on');
            set(handles.panel_topo_source_z2_edt,'visible','on');
            set(handles.panel_topo_source_z1_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.z(1)));
            set(handles.panel_topo_source_z2_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.z(2)));
        end
        
        if datasets_header(k).header.datasize(5)==1
            set(handles.panel_topo_source_y_txt,'visible','off');
            set(handles.panel_topo_source_y1_edt,'visible','off');
            set(handles.panel_topo_source_y2_edt,'visible','off');
        else
            set(handles.panel_topo_source_y_txt,'visible','on');
            set(handles.panel_topo_source_y1_edt,'visible','on');
            set(handles.panel_topo_source_y2_edt,'visible','on');
            set(handles.panel_topo_source_y1_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.y(1)));
            set(handles.panel_topo_source_y2_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.y(2)));
        end
        
        if datasets_header(k).header.datasize(6)==1
            set(handles.panel_topo_source_x_txt,'visible','off');
            set(handles.panel_topo_source_x1_edt,'visible','off');
            set(handles.panel_topo_source_x2_edt,'visible','off');
        else
            set(handles.panel_topo_source_x_txt,'visible','on');
            set(handles.panel_topo_source_x1_edt,'visible','on');
            set(handles.panel_topo_source_x2_edt,'visible','on');
            set(handles.panel_topo_source_x1_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.x(1)));
            set(handles.panel_topo_source_x2_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.x(2)));
        end
        
        if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes,'off')
            set(handles.panel_topo_elec_chk,'value',0);
            set(handles.panel_topo_elec_markersize_txt,'enable','off');
            set(handles.panel_topo_elec_markersize_edt,'enable','off');
            set(handles.panel_topo_elec_label_chk,'enable','off');
            set(handles.panel_topo_elec_marker_txt,'enable','off');
            set(handles.panel_topo_elec_marker_listbox,'enable','off');
        else
            set(handles.panel_topo_elec_chk,'value',1);
            set(handles.panel_topo_elec_markersize_txt,'enable','on');
            set(handles.panel_topo_elec_markersize_edt,'enable','on');
            set(handles.panel_topo_elec_label_chk,'enable','on');
            set(handles.panel_topo_elec_marker_txt,'enable','on');
            set(handles.panel_topo_elec_marker_listbox,'enable','on');
        end
        if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes,'labels')
            set(handles.panel_topo_elec_label_chk,'value',1);
        else
            set(handles.panel_topo_elec_label_chk,'value',0);
        end
        chan_labels={datasets_header(k).header.chanlocs.labels};
        set(handles.panel_topo_elec_exclude_listbox,'string',chan_labels);
        [~,ch_exclude_idx] = intersect(chan_labels,option.ax{option.cnt_subfig}.content{option.cnt_content}.exclude);
        set(handles.panel_topo_elec_exclude_listbox,'value',ch_exclude_idx);
        
        set(handles.panel_topo_elec_marker_listbox,'string',chan_labels);
        [~,ch_marker_idx] = intersect(chan_labels,option.ax{option.cnt_subfig}.content{option.cnt_content}.mark);
        set(handles.panel_topo_elec_marker_listbox,'value',ch_marker_idx);
        
        if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.dim,'2D')
            set(handles.panel_topo_dim_2D,'value',1);
            
            set(handles.panel_topo_view_txt,'visible','off');
            set(handles.panel_topo_view_pop,'visible','off');
            set(handles.panel_topo_view_az_txt,'visible','off');
            set(handles.panel_topo_view_az_edt,'visible','off');
            set(handles.panel_topo_view_el_txt,'visible','off');
            set(handles.panel_topo_view_el_edt,'visible','off');
            
            set(handles.panel_topo_headrad_txt,'visible','on');
            set(handles.panel_topo_headrad_edt,'visible','on');
            set(handles.panel_topo_shrink_txt,'visible','on');
            set(handles.panel_topo_shrink_edt,'visible','on');
            set(handles.panel_topo_contour_chk,'visible','on');
            set(handles.panel_topo_contour_color_btn,'visible','on');
            
            if ~isempty(option.ax{option.cnt_subfig}.content{option.cnt_content}.headrad)
                set(handles.panel_topo_headrad_edt,'string',...
                    num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.headrad));
            end
            set(handles.panel_topo_shrink_edt,'string',...
                num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.shrink));
            if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour,'on')
                set(handles.panel_topo_contour_chk,'value',1);
                set(handles.panel_topo_contour_color_btn,'enable','on');
            else
                set(handles.panel_topo_contour_chk,'value',0);
                set(handles.panel_topo_contour_color_btn,'enable','off');
            end
            set(handles.panel_topo_elec_markersize_edt,...
                'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.dotsize));
            
            c=option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_edgecolor;
            set(handles.panel_topo_contour_color_btn,'foregroundcolor',c);
            set(handles.panel_topo_contour_color_btn,'string',['[',num2str(c(1),'%0.2g'),',',num2str(c(2),'%0.2g'),',',num2str(c(3),'%0.2g'),']']);
            
            set(handles.panel_topo_surface_chk,'visible','on');
            if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.surface,'on')
                set(handles.panel_topo_surface_chk,'value',1);
                set(handles.panel_topo_colorbar_chk,'enable','on');
                set(handles.panel_topo_colormap_txt,'enable','on');
                set(handles.panel_topo_colormap_pop,'enable','on');
                if strcmpi(option.ax{option.cnt_subfig}.colorbar,'on')
                    set(handles.panel_topo_colorbar_chk,'value',1);
                else
                    set(handles.panel_topo_colorbar_chk,'value',0);
                end
            else
                set(handles.panel_topo_surface_chk,'value',0);
                set(handles.panel_topo_colorbar_chk,'enable','off');
                set(handles.panel_topo_colormap_txt,'enable','off');
                set(handles.panel_topo_colormap_pop,'enable','off');
            end
            
        else
            set(handles.panel_topo_dim_3D,'value',1);
            set(handles.panel_topo_headrad_txt,'visible','off');
            set(handles.panel_topo_headrad_edt,'visible','off');
            set(handles.panel_topo_shrink_txt,'visible','off');
            set(handles.panel_topo_shrink_edt,'visible','off');
            set(handles.panel_topo_contour_chk,'visible','off');
            set(handles.panel_topo_contour_color_btn,'visible','off');
            
            set(handles.panel_topo_view_txt,'visible','on');
            set(handles.panel_topo_view_pop,'visible','on');
            set(handles.panel_topo_view_az_txt,'visible','on');
            set(handles.panel_topo_view_az_edt,'visible','on');
            set(handles.panel_topo_view_el_txt,'visible','on');
            set(handles.panel_topo_view_el_edt,'visible','on');
            
            set(handles.panel_topo_view_az_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.view(1)));
            set(handles.panel_topo_view_el_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.view(2)));
            set(handles.panel_topo_view_pop,'value',1);
            if option.ax{option.cnt_subfig}.content{option.cnt_content}.view==[-180,30]
                set(handles.panel_topo_view_pop,'value',2);%front
            end
            if option.ax{option.cnt_subfig}.content{option.cnt_content}.view==[0,30]
                set(handles.panel_topo_view_pop,'value',3);%back
            end
            if option.ax{option.cnt_subfig}.content{option.cnt_content}.view==[-90,30]
                set(handles.panel_topo_view_pop,'value',4);%left
            end
            if option.ax{option.cnt_subfig}.content{option.cnt_content}.view==[90,30]
                set(handles.panel_topo_view_pop,'value',5);%right
            end
            if option.ax{option.cnt_subfig}.content{option.cnt_content}.view==[135,30]
                set(handles.panel_topo_view_pop,'value',6);%frontright
            end
            if option.ax{option.cnt_subfig}.content{option.cnt_content}.view==[45,30]
                set(handles.panel_topo_view_pop,'value',7);%backright
            end
            if option.ax{option.cnt_subfig}.content{option.cnt_content}.view==[-135,30]
                set(handles.panel_topo_view_pop,'value',8);%frontleft
            end
            if option.ax{option.cnt_subfig}.content{option.cnt_content}.view==[-45,30]
                set(handles.panel_topo_view_pop,'value',9);%backleft
            end
            if option.ax{option.cnt_subfig}.content{option.cnt_content}.view==[0,90]
                set(handles.panel_topo_view_pop,'value',10);%top
            end
            
            set(handles.panel_topo_surface_chk,'visible','off');
            set(handles.panel_topo_colorbar_chk,'enable','on');
            set(handles.panel_topo_colormap_txt,'enable','on');
            set(handles.panel_topo_colormap_pop,'enable','on');
        end
        
        
        if strcmpi(option.ax{option.cnt_subfig}.colorbar,'on')
            set(handles.panel_topo_colorbar_chk,'value',1);
        else
            set(handles.panel_topo_colorbar_chk,'value',0);
        end
        
        if isempty(option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits)
            set(handles.panel_topo_clim_chk,'value',0);
            set(handles.panel_topo_clim1_edt,'enable','off');
            set(handles.panel_topo_clim2_edt,'enable','off');
            set(handles.panel_topo_clim1_txt,'enable','off');
            set(handles.panel_topo_clim2_txt,'enable','off');
        else
            set(handles.panel_topo_clim_chk,'value',1);
            set(handles.panel_topo_clim1_edt,'enable','on',...
                'string',option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits(1));
            set(handles.panel_topo_clim2_edt,'enable','on',...
                'string',option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits(2));
            set(handles.panel_topo_clim1_txt,'enable','on');
            set(handles.panel_topo_clim2_txt,'enable','on');
        end
        
        if verLessThan('matlab','8.4')
            str_colormap={'jet','hsv','hot','cool','spring','summer','autumn',...
                'winter','gray','bone','copper','pink'};
            color_idx=1;
        else
            str_colormap={'parula','jet','hsv','hot','cool','spring','summer',...
                'autumn','winter','gray','bone','copper','pink'};
            color_idx=2;
        end
        for l=1:length(str_colormap)
            if strcmpi(option.ax{option.cnt_subfig}.colormap,str_colormap(l))
                color_idx=l;
                break;
            end
        end
        set(handles.panel_topo_colormap_pop,'value',color_idx);
        
    end
    function topo_update()
        if ~strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.type,'topo')
            return;
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset=min(length(datasets_header),...
            option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset);
        
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset;
        header=datasets_header(k).header;
        i_pos=1;
        x_pos=[1,1];
        y_pos=[1,1];
        z_pos=[1,1];
        
        if header.datasize(6)~=1
            x_pos(1)=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.x(1)-header.xstart)/header.xstep)+1);
            if x_pos(1)<1
                x_pos(1)=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.x(1)=header.xstart;
            end
            if x_pos(1)>header.datasize(6)
                x_pos(1)=header.datasize(6);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.x(1)=header.xstart+(header.datasize(6)-1)*header.xstep;
            end
            x_pos(2)=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.x(2)-header.xstart)/header.xstep)+1);
            if x_pos(2)<1
                x_pos(2)=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.x(2)=header.xstart;
            end
            if x_pos(2)>header.datasize(6)
                x_pos(2)=header.datasize(6);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.x(2)=header.xstart+(header.datasize(6)-1)*header.xstep;
            end
        end
        if header.datasize(5)~=1
            y_pos(1)=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.y(1)-header.ystart)/header.ystep)+1);
            if y_pos(1)<1
                y_pos(1)=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.y(1)=header.ystart;
            end
            if y_pos(1)>header.datasize(5)
                y_pos(1)=header.datasize(5);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.y(1)=header.ystart+(header.datasize(5)-1)*header.ystep;
            end
            y_pos(2)=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.y(2)-header.ystart)/header.ystep)+1);
            if y_pos(2)<1
                y_pos(2)=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.y(2)=header.ystart;
            end
            if y_pos(2)>header.datasize(5)
                y_pos(2)=header.datasize(5);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.y(2)=header.ystart+(header.datasize(5)-1)*header.ystep;
            end
        end
        if header.datasize(4)~=1
            z_pos(1)=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.z(1)-header.zstart)/header.zstep)+1);
            if z_pos(1)<1
                z_pos(1)=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.z(1)=header.zstart;
            end
            if z_pos(1)>header.datasize(4)
                z_pos(1)=header.datasize(4);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.z(1)=header.zstart+(header.datasize(4)-1)*header.zstep;
            end
            z_pos(2)=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.z(2)-header.zstart)/header.zstep)+1);
            if z_pos(2)<1
                z_pos(2)=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.z(2)=header.zstart;
            end
            if z_pos(2)>header.datasize(4)
                z_pos(2)=header.datasize(4);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.z(2)=header.zstart+(header.datasize(4)-1)*header.zstep;
            end
        end
        if header.datasize(3)~=1
            i_pos=option.ax{option.cnt_subfig}.content{option.cnt_content}.idx;
            if i_pos>header.datasize(3)
                i_pos=header.datasize(3);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=i_pos;
            end
        end
        values=double(datasets_data(k).data(option.ax{option.cnt_subfig}.content{option.cnt_content}.ep,:,i_pos,z_pos(1):z_pos(2),y_pos(1):y_pos(2),x_pos(1):x_pos(2)));
        values=mean(mean(mean(values,6),5),4);
        
        
        if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.dim,'2D')
            topo2D_update(values);
        else
            topo3D_update(values);
        end
    end
    function topo2D_update(values)
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).surf_3D,'visible','off');
        view(handles.ax(option.cnt_subfig),[0 0 1]);
        delete(findall(handles.ax(option.cnt_subfig),'Type','light'));
        
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset;
        header=datasets_header(k).header;
        chanlocs=header.chanlocs;
        
        gridres = 40;
        headrad=option.ax{option.cnt_subfig}.content{option.cnt_content}.headrad;
        shrink=option.ax{option.cnt_subfig}.content{option.cnt_content}.shrink;
        
        %% not understand
        if any(values == 0) || ~isempty( [ chanlocs(values == 0).theta ])
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour = 'off';
        end
        
        %% remove the excluded channels
        chan_labels={chanlocs.labels};
        if ~isempty(option.ax{option.cnt_subfig}.content{option.cnt_content}.exclude)
            [~,ia] = intersect(chan_labels,option.ax{option.cnt_subfig}.content{option.cnt_content}.exclude);
            chan_labels(ia) = [];
            chanlocs(ia)    = [];
            values(ia)      = [];
        end
        ia = cellfun('isempty', { chanlocs.theta });
        values(ia)=[];
        chan_labels(ia)=[];
        
        if isempty(values)
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).surf_2D,'visible','off');
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour,'visible','off');
            return;
        end
        
        [y,x]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
        x=-x;
        x = x*shrink;
        y = y*shrink;
        if isempty(headrad)
            headrad=max(sqrt(x.^2+y.^2));
            set(handles.panel_topo_headrad_edt,'string',num2str(headrad));
        end
        ylimtmp = max(headrad, 0.58);
        set(handles.ax(option.cnt_subfig),'ylim',[-ylimtmp ylimtmp]);
        set(handles.ax(option.cnt_subfig),'xlim',[-ylimtmp ylimtmp]);
        
        % data points for 2-D data plot
        pnts = linspace(0,2*pi,200/0.25*(headrad.^2));
        coords = linspace(-headrad, headrad, gridres);
        ay = repmat(coords,  [gridres 1]);
        ax = repmat(coords', [1 gridres]);
        xx = sin(pnts)*headrad;
        yy = cos(pnts)*headrad;
        for ind=1:length(xx)
            [~, closex] = min(abs(xx(ind)-coords));
            [~, closey] = min(abs(yy(ind)-coords));
            ax(closex,closey) = xx(ind);
            ay(closex,closey) = yy(ind);
        end
        xx2 = sin(pnts)*(headrad-0.01);
        yy2 = cos(pnts)*(headrad-0.01);
        for ind=1:length(xx)
            [~, closex] = min(abs(xx2(ind)-coords));
            [~, closey] = min(abs(yy2(ind)-coords));
            ax(closex,closey) = xx(ind);
            ay(closex,closey) = yy(ind);
        end
        a = griddata(x, y, values, -ay, ax, 'v4');
        aradius = sqrt(ax.^2 + ay.^2);
        a(aradius(:) > headrad+0.01) = NaN;
        
        if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.surface,'on')
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).surf_2D,...
                'Xdata',ay,'Ydata',ax,'Zdata',a,'visible','on');
            shading(handles.ax(option.cnt_subfig),'interp');
        else
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).surf_2D,...
                'Xdata',ay,'Ydata',ax,'Zdata',a,'visible','off');
        end
        if max(a(:))>0
            top = double(max(a(:))*1.05);
        else
            top = double(max(a(:))*0.95);
        end
        if verLessThan('matlab','8.4')
            if ishandle(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour)
                delete(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour);
            end
            [~,handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour]=...
                contour3(handles.ax(option.cnt_subfig),ay,ax,a);
            for k = 1:length(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour)
                set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour(k),...
                    'edgecolor', option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_edgecolor);
            end
            if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour, 'on')
                for k = 1:length(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour)
                    set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour(k),'visible','on');
                end
            else
                for k = 1:length(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour)
                    set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour(k),'visible','off');
                end
            end
        else
            if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour, 'on')
                set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour,...
                    'XData',ay, 'YData',ax,'ZData', a,'visible','on',...
                    'edgecolor', option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_edgecolor);
            else
                set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour,...
                    'XData',ay, 'YData',ax,'ZData', a,'visible','off',...
                    'edgecolor', option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_edgecolor);
            end
        end
        
        delete(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text);
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text=[];
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker1,'visible','off');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker2,'visible','off');
        if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes, 'on') ||...
                strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes, 'labels')
            rad = sqrt(x.^2 + y.^2);
            x(rad > headrad) = [];
            y(rad > headrad) = [];
            chan_labels(rad > headrad)=[];
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode,...
                'XData',-x,'YData', y, 'ZData',ones(size(x))*top,'visible','on', ...
                'markersize', option.ax{option.cnt_subfig}.content{option.cnt_content}.dotsize);
            
           
            [~,ia] = intersect(chan_labels,option.ax{option.cnt_subfig}.content{option.cnt_content}.mark);
            if ~isempty(ia)
                set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker1,...
                    'XData',-x(ia),'YData',  y(ia), 'ZData',ones(size(x(ia)))*top+0.1,'visible','on',...
                    'markersize', 4*option.ax{option.cnt_subfig}.content{option.cnt_content}.dotsize);
                set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker2,...
                    'XData',-x(ia),'YData',  y(ia), 'ZData',ones(size(x(ia)))*top+0.2,'visible','on',...
                    'markersize', 2*option.ax{option.cnt_subfig}.content{option.cnt_content}.dotsize);
            end
            if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes, 'labels')
                for index = 1:length(x)
                    handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text(index)=...
                        text( -x(index)+0.02, y(index), top+0.3, chan_labels{index},...
                        'parent',handles.ax(option.cnt_subfig));
                end
            end
        else
            % invisible electrode that avoid plotting problem (no surface, only contours)
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode,...
                'XData',-x(1),'YData', y(1), 'ZData',-top,'markersize', 0.001);
        end
        colormap(handles.ax(option.cnt_subfig),option.ax{option.cnt_subfig}.colormap);
        if isempty(option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits)
            set(handles.ax(option.cnt_subfig),'CLimMode','auto');
        else
            set(handles.ax(option.cnt_subfig),'CLim',option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits);
        end
        temp=get(handles.ax(option.cnt_subfig),'CLim');
        set(handles.panel_topo_clim1_edt,'string',num2str(temp(1)));
        set(handles.panel_topo_clim2_edt,'string',num2str(temp(2)));
        
        if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.surface,'on') && strcmpi(option.ax{option.cnt_subfig}.colorbar,'on')
            if verLessThan('matlab','8.4')
                colorbar('peer',handles.ax(option.cnt_subfig));
            else
                colorbar(handles.ax(option.cnt_subfig));
            end
        else
            if verLessThan('matlab','8.4')
                colorbar('off','peer',handles.ax(option.cnt_subfig));
            else
                colorbar(handles.ax(option.cnt_subfig),'off');
            end
        end
        Set_position(handles.ax(option.cnt_subfig),option.ax{option.cnt_subfig}.pos);
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line1,'ZData',ones(1,200)*top,'visible','on');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line2,'ZData',ones(1,10)*top,'visible','on');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line3,'ZData',ones(1,10)*top,'visible','on');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line4,'ZData',ones(5,1)*top,'visible','on');
        
    end
    function topo3D_update(values)
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).surf_2D,'visible','off');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).contour,'visible','off');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line1,'visible','off');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line2,'visible','off');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line3,'visible','off');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line4,'visible','off');
        
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset;
        header=datasets_header(k).header;
        chanlocs=header.chanlocs;
        
        %colornum=64;
        chan_labels={chanlocs.labels};
        for l=1:length(chanlocs)
            header.chanlocs(l).topo_enabled=1;
        end
        if ~isempty(option.ax{option.cnt_subfig}.content{option.cnt_content}.exclude)
            [~,ia] = intersect(chan_labels,option.ax{option.cnt_subfig}.content{option.cnt_content}.exclude);
            for l=ia'
                header.chanlocs(l).topo_enabled=0;
            end
        end
        header=CLW_make_spl(header);
        chan_labels  =   chan_labels(header.spl.indices);
        chanlocs     =   chanlocs(header.spl.indices);
        values       =   values(header.spl.indices);
        
        meanval = mean(values);
        P=header.spl.GG*[values(:)- meanval;0]+meanval;
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).surf_3D,...
            'FaceVertexCdata',P,'visible','on');
        axis(handles.ax(option.cnt_subfig),[-125 125 -125 125 -125 125]);
        colormap(handles.ax(option.cnt_subfig),option.ax{option.cnt_subfig}.colormap);
        if isempty(option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits)
            set(handles.ax(option.cnt_subfig),'CLimMode','auto');
        else
            set(handles.ax(option.cnt_subfig),'CLim',option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits);
        end
        temp=get(handles.ax(option.cnt_subfig),'CLim');
        set(handles.panel_topo_clim1_edt,'string',num2str(temp(1)));
        set(handles.panel_topo_clim2_edt,'string',num2str(temp(2)));
        
        delete(findall(handles.ax(option.cnt_subfig),'Type','light'));
        light('parent',handles.ax(option.cnt_subfig),'Position',[-125  125  80],'Style','infinite');
        light('parent',handles.ax(option.cnt_subfig),'Position',[125  125  80],'Style','infinite');
        light('parent',handles.ax(option.cnt_subfig),'Position',[125 -125 80],'Style','infinite');
        light('parent',handles.ax(option.cnt_subfig),'Position',[-125 -125 80],'Style','infinite');
        lighting(handles.ax(option.cnt_subfig),'phong');
        view(handles.ax(option.cnt_subfig),option.ax{option.cnt_subfig}.content{option.cnt_content}.view);
        
        
        delete(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text);
        handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text=[];
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode,'visible','off');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker1,'visible','off');
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker2,'visible','off');
        if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes, 'on') ||...
                strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes, 'labels')
            set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode,...
                'XData',header.spl.newElect(:,1),'YData', header.spl.newElect(:,2), 'ZData',header.spl.newElect(:,3),'visible','on', ...
                'markersize', option.ax{option.cnt_subfig}.content{option.cnt_content}.dotsize);
            if strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes, 'labels')
                for index = 1:length(chan_labels)
                    handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).text(index)=...
                        text(header.spl.newElect(index,1),header.spl.newElect(index,2),header.spl.newElect(index,3),...
                        chan_labels{index},'parent',handles.ax(option.cnt_subfig),...
                        'FontWeight','bold','HorizontalAlignment','center');
                end
            end
            [~,ia] = intersect(chan_labels,option.ax{option.cnt_subfig}.content{option.cnt_content}.mark);
            if ~isempty(ia)
                set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker1,...
                    'XData',header.spl.newElect(ia,1),'YData',  header.spl.newElect(ia,2), 'ZData',header.spl.newElect(ia,3),'visible','on',...
                    'markersize', 4*option.ax{option.cnt_subfig}.content{option.cnt_content}.dotsize);
                set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).electrode_marker2,...
                    'XData',header.spl.newElect(ia,1),'YData',  header.spl.newElect(ia,2), 'ZData',header.spl.newElect(ia,3),'visible','on',...
                    'markersize', 2*option.ax{option.cnt_subfig}.content{option.cnt_content}.dotsize);
            end
        end
        
        if strcmpi(option.ax{option.cnt_subfig}.colorbar,'on')
            if verLessThan('matlab','8.4')
                colorbar('peer',handles.ax(option.cnt_subfig));
            else
                colorbar(handles.ax(option.cnt_subfig));
            end
        else
            if verLessThan('matlab','8.4')
                colorbar('off','peer',handles.ax(option.cnt_subfig));
            else
                colorbar(handles.ax(option.cnt_subfig),'off');
            end
        end
        Set_position(handles.ax(option.cnt_subfig),option.ax{option.cnt_subfig}.pos);
    end
    function topo_source_pop_callback(~,~)
        % dataset
        k=get(handles.panel_topo_source_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.dataset=k;
        header=datasets_header(k).header;
        
        % epoch
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ep=...
            min(option.ax{option.cnt_subfig}.content{option.cnt_content}.ep,header.datasize(1));
        
        % index
        if datasets_header(k).header.datasize(3)==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=1;
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=...
                min(option.ax{option.cnt_subfig}.content{option.cnt_content}.idx,header.datasize(3));
        end
        topo_callback();
    end
    function topo_source_epoch_pop_callback(~,~)
        k=get(handles.panel_topo_source_epoch_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.ep=k;
        topo_callback();
    end
    function topo_source_index_pop_callback(~,~)
        k=get(handles.panel_topo_source_index_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.idx=k;
        topo_callback();
    end
    function topo_source_z_edt_callback(~,~)
        temp(1)=str2double(get(handles.panel_topo_source_z1_edt,'String'));
        temp(2)=str2double(get(handles.panel_topo_source_z2_edt,'String'));
        if ~isempty(temp) && isfinite(temp(1))&& isfinite(temp(2))
            if temp(1)>temp(2)
                temp=temp([2,1]);
            end
            option.ax{option.cnt_subfig}.content{option.cnt_content}.z=temp;
        end
        topo_callback();
    end
    function topo_source_y_edt_callback(~,~)
        temp(1)=str2double(get(handles.panel_topo_source_y1_edt,'String'));
        temp(2)=str2double(get(handles.panel_topo_source_y2_edt,'String'));
        if ~isempty(temp) && isfinite(temp(1))&& isfinite(temp(2))
            if temp(1)>temp(2)
                temp=temp([2,1]);
            end
            option.ax{option.cnt_subfig}.content{option.cnt_content}.y=temp;
        end
        topo_callback();
    end
    function topo_source_x_edt_callback(~,~)
        temp(1)=str2double(get(handles.panel_topo_source_x1_edt,'String'));
        temp(2)=str2double(get(handles.panel_topo_source_x2_edt,'String'));
        if ~isempty(temp) && isfinite(temp(1))&& isfinite(temp(2))
            if temp(1)>temp(2)
                temp=temp([2,1]);
            end
            option.ax{option.cnt_subfig}.content{option.cnt_content}.x=temp;
        end
        topo_callback();
    end
    function topo_elec_chk_callback(~,~)
        if get(handles.panel_topo_elec_chk,'value')==1
            if get(handles.panel_topo_elec_label_chk,'value')==1
                option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes='labels';
            else
                option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes='on';
            end
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes='off';
        end
        topo_callback();
    end
    function topo_elec_label_chk_callback(~,~)
        if get(handles.panel_topo_elec_label_chk,'value')==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes='labels';
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.electrodes='on';
        end
        topo_callback();
    end
    function topo_elec_markersize_edt_callback(~,~)
        temp=str2num(get(handles.panel_topo_elec_markersize_edt,'string'));
        if ~isempty(temp) && isfinite(temp)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.dotsize=temp;
        end
        topo_callback();
    end
    function topo_elec_exclude_listbox_callback(~,~)
        str=get(handles.panel_topo_elec_exclude_listbox,'string');
        temp=get(handles.panel_topo_elec_exclude_listbox,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.exclude={str{temp}};
        [~,ia] = intersect(option.ax{option.cnt_subfig}.content{option.cnt_content}.mark,option.ax{option.cnt_subfig}.content{option.cnt_content}.exclude);
        option.ax{option.cnt_subfig}.content{option.cnt_content}.mark(ia)=[];
        topo_callback();
    end
    function topo_elec_marker_listbox_callback(~,~)
        str=get(handles.panel_topo_elec_marker_listbox,'string');
        temp=get(handles.panel_topo_elec_marker_listbox,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.mark={str{temp}};
        [~,ia] = intersect(option.ax{option.cnt_subfig}.content{option.cnt_content}.mark,option.ax{option.cnt_subfig}.content{option.cnt_content}.exclude);
        option.ax{option.cnt_subfig}.content{option.cnt_content}.mark(ia)=[];
        topo_callback();
    end
    function topo_dim_bg_callback(~,~)
        if get(handles.panel_topo_dim_2D,'value')==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.dim='2D';
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.dim='3D';
        end
        topo_callback();
    end
    function topo_view_pop_callback(~,~)
        n=get(handles.panel_topo_view_pop,'value');
        switch n
            case 2%front
                option.ax{option.cnt_subfig}.content{option.cnt_content}.view=[-180,30];
            case 3%back
                option.ax{option.cnt_subfig}.content{option.cnt_content}.view=[0,30];
            case 4%left
                option.ax{option.cnt_subfig}.content{option.cnt_content}.view=[-90,30];
            case 5%right
                option.ax{option.cnt_subfig}.content{option.cnt_content}.view=[90,30];
            case 6%frontright
                option.ax{option.cnt_subfig}.content{option.cnt_content}.view=[135,30];
            case 7%backright
                option.ax{option.cnt_subfig}.content{option.cnt_content}.view=[45,30];
            case 8%frontleft
                option.ax{option.cnt_subfig}.content{option.cnt_content}.view=[-135,30];
            case 9%backleft
                option.ax{option.cnt_subfig}.content{option.cnt_content}.view=[-45,30];
            case 10%top
                option.ax{option.cnt_subfig}.content{option.cnt_content}.view=[0,90];
        end
        topo_callback();
    end
    function topo_view_az_edt_callback(~,~)
        c=str2num(get(handles.panel_topo_view_az_edt,'string'));
        if ~isempty(c) && isfinite(c)
            c=mod(c+180,360)-180;
            option.ax{option.cnt_subfig}.content{option.cnt_content}.view(1)=c;
            topo_callback();
        end
    end
    function topo_view_el_edt_callback(~,~)
        c=str2num(get(handles.panel_topo_view_el_edt,'string'));
        if ~isempty(c) && isfinite(c)
            c=mod(c+90,360)-90;
            option.ax{option.cnt_subfig}.content{option.cnt_content}.view(2)=c;
            topo_callback();
        end
    end
    function topo_headrad_edt_callback(~,~)
        temp=str2num(get(handles.panel_topo_headrad_edt,'string'));
        if ~isempty(temp) && isfinite(temp) && temp>0
            option.ax{option.cnt_subfig}.content{option.cnt_content}.headrad=temp;
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.headrad=[];
        end
        topo_callback();
    end
    function topo_shrink_edt_callback(~,~)
        temp=str2num(get(handles.panel_topo_shrink_edt,'string'));
        if ~isempty(temp) && isfinite(temp) && temp>0
            option.ax{option.cnt_subfig}.content{option.cnt_content}.shrink=temp;
        end
        topo_callback();
    end
    function topo_clim_chk_callback(~,~)
        if get(handles.panel_topo_clim_chk,'value')==1
            c1=str2num(get(handles.panel_topo_clim1_edt,'string'));
            c2=str2num(get(handles.panel_topo_clim2_edt,'string'));
            option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits=[c1,c2];
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits=[];
        end
        topo_callback();
    end
    function topo_clim_edt_callback(~,~)
        c1=str2num(get(handles.panel_topo_clim1_edt,'string'));
        c2=str2num(get(handles.panel_topo_clim2_edt,'string'));
        if ~isempty(c1) && isfinite(c1)&&  ~isempty(c2) && isfinite(c2)
            if c1<c2
                option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits=[c1,c2];
            else
                option.ax{option.cnt_subfig}.content{option.cnt_content}.maplimits=[c2,c1];
            end
        end
        topo_callback();
    end
    function topo_surface_chk_callback(~,~)
        if get(handles.panel_topo_surface_chk,'value')==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.surface='on';
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.surface='off';
        end
        topo_callback();
    end
    function topo_colorbar_chk_callback(~,~)
        if get(handles.panel_topo_colorbar_chk,'value')==1
            option.ax{option.cnt_subfig}.colorbar='on';
        else
            option.ax{option.cnt_subfig}.colorbar='off';
        end
        topo_callback();
    end
    function topo_colormap_pop_callback(~,~)
        str=get(handles.panel_topo_colormap_pop,'string');
        value=get(handles.panel_topo_colormap_pop,'value');
        option.ax{option.cnt_subfig}.colormap=str{value};
        
        if verLessThan('matlab','8.4')
            for k=1:length(option.ax)
                if ~strcmpi(option.ax{k}.style,'Curve')
                    option.ax{k}.colormap=str{value};
                end
            end
        end
        topo_callback();
    end
    function topo_contour_chk_callback(~,~)
        if get(handles.panel_topo_contour_chk,'value')==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour='on';
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.contour='off';
        end
        topo_callback();
    end
    function topo_contour_color_btn_callback(~,~)
        option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_edgecolor =...
            uisetcolor(option.ax{option.cnt_subfig}.content{option.cnt_content}.contour_edgecolor);
        topo_callback();
    end

%% panel_lissajous function
    function lissajous_callback()
        lissajous_update();
        c=option.ax{option.cnt_subfig}.content{option.cnt_content}.color;
        set(handles.panel_lissajous_color_btn,'foregroundcolor',c);
        set(handles.panel_lissajous_color_btn,'string',['[',num2str(c(1),'%0.2g'),',',num2str(c(2),'%0.2g'),',',num2str(c(3),'%0.2g'),']']);
        set(handles.panel_lissajous_width_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth));
        switch option.ax{option.cnt_subfig}.content{option.cnt_content}.style
            case '-'
                set(handles.panel_lissajous_style_pop,'value',1);
            case '--'
                set(handles.panel_lissajous_style_pop,'value',2);
            case ':'
                set(handles.panel_lissajous_style_pop,'value',3);
            case '-.'
                set(handles.panel_lissajous_style_pop,'value',4);
            case 'none'
                set(handles.panel_lissajous_style_pop,'value',5);
        end
        switch option.ax{option.cnt_subfig}.content{option.cnt_content}.marker
            case 'none'
                set(handles.panel_lissajous_marker_pop,'value',1);
            case 'o'
                set(handles.panel_lissajous_marker_pop,'value',2);
            case '+'
                set(handles.panel_lissajous_marker_pop,'value',3);
            case '*'
                set(handles.panel_lissajous_marker_pop,'value',4);
            case '.'
                set(handles.panel_lissajous_marker_pop,'value',5);
            case 'x'
                set(handles.panel_lissajous_marker_pop,'value',6);
            case 's'
                set(handles.panel_lissajous_marker_pop,'value',7);
            case 'd'
                set(handles.panel_lissajous_marker_pop,'value',8);
            case '^'
                set(handles.panel_lissajous_marker_pop,'value',9);
            case 'v'
                set(handles.panel_lissajous_marker_pop,'value',10);
            case '>'
                set(handles.panel_lissajous_marker_pop,'value',11);
            case '<'
                set(handles.panel_lissajous_marker_pop,'value',12);
            case 'p'
                set(handles.panel_lissajous_marker_pop,'value',13);
            case 'h'
                set(handles.panel_lissajous_marker_pop,'value',14);
        end
        
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_dataset;
        set(handles.panel_lissajous_source1_pop,'value',k);
        set(handles.panel_lissajous_source1_epoch_pop,'string',cellstr(num2str([1:datasets_header(k).header.datasize(1)]')));
        set(handles.panel_lissajous_source1_epoch_pop,'value',option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ep);
        set(handles.panel_lissajous_source1_channel_pop,'string',{datasets_header(k).header.chanlocs.labels});
        ch_idx=1;
        for l=1:length({datasets_header(k).header.chanlocs.labels})
            if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ch,...
                    datasets_header(k).header.chanlocs(l).labels)
                ch_idx=l;
                break;
            end
        end
        set(handles.panel_lissajous_source1_channel_pop,'value',ch_idx);
        if datasets_header(k).header.datasize(3)==1
            set(handles.panel_lissajous_source1_index_txt,'visible','off');
            set(handles.panel_lissajous_source1_index_pop,'visible','off');
        else
            set(handles.panel_lissajous_source1_index_txt,'visible','on');
            set(handles.panel_lissajous_source1_index_pop,'visible','on');
            set(handles.panel_lissajous_source1_index_pop,'string',datasets_header(k).header.index_labels);
            set(handles.panel_lissajous_source1_index_pop,'value',option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_idx);
        end
        if datasets_header(k).header.datasize(4)==1
            set(handles.panel_lissajous_source1_z_txt,'visible','off');
            set(handles.panel_lissajous_source1_z_edt,'visible','off');
        else
            set(handles.panel_lissajous_source1_z_txt,'visible','on');
            set(handles.panel_lissajous_source1_z_edt,'visible','on');
            set(handles.panel_lissajous_source1_z_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_z));
        end
        if datasets_header(k).header.datasize(5)==1
            set(handles.panel_lissajous_source1_y_txt,'visible','off');
            set(handles.panel_lissajous_source1_y_edt,'visible','off');
        else
            set(handles.panel_lissajous_source1_y_txt,'visible','on');
            set(handles.panel_lissajous_source1_y_edt,'visible','on');
            set(handles.panel_lissajous_source1_y_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_y));
        end
        
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_dataset;
        set(handles.panel_lissajous_source2_pop,'value',k);
        set(handles.panel_lissajous_source2_epoch_pop,'string',cellstr(num2str([1:datasets_header(k).header.datasize(1)]')));
        set(handles.panel_lissajous_source2_epoch_pop,'value',option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ep);
        set(handles.panel_lissajous_source2_channel_pop,'string',{datasets_header(k).header.chanlocs.labels});
        ch_idx=1;
        for l=1:length({datasets_header(k).header.chanlocs.labels})
            if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ch,...
                    datasets_header(k).header.chanlocs(l).labels)
                ch_idx=l;
                break;
            end
        end
        set(handles.panel_lissajous_source2_channel_pop,'value',ch_idx);
        if datasets_header(k).header.datasize(3)==1
            set(handles.panel_lissajous_source2_index_txt,'visible','off');
            set(handles.panel_lissajous_source2_index_pop,'visible','off');
        else
            set(handles.panel_lissajous_source2_index_txt,'visible','on');
            set(handles.panel_lissajous_source2_index_pop,'visible','on');
            set(handles.panel_lissajous_source2_index_pop,'string',datasets_header(k).header.index_labels);
            set(handles.panel_lissajous_source2_index_pop,'value',option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_idx);
        end
        if datasets_header(k).header.datasize(4)==1
            set(handles.panel_lissajous_source2_z_txt,'visible','off');
            set(handles.panel_lissajous_source2_z_edt,'visible','off');
        else
            set(handles.panel_lissajous_source2_z_txt,'visible','on');
            set(handles.panel_lissajous_source2_z_edt,'visible','on');
            set(handles.panel_lissajous_source2_z_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_z));
        end
        if datasets_header(k).header.datasize(5)==1
            set(handles.panel_lissajous_source2_y_txt,'visible','off');
            set(handles.panel_lissajous_source2_y_edt,'visible','off');
        else
            set(handles.panel_lissajous_source2_y_txt,'visible','on');
            set(handles.panel_lissajous_source2_y_edt,'visible','on');
            set(handles.panel_lissajous_source2_y_edt,'string',num2str(option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_y));
        end
    end
    function lissajous_update()
        if ~strcmpi(option.ax{option.cnt_subfig}.content{option.cnt_content}.type,'lissajous')
            return;
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_dataset=min(length(datasets_header),...
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_dataset);
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_dataset=min(length(datasets_header),...
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_dataset);
        
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_dataset;
        header=datasets_header(k).header;
        i_pos=1;
        y_pos=1;
        z_pos=1;
        if header.datasize(5)~=1
            y_pos=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_y-header.ystart)/header.ystep)+1);
            if y_pos<1
                y_pos=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_y=header.ystart;
            end
            if y_pos>header.datasize(5)
                y_pos=header.datasize(5);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_y=header.ystart+(header.datasize(5)-1)*header.ystep;
                
            end
        end
        if header.datasize(4)~=1
            z_pos=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_z-header.zstart)/header.zstep)+1);
            if z_pos<1
                z_pos=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_z=header.zstart;
            end
            if z_pos>header.datasize(4)
                z_pos=header.datasize(4);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_z=header.zstart+(header.datasize(4)-1)*header.zstep;
            end
        end
        if header.datasize(3)~=1
            i_pos=option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_idx;
            if i_pos>header.datasize(3)
                i_pos=header.datasize(3);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_idx=i_pos;
            end
        end
        ch_idx=1;
        for l=1:length({datasets_header(k).header.chanlocs.labels})
            if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ch,...
                    datasets_header(k).header.chanlocs(l).labels)
                ch_idx=l;
                break;
            end
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ch=...
            datasets_header(k).header.chanlocs(ch_idx).labels;
        x=squeeze(datasets_data(k).data(...
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ep,...
            ch_idx,i_pos,z_pos,y_pos,:));
        
        
        k=option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_dataset;
        header=datasets_header(k).header;
        i_pos=1;
        y_pos=1;
        z_pos=1;
        if header.datasize(5)~=1
            y_pos=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_y-header.ystart)/header.ystep)+1);
            if y_pos<1
                y_pos=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_y=header.ystart;
            end
            if y_pos>header.datasize(5)
                y_pos=header.datasize(5);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_y=header.ystart+(header.datasize(5)-1)*header.ystep;
            end
        end
        if header.datasize(4)~=1
            z_pos=round(((option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_z-header.zstart)/header.zstep)+1);
            if z_pos<1
                z_pos=1;
                option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_z=header.zstart;
            end
            if z_pos>header.datasize(4)
                z_pos=header.datasize(4);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_z=header.zstart+(header.datasize(4)-1)*header.zstep;
            end
        end
        if header.datasize(3)~=1
            i_pos=option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_idx;
            if i_pos>header.datasize(3)
                i_pos=header.datasize(3);
                option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_idx=i_pos;
            end
        end
        ch_idx=1;
        for l=1:length({datasets_header(k).header.chanlocs.labels})
            if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ch,...
                    datasets_header(k).header.chanlocs(l).labels)
                ch_idx=l;
                break;
            end
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ch=...
            datasets_header(k).header.chanlocs(ch_idx).labels;
        y=squeeze(datasets_data(k).data(...
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ep,...
            ch_idx,i_pos,z_pos,y_pos,:));
        len=min(length(x),length(y));
        
        set(handles.ax_child{option.cnt_subfig}.handle(option.cnt_content).line,...
            'XData',x(1:len),'YData',y(1:len),...
            'linewidth',option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth,...
            'linestyle',option.ax{option.cnt_subfig}.content{option.cnt_content}.style,...
            'marker',option.ax{option.cnt_subfig}.content{option.cnt_content}.marker,...
            'color',option.ax{option.cnt_subfig}.content{option.cnt_content}.color);
        content_xyaxis_update();
    end
    function lissajous_color_btn_callback(~,~)
        option.ax{option.cnt_subfig}.content{option.cnt_content}.color = uisetcolor(option.ax{option.cnt_subfig}.content{option.cnt_content}.color);
        lissajous_callback();
    end
    function lissajous_width_edt_callback(~,~)
        c=str2num(get(handles.panel_lissajous_width_edt,'string'));
        if ~isempty(c) && isfinite(c) &&c>0
            option.ax{option.cnt_subfig}.content{option.cnt_content}.linewidth=c;
        end
        lissajous_callback();
    end
    function lissajous_style_pop_callback(~,~)
        c=get(handles.panel_lissajous_style_pop,'value');
        switch c
            case 1
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='-';
            case 2
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='--';
            case 3
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style=':';
            case 4
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='-.';
            case 5
                option.ax{option.cnt_subfig}.content{option.cnt_content}.style='none';
        end
        lissajous_callback();
    end
    function lissajous_marker_pop_callback(~,~)
        c=get(handles.panel_lissajous_marker_pop,'value');
        switch c
            case 1
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='none';
            case 2
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='o';
            case 3
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='+';
            case 4
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='*';
            case 5
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='.';
            case 6
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='x';
            case 7
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='s';
            case 8
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='d';
            case 9
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='^';
            case 10
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='v';
            case 11
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='>';
            case 12
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='<';
            case 13
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='p';
            case 14
                option.ax{option.cnt_subfig}.content{option.cnt_content}.marker='h';
        end
        lissajous_callback();
    end
    function lissajous_source1_pop_callback(~,~)
        % dataset
        k=get(handles.panel_lissajous_source1_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_dataset=k;
        header=datasets_header(k).header;
        
        % epoch
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ep=...
            min(option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ep,header.datasize(1));
        
        % channel
        set(handles.panel_lissajous_source1_channel_pop,'string',{datasets_header(k).header.chanlocs.labels});
        ch_idx=1;
        for l=1:length({datasets_header(k).header.chanlocs.labels})
            if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ch,...
                    datasets_header(k).header.chanlocs(l).labels)
                ch_idx=l;
                break;
            end
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ch=datasets_header(k).header.chanlocs(ch_idx).labels;
        
        % index
        if datasets_header(k).header.datasize(3)==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_idx=1;
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_idx=...
                min(option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_idx,header.datasize(3));
        end
        lissajous_update();
    end
    function lissajous_source1_epoch_pop_callback(~,~)
        k=get(handles.panel_lissajous_source1_epoch_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ep=k;
        lissajous_update();
    end
    function lissajous_source1_channel_pop_callback(~,~)
        k=get(handles.panel_lissajous_source1_channel_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_ch=...
            datasets_header(option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_dataset).header.chanlocs(k).labels;
        lissajous_update();
    end
    function lissajous_source1_index_pop_callback(~,~)
        k=get(handles.panel_lissajous_source1_index_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_idx=k;
        lissajous_update();
    end
    function lissajous_source1_z_edt_callback(~,~)
        temp=str2double(get(handles.panel_lissajous_source1_z_edt,'String'));
        if ~isempty(temp) && isfinite(temp)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_z=temp;
        end
        lissajous_update();
    end
    function lissajous_source1_y_edt_callback(~,~)
        temp=str2double(get(handles.panel_lissajous_source1_y_edt,'String'));
        if ~isempty(temp) && isfinite(temp)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source1_y=temp;
        end
        lissajous_update();
    end
    function lissajous_source2_pop_callback(~,~)
        % dataset
        k=get(handles.panel_lissajous_source2_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_dataset=k;
        header=datasets_header(k).header;
        
        % epoch
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ep=...
            min(option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ep,header.datasize(1));
        
        % channel
        set(handles.panel_lissajous_source2_channel_pop,'string',{datasets_header(k).header.chanlocs.labels});
        ch_idx=1;
        for l=1:length({datasets_header(k).header.chanlocs.labels})
            if strcmp(option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ch,...
                    datasets_header(k).header.chanlocs(l).labels)
                ch_idx=l;
                break;
            end
        end
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ch=datasets_header(k).header.chanlocs(ch_idx).labels;
        
        % index
        if datasets_header(k).header.datasize(3)==1
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_idx=1;
        else
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_idx=...
                min(option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_idx,header.datasize(3));
        end
        lissajous_update();
    end
    function lissajous_source2_epoch_pop_callback(~,~)
        k=get(handles.panel_lissajous_source2_epoch_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ep=k;
        lissajous_update();
    end
    function lissajous_source2_channel_pop_callback(~,~)
        k=get(handles.panel_lissajous_source2_channel_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_ch=...
            datasets_header(option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_dataset).header.chanlocs(k).labels;
        lissajous_update();
    end
    function lissajous_source2_index_pop_callback(~,~)
        k=get(handles.panel_lissajous_source2_index_pop,'value');
        option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_idx=k;
        lissajous_update();
    end
    function lissajous_source2_z_edt_callback(~,~)
        temp=str2double(get(handles.panel_lissajous_source2_z_edt,'String'));
        if ~isempty(temp) && isfinite(temp)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_z=temp;
        end
        lissajous_update();
    end
    function lissajous_source2_y_edt_callback(~,~)
        temp=str2double(get(handles.panel_lissajous_source2_y_edt,'String'));
        if ~isempty(temp) && isfinite(temp)
            option.ax{option.cnt_subfig}.content{option.cnt_content}.source2_y=temp;
        end
        lissajous_update();
    end

%% other function
    function Set_position(obj,position)
        set(obj,'Units','pixels');
        set(obj,'Position',position);
        set(obj,'Units','normalized');
    end
end