function option=CLW_check_input(option,item,arg)
item=cellstr(item);
if ~isempty(arg)
    if length(arg)==1
        for k=1:length(item)
            if isfield(arg{1},item{k})
                str=['option.',item{k},'=arg{1}.',item{k},';'];
                eval(str);
            end
        end
    else
        for k=1:length(item)
            a=find(strcmpi(arg,item{k}));
            if ~isempty(a)&& length(arg)>=a+1
                str=['option.',item{k},'=arg{a+1};'];
                eval(str);
            end
        end
    end
end
if isfield(option,'suffix')
    option.suffix=strtrim(option.suffix);
end