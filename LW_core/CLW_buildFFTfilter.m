function v = CLW_buildFFTfilter(header,option)
xstart=0;
xstep=1/(header.xstep*header.datasize(6));
switch option.filter_type
    case 'lowpass'
        x1=fix((option.high_cutoff-xstart)/xstep)+1;
        x2=fix((option.high_cutoff+option.high_width-xstart)/xstep)+1;
        v=FFTfilter_lowpass(x1,x2,header.datasize(6));
    case 'highpass'
        x2=fix((option.low_cutoff-xstart)/xstep)+1;
        x1=fix((option.low_cutoff-option.low_width-xstart)/xstep)+1;
        v=1-FFTfilter_lowpass(x1,x2,header.datasize(6));
    case 'bandpass'
        x1=fix((option.high_cutoff-xstart)/xstep)+1;
        x2=fix((option.high_cutoff+option.high_width-xstart)/xstep)+1;
        v1=FFTfilter_lowpass(x1,x2,header.datasize(6));
        
        x2=fix((option.low_cutoff-xstart)/xstep)+1;
        x1=fix((option.low_cutoff-option.low_width-xstart)/xstep)+1;
        v2=1-FFTfilter_lowpass(x1,x2,header.datasize(6));
        v=v1.*v2;
    case 'notch'
        v=ones(1,header.datasize(6));
        for k=1:option.harmonic_num
            x1=fix((option.notch_fre*k+option.notch_width-xstart)/xstep)+1;
            x2=fix((option.notch_fre*k+option.notch_width+option.slope_width-xstart)/xstep)+1;
            v1=FFTfilter_lowpass(x1,x2,header.datasize(6));
            
            x2=fix((option.notch_fre*k-option.notch_width-xstart)/xstep)+1;
            x1=fix((option.notch_fre*k-option.notch_width-option.slope_width-xstart)/xstep)+1;
            v2=1-FFTfilter_lowpass(x1,x2,header.datasize(6));
            v=v.*(1-v1.*v2);
        end
end
if mod(header.datasize(6),2)==1
    v((end+1)/2:end)=v((end-1)/2:-1:2);
else
    v(end/2+2:end)=v(end/2:-1:2);
end
end
function v=FFTfilter_lowpass(x1,x2,datalength)
x1=max(x1,1);
x2=max(x2,1);
x1=min(x1,datalength);
x2=min(x2,datalength);
if(x1>x2)
    temp=x1;
    x1=x2;
    x2=temp;
end
v=ones(1,datalength);
v(x2:end)=0;
if x2>x1+1
han=hanning((x2-x1-1)*2);
v(x1+1:x2-1)=han(end/2+1:end);
end
end
