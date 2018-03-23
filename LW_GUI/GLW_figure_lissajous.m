function GLW_figure_lissajous(option)
if ~isfield(option,'inputfiles')||isempty(option.inputfiles)
    return;
end
option.ax{1}.name='Curve1';
option.ax{1}.pos=[92,72.5,542.5,529.75];
option.ax{1}.style='Curve';
option.ax{1}.content{1}.name='lissajous1';
option.ax{1}.content{1}.type='lissajous';
option.ax{1}.content{1}.source1_ch='Cz';
option.ax{1}.content{1}.source2_ch='Oz';
option.ax{1}.content{1}.color=[0.85,0.325,0.098];
GLW_figure(option);
end