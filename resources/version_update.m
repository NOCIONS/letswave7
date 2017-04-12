clc;clear;
[pathstr] = fileparts(mfilename('fullpath'));
file_name=fullfile(pathstr,'version.txt');
t=datetime(datetime,'format','yyyyMMddhhmmss');
lw_version=str2num(char(t));
fileID = fopen(file_name,'w');
fwrite(fileID,char(t));
fclose(fileID);