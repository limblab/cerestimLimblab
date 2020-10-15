%test cerestim96 recording during stim:

%configure params

pWidth=200;%in us
amp1=60;%in uA
pWidth1=200;%in usCoul
amp2=60;%in uA
pWidth2=200;%in us
interphase=53;
% 
interpulse=53;
%
freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz
nPulses=1;
nomFreq=200;
nTests=100;
chanList=[1:96];


if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end

stimObj.setStimPattern('waveform',1,...
                        'polarity',0,...
                        'pulses',nPulses,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq);
 stimObj.setStimPattern('waveform',2,...
                        'polarity',1,...
                        'pulses',nPulses,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq);   
    

%loop through channels and stim each one:
for j=1:numel(chanList)
     pause(1/nomFreq);
    for i=1:nTests
        disp(['working on pulse: ',num2str(i)])
        %deliver our stimuli:
        stimObj.manualStim(chanList(j),1);
         pause(1/nomFreq);
    end
end
cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
