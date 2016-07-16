clc;clear;
load('matlab.mat');
ch_n=6;
data=squeeze(data(ch_n,:,1,:)-data(ch_n,:,2,:))';
L=size(data,2);
N=size(data,1);
[~,p,~,stats] =ttest(data);
t_value=abs(stats.tstat);

idx=find(p<0.05 & p>0.05/L);
t_threshold=sort(t_value(idx));
distribution=zeros(2^N,length(idx));
for k=0:2^N-1
    A=dec2bin(k)-'0';   A=[zeros(1,N-length(A)),A];
    temp=data;          temp(A==1,:)=-temp(A==1,:);
    [~,~,~,stats] =ttest(temp);
    stats=abs(stats.tstat);
    
    for l=1:length(idx)
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
selected=zeros(length(t_value),1);
figure();
for l=1:length(idx)
    L=bwlabel(t_value>t_threshold(l));
    for i=1:max(L);
        if(sum(t_value(L==i))>distribution(l))
            selected(L==i)=l;
        end
    end
    
    hold on;
    plot(selected);
end
