classdef FLW_ANOVA_permutation<CLW_permutation
    properties
        FLW_TYPE=2;
        
        h_factor_name;
        h_bg;
        h_r1;
        h_r2;
        h_group;
        h_show_progress;
    end
    
    methods
        function obj = FLW_ANOVA_permutation(batch_handle)
            obj@CLW_permutation(batch_handle,'ANOVA','anova_factor',...
                'Compute a point-by-point ANOVA using multiple datasets.');
            
            uicontrol('style','text','position',[35,436,80,20],...
                'string','Factor name:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_factor_name=uicontrol('style','edit','string','factor1',...
                'HorizontalAlignment','left','backgroundcolor',1*[1,1,1],...
                'position',[35,413,200,25],'parent',obj.h_panel);
            
            obj.h_bg = uibuttongroup('units','pixels','BorderType','none',...
                'Position',[34,280,130,62],'parent',obj.h_panel);
            obj.h_r1 = uicontrol(obj.h_bg,'Style','radiobutton',...
                'String','within subject','Position',[1 31 120 30]);
            obj.h_r2 = uicontrol(obj.h_bg,'Style','radiobutton',...
                'String','between subject','Position',[1 1 120 30]);
            
            set(obj.h_factor_name,'callback',@obj.factorname_changed);
            
        end
        
        function factorname_changed(obj,varargin)
            set(obj.h_suffix_edit,'string',['anova_',get(obj.h_factor_name,'string')]);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_permutation(obj);
            if get(obj.h_r1,'value')==1
                option.factor_name=['W:',get(obj.h_factor_name,'string')];
            else
                option.factor_name=['B:',get(obj.h_factor_name,'string')];
            end
        end
        
        function set_option(obj,option)
            set_option@CLW_permutation(obj,option);
            lwdataset=batch_pre.lwdataset;
            set(obj.h_factor_name,'string',option.factor_name(3:end));
            if obj.h_factor_name(1)=='W'
                set(obj.h_r1,'value',1);
            else
                set(obj.h_r2,'value',1);
            end
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''factor_name'','];
            frag_code=[frag_code,'''',option.factor_name,''''];
            frag_code=[frag_code,','];
            frag_code=[frag_code,get_Script@CLW_permutation(obj)];
            str=get_Script@CLW_generic(obj,frag_code,option);
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
                if (lwdataset_in(1).header.datasize([2,4:6])-datasize([2,4:6]))~=0
                    error(['***dataset No. ',num2str(k),...
                        ' did not have the same size with the first dataset.***']);
                end
            end
            if option.factor_name(1)=='W'
                for k=2:length(lwdataset_in)
                    if (lwdataset_in(k).header.datasize(1)-datasize(1))~=0
                        error(['***For within subject design, dataset No. ',num2str(k),...
                            ' did not have the same subject number with the first dataset.***']);
                    end
                end
            end
            
            header_out=lwdataset_in(1).header;
            N=length(option.factor_name);
            header_out.datasize(1)=1;
            header_out.index_labels{1}=['p: ',option.factor_name(3:end)];
            header_out.index_labels{2}=['F: ',option.factor_name(3:end)];
            if option.permutation==1
                header_out.datasize(3)=4;
                header_out.index_labels{3}=['cluster p: ',option.factor_name(3:end)];
                header_out.index_labels{4}=['cluster F: ',option.factor_name(3:end)];
            else
                header_out.datasize(3)=2;
            end
            
            
            header_out.events=[];
            
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        
        function lwdata_out=get_lwdata(lwdataset_in,varargin)
            option.factor_name='W:factor';
            option.alpha=0.05;
            option.permutation=0;
            option.num_permutations=2000;
            option.cluster_threshold=0.05;
            option.show_progress=1;
            option.cluster_union=0;
            option.multiple_sensor=0;
            option.chan_dist=0;
            
            option.suffix='anova_factor';
            option.is_save=0;
            
            option=CLW_check_input(option,{'factor_name','alpha',...
                'permutation','num_permutations','cluster_statistic',...
                'cluster_threshold','show_progress','cluster_union',...
                'multiple_sensor','chan_dist','suffix','is_save'},...
                varargin);
            header=FLW_ANOVA_permutation.get_header(lwdataset_in,option);
            
            chan_used=find([header.chanlocs.topo_enabled]==1, 1);
            if isempty(chan_used)
                temp=CLW_elec_autoload(header);
                [y,x]= pol2cart(pi/180.*[temp.chanlocs.theta],[temp.chanlocs.radius]);
            else
                temp=header;
                [y,x]= pol2cart(pi/180.*[header.chanlocs.theta],[header.chanlocs.radius]);
            end
            dist_temp=squareform(pdist([x;y]'))<option.chan_dist;
            idx=find([temp.chanlocs.topo_enabled]==1);
            dist= false(header.datasize(2),header.datasize(2));
            if isempty(dist_temp)
                dist(idx,idx)=0;
            else
                dist(idx,idx)=dist_temp;
            end
            %% now
            wtfactornames={};
            btfactornames={};
            wtfactors=[];
            btfactors=[];
            if option.factor_name(1)=='W'
                wtfactornames={option.factor_name(3:end)};
            else
                btfactornames={option.factor_name(3:end)};
            end
            k=1;
            tpsubjects=[];
            for datapos=1:length(lwdataset_in)
                num_epochs=lwdataset_in(datapos).header.datasize(1);
                for j=1:num_epochs
                    if option.factor_name(1)=='W'
                        tpsubjects(k,1)=j;
                        wtfactors(k,1)=datapos;
                    else
                        tpsubjects(k,1)=k;
                        btfactors(k,1)=datapos;
                    end
                    k=k+1;
                end
            end
            
            if option.show_progress==1
                fig=figure('numbertitle','off','name','ANOVA progress',...
                    'MenuBar','none','DockControls','off');
                pos=get(fig,'position');
                pos(3:4)=[400,100];
                set(fig,'position',pos);
                hold on;
                run_slider=rectangle('Position',[0 0 eps 1],'FaceColor',[255,71,38]/255,'LineStyle','none');
                rectangle('Position',[0 0 1 1]);
                xlim([0,1]);
                ylim([-1,2]);
                axis off;
                h_text=text(1,-0.5,'starting...','HorizontalAlignment','right','Fontsize',12,'FontWeight','bold');
                pause(0.001);
                tic;
                t1=toc;
            end    
                    
            data=zeros(header.datasize([3,2,4,1,5,6]));
            for z_idx=1:header.datasize(4)
                if option.multiple_sensor==0
                    for ch_idx=1:1:header.datasize(2)
                        tpdata=[];
                        for datapos=1:length(lwdataset_in)
                            num_epochs=lwdataset_in(datapos).header.datasize(1);
                            tpdata=[tpdata;reshape(lwdataset_in(datapos).data(:,ch_idx,1,z_idx,:,:),num_epochs,[])];
                        end
                        result=anovaNxM(tpdata,tpsubjects,wtfactors,wtfactornames,btfactors,btfactornames);
                        data(1,ch_idx,z_idx,:)=result.eff.p;
                        data(2,ch_idx,z_idx,:)=result.eff.F;
                        
                        if option.permutation==1
                            if sum(result.eff.p(:)<=option.alpha)==0
                                data(3,ch_idx,z_idx,:)=1;
                                data(4,ch_idx,z_idx,:)=0;
                                continue;
                            end
                            F1=reshape(result.eff.F.*(result.eff.p<option.alpha),lwdataset_in(1).header.datasize(5),[])';
                            cluster_distribute=zeros(1,option.num_permutations);
                            for iter=1:option.num_permutations
                                tp_wtfactors=wtfactors;
                                tp_btfactors=btfactors;
                                if option.factor_name(1)=='W'
                                    num_epochs=lwdataset_in(1).header.datasize(1);
                                    for j=1:num_epochs
                                        idx=find(tpsubjects==j);
                                        tp_wtfactors(idx)=wtfactors(idx(randperm(length(lwdataset_in))));
                                    end
                                else
                                    tp_btfactors=btfactors(randperm(length(btfactors)));
                                end
                                result=anovaNxM(tpdata,tpsubjects,tp_wtfactors,wtfactornames,tp_btfactors,btfactornames);
                                F=reshape(result.eff.F.*(result.eff.p<0.05),lwdataset_in(1).header.datasize(5),[])';
                                cluster_distribute(iter)=CLW_max_cluster(F);
                                t=toc;
                                if option.show_progress && ishandle(fig) && t-t1>0.2
                                    t1=t;
                                    N=(iter+(ch_idx-1+(z_idx-1)*header.datasize(2))*option.num_permutations);
                                    N=N/option.num_permutations/header.datasize(2)/header.datasize(4);
                                    set(run_slider,'Position',[0 0 N 1]);
                                    set(h_text,'string',[num2str(N*100,'%0.0f'),'% ( ',num2str(t/N*(1-N),'%0.0f'),' second left)']);
                                    drawnow ;
                                end
                            end
                            data_tmp=CLW_detect_cluster(F1,option,cluster_distribute)';
                            data(3,ch_idx,z_idx,:)=data_tmp(:);
                            data(4,ch_idx,z_idx,:)=(data_tmp(:)<1).*squeeze(data(2,ch_idx,z_idx,:));
                        end
                    end
                else
                    tpdata=[];
                    for datapos=1:length(lwdataset_in);
                        num_epochs=lwdataset_in(datapos).header.datasize(1);
                        tpdata=[tpdata;reshape(lwdataset_in(datapos).data(:,:,1,z_idx,:,:),num_epochs,[])];
                    end
                    p1=zeros(lwdataset_in(1).header.datasize([2,5,6]));
                    F1=zeros(lwdataset_in(1).header.datasize([2,5,6]));
                    for k=1:ceil(size(tpdata,2)/200)
                        if k<ceil(size(tpdata,2)/200)
                            idx=(1:200)+(k-1)*200;
                        else
                            idx=(1+(k-1)*200):size(tpdata,2);
                        end
                        result=anovaNxM(tpdata(:,idx),tpsubjects,wtfactors,wtfactornames,btfactors,btfactornames);
                        p1(idx)=result.eff.p;
                        F1(idx)=result.eff.F;
                    end
                    data(1,:,1,z_idx,:,:)=p1;
                    data(2,:,1,z_idx,:,:)=F1;
                    if sum(p1(:)<=option.alpha)==0
                        data(3,:,1,z_idx,:,:)=1;
                        data(4,:,1,z_idx,:,:)=0;
                        continue;
                    end
                    F1=permute(F1.*(p1<option.alpha),[3,2,4,1]);
                    curve=[];
                    cluster_distribute=zeros(1,option.num_permutations);
                    for iter=1:option.num_permutations
                        tp_wtfactors=wtfactors;
                        tp_btfactors=btfactors;
                        if option.factor_name(1)=='W'
                            num_epochs=lwdataset_in(1).header.datasize(1);
                            for j=1:num_epochs
                                idx=find(tpsubjects==j);
                                tp_wtfactors(idx)=wtfactors(idx(randperm(length(lwdataset_in))));
                            end
                        else
                            tp_btfactors=btfactors(randperm(length(btfactors)));
                        end
                        p=zeros(lwdataset_in(1).header.datasize([2,5,6]));
                        F=zeros(lwdataset_in(1).header.datasize([2,5,6]));
                        for k=1:ceil(size(tpdata,2)/200)
                            if k<ceil(size(tpdata,2)/200)
                                idx=(1:200)+(k-1)*200;
                            else
                                idx=(1+(k-1)*200):size(tpdata,2);
                            end
                            result=anovaNxM(tpdata(:,idx),tpsubjects,tp_wtfactors,wtfactornames,tp_btfactors,btfactornames);
                            p(idx)=result.eff.p;
                            F(idx)=result.eff.F;
                        end
                        F=permute(F.*(p<option.alpha),[3,2,4,1]);
                        cluster_distribute(iter)=CLW_max_cluster(F,dist);
                        
                        t=toc;
                        if option.show_progress && ishandle(fig) && t-t1>0.2
                            t1=t;
                            N=(iter+(z_idx-1)*option.num_permutations);
                            N=N/option.num_permutations/header.datasize(4);
                            set(run_slider,'Position',[0 0 N 1]);
                            set(h_text,'string',[num2str(N*100,'%0.0f'),'% ( ',num2str(t/N*(1-N),'%0.0f'),' second left)']);
                            drawnow;
                        end
                    end
                    data_tmp=CLW_detect_cluster(F1,option,cluster_distribute,dist);
                    data_tmp=permute(data_tmp,[5,4,6,3,2,1]);
                    data(3,:,1,z_idx,:,:)=data_tmp;
                    data(4,:,1,z_idx,:,:)=(data_tmp<1).*data(2,:,1,z_idx,:,:);
                end
            end
            if option.show_progress==1 && ishandle(fig)
                set(run_slider,'Position',[0 0 1 1]);
                set(h_text,'string','finished and saving.');
                drawnow;
            end
            data=ipermute(data,[3,2,4,1,5,6]);
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
            
            if option.show_progress  && ishandle(fig)
                close(fig);
            end
        end
    end
end