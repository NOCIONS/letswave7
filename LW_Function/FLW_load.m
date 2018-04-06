classdef FLW_load<CLW_generic
    %FLW_load
    properties
        FLW_TYPE=0;
        
        h_file_list;
        h_btn_add;
        h_btn_del;
        h_btn_up;
        h_btn_down;
    end
    
    methods
        function obj = FLW_load(batch_handle)
            obj@CLW_generic(batch_handle,'load',' ','Load the letswave data files.');
            set(obj.h_suffix_txt,'visible','off');
            set(obj.h_suffix_edit,'visible','off');
            set(obj.h_is_save_chx,'visible','off');
            
            
            icon=load('icon.mat');
            obj.h_file_list=uicontrol('style','listbox','max',2,...
                'String',{},'backgroundcolor',[1,1,1],'value',[],...
                'position',[5,250,408,268],'parent',obj.h_panel);
            obj.h_btn_add=uicontrol('style','pushbutton',...
                'position',[30,200,60,40],'parent',obj.h_panel,...
                'CData',icon.icon_dataset_add,'callback',@obj.dataset_Add);
            obj.h_btn_del=uicontrol('style','pushbutton',...
                'position',[130,200,60,40],'parent',obj.h_panel,...
                'CData',icon.icon_dataset_del,'callback',@obj.dataset_Del);
            obj.h_btn_up=uicontrol('style','pushbutton',...
                'position',[230,200,60,40],'parent',obj.h_panel,...
                'CData',icon.icon_dataset_up,'callback',@obj.dataset_Up);
            obj.h_btn_down=uicontrol('style','pushbutton',...
                'position',[330,200,60,40],'parent',obj.h_panel,...
                'CData',icon.icon_dataset_down,'callback',@obj.dataset_Down);
        end
        
        function add_file(obj,filename)
            filename=cellstr(filename);
            st=get(obj.h_file_list,'String');
            st_userdata=get(obj.h_file_list,'Userdata');
            for data_pos=1:length(filename)
                [p,n,e]=fileparts(filename{data_pos});
                if isempty(p)
                    p=pwd;
                end
                if isempty(e)
                    e='.lw6';
                end
                switch e
                    case '.lw6'
                        if strcmp(p,pwd) && sum(strcmp(n,{obj.virtual_filelist.filename}))
                            st{end+1}=['<HTML><BODY color="red">',n];
                        else
                            st{end+1}=n;
                        end
                    
                    case {'.lw4','.lw5'}
                    st{end+1}=['<HTML><BODY color="blue">',n,e];
                end
                st_userdata{end+1}=fullfile(p,[n,e]);
            end
            set(obj.h_file_list,'String',st);
            set(obj.h_file_list,'Userdata',st_userdata);
        end
        
        function dataset_Add(obj,varargin)
            [FileName,PathName] = GLW_getfile({obj.virtual_filelist.filename});
            if(PathName~=0)
                filename=cell(1,length(FileName));
                for k=1:length(FileName)
                filename{k}=fullfile(PathName,FileName{k});
                end
                obj.add_file(filename);
            end
        end
        
        function dataset_Del(obj,varargin)
            st=get(obj.h_file_list,'String');
            if ~isempty(st)
                index_all=1:length(st);
                index_selected=get(obj.h_file_list,'value');
                if isempty(index_selected)
                    warndlg('No file is selected!');
                    return;
                end
                index_remain=setdiff(index_all,index_selected);
                set(obj.h_file_list,'value',1);
                
                if index_selected(1)<=length(index_remain)
                    set(obj.h_file_list,'value',index_selected(1));
                else
                    set(obj.h_file_list,'value',max(1,length(index_remain)));
                end
                set(obj.h_file_list,'String',st(index_remain));
                st_userdata=get(obj.h_file_list,'userdata');
                set(obj.h_file_list,'userdata',st_userdata(index_remain));
            else
                warndlg('No file is selected!');
            end
        end
        
        function dataset_Up(obj,varargin)
            index=get(obj.h_file_list,'value');
            st=get(obj.h_file_list,'String');
            if isempty(st) || index(1)==1 
                return;
            else
                index_unselected=setdiff(1:length(st),index);
                index_order=zeros(1,length(st));
                index_order(index-1)=index;
                for k=1:length(index_order)
                    if index_order(k)==0
                        index_order(k)=index_unselected(1);
                        index_unselected=index_unselected(2:end);
                    end
                end
                set(obj.h_file_list,'String',st(index_order));
                st_userdata=get(obj.h_file_list,'userdata');
                set(obj.h_file_list,'userdata',st_userdata(index_order));
                set(obj.h_file_list,'value',index-1);
            end
        end
        
        function dataset_Down(obj,varargin)
            index=get(obj.h_file_list,'value');
            st=get(obj.h_file_list,'String');
            if isempty(st) || index(end)==length(st)
                return;
            else
                index_unselected=setdiff(1:length(st),index);
                index_order=zeros(1,length(st));
                index_order(index+1)=index;
                for k=1:length(index_order)
                    if index_order(k)==0
                        index_order(k)=index_unselected(1);
                        index_unselected=index_unselected(2:end);
                    end
                end
                set(obj.h_file_list,'String',st(index_order));
                st_userdata=get(obj.h_file_list,'userdata');
                set(obj.h_file_list,'userdata',st_userdata(index_order));
                set(obj.h_file_list,'value',index+1);
            end
        end
        
        function GUI_update(obj,batch_pre)
            obj.virtual_filelist=batch_pre.virtual_filelist;
            st=[];
            st_userdata=[];
            filename=get(obj.h_file_list,'Userdata');
            for data_pos=1:length(filename)
                [p,n,e]=fileparts(filename{data_pos});
                if isempty(p)
                    p=pwd;
                end
                if isempty(e)
                    e='.lw6';
                end
                switch e
                    case '.lw6'
                        if strcmp(p,pwd) && sum(strcmp(n,{obj.virtual_filelist.filename}))
                            st{end+1}=['<HTML><BODY color="red">',n];
                        else
                            if exist(fullfile(p,[n,'.lw6']),'file')~=2
                                error(['***file [',fullfile(p,[n,'.lw6']),'] does not exist any more.***']);
                            end
                            st{end+1}=n;
                        end
                    case '.lw5'
                     if exist(fullfile(p,[n,e]),'file')~=2
                         error(['***file [',fullfile(p,[n,e]),'] does not exist any more.***']);
                     end
                     st{end+1}=['<HTML><BODY color="blue">',n,e];
                end
                st_userdata{end+1}=fullfile(p,[n,e]);
            end
            set(obj.h_file_list,'String',st);
            set(obj.h_file_list,'Userdata',st_userdata);
            
            
