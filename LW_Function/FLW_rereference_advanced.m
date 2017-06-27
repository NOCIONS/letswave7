classdef FLW_rereference_advanced<CLW_generic
    properties
        FLW_TYPE=1;
        h_active_list;
        h_ref_list;
        h_new_list;
        h_not_equal_txt;
    end
    
    methods
       function obj = FLW_rereference_advanced(batch_handle)
            obj@CLW_generic(batch_handle,'rereference_advanced','reref_adv',...
                'Just make a rereference_advanced for how to the FLW file.');
            
            uicontrol('style','text','position',[5,490,100,20],...
                'string','Active channel:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_active_list=uicontrol('style','listbox',...
                'position',[5,132,100,358],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[120,490,100,20],...
                'string','Reference channel:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_ref_list=uicontrol('style','listbox',...
                'position',[120,132,100,358],'parent',obj.h_panel);
            
            
            uicontrol('style','text','position',[233,490,100,20],...
                'string','New channel:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_new_list=uicontrol('style','listbox','min',0,'max',2,...
                'position',[233,177,180,313],'parent',obj.h_panel);
            userdata.active_list=[];
            userdata.ref_list=[];
            set(obj.h_new_list,'userdata',userdata);
            
            icon=load('icon.mat');
            uicontrol('style','pushbutton','CData',icon.icon_dataset_add,...
                'position',[233,132,40,40],'callback',@obj.channel_add,...
                'parent',obj.h_panel);
            uicontrol('style','pushbutton','CData',icon.icon_dataset_del,...
                'position',[280,132,40,40],'callback',@obj.channel_del,...
                'parent',obj.h_panel);
            uicontrol('style','pushbutton','CData',icon.icon_dataset_up,...
                'position',[327,132,40,40],'callback',@obj.channel_up,...
                'parent',obj.h_panel);
            uicontrol('style','pushbutton','CData',icon.icon_dataset_down,...
                'position',[374,132,40,40],'callback',@obj.channel_down,...
                'parent',obj.h_panel);
            
            obj.h_not_equal_txt=uicontrol('style','text','visible','off',...
                'position',[0,125,240,20],'foregroundcolor',[1,0,0],...
                'string','The datasets share different channel property.',...
                'HorizontalAlignment','center','parent',obj.h_panel);
            set(obj.h_active_list,'backgroundcolor',[1,1,1]);
            set(obj.h_ref_list,'backgroundcolor',[1,1,1]);
            set(obj.h_new_list,'backgroundcolor',[1,1,1]);
       end
       
       function channel_add(obj,varargin)
           str=get(obj.h_active_list,'String');
           if isempty(str)
               set(obj.h_txt_cmt,'String','no channel selected.',...
                   'ForegroundColor','red');
               return;
           else
               active_str=str(get(obj.h_active_list,'value'));
           end
           str=get(obj.h_ref_list,'String');
           if isempty(str)
               set(obj.h_txt_cmt,'String','no channel selected.',...
                   'ForegroundColor','red');
               return;
           else
               reference_str=str(get(obj.h_ref_list,'value'));
           end        
           
           userdata=get(obj.h_new_list,'userdata');
           active_list=userdata.active_list;
           ref_list=userdata.ref_list;
           idx=get(obj.h_new_list,'Value');
           if isempty(idx)||isempty(active_list)
               active_list{end+1}=char(active_str);
               ref_list{end+1}=char(reference_str);
           else
               idx=idx(end);
               active_list={active_list{1:idx(end)},char(active_str),...
                   active_list{idx(end)+1:end}};
               ref_list={ref_list{1:idx(end)},char(reference_str),...
                   ref_list{idx(end)+1:end}};
           end
           userdata.active_list=active_list;
           userdata.ref_list=ref_list;
           
           str={};
           for k=1:length(active_list)
               if strcmp(ref_list{k},'0')
                   str{k}=active_list{k};
               else
                   str{k}=strcat(active_list{k},'-',ref_list{k});
               end
           end
           set(obj.h_new_list,'string',str);
           set(obj.h_new_list,'userdata',userdata);
       end
       
       function channel_del(obj,varargin)
           userdata=get(obj.h_new_list,'userdata');
           active_list=userdata.active_list;
           ref_list=userdata.ref_list;
           idx=get(obj.h_new_list,'Value');
           if isempty(idx)
               set(obj.h_txt_cmt,'String','no channel selected.',...
                   'ForegroundColor','red');
               return;
           else
               active_list={active_list{setdiff(1:end,idx)}};
               ref_list={ref_list{setdiff(1:end,idx)}};
           end
           userdata.active_list=active_list;
           userdata.ref_list=ref_list;
           if isempty(active_list)
               set(obj.h_new_list,'string',[]);
           else
               str={};
               for k=1:length(active_list)
                   if strcmp(ref_list{k},'0')
                       str{k}=active_list{k};
                   else
                       str{k}=strcat(active_list{k},'-',ref_list{k});
                   end
               end
               set(obj.h_new_list,'string',str);
           end
           set(obj.h_new_list,'userdata',userdata);
           idx=idx(1)-1;
           if(idx==0)
               idx=1;
           end
           set(obj.h_new_list,'value',idx);
       end
       
       function channel_up(obj,varargin)
           userdata=get(obj.h_new_list,'userdata');
           active_list=userdata.active_list;
           ref_list=userdata.ref_list;
           idx=get(obj.h_new_list,'Value');
           if isempty(idx)
               set(obj.h_txt_cmt,'String','no channel selected.',...
                   'ForegroundColor','red');
               return;
           end
           if idx(1)==1
               return;
           end
           idx_unsel=setdiff(1:length(active_list),idx);
           idx_order=zeros(1,length(active_list));
           idx_order(idx-1)=idx;
           for k=1:length(idx_order)
               if idx_order(k)==0
                   idx_order(k)=idx_unsel(1);
                   idx_unsel=idx_unsel(2:end);
               end
           end
           
           active_list={active_list{idx_order}};
           ref_list={ref_list{idx_order}};
           userdata.active_list=active_list;
           userdata.ref_list=ref_list;
           str={};
           for k=1:length(active_list)
               if strcmp(ref_list{k},'0')
                   str{k}=active_list{k};
               else
                   str{k}=strcat(active_list{k},'-',ref_list{k});
               end
           end
           set(obj.h_new_list,'string',str);
           set(obj.h_new_list,'userdata',userdata);
           set(obj.h_new_list,'value',idx-1);
       end
       
       function channel_down(obj,varargin)
           userdata=get(obj.h_new_list,'userdata');
           active_list=userdata.active_list;
           ref_list=userdata.ref_list;
           idx=get(obj.h_new_list,'Value');
           if isempty(idx)
               set(obj.h_txt_cmt,'String','no channel selected.',...
                   'ForegroundColor','red');
               return;
           end
           if idx(end)==length(active_list)
               return;
           end
           idx_unsel=setdiff(1:length(active_list),idx);
           idx_order=zeros(1,length(active_list));
           idx_order(idx+1)=idx;
           for k=1:length(idx_order)
               if idx_order(k)==0
                   idx_order(k)=idx_unsel(1);
                   idx_unsel=idx_unsel(2:end);
               end
           end
           active_list={active_list{idx_order}};
           ref_list={ref_list{idx_order}};
           userdata.active_list=active_list;
           userdata.ref_list=ref_list;
           str={};
           for k=1:length(active_list)
               if strcmp(ref_list{k},'0')
                   str{k}=active_list{k};
               else
                   str{k}=strcat(active_list{k},'-',ref_list{k});
               end
           end
           set(obj.h_new_list,'string',str);
           set(obj.h_new_list,'userdata',userdata);
           set(obj.h_new_list,'value',idx+1);
       end
       
       function option=get_option(obj)
           option=get_option@CLW_generic(obj);
           userdata=get(obj.h_new_list,'userdata');
           option.active_list=userdata.active_list;
           option.ref_list=userdata.ref_list;
       end
       
       function set_option(obj,option)
           set_option@CLW_generic(obj,option);
           
           userdata.active_list=option.active_list;
           userdata.ref_list=option.ref_list;
           if isempty(option.active_list)
               set(obj.h_new_list,'string',[]);
           else
               str={};
               for k=1:length(option.active_list)
                   if strcmp(option.ref_list{k},'0')
                       str{k}=option.active_list{k};
                   else
                       str{k}=strcat(option.active_list{k},'-',option.ref_list{k});
                   end
               end
               set(obj.h_new_list,'string',str);
           end
           set(obj.h_new_list,'userdata',userdata);
           
           
           
       end
       
       function str=get_Script(obj)
           option=get_option(obj);
           frag_code=[];
           frag_code=[frag_code,'''active_list'',{{'];
           for k=1:length(option.active_list)
               frag_code=[frag_code,'''',strrep(option.active_list{k},'''',''''''),''''];
               if k~=length(option.active_list)
                   frag_code=[frag_code,','];
               end
           end
           frag_code=[frag_code,'}},'];
           frag_code=[frag_code,'''ref_list'',{{'];
           for k=1:length(option.ref_list)
               frag_code=[frag_code,'''',strrep(option.ref_list{k},'''',''''''),''''];
               if k~=length(option.ref_list)
                   frag_code=[frag_code,','];
               end
           end
           frag_code=[frag_code,'}},'];
           str=get_Script@CLW_generic(obj,frag_code,option);
       end
       
       function GUI_update(obj,batch_pre)
            option=obj.get_option();
            lwdataset=batch_pre.lwdataset;
            channel_labels={lwdataset(1).header.chanlocs.labels};
            set(obj.h_not_equal_txt,'visible','off');
            for dataset_pos=2:length(lwdataset)
                channel_labels1={lwdataset(dataset_pos).header.chanlocs.labels};
                channel_labels2= intersect(channel_labels,channel_labels1,'stable');
                if length(channel_labels2)<length(channel_labels)||...
                        length(channel_labels2)<length(channel_labels)
                    set(obj.h_not_equal_txt,'visible','on');
                end
                channel_labels=channel_labels2;
            end
            if isempty(channel_labels)
                error('***No common channels.***')
            end
            set(obj.h_ref_list,'String',['0',channel_labels]);
            set(obj.h_active_list,'String',channel_labels);
            
            
            str=channel_labels;
            str_ref=['0',channel_labels];
            
            active_list=[];
            ref_list=[];
            for k=1:length(option.active_list)
                if sum(strcmp(option.active_list{k},str))>0 &&...
                        sum(strcmp(option.ref_list{k},str_ref))>0
                    active_list{end+1}=option.active_list{k};
                    ref_list{end+1}=option.ref_list{k};
                end
            end
            userdata.active_list=active_list;
            userdata.ref_list=ref_list;
            if isempty(active_list)
                set(obj.h_new_list,'string',[]);
            else
                str={};
                for k=1:length(active_list)
                    if strcmp(ref_list{k},'0')
                        str{k}=active_list{k};
                    else
                        str{k}=strcat(active_list{k},'-',ref_list{k});
                    end
                end
                set(obj.h_new_list,'string',str);
            end
            set(obj.h_new_list,'userdata',userdata);
            
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
       end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            channel_labels={header_in.chanlocs.labels};
            channel_labels{end+1}='0';
            active_idx=[];
            ref_idx=[];
            for k=1:length(option.active_list)
                temp=find(strcmp(option.active_list{k},channel_labels));
                if isempty(temp)
                    error(['channel ',option.active_list{k},' not found']);
                end
                if length(temp)>1
                    error(['multiple channel ',option.active_list{k},' is found']);
                end
                active_idx=[active_idx,temp(1)];
                temp=find(strcmp(option.ref_list{k},channel_labels));
                if isempty(temp)
                    error(['channel ',option.ref_list{k},' not found']);
                end
                if length(temp)>1
                    error(['multiple channel ',option.ref_list{k},' is found']);
                end
                
                ref_idx=[ref_idx,temp(1)];
            end
            option.active_idx=active_idx;
            option.ref_idx=ref_idx;
            header_out.datasize(2)=length(active_idx);
            header_out.chanlocs=[];
            for i=1:length(active_idx)
                if strcmp(option.ref_list{i},'0')
                    header_out.chanlocs(i).labels=option.active_list{i};
                else
                    header_out.chanlocs(i).labels=[option.active_list{i} '-' option.ref_list{i}];
                end
                header_out.chanlocs(i).topo_enabled=0;
                header_out.chanlocs(i).SEEG_enabled=0;
                header_out.chanlocs(i).theta=[];
                header_out.chanlocs(i).radius=[];
                header_out.chanlocs(i).sph_theta=[];
                header_out.chanlocs(i).sph_phi=[];
                header_out.chanlocs(i).sph_theta_besa=[];
                header_out.chanlocs(i).sph_phi_besa=[];
                header_out.chanlocs(i).X=[];
                header_out.chanlocs(i).Y=[];
                header_out.chanlocs(i).Z=[];
            end
            
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.suffix='reref_adv';
            option.is_save=0;
            option=CLW_check_input(option,{'active_list','ref_list','suffix','is_save'},varargin);
            header=FLW_rereference_advanced.get_header(lwdata_in.header,option);
            ref_idx=header.history(end).option.ref_idx;
            active_idx=header.history(end).option.active_idx;
            data=lwdata_in.data;
            data(:,end+1,:,:,:,:)=0;
            data=data(:,active_idx,:,:,:,:)-data(:,ref_idx,:,:,:,:);
            try
                rmfield(header.history(end).option,'ref_idx');
            end
            try
                rmfield(header.history(end).option,'apply_idx');
            end
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end