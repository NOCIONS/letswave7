classdef FLW_selection<CLW_generic
    properties
        FLW_TYPE=1;
        h_selection_items_pop;
        h_not_equal_txt;
        h_old_list;
        h_new_list;
        
        h_add_top_btn;
        h_add_bottom_btn;
        h_add_all_btn;
        h_insert_btn;
        
        h_sort_asc_btn;
        h_sort_desc_btn;
        h_sort_up_btn;
        h_sort_down_btn;
        
        
        h_remove_btn;
        h_remove_all_btn;
        
        h_select_odd_btn;
        h_select_even_btn;
        
        labels_chan;
        labels_epoch;
        labels_idx;
        isequal_chan;
        isequal_epoch;
        isequal_idx;
    end
    
    methods
        function obj = FLW_selection(batch_handle)
            icon=load('icon.mat');
            obj@CLW_generic(batch_handle,'selection','sel_chan',...
                'Selection the signal by channel/epoch/index.');
            uicontrol('style','text','position',[20,490,150,20],...
                'string','Selection Items:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_selection_items_pop=uicontrol('style','popupmenu',...
                'String',{'epoch','channel','index'},'value',2,...
                'callback',@obj.item_Changed,'position',[130,485,150,30],...
                'parent',obj.h_panel);
            
            obj.h_old_list=uicontrol('style','listbox','min',0,'max',2,...
                'position',[28,160,120,320],'parent',obj.h_panel,...
                'Callback',@obj.old_list_Callback);
            
            obj.h_new_list=uicontrol('style','listbox','min',0,'max',2,...
                'position',[255,160,120,320],'parent',obj.h_panel);
            
            
            obj.h_add_top_btn=uicontrol('style','pushbutton',...
                'string','Add Top','callback',@obj.add_top_Callback,...
                'position',[159,450,80,28],'parent',obj.h_panel);
            obj.h_add_bottom_btn=uicontrol('style','pushbutton',...
                'string','Add Bottom','callback',@obj.add_bottom_Callback,...
                'position',[159,424,80,28],'parent',obj.h_panel);
            obj.h_add_all_btn=uicontrol('style','pushbutton',...
                'string','Add All','callback',@obj.add_all_Callback,...
                'position',[159,398,80,28],'parent',obj.h_panel);
            obj.h_insert_btn=uicontrol('style','pushbutton',...
                'string','insert','callback',@obj.insert_Callback,...
                'position',[159,372,80,28],'parent',obj.h_panel);
            
            obj.h_sort_asc_btn=uicontrol('style','pushbutton',...
                'string','Sort Asc.','callback',@obj.sort_asc_Callback,...
                'position',[159,320,80,28],'parent',obj.h_panel);
            obj.h_sort_desc_btn=uicontrol('style','pushbutton',...
                'string','Sort Desc.','callback',@obj.sort_desc_Callback,...
                'position',[159,294,80,28],'parent',obj.h_panel);
            obj.h_sort_up_btn=uicontrol('style','pushbutton',...
                'CData',icon.icon_dataset_up,'callback',@obj.sort_up_Callback,...
                'position',[159,268,80,28],'parent',obj.h_panel);
            obj.h_sort_down_btn=uicontrol('style','pushbutton',...
                'CData',icon.icon_dataset_down,'callback',@obj.sort_down_Callback,...
                'position',[159,242,80,28],'parent',obj.h_panel);
            
            
            obj.h_remove_btn=uicontrol('style','pushbutton',...
                'string','Remove','callback',@obj.remove_Callback,...
                'position',[159,200,80,28],'parent',obj.h_panel);
            obj.h_remove_all_btn=uicontrol('style','pushbutton',...
                'string','Remove All','callback',@obj.remove_all_Callback,...
                'position',[159,174,80,28],'parent',obj.h_panel);
            
            
            obj.h_select_odd_btn=uicontrol('style','pushbutton',...
                'string','Select Odd','callback',@obj.select_odd_Callback,...
                'position',[28,133,60,20],'parent',obj.h_panel);
            obj.h_select_even_btn=uicontrol('style','pushbutton',...
                'string','Select Even','callback',@obj.select_even_Callback,...
                'position',[90,133,60,20],'parent',obj.h_panel);
            obj.h_not_equal_txt=uicontrol('style','text','visible','off',...
                'position',[160,131,400,20],'foregroundcolor',[1,0,0],...
                'string','The datasets share different epoch/channel/index property.',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            if ispc
                set(obj.h_add_top_btn,'position',[159,450,80,28]);
                set(obj.h_add_bottom_btn,'position',[159,422,80,28]);
                set(obj.h_add_all_btn,'position',[159,394,80,28]);
                set(obj.h_insert_btn,'position',[159,366,80,28]);
                
                set(obj.h_sort_asc_btn,'position',[159,320,80,28]);
                set(obj.h_sort_desc_btn,'position',[159,292,80,28]);
                set(obj.h_sort_up_btn,'position',[159,264,80,28]);
                set(obj.h_sort_down_btn,'position',[159,236,80,28]);
                
                set(obj.h_remove_btn,'position',[159,200,80,28]);
                set(obj.h_remove_all_btn,'position',[159,172,80,28]);
                set(obj.h_select_odd_btn,'string','Odd');
                set(obj.h_select_even_btn,'string','Even');
            end
        
            set(obj.h_selection_items_pop,'backgroundcolor',[1,1,1]);
            set(obj.h_old_list,'backgroundcolor',[1,1,1]);
            set(obj.h_new_list,'backgroundcolor',[1,1,1]);
        end
        
        function old_list_Callback(obj,varargin)
            if strcmp(get(gcf,'SelectionType'),'open')
                obj.insert_Callback(obj,varargin);
            end
        end
        
        function item_Changed(obj,varargin)
            st_value=get(obj.h_selection_items_pop,'value');
            str=get(obj.h_suffix_edit,'string');
            if sum(strcmp(str,{'sel_epoch','sel_chan','sel_idx'}))
                switch(st_value)
                    case 1
                        if ~strcmp(str,'sel_epoch')
                            set(obj.h_suffix_edit,'string','sel_epoch');
                            set(obj.h_old_list,'value',[],'string',obj.labels_epoch);
                            set(obj.h_new_list,'value',[],'string',[]);
                            if obj.isequal_epoch==0
                                set(obj.h_not_equal_txt,'visible','off');
                            else
                                set(obj.h_not_equal_txt,'visible','on');
                            end
                            if isempty(obj.labels_epoch)
                                error('***The epoch size is zero in some datasets.***')
                            end
                        end
                    case 2
                        if ~strcmp(str,'sel_chan')
                            set(obj.h_suffix_edit,'string','sel_chan');
                            set(obj.h_new_list,'value',[],'string',[]);
                            set(obj.h_old_list,'value',[],'string',obj.labels_chan);
                            if obj.isequal_chan==0
                                set(obj.h_not_equal_txt,'visible','off');
                            else
                                set(obj.h_not_equal_txt,'visible','on');
                            end
                            if isempty(obj.labels_chan)
                                error('***No common channels.***')
                            end
                        end
                    case 3
                        if ~strcmp(str,'sel_idx')
                            set(obj.h_suffix_edit,'string','sel_idx');
                            set(obj.h_new_list,'value',[],'string',[]);
                            set(obj.h_old_list,'value',[],'string',obj.labels_idx);
                            if obj.isequal_idx==0
                                set(obj.h_not_equal_txt,'visible','off');
                            else
                                set(obj.h_not_equal_txt,'visible','on');
                            end
                            if isempty(obj.labels_idx)
                                error('***The index size is zero in some datasets.***')
                            end
                        end
                end
            end
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            selected=get(obj.h_selection_items_pop,'Value');
            st=get(obj.h_selection_items_pop,'String');
            option.type=st{selected};
            st=get(obj.h_new_list,'String');
            option.items=st;
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            switch option.type
                case 'epoch'
                    set(obj.h_selection_items_pop,'value',1);
                case 'channel'
                    set(obj.h_selection_items_pop,'value',2);
                case 'index'
                    set(obj.h_selection_items_pop,'value',3);
            end
            set(obj.h_new_list,'String',option.items);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''type'',''',option.type,''','];
            
            frag_code=[frag_code,'''items'',{{'];
            for k=1:length(option.items)
                frag_code=[frag_code,'''',strrep(option.items{k},'''',''''''),''''];
                if k~=length(option.items)
                    frag_code=[frag_code,','];
                end
            end
            frag_code=[frag_code,'}},'];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function GUI_update(obj,batch_pre)
            old_list=get(obj.h_old_list,'String');
            if isempty(old_list)
                old_idx=[];
            else
                old_idx=old_list(get(obj.h_old_list,'Value'));
            end
            new_list=get(obj.h_new_list,'String');
            if isempty(new_list)
                new_idx=[];
            else
                new_idx=new_list(get(obj.h_new_list,'Value'));
            end
            
            lwdataset=batch_pre.lwdataset;
            
            obj.isequal_chan=0;
            obj.labels_chan={lwdataset(1).header.chanlocs.labels};
            for dataset_pos=2:length(lwdataset)
                labels_chan_temp={lwdataset(dataset_pos).header.chanlocs.labels};
                obj.labels_chan=intersect(obj.labels_chan,...
                    labels_chan_temp,'stable');
                if length(obj.labels_chan)<length(labels_chan_temp)
                    obj.isequal_chan=1;
                end
            end
            if isempty(obj.labels_chan)
                error('***No common channels.***')
            end
            
            obj.isequal_epoch=0;
            epoch_size=lwdataset(1).header.datasize(1);
            for dataset_pos=2:length(lwdataset)
                epoch_size_temp=lwdataset(dataset_pos).header.datasize(1);
                if epoch_size_temp<epoch_size
                    obj.isequal_epoch=1;
                end
                epoch_size=min(epoch_size,epoch_size_temp);
            end
            if epoch_size==0
                error('***The epoch size is zero in some datasets..***')
            end
            obj.labels_epoch=cell(epoch_size,1);
            for k=1:epoch_size
                obj.labels_epoch{k}=num2str(k);
            end
            
            obj.isequal_idx=0;
            idx_size=lwdataset(1).header.datasize(3);
            idx_size_temp=idx_size;
            for dataset_pos=2:length(lwdataset)
                idx_size_temp=min(lwdataset(dataset_pos).header.datasize(3),...
                    idx_size_temp);
            end
            if idx_size_temp<idx_size
                obj.isequal_idx=1;
            end
            if idx_size==0
                error('***The index size is zero in some datasets..***')
            end
            obj.labels_idx=cell(idx_size,1);
            for k=1:idx_size
                obj.labels_idx{k}=num2str(k);
            end
            
            
            set(obj.h_not_equal_txt,'visible','off');
            st_value=get(obj.h_selection_items_pop,'value');
            switch(st_value)
                case 1%epoch
                    if obj.isequal_epoch
                        set(obj.h_not_equal_txt,'visible','on');
                    end
                    set(obj.h_old_list,'String',obj.labels_epoch);
                    [temp,~,temp_idx]= intersect(obj.labels_epoch,new_list,'stable');
                    [~,temp_idx]=sort(temp_idx);
                    temp=temp(temp_idx);
%                     temp= intersect(obj.labels_epoch,new_list,'stable');
                    set(obj.h_new_list,'String',temp);
                    [~,~,idx] = intersect(old_idx,obj.labels_epoch,'stable');
                    set(obj.h_old_list,'value',idx);
                    [~,~,idx] = intersect(new_idx,temp,'stable');
                    set(obj.h_new_list,'value',idx);
                case 2%channel
                    if obj.isequal_chan
                        set(obj.h_not_equal_txt,'visible','on');
                    end
                    set(obj.h_old_list,'String',obj.labels_chan);
                    [temp,~,temp_idx]= intersect(obj.labels_chan,new_list,'stable');
                    [~,temp_idx]=sort(temp_idx);
                    temp=temp(temp_idx);
                    set(obj.h_new_list,'String',temp);
                    [~,~,idx] = intersect(old_idx,obj.labels_chan,'stable');
                    set(obj.h_old_list,'value',idx);
                    [~,~,idx] = intersect(new_idx,temp,'stable');
                    set(obj.h_new_list,'value',idx);
                case 3%index
                    if obj.isequal_idx
                        set(obj.h_not_equal_txt,'visible','on');
                    end
                    set(obj.h_old_list,'String',obj.labels_idx);
                    temp= intersect(obj.labels_idx,new_list,'stable');
                    set(obj.h_new_list,'String',temp);
                    [~,~,idx] = intersect(old_idx,obj.labels_idx,'stable');
                    set(obj.h_old_list,'value',idx);
                    [~,~,idx] = intersect(new_idx,temp,'stable');
                    set(obj.h_new_list,'value',idx);
            end
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
        
        function add_top_Callback(obj,varargin)
            old_list=get(obj.h_old_list,'String');
            if isempty(old_list)
                old_idx=[];
            else
                old_idx=old_list(get(obj.h_old_list,'Value'));
            end
            
            new_list=get(obj.h_new_list,'String');
            if isempty(new_list)
                new_idx=[];
            else
                new_idx=new_list(get(obj.h_new_list,'Value'));
            end
            old_idx = setdiff(old_idx,new_list,'stable');
            set(obj.h_new_list,'String',[old_idx;new_list]);
            set(obj.h_new_list,'value',1:length(old_idx));
        end
        
        function add_bottom_Callback(obj,varargin)
            old_list=get(obj.h_old_list,'String');
            if isempty(old_list)
                old_idx=[];
            else
                old_idx=old_list(get(obj.h_old_list,'Value'));
            end
            
            new_list=get(obj.h_new_list,'String');
            if isempty(new_list)
                new_idx=[];
            else
                new_idx=new_list(get(obj.h_new_list,'Value'));
            end
            old_idx = setdiff(old_idx,new_list,'stable');
            
            if ~isempty(old_idx)
                set(obj.h_new_list,'String',[new_list;old_idx]);
                set(obj.h_new_list,'value',length(new_list)+(1:length(old_idx)));
            end
        end
        
        function add_all_Callback(obj,varargin)
            old_list=get(obj.h_old_list,'String');
            
            if ~isempty(old_list)
                set(obj.h_new_list,'String',old_list);
                set(obj.h_new_list,'value',1:length(old_list));
            end
        end
        
        function insert_Callback(obj,varargin)
            old_list=get(obj.h_old_list,'String');
            if isempty(old_list)
                old_idx=[];
            else
                old_idx=old_list(get(obj.h_old_list,'Value'));
            end
            
            new_list=get(obj.h_new_list,'String');
            if isempty(new_list)
                new_idx=0;
            else
                new_idx=get(obj.h_new_list,'Value');
            end
            old_idx = setdiff(old_idx,new_list,'stable');
            if ~isempty(old_idx)
                set(obj.h_new_list,'String',...
                    [new_list(1:new_idx(1));old_idx;new_list(new_idx(1)+1:end)]);
                set(obj.h_new_list,'value',new_idx(1)+(1:length(old_idx)));
            end
        end
        
        function sort_asc_Callback(obj,varargin)
            new_list=get(obj.h_new_list,'String');
            if isempty(new_list)
            else
                new_idx=get(obj.h_new_list,'Value');
                [new_list,b]=sort(new_list);
                [~,bi]=sort(b);
                set(obj.h_new_list,'String',new_list);
                set(obj.h_new_list,'value',bi(new_idx));
            end
        end
        
        function sort_desc_Callback(obj,varargin)
            new_list=get(obj.h_new_list,'String');
            if isempty(new_list)
            else
                new_idx=get(obj.h_new_list,'Value');
                [new_list,b]=sort(new_list);
                [~,bi]=sort(b,'descend');
                set(obj.h_new_list,'String',new_list(end:-1:1));
                set(obj.h_new_list,'value',bi(new_idx));
            end
        end
        
        function sort_up_Callback(obj,varargin)
            new_list=get(obj.h_new_list,'String');
            new_idx=get(obj.h_new_list,'Value');
            if isempty(new_list)|| new_idx(1)==1
            else
                index_unselected=setdiff(1:length(new_list),new_idx);
                index_order=zeros(1,length(new_list));
                index_order(new_idx-1)=new_idx;
                for k=1:length(index_order)
                    if index_order(k)==0
                        index_order(k)=index_unselected(1);
                        index_unselected=index_unselected(2:end);
                    end
                end
                
                set(obj.h_new_list,'String',new_list(index_order));
                set(obj.h_new_list,'value',new_idx-1);
            end
        end
        
        function sort_down_Callback(obj,varargin)
            new_list=get(obj.h_new_list,'String');
            new_idx=get(obj.h_new_list,'Value');
            if isempty(new_list) || new_idx(end)==length(new_list)
                return;
            else
                index_unselected=setdiff(1:length(new_list),new_idx);
                index_order=zeros(1,length(new_list));
                index_order(new_idx+1)=new_idx;
                for k=1:length(index_order)
                    if index_order(k)==0
                        index_order(k)=index_unselected(1);
                        index_unselected=index_unselected(2:end);
                    end
                end
                set(obj.h_new_list,'String',new_list(index_order));
                set(obj.h_new_list,'value',new_idx+1);
            end
        end
        
        function remove_Callback(obj,varargin)
            new_list=get(obj.h_new_list,'String');
            new_idx=get(obj.h_new_list,'Value');
            if ~isempty(new_list) && ~isempty(new_idx)
                index_order=setdiff(1:length(new_list),new_idx);
                if new_idx(1)<=length(index_order)
                    set(obj.h_new_list,'value',new_idx(1));
                else
                    set(obj.h_new_list,'value',max(1,length(index_order)));
                end
                set(obj.h_new_list,'String',new_list(index_order));
            end
            
        end
        
        function remove_all_Callback(obj,varargin)
            set(obj.h_new_list,'String',[]);
            set(obj.h_new_list,'value',1);
        end
        
        function select_odd_Callback(obj,varargin)
            old_list=get(obj.h_old_list,'String');
            if ~isempty(old_list)
                set(obj.h_old_list,'Value',1:2:length(old_list));
            end
        end
        
        function select_even_Callback(obj,varargin)
            old_list=get(obj.h_old_list,'String');
            if ~isempty(old_list)&& length(old_list)>1
                set(obj.h_old_list,'Value',2:2:length(old_list));
            end
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            
            switch option.type
                case 'epoch'
                    epoch_size=header_in.datasize(1);
                    epoch_idx=[];
                    event_epoch_list=[header_in.events.epoch];
                    events=[];
                    for k=1:length(option.items)
                        temp_idx=str2num(option.items{k});
                        if(temp_idx<=epoch_size)
                            epoch_idx=[epoch_idx,k];
                            events_temp=header_in.events(find(event_epoch_list==temp_idx));
                            [events_temp(:).epoch]=deal(k);
                            events=cat(2,events,events_temp);
                        end
                    end
                    if isempty(epoch_idx)
                        error('No corresponding epoch is found');
                    end
                    header_out.events=events;

                    option.items=option.items(epoch_idx);
                    header_out.datasize(1)=length(epoch_idx);
                case 'channel'
                    channel_labels={header_in.chanlocs.labels};
                    items = intersect(option.items,channel_labels,'stable');
                    if isempty(items)
                        error('No corresponding channel is found');
                    end
                    option.items=items;
                    [~,channel_idx,temp_idx]=intersect(channel_labels,option.items,'stable');
                    [~,temp_idx]=sort(temp_idx);
                    channel_idx=channel_idx(temp_idx);
                    header_out.datasize(2)=length(channel_idx);
                    header_out.chanlocs=header_out.chanlocs(channel_idx);
                case 'index'
                    index_size=header_in.datasize(3);
                    index_idx=[];
                    for k=1:length(option.items)
                        if(str2num(option.items{k})<=index_size)
                            index_idx=[index_idx,k];
                        end
                    end
                    if isempty(index_idx)
                        error('No corresponding index is found');
                    end
                    option.items=option.items(index_idx);
                    header_out.datasize(3)=length(index_idx);
                    if isfield(header_out,'index_labels')
                        header_out.index_labels=header_out.index_labels(index_idx);
                    end
            end
            
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.suffix='sel_chan';
            option.is_save=0;
            option.items=[];
            option=CLW_check_input(option,{'type','items','suffix','is_save'},varargin);
            header=FLW_selection.get_header(lwdata_in.header,option);
            
            data=lwdata_in.data;
            switch option.type
                case 'epoch'
                    epoch_idx=[];
                    for k=1:length(option.items)
                        epoch_idx=[epoch_idx,str2num(option.items{k})];
                    end
                    data=data(epoch_idx,:,:,:,:,:);
                    
                case 'channel'
                    channel_labels={lwdata_in.header.chanlocs.labels};
                    [~,channel_idx,temp_idx]=intersect(channel_labels,option.items,'stable');
                    [~,temp_idx]=sort(temp_idx);
                    channel_idx=channel_idx(temp_idx);
                    data=data(:,channel_idx,:,:,:,:);
                case 'index'
                    index_idx=[];
                    for k=1:length(option.items)
                        index_idx=[index_idx,str2num(option.items{k})];
                    end
                    data=data(:,:,index_idx,:,:,:);
            end
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end
