function buildStimSequence_manyChannels(stimObj,chanLists,waveNum,pulseWait)
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
    
    
    % there is a limit on the number of commands can be in a sequence, so
    % if we are only stimulating on a single electrode, do not call
    % beginGroup and endGroup to minimize the number of commands

    
    stimObj.beginSequence()
        for i=1:numel(chanLists)
            stimObj.beginGroup()
                for k=1:numel(chanLists{i})
                    if(~iscell(waveNum))
                        stimObj.autoStim(chanLists{i}(k),waveNum)
                    else
                        stimObj.autoStim(chanLists{i}(k),waveNum{i}(k))
                    end
                end
            stimObj.endGroup()
        end
        stimObj.wait(pulseWait)
    stimObj.endSequence()

end