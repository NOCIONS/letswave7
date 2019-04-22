function LW_init()
set(0,'DefaultUicontrolFontSize',10);

if verLessThan('matlab','8.4')
    warning('off','MATLAB:CELL:INTERSECT:RowsFlagIgnored');
end

% find the path of letswave7
str=which('letswave7');
p=fileparts(str);

% remove all the paths including 'letswave','eeglab','fieldtrip'
str=path;
idx=find(str==pathsep);
str_rm=[];
for k=1:length(idx)
    if k==1
        str_idx=str(1:idx(k)-1);
    else
        str_idx=str(idx(k-1)+1:idx(k)-1);
    end
    str_temp=lower(str_idx);
    if ~isempty(strfind(str_temp,'letswave'))||...
            ~isempty(strfind(str_temp,'eeglab'))||...
            ~isempty(strfind(str_temp,'fieldtrip'))
        if isempty(str_rm)
            str_rm=str_idx;
        else
            str_rm=[str_rm,pathsep,str_idx];
        end
    end
end
if ~isempty(str_rm)
    rmpath(str_rm);
end


% add the paths  of letswave7
str_add=[fullfile(p),pathsep,...
    fullfile(p,'res'),pathsep,...
    fullfile(p,'LW_Function'),pathsep,...
    fullfile(p,'LW_GUI'),pathsep,...
    genpath(fullfile(p,'LW_Core')),pathsep,...
    genpath(fullfile(p,'external')),pathsep,...
    fullfile(p,'plugins'),pathsep];

% init the environment
pathstr=fullfile(p,'plugins');
filename=dir(pathstr);
batch_list=[];
batch_idx=1;
plugins_list=[];
plugins_idx=1;

for k=3:length(filename)
    if filename(k).isdir % not a folder
        str=fullfile(pathstr,filename(k).name,'menu.xml');
        if ~exist(str,'file')
            continue;
        end
        str_add=[str_add,fullfile(pathstr,filename(k).name),pathsep];
        plugins_list{plugins_idx}=filename(k).name;
        plugins_idx=plugins_idx+1;
    else
        [~,~,ext]=fileparts(filename(k).name);
        if strcmp(ext,'.lw_script')
            batch_list{batch_idx}=filename(k).name;
            batch_idx=batch_idx+1;
        end
    end
end
save(fullfile(p,'res','batch_plugins.mat'),'batch_list','plugins_list');
str_add=strrep(str_add,[pathsep,pathsep],pathsep);
addpath(str_add);
