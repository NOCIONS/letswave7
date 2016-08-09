% clc;clear;close all;
% epoc_n=16;
% ch_n=10;
% x_n=1000;
% y_n=10;
% z_n=1;
% 
% tic;
% lwdata_in.data=randn(epoc_n,ch_n,1,z_n,y_n,x_n);
% for z_idx=1:z_n
%     for ch_idx=1:ch_n
%         tp_data=lwdata_in.data(:,ch_idx,1,z_n,:,:);
%         [H,P,~,STATS]=ttest(tp_data);
%         P=permute(P,[6,5,1,2,3,4]);
%         for k=1:100
%             RLL=reshape(bwlabel(P,4),[],1);
%         end
%     end
% end
% toc;
% 
% tic;
% lwdata_in.data=randn(epoc_n,ch_n,1,z_n,y_n,x_n);
% for z_idx=1:z_n
%     tp_data=lwdata_in.data(:,:,1,z_n,:,:);
%     [H,P,~,STATS]=ttest(tp_data);
%     P=permute(P,[6,5,1,2,3,4]);
%     for k=1:100
%         RLL=reshape(bwlabeln(P,4),[],1);
%     end
% end
% toc;
% 
function [a,b]=test2()
a=[1,2];
b=[3;4];
