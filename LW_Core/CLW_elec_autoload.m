function header=CLW_elec_autoload(header)
if isempty(header.chanlocs)
    return;
end
load('mat_chanlocs.mat');
%addpath('/Users/huanggan/Documents/MATLAB/letswave6/res/electrodes/spherical_locations');
%chanlocs=readlocs('biosemi_locations_256.xyz');
chanloc_labels={chanlocs.labels};
channel_labels={header.chanlocs.labels};
header_chanlocs=header.chanlocs;

for chanpos=1:length(channel_labels)
    a=find(strcmpi(channel_labels{chanpos},chanloc_labels)==1);
    if isempty(a)
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