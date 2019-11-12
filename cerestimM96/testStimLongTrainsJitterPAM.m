%test cerestim96 recording during stim:
%testStimDoublePulse configures the stimulator with a pair of waveforms, one cathodal
%leading, the other anodal leading. testStim then initiates cerebus
%recording, followed by issuing alternating cathodal and anodal stimuli
% Two cathodal or anodal pulses are sent in succession with latency based
% on doublePulseLatency


%testStimDoublePulse requires the following variables
%amp1           :   amplitude of first pulse phase
%amp2           :   amplitude of second pulse phase
%pWidth1        :   width of first pulse phase
%pWidth2        :   width of second pulse phase
%interpulse     :   time between pulses
%interphase     :   interphase time of the waveform. This is also the time
%                       the sync line is high after the last pulse
%nPulses        :   pulses per waveform
%chanList       :   a vector of channel numbers that will be sequentially
%                       stimulated
%folder         :   name of the folder where data should be saved
%prefix         :   a string that will be appended to the front of every
%                       file name
%nomFreq        :   frequency that matlab will attempt to stimulate at
%nTests         :   number of times the script will issue a cathodal/anodal
%                       stim pair
%doublePulseLatency  : time in ms between the double pulses

pWidth1 = [200];
pWidth2 = [200];
interpulse = 53;
interphase = 53;
pol = 0; % 0 is cathodic first
IPI_mean = [10]; % % ms
amp1 = [40];
amp2 = [amp1];
pulse_amp_mod_freq = 1; % hz
pulse_amp_mod_depth = 20; % +- this value from amp1 and amp2
pulse_amp_mod_num_stim_codes = min(14,pulse_amp_mod_depth*2+1);

stim_code_amps = [floor(amp1+linspace(-pulse_amp_mod_depth,pulse_amp_mod_depth,pulse_amp_mod_num_stim_codes)),amp1]; % append base amplitude for non PAM condition

train_length = 4; % s

prefix=['Han_'];
chanList = 14;

correctionFactor = 0; % ms correction

nomFreq = [1/20]; %

nTests = 8; % 
num_files = 10;

folder='C:\H\';

if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end

waveforms = [];

for i = 1:numel(stim_code_amps)
    
    freq(i) = floor(1/((pWidth1(i)+pWidth2(i)+interphase+interpulse)*10^-6));%hz
    stimObj.setStimPattern('waveform',i,...
                        'polarity',pol,...
                        'pulses',1,...
                        'amp1',stim_code_amps(i),...
                        'amp2',stim_code_amps(i),...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq(i));
                    
    waveforms.parameters(i).polarity = pol; % 0 is cathodic first, look at matlab api
    waveforms.parameters(i).amp1 = stim_code_amps(i);
    waveforms.parameters(i).amp2 = stim_code_amps(i);
    waveforms.parameters(i).pWidth1 = pWidth1;
    waveforms.parameters(i).pWidth2 = pWidth2;
    waveforms.parameters(i).interphase = interphase;
    waveforms.parameters(i).freq = freq;
    waveforms.parameters(i).interpulse = interpulse;
    waveforms.parameters(i).nPulses = 1;
end


%establish cerebus connection
initializeCerebus();

%loop through channels and log a test file for each one:
for j=1:num_files
    disp(['working on file: ',num2str(j)])

    waveforms.waveSent = [];
    waveforms.ampSent = [];
    waveforms.chanSent = {};
    
    fName=startcerebusStimRecording(chanList,amp1,amp2,pWidth1(1),pWidth2(1),interpulse,j,folder,prefix,pol);
    for trial = 1:nTests
        % decide which trial type this is:
        % 0 = base case, stim at base amplitude and at IPI_mean
        % 1 = jitter frequency at base amplitude
        % 2 = PAM -- pulse amp modulation at IPI_mean
        % 3 = PAM and jitter frequency...fun....
        
        trial_type = floor(rand()*4);
        
        % define IPI between each pulse for each trial case (IPIs)
        % define stim code for each pulse for each trial case (stim_codes)
        switch trial_type
            case 0 % base case
                % use mean IPI
                num_pulses = train_length/(IPI_mean/1000) + 1;
                IPIs = IPI_mean + zeros(1,num_pulses);
                stim_codes = numel(stim_code_amps) + zeros(1,num_pulses);
                
            case 1 % jitter frequency, base amp
                num_pulses_max = train_length/(IPI_mean/1000) * 3;
                IPIs = poissrnd(IPI_mean,num_pulses_max,1);
                IPI_sum = cumsum(IPIs);
                IPIs = IPIs(1:find(IPI_sum > train_length*1000,1,'first'));
                
                stim_codes = numel(stim_code_amps) + zeros(1,numel(IPIs));
                
            case 2 % pulse amp modulation
                num_pulses = train_length/(IPI_mean/1000);
                IPIs = IPI_mean + zeros(1,num_pulses);
                pulse_times = [0,cumsum(IPIs(1:end))/1000];
                
                sin_vals = (sin(pulse_times*pulse_amp_mod_freq*2*pi)+1)/2;
                stim_codes = ceil((sin_vals)*(numel(stim_code_amps)-1));
                
            case 3 % PAM and jitter freq
                num_pulses_max = train_length/(IPI_mean/1000) * 3;
                IPIs = poissrnd(IPI_mean,num_pulses_max,1);
                IPI_sum = cumsum(IPIs);
                IPIs = IPIs(1:find(IPI_sum > train_length*1000,1,'first'));
                
                pulse_times = [0,cumsum(IPIs(1:end))/1000];
                sin_vals = (sin(pulse_times*pulse_amp_mod_freq*2*pi)+1)/2;
                stim_codes = ceil((sin_vals)*(numel(stim_code_amps)-1));
        end
        
        chan_idx = ceil(rand()*numel(chanList));
        disp(['Stim chan: ',num2str(chanList(chan_idx))]);
        
        waveforms.waveSent(end+1,1) = trial_type;
        waveforms.ampSent = [waveforms.ampSent;stim_codes'];
        waveforms.chanSent{end+1,1} = chanList(chan_idx);
        
        % deliver our stimuli
        for p = 1:numel(stim_codes)
            stimObj.groupStimulus(1,1,1,1,chanList(chan_idx),stim_codes(p))
            pause(IPIs(p)/1000);

        end
        nomFreq_idx = ceil(rand(1,1)*numel(nomFreq));

        pause(1/nomFreq(nomFreq_idx)+0.1); % pause for longer than needed just in case timing is off
        % tell cerestim to stop stimulating (it should be done, but to prevent
        % errors)
        stimObj.stop();
    end
    %stop recording:
    cbmex('fileconfig',fName,'',0)
    
    save(strcat(folder,fName(1:end-3),'waveformsSent_',num2str(j)),'waveforms');    
    
end

cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
pause(2)


%     for s = 1:nTests
%         disp(['working on pulse: ',num2str(i)])
% %         % deliver either a cathodal first or anodal first pulse
% %         stimObj.manualStim(chanList(j),mod(s,2)+1);
% %         % wait the desired latency
% %         pause(doublePulseLatency/1000);
% %         % deliver a second pulse
% %         stimObj.manualStim(chanList(j),mod(s,2)+1);
% %         % wait a bit
% %         pause(1/nomFreq - doublePulseLatency/1000 + rand()/20);
%     end
    %
