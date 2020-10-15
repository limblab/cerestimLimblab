stim_rate = 0.7;
bump_rate = 0.7;
disp('here');
stim_bump_rate = stim_rate*bump_rate
stim_alone = stim_rate*(1-bump_rate)
bump_alone = (1-stim_rate)*bump_rate
catch_rate = (1-stim_rate)*(1-bump_rate)
