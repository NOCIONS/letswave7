function max_value=CLW_max_cluster(tstat,dist)
%% CLW_max_cluster
if nargin==1
    dist=[];
end
max_value=0;
RLL=reshape(CLW_bwlabel(tstat,dist),[],1);
for k=1:max(RLL)
    max_value=max(max_value,sum(tstat(RLL==k)));
end

