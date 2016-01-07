clc;clear;
latency=linspace(0,100,1000)+0.5*sin(linspace(0,100,1000));
l=1:100;
dx1=l-0.2;
dx2=l-0.2+1;
A=find((ones(100,1)*latency>dx1'*ones(1,1000)) & (ones(100,1)*latency<dx2'*ones(1,1000)));
[I,J] = ind2sub([100,1000],A);