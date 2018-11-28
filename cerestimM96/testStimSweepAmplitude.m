%test cerestim96 recording during stim:

%configure params
chanList=[95];
chanList_small = 1;
amp_small = 1;
freq_small = 1500;

amp_small = 1;
amp = 10;

pol = 0; % 0 = cathodal first

pWidth1=200;%in us
pWidth2=200;%in us

interphase=53;
interpulse=53; %

freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz

nPulses=1;

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
initializeCerebus();

% sweep through amplitudes numSweep times

    stimObj.setStimPattern('waveform',1,... % set stim pattern based on amp
                            'polarity',pol,...
                            'pulses',nPulses,...
                            'amp1',amp,...
                            'amp2',amp,...
                            'width1',pWidth1,...
                            'width2',pWidth2,...
                            'interphase',interphase,...
                            'frequency',freq);
     
                                
    stimObj.setStimPattern('waveform',2,...
                            'polarity',0,...
                            'pulses',100,...
                            'amp1',amp_small,...
                            'amp2',amp_small,...
                            'width1',pWidth1,...
                            'width2',pWidth2,...
                            'interphase',interphase,...
                            'frequency',freq_small);   
                                

            
    stimObj.beginSequence()
    stimObj.beginGroup()
    stimObj.autoStim(chanList,1)
    stimObj.autoStim(chanList_small,2)
    stimObj.endGroup()
    stimObj.endSequence()
    
    stimObj.trigger(1) % rising edge;
                 

%%
stimObj.trigger(0);
cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
