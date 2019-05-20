classdef FLW_compute_ICA<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Mout, like math_multiple, t-test
        FLW_TYPE=1;
        %properties
        h_algorithm;
        h_buttongroup;
        h_r1;
        h_r2;
        h_r3;
        h_r2_text;
        h_r2_num_ICs;
        h_r3_text1;
        h_r3_method;
        h_r3_text2;
        h_r3_percentage;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_compute_ICA(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'ICA','ica',...
                ['Compute an Independent Component Analysis (ICA) separatly',...
                ' for each dataset.The ICA decomposition can be performed',... 
                ' using the RUNICA algorithm (as implemented in EEGLAB),',...
                ' or using the JADER algorithm. The mixing and unmixing',...
                ' matrices are stored in the history of dataset header.']);
            uicontrol('style','text','position',[35,480,150,20],...
                'string','algorithm :',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_algorithm=uicontrol('style','popupmenu',...
                'String',{'runica','jader'},'value',1,...
                'position',[35,460,100,20],'parent',obj.h_panel);
            uicontrol('style','text','position',[35,430,150,20],...
                'string','number of components:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_buttongroup=uibuttongroup('units','pixels','userdata',1,...
                'position',[40,405,360,24],'parent',obj.h_panel);
            obj.h_r1=uicontrol(obj.h_buttongroup,'style','radiobutton','userdata',1,...
                'String','All components','position',[1,1,120,20],'handleVisibility','off');
            obj.h_r2=uicontrol(obj.h_buttongroup,'style','radiobutton','userdata',2,...
                'String','decide by user','position',[123,1,120,20],'handleVisibility','off');
            obj.h_r3=uicontrol(obj.h_buttongroup,'style','radiobutton','userdata',3,...
                'String','decide by PICA','position',[246,1,100,20],'handleVisibility','off');
            set(obj.h_buttongroup,'SelectionChangeFcn',@obj.bselection);
            %set(obj.h_buttongroup,'SelectionChangedFcn',@obj.bselection);
            
            if ispc
                set(obj.h_r2,'position',[115,1,120,20]);
                set(obj.h_r3,'position',[230,1,120,20]);
            end
            obj.h_r2_text=uicontrol('style','text','position',[35,350,150,20],...
                'string','Components Numbers:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_r2_num_ICs=uicontrol('style','edit',...
                'String','','position',[80,331,250,20],'parent',obj.h_panel);
            
            obj.h_r3_text1=uicontrol('style','text','position',[35,350,150,20],...
                'string','Criterion for PICA estimate:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_r3_method=uicontrol('style','popupmenu',...
                'String',{'Laplacian Estimate (LAP)',...
                'Bayesian Information Criterion (BIC)',...
                'Rajan & Rayner (RRN)',...
                ' Akaike information criterion (AIC)',...
                'minimum description length (MDL)'},...
                'value',1,'position',[76,330,260,20],'parent',obj.h_panel);
            
            obj.h_r3_text2=uicontrol('style','text','position',[35,300,180,20],...
                'string','Percentage of PICA estimate:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_r3_percentage=uicontrol('style','edit',...
                'String','100','position',[80,280,250,20],'parent',obj.h_panel);
            
            set(obj.h_r2_text,'visible','off');
            set(obj.h_r2_num_ICs,'visible','off');
            set(obj.h_r3_text1,'visible','off');
            set(obj.h_r3_method,'visible','off');
            set(obj.h_r3_text2,'visible','off');
            set(obj.h_r3_percentage,'visible','off');
            set(obj.h_algorithm,'backgroundcolor',[1,1,1]);
            set(obj.h_r2_num_ICs,'backgroundcolor',[1,1,1]);
            set(obj.h_r3_method,'backgroundcolor',[1,1,1]);
            set(obj.h_r3_percentage,'backgroundcolor',[1,1,1]);
        end
        
        function bselection(obj,~,callbackdata)
            t=get(callbackdata.NewValue,'userdata');
            set(obj.h_buttongroup,'userdata',t);
            switch t
                case 1
                    set(obj.h_r2_text,'visible','off');
                    set(obj.h_r2_num_ICs,'visible','off');
                    set(obj.h_r3_text1,'visible','off');
                    set(obj.h_r3_method,'visible','off');
                    set(obj.h_r3_text2,'visible','off');
                    set(obj.h_r3_percentage,'visible','off');
                case 2
                    set(obj.h_r2_text,'visible','on');
                    set(obj.h_r2_num_ICs,'visible','on');
                    set(obj.h_r3_text1,'visible','off');
                    set(obj.h_r3_method,'visible','off');
                    set(obj.h_r3_text2,'visible','off');
                    set(obj.h_r3_percentage,'visible','off');
                case 3
                    set(obj.h_r2_text,'visible','off');
                    set(obj.h_r2_num_ICs,'visible','off');
                    set(obj.h_r3_text1,'visible','on');
                    set(obj.h_r3_method,'visible','on');
                    set(obj.h_r3_text2,'visible','on');
                    set(obj.h_r3_percentage,'visible','on');
            end
        end
        
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.ICA_mode=get(obj.h_buttongroup,'userdata');
            option.algorithm=get(obj.h_algorithm,'value');
            option.num_ICs=str2num(get(obj.h_r2_num_ICs,'string'));
            option.percentage_PICA=str2num(get(obj.h_r3_percentage,'string'));
            option.criterion_PICA=get(obj.h_r3_method,'value');
            switch(option.criterion_PICA)
                case 1
                    option.criterion_PICA='LAP';
                case 2
                    option.criterion_PICA='BIC';
                case 3
                    option.criterion_PICA='RRN';
                case 4
                    option.criterion_PICA='AIC';
                case 5
                    option.criterion_PICA='MDL';
            end
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_buttongroup,'userdata',option.ICA_mode);
            set(obj.h_algorithm,'value',option.algorithm);
            set(obj.h_buttongroup,'userdata',option.ICA_mode);
            switch option.ICA_mode
                case 1
                    set(obj.h_r3_text1,'visible','off');
                    set(obj.h_r3_method,'visible','off');
                    set(obj.h_r3_text2,'visible','off');
                    set(obj.h_r3_percentage,'visible','off');
                    set(obj.h_r1,'value',1);
                case 2
                    set(obj.h_r2_text,'visible','on');
                    set(obj.h_r2_num_ICs,'visible','on');
                    set(obj.h_r3_text1,'visible','off');
                    set(obj.h_r3_method,'visible','off');
                    set(obj.h_r3_text2,'visible','off');
                    set(obj.h_r3_percentage,'visible','off');
                    set(obj.h_r2,'value',1);
                case 3
                    set(obj.h_r2_text,'visible','off');
                    set(obj.h_r2_num_ICs,'visible','off');
                    set(obj.h_r3_text1,'visible','on');
                    set(obj.h_r3_method,'visible','on');
                    set(obj.h_r3_text2,'visible','on');
                    set(obj.h_r3_percentage,'visible','on');
                    set(obj.h_r3,'value',1);
            end
            
            set(obj.h_r2_num_ICs,'String',num2str(option.num_ICs));
            set(obj.h_r3_percentage,'String',num2str(option.percentage_PICA));
            switch(option.criterion_PICA)
                case 'LAP'
                    set(obj.h_r3_method,'value',1);
                case 'BIC'
                    set(obj.h_r3_method,'String',2);
                case 'RRN'
                    set(obj.h_r3_method,'String',3);
                case 'AIC'
                    set(obj.h_r3_method,'String',4);
                case 'MDL'
                    set(obj.h_r3_method,'String',5);
            end
        end
        
        %get the script for this operation
        %run this function, normally we will get a script 
        %with two lines as following 
        %      option=struct('suffix','demo','is_save',1);
        %      lwdata= FLW_Demo.get_lwdata(lwdata,option);
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            %%%
            frag_code=[frag_code,'''ICA_mode'',',...
                num2str(option.ICA_mode),','];
            frag_code=[frag_code,'''algorithm'',',...
                num2str(option.algorithm),','];
            switch(option.ICA_mode)
                case 2
                    frag_code=[frag_code,'''num_ICs'',',...
                        num2str(option.num_ICs),','];
                case 3
                    frag_code=[frag_code,'''percentage_PICA'',',...
                        num2str(option.percentage_PICA),','];
                    frag_code=[frag_code,'''criterion_PICA'',''',...
                        option.criterion_PICA,''','];
            end
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function GUI_update(obj,batch_pre)
            obj.lwdataset=batch_pre.lwdataset;
            if isempty(get(obj.h_r2_num_ICs,'string'))
                set(obj.h_r2_num_ICs,'string',num2str(obj.lwdataset(1).header.datasize(2)));
            end
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
        
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            
            option.unmix_matrix=eye(header_in.datasize(2),header_in.datasize(2));
            option.mix_matrix=eye(header_in.datasize(2),header_in.datasize(2));
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            %default values
            option.ICA_mode=1;
            option.algorithm=1;
            option.num_ICs=1;
            option.percentage_PICA=100;
            option.criterion_PICA='LAP';
            option.suffix='ica';
            option.is_save=0;
            option=CLW_check_input(option,{'ICA_mode','algorithm','num_ICs',...
                'percentage_PICA','criterion_PICA','suffix','is_save'},varargin);
            header_in=lwdata_in.header;
            header=FLW_compute_ICA.get_header(header_in,option);
            data=permute(lwdata_in.data(:,:,1,1,1,:),[2,6,1,3,4,5]);
            if option.ICA_mode==3
                dimprob=pca_dim(data(:,:));
                switch option.criterion_PICA
                    case 'LAP'
                        [~,num_ICs]=max(dimprob.lap);
                    case 'BIC'
                        [~,num_ICs]=max(dimprob.bic);
                    case 'RRN'
                        [~,num_ICs]=max(dimprob.rrn);
                    case 'AIC'
                        [~,num_ICs]=max(dimprob.aic);
                    case 'MDL'
                        [~,num_ICs]=max(dimprob.mdl);
                end
                num_ICs=round(num_ICs*(option.percentage_PICA/100));
            end
            switch option.algorithm
                case 1
                    if option.ICA_mode==1
                        [ica.weights,ica.sphere,~,~,~,~,~]=runica(data(:,:));
                    else
                        [ica.weights,ica.sphere,~,~,~,~,~]=runica(data(:,:),'pca',option.num_ICs);
                    end
                    ica_um=ica.weights*ica.sphere;
                case 2
                    if option.ICA_mode==1
                        ica_um=jader(data(:,:));
                    else
                        ica_um=jader(data(:,:),num_ICs);
                    end
            end
            header.history(end).option.unmix_matrix=ica_um;
            header.history(end).option.mix_matrix=pinv(ica_um);
            lwdata_out.header=header;
            lwdata_out.data=lwdata_in.data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end