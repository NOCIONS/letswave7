% events=[];
% events.stack=cell(21,1);
% events.stack_idx=1;
% events.table=header.events;
% events.stack{events.stack_idx}=events.table;
% events.code_all=unique({events.table.code});
% events.code=unique({events.table([events.table.epoch]==1).code});
% events.code_sel=1:length(events.code);
% if length(events.code_all)<=64
%     events.color=jet((length(events.code_all)-1)*10+1);
%     events.color=events.color(1:10:end,:);
% else
%     events.color=jet(length(events.code_all));
% end
% 
% 
% 
% events.code_sel=1:3;
% str=events.code(events.code_sel);
% events.code=events.code(setdiff(1:end,1:3));
% events.code_sel=[];
% for k=1:length(str)
%     events.table=events.table(~strcmp({events.table.code},str{k}));
% end
% events.stack_idx=mod(events.stack_idx,21)+1;
% events.stack{events.stack_idx}=events.table;
% events.stack{mod(events.stack_idx,21)+1}=[];


%function test
figure()
D={'12','32','12';4,5,6;7,8,9};
h_table=uitable('data',D,'CellEditCallback',@Event_table_Edited,...
    'ColumnEditable', [true true true]);
%end

% function Event_table_Edited(obj,callbackdata)
%     clc;
%     disp(callbackdata)
%     d=get(obj,'data');
%     d{callbackdata.Indices(1),callbackdata.Indices(2)}=callbackdata.PreviousData;
%     set(obj,'Data',d);
% end