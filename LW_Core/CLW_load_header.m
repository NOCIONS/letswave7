function header = CLW_load_header(filename)
[p,n,e]=fileparts(filename);
switch(e)
    case {'.lw5','.lw6'}
        load(fullfile(p,[n,e]),'-MAT');
    otherwise
        load(fullfile(p,[n,'.lw6']),'-MAT');
end
header.name=n;
header=CLW_check_header(header);
end