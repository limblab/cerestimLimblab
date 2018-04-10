% This file is mean to be called by 'script_runStimAndRecord.' These two functions 
% use a set of wave shapes (amplitude, pulsewidth, interphase, interpulse, polarities)
% and stimulates with single pulses randomly at a set frequency. 
% This is used when the order of pulses should be interleaved during an experiment. 
% Stimulation parameters and which waveform/channel is stimulated is stored in  a
% '..._waveformsSent' mat file. 


% Waveform parameters: All array sizes should be the same, the ith waveform
% is built by selecting the ith parameter in each of the following arrays
% amp1: amplitude of the first phase
% amp2: amplitude of the second phase
% pWidth1: pulse width of the first phase
% pWidth2: pulse width of the second phase
% interphase: time between phases (min 53us)
% interpulse: time between pulses (for fast settle circuit, 300us is common)
% polarities: polarity of the waveform (0 cathodal, 1 anodal)

% nPulses: number of pulses in a single train (1 for a single pulse)
% nomFreq: frequency to stimulate
% nTests: number of trains
% chanList: list of channels to stimulate. Channels and waveform are
%           independent
% saveImpedance: run an impedance test?
% folder: folder to save files in
% prefix: prefix for file name
if(numel(chanList) > 1)
    interleaveChanList = 1;
else
    interleaveChanList = 0;
end

if(numel(amp1) > 1)
    interleaveAmplitude = 1;
else
    interleaveAmplitude = 0;
end

%% deal with varargin
for v = 1:2:numel(arg)
    switch arg{v}
        case 'interleaveChanList'
            interleaveChanList = arg{v+1};
    end
end

if(numel(chanList)==1)
    interleaveChanList = 0;
end

% set up stim object and connect
if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end

%establish cerebus connection
initializeCerebus();

%% set up stim patterns

patternCounter = 1;
waveforms = [];

% generate waveforms
for idx = 1:numel(amp1)
    freq=floor(1/((pWidth1(idx)+pWidth2(idx)+interphase(idx)+interpulse(idx))*10^-6));%hz
    stimObj.setStimPattern('waveform',patternCounter,...
                            'polarity',polarities(idx),... % 0 = cathodic first
                            'pulses',nPulses,...
                            'amp1',amp1(idx),...
                            'amp2',amp2(idx),...
                            'width1',pWidth1(idx),...
                            'width2',pWidth2(idx),...
                            'interphase',interphase(idx),...
                            'frequency',freq);

    waveforms.parameters(patternCounter).polarity = 0; % 0 is cathodic first, look at matlab api
    waveforms.parameters(patternCounter).amp1 = amp1(idx);
    waveforms.parameters(patternCounter).amp2 = amp1(idx);
    waveforms.parameters(patternCounter).pWidth1 = pWidth1(idx);
    waveforms.parameters(patternCounter).pWidth2 = pWidth2(idx);
    waveforms.parameters(patternCounter).interphase = interphase(idx);
    waveforms.parameters(patternCounter).freq = freq;
    waveforms.parameters(patternCounter).interpulse = interpulse(idx);

    patternCounter = patternCounter + 1;
    
end
%% test and save impedance:
if(saveImpedance == 1)
    t=clock;
        t(6)=round(t(6));
        tStr='';
        for k=1:6
            tStr=[tStr,num2str(t(k)),'_']
        end
    impedanceData=stimObj.testElectrodes();
    save([folder,'impedance0',tStr,'.mat'],'impedanceData','-v7.3')
end
%% log a test file:
if(interleaveChanList) % for loop operates once
    maxChannels = 1;
else
    maxChannels = numel(chanList); % for loop operates once per channel
end

