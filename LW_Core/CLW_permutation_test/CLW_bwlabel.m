function L=CLW_bwlabel(BW,dist)
if nargin==1
    dist=[];
end
temp=size(BW);
L=zeros(temp);
length_L=1;
for k=3:length(temp)
    length_L=length_L*temp(k);
end
max_idx=0;
for k=1:length_L
    L(:,:,k)=bwlabel(BW(:,:,k),4)+max_idx;
    max_idx=max(max(L(:,:,k)));
end
L(BW==0)=0;
L=reshape(L,temp(1)*temp(2),[]);
if ~isempty(dist)
    for ch_n1=1:size(BW,4)
        for ch_n2=ch_n1+1:size(BW,4)
            if dist(ch_n1,ch_n2)==1
                temp=L(:,ch_n1).*L(:,ch_n2);
                temp_L=bwlabel(temp);
                for j=1:max(temp_L)
                    temp_idx=find(temp_L==j,1);
                    L(L==L(temp_idx,ch_n2))=L(temp_idx,ch_n1);
                end
            end
        end
    end
end
