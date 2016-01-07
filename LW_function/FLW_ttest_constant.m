classdef FLW_ttest_constant<CLW_generic
    properties
        FLW_TYPE=1;
        h_constant_edit;
        h_tail_pop;
        h_alpha_edit;
        h_permutation_test_chk;
        h_panel;
        h_method_pop;
        h_threshold_edit;
        h_number_edit;
        h_show_progress_chk;
    end
    
    methods
        function obj = FLW_ttest_constant(tabgp)
            obj@CLW_generic(tabgp,'ttest','ttest',...
                'Just make a ttest_constant for how to the FLW file.');
            
            uicontrol('style','text','position',[35,533,200,20],...
                'string','Compare to constant','HorizontalAlignment','left',...
                'parent',obj.h_tab);
            obj.h_constant_edit=uicontrol('style','edit','String','0',...
                'position',[35,510,200,25],'parent',obj.h_tab);
            
            uicontrol('style','text','position',[35,470,200,20],...
                'string','Type of alternative hypothsis:','HorizontalAlignment','left',...
                'parent',obj.h_tab);
            obj.h_tail_pop=uicontrol('style','popupmenu','value',1,...
                'String',{'two-tailed test','left-tailed test','right-tailed test'},...
                'position',[35,440,200,30],'parent',obj.h_tab);
            
            uicontrol('style','text','position',[35,400,200,20],...
                'string','Alpha level:','HorizontalAlignment','left',...
                'parent',obj.h_tab);
            obj.h_alpha_edit=uicontrol('style','edit','String','0.05',...
                'position',[35,377,200,25],'parent',obj.h_tab);
            
            
            obj.h_panel=uipanel('unit','pixels','position',[20,135,400,225],...
                'parent',obj.h_tab);
            obj.h_permutation_test_chk=uicontrol('style','checkbox',...
                'String','Clustersize-based permutation testing',...
                'position',[15,190,350,25],'callback',@obj.showpanel,...
                'parent',obj.h_panel);
            
            uicontrol('style','text','position',[15,160,200,20],...
                'string','Criteria for the threshold:','tag','permute',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_method_pop=uicontrol('style','popupmenu','value',1,...
                'String',{'Percentile of mean cluster sum',...
                'Percentile of max cluster sum',...
                'Standard-deviation of mean cluster sum',...
                'Standard-deviation of max cluster sum'},'tag','permute',...
                'position',[15,130,200,30],'parent',obj.h_panel);
            
            uicontrol('style','text','position',[15,100,200,20],...
                'string','Cluster threshold:','tag','permute',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_threshold_edit=uicontrol('style','edit','String','95',...
                'position',[15,75,200,25],'tag','permute',...
                'parent',obj.h_panel);
            
            uicontrol('style','text','position',[15,40,200,20],...
                'string','Number of permutations:','tag','permute',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_number_edit=uicontrol('style','edit','String',2000,...
                'position',[15,10,200,25],'tag','permute',...
                'parent',obj.h_panel);
            obj.h_show_progress_chk=uicontrol('style','checkbox',...
                'String','show progress','value',1,...
                'position',[225,10,200,25],'tag','permute',...
                'parent',obj.h_panel);
            
            h=findobj(obj.h_panel,'tag','permute');
            set(h,'enable','off');
        end
        
        function showpanel(obj,varargin)
            h=findobj(obj.h_panel,'tag','permute');
            if get(obj.h_permutation_test_chk,'value')
                set(h,'enable','on');
            else
                set(h,'enable','off');
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
            switch get(obj.h_method_pop,'value')
                case 1
                    option.cluster_statistic='perc_mean';
                case 2
                    option.cluster_statistic='perc_max';
                case 3
                    option.cluster_statistic='sd_mean';
                case 4
                    option.cluster_statistic='sd_max';
            end
            option.cluster_threshold=str2num(get(obj.h_threshold_edit,'string'));
            option.num_permutations=str2num(get(obj.h_number_edit,'string'));
            option.show_progress=get(obj.h_show_progress_chk,'value');
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
            obj.showpanel();
            set(obj.h_alpha_edit,'string',num2str(option.alpha));
            switch option.cluster_statistic
                case 'perc_mean'
                    set(obj.h_method_pop,'value',1);
                case 'perc_max'
                    set(obj.h_method_pop,'value',2);
                case 'sd_mean'
                    set(obj.h_method_pop,'value',3);
                case 'sd_max'
                    set(obj.h_method_pop,'value',4);
            end
            set(obj.h_threshold_edit,'string',num2str(option.cluster_threshold));
            set(obj.h_number_edit,'string',num2str(option.num_permutations));
            set(obj.h_show_progress_chk,'value',option.show_progress);
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
            frag_code=[frag_code,'''permutation'',',...
                num2str(option.permutation),','];
            frag_code=[frag_code,'''cluster_statistic'',''',...
                option.cluster_statistic,''','];
            frag_code=[frag_code,'''cluster_threshold'',',...
                num2str(option.cluster_threshold),','];
            frag_code=[frag_code,'''num_permutations'',',...
                num2str(option.num_permutations),',']; 
            frag_code=[frag_code,'''show_progress'',',...
                num2str(option.show_progress),',']; 
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            
            header_out.datasize(1)=1;
            header_out.index_labels{1}='p-value';
            header_out.index_labels{2}='T-value';
            if option.permutation==1
                header_out.datasize(3)=5;
                header_out.index_labels{3}='cluster p-value';
                header_out.index_labels{4}='cluster T-value';
                header_out.index_labels{5}='threshold';
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
            option.num_permutations=250;
            option.cluster_statistic='perc_mean'; 
            option.cluster_threshold=95;
            option.show_progress=1;
            
            option.affix='ttest';
            option.is_save=0;
            option=CLW_check_input(option,{'constant','tails','alpha',...
                'permutation','num_permutations','cluster_statistic',...
                'cluster_threshold','show_progress','affix','is_save'},...
                varargin);
            header=FLW_ttest_constant.get_header(lwdata_in.header,option);
            
            tp_data=lwdata_in.data(:,:,1,:,:,:)-option.constant;
            [H,P,~,STATS]=ttest(tp_data,...
                option.constant,option.alpha,option.tails);
            data=zeros(header.datasize);
            data(:,:,1,:,:,:)=P;
            data(:,:,2,:,:,:)=STATS.tstat;
            if option.permutation==1
                if option.show_progress
                    h_fig=-1;
                    curve=[];
                end
                data_cutoff=H.*STATS.tstat;
                data_cutoff=permute(data_cutoff,[5,6,1,2,3,4]);
                RLL=reshape(bwlabeln(data_cutoff,4),[],1);
                for k=1:max(RLL)
                    ff=find(RLL==k);
                    data_cutoff(ff)=sum(abs(data_cutoff(ff)));
                end
                
                tp_data=lwdata_in.data(:,:,1,:,:,:)-option.constant;
                for iter=1:option.num_permutations
                    rnd_data=randn(size(tp_data));
                    rnd_data=tp_data.*rnd_data./abs(rnd_data);
                    
%                     rnd_data=tp_data;
%                     rnd_data(2:2:end,:,:,:,:,:)=-rnd_data(2:2:end,:,:,:,:,:);
                    [H,~,~,STATS]=ttest(rnd_data,0,option.alpha,option.tails);
                    Tvalue=H.*STATS.tstat;
                    Tvalue=permute(Tvalue,[5,6,1,2,3,4]);
                    RLL=reshape(bwlabeln(Tvalue,4),[],1);
                    RLL_size=cell(size(lwdata_in.data,2),size(lwdata_in.data,4));
                    
                    for k=1:max(RLL)
                        ff=find(RLL==k);
                        v=sum(abs(Tvalue(ff)));
                        if v>0
                            [~,~,~,chanpos,~,dz]=ind2sub(size(Tvalue),ff);
                            chanpos=chanpos(1);dz=dz(1);
                            RLL_size{chanpos,dz}=[RLL_size{chanpos,dz},v];
                        end
                    end
                    RLL_size=cellfun(@(x)setzeros(x),RLL_size, 'UniformOutput',false);
                    blob_size_mean(:,:,iter)=cellfun(@(x)mean(abs(x)), RLL_size);
                    blob_size_max(:,:,iter)=cellfun(@(x)max(abs(x)), RLL_size);
                    
                    if option.show_progress&& mod(iter,ceil(option.num_permutations/200)==0)
                        switch option.cluster_statistic
                            case 'perc_mean'
                                criticals=prctile(blob_size_mean,option.cluster_threshold,3);
                            case 'perc_max'
                                criticals=prctile(blob_size_max,option.cluster_threshold,3);
                            case 'sd_mean'
                                criticals=option.cluster_threshold*std(blob_size_mean,[],3)+mean(blob_size_mean,3);
                            case 'sd_max'
                                criticals=option.cluster_threshold*std(blob_size_max,[],3)+mean(blob_size_max,3);
                        end
                        if ~ishandle(h_fig)
                            h_fig=figure();
                        end
                        curve=[curve,criticals(:,1)];
                        plot(1:iter,curve);
                        xlim([1,option.num_permutations])
                        drawnow;
                    end
                end
                switch option.cluster_statistic
                    case 'perc_mean'
                        criticals=prctile(blob_size_mean,option.cluster_threshold,3);
                    case 'perc_max'
                        criticals=prctile(blob_size_max,option.cluster_threshold,3);
                    case 'sd_mean'
                        criticals=option.cluster_threshold*std(blob_size_mean,[],3)+mean(blob_size_mean,3);
                    case 'sd_max'
                        criticals=option.cluster_threshold*std(blob_size_max,[],3)+mean(blob_size_max,3);
                end
                data_threshold=zeros(size(data_cutoff));
                for chanpos=1:size(lwdata_in.data,2)
                    for dz=1:size(lwdata_in.data,4)
                        data_cutoff(:,:,1,chanpos,1,dz)=data_cutoff(:,:,1,chanpos,1,dz)>criticals(chanpos,dz);
                        data_threshold(:,:,1,chanpos,1,dz)=criticals(chanpos,dz);
                    end
                end
                data_cutoff=ipermute(data_cutoff,[5,6,1,2,3,4]);
                data_threshold=ipermute(data_threshold,[5,6,1,2,3,4]);
                data(:,:,3,:,:,:)=1-(1-data(:,:,1,:,:,:)).*data_cutoff;
                data(:,:,4,:,:,:)=data(:,:,2,:,:,:).*data_cutoff;
                data(:,:,5,:,:,:)=data_threshold;
            end
            
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
            if option.permutation && option.show_progress
                if ishandle(h_fig)
                    close(h_fig);
                end
            end
        end
    end
end

function y=setzeros(x)
if isempty(x)
    y=0;
else
    y=x;
end
end