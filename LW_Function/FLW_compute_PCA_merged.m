classdef FLW_compute_PCA_merged<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Mout, like math_multiple, t-test
        FLW_TYPE=4;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_compute_PCA_merged(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'PCA_merged','pca_merged',...
                 ['This function is identical to the COMPUTE PCA MATRIX function ',...
                'except for the fact that PCA is performed after merging ',...
                'multiple datasets. The obtained PCA matrix is then ',...
                'assigned to each original dataset. This is useful if you ',...
                'wish to obtain a single matrix for multiple datasets that ',...
                'have all been obtained during the same recording. Note ',...
                'that this is valid if and only if it is reasonable to ',...
                'assume that all the datasets can be explained by a single ',...
                'set of independent components, each projecting identically ',...
                'to the different channels across datasets..']);
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
        
        %get the script for this operation
        %run this function, normally we will get a script 
        %with two lines as following 
        %      option=struct('suffix','demo','is_save',1);
        %      lwdata= FLW_Demo.get_lwdata(lwdata,option);
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
    end
    
    methods (Static = true)
        function lwdataset_out= get_headerset(lwdataset_in,option)
            N=length(lwdataset_in);
            lwdataset_out=[];
            for k=1:N
                lwdataset_out(end+1).header=FLW_compute_PCA_merged.get_header(lwdataset_in(k).header,option);
                lwdataset_out(end).data=[];
            end
        end
        
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
        
        function lwdataset_out= get_lwdataset(lwdataset_in,varargin)
            N=length(lwdataset_in);
            %default values
            option.suffix='pca_merged';
            option.is_save=0;
            option=CLW_check_input(option,{'suffix','is_save'},varargin);
            lwdataset_out=FLW_compute_PCA_merged.get_headerset(lwdataset_in,option);
            
            data=[];
            for k=1:N
                lwdataset_out(k).data=lwdataset_in(k).data;
                temp=permute(lwdataset_out(k).data(:,:,1,1,1,:),[2,6,1,3,4,5]);
                data=[data,temp(:,:)];
            end
            unmix_matrix=pca(data(:,:)')';
            for k=1:N
                lwdataset_out(k).header.history(end).option.unmix_matrix=unmix_matrix;
                lwdataset_out(k).header.history(end).option.mix_matrix=pinv(unmix_matrix);
                if option.is_save
                    CLW_save(lwdataset_out(k));
                end
            end
        end
        
    end
end