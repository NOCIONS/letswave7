classdef FLW_spatial_filter_apply<CLW_generic
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
        function obj = FLW_spatial_filter_apply(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'apply filter','sp_filter',...
                'Using Interactive GUI to apply spatial filter by removing components manually.');
        end
    end
    
    methods (Static = true)
        
        function lwdataset_out= get_headerset(lwdataset_in,option)
            [option.unmix_matrix,option.mix_matrix]=...
                CLW_get_mix_unmix_matrix(lwdataset_in(1).header);
            if isempty(option.unmix_matrix) && isempty(option.mix_matrix)
                error('***No unmix/mix matrix can been loaded.***');
            end
            N=length(lwdataset_in);
            lwdataset_out=[];
            for k=setdiff(1:N,option.ref_dataset)
                lwdataset_out(end+1).header=FLW_spatial_filter_apply.get_header(lwdataset_in(k).header,option);
                lwdataset_out(end).data=[];
            end
        end
        
        function header_out= get_header(header_in,option)
            header_out=header_in;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        
        function lwdataset_out= get_lwdataset(lwdataset_in,varargin)
            option.suffix='sp_filter';
            option.is_save=0;
            option=CLW_check_input(option,{'suffix','is_save'},varargin);
            lwdataset_out = FLW_ttest.get_headerset(lwdataset_in,option);
            
        end
        
    end
end