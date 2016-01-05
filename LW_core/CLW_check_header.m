function [header] = CLW_check_header(header)
% %check history structure is compatible with LW6
% if isfield(header,'history');
%     if isfield(header.history,'configuration');
%     else
%         disp('Deleting History as it is not compatible with LW6');
%         header.history=[];
%     end;
% end;

%check history structure is compatible with LW6
if isfield(header,'history');
    if isfield(header.history,'option');
    else
        %disp('Deleting History as it is not compatible with LW6');
        header.history=[];
    end
end

if ~isfield(header,'index_labels')
    tp={};
    for i=1:header.datasize(3);
        tp{i}=['index ' num2str(i)];
    end
    header.index_labels=tp;
end

if ~isfield(header,'events')
    header.events=struct('code',{},'latency',{},'epoch',{});
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
    if ~isfield(header.chanlocs,'SEEG_enabled')
        [header.chanlocs.SEEG_enabled]=deal(0);
    end
end