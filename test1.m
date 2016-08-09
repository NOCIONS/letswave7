clc;clear;close all;
load('matlab.mat');
[y,x]= pol2cart(pi/180.*[ch.theta],[ch.radius]);
dist=squareform(pdist([x;y]'))<0.22;
clear x y ch data t;

tic;
option.alpha=0.05;
option.tails='both';
option.permutation=1;
option.num_permutations=200;
option.constant=0;
option.show_progress=1;
option.cluster_threshold=0.05;
option.cluster_union=0;
option.multiple_sensor=1;
option.chan_dist=0.22;

h_line=-1;

lwdata_in.data=randn(20,1,1,1,1,1000);
lwdata_in.data(:,:,1,1,1,1:500)=lwdata_in.data(:,:,1,1,1,1:500)-0.21;
lwdata_in.header.datasize=size(lwdata_in.data);


header.datasize=lwdata_in.header.datasize;
header.datasize(1)=1;
if option.permutation==0
    header.datasize(3)=2;
else
    if option.cluster_union
        header.datasize(3)=3;
    else
        header.datasize(3)=4;
    end
end



data=zeros(header.datasize);
for z_idx=1:header.datasize(4)
    if option.multiple_sensor==0
        for ch_idx=1:1:header.datasize(2)
            data_tmp=lwdata_in.data(:,ch_idx,1,z_idx,:,:)-option.constant;
            [~,P,~,STATS]=ttest(data_tmp,0,option.alpha,option.tails);
            data(:,ch_idx,1,z_idx,:,:)=P;
            data(:,ch_idx,2,z_idx,:,:)=STATS.tstat;
            
            curve=[];
            if option.permutation==1
                if option.cluster_union
                    t_threshold=STATS.tstat(P>option.alpha/...
                        (header.datasize(5)*header.datasize(6))...
                        & P<option.alpha);
                    t_threshold=sort(abs(reshape(t_threshold,[],1)));
                else
                    switch option.tails
                        case 'both'
                            t_threshold = abs(tinv(option.alpha/2,size(data_tmp,1)-1));
                        case 'left'
                            t_threshold = abs(tinv(option.alpha,size(data_tmp,1)-1));
                        case 'right'
                            t_threshold = abs(tinv(option.alpha,size(data_tmp,1)-1));
                    end
                end
                
                cluster_distribute=zeros(length(t_threshold),option.num_permutations);
                for iter=1:option.num_permutations
                    rnd_data=randn(size(data_tmp));
                    rnd_data=data_tmp.*rnd_data./abs(rnd_data);
                    
                    tstat=mean(rnd_data)./(std(rnd_data)./sqrt(size(rnd_data,1)));
                    tstat=permute(tstat,[6,5,1,2,3,4]);
                    max_tstat=zeros(length(t_threshold),1);
                    for t_threshold_idx=1:length(t_threshold)
                        switch option.tails
                            case 'both'
                                max_tstat(t_threshold_idx)=max(...
                                    CLW_max_cluster(tstat.*(tstat>t_threshold(t_threshold_idx))),...
                                    CLW_max_cluster(-tstat.*(tstat<-t_threshold(t_threshold_idx))));
                            case 'left'
                                max_tstat(t_threshold_idx)=...
                                    CLW_max_cluster(-tstat.*(tstat<-t_threshold(t_threshold_idx)));
                            case 'right'
                                max_tstat(t_threshold_idx)=...
                                    CLW_max_cluster(tstat.*(tstat>t_threshold(t_threshold_idx)));
                        end
                    end
                    cluster_distribute(:,iter)=max_tstat;
                    
                    
                    if option.show_progress
                        criticals=prctile(cluster_distribute(1,1:iter),(1-option.cluster_threshold)*100);
                        curve=[curve,reshape(criticals,[],1)];
                        if ~ishandle(h_line)
                            figure();
                            h_line=plot(1:iter,curve);
                            xlim([1,option.num_permutations]);
                        else
                            set(h_line,'XData',1:iter,'YData',curve);
                            str=['channel: ',num2str(ch_idx),'/',num2str(header.datasize(2))];
                            if header.datasize(4)>1
                                str=[str,' z:',num2str(z_idx),'/',num2str(header.datasize(4))];
                            end
                            title(str)
                        end
                        drawnow;
                    end
                end
                
                tstat=permute(STATS.tstat,[6,5,1,2,3,4]);
                
                data_tmp=ones(size(tstat));
                for t_threshold_idx=1:length(t_threshold)
                    threshold_tmp=t_threshold(t_threshold_idx);
                    switch option.tails
                        case 'both'
                            data_tmp=data_tmp.*...
                                CLW_detect_cluster(tstat.*(tstat>threshold_tmp),...
                                option,cluster_distribute(t_threshold_idx,:));
                            data_tmp=data_tmp.*...
                                CLW_detect_cluster(-tstat.*(tstat<-threshold_tmp),...
                                option,cluster_distribute(t_threshold_idx,:));
                        case 'left'
                            data_tmp=data_tmp.*...
                                CLW_detect_cluster(-tstat.*(tstat<-threshold_tmp),...
                                option,cluster_distribute(t_threshold_idx,:));
                        case 'right'
                            data_tmp=data_tmp.*...
                                CLW_detect_cluster(tstat.*(tstat>threshold_tmp),...
                                option,cluster_distribute(t_threshold_idx,:));
                    end
                end
                data_tmp=ipermute(data_tmp,[6,5,1,2,3,4]);
                data(:,ch_idx,3,z_idx,:,:)=(data_tmp<1)...
                    .*data(:,ch_idx,2,z_idx,:,:);
                if ~option.cluster_union
                    data(:,ch_idx,4,z_idx,:,:)=data_tmp;
                end
            end
        end
    else
        for ch_idx=1:1:header.datasize(2)
            data_tmp=lwdata_in.data(:,ch_idx,1,z_idx,:,:)-option.constant;
            [~,P,~,STATS]=ttest(data_tmp,0,option.alpha,option.tails);
            data(:,ch_idx,1,z_idx,:,:)=P;
            data(:,ch_idx,2,z_idx,:,:)=STATS.tstat;
        end
        curve=[];
        if option.permutation==1
            if option.cluster_union
                idx_temp=find(data(:,:,1,z_idx,:,:)>option.alpha/...
                    (header.datasize(2)*header.datasize(5)*header.datasize(6))...
                    & data(:,:,1,z_idx,:,:)<option.alpha);
                t_threshold=data(:,:,2,z_idx,:,:);
                t_threshold=t_threshold(idx_temp);
                t_threshold=sort(abs(reshape(t_threshold,[],1)));
            else
                switch option.tails
                    case 'both'
                        t_threshold = abs(tinv(option.alpha/2,size(data_tmp,1)-1));
                    case 'left'
                        t_threshold = abs(tinv(option.alpha,size(data_tmp,1)-1));
                    case 'right'
                        t_threshold = abs(tinv(option.alpha,size(data_tmp,1)-1));
                end
            end
            
            data_tmp=lwdata_in.data(:,:,1,z_idx,:,:)-option.constant;
            cluster_distribute=zeros(length(t_threshold),option.num_permutations);
            for iter=1:option.num_permutations
                rnd_data=randn(size(data_tmp));
                rnd_data=data_tmp.*rnd_data./abs(rnd_data);
                
                tstat=mean(rnd_data)./(std(rnd_data)./sqrt(size(rnd_data,1)));
                tstat=permute(tstat,[6,5,1,2,3,4]);
                max_tstat=zeros(length(t_threshold),1);
                for t_threshold_idx=1:length(t_threshold)
                    switch option.tails
                        case 'both'
                            max_tstat(t_threshold_idx)=max(...
                                CLW_max_cluster(tstat.*(tstat>t_threshold(t_threshold_idx)),dist),...
                                CLW_max_cluster(-tstat.*(tstat<-t_threshold(t_threshold_idx)),dist));
                        case 'left'
                            max_tstat(t_threshold_idx)=...
                                CLW_max_cluster(-tstat.*(tstat<-t_threshold(t_threshold_idx)),dist);
                        case 'right'
                            max_tstat(t_threshold_idx)=...
                                CLW_max_cluster(tstat.*(tstat>t_threshold(t_threshold_idx)),dist);
                    end
                end
                cluster_distribute(:,iter)=max_tstat;
                
                
                if option.show_progress
                    criticals=prctile(cluster_distribute(1,1:iter),(1-option.cluster_threshold)*100);
                    curve=[curve,reshape(criticals,[],1)];
                    if ~ishandle(h_line)
                        figure();
                        h_line=plot(1:iter,curve);
                        xlim([1,option.num_permutations]);
                    else
                        set(h_line,'XData',1:iter,'YData',curve);
                        if header.datasize(4)>1
                            str=[' z:',num2str(z_idx),'/',num2str(header.datasize(4))];
                            title(str)
                        end
                    end
                    drawnow;
                end
            end
            
            tstat=permute(data(:,:,2,z_idx,:,:),[6,5,1,2,3,4]);
            data_tmp=ones(size(tstat));
            for t_threshold_idx=1:length(t_threshold)
                threshold_tmp=t_threshold(t_threshold_idx);
                switch option.tails
                    case 'both'
                        data_tmp=data_tmp.*...
                            CLW_detect_cluster(tstat.*(tstat>threshold_tmp),...
                            option,cluster_distribute(t_threshold_idx,:),dist);
                        data_tmp=data_tmp.*...
                            CLW_detect_cluster(-tstat.*(tstat<-threshold_tmp),...
                            option,cluster_distribute(t_threshold_idx,:),dist);
                    case 'left'
                        data_tmp=data_tmp.*...
                            CLW_detect_cluster(-tstat.*(tstat<-threshold_tmp),...
                            option,cluster_distribute(t_threshold_idx,:),dist);
                    case 'right'
                        data_tmp=data_tmp.*...
                            CLW_detect_cluster(tstat.*(tstat>threshold_tmp),...
                            option,cluster_distribute(t_threshold_idx,:),dist);
                end
            end
            
            data_tmp=ipermute(data_tmp,[6,5,1,2,3,4]);
            data(:,:,3,z_idx,:,:)=(data_tmp<1).*data(:,:,2,z_idx,:,:);
            if ~option.cluster_union
                data(:,:,4,z_idx,:,:)=data_tmp;
            end
        end
    end
end
toc;

close all;
figure()
for k=1:size(data,3)
    subplot(2,2,k)
    plot(squeeze(data(:,1,k,:,:,:)));
end
