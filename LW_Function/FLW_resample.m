classdef FLW_resample<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Mout, like math_multiple, t-test
        FLW_TYPE=1;
        %properties
        h_x_resample_chk;
        h_y_resample_chk;
        h_z_resample_chk;
        h_x_SR_edit;
        h_y_SR_edit;
        h_z_SR_edit;
        h_interpolation_pop;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_resample(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'resample signals','rs',...
                'Resample signals (custom samplingrate)');
            %objects
            %x_resample_chk
            obj.h_x_resample_chk=uicontrol('style','checkbox','position',[38,475,250,20],...
                'string','Change X-dimension sampling rate : ',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %x_SR_edit
            obj.h_x_SR_edit=uicontrol('style','edit',...
                'String','',...
                'value',0,'HorizontalAlignment','left',...
                'position',[40,450,100,20],'parent',obj.h_panel);
            %y_resample_chk
            obj.h_y_resample_chk=uicontrol('style','checkbox','position',[38,415,250,20],...
                'string','Change Y-dimension sampling rate : ',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %y_SR_edit
            obj.h_y_SR_edit=uicontrol('style','edit',...
                'String','',...
                'value',0,'HorizontalAlignment','left',...
                'position',[40,390,100,20],'parent',obj.h_panel);
            %z_resample_chk
            obj.h_z_resample_chk=uicontrol('style','checkbox','position',[38,355,250,20],...
                'string','Change Z-dimension sampling rate : ',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %z_SR_edit
            obj.h_z_SR_edit=uicontrol('style','edit',...
                'String','',...
                'value',0,'HorizontalAlignment','left',...
                'position',[40,330,100,20],'parent',obj.h_panel);
            %interpolation_pop
            uicontrol('style','text','position',[35,290,200,20],...
                'string','Interpolation method : ','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_interpolation_pop=uicontrol('style','popupmenu',...
                'String',{'nearest','linear','spline','pchip','cubic','v5cubic'},'value',1,...
                'position',[35,260,200,30],'parent',obj.h_panel);
            
            set(obj.h_x_SR_edit,'backgroundcolor',[1,1,1]);
            set(obj.h_y_SR_edit,'backgroundcolor',[1,1,1]);
            set(obj.h_z_SR_edit,'backgroundcolor',[1,1,1]);
            set(obj.h_interpolation_pop,'backgroundcolor',[1,1,1]);
        end
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            %
            option.x_resample_chk=get(obj.h_x_resample_chk,'value');
            option.y_resample_chk=get(obj.h_y_resample_chk,'value');
            option.z_resample_chk=get(obj.h_z_resample_chk,'value');          
            option.x_SR=str2num(get(obj.h_x_SR_edit,'string'));
            option.y_SR=str2num(get(obj.h_y_SR_edit,'string'));
            option.z_SR=str2num(get(obj.h_z_SR_edit,'string'));
            str=get(obj.h_interpolation_pop,'String');
            option.interpolation_method=str{get(obj.h_interpolation_pop,'value')};
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            %
            set(obj.h_x_SR_edit,'String',num2str(option.x_SR));
            set(obj.h_y_SR_edit,'String',num2str(option.y_SR));
            set(obj.h_z_SR_edit,'String',num2str(option.z_SR));
            set(obj.h_x_resample_chk,'Value',option.x_resample_chk);
            set(obj.h_y_resample_chk,'Value',option.y_resample_chk);
            set(obj.h_z_resample_chk,'Value',option.z_resample_chk);
            str=get(obj.h_interpolation_pop,'String');
            [~,b]=intersect(str,option.interpolation_method);
            if isempty(b)
                set(obj.h_interpolation_pop,'Value',1);
            else
                set(obj.h_interpolation_pop,'Value',b);
            end
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
            if option.x_resample_chk==1
                frag_code=[frag_code,'''x_resample_chk'',',...
                    num2str(option.x_resample_chk),','];
                frag_code=[frag_code,'''x_SR'',',...
                    num2str(option.x_SR),','];
            end
            if option.y_resample_chk==1
                frag_code=[frag_code,'''y_resample_chk'',',...
                    num2str(option.x_resample_chk),','];
                frag_code=[frag_code,'''y_SR'',',...
                    num2str(option.y_SR),','];
            end
            if option.z_resample_chk==1
                frag_code=[frag_code,'''z_resample_chk'',',...
                    num2str(option.z_resample_chk),','];
                frag_code=[frag_code,'''z_SR'',',...
                    num2str(option.z_SR),','];
            end
            frag_code=[frag_code,'''interpolation_method'',',...
               '''',option.interpolation_method,''','];
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        
        function GUI_update(obj,batch_pre)
            header=batch_pre.lwdataset(1).header;
            if isempty(get(obj.h_x_SR_edit,'String'))
                set(obj.h_x_SR_edit,'String',num2str(1/header.xstep));
            end
            if isempty(get(obj.h_y_SR_edit,'String'))
                set(obj.h_y_SR_edit,'String',num2str(1/header.ystep));
            end
            if isempty(get(obj.h_z_SR_edit,'String'))
                set(obj.h_z_SR_edit,'String',num2str(1/header.zstep));
            end
            if header.datasize(6)==1
                set(obj.h_x_resample_chk,'Value',0);
                set(obj.h_x_resample_chk,'Visible','off');
                set(obj.h_x_SR_edit,'Visible','off');
            else
                set(obj.h_x_resample_chk,'Visible','on');
                set(obj.h_x_SR_edit,'Visible','on');
            end
            if header.datasize(5)==1
                set(obj.h_y_resample_chk,'Value',0);
                set(obj.h_y_resample_chk,'Visible','off');
                set(obj.h_y_SR_edit,'Visible','off');
            else
                set(obj.h_y_resample_chk,'Visible','on');
                set(obj.h_y_SR_edit,'Visible','on');
            end
            if header.datasize(4)==1
                set(obj.h_z_resample_chk,'Value',0);
                set(obj.h_z_resample_chk,'Visible','off');
                set(obj.h_z_SR_edit,'Visible','off');
            else
                set(obj.h_z_resample_chk,'Visible','on');
                set(obj.h_z_SR_edit,'Visible','on');
            end
            
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end   
    end
 
    
    
    
    methods (Static = true)
        function [ntpx,ntpy,ntpz]=resample_vector(inheader,option)
            %ntpx
            ntpx=[];
            if option.x_resample_chk==1
                xstart=inheader.xstart;
                xend=((inheader.datasize(6)-1)*inheader.xstep)+inheader.xstart;
                xstep=1/option.x_SR;
                ntpx=xstart:xstep:xend;
            end
            %ntpy
            ntpy=[];
            if option.y_resample_chk==1
                ystart=inheader.ystart;
                yend=((inheader.datasize(5)-1)*inheader.ystep)+inheader.ystart;
                ystep=1/option.y_SR;
                ntpy=ystart:ystep:yend;
            end
            %ntpz
            ntpz=[];
            if option.z_resample_chk==1
                zstart=inheader.zstart;
                zend=((inheader.datasize(4)-1)*inheader.zstep)+inheader.zstart;
                zstep=1/option.z_SR;
                ntpz=zstart:zstep:zend;
            end
        end
        
        function header_out= get_header(header_in,option)
            header_out=header_in;
            %update header
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            %ntpx,ntpy,ntpz
            [ntpx,ntpy,ntpz]=FLW_resample.resample_vector(header_in,option);
            if option.x_resample_chk==1
                header_out.xstep=1/option.x_SR;
                header_out.datasize(6)=length(ntpx);
            end
            if option.y_resample_chk==1
                header_out.ystep=1/option.y_SR;
                header_out.datasize(5)=length(ntpy);
            end
            if option.z_resample_chk==1
                header_out.zstep=1/option.z_SR;
                header_out.datasize(4)=length(ntpz);
            end
            %
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            %default values
            option.x_resample_chk=0;
            option.y_resample_chk=0;
            option.z_resample_chk=0;
            option.x_SR=1;
            option.y_SR=1;
            option.z_SR=1;
            option.interpolation_method='nearest';
            option.suffix='rs';
            option.is_save=0;
            option=CLW_check_input(option,{'x_resample_chk','y_resample_chk','z_resample_chk',...
                'x_SR','y_SR','z_SR','interpolation_method',...
                'suffix','is_save'},varargin);
            inheader=lwdata_in.header;
            header=FLW_resample.get_header(inheader,option);
            indata=lwdata_in.data;
            %%%
            %tpx,tpy,tpz (original srate)
            tpx=1:1:inheader.datasize(6);
            tpy=1:1:inheader.datasize(5);
            tpz=1:1:inheader.datasize(4);
            tpx=((tpx-1)*inheader.xstep)+inheader.xstart;
            tpy=((tpy-1)*inheader.ystep)+inheader.ystart;
            tpz=((tpz-1)*inheader.zstep)+inheader.zstart;
            %ntpx,ntpy,ntpz (new srate)
            [ntpx,ntpy,ntpz]=FLW_resample.resample_vector(header,option);
            %prepare data
            data=zeros(header.datasize);
            %method
            %disp(['Interpolation method : ' option.interpolation_method]);
            %interp3 (X/Y/Z)
            if (option.x_resample_chk==1) && (option.y_resample_chk==1) && (option.z_resample_chk==1)
                disp('3D interpolation (X/Y/Z)');
                %loop through epochs
                for epochpos=1:header.datasize(1)
                    for chanpos=1:header.datasize(2)
                        for indexpos=1:header.datasize(3)
                            data(epochpos,chanpos,indexpos,:,:,:)=interp3(tpz,tpy,tpx,squeeze(indata(epochpos,chanpos,indexpos,:,:,:)),ntpz,ntpy,ntpx,option.interpolation_method);
                        end
                    end
                end
            end
            %interp2 (X/Y)
            if (option.x_resample_chk==1)&& (option.y_resample_chk==1) && (option.z_resample_chk==0)
                disp('2D interpolation (X/Y)');
                %loop through epochs
                for epochpos=1:header.datasize(1)
                    for chanpos=1:header.datasize(2)
                        for indexpos=1:header.datasize(3)
                            for dz=1:header.datasize(4)
                                data(epochpos,chanpos,indexpos,dz,:,:)=interp2(tpy,tpx,squeeze(indata(epochpos,chanpos,indexpos,dz,:,:)),ntpy,ntpx,option.interpolation_method);
                            end
                        end
                    end
                end
            end
            %interp2 (X/Z)
            if (option.x_resample_chk==1) && (option.y_resample_chk==0) && (option.z_resample_chk==1)
                disp('2D interpolation (X/Z)');
                %loop through epochs
                for epochpos=1:header.datasize(1)
                    for chanpos=1:header.datasize(2)
                        for indexpos=1:header.datasize(3)
                            for dy=1:header.datasize(5)
                                data(epochpos,chanpos,indexpos,:,dy,:)=interp2(tpz,tpx,squeeze(indata(epochpos,chanpos,indexpos,:,dy,:)),ntpz,ntpx,option.interpolation_method);
                            end
                        end
                    end
                end
            end
            %interp2 (Y/Z)
            if (option.x_resample_chk==0)&&(option.z_resample_chk==1)&&(option.z_resample_chk==1)
                disp('2D interpolation (Y/Z)');
                %loop through epochs
                for epochpos=1:header.datasize(1)
                    for chanpos=1:header.datasize(2)
                        for indexpos=1:header.datasize(3)
                            for dx=1:header.datasize(6)
                                data(epochpos,chanpos,indexpos,:,:,dx)=interp2(tpz,tpy,squeeze(indata(epochpos,chanpos,indexpos,:,:,dx)),ntpz,ntpy,option.interpolation_method);
                            end
                        end
                    end
                end
            end
            %interp1 (X)
            if (option.x_resample_chk==1)&&(option.y_resample_chk==0)&&(option.z_resample_chk==0)
                disp('1D interpolation (X)');
                %loop through epochs
                for epochpos=1:header.datasize(1)
                    for chanpos=1:header.datasize(2)
                        for indexpos=1:header.datasize(3)
                            for dz=1:header.datasize(4)
                                for dy=1:header.datasize(5)
                                    data(epochpos,chanpos,indexpos,dz,dy,:)=interp1(tpx,squeeze(indata(epochpos,chanpos,indexpos,dz,dy,:)),ntpx,option.interpolation_method);
                                end
                            end
                        end
                    end
                end
            end
            %interp1 (Y)
            if (option.x_resample_chk==0)&&(option.y_resample_chk==1)&&(option.z_resample_chk==0)
                disp('1D interpolation (Y)');
                %loop through epochs
                for epochpos=1:header.datasize(1)
                    for chanpos=1:header.datasize(2)
                        for indexpos=1:header.datasize(3)
                            for dz=1:header.datasize(4)
                                for dx=1:header.datasize(6)
                                    data(epochpos,chanpos,indexpos,dz,:,dx)=interp1(tpy,squeeze(indata(epochpos,chanpos,indexpos,dz,:,dx)),ntpy,option.interpolation_method);
                                end
                            end
                        end
                    end
                end
            end
            %interp1 (Z)
            if (option.x_resample_chk==0)&&(option.y_resample_chk==0)&&(option.z_resample_chk==1)
                disp('1D interpolation (Z)');
                %loop through epochs
                for epochpos=1:header.datasize(1)
                    for chanpos=1:header.datasize(2)
                        for indexpos=1:header.datasize(3)
                            for dy=1:header.datasize(5)
                                for dx=1:header.datasize(6)
                                    data(epochpos,chanpos,indexpos,:,dy,dx)=interp1(tpz,squeeze(indata(epochpos,chanpos,indexpos,:,dy,dx)),ntpz,option.interpolation_method);
                                end
                            end
                        end
                    end
                end
            end
            %%%
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end