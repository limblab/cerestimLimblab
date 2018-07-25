function buildStimSequence_biomimetic(stimObj,wave_mapping,pulseWait)
    %builds a stim sequence in the stimulator that can be later executed by
    
   
    stimObj.beginSequence()
    stimObj.beginGroup()
        for i=1:size(wave_mapping,1)
            stimObj.autoStim(wave_mapping(i,1),wave_mapping(i,3))
        end
    stimObj.endGroup()
    stimObj.endSequence()



end