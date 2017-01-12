function CLW_dataset_rename(file_str,keyword1_str,keyword2_str,is_regExp,is_caseSen)
if nargin<3
    disp('the input is incorrect.');
    return;
end
if nargin==3
    is_regExp=0;
    is_caseSen=1;
end
if nargin==4
    is_caseSen=1;
end
if isempty(file_str) || isempty(keyword1_str)
    return;
end
file_str=cellstr(file_str);

for k=1:length(file_str)
    [p,n,e]=fileparts(file_str{k});
    file_name=n;
    endIndex=[];
    if is_regExp
        if is_caseSen
            [startIndex,endIndex] = regexp(file_name, keyword1_str);
        else
            [startIndex,endIndex] = regexpi(file_name, keyword1_str);
        end
    else
        if is_caseSen
            startIndex= strfind(file_name, keyword1_str);
        else
            startIndex= strfind(lower(file_name), lower(keyword1_str));
        end
    end
    if isempty(startIndex)
        continue;
    else
        startIndex=startIndex(1);
        if isempty(endIndex)
            endIndex=startIndex+length(keyword1_str)-1;
        else
            endIndex=endIndex(1);
        end
        filename_pre=file_name;
        filename_post=[file_name(1:startIndex-1), ...
            regexprep(file_name(startIndex:endIndex),keyword1_str,keyword2_str),...
            file_name(endIndex+1:end)];
    end
    if ispc
        str=['rename "',fullfile(p,[filename_pre,e]),'" "',fullfile(p,[filename_post,e]),'"'];
        if dos(str);
            try                
                movefile(fullfile(p,[filename_pre,e]),fullfile(p,[filename_post,e]));
            end
        end
    else
        movefile(fullfile(p,[filename_pre,e]),fullfile(p,[filename_post,e]));
    end
    is_copy_matfile=0;
    switch(e)
        case '.lw4'
            if exist([file_str{k}(1:end-1),'5'],'file') || exist([file_str{k}(1:end-1),'6'],'file')
                is_copy_matfile=1;
            end
        case '.lw5'
            if exist([file_str{k}(1:end-1),'4'],'file') || exist([file_str{k}(1:end-1),'6'],'file')
                is_copy_matfile=1;
            end
        case '.lw6'
            if exist([file_str{k}(1:end-1),'4'],'file') || exist([file_str{k}(1:end-1),'5'],'file')
                is_copy_matfile=1;
            end
    end
    if is_copy_matfile
        copyfile(fullfile(p,[filename_pre,'.mat']),fullfile(p,[filename_post,'.mat']));
    else
        if ispc
            str=['rename "',fullfile(p,[filename_pre,'.mat']),...
                '" "',fullfile(p,[filename_post,'.mat']),'"'];
            if dos(str);
                try
                    movefile(fullfile(p,[filename_pre,'.mat']),fullfile(p,[filename_post,'.mat']));
                end
            end
        else
            movefile(fullfile(p,[filename_pre,'.mat']),fullfile(p,[filename_post,'.mat']));
        end
    end
end

