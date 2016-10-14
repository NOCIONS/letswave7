function cluster_detect=CLW_detect_cluster(tstat,option,cluster_distribute,dist)
if nargin==3
    dist=[];
end
cluster_detect=ones(size(tstat));

RLL=reshape(CLW_bwlabel(tstat,dist),[],1);
for k=1:max(RLL)
    ff=find(RLL==k);
    v=sum(abs(tstat(ff)));
    p=sum(cluster_distribute>v)/option.num_permutations;
    if(p<option.cluster_threshold)
        cluster_detect(ff)=p;
        %disp(v);
    end
end