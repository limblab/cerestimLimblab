function [] = useStimArrayToStimulate(stimObj,stim_array)

    for arr_idx = 1:size(stim_array.stim_pattern,2)
        num_elec = sum(stim_array.stim_pattern(:,arr_idx));
        chan_num = stim_array.chans(find(stim_array.stim_pattern(:,arr_idx)));
        if(num_elec > 0 && num_elec < 17)
            stimObj.groupStimulus(1,1,1,num_elec,chan_num',ones(num_elec,1)')
        else
            pause(0.002)
        end
    end

end