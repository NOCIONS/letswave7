function GLW_figure_topo(option)
if ~isfield(option,'inputfiles')||isempty(option.inputfiles)
    return;
end
option.ax{1}.name='Topograph1';
option.ax{1}.pos=[92,72.5,542.5,529.75];
option.ax{1}.style='Topograph';
option.ax{1}.content{1}.name='topo1';
option.ax{1}.content{1}.type='topo';
option.ax{1}.content{1}.x=[0,0];
option.ax{1}.content{1}.dim='2D';
GLW_figure(option);
end