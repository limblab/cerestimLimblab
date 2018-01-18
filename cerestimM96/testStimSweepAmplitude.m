%test cerestim96 recording during stim:

% save params
folder='C:\data\stimTesting\ArtificialMonkey_20171227_noFastSettle\';
prefix='ArtificialMonkey_20171227_modAmp'; % no _ needed

%configure params
chanList=[1:10];

minAmp = 1;
maxAmp = 100;
ampStep = 1;
numSweeps = 10;

pWidth1=200;%in us
pWidth2=200;%in us

interphase=53;
interpulse=250;

freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz

nPulses=1;
nomFreq=10;
nTests=2;

% make stim object
if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end

% impedanceData=stimObj.testElectrodes();
% save([folder,'impedance0',tStr,'.mat'],'impedanceData','-v7.3')

%establish cerebus connection
cbmex('open')
%start file storeage app, or stop recording if already started
fName='temp';
cbmex('fileconfig',fName,'',0)
pause(1)

% sweep through amplitudes numSweep times
for j = 1:numel(chanList)
    
    disp(['working on chan: ',num2str(chanList(j))])
    fNum=num2str(j,'%03d');

    t=clock;
    t(6)=round(t(6));
    tStr='';
    for k=1:6
        tStr=[tStr,num2str(t(k)),'_'];
    end
    
    
    fName=[folder,prefix,'_chan',num2str(chanList(j)),'_stim_minAmp-',num2str(minAmp),'_maxAmp-',num2str(maxAmp),'_ampStep-',num2str(ampStep),'_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse',num2str(interpulse),'_',tStr,fNum];

    [~,fstr,ext]=fileparts(fName);
    %start recording:

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
    pause(10) % pause after starting recording
    
    for sweepIdx = 1:numSweeps % sweep through amps
        for amp = minAmp:ampStep:maxAmp
            stimObj.setStimPattern('waveform',1,... % set stim pattern based on amp
                                    'polarity',0,...
                                    'pulses',nPulses,...
                                    'amp1',amp,...
                                    'amp2',amp,...
                                    'width1',pWidth1,...
                                    'width2',pWidth2,...
                                    'interphase',interphase,...
                                    'frequency',freq);
             stimObj.setStimPattern('waveform',2,...
                                    'polarity',1,...
                                    'pulses',nPulses,...
                                    'amp1',amp,...
                                    'amp2',amp,...
                                    'width1',pWidth1,...
                                    'width2',pWidth2,...
                                    'interphase',interphase,...
                                    'frequency',freq);   

            
            %loop through channels and log a test file for each one:
                %deliver our stimuli:
            for i=1:nTests
            %    x=stimObj.getSequenceStatus();
                if mod(i,2)
                    stimObj.manualStim(chanList(j),1);
                else
                    stimObj.manualStim(chanList(j),2);
                end
    %             if(mod(i,100) == 0)
    %                 disp(i)
    %             end
                pause(1/nomFreq);%+rand/20);%wait a bit to get different timings relative to cerebus clock
            end

        end %amp for

        pause(1) % pause a bit between sweeps?
    end % sweeps for
    
    pause(0.5) % pause before ending recoring
    cbmex('fileconfig',fName,'',0)    
end % chanList for


cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj