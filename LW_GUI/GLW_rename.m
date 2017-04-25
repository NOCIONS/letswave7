function GLW_rename(option)
if length(option.file_str)==1
    fig_rename_single(option);
else
    fig_rename_multiple(option);
end
end

function fig_rename_single(option)
prompt = {'Rename the dataset:'};
dlg_title = 'Rename';
[~,n]=fileparts(option.file_str{1});
filename_pre={n};
filename_post = inputdlg(prompt,dlg_title,[1 length(n)+30],filename_pre);
if isempty(filename_post)
    return
end
CLW_dataset_rename(option.file_str{1},filename_pre{1},filename_post{1});
end

function fig_rename_multiple(option)
handles=[];
file_str=option.file_str;
GLW_rename_Init();
update_handles();
set(handles.fig,'WindowStyle','modal');
uiwait(handles.fig);


    function GLW_rename_Init()
        handles.fig=figure('Position',[100 50 800 600],'name','Rename',...
            'NumberTitle','off','Color',0.94*[1,1,1]);
        set(handles.fig,'MenuBar','none');
        set(handles.fig,'DockControls','off');
        uicontrol('style','text','string','From:','HorizontalAlignment','left',...
            'fontsize',14,'position',[150,570,80,28]);
        uicontrol('style','text','string','To:','HorizontalAlignment','left',...
            'fontsize',14,'position',[600,570,80,28]);
        uicontrol('style','text','string','Keywords:','HorizontalAlignment','left',...
            'position',[10,540,80,28]);
        handles.regExp_chx=uicontrol('style','checkbox','string','regular expression','HorizontalAlignment','left',...
            'position',[80,546,180,28]);
        handles.caseSen_chx=uicontrol('style','checkbox','string','case sensitive','HorizontalAlignment','left',...
            'position',[210,546,180,28]);
        uicontrol('style','text','string','Filename:','HorizontalAlignment','left',...
            'position',[10,480,80,28]);
        handles.keyword1=uicontrol('style','edit','string','','HorizontalAlignment','left',...
            'position',[15,520,370,28]);
        handles.keyword2=uicontrol('style','edit','string','','HorizontalAlignment','left',...
            'position',[415,520,370,28]);
        handles.filename1=uicontrol('style','listbox','string','','HorizontalAlignment','left',...
            'enable','on','value',[],'min',0,'max',2,...
            'position',[15,60,370,430]);
        handles.filename2=uicontrol('style','listbox','string','','HorizontalAlignment','left',...
            'enable','on','value',[],'min',0,'max',2,...
            'position',[415,60,370,430]);
        handles.OK_btn=uicontrol('style','pushbutton','string','Done','HorizontalAlignment','left',...
            'position',[5,5,790,50]);
        st=get(handles.fig,'children');
        for k=1:length(st)
            try
                set(st(k),'units','normalized');
            end
        end
        set(handles.keyword1,'Callback',{@(obj,events)update_handles()});
        set(handles.keyword2,'Callback',{@(obj,events)update_handles()});
        set(handles.OK_btn,'Callback',{@(obj,events)OK_btn_Callback()});
        
        
        set(handles.keyword1,'backgroundcolor',[1,1,1]);
        set(handles.keyword2,'backgroundcolor',[1,1,1]);
        set(handles.filename1,'backgroundcolor',[1,1,1]);
        set(handles.filename2,'backgroundcolor',[1,1,1]);
    end

    function OK_btn_Callback()
        k1=get(handles.keyword1,'string');
        k2=get(handles.keyword2,'string');
        r=get(handles.regExp_chx,'value');
        c=get(handles.caseSen_chx,'value');
        CLW_dataset_rename(option.file_str,k1,k2,r,c);
        close(handles.fig);
    end

    function update_handles()
        keyword1_str=get(handles.keyword1,'string');
        keyword2_str=get(handles.keyword2,'string');
        is_regExp=get(handles.regExp_chx,'value');
        is_caseSen=get(handles.caseSen_chx,'value');
        filename1_str={};
        filename2_str={};
        for k=1:length(file_str)
            file_name=file_str{k}(1:end-4);
            if isempty(keyword1_str)
                is_changed=0;
            else
                endIndex=[];
                switch(is_regExp)
                    case 0
                        if is_caseSen
                            startIndex= strfind(file_name, keyword1_str);
                        else
                            startIndex= strfind(lower(file_name), lower(keyword1_str));
                        end
                    case 1
                        if is_caseSen
                            [startIndex,endIndex] = regexp(file_name, keyword1_str);
                        else
                            [startIndex,endIndex] = regexpi(file_name, keyword1_str);
                        end
                end
                if isempty(startIndex)
                    is_changed=0;
                else
                    is_changed=1;
                    startIndex=startIndex(1);
                    if isempty(endIndex)
                        endIndex=startIndex+length(keyword1_str)-1;
                    else
                        endIndex=endIndex(1);
                    end
                end
            end
            switch(file_str{k}(end))
                case '6'
                    filename1_str{k}='<HTML>';
                case {'4','5'}
                    filename1_str{k}='<HTML><body color="blue">';
            end
            if(is_changed)
                filename2_str{k}=[filename1_str{k},file_name(1:startIndex-1),...
                    '<font color="red"><b>', regexprep(file_name(startIndex:endIndex),keyword1_str,keyword2_str),'</b></font>',...
                    file_name(endIndex+1:end)];
                filename1_str{k}=[filename1_str{k},file_name(1:startIndex-1),...
                    '<font color="red"><b>',file_name(startIndex:endIndex),'</b></font>',...
                    file_name(endIndex+1:end)];
            else
                filename2_str{k}=[filename1_str{k},file_name];
                filename1_str{k}=[filename1_str{k},file_name];
            end
            switch(file_str{k}(end))
                case {'4','5'}
                    filename1_str{k}=[filename1_str{k},file_str{k}(end-3:end)];
                    filename2_str{k}=[filename2_str{k},file_str{k}(end-3:end)];
            end
        end
        filename1_str=strrep(filename1_str,' ','&nbsp;');
        filename2_str=strrep(filename2_str,' ','&nbsp;');
        set(handles.filename1,'string',filename1_str);
        set(handles.filename2,'string',filename2_str);
        set(handles.filename1,'value',[]);
        set(handles.filename2,'value',[]);
    end
end