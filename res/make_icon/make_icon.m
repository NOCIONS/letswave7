clc;clear
icon = fullfile('icon_split.png');
icon_split= double(imread(icon))/255;
icon_split(1,:,:)=NaN;
icon_split(:,1,:)=NaN;

icon = fullfile('icon_polarity.png');
icon_polarity= double(imread(icon))/255;
icon_polarity(icon_polarity==1)=NaN;

icon = fullfile('icon_shade.png');
icon_shade= double(imread(icon))/255;
icon_shade(icon_shade==1)=NaN;

icon = fullfile('icon_cursor.png');
icon_cursor= double(imread(icon))/255;
icon_cursor(icon_cursor==1)=NaN;

icon = fullfile('icon_line.png');
icon_line= double(imread(icon))/255;
icon_line(icon_line==1)=NaN;

icon = fullfile('icon_stem.png');
icon_stem= double(imread(icon))/255;
icon_stem(icon_stem==1)=NaN;

icon = fullfile('icon_stairs.png');
icon_stairs= double(imread(icon))/255;
icon_stairs(icon_stairs==1)=NaN;

icon = fullfile('icon_legend.png');
icon_legend= double(imread(icon))/255;
icon_legend(icon_legend==1)=NaN;

icon = fullfile('icon_title.png');
icon_title= double(imread(icon))/255;
icon_title(icon_title==1)=NaN;

icon = fullfile('icon_topo.png');
icon_topo= double(imread(icon))/255;
%icon_topo(icon_topo==1)=NaN;

icon = fullfile('icon_head.png');
icon_head= double(imread(icon))/255;
%icon_head(icon_head==1)=NaN;

icon = fullfile('icon_dataset_add.png');
icon_dataset_add= double(imread(icon))/255;
icon_dataset_add(icon_dataset_add==1)=NaN;

icon = fullfile('icon_dataset_del.png');
icon_dataset_del= double(imread(icon))/255;
icon_dataset_del(icon_dataset_del==1)=NaN;

icon = fullfile('icon_dataset_down.png');
icon_dataset_down= double(imread(icon))/255;
icon_dataset_down(icon_dataset_down==1)=NaN;

icon = fullfile('icon_dataset_up.png');
icon_dataset_up= double(imread(icon))/255;
icon_dataset_up(icon_dataset_up==1)=NaN;

icon = fullfile('icon_run.png');
icon_run= double(imread(icon))/255;
icon_run(icon_run==0)=NaN;

icon = fullfile('icon_open.png');
icon_open= double(imread(icon))/255;
icon_open(icon_open==0)=NaN;

icon = fullfile('icon_script.png');
icon_script= double(imread(icon))/255;
icon_script(icon_script==0)=NaN;

icon = fullfile('icon_save.png');
icon_save= double(imread(icon))/255;
icon_save(icon_save==0)=NaN;

icon = fullfile('icon_delete.png');
icon_delete= double(imread(icon))/255;
icon_delete(icon_delete==0)=NaN;

icon = fullfile('icon_import.png');
icon_import= double(imread(icon))/255;
icon_import(icon_import==0)=NaN;

icon = fullfile('icon_close.png');
icon_close= double(imread(icon))/255;
icon_close(icon_close==0)=NaN;

icon = fullfile('icon_stop.png');
icon_stop= double(imread(icon))/255;
icon_stop(icon_stop==0)=NaN;

icon = fullfile('icon_open_path.png');
icon_open_path= double(imread(icon))/255;
icon_open_path(icon_open_path==1)=NaN;

icon = fullfile('icon_refresh.png');
icon_refresh= double(imread(icon))/255;
icon_refresh(icon_refresh==1)=NaN;

icon = fullfile('icon_undo.png');
icon_undo= double(imread(icon))/255;
icon_undo(icon_undo==1)=NaN;
icon_redo=icon_undo(:,16:-1:1,:);

icon = fullfile('icon_lock.png');
icon_lock= double(imread(icon))/255;
icon_lock(icon_lock==0)=NaN;

icon = fullfile('icon_unlock.png');
icon_unlock= double(imread(icon))/255;
icon_unlock(icon_unlock==0)=NaN;

icon = fullfile('icon_sendtoworkspace.png');
icon_sendtoworkspace= double(imread(icon))/255;
icon_sendtoworkspace(icon_sendtoworkspace==1)=NaN;

icon = fullfile('icon_loadfromworkspace.png');
icon_loadfromworkspace= double(imread(icon))/255;
icon_loadfromworkspace(icon_loadfromworkspace==1)=NaN;

icon = fullfile('icon_recovery.png');
icon_recovery= double(imread(icon))/255;
icon_recovery(icon_recovery==1)=NaN;

icon = fullfile('icon_rename.png');
icon_rename= double(imread(icon))/255;
icon_rename(icon_rename==1)=NaN;

icon = fullfile('icon_data_manage.png');
icon_data_manage= double(imread(icon))/255;
icon_data_manage(icon_data_manage==0)=NaN;

icon = fullfile('icon_figure_save.png');
icon_figure_save= double(imread(icon))/255;
icon_figure_save(icon_figure_save==0)=NaN;



icon = fullfile('icon_figure.png');
icon_figure= double(imread(icon))/255;
icon_figure(icon_figure==0)=NaN;

icon = fullfile('icon_axis.png');
icon_axis= double(imread(icon))/255;
icon_axis(icon_axis==0)=NaN;

icon = fullfile('icon_content.png');
icon_content= double(imread(icon))/255;
icon_content(icon_content==0)=NaN;




save('../icon.mat','icon_split','icon_polarity','icon_shade','icon_line',...
    'icon_stem','icon_stairs','icon_cursor','icon_legend','icon_title',...
    'icon_topo','icon_head','icon_dataset_add','icon_dataset_del',...
    'icon_dataset_down','icon_dataset_up','icon_run','icon_open',...
    'icon_script','icon_save','icon_delete','icon_import','icon_close',...
    'icon_stop','icon_open_path','icon_refresh','icon_undo','icon_redo',...
    'icon_lock','icon_unlock','icon_sendtoworkspace','icon_loadfromworkspace',...
    'icon_recovery','icon_rename','icon_data_manage','icon_figure_save',...
    'icon_figure','icon_axis','icon_content');

