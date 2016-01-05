function FLW_design()
FLW_name='FLW_FFT';

h=findall(0,'tag','FLW_design');
if ~isempty(h)
    clc;
    close(h);
end
handle.fig = figure('position',[100,100,500,605],'Resize','off',...
    'name','FLW_design','numbertitle','off','tag','FLW_design');
set(handle.fig,'MenuBar','none');
set(handle.fig,'DockControls','off');
icon=load('icon.mat');
handle.toolbar = uitoolbar(handle.fig);

handle.toolbar_open = uipushtool(handle.toolbar);
set(handle.toolbar_open,'CData',icon.icon_open);
handle.menu = uimenu(handle.fig,'Label','test');

handle.path_edit=uicontrol('style','edit',...
    'HorizontalAlignment','left','position',[2,578,470,25]);
handle.path_btn=uicontrol('style','pushbutton','String','...',...
    'position',[475,578,25,25]);
handle.tabgp = uitabgroup(handle.fig,'TabLocation','left',...
    'units','pixels','position',[1,1,499,570]);
eval(['batch{1}=',FLW_name,'(handle.tabgp);']);
end
