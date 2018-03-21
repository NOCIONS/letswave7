clc;clear;
[pathstr] = fileparts(mfilename('fullpath'));
file_name=fullfile(pathstr,'version.txt');
t=datetime('now','format','yyyyMMddHHmmss','TimeZone','Etc/UTC');
lw_version=str2num(char(t));
fileID = fopen(file_name,'w');
fwrite(fileID,char(t));
fclose(fileID);


% file_name=fullfile(pathstr,'check_update.txt');
% fileID = fopen(file_name,'w');
% fprintf(fileID,'import sae\n');
% fprintf(fileID,'\n');
% fprintf(fileID,'def app(environ, start_response):\n');
% fprintf(fileID,'    status = ''200 OK''\n');
% fprintf(fileID,'    response_headers = [(''Content-type'', ''text/plain'')]\n');
% fprintf(fileID,'     start_response(status, response_headers)\n');
% fprintf(fileID,'    return [''20180305072546'']\n');
% fprintf(fileID,'\n');
% fprintf(fileID,'application = sae.create_wsgi_app(app)\n');
% fclose(fileID);

%http://g.sae.sina.com.cn/log/http/2015-06-05/1-access.log
% import sae
% 
% def app(environ, start_response):
%     status = '200 OK'
%     response_headers = [('Content-type', 'text/plain')]
%     start_response(status, response_headers)
%     return ['20180305072546']
% 
% application = sae.create_wsgi_app(app)