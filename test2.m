function test2
figure()
obj=1;
uicontrol('style','pushbutton','String','Set Threshold','callback',@(src,eventdata)test3(obj));
end