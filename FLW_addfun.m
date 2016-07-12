classdef FLW_addfun<handle
    properties
        h_btn;
        h_panel;
    end
    
    methods
        function obj = FLW_addfun(GUI_handle)
            obj.h_btn = uicontrol(GUI_handle.tab_panel,'style','text',...
                'string','add','position',[1,1,100,10]);
            obj.h_panel=uipanel(GUI_handle.fig,...%'BorderType','none',...
            'units','pixels','position',[101,1,399,570]);
            
        end
    end
end