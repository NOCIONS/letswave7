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
        h_xstart_txt;
        h_xend_txt;
        h_xsize_txt;
        h_xstart_edit;
        h_xend_edit;
        h_xsize_edit;
        h_ycrop_chk;
        h_ystart_txt;
        h_yend_txt;
        h_ysize_txt;
        h_ystart_edit;
        h_yend_edit;
        h_ysize_edit;
        h_zcrop_chk;
        h_zstart_txt;
        h_zend_txt;
        h_zsize_txt;
        h_zstart_edit;
        h_zend_edit;
        h_zsize_edit;
        h_rest_btn;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_crop_epochs(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'crop signals','crop',...
                'Crop signals along X/Y/Z dimension(s).');
            %objects
            %xcrop_chk
            obj.h_xcrop_chk=uicontrol('style','checkbox',...
                'String','Crop X dimension','value',0,...
                'position',[35,480,150,30],'parent',obj.h_panel);
            %labels
            obj.h_xstart_txt=uicontrol('style','text','position',[35,460,100,20],...
                'string','Start:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_xend_txt=uicontrol('style','text','position',[140,460,100,20],...
                'string','End:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_xsize_txt=uicontrol('style','text','position',[245,460,100,20],...
                'string','Size:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %xstart_edit
            obj.h_xstart_edit=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','0','HorizontalAlignment','left',...
                'callback',@(varargin)obj.item_end_changed(1),...
                'position',[35,440,100,20],'parent',obj.h_panel);
            %xend_edit
            obj.h_xend_edit=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','0','HorizontalAlignment','left',...
                'callback',@(varargin)obj.item_end_changed(1),...
                'position',[140,440,100,20],'parent',obj.h_panel);
            %xsize_edit
            obj.h_xsize_edit=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','','HorizontalAlignment','left',...
                'callback',@(varargin)obj.item_size_changed(1),...
                'position',[245,440,100,20],'parent',obj.h_panel);

            %ycrop_chk
            obj.h_ycrop_chk=uicontrol('style','checkbox',...
                'String','Crop Y dimension','value',0,...
                'position',[35,400,150,30],'parent',obj.h_panel);
            %labels
            obj.h_ystart_txt=uicontrol('style','text','position',[35,380,100,20],...
                'string','Start:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_yend_txt=uicontrol('style','text','position',[140,380,100,20],...
                'string','End:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_ysize_txt=uicontrol('style','text','position',[245,380,100,20],...
                'string','Size:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %ystart_edit
            obj.h_ystart_edit=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','0','HorizontalAlignment','left',...
                'callback',@(varargin)obj.item_end_changed(2),...
                'position',[35,360,100,20],'parent',obj.h_panel);
            %yend_edit
            obj.h_yend_edit=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','0','HorizontalAlignment','left',...
                'position',[140,360,100,20],'parent',obj.h_panel);
            %ysize_edit
           obj.h_ysize_edit=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','','HorizontalAlignment','left',...
                'callback',@(varargin)obj.item_size_changed(2),...
                'position',[245,360,100,20],'parent',obj.h_panel);

            %zcrop_chk
            obj.h_zcrop_chk=uicontrol('style','checkbox',...
                'String','Crop Z dimension','value',0,...
                'position',[35,320,150,30],'parent',obj.h_panel);
            %labels
            obj.h_zstart_txt=uicontrol('style','text','position',[35,300,100,20],...
                'string','Start:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_zend_txt=uicontrol('style','text','position',[140,300,100,20],...
                'string','End:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_zsize_txt=uicontrol('style','text','position',[245,300,100,20],...
                'string','Size:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %zstart_edit
            obj.h_zstart_edit=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','0','HorizontalAlignment','left',...
                'callback',@(varargin)obj.item_end_changed(3),...
                'position',[35,280,100,20],'parent',obj.h_panel);
            %zend_edit
            obj.h_zend_edit=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','0','HorizontalAlignment','left',...
                'callback',@(varargin)obj.item_end_changed(3),...
                'position',[140,280,100,20],'parent',obj.h_panel);
            %zsize_edit
            obj.h_zsize_edit=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','','HorizontalAlignment','left',...
                'callback',@(varargin)obj.item_size_changed(3),...
                'position',[245,280,100,20],'parent',obj.h_panel);
            
            obj.h_rest_btn=uicontrol('style','pushbutton','String','reset',...
                'position',[245,240,100,30],'Callback',@obj.reset_Callback,...
                'parent',obj.h_panel);
        end
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.xcrop_chk=get(obj.h_xcrop_chk,'value');
            option.ycrop_chk=get(obj.h_ycrop_chk,'value');
            option.zcrop_chk=get(obj.h_zcrop_chk,'value');
            option.xstart=str2num(get(obj.h_xstart_edit,'string'));
            option.ystart=str2num(get(obj.h_ystart_edit,'string'));
            option.zstart=str2num(get(obj.h_zstart_edit,'string'));
            option.xend=str2num(get(obj.h_xend_edit,'string'));
            option.yend=str2num(get(obj.h_yend_edit,'string'));
            option.zend=str2num(get(obj.h_zend_edit,'string'));
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_xcrop_chk,'Value',option.xcrop_chk);
            set(obj.h_ycrop_chk,'Value',option.ycrop_chk);
            set(obj.h_zcrop_chk,'Value',option.zcrop_chk);
            set(obj.h_xstart_edit,'String',num2str(option.xstart));
            set(obj.h_ystart_edit,'String',num2str(option.ystart));
            set(obj.h_zstart_edit,'String',num2str(option.zstart));
            set(obj.h_xend_edit,'String',num2str(option.xend));
            set(obj.h_yend_edit,'String',num2str(option.yend));
            set(obj.h_zend_edit,'String',num2str(option.zend));
            
            xsize=floor(option.xend-option.xstart)/obj.lwdataset(1).header.xstep;
            ysize=floor(option.yend-option.ystart)/obj.lwdataset(1).header.ystep;
            zsize=floor(option.zend-option.zstart)/obj.lwdataset(1).header.zstep;
            
            set(obj.h_xsize_edit,'String',num2str(xsize));
            set(obj.h_ysize_edit,'String',num2str(ysize));
            set(obj.h_zsize_edit,'String',num2str(zsize));
        end
       
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            %%%
            if option.xcrop_chk==1
                frag_code=[frag_code,'''xcrop_chk'',',...
                    num2str(option.xcrop_chk),','];
                frag_code=[frag_code,'''xstart'',',...
                    num2str(option.xstart),','];
                frag_code=[frag_code,'''xend'',',...
                    num2str(option.xend),','];
            end
            if option.ycrop_chk==1
                frag_code=[frag_code,'''ycrop_chk'',',...
                    num2str(option.ycrop_chk),','];
                frag_code=[frag_code,'''ystart'',',...
                    num2str(option.ystart),','];
                frag_code=[frag_code,'''yend'',',...
                    num2str(option.yend),','];
            end
            if option.zcrop_chk==1
                frag_code=[frag_code,'''zcrop_chk'',',...
                    num2str(option.zcrop_chk),','];
                frag_code=[frag_code,'''zstart'',',...
                    num2str(option.zstart),','];
                frag_code=[frag_code,'''zend'',',...
                    num2str(option.zend),','];
            end
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function item_size_changed(obj,varargin)
            switch(varargin{1})
                case 1
                    xstart=str2num(get(obj.h_xstart_edit,'string'));
                    xsize=str2num(get(obj.h_xsize_edit,'string'));
                    xend=xstart+(xsize*obj.lwdataset(1).header.xstep);
                    set(obj.h_xend_edit,'string',num2str(xend));
                    set(obj.h_xcrop_chk,'value',1);
                case 2
                    ystart=str2num(get(obj.h_ystart_edit,'string'));
                    ysize=str2num(get(obj.h_ysize_edit,'string'));
                    yend=ystart+((ysize)*obj.lwdataset(1).header.ystep);
                    set(obj.h_yend_edit,'string',num2str(yend));
                    set(obj.h_ycrop_chk,'value',1);
                case 3
                    zstart=str2num(get(obj.h_zstart_edit,'string'));
                    zsize=str2num(get(obj.h_zsize_edit,'string'));
                    zend=zstart+((zsize)*obj.lwdataset(1).header.zstep);
                    set(obj.h_zend_edit,'string',num2str(zend));
                    set(obj.h_zcrop_chk,'value',1);
            end
        end

        function item_end_changed(obj,varargin)
            switch(varargin{1})
                case 1
                    xstart=str2num(get(obj.h_xstart_edit,'string'));
                    xend=str2num(get(obj.h_xend_edit,'string'));
                    xsize=floor((xend-xstart)/obj.lwdataset(1).header.xstep);
                    set(obj.h_xsize_edit,'string',num2str(xsize));
                    set(obj.h_xcrop_chk,'value',1);
                case 2
                    ystart=str2num(get(obj.h_ystart_edit,'string'));
                    yend=str2num(get(obj.h_yend_edit,'string'));
                    ysize=floor((yend-ystart)/obj.lwdataset(1).header.ystep);
                    set(obj.h_ysize_edit,'string',num2str(ysize));
                    set(obj.h_ycrop_chk,'value',1);
                case 3
                    zstart=str2num(get(obj.h_zstart_edit,'string'));
                    zend=str2num(get(obj.h_zend_edit,'string'));
                    zsize=floor((zend-zstart)/obj.lwdataset(1).header.zstep);
                    set(obj.h_zsize_edit,'string',num2str(zsize));
                    set(obj.h_zcrop_chk,'value',1);
            end     
        end
        
        function reset_Callback(obj,varargin)
            xstart=obj.lwdataset(1).header.xstart;
            xend=obj.lwdataset(1).header.xstart+...
                obj.lwdataset(1).header.datasize(6)*...
                obj.lwdataset(1).header.xstep;
            ystart=obj.lwdataset(1).header.ystart;
            yend=obj.lwdataset(1).header.ystart+...
                obj.lwdataset(1).header.datasize(5)*...
                obj.lwdataset(1).header.ystep;
            zstart=obj.lwdataset(1).header.zstart;
            zend=obj.lwdataset(1).header.zstart+...
                obj.lwdataset(1).header.datasize(4)*...
                obj.lwdataset(1).header.zstep;
            for data_pos=2:length(obj.lwdataset)
                xstart=max(xstart,obj.lwdataset(data_pos).header.xstart);
                xend=min(xend,obj.lwdataset(data_pos).header.xstart+...
                obj.lwdataset(data_pos).header.datasize(6)*...
                obj.lwdataset(data_pos).header.xstep);
            
                ystart=max(ystart,obj.lwdataset(data_pos).header.ystart);
                yend=min(yend,obj.lwdataset(data_pos).header.ystart+...
                obj.lwdataset(data_pos).header.datasize(5)*...
                obj.lwdataset(data_pos).header.ystep);
            
                zstart=max(zstart,obj.lwdataset(data_pos).header.zstart);
                zend=min(zend,obj.lwdataset(data_pos).header.zstart+...
                obj.lwdataset(data_pos).header.datasize(4)*...
                obj.lwdataset(data_pos).header.zstep);
            end
            xsize=floor(xend-xstart)/obj.lwdataset(1).header.xstep;
            ysize=floor(yend-ystart)/obj.lwdataset(1).header.ystep;
            zsize=floor(zend-zstart)/obj.lwdataset(1).header.zstep;
            
            set(obj.h_xstart_edit,'String',num2str(xstart));
            set(obj.h_xend_edit,'String',num2str(xend));
            set(obj.h_xsize_edit,'String',num2str(xsize));
            set(obj.h_ystart_edit,'String',num2str(ystart));
            set(obj.h_yend_edit,'String',num2str(yend));
            set(obj.h_ysize_edit,'String',num2str(ysize));
            set(obj.h_zstart_edit,'String',num2str(zstart));
            set(obj.h_zend_edit,'String',num2str(zend));
            set(obj.h_zsize_edit,'String',num2str(zsize));
            set(obj.h_xcrop_chk,'value',0);
            set(obj.h_ycrop_chk,'value',0);
            set(obj.h_zcrop_chk,'value',0);
        end 
        
        function GUI_update(obj,batch_pre)
            obj.lwdataset=batch_pre.lwdataset;
            if isempty(get(obj.h_xsize_edit,'String'))
                obj.reset_Callback();
            end
            header=batch_pre.lwdataset(1).header;
            if header.datasize(6)==1
                set(obj.h_xcrop_chk,'Value',0);
                set(obj.h_xcrop_chk,'Visible','off');
                set(obj.h_xstart_txt,'Visible','off');
                set(obj.h_xsize_txt,'Visible','off');
                set(obj.h_xend_txt,'Visible','off');
                set(obj.h_xstart_edit,'Visible','off');
                set(obj.h_xend_edit,'Visible','off');
                set(obj.h_xsize_edit,'Visible','off');
            else
                set(obj.h_xcrop_chk,'Visible','on');
                set(obj.h_xstart_txt,'Visible','on');
                set(obj.h_xsize_txt,'Visible','on');
                set(obj.h_xend_txt,'Visible','on');
                set(obj.h_xstart_edit,'Visible','on');
                set(obj.h_xend_edit,'Visible','on');
                set(obj.h_xsize_edit,'Visible','on');
            end
            if header.datasize(5)==1
                set(obj.h_ycrop_chk,'Value',0);
                set(obj.h_ycrop_chk,'Visible','off');
                set(obj.h_ystart_txt,'Visible','off');
                set(obj.h_ysize_txt,'Visible','off');
                set(obj.h_yend_txt,'Visible','off');
                set(obj.h_ystart_edit,'Visible','off');
                set(obj.h_yend_edit,'Visible','off');
                set(obj.h_ysize_edit,'Visible','off');
            else
                set(obj.h_ycrop_chk,'Visible','on');
                set(obj.h_ystart_txt,'Visible','on');
                set(obj.h_ysize_txt,'Visible','on');
                set(obj.h_yend_txt,'Visible','on');
                set(obj.h_ystart_edit,'Visible','on');
                set(obj.h_yend_edit,'Visible','on');
                set(obj.h_ysize_edit,'Visible','on');
            end
            if header.datasize(4)==1
                set(obj.h_zcrop_chk,'Value',0);
                set(obj.h_zcrop_chk,'Visible','off');
                set(obj.h_zstart_txt,'Visible','off');
                set(obj.h_zsize_txt,'Visible','off');
                set(obj.h_zend_txt,'Visible','off');
                set(obj.h_zstart_edit,'Visible','off');
                set(obj.h_zend_edit,'Visible','off');
                set(obj.h_zsize_edit,'Visible','off');
            else
                set(obj.h_zcrop_chk,'Visible','on');
                set(obj.h_zstart_txt,'Visible','on');
                set(obj.h_zsize_txt,'Visible','on');
                set(obj.h_zend_txt,'Visible','on');
                set(obj.h_zstart_edit,'Visible','on');
                set(obj.h_zend_edit,'Visible','on');
                set(obj.h_zsize_edit,'Visible','on');
            end
            
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            if option.xcrop_chk==1
                header_out.datasize(6)=floor(option.xend-option.xstart)/header_out.xstep;
                header_out.xstart=option.xstart;
            end
            if option.ycrop_chk==1
                header_out.datasize(5)=floor(option.yend-option.ystart)/header_out.ystep;
                header_out.ystart=option.zstart;
            end
            if option.zcrop_chk==1
                header_out.datasize(4)=floor(option.zend-option.zstart)/header_out.ystep;
                header_out.zstart=option.zstart;
            end
            
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
                'xstart','ystart','zstart','xend','yend','zend',...
                'suffix','is_save'},varargin);
            header_in=lwdata_in.header;
            header=FLW_crop_epochs.get_header(header_in,option);
            data=lwdata_in.data;
            %%%
            %dxstart,dxend
            if option.xcrop_chk==1
                disp('Crop X dimension');
                dxstart=round(((option.xstart-header_in.xstart)/header_in.xstep))+1;
                dxend=round(((option.xend-header_in.xstart)/header_in.xstep));
                if dxstart>dxend
                    temp=dxend;
                    dxend=dxstart;
                    dxstart=temp;
                end
                dxstart=max(dxstart,1);
                dxend=min(dxend,header_in.datasize(6));
            else
                dxstart=1;
                dxend=header_in.datasize(6);
            end
            %dystart,dyend
            if option.ycrop_chk==1
                disp('Crop Y dimension');
                dystart=round(((option.ystart-header_in.ystart)/header_in.ystep))+1;
                dyend=round(((option.yend-header_in.ystart)/header_in.ystep));
                if dystart>dyend
                    temp=dyend;
                    dyend=dystart;
                    dystart=temp;
                end
                dystart=max(dystart,1);
                dyend=min(dyend,header_in.datasize(5));
            else
                dystart=1;
                dyend=header_in.datasize(5);
            end
            %dzstart,dzend
            if option.zcrop_chk==1
                disp('Crop Z dimension');
                dzstart=round(((option.zstart-header_in.zstart)/header_in.zstep))+1;
                dzend=round(((option.zend-header_in.zstart)/header_in.zstep));
                if dzstart>dzend
                    temp=dzend;
                    dzend=dzstart;
                    dzstart=temp;
                end
                dzstart=max(dzstart,1);
                dzend=min(dzend,header_in.datasize(4));
            else
                dzstart=1;
                dzend=header_in.datasize(4);
            end
            %crop
            data=data(:,:,:,dzstart:dzend,dystart:dyend,dxstart:dxend);
            header.datasize=size(data);
            %%%
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end