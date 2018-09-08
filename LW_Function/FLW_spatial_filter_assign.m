classdef FLW_spatial_filter_assign<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Mout, like math_multiple, t-test
        FLW_TYPE=1;
        %properties
        h_filepath;
        h_file_edit;
        h_sele_btn;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_spatial_filter_assign(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'assign filter','assign',...
                'Assign an existing ICA/PCA mix/unmix spatial matrix of a given dataset to another dataset.');
            uicontrol('style','text','position',[35,430,300,20],...
                'string','load the data set the mix/unmix matrix:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_file_edit=uicontrol('style','edit','position',[35,370,250,55],...
                'Max',3,'string','','userdata','',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_sele_btn=uicontrol('style','pushbutton','position',[305,370,80,55],...
                'string','select','parent',obj.h_panel);
            set(obj.h_sele_btn,'Callback',@obj.btn_selection);
            set(obj.h_file_edit,'background',[1,1,1]);
        end
        
        function btn_selection(obj,varargin)
            [FileName,PathName] = GLW_getfile({obj.virtual_filelist.filename});
            if(PathName~=0)
                filename=fullfile(PathName,FileName{1});
                set(obj.h_file_edit,'string',FileName{1});
                set(obj.h_file_edit,'userdata',filename);
            end
        end
        
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.source=get(obj.h_file_edit,'userdata');
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            [~,n]=fileparts(option.source);
            set(obj.h_file_edit,'string',n);
            set(obj.h_file_edit,'userdata',option.source);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            %%%
            frag_code=[frag_code,'''source'',''',option.source,''','];
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function GUI_update(obj,batch_pre)
            GUI_update@CLW_generic(obj,batch_pre);
            st=get(obj.h_file_edit,'userdata');
            [p,n]=fileparts(st);
            if isempty(p)
                p=pwd;
            end
            file_index=strcmp(n,{obj.virtual_filelist.filename});
            if sum(file_index)==0
                if ~exist(st,'file')
                    set(obj.h_file_edit,'string','');
                    set(obj.h_file_edit,'userdata','');
                end
            end
        end
        
        function header_update(obj,batch_pre)
            header_update@CLW_generic(obj,batch_pre);
            st=get(obj.h_file_edit,'userdata');
            [p,n]=fileparts(st);
            if isempty(p)
                p=pwd;
            end
            file_index=strcmp(n,{obj.virtual_filelist.filename});
            if sum(file_index)==0
                if ~exist(st,'file')
                    error('***No files are selected.***')
                end
            end
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            header_source=CLW_load_header(option.source);
            [option.unmix_matrix,option.mix_matrix]=...
                CLW_get_mix_unmix_matrix(header_source);
            if isempty(option.unmix_matrix) && isempty(option.mix_matrix)
                error('***No unmix/mix matrix is loaded.***');
            end
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            %default values
            option.suffix='assign';
            option.source='';
            option.is_save=0;
            option=CLW_check_input(option,{'source','suffix','is_save'},varargin);
            lwdata_out.header=FLW_spatial_filter_assign.get_header(lwdata_in.header,option);
            lwdata_out.data=lwdata_in.data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end