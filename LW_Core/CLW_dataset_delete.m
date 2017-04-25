function CLW_dataset_delete(filename)
if isempty(filename)
    return;
end
filename=cellstr(filename);
fig=NaN;
if length(filename)>10
    fig=figure('numbertitle','off','name','Delete files',...
        'MenuBar','none','DockControls','off');
    set(fig,'windowstyle','modal');
    pos=get(fig,'position');
    pos(3:4)=[400,100];
    set(fig,'position',pos);
    hold on;
    run_slider=rectangle('Position',[0 0 eps 1],'FaceColor',[255,71,38]/255,'LineStyle','none');
    rectangle('Position',[0 0 1 1]);
    xlim([0,1]);
    ylim([-1,2]);
    axis off;
    h_text=text(1,-0.5,'starting...','HorizontalAlignment','right','Fontsize',12,'FontWeight','bold');
    pause(0.001);
end
tic;
t1=toc;
for k=1:length(filename)
    delete(filename{k});
    switch(filename{k}(end))
        case '4'
            if ~exist([filename{k}(1:end-1),'5'],'file') && ~exist([filename{k}(1:end-1),'6'],'file')
                delete([filename{k}(1:end-3),'mat']);
            end
        case '5'
            if ~exist([filename(1:end-1),'4'],'file') && ~exist([filename{k}(1:end-1),'6'],'file')
                delete([filename{k}(1:end-3),'mat']);
            end
        case '6'
            if ~exist([filename{k}(1:end-1),'4'],'file') && ~exist([filename{k}(1:end-1),'5'],'file')
                delete([filename{k}(1:end-3),'mat']);
            end
    end
    t=toc;
    if ishandle(fig) && t-t1>0.2
        t1=t;
        N=k/length(filename);
        set(run_slider,'Position',[0 0 N 1]);
        set(h_text,'string',[num2str(k),'/',num2str(length(filename)),' ( ',num2str(t/N*(1-N),'%0.0f'),' second left)']);
        drawnow ;
    end
end
if ishandle(fig)
    set(run_slider,'Position',[0 0 1 1]);
    set(h_text,'string','finished.');
    drawnow;
    pause(0.1);
    close(fig);
end