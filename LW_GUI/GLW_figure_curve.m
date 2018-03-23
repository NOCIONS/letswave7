function GLW_figure_curve(option)
if ~isfield(option,'inputfiles')||isempty(option.inputfiles)
    return;
end
option.ax{1}.name='Curve1';
option.ax{1}.pos=[92,72.5,542.5,529.75];
option.ax{1}.style='Curve';
option.ax{1}.content{1}.name='curve1';
option.ax{1}.content{1}.type='curve';
option.ax{1}.content{1}.ch='Cz';
option.ax{1}.content{1}.color=[0.85,0.325,0.098];
GLW_figure(option);
end