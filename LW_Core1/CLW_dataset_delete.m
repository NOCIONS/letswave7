function CLW_dataset_delete(filename)
if isempty(filename)
    return;
end
filename=cellstr(filename);
for k=1:length(filename)
    delete(filename{k});
    switch(filename{k}(end))
        case '4'
            if ~exist([filename{k}(1:end-1),'5'],'file') && ~exist([filename{k}(1:end-1),'6'],'file')
                delete([filename{k}(1:end-3),'mat']);
            end
        case '5'
            if ~exist([filename(1:end-1),'4'],'file') && ~exist([filename{k}(1:end-1),'6'],'file')
                delete([filename{k}(1:end-3),'mat']);
            end
        case '6'
            if ~exist([filename{k}(1:end-1),'4'],'file') && ~exist([filename{k}(1:end-1),'5'],'file')
                delete([filename{k}(1:end-3),'mat']);
            end
    end
end