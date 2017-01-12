function header_out=CLW_events_duplicate_check(header_in,varargin)
header_out=header_in;
events_in=header_in.events;
if isempty(varargin)
    latency=header_in.xstep;
else
    latency=varargin{1};
end
event_num=size(events_in,2);
if event_num~=0
    event_latency=[events_in.latency];
    [~,event_index]=sort(event_latency);
    event_baned=[];
    for eventpos=1:event_num
        if  ismember(eventpos,event_baned)
            continue;
        end
        current_code=events_in(event_index(eventpos)).code;
        current_latency=events_in(event_index(eventpos)).latency;
        current_epoch=events_in(event_index(eventpos)).epoch;
        for eventpos2=eventpos+1:event_num
            if strcmpi(events_in(event_index(eventpos2)).code,current_code) &&...
                    (events_in(event_index(eventpos2)).epoch==current_epoch) &&...
                    (events_in(event_index(eventpos2)).latency-current_latency)<=latency+eps
                event_baned=[event_baned,eventpos2];
            else
                break;
            end
        end
    end
    event_baned=event_index(event_baned);
    event_baned=unique(event_baned);
    if ~isempty(event_baned)
        disp(['Deleting ' num2str(length(event_baned)) ' invalid events.']);
    end
    header_out.events=events_in(setdiff(1:event_num,event_baned));
end