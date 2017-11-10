classdef FLW_butterworth_filter<CLW_generic
    properties
        FLW_TYPE=1;
        
        h_all_option;
        h_filtertype_pop;
        h_low_cutoff_txt;
        h_low_cutoff_edt;
        h_high_cutoff_txt;
        h_high_cutoff_edt;
        h_filter_order_txt;
        h_filter_order_edt;
    end
    
    methods
        function obj = FLW_butterworth_filter(batch_handle)
            obj@CLW_generic(batch_handle,'butterworth filter','butt',...
                'Apply a Butterworth filter to the dataset. A Hanning window is used to design the cutoff transition.');
            
            uicontrol('style','text','position',[35,470,200,20],...
                'string','filter type:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_filtertype_pop=uicontrol('style','popupmenu',...
                'String',{'lowpass','highpass','bandpass','notch'},...
                 'backgroundcolor',[1,1,1],...
                 'value',3,'callback',@obj.method_change,...
                'position',[35,440,300,30],'parent',obj.h_panel);
            
            obj.h_low_cutoff_txt=uicontrol('style','text','position',[15,410,150,19],...
                'string','low cutoff frequency(Hz):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_low_cutoff_edt=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','0.5','position',[180,410,100,19],'parent',obj.h_panel);
            obj.h_high_cutoff_txt=uicontrol('style','text','position',[15,370,150,19],...
                'string','high cutoff frequency(Hz):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_high_cutoff_edt=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','30','position',[180,370,100,19],'parent',obj.h_panel);
            
            obj.h_filter_order_txt=uicontrol('style','text','position',[15,340,150,19],...
                'string','filter order:','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_filter_order_edt=uicontrol('style','edit',...
                 'backgroundcolor',[1,1,1],...
                'String','4','position',[180,340,100,19],'parent',obj.h_panel);
            obj.h_all_option=[  obj.h_low_cutoff_txt;   obj.h_low_cutoff_edt;
                obj.h_high_cutoff_txt;  obj.h_high_cutoff_edt];
        end
         
        function method_change(obj,varargin)
            index=get(obj.h_filtertype_pop,'value');
            set(obj.h_all_option,'visible','on');
            switch(index)
                case 1%lowpass
                    set(obj.h_low_cutoff_txt,'visible','off');
                    set(obj.h_low_cutoff_edt,'visible','off');
                case 2%highpass
                    set(obj.h_high_cutoff_txt,'visible','off');
                    set(obj.h_high_cutoff_edt,'visible','off');
            end
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            str=get(obj.h_filtertype_pop,'String');
            str_value=get(obj.h_filtertype_pop,'value');
            option.filter_type=str{str_value};
            switch(option.filter_type)
                case 'lowpass'
                    option.high_cutoff=str2num(get(obj.h_high_cutoff_edt,'string'));
                case 'highpass'
                    option.low_cutoff=str2num(get(obj.h_low_cutoff_edt,'string'));
                case {'bandpass','notch'}
                    option.high_cutoff=str2num(get(obj.h_high_cutoff_edt,'string'));
                    option.low_cutoff=str2num(get(obj.h_low_cutoff_edt,'string'));
            end
            option.filter_order=str2num(get(obj.h_filter_order_edt,'string'));
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_all_option,'visible','on');
            switch(option.filter_type)
                case 'lowpass'
                    set(obj.h_filtertype_pop,'value',1);
                    set(obj.h_high_cutoff_edt,'string',num2str(option.high_cutoff));
                    set(obj.h_low_cutoff_txt,'visible','off');
                    set(obj.h_low_cutoff_edt,'visible','off');
                case 'highpass'
                    set(obj.h_filtertype_pop,'value',2);
                    set(obj.h_low_cutoff_edt,'string',num2str(option.low_cutoff));
                    set(obj.h_high_cutoff_txt,'visible','off');
                    set(obj.h_high_cutoff_edt,'visible','off');
                case 'bandpass'
                    set(obj.h_filtertype_pop,'value',3);
                    set(obj.h_high_cutoff_edt,'string',num2str(option.high_cutoff));
                    set(obj.h_low_cutoff_edt,'string',num2str(option.low_cutoff));
                case 'notch'
                    set(obj.h_filtertype_pop,'value',4);
                    set(obj.h_high_cutoff_edt,'string',num2str(option.high_cutoff));
                    set(obj.h_low_cutoff_edt,'string',num2str(option.low_cutoff));
            end
            set(obj.h_filter_order_edt,'string',num2str(option.filter_order));
            
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''filter_type'',''',option.filter_type,''','];
            switch option.filter_type
                case 'lowpass'
                    frag_code=[frag_code,'''high_cutoff'',',num2str(option.high_cutoff),','];
                case 'highpass'
                    frag_code=[frag_code,'''low_cutoff'',',num2str(option.low_cutoff),','];
                case {'bandpass','notch'}
                    frag_code=[frag_code,'''high_cutoff'',',num2str(option.high_cutoff),','];
                    frag_code=[frag_code,'''low_cutoff'',',num2str(option.low_cutoff),','];
            end
            frag_code=[frag_code,'''filter_order'',',num2str(option.filter_order),','];
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
            option.filter_type='bandpass';
            option.high_cutoff=30;
            option.low_cutoff=0.5;
            option.filter_order=0.5;
            option.suffix='butt';
            option.is_save=0;
            option=CLW_check_input(option,{'filter_type','high_cutoff',...
                'low_cutoff','filter_order','suffix','is_save'},varargin);
            switch option.filter_type
                case 'lowpass'
                    option=rmfield(option,'low_cutoff');
                case 'highpass'
                    option=rmfield(option,'high_cutoff');
            end
            header=FLW_butterworth_filter.get_header(lwdata_in.header,option);
            data=lwdata_in.data;
            data=permute(data,[6,1,2,3,4,5]);
            data=reshape(data,size(data,1),[]);
            data=[ones(option.filter_order*3,1)*data(1,:);data;ones(option.filter_order*3,1)*data(end,:);];
            Fs=1/header.xstep;
            fnyquist=Fs/2;
            switch option.filter_type
                case 'lowpass'
                    [b,a]=butter(option.filter_order,option.high_cutoff/fnyquist,'low');
                    data=filtfilt(b,a,data);
                case 'highpass'
                    [b,a]=butter(option.filter_order,option.low_cutoff/fnyquist,'high');
                    data=filtfilt(b,a,data);
                case 'bandpass'
                    filtOrder=option.filter_order;
                    if mod(filtOrder,2)
                        filtOrder=filtOrder-1;
                    end
                    filtOrder=filtOrder/2;
                    [b,a]=butter(filtOrder,option.high_cutoff/fnyquist,'low');
                    data=filtfilt(b,a,data);
                    [b,a]=butter(filtOrder,option.low_cutoff/fnyquist,'high');
                    data=filtfilt(b,a,data);
                case 'notch'
                    [b,a]=butter(option.filter_order,[option.low_cutoff,...
                        option.high_cutoff]/fnyquist,'stop');
                    data=filtfilt(b,a,data);
            end
            
            data=data(option.filter_order*3+1:end-option.filter_order*3,:);
            data=reshape(data,lwdata_in.header.datasize([6,1,2,3,4,5]));
            data=ipermute(data,[6,1,2,3,4,5]);
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end