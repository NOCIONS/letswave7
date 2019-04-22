function is_updated=GLW_update()
is_updated=0;
scrsz = get(0,'MonitorPositions');
scrsz=scrsz(1,:);
pos=[scrsz(3)/2,scrsz(4)/2,250,100];
fig=figure('Position',pos,'color',[0.93,0.93,0.93],...
    'name','Letswave Updating ','NumberTitle','off');
set(fig,'MenuBar','none');
set(fig,'DockControls','off');
update_btn=uicontrol('style','pushbutton','callback',@updateing,...
    'String','update','position',[25,10,200,50],'enable','off');
update_txt=uicontrol('style','text','backgroundcolor',[0.93,0.93,0.93],...
    'String','checking...','position',[5,70,240,20]);
pause(0.001);
url='https://raw.githubusercontent.com/NOCIONS/letswave7/master/res/version.txt';
try
    lw_version = str2num(urlread(url));
    temp=load('version.txt');
    if temp<lw_version
        set(update_txt,'string','There is new version for updating.');
        set(update_btn,'enable','on');
    else
        set(update_txt,'string','The currest version is already the latest.');
    end
catch
    set(update_txt,'string','Unable to access the website.');
end
pause(0.001);
set(fig,'windowstyle','modal');
uiwait(fig);

    function updateing(~,~)
        set(update_txt,'String','Downloading from server...');
        set(update_btn,'enable','off');
        pause(0.001);
        fullURL='https://github.com/NOCIONS/letswave7/archive/master.zip';
        st=which('letswave7.m');
        p=fileparts(st);
        filename=fullfile(p,'letswave7.zip');
        try
            urlwrite(fullURL,filename);
        catch
            set(update_txt,'String','Failed to download from server.');
            set(update_btn,'enable','on');
            return;
        end
        set(update_txt,'String','File downloaded. Updating Letswave...');
        pause(0.001);
        filenames=unzip(filename,p);
        filenames2=filenames;
        st2=[filesep 'letswave7-master'];
        st2_length=length(st2);
        for filepos=1:length(filenames)
            st=filenames{filepos};
            a=strfind(st,st2);
            st(a(end):a(end)+st2_length-1)=[];
            filenames2{filepos}=st;
        end
        for filepos=1:length(filenames)
            try
                [SUCCESS,~,MESSAGEID]=copyfile(filenames{filepos},filenames2{filepos});
                if SUCCESS==0
                    if ~strcmp(filenames2{filepos},[p,filesep])
                        disp(['Could not update : ' filenames2{filepos}]);
                    end
                end
            catch
                disp(['Could not update : ' filenames2{filepos}]);
                disp(MESSAGEID);
            end
        end
        rmdir([p filesep 'letswave7-master'],'s');
        delete([p filesep 'letswave7.zip']);
        set(update_txt,'String','Finished installing. Letswave will restart.');
        pause(0.5);
        is_updated=1;
        close(fig);
    end
end