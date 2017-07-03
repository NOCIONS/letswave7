classdef FLW_spatial_filter_unmix<CLW_generic
    properties
        FLW_TYPE=1;
    end
    
    methods
        function obj = FLW_spatial_filter_unmix(batch_handle)
            obj@CLW_generic(batch_handle,'unmix','sp_um',...
                'Unmix original signals into a set of components. This requires a dataset with an associated ICA/PCA unmix matrix.');
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            [option.unmix_matrix,option.mix_matrix]=...
                CLW_get_mix_unmix_matrix(header_in);
            if isempty(option.unmix_matrix) && isempty(option.mix_matrix)
                error('***No unmix/mix matrix can been loaded.***');
            end
            
            header_out=header_in;
            header_out.datasize(2)=size(option.unmix_matrix,1);
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            chanlocs=header_out.chanlocs;
            option.original_chanlocs=chanlocs;
            for k=1:size(option.unmix_matrix,1)
                chanlocs(k).labels=['comp ',num2str(k)];
                chanlocs(k).topo_enabled=0;
            end
            chanlocs=chanlocs(1:size(option.unmix_matrix,1));
            header_out.chanlocs=chanlocs;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.suffix='sp_um';
            option.is_save=0;
            option=CLW_check_input(option,{'suffix','is_save'},varargin);
            header=FLW_spatial_filter_unmix.get_header(lwdata_in.header,option);
            
            data=permute(lwdata_in.data,[2,1,3,4,5,6]);
            size_temp=size(data);
            data=reshape(header.history(end).option.unmix_matrix*data(:,:),...
                [],size_temp(2),size_temp(3),size_temp(4),size_temp(5),size_temp(6));
            data=ipermute(data,[2,1,3,4,5,6]);
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end