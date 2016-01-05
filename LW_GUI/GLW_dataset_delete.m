function GLW_dataset_delete(option)
button = questdlg('Are you sure to delete these files?','Delete','Yes','No','Yes');
if strcmp(button,'Yes')
    for k=1:length(option.file_str)
        filename=fullfile(option.file_path,option.file_str{k});
        delete(option.file_str{k});
        switch(filename(end))
            case '4'
                if ~exist([filename(1:end-1),'5'],'file') && ~exist([filename(1:end-1),'6'],'file')
                    delete([option.file_str{k}(1:end-3),'mat']);
                end
            case '5'
                if ~exist([filename(1:end-1),'4'],'file') && ~exist([filename(1:end-1),'6'],'file')
                    delete([option.file_str{k}(1:end-3),'mat']);
                end
            case '6'
                if ~exist([filename(1:end-1),'4'],'file') && ~exist([filename(1:end-1),'5'],'file')
                    delete([option.file_str{k}(1:end-3),'mat']);
                end
        end
    end
end