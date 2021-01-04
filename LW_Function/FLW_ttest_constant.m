classdef FLW_ttest_constant<CLW_permutation
    properties
        FLW_TYPE=1;
        h_constant_edit;
        h_tail_pop;
    end
    
    methods
        function obj = FLW_ttest_constant(batch_handle)
            obj@CLW_permutation(batch_handle,'ttest','ttest',...
                'point by point one-sample t-test with cluster based permutation test.');
            
            uicontrol('style','text','position',[35,490,200,20],...
                'string','Type of alternative hypothsis:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_tail_pop=uicontrol('style','popupmenu','value',1,...
                'String',{'two-tailed test','left-tailed test','right-tailed test'},...
                'backgroundcolor',1*[1,1,1],...
                'position',[35,465,200,30],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[35,435,200,20],...
                'string','Compare to constant','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_constant_edit=uicontrol('style','edit','String','0',...
                'backgroundcolor',1*[1,1,1],...
                'position',[35,415,200,25],'parent',obj.h_panel);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_permutation(obj);
            option.constant=str2num(get(obj.h_constant_edit,'string'));
            switch get(obj.h_tail_pop,'value')
                case 1
                    option.tails='both';
                case 2
                    option.tails='left';
                case 3
                    option.tails='right';
            end
        end
        
        function set_option(obj,option)
            set_option@CLW_permutation(obj,option);
            set(obj.h_constant_edit,'string',num2str(option.constant));
            switch(option.tails)
                case 'both'
                    set(obj.h_tail_pop,'value',1)
                case 'left'
                    set(obj.h_tail_pop,'value',2)
                case 'right'
                    set(obj.h_tail_pop,'value',3)
            end
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''constant'',',...
                num2str(option.constant),','];
            frag_code=[frag_code,'''tails'',''',...
                option.tails,''','];
            frag_code=[frag_code,get_Script@CLW_permutation(obj)];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
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
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.constant=0;
            option.tails='both';
            option.alpha=0.05;
            option.permutation=0;
            option.num_permutations=2000;
            option.cluster_threshold=0.05;
            option.show_progress=1;
            option.multiple_sensor=0;
            option.chan_dist=0;
            
            option.suffix='ttest';
            option.is_save=0;
            option=CLW_check_input(option,{'constant','tails','alpha',...
                'permutation','num_permutations','cluster_statistic',...
                'cluster_threshold','show_progress',...
                'multiple_sensor','chan_dist','suffix','is_save'},...
                varargin);
            if option.permutation==0
                option.show_progress=0;
            end
            header=FLW_ttest_constant.get_header(lwdata_in.header,option);
            
            
            if option.multiple_sensor
                chan_used=find([header.chanlocs.topo_enabled]==1, 1);
                if isempty(chan_used)
                    temp=CLW_elec_autoload(header); 
                    chan_used=find([temp.chanlocs.topo_enabled]==1);
                    [y,x]= pol2cart(pi/180.*[temp.chanlocs.theta],[temp.chanlocs.radius]);
                else
                    [y,x]= pol2cart(pi/180.*[header.chanlocs.theta],[header.chanlocs.radius]);
                end
                dist=zeros(length(header.chanlocs),length(header.chanlocs));
                dist(chan_used,chan_used)=squareform(pdist([x;y]'))<option.chan_dist;
            end
            
            if option.permutation && option.num_permutations>=2^(size(lwdata_in.data,1)-1)
                option.num_permutations=2^(size(lwdata_in.data,1)-1);
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
                        data_tmp=lwdata_in.data(:,ch_idx,1,z_idx,:,:)-option.constant;
                        [~,P,~,STATS]=ttest(data_tmp,0,option.alpha,option.tails);
                        data(:,ch_idx,1,z_idx,:,:)=P;
                        data(:,ch_idx,2,z_idx,:,:)=STATS.tstat;
                        
                        if option.permutation==1
                            if sum(P(:)<=option.alpha)==0
                                data(:,ch_idx,3,z_idx,:,:)=1;
                                data(:,ch_idx,4,z_idx,:,:)=0;
                                continue;
                            end
                            if strcmp(option.tails,'both')
                                t_threshold = abs(tinv(option.alpha/2,size(data_tmp,1)-1));
                            else
                                t_threshold = abs(tinv(option.alpha,size(data_tmp,1)-1));
                            end
                            
                            cluster_distribute=zeros(1,option.num_permutations);
                            for iter=1:option.num_permutations
                                if option.num_permutations==2^(size(data_tmp,1)-1)
                                    A=dec2bin(iter-1)-'0';   A=[zeros(1,size(data_tmp,1)-length(A)),A];
                                else
                                    A=sign(randn(size(data_tmp,1),1));
                                end
                                rnd_data=data_tmp;
                                rnd_data(A==1,:)=-rnd_data(A==1,:);
                                tstat=mean(rnd_data)./(std(rnd_data)./sqrt(size(rnd_data,1)));
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
                                
                                if option.show_progress
                                    t=toc;
                                    if ishandle(fig) && t-t1>0.2
                                        t1=t;
                                        N=(iter+(ch_idx-1+(z_idx-1)*header.datasize(2))*option.num_permutations);
                                        N=N/option.num_permutations/header.datasize(2)/header.datasize(4);
                                        set(run_slider,'Position',[0 0 N 1]);
                                        set(h_text,'string',[num2str(N*100,'%0.0f'),'% ( ',num2str(t/N*(1-N),'%0.0f'),' second left)']);
                                        drawnow;
                                    end
                                end
                            end
                            
%                             hold on;
%                             temp=sort(cluster_distribute(1,:),'descend');
%                             temp_idx=ceil(length(temp)*option.cluster_threshold);
%                             plot(temp);
%                             plot(temp_idx,temp(temp_idx),'*');
%                             disp(temp(temp_idx))

                            tstat=permute(STATS.tstat,[6,5,1,2,3,4]);
                            data_tmp=ones(size(tstat));
                            switch option.tails
                                case 'both'
                                    data_tmp=data_tmp.*...
                                        CLW_detect_cluster(tstat.*(tstat>=t_threshold),...
                                        option,cluster_distribute);
                                    data_tmp=data_tmp.*...
                                        CLW_detect_cluster(-tstat.*(tstat<=-t_threshold),...
                                        option,cluster_distribute);
                                case 'left'
                                    data_tmp=data_tmp.*...
                                        CLW_detect_cluster(-tstat.*(tstat<=-t_threshold),...
                                        option,cluster_distribute);
                                case 'right'
                                    data_tmp=data_tmp.*...
                                        CLW_detect_cluster(tstat.*(tstat>=t_threshold),...
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
                        data_tmp=lwdata_in.data(:,ch_idx,1,z_idx,:,:)-option.constant;
                        [~,P,~,STATS]=ttest(data_tmp,0,option.alpha,option.tails);
                        data(:,ch_idx,1,z_idx,:,:)=P;
                        data(:,ch_idx,2,z_idx,:,:)=STATS.tstat;
                    end
                    
                    if sum(reshape(data(:,:,1,z_idx,:,:),[],1)<=option.alpha)==0
                        data(:,:,3,z_idx,:,:)=1;
                        data(:,:,4,z_idx,:,:)=0;
                        continue;
                    end
                    if strcmp(option.tails,'both')
                        t_threshold = abs(tinv(option.alpha/2,size(data_tmp,1)-1));
                    else
                        t_threshold = abs(tinv(option.alpha,size(data_tmp,1)-1));
                    end
                    
                    data_tmp=lwdata_in.data(:,:,1,z_idx,:,:)-option.constant;
                    cluster_distribute=zeros(1,option.num_permutations);
                    for iter=1:option.num_permutations
                        
                        if option.num_permutations==2^(size(data_tmp,1)-1)
                            A=dec2bin(iter-1)-'0';   A=[zeros(1,size(data_tmp,1)-length(A)),A];
                        else
                            A=sign(randn(size(data_tmp,1),1));
                        end
                        rnd_data=data_tmp;
                        rnd_data(A==1,:)=-rnd_data(A==1,:);
                        tstat=mean(rnd_data)./(std(rnd_data)./sqrt(size(rnd_data,1)));
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
                        cluster_distribute(1,iter)=max_tstat;
                        
%                         if (iter==17&&option.alpha<0.4)||(iter==2&&option.alpha>0.4)
%                             %figure();
%                             temp=permute(data(:,:,2,z_idx,:,:),[6,5,1,2,3,4]);
%                             max_value=0;
%                             RLL=reshape(CLW_bwlabel(temp.*(temp>=2.236),dist),[],1);
%                             for k=1:max(RLL)
%                                 if max_value<sum(temp(RLL==k))
%                                     max_value=sum(temp(RLL==k));
%                                     max_index=k;
%                                 end
%                             end
%                             ff=find(RLL==max_index);
%                             temp1=CLW_bwlabel(tstat.*(tstat>=t_threshold),dist)';
%                             temp=zeros(size(temp));temp(ff)=1;
%                             imagesc(squeeze(temp)'.*squeeze(temp1));
%                             
%                             colormap(lines);
%                             x=colormap;x(1,:)=[1,1,1];colormap(x);
%                         end
                        if option.show_progress 
                            t=toc;
                            if ishandle(fig) && t-t1>0.2
                                t1=t;
                                N=(iter+(z_idx-1)*option.num_permutations);
                                N=N/option.num_permutations/header.datasize(4);
                                set(run_slider,'Position',[0 0 N 1]);
                                set(h_text,'string',[num2str(N*100,'%0.0f'),'% ( ',num2str(t/N*(1-N),'%0.0f'),' second left)']);
                                drawnow;
                            end
                        end
                    end
                    
                    
%                     temp=sort(cluster_distribute(1,:),'descend');
%                     temp_idx=ceil(length(temp)*option.cluster_threshold);
%                     [~,b]=find(cluster_distribute(1,:)==temp(temp_idx));
% %                     disp(b);
% %                     disp(temp(temp_idx));
%                     
%                     figure();
%                     hold on;
%                     stairs((1:length(temp))*100/length(temp),temp);
%                     plot(temp_idx/length(temp)*100,temp(temp_idx),'*');
%                     xlim([1,length(temp)]*100/length(temp))
%                     drawnow
                   
                    
                    tstat=permute(data(:,:,2,z_idx,:,:),[6,5,1,2,3,4]);
                    data_tmp=ones(size(tstat));
                    switch option.tails
                        case 'both'
                            data_tmp=data_tmp.*...
                                CLW_detect_cluster(tstat.*(tstat>t_threshold),...
                                option,cluster_distribute,dist);
                            data_tmp=data_tmp.*...
                                CLW_detect_cluster(-tstat.*(tstat<-t_threshold),...
                                option,cluster_distribute,dist);
                        case 'left'
                            data_tmp=data_tmp.*...
                                CLW_detect_cluster(-tstat.*(tstat<-t_threshold),...
                                option,cluster_distribute,dist);
                        case 'right'
                            data_tmp=data_tmp.*...
                                CLW_detect_cluster(tstat.*(tstat>t_threshold),...
                                option,cluster_distribute,dist);
                    end
                    
                    data_tmp=ipermute(data_tmp,[6,5,1,2,3,4]);
                    data(:,:,3,z_idx,:,:)=data_tmp;
                    data(:,:,4,z_idx,:,:)=(data_tmp<1).*data(:,:,2,z_idx,:,:);
                end
            end
            if option.show_progress==1 && ishandle(fig)
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