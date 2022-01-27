classdef FLW_spatial_filter_remix<CLW_generic
    properties
        FLW_TYPE=1;
        h_comp_list;
    end
    
    methods
        function obj = FLW_spatial_filter_remix(batch_handle)
            obj@CLW_generic(batch_handle,'remix','sp_mm',...
                'Unmix original signals into a set of components. This requires a dataset with an associated ICA/PCA unmix matrix.');
            
            obj.h_comp_list=uicontrol('style','listbox','min',0,'max',2,...
                'position',[110,140,140,360],'parent',obj.h_panel); 
            uicontrol('style','text','position',[105,500,200,20],...
                'string','Select the component to remove:',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            set(obj.h_comp_list,'backgroundcolor',[1,1,1]);
        end
        
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            option.remove_idx=get(obj.h_comp_list,'Value');
        end
        
        function set_option(obj,option)
            set_option@CLW_generic(obj,option);
            set(obj.h_comp_list,'value',option.remove_idx);
        end
        
        function str=get_Script(obj)
            option=get_option(obj);
            frag_code=[];
            
            frag_code=[frag_code,'''remove_idx'',['];
            for k=1:length(option.remove_idx)
                frag_code=[frag_code,num2str(option.remove_idx(k))];
                if k~=length(option.remove_idx)
                    frag_code=[frag_code,','];
                end
            end
            frag_code=[frag_code,'],']; 
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        
        function GUI_update(obj,batch_pre)
            remove_idx=get(obj.h_comp_list,'Value');
            
            
            lwdataset=batch_pre.lwdataset;
            channel_num=lwdataset(1).header.datasize(2);
            for dataset_pos=2:length(lwdataset)
                if lwdataset(1).header.datasize(2)~=channel_num
                    error('The datasets share different channel numbers.')
                end
            end
            channel_labels={lwdataset(1).header.chanlocs.labels};
            remove_idx=remove_idx(remove_idx<=channel_num);
            set(obj.h_comp_list,'String',channel_labels,'Value',remove_idx);
            
            obj.virtual_filelist=batch_pre.virtual_filelist;
            set(obj.h_txt_cmt,'String',{obj.h_title_str,obj.h_help_str},'ForegroundColor','black');
        end
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            option.unmix_matrix=[];
            option.mix_matrix=[];
            for k=length(header_in.history):-1:1
                if strcmp(header_in.history(k).option.function, 'FLW_spatial_filter_unmix')
                    option.unmix_matrix=header_in.history(k).option.unmix_matrix;
                    option.mix_matrix=header_in.history(k).option.mix_matrix;
                    original_chanlocs=header_in.history(k).option.original_chanlocs;
                    continue;
                end
            end
            if isempty(option.unmix_matrix) && isempty(option.mix_matrix)
                error('***No unmix/mix matrix can been loaded.***');
            end
            header_out=header_in;
            header_out.datasize(2)=size(option.mix_matrix,1);
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            header_out.chanlocs=original_chanlocs;
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            option.suffix='sp_mm';
            option.remove_idx=[];
            option.apply_list=[];
            option.is_save=0;
            option=CLW_check_input(option,{'remove_idx','suffix','is_save'},varargin);
            header=FLW_spatial_filter_remix.get_header(lwdata_in.header,option);
            remix_matrix=header.history(end).option.mix_matrix;
            remix_matrix(:,header.history(end).option.remove_idx)=0;
                
            data=permute(lwdata_in.data,[2,1,3,4,5,6]);
            size_temp=size(data);
            data=reshape(remix_matrix*data(:,:),...
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