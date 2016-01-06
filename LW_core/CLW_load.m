function [header,data] = CLW_load(filename)
header=CLW_load_header(filename);
data = CLW_load_data(filename);
end

