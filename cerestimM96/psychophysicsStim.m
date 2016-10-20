%% configuration for stimulation
    ampStep=5;%in uA
    pWidth=200;%in us
    freq=200;%in hz
    duration=.400;%in s
    nPulses=floor(freq/duration);
    nStim=4;
    chans=[1];
%% set up stimulation:
    stimObj=cerestim96;
    %connect to cerestim96
    stimObj.connect();
    if ~stimObj.isConnected();
        error('psychophysicsStim:noStimulator','could not establish connection to stimulator')
    end
    %configure stimuli
    for i=0:nStim-1
        amp=(i+1)*ampStep;
        stimObj.setStimPattern(i,0,nPulses,amp,amp,pWidth,pWidth,53,freq)
    end
%% use cbmex to loop-wait for stim word. 
%When stim word happens call cerestim96 to start pulse train:   