function [ sequence_array, reps ] = buildAudioSequence( desired_dur, sine_freq, max_amp)

dt=1/30; % ms, minimum is like 0.034 because 30*0.03334 is 1

% build sequence for 1 sine wave, then repeat as much as needed.
% Technically doesn't give us exactly the desired_duration, but will be
% close with high frequencies and nice numbers.

t_data = (0:dt:1000/sine_freq)/1000; % convert to s
amp_data = max_amp*sin(2*pi*sine_freq*t_data) + max_amp; % can't be less than zero

sequence_array = reshape([round(dt*30*ones(size(amp_data))); amp_data],1,2*numel(amp_data));
reps = ceil(desired_dur/(1/sine_freq));


end

