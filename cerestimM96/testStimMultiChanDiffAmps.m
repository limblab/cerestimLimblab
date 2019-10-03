%test cerestim96 recording during stim:
%testMultiChanDiffAmps stimulates on multiple channels with each channel
%having a different amplitude. Also supports trains.


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

aux_pWidth1 = [200];
aux_pWidth2 = [200];


interpulse = 53;
interphase = 53;
pol = 0; % 0 is cathodic first


doublePulseLatency = [10]; % -1 = single pulse, % 20, 50, 100, 200
amp1 = [0,30];
amp2 = [0,30];

aux_amp1 = [0,20,30,40];
aux_amp2 = [0,20,30,40];

nPulses = [11];

correctionFactor = -0.1; % ms correction

nomFreq = [1.5]; % freq to stim at
nTests = 200; % 
num_files = 8;
chanList = [92]; % can only handle single channel stim, so this should be a single channel
aux_chanList = [91,63,47]; % will stimulate on ONE of these as well


prefix=['Han_'];
folder='C:\H\';

%configure params
% freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz

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

% setup waveform for base channel
for i = 1:numel(amp1)
    
    freq(i) = floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz
    if(amp1(i) > 0)
        stimObj.setStimPattern('waveform',i,...
                            'polarity',pol,...
                            'pulses',1,...
                            'amp1',amp1(i),...
                            'amp2',amp2(i),...
                            'width1',pWidth1,...
                            'width2',pWidth2,...
                            'interphase',interphase,...
                            'frequency',freq(i));
    else
        stimObj.disableStimulus(i);
    end
                    
    waveforms.parameters(i).polarity = pol; % 0 is cathodic first, look at matlab api
    waveforms.parameters(i).amp1 = amp1(i);
    waveforms.parameters(i).amp2 = amp2(i);
    waveforms.parameters(i).pWidth1 = pWidth1;
    waveforms.parameters(i).pWidth2 = pWidth2;
    waveforms.parameters(i).interphase = interphase;
    waveforms.parameters(i).freq = freq(i);
    waveforms.parameters(i).interpulse = interpulse;
    waveforms.parameters(i).nPulses = 1;
end

% setup aux wavefomrs
for i = 1:numel(aux_amp1)
    counter = i + numel(amp1);
    freq(counter) = floor(1/((aux_pWidth1+aux_pWidth2+interphase+interpulse)*10^-6));%hz
    if(aux_amp1(i) > 0)
        stimObj.setStimPattern('waveform',counter,...
                            'polarity',pol,...
                            'pulses',1,...
                            'amp1',aux_amp1(i),...
                            'amp2',aux_amp2(i),...
                            'width1',aux_pWidth1,...
                            'width2',aux_pWidth2,...
                            'interphase',interphase,...
                            'frequency',freq(counter));
    else
        stimObj.disableStimulus(counter);
    end
    
    waveforms.parameters(counter).polarity = pol; % 0 is cathodic first, look at matlab api
    waveforms.parameters(counter).amp1 = aux_amp1(i);
    waveforms.parameters(counter).amp2 = aux_amp2(i);
    waveforms.parameters(counter).pWidth1 = aux_pWidth1;
    waveforms.parameters(counter).pWidth2 = aux_pWidth2;
    waveforms.parameters(counter).interphase = interphase;
    waveforms.parameters(counter).freq = freq(counter);
    waveforms.parameters(counter).interpulse = interpulse;
    waveforms.parameters(counter).nPulses = 1;
end


%establish cerebus connection
initializeCerebus();
%loop through channels and log a test file for each one:
for j=1:num_files
    disp(['working on chan: ',num2str(chanList)])
    waveforms.waveSent = [];
    waveforms.chanSent = {};
    
    fName=startcerebusStimRecording(chanList,amp1,amp2,pWidth1(1),pWidth2(1),interpulse,j,folder,prefix,pol);
    for trial = 1:nTests
        % get number of pulses and latency between pulses
        dpl_idx = ceil(rand()*numel(doublePulseLatency));
        if(doublePulseLatency(dpl_idx) <= 0)
            num_pulses = 1;
        else
            num_pulses = nPulses(dpl_idx);
        end
        
        % get wave_idx based on aux_channel amplitudes
        wave_idx = ceil(rand()*numel(amp1));
        aux_wave_idx = ceil(rand()*numel(aux_amp1)) + numel(amp1); % offset based on base channel amplitudes
        % get chan sent from chanList and aux_chanList
        aux_chan = aux_chanList(ceil(rand()*numel(aux_chanList)));
        
        % if we are actually stimulating, store waves. Technically, we
        % don't stimulate if both amps are 0 (no sync line activity)
        if(amp1(wave_idx) > 0 || aux_amp1(aux_wave_idx-numel(amp1)) > 0)
            waveforms.waveSent(end+1,:) = [wave_idx,aux_wave_idx];
            waveforms.chanSent{end+1,1} = [chanList,aux_chan];
        end
        % build stim sequence
        stimObj.beginSequence()
        disp([wave_idx,aux_wave_idx])
        for i=1:num_pulses % cathodal then anodal
            % stimulate once on all channels
            
            stimObj.beginGroup()
            if(amp1(wave_idx) > 0)
                stimObj.autoStim(chanList,wave_idx); % only use waveform 1 for the base channel
            end
            if(aux_amp1(aux_wave_idx-numel(amp1)) > 0)
                stimObj.autoStim(aux_chan,aux_wave_idx);
            end
            stimObj.endGroup();
            % pause for doublePulseLatency
            if(i ~= num_pulses)
                stimObj.wait(doublePulseLatency(dpl_idx) + correctionFactor)
            end
            % wait the nominal frequency
        end
        stimObj.endSequence()

        % deliver our stimuli
        if(amp1(wave_idx) > 0 || aux_amp1(aux_wave_idx - numel(amp1)) > 0) % will bug out if both are 0 I think
            stimObj.play(1);
        end
        nomFreq_idx = ceil(rand(1,1)*numel(nomFreq));
        pause(1/nomFreq(nomFreq_idx)) % 
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
