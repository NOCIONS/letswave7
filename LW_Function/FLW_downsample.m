classdef FLW_downsample<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Mout, like math_multiple, t-test
        FLW_TYPE=1;
        %properties
        h_x_label;
        h_y_label;
        h_z_label;
        h_x_dsratio_edit;
        h_y_dsratio_edit;
        h_z_dsratio_edit;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_downsample(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'Downsample signals','ds',...
                'Downsample signals (integer ratio)');
            %objects
            %X labels
            obj.h_x_label=uicontrol('style','text','position',[35,440,200,20],...
                'string','X-dimension downsample ratio :',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %x_dsratio_edit
            obj.h_x_dsratio_edit=uicontrol('style','edit',...
                'String','','value',0,'backgroundcolor',[1,1,1],...
                'position',[35,420,100,20],'parent',obj.h_panel);
            
            %Y labels
            obj.h_y_label=uicontrol('style','text','position',[35,380,200,20],...
                'string','Y-dimension downsample ratio :',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %y_dsratio_edit
            obj.h_y_dsratio_edit=uicontrol('style','edit',...
                'String','','value',0,'backgroundcolor',[1,1,1],...
                'position',[35,360,100,20],'parent',obj.h_panel);
            %Z labels
            obj.h_z_label=uicontrol('style','text','position',[35,320,200,20],...
                'string','Z-dimension downsample ratio :',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %x_dsratio_edit
            obj.h_z_dsratio_edit=uicontrol('style','edit',...
                'String','','value',0,'backgroundcolor',[1,1,1],...
                'position',[35,300,100,20],'parent',obj.h_panel);
        end
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            %
            option.x_dsratio=str2num(get(obj.h_x_dsratio_edit,'string'));
            option.y_dsratio=str2num(get(obj.h_y_dsratio_edit,'string'));
            option.z_dsratio=str2num(get(obj.h_z_dsratio_edit,'string'));
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            %
            set(obj.h_x_dsratio_edit,'String',num2str(option.x_dsratio));
            set(obj.h_y_dsratio_edit,'String',num2str(option.y_dsratio));
            set(obj.h_z_dsratio_edit,'String',num2str(option.z_dsratio));
        end
        
        %get the script for this operation
        %run this function, normally we will get a script 
        %with two lines as following 
        %      option=struct('suffix','demo','is_save',1);
        %      lwdata= FLW_Demo.get_lwdata(lwdata,option);
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            %%%
            if option.x_dsratio>1
                frag_code=[frag_code,'''x_dsratio'',',...
                    num2str(option.x_dsratio),','];
            end
            if option.y_dsratio>1
                frag_code=[frag_code,'''y_dsratio'',',...
                    num2str(option.y_dsratio),','];
            end
            if option.z_dsratio>1
                frag_code=[frag_code,'''z_dsratio'',',...
                    num2str(option.z_dsratio),','];
            end
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        
        function GUI_update(obj,batch_pre)
            header=batch_pre.lwdataset(1).header;
            if isempty(get(obj.h_x_dsratio_edit,'String'))
                set(obj.h_x_dsratio_edit,'String','1');
            end
            if isempty(get(obj.h_y_dsratio_edit,'String'))
                set(obj.h_y_dsratio_edit,'String','1');
            end
            if isempty(get(obj.h_z_dsratio_edit,'String'))
                set(obj.h_z_dsratio_edit,'String','1');
            end
            if header.datasize(6)==1
                set(obj.h_x_dsratio_edit,'String','1');
                set(obj.h_x_dsratio_edit,'Visible','off');
                set(obj.h_x_label,'Visible','off');
            end
            if header.datasize(5)==1
                set(obj.h_y_dsratio_edit,'String','1');
                set(obj.h_y_dsratio_edit,'Visible','off');
                set(obj.h_y_label,'Visible','off');
            end
            if header.datasize(4)==1
                set(obj.h_z_dsratio_edit,'String','1');
                set(obj.h_z_dsratio_edit,'Visible','off');
                set(obj.h_z_label,'Visible','off');
            end
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            %check that ratios are integer values
            if floor(option.x_dsratio)==option.x_dsratio
            else
                disp('!!! X downsample ratio is not an integer!');
                return;
            end
            if floor(option.y_dsratio)==option.y_dsratio
            else
                disp('!!! Y downsample ratio is not an integer!');
                return;
            end
            if floor(option.z_dsratio)==option.z_dsratio
            else
                disp('!!! Z downsample ratio is not an integer!');
                return;
            end
            %update header
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            %set xvector,yvector,zvector
            zvector=1:option.z_dsratio:header_in.datasize(4);
            yvector=1:option.y_dsratio:header_in.datasize(5);
            xvector=1:option.x_dsratio:header_in.datasize(6);
            %update datasize
            header_out.datasize(4)=length(zvector);
            header_out.datasize(5)=length(yvector);
            header_out.datasize(6)=length(xvector);
            %update SR
            header_out.xstep=header_in.xstep*option.x_dsratio;
            header_out.ystep=header_in.ystep*option.y_dsratio;
            header_out.zstep=header_in.zstep*option.z_dsratio;
            %
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            %default values
            option.x_dsratio=1;
            option.y_dsratio=1;
            option.z_dsratio=1;
            option.suffix='ds';
            option.is_save=0;
            option=CLW_check_input(option,{'x_dsratio','y_dsratio','z_dsratio',...
                'suffix','is_save'},varargin);
            inheader=lwdata_in.header;
            header=FLW_downsample.get_header(inheader,option);
            data=lwdata_in.data;
            %%%
            %set xvector,yvector,zvector
            zvector=1:option.z_dsratio:inheader.datasize(4);
            yvector=1:option.y_dsratio:inheader.datasize(5);
            xvector=1:option.x_dsratio:inheader.datasize(6);
            %update data
            data=data(:,:,:,zvector,yvector,xvector);
            %%%
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end