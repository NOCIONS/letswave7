classdef FLW_merge<CLW_generic
    properties
        FLW_TYPE=2;
        h_merge_items_pop;
    end
    methods
        function obj = FLW_merge(batch_handle)
            obj@CLW_generic(batch_handle,'merge','merge_epoch',...
                'Merge multiple data files with similar poperty into one data file. Since multiple data files are involved, this operation must be kept in a separate section.');
            set(obj.h_is_save_chx,'enable','off');           
            uicontrol('style','text','position',[35,470,200,20],...
                'string','Merge Items:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_merge_items_pop=uicontrol('style','popupmenu',...
                'String',{'epoch','channel','index'},...
                'callback',@obj.item_Changed,'position',[35,440,150,30],...
                'parent',obj.h_panel);
        end
        
        function item_Changed(obj,varargin)
            st_value=get(obj.h_merge_items_pop,'value');
            str=get(obj.h_suffix_edit,'string');
            if sum(strcmp(str,{'merge_epoch','merge_channel','merge_index'}))
                switch(st_value)
                    case 1
                        set(obj.h_suffix_edit,'string','merge_epoch');
                    case 2
                        set(obj.h_suffix_edit,'string','merge_channel');
                    case 3
                        set(obj.h_suffix_edit,'string','merge_index');
                end
            end
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            st=get(obj.h_merge_items_pop,'String');
            st_value=get(obj.h_merge_items_pop,'value');
            option.type=st{st_value};
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            switch option.type
                case 'merge_epoch'
                    set(obj.h_merge_items_pop,'value',1);
                case 'merge_channel'
                    set(obj.h_merge_items_pop,'value',2);
                case 'merge_index'
                    set(obj.h_merge_items_pop,'value',3);
            end
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''type'',''',option.type,''','];
            temp='option=struct(';
            temp=[temp,frag_code];
            temp=[temp,'''suffix'',''',option.suffix,''','];
            temp=[temp,'''is_save'',',num2str(option.is_save)];
            temp=[temp,');'];
            str=[{temp},{['lwdata= ',class(obj),'.get_lwdata(lwdataset,option);']}];
        end
        
        function header_update(obj,batch_pre)
            lwdataset=batch_pre.lwdataset;
            option=get_option(obj);
            evalc('obj.lwdataset.header = obj.get_header(lwdataset,option);');
            if option.is_save
                obj.virtual_filelist(end+1)=struct(...
                    'filename',obj.lwdataset.header.name,...
                    'header',obj.lwdataset.header);
            end
        end
    end
    
    methods (Static = true)
        function header_out= get_header(lwdataset_in,option)
            if isempty(lwdataset_in)
                error('***Not enough files to merge.***');
            end
            switch(option.type)
                case 'epoch'
                    header_out = FLW_merge.get_header_epoch(lwdataset_in);
                case 'channel'
                    header_out = FLW_merge.get_header_channel(lwdataset_in);
                case 'index'
                    header_out = FLW_merge.get_header_index(lwdataset_in);
            end
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function header_out= get_header_epoch(lwdataset_in)
            %% check the files
            header_out=lwdataset_in(1).header;
            for dataset_pos=2:length(lwdataset_in)
                if ~(header_out.datasize(2:6)==lwdataset_in(dataset_pos).header.datasize(2:6));
                    error('***Datasets cannot be merged as their sizes do not match. ***');
                end
            end
            num_epochs=lwdataset_in(1).header.datasize(1);
            for dataset_pos=2:length(lwdataset_in)
                if ~isempty(lwdataset_in(dataset_pos).header.events)
                    events=lwdataset_in(dataset_pos).header.events;
                    for i=1:length(events);
                        events(i).epoch=events(i).epoch+num_epochs;
                    end
                    header_out.events=[header_out.events,events];
                end
                num_epochs=num_epochs+lwdataset_in(dataset_pos).header.datasize(1);
            end
            header_out.datasize(1)=num_epochs;
        end
        
        function header_out= get_header_channel(lwdataset_in)
            %% check the files
            header_out=lwdataset_in(1).header;
            for dataset_pos=2:length(lwdataset_in)
                if ~(header_out.datasize([1,3:6])==lwdataset_in(dataset_pos).header.datasize([1,3:6]));
                    error('***Datasets cannot be merged as their sizes do not match. ***');
                end
            end
            for dataset_pos=2:length(lwdataset_in)
                header_out.chanlocs=[header_out.chanlocs lwdataset_in(dataset_pos).header.chanlocs];
                header_out.events=[header_out.events  lwdataset_in(dataset_pos).header.events];
            end
            labels={header_out.chanlocs.labels};labels={header_out.chanlocs.labels};
            [~,ia,ic]=unique(labels,'stable');
            index=zeros(1,length(labels));
            for k=setdiff(1:length(labels),ia)
                index(ic(k))=index(ic(k))+1;
                labels{k}=[labels{k},'_',num2str(index(ic(k)))];
            end
            [header_out.chanlocs.labels]=deal(labels{:});
            header_out=CLW_events_duplicate_check(header_out);
            header_out.datasize(2)=length(header_out.chanlocs);
        end
        
        function header_out= get_header_index(lwdataset_in)
            %% check the files
            header_out=lwdataset_in(1).header;
            for dataset_pos=2:length(lwdataset_in)
                if ~(header_out.datasize([1:2,4:6])==lwdataset_in(dataset_pos).header.datasize([1:2,4:6]));
                    error('***Datasets cannot be merged as their sizes do not match. ***');
                end
            end
            for dataset_pos=2:length(lwdataset_in)
                header_out.index_labels=[header_out.index_labels lwdataset_in(dataset_pos).header.index_labels];
                header_out.events=[header_out.events  lwdataset_in(dataset_pos).header.events];
            end
            header_out=CLW_events_duplicate_check(header_out);
            header_out.datasize(3)=length(header_out.index_labels);
        end
        
        function lwdata_out=get_lwdata(lwdataset_in,varargin)
            option.suffix='merge_epoch';
            option.type='epoch';
            option.is_save=0;
            option=CLW_check_input(option,{'type','suffix','is_save'},varargin);
            
            header= FLW_merge.get_header(lwdataset_in,option);
            data=lwdataset_in(1).data;
            switch(option.type)
                case 'epoch'
                    for dataset_pos=2:length(lwdataset_in)
                        data=cat(1,data,lwdataset_in(dataset_pos).data);
                    end
                case 'channel'
                    for dataset_pos=2:length(lwdataset_in)
                        data=cat(2,data,lwdataset_in(dataset_pos).data);
                    end
                case 'index'
                    for dataset_pos=2:length(lwdataset_in)
                        data=cat(3,data,lwdataset_in(dataset_pos).data);
                    end
            end
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end