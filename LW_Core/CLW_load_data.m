function data = CLW_load_data(filename)
[p,n,ext]=fileparts(filename);
if ~isempty(ext) && (~strcmp(ext,'.lw6') && ~strcmp(ext,'.mat'))
    n=[n,ext];
end
load(fullfile(p,[n,'.mat']),'-MAT');
data=double(data);
end

