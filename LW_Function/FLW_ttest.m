classdef FLW_ttest<CLW_permutation
    properties
        FLW_TYPE=4;
        h_tail_pop;
        h_type_pop;
        h_reference_pop;
    end
    
    methods
        function obj = FLW_ttest(batch_handle)
            obj@CLW_permutation(batch_handle,'ttest','ttest',...
                'point by point paired sample or two-sample t-test with cluster based permutation test.');
            
            uicontrol('style','text','position',[35,490,200,20],...
                'string','Test type','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_type_pop=uicontrol('style','popupmenu','value',1,...
                'String',{'paired sample t-test','two-sample t-test'},...
                'backgroundcolor',1*[1,1,1],...
                'position',[35,465,200,30],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[35,435,200,20],...
                'string','Type of alternative hypothsis:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_tail_pop=uicontrol('style','popupmenu','value',1,...
                'String',{'two-tailed test','left-tailed test','right-tailed test'},...
                'backgroundcolor',1*[1,1,1],...
                'position',[35,415,200,25],'parent',obj.h_panel);
            
            
            uicontrol('style','text','position',[35,380,200,20],...
                'string','Reference Dataset','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_reference_pop=uicontrol('style','popupmenu','value',1,...
                'String',{'Dataset 1'},...
                'backgroundcolor',1*[1,1,1],...
                'position',[35,360,200,25],'parent',obj.h_panel);
            
            set(obj.h_alpha_txt,'position',[35,325,200,20]);
            set(obj.h_alpha_edit,'position',[35,302,200,25]);
            
        end
        
        function option=get_option(obj)
            option=get_option@CLW_permutation(obj);
            switch get(obj.h_type_pop,'value')
                case 1
                    option.test_type='paired sample';
                case 2
                    option.test_type='two-sample';
            end
            switch get(obj.h_tail_pop ,'value')
                case 1
                    option.tails='both';
                case 2
                    option.tails='left';
                case 3
                    option.tails='right';
            end
            option.ref_dataset=get(obj.h_reference_pop ,'value');
        end
        
        function set_option(obj,option)
            set_option@CLW_permutation(obj,option);
            switch(option.test_type)
                case 'paired sample'
                    set(obj.h_type_pop,'value',1)
                case 'two-sample'
                    set(obj.h_type_pop,'value',2)
            end
            switch(option.tails)
                case 'both'
                    set(obj.h_tail_pop,'value',1)
                case 'left'
                    set(obj.h_tail_pop,'value',2)
                case 'right'
                    set(obj.h_tail_pop,'value',3)
            end
            N=length(get(obj.h_reference_pop ,'string'));
            if option.ref_dataset>N || option.ref_dataset<1
                set(obj.h_reference_pop ,'value',1);
            else
                set(obj.h_reference_pop ,'value',option.ref_dataset);
            end
        end
        
        function GUI_update(obj,batch_pre)
            GUI_update@CLW_permutation(obj,batch_pre);
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
            frag_code=[frag_code,'''test_type'',''',...
                option.test_type,''','];
            frag_code=[frag_code,'''tails'',''',...
                option.tails,''','];
            frag_code=[frag_code,'''ref_dataset'',',...
                num2str(option.ref_dataset),','];
            frag_code=[frag_code,get_Script@CLW_permutation(obj)];
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
            for k=setdiff(1:N,option.ref_dataset)
                lwdataset_out(end+1).header=FLW_ttest.get_header(lwdataset_in(k).header,option);
                lwdataset_out(end).data=[];
            end
        end
        
        function header_out= get_header(header_in,option)
            if header_in.datasize(1)==1
                error('There is only one epoch in the dataset!');
            end
            header_out=header_in;
            
            header_out.datasize(1)=1;
            header_out.index_labels{1}='p-value';
            header_out.index_labels{2}='t-value';
            if option.permutation==1
                header_out.datasize(3)=4;
                header_out.index_labels{3}='cluster p-value';
                header_out.index_labels{4}='cluster t-value';
            else
                header_out.datasize(3)=2;
            end
            header_out.events=[];
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            option.ref_dataset=1;
            header_out.history(end+1).option=option;
        end
        
        function lwdataset_out= get_lwdataset(lwdataset_in,varargin)
            option.test_type='paired sample';
            option.tails='both';
            option.ref_dataset=1;
            option.alpha=0.05;
            option.permutation=0;
            option.num_permutations=2000;
            option.cluster_threshold=0.05;
            option.show_progress=1;
            option.cluster_union=0;
            option.multiple_sensor=0;
            option.chan_dist=0;
            
            option.suffix='ttest';
            option.is_save=0;
            option=CLW_check_input(option,{'test_type','tails','ref_dataset','alpha',...
                'permutation','num_permutations','cluster_statistic',...
                'cluster_threshold','show_progress','cluster_union',...
                'multiple_sensor','chan_dist','suffix','is_save'},...
                varargin);
            %lwdataset_out = FLW_ttest.get_headerset(lwdataset_in,option);
            
            N=length(lwdataset_in);
            dataset_idx=setdiff(1:N,option.ref_dataset);
            lwdataset_out=struct('header',[],'data',[]);
            for k=1:N-1
                lwdataset_out(end+1)=FLW_ttest.get_lwdata(lwdataset_in([option.ref_dataset,dataset_idx(k)]),option);
            end
        end
        
        function lwdata_out=get_lwdata(lwdataset_in,varargin)
            option.test_type='paired sample';
            option.tails='both';
            option.alpha=0.05;
            option.permutation=0;
            option.num_permutations=2000;
            option.cluster_threshold=0.05;
            option.show_progress=1;
            option.cluster_union=0;
            option.multiple_sensor=0;
            option.chan_dist=0;
            
            option.suffix='ttest';
            option.is_save=0;
            option=CLW_check_input(option,{'test_type','tails','alpha',...
                'permutation','num_permutations','cluster_statistic',...
                'cluster_threshold','show_progress','cluster_union',...
                'multiple_sensor','chan_dist','suffix','is_save'},...
                varargin);
            if option.permutation==0
                option.show_progress=0;
            end
            option.ref_dataset=1;
            header=FLW_ttest.get_header(lwdataset_in(2).header,option);
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
            if ~isempty(idx)
                if length(idx)==1
                    dist(idx,idx)=0;
                else
                    dist(idx,idx)=dist_temp;
                end
            end
            
            
            data_n=size(lwdataset_in(2).data,1);
            data_m=size(lwdataset_in(1).data,1);
            if strcmp(option.test_type,'paired sample')
                df=data_n-1;
            else
                df=data_n+data_m-2;
            end
            
            if option.show_progress==1
                fig=figure('numbertitle','off','name','ttest progress',...
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
            
            data=zeros(header.datasize);
            for z_idx=1:header.datasize(4)
                if option.multiple_sensor==0
                    for ch_idx=1:1:header.datasize(2)
                        if strcmp(option.test_type,'paired sample')
                            data_tmp=lwdataset_in(2).data(:,ch_idx,1,z_idx,:,:)-...
                                lwdataset_in(1).data(:,ch_idx,1,z_idx,:,:);
                            [~,P,~,STATS]=ttest(data_tmp,0,option.alpha,option.tails);
                        else
                            data_tmp=[lwdataset_in(2).data(:,ch_idx,1,z_idx,:,:);...
                                lwdataset_in(1).data(:,ch_idx,1,z_idx,:,:)];
                            [~,P,~,STATS]=ttest2(data_tmp(1:data_n,:,:,:,:,:),...
                                data_tmp(data_n+1:end,:,:,:,:,:),option.alpha,option.tails);
                        end
                        data(:,ch_idx,1,z_idx,:,:)=P;
                        data(:,ch_idx,2,z_idx,:,:)=STATS.tstat;
                        
                        if option.permutation==1
                            if sum(P(:)<=option.alpha)==0
                                data(:,:,3,z_idx,:,:)=1;
                                data(:,:,4,z_idx,:,:)=0;
                                continue;
                            end
                            
                            if strcmp(option.tails,'both')
                                t_threshold = abs(tinv(option.alpha/2,df));
                            else
                                t_threshold = abs(tinv(option.alpha,df));
                            end
                            
                            cluster_distribute=zeros(1,option.num_permutations);
                            for iter=1:option.num_permutations
                                if strcmp(option.test_type,'paired sample')
                                    if option.num_permutations==2^(size(data_tmp,1)-1)
                                        A=dec2bin(iter-1)-'0';   A=[zeros(1,size(data_tmp,1)-length(A)),A];
                                    else
                                        A=sign(randn(size(data_tmp,1),1));
                                    end
                                    rnd_data=data_tmp;
                                    rnd_data(A==1,:)=-rnd_data(A==1,:);
                                    tstat=mean(rnd_data)./(std(rnd_data)./sqrt(data_n));
                                else
                                    idx = randperm(data_n+data_m);
                                    x=data_tmp(idx(1:data_n),:,:,:,:,:);
                                    y=data_tmp(idx(data_n+1:end),:,:,:,:,:);
                                    tstat=(mean(x)-mean(y))./sqrt(((data_n-1).*nanvar(x)+(data_m-1).*nanvar(y))./df.*(1/data_n+1/data_m));
                                    %tstat=(mean(x)-mean(y))./sqrt(nanvar(x)./data_n+nanvar(y)./data_m);
                                end
                                
                                tstat=permute(tstat,[6,5,1,2,3,4]);
                                max_tstat=0;
                                switch option.tails
                                    case 'both'
                                        max_tstat=max(...
                                            CLW_max_cluster(tstat.*(tstat>=t_threshold)),...
                                            CLW_max_cluster(-tstat.*(tstat<=-t_threshold)));
                                    case 'left'
                                        max_tstat=...
                                            CLW_max_cluster(-tstat.*(tstat<=-t_threshold));
                                    case 'right'
                                        max_tstat=...
                                            CLW_max_cluster(tstat.*(tstat>=t_threshold));
                                end
                                cluster_distribute(iter)=max_tstat;
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
                            
                            tstat=permute(STATS.tstat,[6,5,1,2,3,4]);
                            switch option.tails
                                case 'both'
                                    data_tmp=CLW_detect_cluster(tstat.*(tstat>t_threshold),...
                                        option,cluster_distribute);
                                    data_tmp=data_tmp.*...
                                        CLW_detect_cluster(-tstat.*(tstat<-t_threshold),...
                                        option,cluster_distribute);
                                case 'left'
                                    data_tmp=CLW_detect_cluster(-tstat.*(tstat<-t_threshold),...
                                        option,cluster_distribute);
                                case 'right'
                                    data_tmp=CLW_detect_cluster(tstat.*(tstat>t_threshold),...
                                        option,cluster_distribute);
                            end
                            data_tmp=ipermute(data_tmp,[6,5,1,2,3,4]);
                            data(:,ch_idx,3,z_idx,:,:)=data_tmp;
                            data(:,ch_idx,4,z_idx,:,:)=(data_tmp<1)...
                                .*data(:,ch_idx,2,z_idx,:,:);
                        end
                    end
                else
                    for ch_idx=1:1:header.datasize(2)
                        if strcmp(option.test_type,'paired sample')
                            data_tmp=lwdataset_in(2).data(:,ch_idx,1,z_idx,:,:)-...
                                lwdataset_in(1).data(:,ch_idx,1,z_idx,:,:);
                            [~,P,~,STATS]=ttest(data_tmp,0,option.alpha,option.tails);
                        else
                            data_tmp=[lwdataset_in(2).data(:,ch_idx,1,z_idx,:,:);...
                                lwdataset_in(1).data(:,ch_idx,1,z_idx,:,:)];
                            [~,P,~,STATS]=ttest2(data_tmp(1:data_n,:,:,:,:,:),...
                                data_tmp(data_n+1:end,:,:,:,:,:),option.alpha,option.tails);
                        end
                        data(:,ch_idx,1,z_idx,:,:)=P;
                        data(:,ch_idx,2,z_idx,:,:)=STATS.tstat;
                    end
                    if sum(reshape(data(:,:,1,z_idx,:,:),[],1)<=option.alpha)==0
                        data(:,:,3,z_idx,:,:)=1;
                        data(:,:,4,z_idx,:,:)=0;
                        continue;
                    end
                    if strcmp(option.tails,'both')
                        t_threshold = abs(tinv(option.alpha/2,df));
                    else
                        t_threshold = abs(tinv(option.alpha,df));
                    end
                    
                    if strcmp(option.test_type,'paired sample')
                        data_tmp=lwdataset_in(2).data(:,:,1,z_idx,:,:)-...
                            lwdataset_in(1).data(:,:,1,z_idx,:,:);
                    else
                        data_tmp=[lwdataset_in(2).data(:,:,1,z_idx,:,:);...
                            lwdataset_in(1).data(:,:,1,z_idx,:,:)];
                    end
                    cluster_distribute=zeros(1,option.num_permutations);
                    for iter=1:option.num_permutations
                        if strcmp(option.test_type,'paired sample')
                            if option.num_permutations==2^(size(data_tmp,1)-1)
                                A=dec2bin(iter-1)-'0';   A=[zeros(1,size(data_tmp,1)-length(A)),A];
                            else
                                A=sign(randn(size(data_tmp,1),1));
                            end
                            rnd_data=data_tmp;
                            rnd_data(A==1,:)=-rnd_data(A==1,:);
                            tstat=mean(rnd_data)./(std(rnd_data)./sqrt(data_n));
                        else
                            idx = randperm(data_n+data_m);
                            x=data_tmp(idx(1:data_n),:,:,:,:,:);
                            y=data_tmp(idx(data_n+1:end),:,:,:,:,:);
                            tstat=(mean(x)-mean(y))./sqrt(((data_n-1).*nanvar(x)+(data_m-1).*nanvar(y))./df.*(1/data_n+1/data_m));
                            %tstat=(mean(x)-mean(y))./sqrt(nanvar(x)./data_n+nanvar(y)./data_m);
                        end
                        tstat=permute(tstat,[6,5,1,2,3,4]);
                        max_tstat=0;
                        switch option.tails
                            case 'both'
                                max_tstat=max(...
                                    CLW_max_cluster(tstat.*(tstat>=t_threshold),dist),...
                                    CLW_max_cluster(-tstat.*(tstat<=-t_threshold),dist));
                            case 'left'
                                max_tstat=...
                                    CLW_max_cluster(-tstat.*(tstat<=-t_threshold),dist);
                            case 'right'
                                max_tstat=...
                                    CLW_max_cluster(tstat.*(tstat>=t_threshold),dist);
                        end
                        cluster_distribute(iter)=max_tstat;
                        
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
                    
                    tstat=permute(data(:,:,2,z_idx,:,:),[6,5,1,2,3,4]);
                    switch option.tails
                        case 'both'
                            data_tmp=CLW_detect_cluster(tstat.*(tstat>t_threshold),...
                                option,cluster_distribute,dist);
                            data_tmp=data_tmp.*...
                                CLW_detect_cluster(-tstat.*(tstat<-t_threshold),...
                                option,cluster_distribute,dist);
                        case 'left'
                            data_tmp=CLW_detect_cluster(-tstat.*(tstat<-t_threshold),...
                                option,cluster_distribute,dist);
                        case 'right'
                            data_tmp=CLW_detect_cluster(tstat.*(tstat>t_threshold),...
                                option,cluster_distribute,dist);
                    end
                    data_tmp=ipermute(data_tmp,[6,5,1,2,3,4]);
                    data(:,:,3,z_idx,:,:)=data_tmp;
                    data(:,:,4,z_idx,:,:)=(data_tmp<1).*data(:,:,2,z_idx,:,:);
                end
            end
            
            if option.show_progress && ishandle(fig)
                set(run_slider,'Position',[0 0 1 1]);
                set(h_text,'string','finished and saving.');
                drawnow;
            end
            
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