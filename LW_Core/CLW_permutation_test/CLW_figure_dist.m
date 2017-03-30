function CLW_figure_dist(obj)
header=obj.lwdataset(1).header;
chan_used=find([header.chanlocs.topo_enabled]==1, 1);
if isempty(chan_used)
    temp=CLW_elec_autoload(header);
    header.chanlocs=temp.chanlocs;
end 
[y,x]= pol2cart(pi/180.*[header.chanlocs.theta],[header.chanlocs.radius]);
dist=squareform(pdist([x;y]'));
d_max=max(max(dist));

f=figure('Resize','off','color',0.94*[1,1,1]);
set(f,'WindowStyle','modal')
p=get(f,'position');
p([3,4])=[560 420];
set(f,'position',p);

uicontrol('Style', 'text','horizontalalignment','left',...
    'string','Set the threshold for the sensor connection',...
    'units','normal','Position', [0.05 0.11 0.5 0.05]);

txt2 = uicontrol('Style', 'text','horizontalalignment','right',...
    'string','','units','normal','Position', [0.5 0.11 0.45 0.05]);
sld_value=str2num(get(obj.h_chan_dist_edit,'string'));
if isempty(sld_value)
    sld_value=0;
end
if sld_value<0
    sld_value=0;
end
if sld_value>d_max
    sld_value=d_max;
end
sld = uicontrol('Style', 'slider','Min',0,'Max',d_max,...
    'Value',sld_value,...
    'units','normal','Position', [0.05 0.084 0.7 0.038],...
    'Callback', @callback_sld);

edt = uicontrol('Style', 'edit','string',num2str(sld_value),...
    'units','normal','Position', [0.76 0.08 0.185 0.045],...
    'Callback', @callback_edt);

btn = uicontrol('Style', 'pushbutton','string','OK',...
    'units','normal','Position', [0.05 0 0.9 0.08],...
    'Callback', @callback_btn);

r=axes('position',[0.05,0.2,0.9,0.78]);
axis off;
draw();

    function callback_sld(~,varargin)
        draw();
        d=get(sld,'value');
        set(edt,'string',num2str(d));
    end

    function callback_edt(~,varargin)
        d=str2num(get(edt,'string'));
        if isempty(d)
            d=0;
        end
        if d<0
            d=0;
        end
        if d>d_max
            d=d_max;
        end
        set(sld,'value',d);
        set(edt,'string',num2str(d));
        draw();
    end

    function callback_btn(~,varargin)
        set(obj.h_chan_dist_edit,'string',get(edt,'string'));
        close(f);
    end

    function draw()
        d=get(sld,'value');
        N=length(dist);
        edge_idx=(sum(sum(dist<=d))-N)/N;
        str=['each channel has ',num2str(edge_idx),' neighbours in average'];
        set(txt2,'string',str);
        hold off;
        plot(r,x,y,'.');
        axis off;
        hold on;
        idx=find([header.chanlocs.topo_enabled]==1);
        for k=1:length(idx)
            text(x(k),y(k),header.chanlocs(idx(k)).labels);
        end
        line_x=[];
        line_y=[];
        for j=1:N-1
            for k=j+1:N
                if dist(j,k)<d
                    line_x=[line_x,x([j,k])'];
                    line_y=[line_y,y([j,k])'];
                end
            end
        end
        plot(r,line_x,line_y,'r');
    end
end