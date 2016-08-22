function FLW_design()
close all;
FLW_name='FLW_ttest';

h=findall(0,'tag','FLW_design');
if ~isempty(h)
    clc;
    close(h);
end
 handle.fig = figure('position',[100,100,520,605],'Resize','off',...
            'name','Letswave Batch','numbertitle','off');
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
