function GLW_update(~)
scrsz = get(0,'ScreenSize');
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
url='https://raw.githubusercontent.com/NOCIONS/letswave7/master/resources/version.txt';
try
    lw_version = str2num(urlread(url));
    handles.version_checkked=1;
    temp=load('version.txt');
    if temp<lw_version
        set(update_txt,'string','There is new version for updating.','enable','on');
    else
        set(update_txt,'string','The currest version is already the latest.');
    end
catch
    set(update_txt,'string','Unable to access the website.');
end
end

function updateing()
disp('123');
% set(handles.current_text,'String','Downloading from server...');
% drawnow;
% fullURL=['https://github.com/NOCIONS/letswave6/archive/master.zip'];
% st=which('letswave6.m');
% [p n e]=fileparts(st);
% filename=[p filesep 'letswave6.zip'];
% try
%     urlwrite(fullURL,filename);
% catch
%     disp('Failed to download from server.');
% end;
% set(handles.current_text,'String','File downloaded. Updating Letswave...');
% filenames=unzip(filename,p);
% filenames2=filenames;
% st2=[filesep 'letswave6-master'];
% st2_length=length(st2);
% for filepos=1:length(filenames);
%     st=filenames{filepos};
%     a=strfind(st,st2);
%     st(a(end):a(end)+st2_length-1)=[];
%     filenames2{filepos}=st;
% end;
% for filepos=1:length(filenames);
%     try
%         [SUCCESS,MESSAGE,MESSAGEID]=copyfile(filenames{filepos},filenames2{filepos});
%         if SUCCESS==0;
%             disp(['Could not update : ' filenames2{filepos}]);
%         end;
%     catch
%         disp(['Could not update : ' filenames2{filepos}]);
%         disp(MESSAGEID);
%     end;
% end;
% rmdir([p filesep 'letswave6-master'],'s');
% delete([p filesep 'letswave6.zip']);
% set(handles.current_text,'String','Finished installing.');
end