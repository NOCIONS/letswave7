function LW_init()

%find letswave7
str=which('letswave7');
p=fileparts(str);

%find (and remove) path entries to letswave5 or letswave6
str=strsplit(path,pathsep);
tf5= ~cellfun(@isempty,strfind(str,'letswave5'));
tf6= ~cellfun(@isempty,strfind(str,'letswave6'));
str = strjoin(str(tf5|tf6),pathsep);
rmpath(str);

%add path entries to LW7 subfolders
str=[strjoin(fullfile(p,{'resources','LW_Function','LW_GUI'}),pathsep),...
    pathsep,genpath(fullfile(p,'LW_Core')),...
    pathsep,genpath(fullfile(p,'external'))];
addpath(str);
end
