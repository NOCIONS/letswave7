classdef FLW_compute_PCA<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Mout, like math_multiple, t-test
        FLW_TYPE=1;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_compute_PCA(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'PCA','pca',...
                ['Compute an Principal Component Analysis (PCA) separatly',...
                ' for each dataset. The mixing and unmixing matrices '...
                'are stored in the history of dataset header.']);
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
            option.suffix='pca';
            option.is_save=0;
            option=CLW_check_input(option,{'suffix','is_save'},varargin);
            header_in=lwdata_in.header;
            header=FLW_compute_PCA.get_header(header_in,option);
            data=permute(lwdata_in.data(:,:,1,1,1,:),[2,6,1,3,4,5]);
            unmix_matrix=pca(data(:,:)')';
            header.history(end).option.unmix_matrix=unmix_matrix;
            header.history(end).option.mix_matrix=pinv(unmix_matrix);
            lwdata_out.header=header;
            lwdata_out.data=lwdata_in.data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end