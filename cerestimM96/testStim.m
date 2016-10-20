%test cerestim96 recording during stim:

%configure params
amp=20;%in uA
pWidth=200;%in us
interphase=53;
interpulse=53;
freq=floor(1/((2*pWidth+interphase+interpulse)*10^-6));%hz
nPulses=1;
nomFreq=10;
nTests=100;

if ~exist('stimObj','var')
    stimObj=cerestim96;
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end

    
stimObj.setStimPattern('waveform',1,...
                        'polarity',0,...
                        'pulses',nPulses,...
                        'amp1',amp,...
                        'amp2',amp,...
                        'width1',pWidth,...
                        'width2',pWidth,...
                        'interphase',interphase,...
                        'frequency',freq);
    
%establish cerebus connection
cbmex('open')
%start file storeage app, or stop recording if already started
cbmex('fileconfig',fName,'',0)
pause(1)
%loop through channels and log a test file for each one:
for j=1:96
    fNum=num2str(j,'%03d');
    fName=['E:\TestData\stimArtifact\cerestim96ArtifactTest-unmodifiedAmp_ch',num2str(j),'stim_',num2str(nPulses),'pulse_nominalFreq',num2str(nomFreq),'HZ_',fNum];
    %start recording:
    cbmex('fileconfig',fName,'testing stimulation artifacts',1)
    pause(.5)
    %deliver our stimuli:
    for i=1:nTests
    %    x=stimObj.getSequenceStatus();
        stimObj.manualStim(j,1)
        pause(1/nomFreq+rand/20);%wait a bit to get different timings relative to cerebus clock
    end
    pause(.5)
    %stop recording:
    cbmex('fileconfig',fName,'',0)
end
cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
