function data = CLW_load_data(filename)
[p,n]=fileparts(filename);
load(fullfile(p,[n,'.mat']),'-MAT');
data=double(data);
end