%             st_userdata=get(obj.h_file_list,'userdata');
%             for data_pos=1:length(st_userdata)
%                 [p,n]=fileparts(char(st_userdata{data_pos}));
%                 if isempty(p)
%                     p=pwd;
%                 end
%                 if strcmp(p,pwd) && sum(strcmp(n,{obj.virtual_filelist.filename}))
%                 else
%                      if exist(fullfile(p,[n,'.lw6']),'file')~=2
%                          error(['***file [',fullfile(p,[n,'.lw6']),'] does not exist any more.***']);
%                      end
%                 end
%             end
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
        
        function header_update(obj,batch_pre)
            if ~isempty(batch_pre)
                obj.virtual_filelist=batch_pre.virtual_filelist;
            end
            obj.lwdataset=[];
            st=get(obj.h_file_list,'userdata');
            for k=1:length(st)
                [p,n]=fileparts(char(st{k}));
                if isempty(p)
                    p=pwd;
                end
                file_index=strcmp(n,{obj.virtual_filelist.filename});
                if sum(file_index)==0
                    option=struct('filename',char(st{k}));
                    evalc('obj.lwdataset(k).header = obj.get_header([],option);');
                else
                    file_index=find(file_index);
                    obj.lwdataset(k).header = obj.virtual_filelist(file_index(end)).header;
                end
            end
            
            if isempty(obj.lwdataset(k))
                error('***No files are selected.***')
            end
        end
        
        function option=get_option(obj)
            option.filename=cellstr(get(obj.h_file_list,'userdata'));
            option.function='FLW_load';
        end
        
        function set_option(obj,option)
            filename=cellstr(option.filename);
            st={};
            st_userdata=[];
            for data_pos=1:length(filename)
                [p,n]=fileparts(filename{data_pos});
                if isempty(p)
                    p=pwd;
                end
                st=[st,cellstr(n)];
                st_userdata=[st_userdata,cellstr(fullfile(p,[n,'.lw6']))];
            end
            set(obj.h_file_list,'String',st);
            set(obj.h_file_list,'Userdata',st_userdata);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            str={};
            for k=1:length(option.filename)
                temp='option=struct(';
                temp=[temp,'''filename'',''',option.filename{k},''''];
                temp=[temp,');'];
                str=[str,{temp}];
                str=[str,{'lwdata= FLW_load.get_lwdata(option);'}];
            end
        end
        
        function str=get_Script_set(obj)
            option=get_option(obj);
            str={};
            temp='option=struct(';
            temp=[temp,'''filename'',{{'];
            for k=1:length(option.filename)
                temp=[temp,'''',option.filename{k},''''];
                if k~=length(option.filename)
                    temp=[temp,','];
                end
            end
            temp=[temp,'}}'];
            temp=[temp,');'];
            str=[str,{temp}];
            str=[str,{'lwdataset= FLW_load.get_lwdataset(option);'}];
        end
    end
    
    methods (Static = true)
        function header_out= get_header(~,option)
            header_out= CLW_load_header(option.filename);
        end
        
        function lwdata_out= get_lwdata(varargin)
            option.filename='';
            option=CLW_check_input(option,{'filename'},varargin);
            if isempty(option.filename) && ~ischar(option.filename)
                error('***invalid filename input.***');
            end
            [lwdata_out.header,lwdata_out.data] = CLW_load(option.filename);
        end
        
        function lwdataset_out = get_lwdataset(varargin)
            option.filename='';
            option=CLW_check_input(option,{'filename'},varargin);
            if isempty(option.filename) && ~iscell(option.filename)
                error('***invalid filename input.***');
            end
            for k=1:length(option.filename)
                [lwdataset_out(k).header,lwdataset_out(k).data] = CLW_load(option.filename{k});
            end
        end
    end
end