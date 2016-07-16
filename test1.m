% function test1
% clc;close all;
% figure()
% h=uicontrol('style','listbox','min',0,'max',2,...
%     'string',{'asd1','asd2','asd3','asd4'},...
%     'position',[10,10,130,300],'value',[2,4],...
%     'KeyPressFcn',@key_Press);
% 
%     function key_Press(obj,varargin)
%         disp(1);
%     end
% end

h.a=1;
isfield(h,'a')
