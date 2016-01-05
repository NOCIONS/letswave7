function header = CLW_load_header(filename)
[p,n]=fileparts(filename);
load(fullfile(p,[n,'.lw6']),'-MAT');
header.name=n;
header=CLW_check_header(header);
end

