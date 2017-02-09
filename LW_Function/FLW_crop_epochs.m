classdef FLW_crop_epochs<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Mout, like math_multiple, t-test
        FLW_TYPE=1;
        %properties
        h_xcrop_chk;
        h_xstart_edit;
        h_xend_edit;
        h_xsize_edit;
        h_ycrop_chk;
        h_ystart_edit;
        h_yend_edit;
        h_ysize_edit;
        h_zcrop_chk;
        h_zstart_edit;
        h_zend_edit;
        h_zsize_edit;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_crop_epochs(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'Crop signals along X/Y/Z dimension(s)','crop',...
                'Crop signals along X/Y/Z dimension(s).');
            %objects
            %xcrop_chk
            obj.h_xcrop_chk=uicontrol('style','checkbox',...
                'String','Crop X dimension','value',1,...
                'position',[35,480,150,30],'parent',obj.h_panel);
            %labels
            uicontrol('style','text','position',[35,460,100,20],...
                'string','Start:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            uicontrol('style','text','position',[140,460,100,20],...
                'string','End:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            uicontrol('style','text','position',[245,460,100,20],...
                'string','Size:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %xstart_edit
            obj.h_xstart_edit=uicontrol('style','edit',...
                'String','0',...
                'value',0,'HorizontalAlignment','left',...
                'position',[35,440,100,20],'parent',obj.h_panel);
            %xend_edit
            obj.h_xend_edit=uicontrol('style','edit',...
                'String','0','HorizontalAlignment','left',...
                'value',0,'callback',@obj.item_end_changed,...
                'position',[140,440,100,20],'parent',obj.h_panel);
            %xsize_edit
            obj.h_xsize_edit=uicontrol('style','edit',...
                'String','','HorizontalAlignment','left',...
                'value',0,'callback',@obj.item_size_changed,...
                'position',[245,440,100,20],'parent',obj.h_panel);

            %ycrop_chk
            obj.h_ycrop_chk=uicontrol('style','checkbox',...
                'String','Crop Y dimension','value',0,...
                'position',[35,400,150,30],'parent',obj.h_panel);
            %labels
            uicontrol('style','text','position',[35,380,100,20],...
                'string','Start:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            uicontrol('style','text','position',[140,380,100,20],...
                'string','End:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            uicontrol('style','text','position',[245,380,100,20],...
                'string','Size:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %ystart_edit
            obj.h_ystart_edit=uicontrol('style','edit',...
                'String','0','HorizontalAlignment','left',...
                'value',0,...
                'position',[35,360,100,20],'parent',obj.h_panel);
            %yend_edit
            obj.h_yend_edit=uicontrol('style','edit',...
                'String','0','HorizontalAlignment','left',...
                'value',0,'callback',@obj.item_end_changed,...
                'position',[140,360,100,20],'parent',obj.h_panel);
            %ysize_edit
            obj.h_ysize_edit=uicontrol('style','edit',...
                'String','','HorizontalAlignment','left',...
                'value',0,'callback',@obj.item_size_changed,...
                'position',[245,360,100,20],'parent',obj.h_panel);

            %zcrop_chk
            obj.h_zcrop_chk=uicontrol('style','checkbox',...
                'String','Crop Z dimension','value',0,...
                'position',[35,320,150,30],'parent',obj.h_panel);
            %labels
            uicontrol('style','text','position',[35,300,100,20],...
                'string','Start:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            uicontrol('style','text','position',[140,300,100,20],...
                'string','End:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            uicontrol('style','text','position',[245,300,100,20],...
                'string','Size:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %zstart_edit
            obj.h_zstart_edit=uicontrol('style','edit',...
                'String','0','HorizontalAlignment','left',...
                'value',0,...
                'position',[35,280,100,20],'parent',obj.h_panel);
            %zend_edit
            obj.h_zend_edit=uicontrol('style','edit',...
                'String','0','HorizontalAlignment','left',...
                'value',0,'callback',@obj.item_end_changed,...
                'position',[140,280,100,20],'parent',obj.h_panel);
            %zsize_edit
            obj.h_zsize_edit=uicontrol('style','edit',...
                'String','','HorizontalAlignment','left',...
                'value',0,'callback',@obj.item_size_changed,...
                'position',[245,280,100,20],'parent',obj.h_panel);

        end
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            %
            option.xcrop_chk=get(obj.h_xcrop_chk,'value');
            option.ycrop_chk=get(obj.h_ycrop_chk,'value');
            option.zcrop_chk=get(obj.h_zcrop_chk,'value');
            option.xstart=str2num(get(obj.h_xstart_edit,'string'));
            option.ystart=str2num(get(obj.h_ystart_edit,'string'));
            option.zstart=str2num(get(obj.h_zstart_edit,'string'));
            option.xsize=str2num(get(obj.h_xsize_edit,'string'));
            option.ysize=str2num(get(obj.h_ysize_edit,'string'));
            option.zsize=str2num(get(obj.h_zsize_edit,'string'));
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            %
            set(obj.h_xcrop_chk,'Value',option.xcrop_chk);
            set(obj.h_ycrop_chk,'Value',option.ycrop_chk);
            set(obj.h_zcrop_chk,'Value',option.zcrop_chk);
            set(obj.h_xstart_edit,'String',num2str(option.xstart));
            set(obj.h_ystart_edit,'String',num2str(option.ystart));
            set(obj.h_zstart_edit,'String',num2str(option.zstart));
            set(obj.h_xsize_edit,'String',num2str(option.xsize));
            set(obj.h_ysize_edit,'String',num2str(option.ysize));
            set(obj.h_zsize_edit,'String',num2str(option.zsize));
            %still needs to update xend, yend and zend, where?
            item_size_changed(obj);
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
            if option.xcrop_chk==1;
                frag_code=[frag_code,'''xcrop_chk'',',...
                    num2str(option.xcrop_chk),','];
                frag_code=[frag_code,'''xstart'',',...
                    num2str(option.xstart),','];
                frag_code=[frag_code,'''xsize'',',...
                    num2str(option.xsize),','];
            end;
            if option.ycrop_chk==1;
                frag_code=[frag_code,'''ycrop_chk'',',...
                    num2str(option.ycrop_chk),','];
                frag_code=[frag_code,'''ystart'',',...
                    num2str(option.ystart),','];
                frag_code=[frag_code,'''ysize'',',...
                    num2str(option.yend),','];
            end;
            if option.zcrop_chk==1;
                frag_code=[frag_code,'''zcrop_chk'',',...
                    num2str(option.zcrop_chk),','];
                frag_code=[frag_code,'''zstart'',',...
                    num2str(option.zstart),','];
                frag_code=[frag_code,'''zsize'',',...
                    num2str(option.xend),','];
            end;
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function item_size_changed(obj,varargin)
            xsize=str2num(get(obj.h_xsize_edit,'string'));
            ysize=str2num(get(obj.h_ysize_edit,'string'));
            zsize=str2num(get(obj.h_zsize_edit,'string'));
            xstart=str2num(get(obj.h_xstart_edit,'string'));
            ystart=str2num(get(obj.h_ystart_edit,'string'));
            zstart=str2num(get(obj.h_zstart_edit,'string'));
            xend=xstart+((xsize)*obj.lwdataset(1).header.xstep);
            yend=ystart+((ysize)*obj.lwdataset(1).header.ystep);
            zend=zstart+((zsize)*obj.lwdataset(1).header.zstep);
            set(obj.h_xend_edit,'string',num2str(xend));
            set(obj.h_yend_edit,'string',num2str(yend));
            set(obj.h_zend_edit,'string',num2str(zend));            
        end

        function item_end_changed(obj,varargin)
            xend=str2num(get(obj.h_xend_edit,'string'));
            yend=str2num(get(obj.h_yend_edit,'string'));
            zend=str2num(get(obj.h_zend_edit,'string'));
            xstart=str2num(get(obj.h_xstart_edit,'string'));
            ystart=str2num(get(obj.h_ystart_edit,'string'));
            zstart=str2num(get(obj.h_zstart_edit,'string'));
            xsize=((xend-xstart)/obj.lwdataset(1).header.xstep);
            ysize=((yend-ystart)/obj.lwdataset(1).header.ystep);
            zsize=((zend-zstart)/obj.lwdataset(1).header.zstep);
            set(obj.h_xsize_edit,'string',num2str(xsize));
            set(obj.h_ysize_edit,'string',num2str(ysize));
            set(obj.h_zsize_edit,'string',num2str(zsize));            
        end
        
        function GUI_update(obj,batch_pre)
            obj.virtual_filelist=batch_pre.virtual_filelist;
            obj.lwdataset=batch_pre.lwdataset;
            lwdataset=batch_pre.lwdataset;
            header=lwdataset(1).header;
            if isempty(get(obj.h_xsize_edit,'String'))
                set(obj.h_xstart_edit,'String',num2str(header.xstart));
                set(obj.h_xend_edit,'String',num2str(header.xstart+header.datasize(6)*header.xstep));
                set(obj.h_xsize_edit,'String',num2str(header.datasize(6)));
            end
            if isempty(get(obj.h_ysize_edit,'String'))
                set(obj.h_ystart_edit,'String',num2str(header.ystart));
                set(obj.h_yend_edit,'String',num2str(header.ystart+header.datasize(5)*header.ystep));
                set(obj.h_ysize_edit,'String',num2str(header.datasize(5)));
            end
            if isempty(get(obj.h_zsize_edit,'String'))
                set(obj.h_zstart_edit,'String',num2str(header.zstart));
                set(obj.h_zend_edit,'String',num2str(header.zstart+header.datasize(4)*header.zstep));
                set(obj.h_zsize_edit,'String',num2str(header.datasize(4)));
            end
            xsize=str2num(get(obj.h_xsize_edit,'String'));
            set(obj.h_xend_edit,'String',num2str(header.xstart+(xsize-1)*header.xstep));
            ysize=str2num(get(obj.h_ysize_edit,'String'));
            set(obj.h_yend_edit,'String',num2str(header.ystart+(ysize-1)*header.ystep));
            zsize=str2num(get(obj.h_zsize_edit,'String'));
            set(obj.h_zend_edit,'String',num2str(header.zstart+(zsize-1)*header.zstep));
            item_size_changed(obj);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            if option.xcrop_chk==1;
                header_out.datasize(6)=option.xsize;
                header_out.xstart=option.xstart;
            end;
            if option.ycrop_chk==1;
                header_out.datasize(5)=option.ysize;
                header_out.ystart=option.zstart;
            end;
            if option.zcrop_chk==1;
                header_out.datasize(4)=option.zsize;
                header_out.zstart=option.zstart;
            end;
            %
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            %default values
            option.xcrop_chk=0;
            option.ycrop_chk=0;
            option.zcrop_chk=0;
            option.xstart=0;
            option.xsize=0;
            option.ystart=0;
            option.ysize=0;
            option.zstart=0;
            option.zsize=0;
            option.suffix='crop';
            option.is_save=0;
            option=CLW_check_input(option,{'xcrop_chk','ycrop_chk','zcrop_chk',...
                'xstart','xsize','ystart','ysize','zstart','zsize',...
                'suffix','is_save'},varargin);
            inheader=lwdata_in.header;
            header=FLW_crop_epochs.get_header(inheader,option);
            data=lwdata_in.data;
            %%%
            %dxstart,dxend
            if option.xcrop_chk==1;
                disp('Crop X dimension');
                dxstart=round(((option.xstart-inheader.xstart)/inheader.xstep))+1;
                dxend=(dxstart+option.xsize)-1;
            else
                dxstart=1;
                dxend=inheader.datasize(6);
            end;
            %dystart,dyend
            if option.ycrop_chk==1;
                disp('Crop Y dimension');
                dystart=round(((option.ystart-inheader.ystart)/inheader.ystep))+1;
                dyend=(dystart+option.ysize)-1;
            else
                dystart=1;
                dyend=inheader.datasize(5);
            end;
            %dzstart,dzend
            if option.zcrop_chk==1;
                disp('Crop Z dimension');
                dzstart=round(((option.zstart-inheader.zstart)/inheader.zstep))+1;
                dzend=(dzstart+option.zsize)-1;
            else
                dzstart=1;
                dzend=inheader.datasize(4);
            end;
            %crop
            data=data(:,:,:,dzstart:dzend,dystart:dyend,dxstart:dxend);
            %%%
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end