classdef FLW_import_mat
    properties
        h_fig;
        h_var_list;
        h_refresh_btn;
        h_load_btn;
        h_script_btn;
        h_unit_pop;
        h_xstart_edit;
        h_xstep_edit;
        h_xunit_pop;
        h_ystart_edit;
        h_ystep_edit;
        h_yunit_pop;
        h_dimension1_pop;
        h_dimension2_pop;
        h_dimension3_pop;
        h_dimension4_pop;
        h_process_btn;
        h_parent;
    end
    
    methods
        function obj = FLW_import_mat(varargin)
            if ~isempty(varargin)
                obj.h_parent=varargin{1};
            else
                obj.h_parent=[];
            end
            obj=obj.init_handles();
            obj=obj.update_handles();
            
            set(obj.h_dimension1_pop,'Callback',@obj.update_dimesion);
            set(obj.h_dimension2_pop,'Callback',@obj.update_dimesion);
            set(obj.h_dimension3_pop,'Callback',@obj.update_dimesion);
            set(obj.h_dimension4_pop,'Callback',@obj.update_dimesion);
            set(obj.h_var_list,'Callback',@obj.var_list_chg);
            set(obj.h_refresh_btn,'Callback',@obj.update_handles);
            set(obj.h_load_btn,'Callback',@obj.load);
            set(obj.h_process_btn,'Callback',@obj.process);
            set(obj.h_script_btn,'Callback',@obj.get_script);
            set(obj.h_fig,'windowstyle','modal');
            uiwait(obj.h_fig);
        end
        
        function obj=init_handles(obj)
            obj.h_fig=figure('name','Import mat variable',...
                'NumberTitle','off','color',0.94*[1,1,1]);
            set(obj.h_fig,'WindowStyle','modal');
            pos=get(obj.h_fig,'Position');
            pos(3:4)=[600 510];
            scrsz = get(0,'MonitorPositions');
            scrsz=scrsz(1,:);
            if pos(1)+pos(3)>scrsz(3)
                pos(1)=(scrsz(3)-pos(3))/2;
            end
            if pos(2)+pos(4)+100>scrsz(4)
                pos(2)=(scrsz(4)-pos(4)-100)/2;
            end
            set(obj.h_fig,'Position',pos);
            set(obj.h_fig,'MenuBar','none');
            set(obj.h_fig,'DockControls','off');
            uicontrol('style','text','string',...
                'Select workspace variable(s) to import:','HorizontalAlignment','left',...
                'position',[10,470,380,28]);
            obj.h_var_list=uicontrol('style','listbox','string','',...
                'HorizontalAlignment','left',...
                'position',[15,10,250,460],'value',[],'max',10);
            obj.h_refresh_btn=uicontrol('style','pushbutton',...
                'string','Refresh','HorizontalAlignment','left',...
                'position',[270,430,320,40]);
            obj.h_load_btn=uicontrol('style','pushbutton',...
                'string','Load mat-file into workspace','HorizontalAlignment','left',...
                'position',[270,385,320,40]);
            icon=load('icon.mat');
            obj.h_script_btn=uicontrol('style','pushbutton',...
                'position',[550,345,40,40],'CData',icon.icon_script);
            uicontrol('style','text','string','Unit:',...
                'HorizontalAlignment','left',...
                'position',[340,307,150,40]);
            obj.h_unit_pop=uicontrol('style','popup','string', ...
                {'amplitude','power','phase','complex'},'HorizontalAlignment','left',...
                'position',[375,310,150,40]);
            
            uicontrol('style','text','string','X Start:','HorizontalAlignment','right',...
                'position',[280,270,50,40]);
            obj.h_xstart_edit=uicontrol('style','edit','string','0',...
                'HorizontalAlignment','left',...
                'position',[340,289,80,30]);
            uicontrol('style','text','string','X Step:','HorizontalAlignment','right',...
                'position',[280,234,50,40]);
            obj.h_xstep_edit=uicontrol('style','edit','string','1',...
                'HorizontalAlignment','left',...
                'position',[340,250,80,30]);
            uicontrol('style','text','string','X Unit:','HorizontalAlignment','right',...
                'position',[280,208,50,30]);
            obj.h_xunit_pop=uicontrol('style','popup','string', {'time','frequency'},...
                'HorizontalAlignment','left',...
                'position',[334,209,92,32]);
            
            uicontrol('style','text','string','Y Start:','HorizontalAlignment','right',...
                'position',[440,270,50,40]);
            obj.h_ystart_edit=uicontrol('style','edit','string','0',...
                'HorizontalAlignment','left',...
                'position',[500,289,80,30]);
            uicontrol('style','text','string','Y Step:','HorizontalAlignment','right',...
                'position',[440,234,50,40]);
            obj.h_ystep_edit=uicontrol('style','edit','string','1',...
                'HorizontalAlignment','left',...
                'position',[500,250,80,30]);
            uicontrol('style','text','string','Y Unit:','HorizontalAlignment','right',...
                'position',[440,208,50,30]);
            obj.h_yunit_pop=uicontrol('style','popup','string', ...
                {'time','frequency'},'HorizontalAlignment','left',...
                'position',[494,209,92,32],'value',2);
            
            
            uicontrol('style','text','string','Dimension 1:',...
                'HorizontalAlignment','left',...
                'position',[280,164,100,30]);
            obj.h_dimension1_pop=uicontrol('style','popup',...
                'string', {'X','Y','Channels','Epochs'},...
                'HorizontalAlignment','left','position',[374,165,210,32],...
                'value',1,'UserData',1);
            
            
            uicontrol('style','text','string','Dimension 2:',...
                'HorizontalAlignment','left',...
                'position',[280,134,100,30]);
            obj.h_dimension2_pop=uicontrol('style','popup',...
                'string', {'X','Y','Channels','Epochs'},...
                'HorizontalAlignment','left','position',[374,135,210,32],...
                'value',2,'UserData',2);
            
            
            uicontrol('style','text','string','Dimension 3:',...
                'HorizontalAlignment','left',...
                'position',[280,104,100,30]);
            obj.h_dimension3_pop=uicontrol('style','popup',...
                'string', {'X','Y','Channels','Epochs'},...
                'HorizontalAlignment','left','position',[374,105,210,32],...
                'value',3,'UserData',3);
            
            
            uicontrol('style','text','string','Dimension 4:',...
                'HorizontalAlignment','left',...
                'position',[280,74,100,30]);
            obj.h_dimension4_pop=uicontrol('style','popup',...
                'string', {'X','Y','Channels','Epochs'},...
                'HorizontalAlignment','left','position',[374,75,210,32],...
                'value',4,'UserData',4);
            
            obj.h_process_btn=uicontrol('style','pushbutton','string','Import',...
                'HorizontalAlignment','left',...
                'position',[270,10,320,60]);
           set(obj.h_var_list, 'backgroundcolor',[1,1,1]);
           set(obj.h_unit_pop, 'backgroundcolor',[1,1,1]);
           set(obj.h_xstart_edit, 'backgroundcolor',[1,1,1]);
           set(obj.h_xstep_edit, 'backgroundcolor',[1,1,1]);
           set(obj.h_xunit_pop, 'backgroundcolor',[1,1,1]);
           set(obj.h_ystart_edit, 'backgroundcolor',[1,1,1]);
           set(obj.h_ystep_edit, 'backgroundcolor',[1,1,1]);
           set(obj.h_yunit_pop, 'backgroundcolor',[1,1,1]);
           set(obj.h_dimension1_pop, 'backgroundcolor',[1,1,1]);
           set(obj.h_dimension2_pop, 'backgroundcolor',[1,1,1]);
           set(obj.h_dimension3_pop, 'backgroundcolor',[1,1,1]);
           set(obj.h_dimension4_pop, 'backgroundcolor',[1,1,1]);
           
           st=get(obj.h_fig,'children');
           for k=1:length(st)
               try
                   set(st(k),'units','normalized');
               end
           end
           
        end
        
        function obj=load(obj,varargin)
            st={};
            [st,pathname]=uigetfile('*.mat;*.MAT','select datafiles','MultiSelect','on');
            filename=[];
            if st==0
                return;
            end
            if ~isempty(st)
                if ~iscell(st)
                    st2{1}=st;
                    st=st2;
                end
                for i=1:length(st)
                    filename{i}=[pathname,st{i}];
                end
            end
            if ~isempty(filename)
                for i=1:length(filename)
                    st=['load ''' filename{i} ''''];
                    evalin('base',st);
                end
                obj=obj.update_handles();
            end
        end
        
        function obj=process(obj,varargin)
            set(obj.h_process_btn,'Enable','off');
            set(obj.h_process_btn,'String','Processing...');
            pause(0.001)
            option=obj.get_option();
            if isempty(option)
                return;
            end
            st=get(obj.h_var_list,'String');
            v=get(obj.h_var_list,'Value');
            for k=1:length(v)
                option.filename=st{v(k)};
                matdata=evalin('base',option.filename);
                obj.get_lwdata(matdata,option);
                if ~isempty(obj.h_parent)
                    set(obj.h_parent,'userdata',1);
                end
            end
            set(obj.h_process_btn,'String','Done');
            set(obj.h_process_btn,'Enable','off');
        end
        
        function obj=update_handles(obj,varargin)
            vars = evalin('base','whos');
            idx=~cellfun('isempty',strfind({vars.class},'int'));
            idx=idx+strcmp({vars.class},'single');
            idx=idx+strcmp({vars.class},'double');
            idx=(idx>0).*(cellfun('length',{vars.size})<5);
            idx=idx.*cellfun(@(x)sum(x==0)==0,{vars.size});
            idx=find(idx);
            v=get(obj.h_var_list,'Value');
            str_selected={};
            if isempty(v)
                v=1;
                set(obj.h_var_list,'Value',v);
            else
                str_selected=get(obj.h_var_list,'String');
                str_selected=str_selected{v};
            end
            set(obj.h_var_list,'String',{vars(idx).name});
            set(obj.h_var_list,'UserData',{vars(idx).size});
            [~,reference_idx] = intersect({vars(idx).name},str_selected,'stable');
            if isempty(reference_idx) && ~isempty(idx)
                set(obj.h_var_list,'Value',1);
            else
                set(obj.h_var_list,'Value',reference_idx);
            end
            obj.var_list_chg();
            
            set(obj.h_process_btn,'String','Import');
            set(obj.h_process_btn,'Enable','on');
        end
        
        function var_list_chg(obj,varargin)
            v=get(obj.h_var_list,'value');
            set(obj.h_dimension1_pop,'Enable','off');
            set(obj.h_dimension2_pop,'Enable','off');
            set(obj.h_dimension3_pop,'Enable','off');
            set(obj.h_dimension4_pop,'Enable','off');
            
            set(obj.h_xstart_edit,'enable','off');
            set(obj.h_xstep_edit,'enable','off');
            set(obj.h_xunit_pop,'enable','off');
            set(obj.h_ystart_edit,'enable','off');
            set(obj.h_ystep_edit,'enable','off');
            set(obj.h_yunit_pop,'enable','off');
            if isempty(v)
                return;
            end
            var_size=get(obj.h_var_list,'UserData');
            var_size=var_size{v(1)};
            set(obj.h_dimension1_pop,'Enable','on');
            switch length(var_size)
                case 2
                    set(obj.h_dimension2_pop,'Enable','on');
                case 3
                    set(obj.h_dimension2_pop,'Enable','on');
                    set(obj.h_dimension3_pop,'Enable','on');
                case 4
                    set(obj.h_dimension2_pop,'Enable','on');
                    set(obj.h_dimension3_pop,'Enable','on');
                    set(obj.h_dimension4_pop,'Enable','on');
            end
            order=1:4;
            order(1)= get(obj.h_dimension1_pop,'Value');
            order(2)= get(obj.h_dimension2_pop,'Value');
            order(3)= get(obj.h_dimension3_pop,'Value');
            order(4)= get(obj.h_dimension4_pop,'Value');
            if find(order(1:length(var_size))==1)
                set(obj.h_xstart_edit,'enable','on');
                set(obj.h_xstep_edit,'enable','on');
                set(obj.h_xunit_pop,'enable','on');
            end
            if find(order(1:length(var_size))==2)
                set(obj.h_ystart_edit,'enable','on');
                set(obj.h_ystep_edit,'enable','on');
                set(obj.h_yunit_pop,'enable','on');
            end
            set(obj.h_process_btn,'String','Import');
            set(obj.h_process_btn,'Enable','on');
        end
        
        function update_dimesion(obj,varargin)
            k1=get(varargin{1},'UserData');
            v=get(varargin{1},'Value');
            order=1:4;
            order(1)= get(obj.h_dimension1_pop,'Value');
            order(2)= get(obj.h_dimension2_pop,'Value');
            order(3)= get(obj.h_dimension3_pop,'Value');
            order(4)= get(obj.h_dimension4_pop,'Value');
            k2= setdiff(find(order==v),k1);
            if ~isempty(k2)
                order(k2)=setdiff(1:4,order);
                switch k2
                    case 1
                        set(obj.h_dimension1_pop,'Value',order(1));
                    case 2
                        set(obj.h_dimension2_pop,'Value',order(2));
                    case 3
                        set(obj.h_dimension3_pop,'Value',order(3));
                    case 4
                        set(obj.h_dimension4_pop,'Value',order(4));
                end
                
                v=get(obj.h_var_list,'value');
                var_size=get(obj.h_var_list,'UserData');
                var_size=var_size{v};
                if find(order(1:length(var_size))==1)
                    set(obj.h_xstart_edit,'enable','on');
                    set(obj.h_xstep_edit,'enable','on');
                    set(obj.h_xunit_pop,'enable','on');
                else
                    set(obj.h_xstart_edit,'enable','off');
                    set(obj.h_xstep_edit,'enable','off');
                    set(obj.h_xunit_pop,'enable','off');
                end
                if find(order(1:length(var_size))==2)
                    set(obj.h_ystart_edit,'enable','on');
                    set(obj.h_ystep_edit,'enable','on');
                    set(obj.h_yunit_pop,'enable','on');
                else
                    set(obj.h_ystart_edit,'enable','off');
                    set(obj.h_ystep_edit,'enable','off');
                    set(obj.h_yunit_pop,'enable','off');
                end
            end
            set(obj.h_process_btn,'String','Import');
            set(obj.h_process_btn,'Enable','on');
        end
        
        function option=get_option(obj)
            v=get(obj.h_var_list,'Value');
            if isempty(v)
                option=[];
                uiwait(msgbox('Please select atleast one variable','Warning','modal'));
                return;
            end
            
            st=get(obj.h_var_list,'String');
            option.filename=st{v(1)};
            
            option.dimension_descriptors={'X','Y','channels','epochs'};
            order=1:4;
            order(1)= get(obj.h_dimension1_pop,'Value');
            order(2)= get(obj.h_dimension2_pop,'Value');
            order(3)= get(obj.h_dimension3_pop,'Value');
            order(4)= get(obj.h_dimension4_pop,'Value');
            option.dimension_descriptors={option.dimension_descriptors{order}};
            
            var_size=get(obj.h_var_list,'UserData');
            var_size=var_size{v(1)};
            temp=find(order==1);
            if(length(var_size)<temp|| var_size(temp)<=1)
                option=[];
                uiwait(msgbox({'X must be selected in the Dimension,',...
                'And there must be more than one point in Dimension X'},...
                'Warning','modal'));
                return;
            end
                
            st=get(obj.h_unit_pop,'String');
            option.unit=st{get(obj.h_unit_pop,'Value')};
            
            st=get(obj.h_xunit_pop,'String');
            option.xunit=st{get(obj.h_xunit_pop,'Value')};
            option.xstart=str2num(get(obj.h_xstart_edit,'String'));
            option.xstep=str2num(get(obj.h_xstep_edit,'String'));
            
            st=get(obj.h_yunit_pop,'String');
            option.yunit=st{get(obj.h_yunit_pop,'Value')};
            option.ystart=str2num(get(obj.h_ystart_edit,'String'));
            option.ystep=str2num(get(obj.h_ystep_edit,'String'));
            
            option.is_save=1;
        end
        
        function get_script(obj,varargin)
            option=get_option(obj);
            if isempty(option)
                return;
            end
            script={};
            
            script{end+1}='LW_init();';
            script{end+1}=['option.dimension_descriptors={'''...
                ,option.dimension_descriptors{1},''','''...
                ,option.dimension_descriptors{2},''','''...
                ,option.dimension_descriptors{3},''','''...
                ,option.dimension_descriptors{4},'''};'];
            script{end+1}=['option.unit=''',option.unit,''';'];
            script{end+1}=['option.xunit=''',option.xunit,''';'];
            script{end+1}=['option.yunit=''',option.yunit,''';'];
            script{end+1}=['option.xstart=',num2str(option.xstart),';'];
            script{end+1}=['option.xstep=',num2str(option.xstep),';'];
            script{end+1}=['option.ystart=',num2str(option.ystart),';'];
            script{end+1}=['option.ystep=',num2str(option.ystep),';'];
            script{end+1}='option.is_save=1;';
            script{end+1}='';
            
            st=get(obj.h_var_list,'String');
            v=get(obj.h_var_list,'Value');
            for k=1:length(v)
                script{end+1}=['option.filename=''',st{v(k)},''';'];
                script{end+1}=['FLW_import_mat.get_lwdata(',st{v(k)},',option);'];
                script{end+1}='';
            end
            
            CLW_show_script(script);
            
        end
    end
    
    methods (Static = true)
        function lwdata_out=get_lwdata(matdata,varargin)
            option.dimension_descriptors={'epochs','channels','Y','X'};
            option.unit='amplitude';
            option.xunit='time';
            option.yunit='frequency';
            option.xstart=0;
            option.ystart=0;
            option.xstep=1;
            option.ystep=1;
            option.is_save=0;
            option.filename='mat';
            option=CLW_check_input(option,{'dimension_descriptors','unit',...
                'xunit','yunit','xstart','ystart',...
                'xstep','ystep','filename','is_save'},varargin);
            
            header.name=option.filename;
            header.tags={};
            header.history=[];
            header.datasize=[];
            header.xstart=option.xstart;
            header.ystart=option.ystart;
            header.zstart=0;
            header.xstep=option.xstep;
            header.ystep=option.ystep;
            header.zstep=1;
            
            dimlist={'epochs','channels','index','Z','Y','X'};
            dim_labels=option.dimension_descriptors;
            for i=1:length(dim_labels)
                tp=find(strcmpi(dim_labels{i},dimlist));
                a(i)=tp;
            end
            dim_order=[0 0 0 0 0 0];
            for i=1:length(a)
                dim_order(a(i))=i;
            end
            tp=find(dim_order==0);
            if ~isempty(tp)
                for i=1:length(tp)
                    dim_order(tp(i))=length(a)+i;
                end
            end
            data=permute(single(matdata),dim_order);
            header.datasize=size(data);
            
            
            filetype=option.unit;
            filetype=[option.xunit '_' filetype];
            if header.datasize(5)>1
                filetype=[option.yunit '_' filetype];
            end
            header.filetype=filetype;
            
            chanloc.labels='';
            chanloc.topo_enabled=0;
            chanloc.SEEG_enabled=0;
            for chanpos=1:header.datasize(2)
                chanloc.labels=['C' num2str(chanpos)];
                header.chanlocs(chanpos)=chanloc;
            end
            header.events=[];
            
            lwdata_out.header=header;
            lwdata_out.data=data;
            
            if option.is_save
                CLW_save(lwdata_out);
            end
            if nargout>0
                lwdata_out.data=double(lwdata_out.data);
            end
        end
    end
end