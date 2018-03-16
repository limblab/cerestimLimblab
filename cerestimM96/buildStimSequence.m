function buildStimSequence(stimObj,chanList,waveList,pulseWait)
    %builds a stim sequence in the stimulator that can be later executed by
    %the stimObj.play(#) command. 
    %this function takes in a list of channels what will be simultaneously
    %stimulated. The number of channels is limited by the number of
    %stimulation modules installed in the cerestim96, up to a max of 16.
    %
    %this function takes in a list of waveform numbers that will be
    %sequentially issued. If for instance you have configured the
    %stimulator with a cathodal pulse in waveform1, and an anodal pulse in
    %waveform 2, then entering [1, 2] will issue a cathodal pulse followed
    %by an anodal pulse.
    %
    %this function takes in the time between pulses in ms. This will be
    %used to separated the pulses in wavelist, and inserted at the end of
    %the series of stimuli. Note that the sync line will NOT be high during
    %this interval, and that this time will be applied starting AFTER the
    %interpulse interval time in the last waveform of the waveList
    
    stimObj.beginSequence()
        for i=1:numel(waveList)
            stimObj.beginGroup()
                for k=1:numel(chanList)
                    stimObj.autoStim(chanList(k),waveList(i))
                end
            stimObj.endGroup()
            stimObj.wait(pulseWait)
        end
    stimObj.endSequence()

end