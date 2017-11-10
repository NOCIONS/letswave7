classdef FLW_math<CLW_generic
    properties
        FLW_TYPE=4;
        h_operation_pop;
        h_reference_pop;
    end
    
    methods
        function obj = FLW_math(batch_handle)
            obj@CLW_generic(batch_handle,'math','add',...
                'Compute simple mathematical operations between two datasets.');
            
            uicontrol('style','text','position',[35,470,200,20],...
                'string','Operation:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_operation_pop=uicontrol('style','popupmenu',...
                'String',{'Add (A+B)','Subtract (A-B)','Multiple (A*B)','Divide (A/B)'},...
                 'backgroundcolor',[1,1,1],'value',1,'callback',@obj.method_change,...
                 'position',[35,440,300,30],'parent',obj.h_panel);
            uicontrol('style','text','position',[35,410,150,19],...
                'string','Reference Dataset (B):','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_reference_pop=uicontrol('style','popupmenu','value',1,...
                'String',{'Dataset 1'},...
                'backgroundcolor',1*[1,1,1],...
                'position',[35,380,200,30],'parent',obj.h_panel);
        end
        
        function method_change(obj,varargin)
            index=get(obj.h_operation_pop,'value');
            str=get(obj.h_suffix_edit,'string');
            if sum(strcmp(str,{'add','sub','mul','div'}))==1
                switch(index)
                    case 1
                        set(obj.h_suffix_edit,'string','add');
                    case 2
                        set(obj.h_suffix_edit,'string','sub');
                    case 3
                        set(obj.h_suffix_edit,'string','mul');
                    case 4
                        set(obj.h_suffix_edit,'string','div');
                end
            end
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            switch get(obj.h_operation_pop,'value')
                case 1
                    option.operation='add';
                case 2
                    option.operation='sub';
                case 3
                    option.operation='mul';
                case 4
                    option.operation='div';
            end
            option.ref_dataset=get(obj.h_reference_pop ,'value');
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            switch option.operation
                case 'add'
                    set(obj.h_operation_pop,'value',1);
                case 'sub'
                    set(obj.h_operation_pop,'value',2);
                case 'mul'
                    set(obj.h_operation_pop,'value',3);
                case 'div'
                    set(obj.h_operation_pop,'value',4);
            end
            str=get(obj.h_suffix_edit,'string');
            if sum(strcmp(str,{'add','sub','mul','div'}))==1
                switch(option.operation)
                    case 1
                        set(obj.h_suffix_edit,'string','add');
                    case 2
                        set(obj.h_suffix_edit,'string','sub');
                    case 3
                        set(obj.h_suffix_edit,'string','mul');
                    case 4
                        set(obj.h_suffix_edit,'string','div');
                end
            end
            
            N=length(get(obj.h_reference_pop ,'string'));
            if option.ref_dataset>N || option.ref_dataset<1
                get(obj.h_reference_pop ,'value',1);
            else
                get(obj.h_reference_pop ,'value',option.ref_dataset);
            end
        end
        
        function GUI_update(obj,batch_pre)
            GUI_update@CLW_generic(obj,batch_pre);
            obj.lwdataset=batch_pre.lwdataset;
            str_old=get(obj.h_reference_pop,'string');
            value=get(obj.h_reference_pop,'value');
            str_old=str_old{value};
            str={};
            value=1;
            for k=1:length(obj.lwdataset)
                str{end+1}=obj.lwdataset(k).header.name;
                if strcmp(str_old,str{end})
                    value=k;
                end
            end
            set(obj.h_reference_pop,'string',str);
            set(obj.h_reference_pop,'value',value);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''operation'',''',...
                option.operation,''','];
            frag_code=[frag_code,'''ref_dataset'',',...
                num2str(option.ref_dataset),','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function header_update(obj,batch_pre)
            obj.virtual_filelist=batch_pre.virtual_filelist;
            option=get_option(obj);
            %evalc is used to block the information in Command Window
            evalc ('obj.lwdataset=obj.get_headerset(batch_pre.lwdataset,option);')
            if option.is_save
                for data_pos=1:length(obj.lwdataset)
                    obj.virtual_filelist(end+1)=struct(...
                        'filename',obj.lwdataset(data_pos).header.name,...
                        'header',obj.lwdataset(data_pos).header);
                end
            end
        end
    end
    
    methods (Static = true)
        function lwdataset_out= get_headerset(lwdataset_in,option)
            N=length(lwdataset_in);
            lwdataset_out=[];
            option.ref_name=lwdataset_in(option.ref_dataset).header.name;
            for k=setdiff(1:N,option.ref_dataset)
                lwdataset_out(end+1).header=FLW_ttest.get_header(lwdataset_in(k).header,option);
                lwdataset_out(end).data=[];
            end
        end
        
        function header_out= get_header(header_in,option)
            header_out=header_in;
            header_out.events=[];
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            option.ref_dataset=2;
            header_out.history(end+1).option=option;
        end
        
        function lwdataset_out= get_lwdataset(lwdataset_in,varargin)
            option.operation='add';
            option.ref_dataset=2;
            option.suffix='add';
            option.is_save=0;
            option=CLW_check_input(option,{'operation','ref_dataset','suffix','is_save'},...
                varargin);
            %lwdataset_out = FLW_ttest.get_headerset(lwdataset_in,option);
            
            N=length(lwdataset_in);
            dataset_idx=setdiff(1:N,option.ref_dataset);
            lwdataset_out=struct('header',[],'data',[]);
            for k=1:N-1
                lwdataset_out(end+1)=FLW_math.get_lwdata(lwdataset_in([dataset_idx(k),option.ref_dataset]),option);
            end
        end
        
        function lwdata_out=get_lwdata(lwdataset_in,varargin)
            option.operation='add';
            option.suffix='add';
            option.is_save=0;
            option=CLW_check_input(option,{'operation','suffix','is_save'},...
                varargin);
            option.ref_name=lwdataset_in(2).header.name;
            header=FLW_math.get_header(lwdataset_in(1).header,option);
            switch option.operation
                case 'add'
                    data=lwdataset_in(1).data+lwdataset_in(2).data;
                case 'sub'
                    data=lwdataset_in(1).data-lwdataset_in(2).data;
                case 'mul'
                    data=lwdataset_in(1).data.*lwdataset_in(2).data;
                case 'div'
                    data=lwdataset_in(1).data./lwdataset_in(2).data;
            end
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end