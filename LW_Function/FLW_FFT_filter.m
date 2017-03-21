classdef FLW_FFT_filter<CLW_generic
    properties
        FLW_TYPE=1;
        h_filtertype_pop;
        
        h_all_option;
        h_low_cutoff_txt
        h_low_cutoff_edt;
        h_low_width_txt;
        h_low_width_edt;
        h_high_cutoff_txt;
        h_high_cutoff_edt;
        h_high_width_txt;
        h_high_width_edt;
        
        h_notch_fre_txt
        h_notch_fre_edt;
        h_notch_width_txt;
        h_notch_width_edt;
        h_slope_width_txt;
        h_slope_width_edt;
        h_harmonic_num_txt;
        h_harmonic_num_edt;
    end
    
    methods
        function obj = FLW_FFT_filter(batch_handle)
            obj@CLW_generic(batch_handle,'FFT filter','filt_fft',...
                'Apply an FFT filter to the dataset(s). A Hanning window is used to design the cutoff transition.');
            uicontrol('style','text','position',[35,470,200,20],...
                'string','Filter Type','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_filtertype_pop=uicontrol('style','popupmenu',...
                'String',{'lowpass','highpass','bandpass','notch'},...
                'value',3,'callback',@obj.method_change,...
                'position',[35,440,360,30],'parent',obj.h_panel);
            %%
            obj.h_low_cutoff_txt=uicontrol('style','text','position',[15,400,150,19],...
                'string','low cutoff frequency(Hz):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_low_cutoff_edt=uicontrol('style','edit',...
                'String','0.5','position',[180,400,100,19],'parent',obj.h_panel);
            obj.h_low_width_txt=uicontrol('style','text','position',[15,370,150,19],...
                'string','width(Hz):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_low_width_edt=uicontrol('style','edit',...
                'String','0.25','position',[180,370,100,19],'parent',obj.h_panel);
            
            obj.h_high_cutoff_txt=uicontrol('style','text','position',[15,340,150,19],...
                'string','high cutoff frequency(Hz):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_high_cutoff_edt=uicontrol('style','edit',...
                'String','30','position',[180,340,100,19],'parent',obj.h_panel);
            obj.h_high_width_txt=uicontrol('style','text','position',[15,310,150,19],...
                'string','width(Hz):','HorizontalAlignment','right',...
                'parent',obj.h_panel);
            obj.h_high_width_edt=uicontrol('style','edit',...
                'String','1','position',[180,310,100,19],'parent',obj.h_panel);
            
           obj.h_notch_fre_txt=uicontrol('style','text','position',[15,400,150,19],...
                'string','notch frequency(Hz):','HorizontalAlignment','right',...
                'parent',obj.h_panel,'visible','off');
            obj.h_notch_fre_edt=uicontrol('style','edit',...
                'String','50','position',[180,400,100,19],'parent',obj.h_panel,'visible','off');
            obj.h_notch_width_txt=uicontrol('style','text','position',[15,370,150,19],...
                'string','notch width(Hz):','HorizontalAlignment','right',...
                'parent',obj.h_panel,'visible','off');
            obj.h_notch_width_edt=uicontrol('style','edit',...
                'String','2','position',[180,370,100,19],'parent',obj.h_panel,'visible','off');
            
            obj.h_slope_width_txt=uicontrol('style','text','position',[15,340,150,19],...
                'string','slpoe cutoff width(Hz):','HorizontalAlignment','right',...
                'parent',obj.h_panel,'visible','off');
            obj.h_slope_width_edt=uicontrol('style','edit',...
                'String','2','position',[180,340,100,19],'parent',obj.h_panel,'visible','off');
            obj.h_harmonic_num_txt=uicontrol('style','text','position',[15,310,150,19],...
                'string','number of the harmonics:','HorizontalAlignment','right',...
                'parent',obj.h_panel,'visible','off');
            obj.h_harmonic_num_edt=uicontrol('style','edit',...
                'String','2','position',[180,310,100,19],'parent',obj.h_panel,'visible','off');
            obj.h_all_option=[  obj.h_low_cutoff_txt;   obj.h_low_cutoff_edt;
                obj.h_low_width_txt;    obj.h_low_width_edt;
                obj.h_high_cutoff_txt;  obj.h_high_cutoff_edt;
                obj.h_high_width_txt;   obj.h_high_width_edt;
                obj.h_notch_fre_txt;    obj.h_notch_fre_edt;
                obj.h_notch_width_txt;  obj.h_notch_width_edt;
                obj.h_slope_width_txt;  obj.h_slope_width_edt;
                obj.h_harmonic_num_txt;	obj.h_harmonic_num_edt];
            set(obj.h_filtertype_pop,'backgroundcolor',[1,1,1]);
            set(obj.h_low_cutoff_edt,'backgroundcolor',[1,1,1]);
            set(obj.h_low_width_edt,'backgroundcolor',[1,1,1]);
            set(obj.h_high_cutoff_edt,'backgroundcolor',[1,1,1]);
            set(obj.h_high_width_edt,'backgroundcolor',[1,1,1]);
            set(obj.h_notch_fre_edt,'backgroundcolor',[1,1,1]);
            set(obj.h_notch_width_edt,'backgroundcolor',[1,1,1]);
            set(obj.h_slope_width_edt,'backgroundcolor',[1,1,1]);
            set(obj.h_harmonic_num_edt,'backgroundcolor',[1,1,1]);
        end
        
        function method_change(obj,varargin)
            index=get(obj.h_filtertype_pop,'value');
            set(obj.h_all_option,'visible','off');
            switch(index)
                case 1%lowpass
                    set(obj.h_high_cutoff_txt,'visible','on');
                    set(obj.h_high_cutoff_edt,'visible','on');
                    set(obj.h_high_width_txt,'visible','on');
                    set(obj.h_high_width_edt,'visible','on');
                case 2%highpass
                    set(obj.h_low_cutoff_txt,'visible','on');
                    set(obj.h_low_cutoff_edt,'visible','on');
                    set(obj.h_low_width_txt,'visible','on');
                    set(obj.h_low_width_edt,'visible','on');
                case 3%bandpass
                    set(obj.h_low_cutoff_txt,'visible','on');
                    set(obj.h_low_cutoff_edt,'visible','on');
                    set(obj.h_low_width_txt,'visible','on');
                    set(obj.h_low_width_edt,'visible','on');
                    set(obj.h_high_cutoff_txt,'visible','on');
                    set(obj.h_high_cutoff_edt,'visible','on');
                    set(obj.h_high_width_txt,'visible','on');
                    set(obj.h_high_width_edt,'visible','on');
                case 4%notch
                    set(obj.h_notch_fre_txt,'visible','on');
                    set(obj.h_notch_fre_edt,'visible','on');
                    set(obj.h_notch_width_txt,'visible','on');
                    set(obj.h_notch_width_edt,'visible','on');
                    set(obj.h_slope_width_txt,'visible','on');
                    set(obj.h_slope_width_edt,'visible','on');
                    set(obj.h_harmonic_num_txt,'visible','on');
                    set(obj.h_harmonic_num_edt,'visible','on');
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
                    option.high_width=str2num(get(obj.h_high_width_edt,'string'));
                case 'highpass'
                    option.low_cutoff=str2num(get(obj.h_low_cutoff_edt,'string'));
                    option.low_width=str2num(get(obj.h_low_width_edt,'string'));
                case 'bandpass'
                    option.high_cutoff=str2num(get(obj.h_high_cutoff_edt,'string'));
                    option.high_width=str2num(get(obj.h_high_width_edt,'string'));
                    option.low_cutoff=str2num(get(obj.h_low_cutoff_edt,'string'));
                    option.low_width=str2num(get(obj.h_low_width_edt,'string'));
                case 'notch'
                    option.notch_fre=str2num(get(obj.h_notch_fre_edt,'string'));
                    option.notch_width=str2num(get(obj.h_notch_width_edt,'string'));
                    option.slope_width=str2num(get(obj.h_slope_width_edt,'string'));
                    option.harmonic_num=str2num(get(obj.h_harmonic_num_edt,'string'));
            end
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_all_option,'visible','off');
            switch option.filter_type
                case 'lowpass'
                    set(obj.h_filtertype_pop,'value',1);
                    set(obj.h_high_cutoff_txt,'visible','on');
                    set(obj.h_high_cutoff_edt,'visible','on');
                    set(obj.h_high_width_txt,'visible','on');
                    set(obj.h_high_width_edt,'visible','on');
                    set(obj.h_high_cutoff_edt,'string',num2str(option.high_cutoff));
                    set(obj.h_high_width_edt,'string',num2str(option.high_width));
                case 'highpass'
                    set(obj.h_filtertype_pop,'value',2);
                    set(obj.h_low_cutoff_txt,'visible','on');
                    set(obj.h_low_cutoff_edt,'visible','on');
                    set(obj.h_low_width_txt,'visible','on');
                    set(obj.h_low_width_edt,'visible','on');
                    set(obj.h_low_cutoff_edt,'string',num2str(option.low_cutoff));
                    set(obj.h_low_width_edt,'string',num2str(option.low_width));
                case 'bandpass'
                    set(obj.h_filtertype_pop,'value',3);
                    set(obj.h_low_cutoff_txt,'visible','on');
                    set(obj.h_low_cutoff_edt,'visible','on');
                    set(obj.h_low_width_txt,'visible','on');
                    set(obj.h_low_width_edt,'visible','on');
                    set(obj.h_high_cutoff_txt,'visible','on');
                    set(obj.h_high_cutoff_edt,'visible','on');
                    set(obj.h_high_width_txt,'visible','on');
                    set(obj.h_high_width_edt,'visible','on');
                    set(obj.h_high_cutoff_edt,'string',num2str(option.high_cutoff));
                    set(obj.h_high_width_edt,'string',num2str(option.high_width));
                    set(obj.h_low_cutoff_edt,'string',num2str(option.low_cutoff));
                    set(obj.h_low_width_edt,'string',num2str(option.low_width));
                case 'notch'
                    set(obj.h_filtertype_pop,'value',4);
                    set(obj.h_notch_fre_txt,'visible','on');
                    set(obj.h_notch_fre_edt,'visible','on');
                    set(obj.h_notch_width_txt,'visible','on');
                    set(obj.h_notch_width_edt,'visible','on');
                    set(obj.h_slope_width_txt,'visible','on');
                    set(obj.h_slope_width_edt,'visible','on');
                    set(obj.h_harmonic_num_txt,'visible','on');
                    set(obj.h_harmonic_num_edt,'visible','on');
                    set(obj.h_notch_fre_edt,'string',num2str(option.notch_fre));
                    set(obj.h_notch_width_edt,'string',num2str(option.notch_width));
                    set(obj.h_slope_width_edt,'string',num2str(option.slope_width));
                    set(obj.h_harmonic_num_edt,'string',num2str(option.harmonic_num));
            end
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''filter_type'',''',option.filter_type,''','];
            switch option.filter_type
                case 'lowpass'
                    frag_code=[frag_code,'''high_cutoff'',',num2str(option.high_cutoff),','];
                    frag_code=[frag_code,'''high_width'',',num2str(option.high_width),','];
                case 'highpass'
                    frag_code=[frag_code,'''low_cutoff'',',num2str(option.low_cutoff),','];
                    frag_code=[frag_code,'''low_width'',',num2str(option.low_width),','];
                case 'bandpass'
                    frag_code=[frag_code,'''high_cutoff'',',num2str(option.high_cutoff),','];
                    frag_code=[frag_code,'''high_width'',',num2str(option.high_width),','];
                    frag_code=[frag_code,'''low_cutoff'',',num2str(option.low_cutoff),','];
                    frag_code=[frag_code,'''low_width'',',num2str(option.low_width),','];
                case 'notch'
                    frag_code=[frag_code,'''notch_fre'',',num2str(option.notch_fre),','];
                    frag_code=[frag_code,'''notch_width'',',num2str(option.notch_width),','];
                    frag_code=[frag_code,'''slope_width'',',num2str(option.slope_width),','];
                    frag_code=[frag_code,'''harmonic_num'',',num2str(option.harmonic_num),','];
            end
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
            option.high_width=1;
            option.low_cutoff=0.5;
            option.low_width=0.25;
            option.notch_fre=50;
            option.notch_width=2;
            option.slope_width=2;
            option.harmonic_num=2;
            option.suffix='filt_fft';
            option.is_save=0;
            option=CLW_check_input(option,{'filter_type','high_cutoff',...
                'high_width','low_cutoff','low_width','notch_fre',...
                'notch_width','slope_width','harmonic_num','suffix',...
                'is_save'},varargin);
            switch option.filter_type
                case 'lowpass'
                    option=rmfield(option,{'low_cutoff','low_width',...
                        'notch_fre','notch_width',...
                        'slope_width','harmonic_num'});
                case 'highpass'
                    option=rmfield(option,{'high_cutoff','high_width',...
                        'notch_fre','notch_width',...
                        'slope_width','harmonic_num'});
                case 'bandpass'
                    option=rmfield(option,{'notch_fre','notch_width',...
                        'slope_width','harmonic_num'});
                case 'notch'
                    option=rmfield(option,{'low_cutoff','low_width',...
                        'high_cutoff','high_width'});
            end
            header=FLW_FFT_filter.get_header(lwdata_in.header,option);
            v = CLW_buildFFTfilter(header,option);
            data=lwdata_in.data;
            temp=lwdata_in.header.datasize;
            temp(6)=1;
            data=real(ifft(fft(data,[],6).*repmat(permute(v,[1,3,4,5,6,2]),temp),[],6));
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end