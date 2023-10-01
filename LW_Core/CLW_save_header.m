function filename=CLW_save(lwdata_in,varargin)
option.path='';
option=CLW_check_input(option,{'path'},varargin);
header=lwdata_in.header;

%% check the events
if ~isempty(header.events)
    header=CLW_events_duplicate_check(header);
    event_banned=[];
    event_banned=[event_banned,find([header.events.epoch]<0)];
    event_banned=[event_banned,find([header.events.epoch]>header.datasize(1))];
    event_banned=[event_banned,find([header.events.latency]<header.xstart)];
    event_banned=[event_banned,find([header.events.latency]>header.xstart+(header.datasize(6)-1)*header.xstep)];
    event_banned=unique(event_banned);
    if ~isempty(event_banned)
        disp(['Deleting ' num2str(length(event_banned)) ' invalid events.']);
    end
    header.events=header.events(setdiff(1:size(header.events,2),event_banned));
else
    header.events=[];
end
[~,n,ext]=fileparts(header.name);
if ~isempty(ext) && (~strcmp(ext,'.lw6') && ~strcmp(ext,'.mat'))
    n=[n,ext];
end
save(fullfile(option.path,[n,'.lw6']),'header');
filename=n;



