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
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.mode='batch';
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            str=get_Script@CLW_generic(obj,frag_code,option);
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
            for k=1:N
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
            option.mode='manager';
            option=CLW_check_input(option,{'suffix','is_save'},varargin);
            lwdataset_out = FLW_spatial_filter_apply.get_headerset(lwdataset_in,option);
            remove_idx=GLW_spatial_filter(lwdataset_in,lwdataset_out(1).header.history(end).option);
            if isnan(remove_idx) 
                if strcmp(option.mode,'batch')
                    error('Spatial filter has been canceled!');
                end
            else
                remix_matrix=lwdataset_out(1).header.history(end).option.mix_matrix;
                remix_matrix(:,remove_idx)=0;
                matrix=remix_matrix*lwdataset_out(1).header.history(end).option.unmix_matrix;
                for k=1:length(lwdataset_out)
                    data=permute(lwdataset_in(k).data,[2,1,3,4,5,6]);
                    size_temp=size(data);
                    data=reshape(matrix*data(:,:),[],size_temp(2),size_temp(3),size_temp(4),size_temp(5),size_temp(6));
                    lwdataset_out(k).data=ipermute(data,[2,1,3,4,5,6]);
                    lwdataset_out(k).header.history(end).option.remove_idx=remove_idx;
                    if option.is_save
                        CLW_save(lwdataset_out(k));
                    end
                end
            end
        end
    end
end