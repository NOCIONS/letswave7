classdef FLW_selection<CLW_generic
    properties
        FLW_TYPE=1;
        h_selection_items_pop;
        h_old_list;
        h_new_list;
        
        h_add_top_btn;
        h_add_bottom_btn;
        h_add_all_btn;
        h_insert_btn;
        
        h_sort_asc_btn;
        h_sort_desc_btn;
        h_sort_up_btn;
        h_sort_down_btn;
        
        
        h_remove_btn;
        h_remove_all_btn;
        
        h_select_odd_btn;
        h_select_even_btn;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_selection(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,affix_name,help_str)
            
            icon=load('icon.mat');
            obj@CLW_generic(batch_handle,'Selection','sel_chan',...
                'Selection the signal by channel/epoch/index.');
            uicontrol('style','text','position',[10,495,150,20],...
                'string','Selection Items:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_selection_items_pop=uicontrol('style','popupmenu',...
                'String',{'epoch','channel','index'},'value',2,...
                'callback',@obj.item_Changed,'position',[100,487,150,30],...
                'parent',obj.h_panel);
            
            obj.h_old_list=uicontrol('style','listbox','min',0,'max',2,...
                'position',[28,160,120,320],'parent',obj.h_panel);
            obj.h_new_list=uicontrol('style','listbox','min',0,'max',2,...
                'position',[255,160,120,320],'parent',obj.h_panel);
            
            
            obj.h_add_top_btn=uicontrol('style','pushbutton',...
                'string','Add Top','callback',@obj.reference_Callback,...
                'position',[159,450,80,28],'parent',obj.h_panel);
            obj.h_add_bottom_btn=uicontrol('style','pushbutton',...
                'string','Add Bottom','callback',@obj.reference_Callback,...
                'position',[159,424,80,28],'parent',obj.h_panel);
            obj.h_add_all_btn=uicontrol('style','pushbutton',...
                'string','Add All','callback',@obj.reference_Callback,...
                'position',[159,398,80,28],'parent',obj.h_panel);
            obj.h_insert_btn=uicontrol('style','pushbutton',...
                'string','insert','callback',@obj.reference_Callback,...
                'position',[159,372,80,28],'parent',obj.h_panel);
            
            obj.h_sort_asc_btn=uicontrol('style','pushbutton',...
                'string','Sort Asc.','callback',@obj.reference_Callback,...
                'position',[159,320,80,28],'parent',obj.h_panel);
            obj.h_sort_desc_btn=uicontrol('style','pushbutton',...
                'string','Sort Desc.','callback',@obj.reference_Callback,...
                'position',[159,294,80,28],'parent',obj.h_panel);
            obj.h_sort_up_btn=uicontrol('style','pushbutton',...
                'CData',icon.icon_dataset_up,'callback',@obj.reference_Callback,...
                'position',[159,268,80,28],'parent',obj.h_panel);
            obj.h_sort_down_btn=uicontrol('style','pushbutton',...
                'CData',icon.icon_dataset_down,'callback',@obj.reference_Callback,...
                'position',[159,242,80,28],'parent',obj.h_panel);
            
            
            obj.h_remove_btn=uicontrol('style','pushbutton',...
                'string','Remove','callback',@obj.reference_Callback,...
                'position',[159,200,80,28],'parent',obj.h_panel);
            obj.h_remove_all_btn=uicontrol('style','pushbutton',...
                'string','Remove All','callback',@obj.reference_Callback,...
                'position',[159,174,80,28],'parent',obj.h_panel);
            
            
            obj.h_select_odd_btn=uicontrol('style','pushbutton',...
                'string','Select Odd','callback',@obj.reference_Callback,...
                'position',[28,133,60,20],'parent',obj.h_panel);
            obj.h_select_even_btn=uicontrol('style','pushbutton',...
                'string','Select Even','callback',@obj.reference_Callback,...
                'position',[90,133,60,20],'parent',obj.h_panel);
        end
        
        function item_Changed(obj,varargin)
            st_value=get(obj.h_arrange_items_pop,'value');
            str=get(obj.h_affix_edit,'string');
            if sum(strcmp(str,{'sel_epoch','sel_channel','sel_index'}))
                switch(st_value)
                    case 1
                        set(obj.h_affix_edit,'string','sel_epoch');
                    case 2
                        set(obj.h_affix_edit,'string','sel_chan');
                    case 3
                        set(obj.h_affix_edit,'string','sel_idx');
                end
            end
        end
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            %to be edited...
            
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            %to be edited...
            
        end
        
        %get the script for this operation
        %run this function, normally we will get a script 
        %with two lines as following 
        %      option=struct('affix','demo','is_save',1);
        %      lwdata= FLW_Demo.get_lwdata(lwdata,option);
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            %to be edited...
            
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function GUI_update(obj,batch_pre)    
            
        
            old_list=get(obj.h_old_list,'String');
            if isempty(old_list)
                old_idx=[];
            else
                old_idx=old_list(get(obj.h_old_list,'Value'));
            end
            new_list=get(obj.h_new_list,'String');
            if isempty(new_list)
                new_idx=[];
            else
                new_idx=new_list(get(obj.h_new_list,'Value'));
            end
            
            lwdataset=batch_pre.lwdataset;
            channel_labels={lwdataset(1).header.chanlocs.labels};
            set(obj.h_not_equal_txt,'visible','off');
             for dataset_pos=2:length(lwdataset)
                channel_labels1={lwdataset(dataset_pos).header.chanlocs.labels};
                channel_labels2= intersect(channel_labels,channel_labels1,'stable');
                if length(channel_labels2)<length(channel_labels)||...
                        length(channel_labels2)<length(channel_labels)
                    set(obj.h_not_equal_txt,'visible','on');
                end
                channel_labels=channel_labels2;
            end
            if isempty(channel_labels)
                error('***No common channels.***')
            end
            set(obj.h_reference_list,'String',channel_labels);
            set(obj.h_apply_list,'String',channel_labels);
            
            
            [~,~,idx] = intersect(old_idx,channel_labels,'stable');
            set(obj.h_reference_list,'value',idx);
            [~,~,idx] = intersect(new_idx,channel_labels,'stable');
            set(obj.h_apply_list,'value',idx);
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
    
        
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            %to be edited...
            
            if ~isempty(option.affix)
                header_out.name=[option.affix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.affix='demo';
            option.is_save=0;
            option=CLW_check_input(option,{'affix','is_save'},varargin);
            header=FLW_Demo.get_header(lwdata_in.header,option);
            
            data=lwdata_in.data;
            %to be edited...
            
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end