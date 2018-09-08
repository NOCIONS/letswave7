classdef CLW_generic<handle
    %CLW_generic
    properties
        h_tab;
        h_panel;
        index_num=1;
        is_selected=1;
        
        h_txt_cmt;
        h_btn_script;
        h_suffix_txt;
        h_suffix_edit;
        h_is_save_chx;
        h_title_str;
        h_help_str;
        lwdataset;
        virtual_filelist;
    end
    
    methods
        function obj = CLW_generic(batch_handle,fun_name,suffix_name,help_str)
            if ispc
            obj.h_title_str=['=======',class(obj),'======='];
            else
            obj.h_title_str=['==========',class(obj),'=========='];
            end
            obj.h_help_str=help_str;
            
            obj.h_tab = uicontrol(batch_handle.tab_panel,'style','pushbutton',...
                'string',fun_name);
            obj.h_panel=uipanel(batch_handle.fig,...
                'units','pixels','position',[99,45,421,526]);
            
            obj.h_txt_cmt = uicontrol('parent',obj.h_panel,'style','edit','max',2,'Enable','inactive',...
                'position',[5,5,305,120],'HorizontalAlignment','left',...
                'backgroundcolor',[1,1,1]);
            set(obj.h_txt_cmt,'string',{obj.h_title_str,obj.h_help_str});           
            obj.h_suffix_txt=uicontrol('style','text','position',[315,100,40,20],...
                'string','prefix:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_suffix_edit=uicontrol('style','edit','position',[315,80,100,25],...
                'HorizontalAlignment','left','string',suffix_name,...
                'backgroundcolor',[1,1,1],'parent',obj.h_panel);
            obj.h_is_save_chx=uicontrol('style','checkbox','value',1,...
                'position',[315,50,100,30],'string','save','parent',obj.h_panel);
            obj.h_btn_script = uicontrol('style','pushbutton',...
                'String','Script','position',[315,5,100,35],...
                'parent',obj.h_panel,'Callback',@obj.view_Script);
            obj.virtual_filelist=struct('filename',{},'header',{});
        end
                
        function option=get_option(obj)
            option=[];
            option.suffix=get(obj.h_suffix_edit,'string');
            option.is_save=get(obj.h_is_save_chx,'value');
            option.function=class(obj);
        end
        
        function set_option(obj,option)
            set(obj.h_suffix_edit,'string',option.suffix);
            set(obj.h_is_save_chx,'value',option.is_save);
        end
        
        function GUI_update(obj,batch_pre)
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
        
        function header_update(obj,batch_pre)
            obj.virtual_filelist=batch_pre.virtual_filelist;
            lwdataset=batch_pre.lwdataset;
            option=get_option(obj);
            for data_pos=1:length(lwdataset)
                %obj.lwdataset(data_pos).header = obj.get_header(lwdataset(data_pos).header,option);
                %evalc is used to block the information in Command Window 
                evalc('obj.lwdataset(data_pos).header = obj.get_header(lwdataset(data_pos).header,option);');
                if option.is_save
                    obj.virtual_filelist(end+1)=struct(...
                        'filename',obj.lwdataset(data_pos).header.name,...
                        'header',obj.lwdataset(data_pos).header);
                end
            end
        end
        
        function str=get_Script(obj,frag_code,option)
            temp='option=struct(';
            temp=[temp,frag_code];
            temp=[temp,'''suffix'',''',option.suffix,''','];
            temp=[temp,'''is_save'',',num2str(option.is_save)];
            temp=[temp,');'];
            switch obj.FLW_TYPE
                case 1 % 1 for the function dealing with single dataset (1in-1out)
                    str=[{temp},{['lwdata= ',class(obj),'.get_lwdata(lwdata,option);']}];
                case 2% 2 for the function with Nin-1out, like merge
                    str=[{temp},{['lwdata= ',class(obj),'.get_lwdata(lwdataset,option);']}];
                case 3% 3 for the function with 1in-Nout, like segmentation_separate
                    str=[{temp},{['lwdataset= ',class(obj),'.get_lwdataset(lwdata,option);']}];
                case 4% 4 for the function with Nin-Mout, like math_multiple, t-test
                    str=[{temp},{['lwdataset= ',class(obj),'.get_lwdataset(lwdataset,option);']}];
            end
        end
        
        function str=get_Script_batch(obj,frag_code,option)
            temp='option=struct(';
            temp=[temp,frag_code];
            temp=[temp,'''suffix'',''',option.suffix,''','];
            temp=[temp,'''is_save'',',num2str(option.is_save)];
            temp=[temp,');'];
            str=[{temp},{['lwdataset= ',class(obj),'.get_lwdataset(lwdataset,option);']}];
        end
        
        function view_Script(obj,varargin)
            script=get_Script(obj);
            CLW_show_script(script);
        end        
    end
end