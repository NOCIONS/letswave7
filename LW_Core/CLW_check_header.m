function [header] = CLW_check_header(header)
% %check history structure is compatible with LW6
% if isfield(header,'history');
%     if isfield(header.history,'configuration');
%     else
%         disp('Deleting History as it is not compatible with LW6');
%         header.history=[];
%     end
% end

%check history structure is compatible with LW6
if isfield(header,'history')
    if isfield(header.history,'option')
    else
        %disp('Deleting History as it is not compatible with LW6');
        header.history=[];
    end
end

if ~isfield(header,'index_labels')
    tp={};
    for i=1:header.datasize(3)
        tp{i}=['index ' num2str(i)];
    end
    header.index_labels=tp;
end
header.datasize=double(header.datasize);
header.xstep=double(header.xstep);
header.xstart=double(header.xstart);
header.ystep=double(header.ystep);
header.ystart=double(header.ystart);
header.zstep=double(header.zstep);
header.zstart=double(header.zstart);

if ~isfield(header,'index_labels')
    tp={};
    for i=1:header.datasize(3)
        tp{i}=['index ' num2str(i)];
    end
    header.index_labels=tp;
end

if ~isfield(header,'epochdata')
    header.epochdata=struct([]);
end

if ~isfield(header,'events')|| isempty(header.events)
    header.events=struct('code',{},'latency',{},'epoch',{});
else
    field_str={'code','latency','epoch'};
    C = setdiff(fieldnames(header.events),field_str);
    header.events = rmfield(header.events,C);
    if ~isfield(header.chanlocs,'code')
        [header.chanlocs.code]=deal('s');
    end
    if ~isfield(header.chanlocs,'latency')
        [header.chanlocs.latency]=deal(header.xstart);
    end
    if ~isfield(header.chanlocs,'epoch')
        [header.chanlocs.epoch]=deal(1);
    end
end

if ~isfield(header,'chanlocs')
    error('***No chanlocs header.chanlocs***');
%     header.chanlocs(header.datasize(2))=struct('labels',[],'topo_enabled',[],...
%         'theta',[],'radius',[],'sph_theta',[],'sph_phi',[],...
%         'sph_theta_besa',[],'sph_phi_besa',[],...
%         'X',[],'Y',[],'Z',[],'SEEG_enabled',[]);
else
    field_str={'labels','topo_enabled','theta','radius',...
        'sph_theta','sph_phi','sph_theta_besa','sph_phi_besa',...
        'X','Y','Z','SEEG_enabled'};
    C = setdiff(fieldnames(header.chanlocs),field_str);
    header.chanlocs = rmfield(header.chanlocs,C);
    if ~isfield(header.chanlocs,'labels')
        error('***No labels in header.chanlocs***');
    end
    if ~isfield(header.chanlocs,'topo_enabled')
        [header.chanlocs.topo_enabled]=deal(0);
    else
        for k=1:size(header.chanlocs,2)
            if isempty(header.chanlocs(k).topo_enabled)
                header.chanlocs(k).topo_enabled=0;
            end
        end
    end
    
    if ~isfield(header.chanlocs,'SEEG_enabled')
        [header.chanlocs.SEEG_enabled]=deal(0);
    else
        for k=1:size(header.chanlocs,2)
            if isempty(header.chanlocs(k).SEEG_enabled)
                header.chanlocs(k).SEEG_enabled=0;
            end
        end
    end
    
    if ~isfield(header.chanlocs,'theta')
        [header.chanlocs.theta]=deal([]);
    end
    if ~isfield(header.chanlocs,'radius')
        [header.chanlocs.radius]=deal([]);
    end
    if ~isfield(header.chanlocs,'sph_theta')
        [header.chanlocs.sph_theta]=deal([]);
    end
    if ~isfield(header.chanlocs,'sph_phi')
        [header.chanlocs.sph_phi]=deal([]);
    end
    if ~isfield(header.chanlocs,'sph_theta_besa')
        [header.chanlocs.sph_theta_besa]=deal([]);
    end
    if ~isfield(header.chanlocs,'sph_phi_besa')
        [header.chanlocs.sph_phi_besa]=deal([]);
    end
    if ~isfield(header.chanlocs,'X')
        [header.chanlocs.X]=deal([]);
    end
    if ~isfield(header.chanlocs,'Y')
        [header.chanlocs.Y]=deal([]);
    end
    if ~isfield(header.chanlocs,'Z')
        [header.chanlocs.Z]=deal([]);
    end
end