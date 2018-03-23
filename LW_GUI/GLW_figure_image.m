function GLW_figure_image(option)
if ~isfield(option,'inputfiles')||isempty(option.inputfiles)
    return;
end
option.ax{1}.name='Image1';
option.ax{1}.pos=[92,72.5,542.5,529.75];
option.ax{1}.style='Image';
option.ax{1}.content{1}.name='image1';
option.ax{1}.content{1}.type='image';
option.ax{1}.content{1}.ch='Cz';
GLW_figure(option);
end