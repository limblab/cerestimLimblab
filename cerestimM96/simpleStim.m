%stimulate channels using cerestimM96

%configure params

%configure stim params
amp=50;%in uA
pWidth=200;%in us
amp1=50;%in uA
pWidth1=200;%in us
amp2=50;%in uA
pWidth2=200;%in us
interphase=53;%us between cathodal and anodal
interpulse=53;%us between pulses in a train
%
freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz
nPulses=1;%how many pulses per train
nomFreq=10;%frequency at which pulse trains are delivered
nTests=100;%how many pulse trains
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
    
%loop through channels:
for j=1:numel(chanList)
    disp(['working on chan: ',num2str(chanList(j))])
    
    %deliver our stimuli:
    for i=1:nTests
    %    x=stimObj.getSequenceStatus();
        if mod(i,2)
            stimObj.manualStim(chanList(j),1);
        else
            stimObj.manualStim(chanList(j),2);
        end
        
    end
    pause(.5)
end


stimObj.disconnect();
stimObj.delete()
clear stimObj
