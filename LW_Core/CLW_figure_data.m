function inputfiles_new=CLW_figure_data(inputfiles)
%close all;clc;
% inputfiles={'/Users/huanggan/Documents/MATLAB/letswave_bank/test/bl cwt butt avg ep_s1 continuous EEG LEPs S06.lw6';...
%     '/Users/huanggan/Documents/MATLAB/letswave_bank/test/bl cwt butt avg ep_s4 continuous EEG LEPs S06.lw6'};
inputfiles_new=inputfiles;
icon=load('icon.mat');
scrsz = get(0,'MonitorPositions');
scrsz=scrsz(1,:);
w=min(scrsz(3),1000);
h=min(length(inputfiles)*24+160,scrsz(4)*2/3);
pos=[(scrsz(3)-w)/2,(scrsz(4)-h)/2,w,h];
fig = figure('name','LW_Table','numbertitle','off','MenuBar','none','DockControls','off','position',pos);
row_selected_idx=[];
col_headers={'old','new'};
pos=get(fig,'position');
tab=uitable(fig,'position',[1,40,pos(3),pos(4)-40],'Data',[inputfiles(:),inputfiles(:)],'ColumnName',col_headers);
btn_add=uicontrol(fig,'style','pushbutton','position',[1,1,40,39],'TooltipString','add','CData',icon.icon_dataset_add);
btn_del=uicontrol(fig,'style','pushbutton','position',[1,1,40,39],'TooltipString','del','CData',icon.icon_dataset_del);
btn_edit=uicontrol(fig,'style','pushbutton','position',[1,1,40,39],'string','Select');
btn_OK=uicontrol(fig,'style','pushbutton','position',[1,1,40,39],'string','OK');
btn_Cancel=uicontrol(fig,'style','pushbutton','position',[1,1,40,39],'string','Cancel');
set(tab,'ColumnEditable', [false,true])
fig_resize();
set(tab,'CellSelectionCallback',@tab_chn_callback);
set(tab,'cellEditCallback',@tab_edt_callback);
set(btn_add,'callback',@btn_add_callback);
set(btn_del,'callback',@btn_del_callback);
set(btn_edit,'callback',@btn_edit_callback);
set(btn_OK,'callback',@btn_OK_callback);
set(btn_Cancel,'callback',@btn_Cancel_callback);
set(fig,'CloseRequestFcn',@btn_Cancel_callback);
try
    set(fig,'SizeChangedFcn',@fig_resize);
catch
    set(fig,'resizefcn',@fig_resize);
end
set(fig,'WindowStyle','modal');
uiwait(fig);

    function tab_update()
        table_data=[];
        for k=1:length(inputfiles)
            table_data{k,1}=inputfiles{k};
        end
        for k=1:length(inputfiles_new)
            table_data{k,2}=inputfiles_new{k};
        end
        set(tab,'Data',table_data);
        drawnow;
    end
    function tab_edt_callback(~, eventdata)
        str=eventdata.NewData;
        [p, n]=fileparts(fullfile(str));
        str=fullfile(p,[n,'.lw6']);
        if exist(str,'file')==2
            inputfiles_new{eventdata.Indices(1,1)}= str;
        else
            inputfiles_new{eventdata.Indices(1,1)}= eventdata.PreviousData;
        end
        tab_update();
    end
    function tab_chn_callback(~, eventdata)
        row_selected_idx = sort(eventdata.Indices(:,1));
    end

    function btn_add_callback(~,~)
        [FileName,PathName] = GLW_getfile();
        if(PathName~=0)
            for k=1:length(FileName)
                inputfiles_new(end+1)=fullfile(PathName,FileName(k));
            end
            tab_update();
        end
    end
    function btn_del_callback(~,~)
        row_selected_idx(row_selected_idx>length(inputfiles_new))=[];
        inputfiles_new(row_selected_idx)=[];
        tab_update();
    end
    function btn_edit_callback(~,~)
        idx=min(row_selected_idx);
        if ~isempty(idx) && idx<=length(inputfiles_new)
            [FileName,PathName] = GLW_getfile();
            if(PathName~=0)
                inputfiles_new(idx)=fullfile(PathName,FileName(1));
                tab_update();
            end
        end
    end
    function btn_OK_callback(~,~)
        if isempty(inputfiles_new)
            warndlg('No datasets selected!','Warning','modal');
        else
            closereq;
        end
    end
    function btn_Cancel_callback(~,~)
        inputfiles_new=[];
        closereq;
    end

    function fig_resize(~,~)
        fig_pos=get(fig,'position');
        btn_h=40;
        btn_w=40;
        if fig_pos(3)<(btn_h+5)*5
            fig_pos(3)=(btn_h+5)*5;
        end
        fig_pos(4)=max(fig_pos(4),120);
        btn_w=min((fig_pos(3)-(btn_h+5)*2)/4+5,120);
        tab_pos=[1,btn_h,fig_pos(3),fig_pos(4)-btn_h];
        
        set(fig,'position',fig_pos);
        set(tab,'position',tab_pos);
        set(tab,'ColumnWidth',{tab_pos(3)/2-18,tab_pos(3)/2-18})
        set(btn_add,'position',      [tab_pos(3)-(btn_w+5)*3-(btn_h+5)*2,1,btn_h,btn_h]);
        set(btn_del,'position',    [tab_pos(3)-(btn_w+5)*3-(btn_h+5)*1,1,btn_h,btn_h]);
        
        set(btn_edit,'position',    [tab_pos(3)-(btn_w+5)*3,1,btn_w,btn_h]);
        set(btn_OK,'position',      [tab_pos(3)-(btn_w+5)*2,1,btn_w,btn_h]);
        set(btn_Cancel,'position',  [tab_pos(3)-(btn_w+5),1,btn_w,btn_h]);
    end
end
