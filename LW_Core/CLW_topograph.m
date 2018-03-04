function CLW_topograph(values, chanlocs, varargin)
option.ax=gca;
option.dim='2D';
option.electrodes='on';
option.colormap='jet';
option.colorbar='off';
option.maplimits=[];
option.shading='interp';
option.contour='on';
option.dotsize=5;
option.mark=[];
option.exclude=[];
option.view=[];
option.shrink=1;
option.headrad=[];
option.surface='on';
option=CLW_check_input(option,{'ax','dim','electrodes','colormap','maplimits',...
    'shading','contour','dotsize','exclude','mark','view','headrad','shrink','surface','colorbar'},...
    varargin);

%% not understand
if any(values == 0) || ~isempty( [ chanlocs(values == 0).theta ])
    option.contour = 'off';
end

%% remove the excluded channels
chan_labels={chanlocs.labels};
if ~isempty(option.exclude)
    [~,ia] = intersect(option.exclude,chan_labels);
    chan_labels(ia) = [];
    chanlocs(ia)    = [];
    values(ia)      = [];
end

ia = cellfun('isempty', { chanlocs.theta });
values(ia)=[];
chan_labels(ia)=[];
[y,x]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
x=-x;
x = x*option.shrink;
y = y*option.shrink;
if isempty(option.headrad)
    option.headrad = max(sqrt(x.^2+y.^2));
end

% data points for 2-D data plot
pnts = linspace(0,2*pi,200/0.25*(option.headrad.^2));
gridres = 40;
coords = linspace(-option.headrad, option.headrad, gridres);

ay = repmat(coords,  [gridres 1]);
ax = repmat(coords', [1 gridres]);

xx = sin(pnts)*option.headrad;
yy = cos(pnts)*option.headrad;
for ind=1:length(xx)
    [~, closex] = min(abs(xx(ind)-coords));
    [~, closey] = min(abs(yy(ind)-coords));
    ax(closex,closey) = xx(ind);
    ay(closex,closey) = yy(ind);
end
xx2 = sin(pnts)*(option.headrad-0.01);
yy2 = cos(pnts)*(option.headrad-0.01);
for ind=1:length(xx)
    [~, closex] = min(abs(xx2(ind)-coords));
    [~, closey] = min(abs(yy2(ind)-coords));
    ax(closex,closey) = xx(ind);
    ay(closex,closey) = yy(ind);
end

a = griddata(x, y, values, -ay, ax, 'v4');
aradius = sqrt(ax.^2 + ay.^2);
a(aradius(:) > option.headrad+0.01) = NaN;
if strcmpi(option.surface,'on')
surf(option.ax,ay, ax, a, 'edgecolor', 'none');
shading(option.ax,option.shading);
end
view([0 0 1]);
hold(option.ax,'on');
top = max(a(:))*1.05;
if strcmpi(option.contour, 'on')
    contour3(option.ax,ay, ax, a, 5, 'edgecolor', 'k');
end

if strcmpi(option.electrodes, 'on') || strcmpi(option.electrodes, 'labels')
    rad = sqrt(x.^2 + y.^2);
    x(rad > option.headrad) = [];
    y(rad > option.headrad) = [];
    plot3(option.ax, -x, y, ones(size(x))*top, 'k.', 'markersize', option.dotsize);
    
    [~,ia] = intersect(option.mark,chan_labels);
    for i =ia'
        plot3(option.ax, -x(i), y(i), double(top), 'y.', 'markersize', 4*option.dotsize);
        plot3(option.ax, -x(i), y(i), double(top), 'r.', 'markersize', 2*option.dotsize);
    end
    if strcmpi(option.electrodes, 'labels')
        for index = 1:length(x)
            text(option.ax, -x(index)+0.02, y(index), double(top), chan_labels{index});
        end
    end
else
    % invisible electrode that avoid plotting problem (no surface, only
    % contours)
    plot3(option.ax, -x, y, -ones(size(x))*top, 'k.', 'markersize', 0.001);
end
colormap(option.colormap);
if ~isempty(option.maplimits)
    caxis(option.ax,option.maplimits);
end
if strcmpi(option.colorbar,'on')
    colorbar;
end

% main circle
% -----------
radiuscircle = 0.5;
pnts   = linspace(0,2*pi,200);
xc     = sin(pnts)*radiuscircle;
yc     = cos(pnts)*radiuscircle;
plot3(option.ax,xc,yc,ones(size(xc))*top, 'k', 'linewidth', 2); 
hold on;

% ears & nose
% -----------
base  = radiuscircle-.0046;
basex = 0.18*radiuscircle;                   % nose width
tip   = 1.15*radiuscircle;
tiphw = .04*radiuscircle;                    % nose tip half width
tipr  = .01*radiuscircle;                    % nose tip rounding
q = .04; % ear lengthening
EarX  = [.497-.005  .510  .518  .5299 .5419  .54    .547   .532   .510   .489-.005]; % radiuscircle = 0.5
EarY  = [q+.0555 q+.0775 q+.0783 q+.0746 q+.0555 -.0055 -.0932 -.1313 -.1384 -.1199];

plot3(option.ax,EarX,EarY,ones(size(EarX))*top,'color','k','LineWidth',2)    % plot left ear
plot3(option.ax,-EarX,EarY,ones(size(EarY))*top,'color','k','LineWidth',2)   % plot right ear
plot3(option.ax,[basex;tiphw;0;-tiphw;-basex],[base;tip-tipr;tip;tip-tipr;base],top*ones(size([basex;tiphw;0;-tiphw;-basex])),'color','k','LineWidth',2);

% axis limits
% -----------
axis off;
set(gca, 'ydir', 'normal');
axis equal
ylimtmp = max(option.headrad, 0.58);
ylim([-ylimtmp ylimtmp]);
end