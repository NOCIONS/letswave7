classdef FLW_ttest_constant<CLW_generic
    properties
        FLW_TYPE=1;
        h_constant_edit;
        h_tail_pop;
        h_alpha_edit;
        h_permutation_test_chk;
        h_permutation_panel;
        h_threshold_edit;
        h_number_edit;
        h_show_progress_chk;
        h_cluster_union_chk;
        
        h_multiple_sensor_panel;
        h_multiple_sensor_chk;
        h_chan_dist_txt;
        h_chan_dist_edit;
        h_chan_dist_btn;
    end
    
    methods
        function obj = FLW_ttest_constant(batch_handle)
            obj@CLW_generic(batch_handle,'ttest','ttest',...
                'Just make a ttest_constant for how to the FLW file.');
            
            uicontrol('style','text','position',[35,490,200,20],...
                'string','Type of alternative hypothsis:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_tail_pop=uicontrol('style','popupmenu','value',1,...
                'String',{'two-tailed test','left-tailed test','right-tailed test'},...
                'position',[35,465,200,30],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[35,435,200,20],...
                'string','Compare to constant','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_constant_edit=uicontrol('style','edit','String','0',...
                'position',[35,415,200,25],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[35,380,200,20],...
                'string','Alpha level:','HorizontalAlignment','left',...
                'parent',obj.h_panel);
            obj.h_alpha_edit=uicontrol('style','edit','String','0.05',...
                'callback',@obj.alpha_level_Callback,...
                'position',[35,357,200,25],'parent',obj.h_panel);
            
            
            obj.h_permutation_panel=uipanel('unit','pixels',...
                'position',[10,135,400,205],'parent',obj.h_panel,...
                'title','Cluster-Based Permutation Test');
            obj.h_permutation_test_chk=uicontrol('style','checkbox',...
                'String','Enable',...
                'position',[15,165,350,25],'callback',@obj.showpanel,...
                'parent',obj.h_permutation_panel);
            
            uicontrol('style','text','position',[15,130,200,20],...
                'string','Cluster threshold:','tag','permute',...
                'HorizontalAlignment','left','parent',obj.h_permutation_panel);
            obj.h_threshold_edit=uicontrol('style','edit','String','0.05',...
                'callback',@obj.alpha_level_Callback,...
                'position',[15,105,220,25],'tag','permute',...
                'parent',obj.h_permutation_panel);
            
            
            uicontrol('style','text','position',[15,70,200,20],...
                'string','Number of permutation:','tag','permute',...
                'HorizontalAlignment','left','parent',obj.h_permutation_panel);
            obj.h_show_progress_chk=uicontrol('style','checkbox',...
                'String','show progress','value',1,...
                'position',[135,70,100,25],'tag','permute',...
                'parent',obj.h_permutation_panel);
            obj.h_number_edit=uicontrol('style','edit','String',2000,...
                'position',[15,45,220,25],'tag','permute',...
                'parent',obj.h_permutation_panel);
            
            obj.h_cluster_union_chk=uicontrol('style','checkbox',...
                'String','Apply Cluster Union Method','value',1,...
                'callback',@obj.set_alpha_level,...
                'position',[15,5,200,25],'tag','permute',...
                'parent',obj.h_permutation_panel);
            
            obj.h_multiple_sensor_panel=uipanel( 'unit','pixels',...
                'title','multiple sensor analysis',...
                'position',[255,5,135,150],'parent',obj.h_permutation_panel);
            obj.h_multiple_sensor_chk=uicontrol('style','checkbox',...
                'String','Enable','value',0,'callback',@obj.showpanel2,...
                'position',[5,110,135,25],'tag','permute',...
                'parent',obj.h_multiple_sensor_panel);
            
            obj.h_chan_dist_txt=uicontrol('style','text','position',[5,80,120,20],...
                'string','channel distance:','tag','permute',...
                'HorizontalAlignment','left','parent',obj.h_multiple_sensor_panel);
            obj.h_chan_dist_edit=uicontrol('style','edit','String','0',...
                'position',[5,55,120,25],'tag','permute',...
                'parent',obj.h_multiple_sensor_panel);
            obj.h_chan_dist_btn=uicontrol('style','pushbutton',...
                'String','Set Distance',...
                'position',[5,10,120,25],'tag','permute',...
                'parent',obj.h_multiple_sensor_panel);
            
            h=findobj(obj.h_permutation_panel,'tag','permute');
            set(h,'enable','off');
        end
        
        function alpha_level_Callback(obj,varargin)
            str=get(varargin{1},'String');
            if get(obj.h_cluster_union_chk,'value')
                set(obj.h_threshold_edit,'string',str);
                set(obj.h_alpha_edit,'string',str);
            end
        end
        
        function set_alpha_level(obj,varargin)
            if get(obj.h_cluster_union_chk,'value')
                set(obj.h_threshold_edit,...
                    'string',get(obj.h_alpha_edit,'string'));
            end
        end
        
        function showpanel(obj,varargin)
            h=findobj(obj.h_permutation_panel,'tag','permute');
            if get(obj.h_permutation_test_chk,'value')
                set(h,'enable','on');
                if ~get(obj.h_multiple_sensor_chk,'value')
                    set(obj.h_chan_dist_txt,'enable','off');
                    set(obj.h_chan_dist_edit,'enable','off');
                    set(obj.h_chan_dist_btn,'enable','off');
                end
            else
                set(h,'enable','off');
            end
        end
        
        function showpanel2(obj,varargin)
            if ~get(obj.h_multiple_sensor_chk,'value')
                set(obj.h_chan_dist_txt,'enable','off');
                set(obj.h_chan_dist_edit,'enable','off');
                set(obj.h_chan_dist_btn,'enable','off');
            else
                set(obj.h_chan_dist_txt,'enable','on');
                set(obj.h_chan_dist_edit,'enable','on');
                set(obj.h_chan_dist_btn,'enable','on');
            end
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.constant=str2num(get(obj.h_constant_edit,'string'));
            switch get(obj.h_tail_pop,'value')
                case 1
                    option.tails='both';
                case 2
                    option.tails='left';
                case 3
                    option.tails='right';
            end
            option.alpha=str2num(get(obj.h_alpha_edit,'string'));
            option.permutation=get(obj.h_permutation_test_chk,'value');
            option.cluster_threshold=str2num(get(obj.h_threshold_edit,'string'));
            option.num_permutations=str2num(get(obj.h_number_edit,'string'));
            option.show_progress=get(obj.h_show_progress_chk,'value');
            
            option.cluster_union=get(obj.h_cluster_union_chk,'value');
            option.multiple_sensor=get(obj.h_multiple_sensor_chk,'value');
            option.chan_dist=str2num(get(obj.h_chan_dist_edit,'string'));
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_constant_edit,'string',num2str(option.constant));
            switch(option.tails)
                case 'both'
                    set(obj.h_tail_pop,'value',1)
                case 'left'
                    set(obj.h_tail_pop,'value',2)
                case 'right'
                    set(obj.h_tail_pop,'value',3)
            end
            set(obj.h_alpha_edit,'string',num2str(option.alpha));
            
            set(obj.h_permutation_test_chk,'value',option.permutation);
            set(obj.h_alpha_edit,'string',num2str(option.alpha));
            set(obj.h_threshold_edit,'string',num2str(option.cluster_threshold));
            set(obj.h_number_edit,'string',num2str(option.num_permutations));
            set(obj.h_show_progress_chk,'value',option.show_progress);
            set(obj.h_cluster_union_chk,'value',option.cluster_union);
            set(obj.h_multiple_sensor_chk,'value',option.multiple_sensor);
            set(obj.h_chan_dist_edit,'string',num2str(option.chan_dist));
            
            obj.showpanel2();
            obj.showpanel();
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            frag_code=[frag_code,'''constant'',',...
                num2str(option.constant),','];
            frag_code=[frag_code,'''tails'',''',...
                option.tails,''','];
            frag_code=[frag_code,'''alpha'',',...
                num2str(option.alpha),','];
            if option.permutation
                frag_code=[frag_code,'''permutation'',',...
                    num2str(option.permutation),','];
                frag_code=[frag_code,'''cluster_threshold'',',...
                    num2str(option.cluster_threshold),','];
                frag_code=[frag_code,'''num_permutations'',',...
                    num2str(option.num_permutations),','];
                frag_code=[frag_code,'''show_progress'',',...
                    num2str(option.show_progress),','];
                frag_code=[frag_code,'''cluster_union'',',...
                    num2str(option.cluster_union),','];
                if option.multiple_sensor
                    frag_code=[frag_code,'''multiple_sensor'',',...
                        num2str(option.multiple_sensor),','];
                    frag_code=[frag_code,'''chan_dist'',',...
                        num2str(option.chan_dist),','];
                end
            end
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
                header_out.datasize(3)=3;
                header_out.index_labels{3}='cluster t-value';
                if ~option.cluster_union
                    header_out.datasize(3)=4;
                    header_out.index_labels{4}='cluster p-value';
                end
            else
                header_out.datasize(3)=2;
            end
            if ~isempty(option.affix)
                header_out.name=[option.affix,' ',header_out.name];
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
            option.cluster_union=1;
            option.multiple_sensor=0;
            option.chan_dist=0;
            
            option.affix='ttest';
            option.is_save=0;
            option=CLW_check_input(option,{'constant','tails','alpha',...
                'permutation','num_permutations','cluster_statistic',...
                'cluster_threshold','show_progress','cluster_union',...
                'multiple_sensor','chan_dist','affix','is_save'},...
                varargin);
            header=FLW_ttest_constant.get_header(lwdata_in.header,option);
            
            
            
            h_line=-1;
            chan_used=find([header.chanlocs.topo_enabled]==1, 1);
            if isempty(chan_used)
                S=load('init_parameter.mat');
                temp=CLW_edit_electrodes(header,S.userdata.chanlocs);
                clear S;
                [y,x]= pol2cart(pi/180.*[temp.chanlocs.theta],[temp.chanlocs.radius]);
            else
                [y,x]= pol2cart(pi/180.*[header.chanlocs.theta],[header.chanlocs.radius]);
            end
            dist=squareform(pdist([x;y]'))<0.22;
            
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
                                        title(get(h_line,'parent'),str);
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
                            idx_temp= data(:,:,1,z_idx,:,:)>option.alpha/...
                                (header.datasize(2)*header.datasize(5)*header.datasize(6))...
                                & data(:,:,1,z_idx,:,:)<option.alpha;
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
                                        title(get(h_line,'parent'),str);
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
            
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
            if option.permutation && option.show_progress
                if ishandle(h_line)
                    close(get(get(h_line,'parent'),'parent'));
                end
            end
        end
    end
end