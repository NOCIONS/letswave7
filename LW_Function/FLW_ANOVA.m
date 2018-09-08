classdef FLW_ANOVA<CLW_generic
    properties
        FLW_TYPE=2;
        
        h_factor_name;
        h_add_within;
        h_add_between;
        h_clear;
        h_group;
        h_show_progress;
    end
    
    methods
        function obj = FLW_ANOVA(batch_handle)
            obj@CLW_generic(batch_handle,'ANOVA','anova',...
                'Compute a point-by-point ANOVA using multiple datasets.');
            
            uicontrol('style','text','position',[10,495,80,20],...
                'string','Factor name:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_factor_name=uicontrol('style','edit','string','factor1',...
                'HorizontalAlignment','left','backgroundcolor',1*[1,1,1],...
                'position',[10,470,150,28],'parent',obj.h_panel);
            
            
            obj.h_add_within=uicontrol('style','pushbutton','string','Add as within factor',...
                'position',[8,435,130,30],'parent',obj.h_panel);
            
            obj.h_add_between=uicontrol('style','pushbutton','string','Add as between factor',...
                'position',[144,435,130,30],'parent',obj.h_panel);
            
            obj.h_clear=uicontrol('style','pushbutton','string','Clear ALL',...
                'position',[280,435,130,30],'parent',obj.h_panel);
            if ispc
                set(obj.h_add_within,'position',[8,435,140,30]);
                set(obj.h_add_between,'position',[154,435,140,30]);
                set(obj.h_clear,'position',[300,435,112,30]);
            end
            
            uicontrol('style','text','position',[10,400,140,20],...
                'string','Group:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_group=uitable('Data',[],'ColumnName',{},...
                'ColumnWidth',{70},'ColumnEditable',true,...
                'backgroundcolor',1*[1,1,1],...
                'position',[5,140,408,260],'parent',obj.h_panel);
            
            obj.h_show_progress=uicontrol('style','checkbox',...
                'string','show_process','value',1,...
                'position',[310,402,130,20],'parent',obj.h_panel);
            
            set(obj.h_add_within,'callback',@(varargin)obj.add_factor_btn(1));
            set(obj.h_add_between,'callback',@(varargin)obj.add_factor_btn(2));
            set(obj.h_clear,'callback',@obj.add_clear_btn);
        end
        
        function add_factor_btn(obj,varargin)
            str=get(obj.h_factor_name,'str');
            if isempty(str)
                return;
            end
            switch(varargin{1})
                case 1
                    str=['W:',str];
                case 2
                    str=['B:',str];
            end
            factor=get(obj.h_group,'ColumnName');
            item_name=get(obj.h_group,'RowName');
            data=get(obj.h_group,'Data');
            if isempty(data)
                factor={str};
                data=ones(length(item_name),1);
            else
                factor=[factor;{str}];
                data=[data,ones(length(item_name),1)];
            end
            set(obj.h_group,'ColumnName',factor);
            set(obj.h_group,'Data',data);
        end
        
        function add_clear_btn(obj,varargin)
            set(obj.h_group,'Data',[]);
            set(obj.h_group,'ColumnName',{});
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.factor_name=get(obj.h_group,'ColumnName');
            option.factor_label=get(obj.h_group,'Data');
            option.show_progress=get(obj.h_show_progress,'value');
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_show_progress,'value',option.show_progress);
            lwdataset=batch_pre.lwdataset;
            RowName={};
            for k=1:length(lwdataset)
                RowName=[RowName,lwdataset{k}.header.name];
            end
            set(obj.h_group,'ColumnName',option.factor_name);
            set(obj.h_group,'RowName',RowName);
            if ~isempty(option.factor_label)
                data=ones(length(RowName),length(option.factor_name));
                row_num=min(length(RowName),size(option.factor_label,1));
                col_num=min(length(option.factor_name),size(option.factor_label,2));
                data(1:row_num,1:col_num)=option.factor_label(1:row_num,1:col_num);
                set(obj.h_group,'Data',data);
            end
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            if ~isempty(option.factor_label)
                frag_code=[frag_code,'''factor_name'',{{'];
                for k=1:length(option.factor_name)
                    frag_code=[frag_code,'''',option.factor_name{k},''''];
                    if k~=length(option.factor_name)
                        frag_code=[frag_code,','];
                    end
                end
                frag_code=[frag_code,'}},'];
                
                frag_code=[frag_code,'''factor_label'',{['];
                for k1=1:size(option.factor_label,1)
                    for k2=1:size(option.factor_label,2)
                        frag_code=[frag_code,num2str(option.factor_label(k1,k2)),];
                        if k2~=size(option.factor_label,2)
                            frag_code=[frag_code,','];
                        else
                            if k1~=size(option.factor_label,1)
                                frag_code=[frag_code,';'];
                            end
                        end
                    end
                end
                frag_code=[frag_code,']},'];
            else
                frag_code=[frag_code,'''factor_name'',{{''B:factor''}},'];
                item_name=get(obj.h_group,'RowName');
                frag_code=[frag_code,'''factor_label'',{['];
                for k=1:length(item_name)
                    frag_code=[frag_code,num2str(k),];
                    if k~=length(item_name)
                        frag_code=[frag_code,';'];
                    end
                end
                frag_code=[frag_code,']},'];
            end
            
            frag_code=[frag_code,'''show_progress'',',...
                num2str(option.show_progress),','];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
   
        function GUI_update(obj,batch_pre)
            option=obj.get_option();
            lwdataset=batch_pre.lwdataset;
            RowName={};
            for k=1:length(lwdataset)
                RowName=[RowName,lwdataset(k).header.name];
            end
            
%             for k=1:length(RowName)
%                 if length(RowName{k})>25
%                     RowName{k}=RowName{k}(1:25);
%                 end
%             end
            
            str_len=0;
            for k=1:length(RowName)
                if length(RowName{k})>str_len
                    str_len=length(RowName{k});
                end
            end
            if str_len>30
                for k=1:length(RowName)
                    filelist_suffix{k}=textscan(RowName{k},'%s');
                    filelist_suffix{k}=filelist_suffix{k}{1}';
                end
                suffix=sort(unique([filelist_suffix{:}]));
                shared=1:length(suffix);
                for k=1:length(RowName)
                    [~,selected_idx]=intersect(suffix,filelist_suffix{k},'stable');
                    [~,temp]=intersect(shared,selected_idx,'stable');
                    shared=shared(temp);
                end
                for k=1:length(RowName)
                    [~,selected_idx]=intersect(filelist_suffix{k},suffix(shared),'stable');
                    temp=setdiff(1:length(filelist_suffix{k}),selected_idx);
                    RowName{k}=char(filelist_suffix{k}(temp(1)));
                    for l=temp(2:end)
                        RowName{k}=[RowName{k},' ',char(filelist_suffix{k}(l))];
                    end
                    if length(RowName{k})>30
                        RowName{k}=RowName{k}(1:30);
                    end
                end
            end

            set(obj.h_group,'RowName',RowName);
            if  ~isempty(option.factor_label)
                data=ones(length(RowName),length(option.factor_name));
                row_num=min(length(RowName),size(option.factor_label,1));
                col_num=min(length(option.factor_name),size(option.factor_label,2));
                data(1:row_num,1:col_num)=option.factor_label(1:row_num,1:col_num);
                set(obj.h_group,'Data',data);
            end
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
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
                error('***No file for ANOVA.***');
            end
            datasize=lwdataset_in(1).header.datasize;
            for k=2:length(lwdataset_in)
                if (lwdataset_in(k).header.datasize([2,4:6])-datasize([2,4:6]))~=0
                    error(['***dataset No. ',num2str(k),...
                        ' did not have the same size with the first dataset.***']);
                end
            end
            
            header_out=lwdataset_in(1).header;
            N=length(option.factor_name);
            header_out.datasize(1)=1;
            header_out.datasize(3)=(2^N-1)*2;
%           index_labels
            header_out.events=[];
            
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        
        function lwdata_out=get_lwdata(lwdataset_in,varargin)
            option.factor_name={'B:factor'};
            option.factor_label=[1:length(lwdataset_in)]';
            option.show_progress=1;
            
            option.suffix='anova';
            option.is_save=0;
            
            option=CLW_check_input(option,{'factor_name','factor_label',...
                'show_progress','suffix','is_save'},varargin);
            header=FLW_ANOVA.get_header(lwdataset_in,option);
            data=zeros(header.datasize([3,1,2,4,5,6]));

            wtfactornames={};
            btfactornames={};
            wtfactors=[];
            btfactors=[];
            factor_order=ones(size(option.factor_label,2),1);
            for k=1:size(option.factor_label,2)
                if option.factor_name{k}(1)-'W'==0
                    wtfactornames=[wtfactornames,{option.factor_name{k}(3:end)}];
                else
                    btfactornames=[btfactornames,{option.factor_name{k}(3:end)}];
                    factor_order(k)=0;
                end
            end
            k=1;
            tpsubjects=[];
            tpdata=[];
            epochs_max=0;
            for datapos=1:length(lwdataset_in);
                num_epochs=lwdataset_in(datapos).header.datasize(1);
                epochs_max=max(epochs_max,num_epochs);
                tpdata=[tpdata;reshape(lwdataset_in(datapos).data(:,:,1,:,:,:),num_epochs,[])];
                for j=1:num_epochs;
                    tpsubjects(k,1)=j;
                    wtfactors(k,:)=option.factor_label(datapos,factor_order==1);
                    btfactors(k,:)=option.factor_label(datapos,factor_order==0);
                    k=k+1;
                end
            end
            [~,~,ic]=unique(btfactors,'rows','sorted');
            tpsubjects=tpsubjects+(ic-1)*epochs_max;
            
            if option.show_progress==1
                fig=figure('numbertitle','off','name','ANOVA progress',...
                    'MenuBar','none','DockControls','off');
                pos=get(fig,'position');
                pos(3:4)=[400,100];
                set(fig,'position',pos);
                hold on;
                run_slider=rectangle('Position',[0 0 0.001 1],'FaceColor',[255,71,38]/255,'LineStyle','none');
                rectangle('Position',[0 0 1 1]);
                xlim([0,1]);
                ylim([-1,2]);
                axis off;
                h_text=text(1,-0.5,'starting...','HorizontalAlignment','right','Fontsize',12,'FontWeight','bold');
                pause(0.001);
                tic;
                t1=toc;
            end
            for k=1:ceil(size(tpdata,2)/200)
                if k<ceil(size(tpdata,2)/200)
                    idx=(1:200)+(k-1)*200;
                else
                    idx=(1+(k-1)*200):size(tpdata,2);
                end
                result=anovaNxM(tpdata(:,idx),tpsubjects,wtfactors,wtfactornames,btfactors,btfactornames);
                for j=1:length(result.eff)
                    data(j,idx)=result.eff(j).p;
                    data(j+length(result.eff),idx)=result.eff(j).F;
                end
                t=toc;
                if option.show_progress==1 && ishandle(fig) && t-t1>0.2
                    t1=t;
                    N=k/ceil(size(tpdata,2)/200);
                    set(run_slider,'Position',[0 0 N 1]);
                    set(h_text,'string',[num2str(N*100,'%0.0f'),'% ( ',num2str(t/N*(1-N),'%0.0f'),' second left)']);
                    pause(0.001);
                end
            end
            if option.show_progress==1 && ishandle(fig)
                set(run_slider,'Position',[0 0 1 1]);
                set(h_text,'string','finished and saving.');
                pause(0.001);
            end
            for i=1:length(result.eff)
                header.index_labels{i}=['p: ',result.eff(i).Name];
                header.index_labels{i+length(result.eff)}=['F: ',result.eff(i).Name];
            end
            data=ipermute(data,[3,1,2,4,5,6]);
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
            if option.show_progress && ishandle(fig)
                close(fig);
            end
        end
    end
end