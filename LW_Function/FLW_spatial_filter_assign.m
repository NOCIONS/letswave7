classdef FLW_spatial_filter_assign<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Mout, like math_multiple, t-test
        FLW_TYPE=1;
        %properties
        h_filepath;
        h_file_edit;
        h_sele_btn;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_spatial_filter_assign(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'assign filter','assign',...
                'Assign an existing ICA/PCA mix/unmix spatial matrix of a given dataset to another dataset.');
            uicontrol('style','text','position',[35,430,200,20],...
                'string','load the data set the mix/unmix matrix:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_file_edit=uicontrol('style','edit','position',[35,400,250,25],...
                'string','','HorizontalAlignment','left','parent',obj.h_panel);
            obj.h_sele_btn=uicontrol('style','pushbutton','position',[305,400,80,25],...
                'string','select','parent',obj.h_panel);
            
            set(obj.h_sele_btn,'Callback',@obj.btn_selection);
        end
        
        
        function bselection(obj)
            
        end
        
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.source=get(obj.h_file_edit,'string');
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_file_edit,'string',option.source);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            %%%
            frag_code=[frag_code,'''source'',''',option.source,''','];
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            source_header=option.source;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            %default values
            option.suffix='assign';
            option.source='';
            option.is_save=0;
            option=CLW_check_input(option,{'source','suffix','is_save'},varargin);
            inheader=lwdata_in.header;
            header=FLW_run_ICA.get_header(inheader,option);
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
                        [ica.weights,ica.sphere,~,~,~,~,~]=runica(data(:,:),'pca',num_ICs);
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