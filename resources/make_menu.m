% clc;clear;%close all;
% s.LW_Manage.menu{1}.Attributes.Label='File';
% s.LW_Manage.menu{1}.submenu{1}.Attributes.Label = 'import';
% s.LW_Manage.menu{1}.submenu{1}.Attributes.callback = '11';
% s.LW_Manage.menu{1}.submenu{2}.Attributes.Label = 'export';
% s.LW_Manage.menu{1}.submenu{2}.Attributes.callback = '12';
% 
% s.LW_Manage.menu{2}.Attributes.Label='Edit';
% s.LW_Manage.menu{2}.submenu{1}.Attributes.Label = 'electrode';
% s.LW_Manage.menu{2}.submenu{1}.Attributes.callback = '21';
% s.LW_Manage.menu{2}.submenu{2}.Attributes.Label = 'event';
% s.LW_Manage.menu{2}.submenu{2}.Attributes.callback = '22';
% s.LW_Manage.menu{2}.submenu{3}.Attributes.Label='epoch';
% s.LW_Manage.menu{2}.submenu{3}.subsubmenu{1}.Attributes.Label = '231';
% s.LW_Manage.menu{2}.submenu{3}.subsubmenu{1}.Attributes.callback = '231';
% 
% s.LW_Manage.menu{3}.Attributes.Label='Process';
% s.LW_Manage.menu{3}.submenu{1}.Attributes.Label = 'time domain';
% s.LW_Manage.menu{3}.submenu{1}.subsubmenu{1}.Attributes.Label = 'segmentation';
% s.LW_Manage.menu{3}.submenu{1}.subsubmenu{1}.Attributes.callback = 'FLW_segmentation';
% s.LW_Manage.menu{3}.submenu{2}.Attributes.Label = 'spatial domain';
% s.LW_Manage.menu{3}.submenu{2}.Attributes.callback = 'FLW_segmentation';
% s.LW_Manage.menu{3}.submenu{3}.Attributes.Label = 'merge';
% s.LW_Manage.menu{3}.submenu{3}.Attributes.callback = 'FLW_merge';
% 
% s.LW_Manage.menu{4}.Attributes.Label='Toolbox';
% s.LW_Manage.menu{4}.submenu{1}.Attributes.Label = 'ICA';
% s.LW_Manage.menu{4}.submenu{1}.Attributes.callback = 'LW_average_epochs';
% s.LW_Manage.menu{4}.submenu{2}.Attributes.Label = 'source analysis';
% s.LW_Manage.menu{4}.submenu{2}.Attributes.callback = 'LW_segmentation';
% s.LW_Manage.menu{4}.submenu{2}.Attributes.Label = 'merge';
% s.LW_Manage.menu{4}.submenu{2}.Attributes.callback = 'LW_merge';
% 
% s.LW_Manage.menu{5}.Attributes.Label='Static';
% s.LW_Manage.menu{5}.submenu{1}.Attributes.Label = 'ANOVA';
% s.LW_Manage.menu{5}.submenu{1}.Attributes.callback = 'LW_ANOVA';
% s.LW_Manage.menu{5}.submenu{2}.Attributes.Label = 'ttest';
% s.LW_Manage.menu{5}.submenu{2}.Attributes.callback = 'LW_ttest';
% 
% s.LW_Manage.menu{6}.Attributes.Label='View';
% s.LW_Manage.menu{6}.submenu{1}.Attributes.Label = 'viewer';
% s.LW_Manage.menu{6}.submenu{1}.Attributes.callback = 'LW_ANOVA';
% s.LW_Manage.menu{6}.submenu{2}.Attributes.Label = 'map viewer';
% s.LW_Manage.menu{6}.submenu{2}.Attributes.callback = 'LW_ttest';
% struct2xml(s,'LW_Manager_menu.xml');
clear;clc;
s=xml2struct('menu_test.xml');
struct2xml(s,'menu_test.xml');
