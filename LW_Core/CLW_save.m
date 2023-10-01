function filename=CLW_save(lwdata_in,varargin)
option.path='';
option=CLW_check_input(option,{'path'},varargin);
header=lwdata_in.header;
header.datasize=size(lwdata_in.data);
data=single(lwdata_in.data);

%% check the events
if ~isempty(header.events)
    header=CLW_events_duplicate_check(header);
    event_rejected=[];
    event_rejected=[event_rejected,find([header.events.epoch]<0)];
    event_rejected=[event_rejected,find([header.events.epoch]>header.datasize(1))];
    event_rejected=[event_rejected,find([header.events.latency]<header.xstart)];
    event_rejected=[event_rejected,find([header.events.latency]>header.xstart+(header.datasize(6)-1)*header.xstep)];
    event_rejected=unique(event_rejected);
    if ~isempty(event_rejected)
        disp(['Deleting ' num2str(length(event_rejected)) ' invalid events.']);
    end
    header.events=header.events(setdiff(1:size(header.events,2),event_rejected));
else
    header.events=[];
end
[~,n,ext]=fileparts(header.name);
if ~isempty(ext) && (~strcmp(ext,'.lw6') && ~strcmp(ext,'.mat'))
    n=[n,ext];
end
save(fullfile(option.path,[n,'.lw6']),'header');
save(fullfile(option.path,[n,'.mat']),'-v7.3','data');
filename=n;



