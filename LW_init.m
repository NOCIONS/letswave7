function LW_init()

%find letswave7
str=which('letswave7');
p=fileparts(str);

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
str_add=[fullfile(p),pathsep,...
    fullfile(p,'resources'),pathsep,...
    fullfile(p,'LW_Function'),pathsep,...
    fullfile(p,'LW_GUI'),pathsep,...
    genpath(fullfile(p,'LW_Core')),pathsep,...
    genpath(fullfile(p,'external')),pathsep];
addpath(str_add);
