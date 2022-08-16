% import events from gtec experiment
% imp_file -> file containing measurement data (samples + trigger times)
% classinfo_file -> file containing experiment data (info about targets +
% nontargets). This file must contain a variable called "classinfo". 
% Format: filename.classinfo (classes x trials)
% e.g. class info file:
% TRIALS:    1  2  3  4  5  6  7  8  9 10 11 12 ..... 
% CLASS 1    0  0  0  1  0  1  0  0  1  0  0  0
% CLASS 2    1  1  1  0  1  0  1  1  0  0  0  0
% CLASS 3    0  0  0  0  0  0  0  0  0  1  1  1
%   :
%   :

function [EEGout] = read_gtec_hdf5events(EEG, imp_file, classinfo_file)

% get timepoints of events
try
    h5read(imp_file,'/AsynchronData/Time');
    h5read(imp_file,'/AsynchronData/TypeID');
    h5read(imp_file,'/AsynchronData/Value');   
catch
    errordlg2('No event information is available in selected data file!','No events found')
    return;
end

    eventtimes = h5read(imp_file,'/AsynchronData/Time');
% get eventinfo from file
% contains information about triggers -> targets and nontargets
% format: [#OfClasses x #OfTrials]
% experimentinfo(1,:) == 1 -> Class 1
% experimentinfo(2,:) == 1 -> Class 2
% experimentinfo(3,:) == 1 -> Class 3
if classinfo_file ~= 0
    experimentinfo=load(classinfo_file);
    nrTrials = size(experimentinfo.classinfo,2);
    nrClasses = size(experimentinfo.classinfo,1);

    eventtypes = zeros(1,nrTrials);
    for trial=1:nrTrials
        eventtypes(trial) = find(experimentinfo.classinfo(:,trial));
    end

    % check sizes
    if size(eventtimes,2) > size(eventtypes,2)
        errordlg2('Measurement - Eventinfo inconsistent!!');
        return;
    end

    % how many different types are in the hdf5 asynchronous data
    events = unique(eventtypes);
    type_cnt = length(events);
    
    load_classinfo = questdlg2('Do you want to rename the events found in the imported data?','Events found','Yes','No','No');
    event_names = cell(1,type_cnt);
    for event=1:type_cnt
            event_names{event} = ['EVENT' sprintf('%02d',event)];
    end
    if strcmpi(load_classinfo,'Yes')
        for event=1:type_cnt
            prompt={['Event: Type ' num2str(events(event))]...
                %'Enter epoch limits in relation to event:',...
                };
            name='Input name for event';
            numlines=1;
            defaultanswer=event_names(event);
            answer=inputdlg2(prompt,name,numlines,defaultanswer);
            if(~strcmpi(answer{1},''))
                event_names(event) = answer;
            end
        end
    end
    
    % initialize event / urevent array with structures
    EEG.event = [];
    EEG.urevent = [];
    EEG.event = struct('latency',{},'type',{},'urevent',{});
    EEG.urevent = struct('latency',{},'type',{});

    for eventno=1:size(eventtimes,2)
        % create event / urevent structures
        event.latency = eventtimes(eventno);
        urevent.latency = eventtimes(eventno);
        event.type = event_names{find(events==eventtypes(eventno),1,'first')};
        urevent.type = event_names{find(events==eventtypes(eventno),1,'first')};
        event.urevent = eventno;    

        % add event / urevent
        EEG.event(eventno) = event;
        EEG.urevent(eventno) = urevent;
    end
    EEGout = EEG;
else
    % no classinfo file loaded -> use data in hdf5 file
    eventtypes = h5read(imp_file,'/AsynchronData/TypeID');
    eventvalues = h5read(imp_file,'/AsynchronData/Value');
    
    if length(eventtypes) == 0
        
        return;
    end
    % how many different types are in the hdf5 asynchronous data
    events = unique(eventtypes);
    type_cnt = length(events);
    
    
    load_classinfo = questdlg2('Do you want to rename the events found in the imported data?','Events found','Yes','No','No');
    event_names = cell(1,type_cnt);
    for event=1:type_cnt
            event_names{event} = ['EVENT' sprintf('%02d',event)];
    end
    if strcmpi(load_classinfo,'Yes')
        for event=1:type_cnt
            prompt={['Event: Type ' num2str(events(event)) ', Value ' num2str(eventvalues(find(eventtypes==events(event),1,'first')))]...
                %'Enter epoch limits in relation to event:',...
                };
            name='Input name for event';
            numlines=1;
            defaultanswer=event_names(event);
            answer=inputdlg2(prompt,name,numlines,defaultanswer);
            if(~strcmpi(answer{1},''))
                event_names(event) = answer;
            end
        end
    end
        
    % check sizes
    if size(eventtimes,2) > size(eventtypes,2)
        fprintf('Measurement - Eventinfo inconsistent!!');
        return;
    end
    
    % initialize event / urevent array with structures
    EEG.event = [];
    EEG.urevent = [];
    EEG.event = struct('latency',{},'type',{},'urevent',{});
    EEG.urevent = struct('latency',{},'type',{});

    for eventno=1:size(eventtimes,2)
        % create event / urevent structures
        event.latency = eventtimes(eventno);
        urevent.latency = eventtimes(eventno);
        event.type = event_names{find(events==eventtypes(eventno),1,'first')};
        urevent.type = event_names{find(events==eventtypes(eventno),1,'first')}; 
        event.urevent = eventno;    

        % add event / urevent
        EEG.event(eventno) = event;
        EEG.urevent(eventno) = urevent;
    end
    EEGout = EEG;
end