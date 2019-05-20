classdef FLW_electrode_location_assign<CLW_generic
    properties
        FLW_TYPE=1;
        h_file_selection;
        h_default_selection;
        h_file_edt;
    end
    
    methods
        function obj = FLW_electrode_location_assign(batch_handle)
            obj@CLW_generic(batch_handle,'assign location','chanlocs',...
                'Assign coordinates to channels whose labels match the labels in the ¡®chanlocs¡¯ file. The default setting is the coordinates with the standard International 10/20 labels');
            uicontrol('style','text','position',[35,480,250,20],...
                'string','Channel location filename:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            filepath=which('letswave7');
            [filepath,~,~]=fileparts(filepath);
            filepath=fullfile(filepath,'res','electrodes','spherical_locations','Standard-10-20-Cap81.locs');
            obj.h_file_edt=uicontrol('style','edit','position',[35,450,290,30],...
                'string','Standard-10-20-Cap81.locs','enable','off',...
                'userdata',filepath,'parent',obj.h_panel);
            obj.h_file_selection=uicontrol('style','pushbutton','position',[35,370,350,60],...
                'string','Select custom file with channel locations',...
                'parent',obj.h_panel);
            obj.h_default_selection=uicontrol('style','pushbutton','position',[340,450,40,30],...
                'string','Reset','parent',obj.h_panel);
            
            set(obj.h_default_selection,'callback',@obj.set_default);
            set(obj.h_file_selection,'callback',@obj.select_files);
            set(obj.h_file_edt,'backgroundcolor',[1,1,1]);
        end
        
        function set_default(obj,varargin)
            filepath=which('letswave7');
            [filepath,~,~]=fileparts(filepath);
            filepath=fullfile(filepath,'res','electrodes','spherical_locations','Standard-10-20-Cap81.locs');
            set(obj.h_file_edt,'string','Standard-10-20-Cap81.locs','userdata',filepath);
        end
        
        function select_files(obj,varargin)
            defualtname=get(obj.h_file_edt,'userdata');
            filterspec={'*.*'};
            [filename,pathname]=uigetfile(filterspec,'Select the file for channel location',defualtname);
            if ~isequal(filename,0)
                set(obj.h_file_edt,'string',filename,'userdata',fullfile(pathname,filename));
            end
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.filepath=get(obj.h_file_edt,'userdata');
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_file_edt,'userdata',option.filepath);
            [~,a,b]=fileparts(option.filepath);
            set(obj.h_file_edt,'string',[a,b]);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            %%%
            frag_code=[frag_code,'''filepath'',''',option.filepath,''','];
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
            
            channel_labels={header_in.chanlocs.labels};
            locs=readlocs(option.filepath);
            locs_labels={locs.labels};
            chanlocs=[];
            
            for chanpos=1:length(channel_labels)
                chanlocs(chanpos).labels=channel_labels{chanpos};
                idx=find(strcmpi(channel_labels(chanpos),locs_labels)==1);
                if isempty(idx)||isempty(locs(idx).X)
                    chanlocs(chanpos).topo_enabled=0;
                    chanlocs(chanpos).SEEG_enabled=0;
                    continue;
                end
                idx=idx(1);
                
                chanlocs(chanpos).theta=locs(idx).theta;
                chanlocs(chanpos).radius=locs(idx).radius;
                chanlocs(chanpos).sph_theta=locs(idx).sph_theta;
                chanlocs(chanpos).sph_phi=locs(idx).sph_phi;
                chanlocs(chanpos).sph_theta_besa=locs(idx).sph_theta_besa;
                chanlocs(chanpos).sph_phi_besa=locs(idx).sph_phi_besa;
                chanlocs(chanpos).X=locs(idx).X;
                chanlocs(chanpos).Y=locs(idx).Y;
                chanlocs(chanpos).Z=locs(idx).Z;
                chanlocs(chanpos).topo_enabled=1;
                chanlocs(chanpos).SEEG_enabled=0;
            end
            header_out.chanlocs=chanlocs;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.filepath=1;
            option.suffix='chanlocs';
            option.is_save=0;
            option=CLW_check_input(option,{'filepath','suffix','is_save'},varargin);
            
            lwdata_out.header=FLW_electrode_location_assign.get_header(lwdata_in.header,option);
            lwdata_out.data=lwdata_in.data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end