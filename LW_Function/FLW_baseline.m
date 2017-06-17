classdef FLW_baseline<CLW_generic
    properties
        FLW_TYPE=1;
        h_operation_pop;
        h_xstart_edt;
        h_xend_edt;
        h_rest_btn;
    end
    
    methods
        function obj = FLW_baseline(batch_handle)
            obj@CLW_generic(batch_handle,'baseline correction','bl',...
                'Make the baseline correction on the dataset.');
            
            uicontrol('style','text','position',[35,470,350,20],...
                'string','Baseline operation:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_operation_pop=uicontrol('style','popupmenu','String',...
                {'substract [yi=xi-mean(bl)]',...
                'ER% [yi=(xi-mean(bl))/mean(bl)]',...
                'divide [yi=xi/mean(bl]',...
                'zscore [yi=(xi-mean(bl))/std(bl)]'},...
                'backgroundcolor',[1,1,1],...
                'position',[35,440,350,30],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[35,370,350,20],...
                'string','Range of surrounding bins defining baseline:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_xstart_edt=uicontrol('style','edit','String','',...
                'backgroundcolor',[1,1,1],'position',[35,340,110,30],...
                'parent',obj.h_panel);
            uicontrol('style','text','position',[160,345,10,20],'string','-',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_xend_edt=uicontrol('style','edit','String','',...
                'position',[180,340,110,30],'backgroundcolor',[1,1,1],...
                'parent',obj.h_panel);
            obj.h_rest_btn=uicontrol('style','pushbutton','String','reset',...
                'position',[320,340,60,30],'Callback',@obj.reset_Callback,...
                'parent',obj.h_panel);
        end
        
        function reset_Callback(obj,varargin)
            xstart=obj.lwdataset(1).header.xstart;
            for data_pos=2:length(obj.lwdataset)
                xstart=max(xstart,obj.lwdataset(data_pos).header.xstart);
            end
            if(xstart>0)
                xend=xstart;
            else
                xend=0;
            end
            set(obj.h_xstart_edt,'string',num2str(xstart));
            set(obj.h_xend_edt,'string',num2str(xend));
        end 
        
        function GUI_update(obj,batch_pre)
            obj.lwdataset=batch_pre.lwdataset;
            if isempty(get(obj.h_xstart_edt,'string'))
                obj.reset_Callback();
            end
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.xstart=str2num(get(obj.h_xstart_edt,'string'));
            option.xend=str2num(get(obj.h_xend_edt,'string'));
            switch(get(obj.h_operation_pop,'value'))
                case 1
                    option.operation='substract';
                case 2
                    option.operation='erpercent';
                case 3
                    option.operation='divide';
                case 4
                    option.operation='zscore';
            end
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            switch option.operation
                case 'substract'
                    set(obj.h_operation_pop,'value',1);
                case 'erpercent'
                    set(obj.h_operation_pop,'value',2);
                case 'divide'
                    set(obj.h_operation_pop,'value',3);
                case 'zscore'
                    set(obj.h_operation_pop,'value',4);
            end
            set(obj.h_xstart_edt,'string',num2str(option.xstart));
            set(obj.h_xend_edt,'string',num2str(option.xend));
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''operation'',''',...
                option.operation,''','];
            frag_code=[frag_code,'''xstart'',',...
                num2str(option.xstart),','];
            frag_code=[frag_code,'''xend'',',...
                num2str(option.xend),','];
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
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.xstart=lwdata_in.header.xstart;
            option.xend=max(0,lwdata_in.header.xstart);
            option.operation='subtract';
            option.suffix='bl';
            option.is_save=0;
            option=CLW_check_input(option,{'xstart','xend','operation',...
                'suffix','is_save'},varargin);
            header=FLW_baseline.get_header(lwdata_in.header,option);
            
            data=lwdata_in.data;
            dxsize=header.datasize(6);
            data=permute(data,[6,1,2,3,4,5]);
            dxstart=round(((option.xstart-header.xstart)/header.xstep)+1);
            dxend=round(((option.xend-header.xstart)/header.xstep)+1);
            if(dxstart>dxend)
                temp=dxend;
                dxend=dxstart;
                dxstart=temp;
            end
            if dxstart<1
                dxstart=1;
            end
            if dxend>dxsize
                dxend=dxsize;
            end
            bl=mean(data(dxstart:dxend,:,:,:,:,:),1);
            bl=bl(ones(dxsize,1),:,:,:,:,:);
            switch option.operation
                case 'substract'
                    data=data-bl;
                case 'erpercent'
                    data=(data-bl)./bl;
                case 'divide'
                    data=data./bl;
                case 'zscore'
                    stfbl=std(data(dxstart:dxend,:,:,:,:,:),[],1);
                    stfbl=stfbl(ones(dxsize,1),:,:,:,:,:);
                    data=(data-bl)./stfbl;
            end
            data=ipermute(data,[6,1,2,3,4,5]);
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end