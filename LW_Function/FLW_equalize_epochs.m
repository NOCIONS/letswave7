classdef FLW_equalize_epochs<CLW_generic
    properties
        % set the type of the FLW class
        % 0 for load (only input);
        % 1 for the function dealing with single dataset (1in-1out)
        % 2 for the function with Nin-1out, like merge
        % 3 for the function with 1in-Nout, like segmentation_separate
        % 4 for the function with Nin-Mout, like math_multiple, t-test
        FLW_TYPE=1;
        %properties
        h_equalize_btn;
        h_numepochs_edit;
        h_selectrandom_chk;
    end
    
    methods
        % the constructor of this class
        function obj = FLW_equalize_epochs(batch_handle)
            %call the constructor of the superclass
            %CLW_generic(tabgp,fun_name,suffix_name,help_str)
            obj@CLW_generic(batch_handle,'Equalize number of epochs','equ',...
                'Equalize number of epochs across datasets.');
            %objects
            %equalize_btn
            obj.h_equalize_btn=uicontrol('style','pushbutton',...
                'String','Find max number of epochs across datasets',...
                'callback',@obj.equalize_btn_pressed,...
                'position',[35,400,300,40],'parent',obj.h_panel);
            uicontrol('style','text','position',[35,365,150,20],...
                'string','Number of epochs :',...
                'HorizontalAlignment','left','parent',obj.h_panel);
            %numepochs_edit
            obj.h_numepochs_edit=uicontrol('style','edit',...
                'String','1','value',0,'backgroundcolor',[1,1,1],...
                'HorizontalAlignment','left',...
                'position',[35,340,100,20],'parent',obj.h_panel);
            %selectrandom_chk
            obj.h_selectrandom_chk=uicontrol('style','checkbox',...
                'String','Select random epochs in datasets','value',0,...
                'position',[35,300,300,30],'parent',obj.h_panel);

        end
        
        %get the parameters setting from the GUI
        function option=get_option(obj)
            option=get_option@CLW_generic(obj);
            %
            option.numepochs=str2num(get(obj.h_numepochs_edit,'string'));
            option.selectrandom=get(obj.h_selectrandom_chk,'value');
        end
        
        %set the GUI via the parameters setting
        function set_option(obj,option)
            set(obj.h_selectrandom_chk,'Value',option.xcrop_chk);
            set(obj.h_numepochs_edit,'String',num2str(option.numepochs));
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
            frag_code=[frag_code,'''numepochs'',',...
                num2str(option.numepochs),','];
            frag_code=[frag_code,'''selectrandom'',',...
                num2str(option.selectrandom),','];
            %%%
            str=get_Script@CLW_generic(obj,frag_code,option);
        end
        
        function GUI_update(obj,batch_pre)
            obj.virtual_filelist=batch_pre.virtual_filelist;
            obj.lwdataset=batch_pre.lwdataset;
        end
        
        function equalize_btn_pressed(obj,varargin)
            for i=1:length(obj.lwdataset)
                numepochs(i)=obj.lwdataset(i).header.datasize(1);
            end
            numepochs=min(numepochs);
            set(obj.h_numepochs_edit,'String',num2str(numepochs));
        end
        
        
    end
    
    methods (Static = true)
        function header_out= get_header(header_in,option)
            header_out=header_in;
            if ~isempty(option.suffix)
                header_out.name=[option.suffix,' ',header_out.name];
            end
            %
            header_out.datasize(1)=option.numepochs;
            %
            option.function=mfilename;
            header_out.history(end+1).option=option;
        end
        
        function lwdata_out=get_lwdata(lwdata_in,varargin)
            %default values
            option.numepochs=1;
            option.selectrandom=0;
            option.suffix='equ';
            option.is_save=0;
            option=CLW_check_input(option,{'numepochs','selectrandom',...
                'suffix','is_save'},varargin);
            inheader=lwdata_in.header;
            header=FLW_equalize_epochs.get_header(inheader,option);
            data=lwdata_in.data;
            %%%
            %epoch_idx
            if option.selectrandom==0
                %sequential
                epoch_idx=1:1:option.numepochs;
            else
                %random
                rnd_idx=rand(inheader.datasize(1),1);
                [~,b]=sort(rnd_idx);
                epoch_idx=b(1:option.numepochs);
            end
            %data
            data=data(epoch_idx,:,:,:,:,:);
            %adjust events
            if isfield(inheader,'events')
                if isempty(inheader.events)
                else
                    for i=1:length(inheader.events)
                        event_epoch_idx(i)=inheader.events(i).epoch;
                    end
                    new_events=[];
                    for i=1:length(epoch_idx)
                        a=find(event_epoch_idx==epoch_idx(i));
                        if isempty(a)
                        else
                            tp=inheader.events(a);
                            for j=1:length(tp)
                                tp(j).epoch=i;
                            end
                            new_events=[new_events tp];
                        end
                    end
                    header.events=new_events;
                end
            end
            %adjust epochdata
            if isfield(inheader,'epochdata')
                header.epochdata=inheader.epochdata(epoch_idx);
            end
            %store selected epochs in history
            header.history(end).option.selected_epochs=epoch_idx;
            %%%
            lwdata_out.header=header;
            lwdata_out.data=data;
            if option.is_save
                CLW_save(lwdata_out);
            end
        end
    end
end