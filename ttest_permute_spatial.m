clc;clear;close all;
load('matlab.mat');
[y,x]= pol2cart(pi/180.*[ch.theta],[ch.radius]);
d=squareform(pdist([x;y]'));

selected=zeros(size(data,2),length(ch));
for ch_n=1:length(ch)
    clc;disp(ch_n)
    data_temp=squeeze(data(ch_n,:,1,:)-data(ch_n,:,2,:))';
    L=size(data_temp,2);
    N=size(data_temp,1);
    [~,p,~,stats] =ttest(data_temp);
    t_value=abs(stats.tstat);

    idx=find(p<0.05 & p>0.05/L);
    t_threshold=sort(t_value(idx));
    distribution=zeros(2^N,length(idx));
    for k=0:2^N-1
        A=dec2bin(k)-'0';   A=[zeros(1,N-length(A)),A];
        temp=data_temp;     temp(A==1,:)=-temp(A==1,:);
        [~,~,~,stats] =ttest(temp);
        stats=abs(stats.tstat);

        for l=1%:length(idx)
            L=bwlabel(stats>t_threshold(l));
            for j=1:max(L);
                v=sum(stats(L==j));
                if(distribution(k+1,l)<v)
                    distribution(k+1,l)=v;
                end
            end
        end
    end
    distribution=sort(distribution,'descend');
    distribution=distribution(ceil(256*0.05),:);
    for l=1%:length(idx)
        L=bwlabel(t_value>t_threshold(l));
        for i=1:max(L);
            if(sum(t_value(L==i))>distribution(l))
                selected(L==i,ch_n)=l;
            end
        end
    end
end
subplot(2,2,2)
imagesc(selected'>0)

%clc;clear;
load('matlab.mat');
[y,x]= pol2cart(pi/180.*[ch.theta],[ch.radius]);
d=squareform(pdist([x;y]'));
data_temp=zeros(8,26*(256+1));
for ch_n=1:26
    data_temp(:,(ch_n-1)*(256+1)+(1:256))=squeeze(data(ch_n,:,1,:)-data(ch_n,:,2,:))';
end
L=size(data_temp,2);
N=size(data_temp,1);
[~,p,~,stats] =ttest(data_temp);
t_value=abs(stats.tstat);

idx=find(p<0.05 & p>0.05/L);
t_threshold=sort(t_value(idx));
distribution=zeros(2^N,length(idx));
for k=0:2^N-1
    A=dec2bin(k)-'0';   A=[zeros(1,N-length(A)),A];
    temp=data_temp;     temp(A==1,:)=-temp(A==1,:);
    [~,~,~,stats] =ttest(temp);
    stats=abs(stats.tstat);
    temp_sign=sign(reshape(mean(temp,1),257,[]));
    
    for l=1%:length(idx)
        if mod(l,100)==0
        clc;disp([k,l])
        end
        L=bwlabel(stats>t_threshold(l));
        L=reshape(L,257,[]);
        for ch_n1=1:26
            for ch_n2=ch_n1+1:26
                if d(ch_n1,ch_n2)<0.22
                    temp=L(:,ch_n1).*L(:,ch_n2).*temp_sign(:,ch_n1).*temp_sign(:,ch_n2)>0;
                    temp_L=bwlabel(temp);
                    for j=1:max(temp_L)
                        temp_idx=find(temp_L==j,1);
                        L(L==L(temp_idx,ch_n2))=L(temp_idx,ch_n1);
                    end
                end
            end
        end
        L=reshape(L,[],1);
        
        
        for j=1:max(L);
            v=sum(stats(L==j));
            if(distribution(k+1,l)<v)
                distribution(k+1,l)=v;
            end
        end
    end
end
distribution=sort(distribution,'descend');
distribution=distribution(ceil(256*0.05),:);
selected1=zeros(1,length(L));
data_temp=sign(reshape(mean(data_temp,1),257,[]));
for l=1%:length(idx)
    L=bwlabel(t_value>t_threshold(l));
    L=reshape(L,257,[]);
    for ch_n1=1:26
        for ch_n2=ch_n1+1:26
            if d(ch_n1,ch_n2)<0.22
                temp=L(:,ch_n1).*L(:,ch_n2).*data_temp(:,ch_n1).*data_temp(:,ch_n2)>0;
                temp_L=bwlabel(temp);
                for j=1:max(temp_L)
                    temp_idx=find(temp_L==j,1);
                    L(L==L(temp_idx,ch_n2))=L(temp_idx,ch_n1);
                end
            end
        end
    end
    L=reshape(L,[],1);
    for i=1:max(L);
        if(sum(t_value(L==i))>distribution(l))
            selected1(L==i)=i;
        end
    end
end

selected1=reshape(selected1,257,[]);
subplot(2,2,1)
imagesc(reshape(p,257,[])'<0.05);

subplot(2,2,4)
imagesc(selected1')

subplot(2,2,3)
imagesc((selected'>0)-(selected1(1:256,:)'>0))

% load('result_all.mat');
% figure()
% subplot(2,2,1)
% imagesc(reshape(p,257,[])'<0.05);
% 
% subplot(2,2,2)
% imagesc(selected'>0);
% 
% subplot(2,2,4)
% imagesc(selected1'>0)
% 
% subplot(2,2,3)
% imagesc((selected'>0)-(selected1(1:256,:)'>0))

% close all;
% figure()
% hold on;
% for t_idx=1:size(selected,1)
%     for ch_idx=1:size(selected,2)
%         if selected(t_idx,ch_idx)>0
%             for ch_idx1= ch_idx+1:size(selected,2)
%                 if selected(t_idx,ch_idx1)>0 && d(ch_idx,ch_idx1)<0.1
%                     plot3([x(ch_idx),x(ch_idx1)],[t(t_idx),t(t_idx)],[y(ch_idx),y(ch_idx1)],'r');
%                 end
%             end
%                 if t_idx<size(selected,1) && selected(t_idx+1,ch_idx)>0
%                     plot3([x(ch_idx),x(ch_idx)],[t(t_idx),t(t_idx+1)],[y(ch_idx),y(ch_idx)],'r');
%                 end
%             %plot3(x(ch_idx),t(t_idx),y(ch_idx),'k.','MarkerSize',14);
%         end
%     end
% end
% view(70,28)





% figure()
% hold on;
% headx = 0.5*[sin(linspace(0,2*pi,100)),NaN,sin(-2*pi*10/360),0,sin(2*pi*10/360),NaN,...
%     0.1*cos(2*pi/360*linspace(80,360-80,100))-1,NaN,...
%     -0.1*cos(2*pi/360*linspace(80,360-80,100))+1];
% heady = 0.5*[cos(linspace(0,2*pi,100)),NaN,cos(-2*pi*10/360),1.1,cos(2*pi*10/360),NaN,...
%     0.2*sin(2*pi/360*linspace(80,360-80,100)),NaN,0.2*sin(2*pi/360*linspace(80,360-80,100))];
% line(headx,heady,'Color',[0,0,0],'Linewidth',2);
% line(headx,heady,'Color',[0,0,0],'Linestyle','none','Marker','.','Markersize',8);
% plot(x,y,'k.','MarkerSize',14)
% for k=1:26
%     text(x(k),y(k),[num2str(k),'. ' ch(k).labels])
%     for j=k+1:26
%         if(d(k,j)<0.22)
%             plot([x(k),x(j)],[y(k),y(j)],'r')
%         end
%     end
% end
