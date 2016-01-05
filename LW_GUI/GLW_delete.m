function GLW_delete(option)
button = questdlg('Are you sure to delete these files?','Delete','Yes','No','Yes');
if strcmp(button,'Yes')
    CLW_dataset_delete(option.file_str);
end
end