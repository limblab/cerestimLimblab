function [] = useStimArrayToStimulate(stimObj,stim_array, wave_num)
    sleep_time = [0.9*ones(1,8),0*ones(1,8)];
    for ts = 1:size(stim_array.stim_pattern,2)
        
        num_elec = sum(stim_array.stim_pattern(:,ts));
        chan_num = stim_array.chans(stim_array.stim_pattern(:,ts)==1);
        if(num_elec > 0 && num_elec < 17)
            stimObj.groupStimulus(1,1,1,num_elec,chan_num',wave_num*ones(1,num_elec))
            java.lang.Thread.sleep(sleep_time(num_elec)+1);
        else
            java.lang.Thread.sleep(1.9+1); % in ms, 2.9ms is the latency for groupStimulus. +1 for some reason
        end
    end

end