%% configuration for stimulation
    ampStep=5;%in uA
    pWidth=200;%in us
    freq=200;%in hz
    duration=.400;%in s
    nPulses=floor(freq/duration);
    nStim=4;
    chans=[1];
%% configuration for cbmex
    wordStim=hex2dec('60');
    maxWait=500;
    pollInterval=.01;
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

while 1
    eTime=tic;
    while toc(eTime)<maxwait
        
        stimCodes=[];
        try
            words = read_words(); % read some data
        catch % maybe cbmex wasn't initialized yet
            CBInitWordRead(mode);
            words = read_words(); % read some data
        end
        if ~isempty(words)
            %scan for stim word:
            stimCodes=words( bitand(hex2dec('f0'),words(:,2)) == wordStim,2);
        end
        if ~isempty(stimCodes)
            if numel(stimcodes)>1
                warning('psychophysicsStim:multipleStimWords','expected a single stim word, and got more than one. Continuing using only the first stim word')
            end
            %issue the stimulus:
            stimObj.manualStim(chans,uint8(stimCodes))
            break
        end
    end
    pause(.00063+duration+.00053)
end


