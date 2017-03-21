classdef CLW_permutation<CLW_generic
    properties
        h_alpha_txt;
        h_alpha_edit;
        h_permutation_test_chk;
        h_permutation_panel;
        h_threshold_edit;
        h_number_edit;
        h_show_progress_chk;
        
        h_multiple_sensor_panel;
        h_multiple_sensor_chk;
        h_chan_dist_txt;
        h_chan_dist_edit;
        h_chan_dist_btn;
    end
    
    methods
        function obj = CLW_permutation(batch_handle,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,fun_name,suffix_name,help_str);
            
            obj.h_alpha_txt=uicontrol('style','text','position',[35,380,200,20],...
                'string','Alpha level:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_alpha_edit=uicontrol('style','edit','String','0.05',...
                'backgroundcolor',1*[1,1,1],'position',[35,357,200,25],...
                'parent',obj.h_panel);
            
            
            obj.h_permutation_panel=uipanel('unit','pixels',...
                'position',[5,135,410,130],'parent',obj.h_panel,...
                'title','Cluster-Based Permutation Test');
            obj.h_permutation_test_chk=uicontrol('style','checkbox',...
                'String','Enable',...
                'position',[15,90,350,25],'callback',@obj.showpanel,...
                'parent',obj.h_permutation_panel);
            
            uicontrol('style','text','position',[15,70,200,20],...
                'string','Cluster threshold:','tag','permute',...
                'HorizontalAlignment','left','parent',obj.h_permutation_panel);
            obj.h_threshold_edit=uicontrol('style','edit','String','0.05',...
                'position',[15,50,220,25],'tag','permute',...
                'backgroundcolor',1*[1,1,1],'parent',obj.h_permutation_panel);
            
            
            uicontrol('style','text','position',[15,25,200,20],...
                'string','Number of permutation:','tag','permute',...
                'HorizontalAlignment','left','parent',obj.h_permutation_panel);
            obj.h_show_progress_chk=uicontrol('style','checkbox',...
                'String','show progress','value',1,...
                'position',[135,25,100,25],'tag','permute',...
                'parent',obj.h_permutation_panel);
            obj.h_number_edit=uicontrol('style','edit','String',2000,...
                'position',[15,5,220,25],'tag','permute',...
                'backgroundcolor',1*[1,1,1],'parent',obj.h_permutation_panel);
            
            
            obj.h_multiple_sensor_panel=uipanel( 'unit','pixels',...
                'title','multiple sensor analysis',...
                'position',[265,5,135,110],'parent',obj.h_permutation_panel);
            obj.h_multiple_sensor_chk=uicontrol('style','checkbox',...
                'String','Enable','value',0,'callback',@obj.showpanel2,...
                'position',[5,73 ,135,25],'tag','permute',...
                'parent',obj.h_multiple_sensor_panel);
            
            obj.h_chan_dist_txt=uicontrol('style','text','position',[5,55,120,20],...
                'string','connection threshold:','tag','permute',...
                'HorizontalAlignment','left','parent',obj.h_multiple_sensor_panel);
            obj.h_chan_dist_edit=uicontrol('style','edit','String','0',...
                'position',[5,35,120,25],'tag','permute',...
                'backgroundcolor',1*[1,1,1],'parent',obj.h_multiple_sensor_panel);
            obj.h_chan_dist_btn=uicontrol('style','pushbutton',...
                'String','Set Threshold','callback',@(src,eventdata)CLW_figure_dist(obj),...
                'position',[5,5,120,25],'tag','permute',...
                'parent',obj.h_multiple_sensor_panel);
            
            h=findobj(obj.h_permutation_panel,'tag','permute');
            set(h,'enable','off');
        end
        
        function showpanel(obj,varargin)
            h=findobj(obj.h_permutation_panel,'tag','permute');
            if get(obj.h_permutation_test_chk,'value')
                set(h,'enable','on');
                if ~get(obj.h_multiple_sensor_chk,'value')
                    set(obj.h_chan_dist_txt,'enable','off');
                    set(obj.h_chan_dist_edit,'enable','off');
                    set(obj.h_chan_dist_btn,'enable','off');
                end
            else
                set(h,'enable','off');
            end
        end
        
        function showpanel2(obj,varargin)
            if ~get(obj.h_multiple_sensor_chk,'value')
                set(obj.h_chan_dist_txt,'enable','off');
                set(obj.h_chan_dist_edit,'enable','off');
                set(obj.h_chan_dist_btn,'enable','off');
            else
                set(obj.h_chan_dist_txt,'enable','on');
                set(obj.h_chan_dist_edit,'enable','on');
                set(obj.h_chan_dist_btn,'enable','on');
            end
        end
        
        function GUI_update(obj,batch_pre)
            obj.lwdataset=batch_pre.lwdataset;
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.alpha=str2num(get(obj.h_alpha_edit,'string'));
            option.permutation=get(obj.h_permutation_test_chk,'value');
            option.cluster_threshold=str2num(get(obj.h_threshold_edit,'string'));
            option.num_permutations=str2num(get(obj.h_number_edit,'string'));
            option.show_progress=get(obj.h_show_progress_chk,'value');
            
            option.multiple_sensor=get(obj.h_multiple_sensor_chk,'value');
            option.chan_dist=str2num(get(obj.h_chan_dist_edit,'string'));
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_alpha_edit,'string',num2str(option.alpha));
            
            set(obj.h_permutation_test_chk,'value',option.permutation);
            set(obj.h_alpha_edit,'string',num2str(option.alpha));
            set(obj.h_threshold_edit,'string',num2str(option.cluster_threshold));
            set(obj.h_number_edit,'string',num2str(option.num_permutations));
            set(obj.h_show_progress_chk,'value',option.show_progress);
            set(obj.h_multiple_sensor_chk,'value',option.multiple_sensor);
            set(obj.h_chan_dist_edit,'string',num2str(option.chan_dist));
            
            obj.showpanel2();
            obj.showpanel();
        end
        
        function frag_code=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''alpha'',',...
                num2str(option.alpha),','];
            if option.permutation
                frag_code=[frag_code,'''permutation'',',...
                    num2str(option.permutation),','];
                frag_code=[frag_code,'''cluster_threshold'',',...
                    num2str(option.cluster_threshold),','];
                frag_code=[frag_code,'''num_permutations'',',...
                    num2str(option.num_permutations),','];
                frag_code=[frag_code,'''show_progress'',',...
                    num2str(option.show_progress),','];
                if option.multiple_sensor
                    frag_code=[frag_code,'''multiple_sensor'',',...
                        num2str(option.multiple_sensor),','];
                    frag_code=[frag_code,'''chan_dist'',',...
                        num2str(option.chan_dist),','];
                end
            end
            
        end
    end
end