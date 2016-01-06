function header=CLW_edit_electrodes(header,chanlocs)
if isempty(chanlocs);
    return;
end
for k=1:length(header.chanlocs);
    channel_labels{k}=header.chanlocs(k).labels;
end
for k=1:length(chanlocs);
    chanloc_labels{k}=chanlocs(k).labels;
end
header_chanlocs=header.chanlocs;
for chanpos=1:length(channel_labels);
    a=find(strcmpi(channel_labels{chanpos},chanloc_labels)==1);
    if isempty(a);
    else
        header_chanlocs(chanpos).theta=chanlocs(a).theta;
        header_chanlocs(chanpos).radius=chanlocs(a).radius;
        header_chanlocs(chanpos).sph_theta=chanlocs(a).sph_theta;
        header_chanlocs(chanpos).sph_phi=chanlocs(a).sph_phi;
        header_chanlocs(chanpos).sph_theta_besa=chanlocs(a).sph_theta_besa;
        header_chanlocs(chanpos).sph_phi_besa=chanlocs(a).sph_phi_besa;
        header_chanlocs(chanpos).X=chanlocs(a).X;
        header_chanlocs(chanpos).Y=chanlocs(a).Y;
        header_chanlocs(chanpos).Z=chanlocs(a).Z;
        header_chanlocs(chanpos).topo_enabled=chanlocs(a).topo_enabled;
        header_chanlocs(chanpos).SEEG_enabled=0;
    end
end
header.chanlocs=header_chanlocs;