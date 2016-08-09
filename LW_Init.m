function LW_Init()
str=which('letswave7');
p=fileparts(str);
str=strsplit(path,';');
tf5= ~cellfun(@isempty,strfind(str,'letswave5'));
tf6= ~cellfun(@isempty,strfind(str,'letswave6'));
str = strjoin(str(tf5|tf6),';');
rmpath(str);

str=strjoin(fullfile(p,{'resources','external',...
    'LW_Function','LW_GUI','LW_Core',fullfile('LW_Core','CLW_permutation_test'),''}),';');
addpath(str);
end