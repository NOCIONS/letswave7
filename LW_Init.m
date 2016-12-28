function LW_Init()
str=which('letswave7');
p=fileparts(str);
str=strsplit(path,pathsep);
tf5= ~cellfun(@isempty,strfind(str,'letswave5'));
tf6= ~cellfun(@isempty,strfind(str,'letswave6'));
str = strjoin(str(tf5|tf6),pathsep);

rmpath(str);

str=[strjoin(fullfile(p,{'resources',...
    'LW_Function','LW_GUI'}),pathsep),pathsep,genpath(fullfile(p,'LW_Core')),pathsep,genpath(fullfile(p,'external'))];
addpath(str);
end
