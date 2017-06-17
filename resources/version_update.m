clc;clear;
[pathstr] = fileparts(mfilename('fullpath'));
file_name=fullfile(pathstr,'version.txt');
t=datetime('now','format','yyyyMMddHHmmss','TimeZone','Etc/UTC');
lw_version=str2num(char(t));
fileID = fopen(file_name,'w');
fwrite(fileID,char(t));
fclose(fileID);