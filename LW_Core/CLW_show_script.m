function CLW_show_script(script)
h=findall(0,'tag','LW_Script');
if ~isempty(h)
    close(h);
end
f=figure('MenuBar','none','DockControls','off',...
    'name','LW_Script','numbertitle','off','tag','LW_Script');
jCodePane=com.mathworks.widgets.SyntaxTextPane;
codeType=jCodePane.M_MIME_TYPE;
jCodePane.setContentType(codeType);
str_temp=[];
for k=1:length(script)
    str_temp=[str_temp,script{k},sprintf('\n')];
end
script = str_temp;%strjoin(script,'\n');
script=strrep(script,'%','%%');
jCodePane.setText(script);
jScrollPane=com.mathworks.mwswing.MJScrollPane(jCodePane);
pos=get(f,'position');
[~,h]=javacomponent(jScrollPane,[1,40,pos(3),pos(4)-40],gcf);
set(h,'units','norm');
btn=uicontrol('style','pushbutton','position',[1,1,pos(3),39],...
    'string','Copy the script to clipboard & Close',...
    'callback',{@close_copy,script});
set(btn,'units','normalized');
end


function close_copy(~,~,script)
clipboard('copy', script);
closereq;
end