for j=1:maxChannels
    if(~interleaveChanList)
        disp(['working on chan: ',num2str(chanList(j))])
    end

    endNumber = 1;
  
    if(interleaveChanList && ~interleaveAmplitude)
        fName=[folder,prefix,'_chanINTERLEAVEDstim_A1-',num2str(amp1),'_',num2str(endNumber)];%'_A2-',num2str(amp2),'_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse-',num2str(interpulse),'_',num2str(endNumber)];
    elseif(~interleaveChanList && interleaveAmplitude)
        fName=[folder,prefix,'_chan',num2str(chanList(j)),'stim_A1-INTERLEAVED_A2-INTERLEAVED','_',num2str(endNumber)];%num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse-',num2str(interpulse),'_',num2str(endNumber)];        
    elseif(interleaveChanList && interleaveAmplitude)
        fName=[folder,prefix,'_chanINTERLEAVEDstim_A1-INTERLEAVED_A2-INTERLEAVED','_',num2str(endNumber)];%num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse-',num2str(interpulse),'_',num2str(endNumber)];        
    else % no interleaving
        fName=[folder,prefix,'_chan',num2str(chanList(j)),'stim_A1-',num2str(amp1),'_',num2str(endNumber)];%'_A2-',num2str(amp2),'_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse-',num2str(interpulse),'_',num2str(endNumber)];        
    end
        
    while exist(strcat(fName,'.nev')) > 0
        endNumber = endNumber + 1;
        if(interleaveChanList && ~interleaveAmplitude)
            fName=[folder,prefix,'_chanINTERLEAVEDstim_A1-',num2str(amp1),'_',num2str(endNumber)];%'_A2-',num2str(amp2),'_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse-',num2str(interpulse),'_',num2str(endNumber)];
        elseif(~interleaveChanList && interleaveAmplitude)
            fName=[folder,prefix,'_chan',num2str(chanList(j)),'stim_A1-INTERLEAVED_A2-INTERLEAVED','_',num2str(endNumber)];%num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse-',num2str(interpulse),'_',num2str(endNumber)];        
        elseif(interleaveChanList && interleaveAmplitude)
            fName=[folder,prefix,'_chanINTERLEAVEDstim_A1-INTERLEAVED_A2-INTERLEAVED','_',num2str(endNumber)];%num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse-',num2str(interpulse),'_',num2str(endNumber)];        
        else % no interleaving
            fName=[folder,prefix,'_chan',num2str(chanList(j)),'stim_A1-',num2str(amp1),'_',num2str(endNumber)];%'_A2-',num2str(amp2),'_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse-',num2str(interpulse),'_',num2str(endNumber)];        
        end
    end
    [~,fstr,ext]=fileparts(fName);
    
    %% start recording:

    ctr=0;
    tmp=dir(folder);
    while isempty(cell2mat(strfind({tmp.name},fstr))) & ctr<10
        cbmex('fileconfig',fName,'',0)
        pause(.5);
        cbmex('fileconfig',fName,'testing stimulation artifacts',1);
        pause(1);
        ctr=ctr+1;
        tmp=dir(folder);
    end
    if ctr==10
       warning('tried to start recording and failed') 
    end
    pause(10)
    %% deliver our stimuli:
    waveforms.waveSent = [];
    waveforms.chanSent = [];
    
    for i=1:nTests
        if(interleaveAmplitude)
            waveSent = ceil(rand()*numel(waveforms.parameters));
            waveforms.waveSent(end+1,1) = waveSent;
        else
            waveSent = 1;
            waveforms.waveSent(end+1,1) = 1;
        end
        if(interleaveChanList)
            chanSent = chanList(ceil(rand()*numel(chanList)));
            waveforms.chanSent(end+1,1) = chanSent;
        else
            chanSent = chanList(j);
            waveforms.chanSent(end+1,1) = chanList(j);
        end
    %    x=stimObj.getSequenceStatus();
        stimObj.manualStim(chanSent,waveSent)

        pause(1/nomFreq+rand/10);%wait a bit to get different timings relative to cerebus clock
        
    end
    
    pause(5)
    
    %% stop recording:
    cbmex('fileconfig',fName,'',0)
%     impedanceData=stimObj.testElectrodes();
%     save([folder,'impedance', tStr,num2str(j),'.mat'],'impedanceData','-v7.3')
    pause(2)
    
    if(endNumber >= 10)
        save(strcat(folder,fstr(1:end-2),'waveformsSent_',num2str(endNumber)),'waveforms');    
    else
        save(strcat(folder,fstr(1:end-1),'waveformsSent_',num2str(endNumber)),'waveforms');    
    end
end

% clear stim object and leave the function
cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj

pause(2);


