function FLW_design()
close all;clc;
FLW_name='FLW_marker_selection';

h=findall(0,'tag','FLW_design');
if ~isempty(h)
    clc;
    close(h);
end

handle.fig = figure('position',[100,100,520,605],'Resize','off',...
    'name','Letswave Batch','numbertitle','off');
scrsz = get(0,'MonitorPositions');
scrsz=scrsz(1,:);
pos=get(handle.fig,'Position');
pos(2)=(scrsz(4)-(pos(2)+pos(4)))/2;
if pos(2)+pos(4)>scrsz(4)-60
    pos(2)=scrsz(4)-60-pos(4);
end
set(handle.fig,'Position',pos);
set(handle.fig,'MenuBar','none');
set(handle.fig,'DockControls','off');
icon=load('icon.mat');
handle.toolbar = uitoolbar(handle.fig);

handle.toolbar_open = uipushtool(handle.toolbar);
set(handle.toolbar_open,'CData',icon.icon_open);
handle.menu = uimenu(handle.fig,'Label','test');


handle.path_edit=uicontrol('style','edit','String',pwd,'userdata',pwd,...
    'HorizontalAlignment','left','position',[3,578,487,25]);
handle.path_btn=uicontrol('style','pushbutton','CData',icon.icon_open_path,...
    'position',[493,578,25,25]);

handle.tab_panel=uipanel(handle.fig,'BorderType','none',...
    'units','pixels','position',[1,45,100,528]);
eval(['batch{1}=',FLW_name,'(handle);']);
end
