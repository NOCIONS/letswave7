classdef FLW_threshold<CLW_generic
    properties
        FLW_TYPE=1;
        h_threshold_value_edt;
        h_threshold_criterion_pop;
        h_consecutivity_criterion_edt;
    end
    
    methods
        function obj = FLW_threshold(batch_handle)
            obj@CLW_generic(batch_handle,'threshold','threshold',...
                'Threshold signals. Apply a threshold criterion to the datasets.');
            
            uicontrol('style','text','position',[20,468,150,20],...
                'string','Threshold value:',...
                'HorizontalAlignment','right','parent',obj.h_panel);
            obj.h_threshold_value_edt=uicontrol('style','edit','String','0.1',...
                'backgroundcolor',[1,1,1],'position',[175,470,110,20],...
                'parent',obj.h_panel);
            
            uicontrol('style','text','position',[20,418,150,20],...
                'string','Threshold Criterion:',...
                'HorizontalAlignment','right','parent',obj.h_panel);
            obj.h_threshold_criterion_pop=uicontrol('style','popupmenu','String',...
                {'>','<','>=','<=','=='},'backgroundcolor',[1,1,1],...
                'position',[175,420,110,20],'parent',obj.h_panel);
            
            
            uicontrol('style','text','position',[20,368,150,20],...
                'string','Consecutivity Criterion:',...
                'HorizontalAlignment','right','parent',obj.h_panel);
            obj.h_consecutivity_criterion_edt=uicontrol('style','edit','String','1',...
                'position',[175,370,110,20],'backgroundcolor',[1,1,1],...
                'parent',obj.h_panel);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.threshold_value=str2num(get(obj.h_threshold_value_edt,'string'));
            option.threshold_criterion=get(obj.h_threshold_criterion_pop,'value');
            switch option.threshold_criterion
                case 1
                    option.threshold_criterion='>';
                case 2
                    option.threshold_criterion='<';
                case 3
                    option.threshold_criterion='>=';
                case 4
                    option.threshold_criterion='<=';
                case 5
                    option.threshold_criterion='==';
            end
            option.consecutivity_criterion=str2num(get(obj.h_consecutivity_criterion_edt,'string'));
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            switch option.threshold_criterion
                case '>'
                    set(obj.h_operation_pop,'value',1);
                case '<'
                    set(obj.h_operation_pop,'value',2);
                case '>='
                    set(obj.h_operation_pop,'value',3);
                case '<='
                    set(obj.h_operation_pop,'value',4);
                case '=='
                    set(obj.h_operation_pop,'value',5);
            end
            set(obj.h_threshold_value_edt,'string',num2str(option.threshold_value));
            set(obj.h_consecutivity_criterion_edt,'string',num2str(option.consecutivity_criterion));
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''threshold_value'',',...
                num2str(option.threshold_value),','];
            frag_code=[frag_code,'''threshold_criterion'',''',...
                option.threshold_criterion,''','];
            frag_code=[frag_code,'''consecutivity_criterion'',',...
                num2str(option.consecutivity_criterion),','];
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
            option.threshold_value=0.2;
            option.threshold_criterion='>';
            option.consecutivity_criterion=1;
            option.suffix='threshold';
            option.is_save=0;
            option=CLW_check_input(option,{'threshold_value',...
                'threshold_criterion','consecutivity_criterion',...
                'suffix','is_save'},varargin);
            header=FLW_threshold.get_header(lwdata_in.header,option);
            
            switch option.threshold_criterion
                case '>'
                    data=double(lwdata_in.data>option.threshold_value);
                case '<'
                    data=double(lwdata_in.data<option.threshold_value);
                case '>='
                    data=double(lwdata_in.data>=option.threshold_value);
                case '<='
                    data=double(lwdata_in.data<=option.threshold_value);
                case '=='
                    data=double(lwdata_in.data==option.threshold_value);
            end
            data=permute(data,[6,5,4,3,2,1]);
            N=size(data(:,:),2);
            if option.consecutivity_criterion>1
                for k=1:N
                    L = bwlabel(data(:,k));
                    L_max=max(L);
                    for l=1:L_max
                        idx_temp=(L==l);
                        if sum(idx_temp)<option.consecutivity_criterion
                            data(idx_temp,k)=0;
                        end
                    end
                end
            end
            data=ipermute(data,[6,5,4,3,2,1]);
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end