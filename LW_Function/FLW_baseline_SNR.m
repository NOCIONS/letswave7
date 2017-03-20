classdef FLW_baseline_SNR<CLW_generic
    properties
        FLW_TYPE=1;
        h_xstart_edt;
        h_xend_edt;
        h_num_extreme_edt;
        h_operation_pop;
    end
    
    methods
        function obj = FLW_baseline_SNR(batch_handle)
            obj@CLW_generic(batch_handle,'baseline_SNR','bl_snr',...
                'This function is used to express the magnitude of steady-state evoked potentials (SS-EPs) identified in frequency spectra relative to the amplitude of the spectra obtained at neighbouring frequency bins. The function can be viewed as a method to apply a baseline correction in the frequency domain.');
            uicontrol('style','text','position',[35,470,350,20],...
                'string','Range of surrounding bins defining baseline:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_xstart_edt=uicontrol('style','edit','String','2',...
                 'backgroundcolor',[1,1,1],...
                 'position',[35,440,110,30],'parent',obj.h_panel);
            uicontrol('style','text','position',[160,445,10,20],'string','-',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_xend_edt=uicontrol('style','edit','String','5',...
                 'backgroundcolor',[1,1,1],...
                 'position',[180,440,110,30],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[35,370,350,20],...
                'string','number of extreme bins (min and max) to remove:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_num_extreme_edt=uicontrol('style','edit','String','0',...
                 'backgroundcolor',[1,1,1],...
                 'position',[35,340,110,30],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[35,270,350,20],...
                'string','Operation:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_operation_pop=uicontrol('style','popupmenu',...
                'String',{'subtract','SNR','zscore','phase percent'},'value',1,...
                 'backgroundcolor',[1,1,1],...
                 'position',[35,240,200,30],'parent',obj.h_panel);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.xstart=str2num(get(obj.h_xstart_edt,'string'));
            option.xend=str2num(get(obj.h_xend_edt,'string'));
            option.num_extreme=str2num(get(obj.h_num_extreme_edt,'string'));
            str=get(obj.h_operation_pop,'String');
            str_value=get(obj.h_operation_pop,'value');
            option.operation=str{str_value};
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_xstart_edt,'string',num2str(option.xstart));
            set(obj.h_xend_edt,'string',num2str(option.xend));
            set(obj.h_num_extreme_edt,'string',num2str(option.num_extreme));
            switch option.operation
                case 'subtract'
                    set(obj.h_operation_pop,'value',1);
                case 'SNR'
                    set(obj.h_operation_pop,'value',2);
                case 'zscore'
                    set(obj.h_operation_pop,'value',3);
                case 'phase percent'
                    set(obj.h_operation_pop,'value',4);
            end
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''xstart'',',...
                num2str(option.xstart),','];
            frag_code=[frag_code,'''xend'',',...
                num2str(option.xend),','];
            frag_code=[frag_code,'''num_extreme'',',...
                num2str(option.num_extreme),','];
            frag_code=[frag_code,'''operation'',''',...
                option.operation,''','];
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
            option.xstart=2;
            option.xend=5;
            option.num_extreme=0;
            option.operation='subtract';
            option.suffix='bl_snr';
            option.is_save=0;
            option=CLW_check_input(option,{'xstart','xend','num_extreme',...
                'operation','suffix','is_save'},varargin);
            header=FLW_baseline_SNR.get_header(lwdata_in.header,option);
            
            data=lwdata_in.data;
            data=permute(data,[6,1,2,3,4,5]);
            
            bl=zeros(size(data));
            if strcmpi(option.operation,'zscore');
                stdbl=zeros(size(data));
            end
            dxsize=size(data,1);
            for dx=1:dxsize
                dx1=dx-option.xend;
                dx2=dx-option.xstart;
                dx3=dx+option.xstart;
                dx4=dx+option.xend;
                
                if dx1<1;
                    dx1=1;
                end
                if dx2<1;
                    dx2=0;
                end
                if dx3>dxsize;
                    dx3=dxsize+1;
                end
                if dx4>dxsize;
                    dx4=dxsize;
                end
                temp=data([dx1:dx2,dx3:dx4],:,:,:,:,:);
                if option.num_extreme>0;
                    temp=sort(temp,1);
                    temp=temp(1+option.num_extreme:end-option.num_extreme,:,:,:,:,:);
                end
                bl(dx,:,:,:,:,:)=mean(temp,1);
                if strcmpi(option.operation,'zscore');
                    stdbl(dx,:,:,:,:,:)=std(temp,[],1);
                end
            end
            
            switch option.operation
                case 'subtract'
                    data=data-bl;
                case 'snr'
                    data=data./bl;
                case 'zscore'
                    stdbl(stdbl==0)=eps;
                    data=(data-bl)./stdbl;
                case 'percent'
                    data=(data-bl)./bl;
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