function [data, header] = Read_EDF_BDF(filename)

% ?thor:  Shapkin Andrey,
% 15-OCT-2012


% filename - File name
% data - Contains a signals in structure of cells
% header  - Contains header

% Updated by Gan Huang
% 12-NOV-2017
% to support the BDF format loading

fid = fopen(filename,'r','ieee-le');

%%% HEADER LOAD
% PART1: (GENERAL)
hdr = char(fread(fid,256,'uchar')');
header.ver=str2num(hdr(1:8));            % 8 ascii : version of this data format (0)
header.patientID  = char(hdr(9:88));     % 80 ascii : local patient identification
header.recordID  = char(hdr(89:168));    % 80 ascii : local recording identification
header.startdate=char(hdr(169:176));     % 8 ascii : startdate of recording (dd.mm.yy)
header.starttime  = char(hdr(177:184));  % 8 ascii : starttime of recording (hh.mm.ss)
header.length = str2num (hdr(185:192));  % 8 ascii : number of bytes in header record
reserved = hdr(193:236); % [EDF+C       ] % 44 ascii : reserved
header.records = str2num (hdr(237:244)); % 8 ascii : number of data records (-1 if unknown)
header.duration = str2num (hdr(245:252)); % 8 ascii : duration of a data record, in seconds
header.channels = str2num (hdr(253:256));% 4 ascii : number of signals (ns) in data record

%%%% PART2 (DEPENDS ON QUANTITY OF CHANNELS)

header.labels=cellstr(char(fread(fid,[16,header.channels],'char')')); % ns * 16 ascii : ns * label (e.g. EEG FpzCz or Body temp)
header.transducer =cellstr(char(fread(fid,[80,header.channels],'char')')); % ns * 80 ascii : ns * transducer type (e.g. AgAgCl electrode)
header.units = cellstr(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * physical dimension (e.g. uV or degreeC)
header.physmin = str2num(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * physical minimum (e.g. -500 or 34)
header.physmax = str2num(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * physical maximum (e.g. 500 or 40)
header.digmin = str2num(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * digital minimum (e.g. -2048)
header.digmax = str2num(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * digital maximum (e.g. 2047)
header.prefilt =cellstr(char(fread(fid,[80,header.channels],'char')')); % ns * 80 ascii : ns * prefiltering (e.g. HP:0.1Hz LP:75Hz)
header.samplerate = str2num(char(fread(fid,[8,header.channels],'char')')); % ns * 8 ascii : ns * nr of samples in each data record
reserved = char(fread(fid,[32,header.channels],'char')'); % ns * 32 ascii : ns * reserved


f1=find(cellfun('isempty', regexp(header.labels, 'EDF Annotations', 'once'))==0); % Channels number with the EDF Annotations
f2=find(cellfun('isempty', regexp(header.labels, 'Status', 'once'))==0); % Channels number with the EDF Annotations
f=[f1(:); f2(:)];
%%%%%% PART 3: Loading of signals

%Structure of the data in format EDF:

%[block1 block2 .. , block N], where N=header.records
% Block structure:
% [(d seconds of 1 channel) (d seconds of 2 channel) ... (d seconds of ? channel)], Where ? - quantity of channels, d - duration of the block
% Ch = header.channels
% d = header.duration
if strcmpi(filename(end-2),'B')
    Ch_data = fread(fid,'bit24');
else
    Ch_data = fread(fid,'int16'); % Loading of signals
end


fclose(fid); % close a file

%%%%% PART 4: Transformation of the data
if header.records<0 % If the quantity of blocks is not known
    R=sum(header.duration*header.samplerate); % Length of one block
    header.records=fix(length(Ch_data)./R); % Quantity of written down blocks
end

% Separating a read signal into blocks
Ch_data=reshape(Ch_data, [], header.records);

% establishing calibration parametres



sf = (header.physmax - header.physmin)./(header.digmax - header.digmin);
dc = header.physmax - sf.* header.digmax;

data=cell(1, header.channels);
Rs=cumsum([1; header.duration*header.samplerate]); % строка индексов подблоко?канало?Rs(k):Rs(k+1)-1


% separating of signals of everyone the channel from blocks
% and recording of signals in structure of cells

for k=1:header.channels
    data{k}=reshape(Ch_data(Rs(k):Rs(k+1)-1, :), [], 1);
    if sum(k==f)==0 % non ?notation
        % Calibration of the data
        data{k}=data{k}.*sf(k)+dc(k);
    end
end

% PART 5: ANNOTATION READ
header.annotation.event={};
header.annotation.starttime=[];
header.annotation.duration=[];
header.annotation.data={};

if sum(f)>0
    try
        for p1=1:length(f)
            fid=fopen('test.bin','w');
            fwrite(fid,data{f(p1)},'bit24');
            fclose(fid);
            
            fid=fopen('test.bin','r');
            Annt = (fread(fid,'uint8'));
            fclose(fid);
            
            ANNONS = reshape(double(data{f(p1)}),3,length(data{f(p1)})/3)'*2.^[0;8;16];
            
            eventVector = bitand(ANNONS, hex2dec('00ffff'));
            disp(eventVector(1:100));
            % in principle the following bits could also be used, but it would require looking at both flanks for the epoch, cmrange and battery
            % if this code ever needs to be enabled, then it should be done consistently with the biosemi_bdf section in ft_read_event
            % epoch   = int8(bitget(dat, 16+1));
            % cmrange = int8(bitget(dat, 20+1));
            % battery = int8(bitget(dat, 22+1));
           
            
            
%             temp=typecast(int16(data{f(p1)}), 'uint8')';
%             for k=4:4:length(temp)
%                 if temp(k)==255
%                     temp((1:4)+k-4)=255-temp((1:4)+k-4);
%                 end
%             end
%             idx=setdiff(1:length(temp),[4:4:length(temp),3:4:length(temp)]);
%             temp1=temp(idx);
%             temp2=typecast(int16(data{f(p1)}), 'uint8')';
%             Annt=char(temp1); 

%             if strcmpi(filename(end-2),'B')
%                 temp=typecast(int32(data{f(p1)}), 'uint8')';
%                 for k=4:4:length(temp)
%                     if temp(k)==255
%                         temp((1:3)+k-4)=255-temp((1:3)+k-4);
%                     end
%                 end
%                 Annt=char(temp(setdiff(1:length(temp),4:4:length(temp))));
%             else
%                 Annt=char(typecast(int16(data{f(p1)}), 'uint8'))';
%             end
            
            
            % separate of annotation on blocks
            Annt=buffer(Annt, header.samplerate(f(p1)).*2, 0)';
            ANsize=size(Annt);
            for p2=1:ANsize(1)
                % search TALs starttime
                Annt1=Annt(p2, :);
                Tstart=regexp(Annt1, '+');
                Tstart=[Tstart(2:end) ANsize(2)];
                
                for p3=1:length(Tstart)-1
                    A=Annt1(Tstart(p3):Tstart(p3+1)-1); % TALs block
                    header.annotation.data={header.annotation.data{:} A};
                    
                    % duration and starttime TALs
                    Tds=find(A==20 | A==21);
                    if length(Tds)>2
                        td=str2num(A(Tds(1)+1:Tds(2)-1));
                        if isempty(td), td=0; end
                        header.annotation.duration=[header.annotation.duration(:); td];
                        header.annotation.starttime=[header.annotation.starttime(:); str2num(A(2:Tds(1)-1))];
                        header.annotation.event={header.annotation.event{:} A(Tds(2)+1:Tds(end)-1)};
                    else
                        header.annotation.duration=[header.annotation.duration(:); 0];
                        header.annotation.starttime=[header.annotation.starttime(:); str2num(A(2:Tds(1)-1))];
                        header.annotation.event={header.annotation.event{:} A(Tds(1)+1:Tds(end)-1)};
                    end
                end
            end
        end
        
        % delete annotation
        a=find(cell2mat(cellfun(@length, header.annotation.event, 'UniformOutput', false))==0);
        header.annotation.event(a)=[];
        header.annotation.starttime(a)=[];
        header.annotation.duration(a)=[];
        
    end
    
end

header.samplerate(f)=[];
header.channels=header.channels-length(f);
header.labels(f)=[];
header.transducer(f)=[];
header.units(f)=[];
header.physmin(f)=[];
header.physmax(f)=[];
header.digmin(f)=[];
header.digmax(f)=[];
header.prefilt(f)=[];
data(f)=[];
