function test
clc;clear;close all;



figure()
event_table = uitable('Data',randn(3,3));


set(event_table,'CellSelectionCallback',@CellSelectionCallback);
    function CellSelectionCallback(~,callbackdata)
        disp(callbackdata.Indices);
    end
end



%
% set(h_table,'CellEditCallback',@CellEditCallback);
%     function CellEditCallback(hObject,callbackdata)
%
%     end
% end




