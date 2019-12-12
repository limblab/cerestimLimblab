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

pWidth1 = repmat([200],1,12);
pWidth2 = pWidth1;
interpulse = 53;
interphase = 53;
pol = 0; % 0 is cathodic first
doublePulseLatency = 1000./[125,125,125,100,100,100,75,75,75,50,50,50]; % -1 = single pulse, % 20, 50, 100, 200
amp1 = [20,40,60,20,40,60,20,40,60,20,40,60];
amp2 = amp1;
nPulses = [125,125,125,100,100,100,75,75,75,50,50,50]*4.2; % 4 second long trains

folder='C:\H\';
prefix=['Han_'];

chanList = 93;

correctionFactor = -0.4; % ms correction

nomFreq = [1/20]; %

nTests = 8; % 
num_files = 12;

if(mod(nTests*num_files,numel(nPulses)) ~= 0)
    error('number of stimuli not divisible by number of conditions');
end

wave_sent_list = repmat([1:1:numel(nPulses)],1,floor(nTests*num_files/numel(nPulses)));
wave_sent_list = wave_sent_list(randperm(numel(wave_sent_list)));
wave_counter = 1;


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

for i = 1:numel(amp1)
    
    freq(i) = floor(1/((pWidth1(i)+pWidth2(i)+interphase+interpulse)*10^-6));%hz
    stimObj.setStimPattern('waveform',i,...
                        'polarity',pol,...
                        'pulses',1,...
                        'amp1',amp1(i),...
                        'amp2',amp2(i),...
                        'width1',pWidth1(i),...
                        'width2',pWidth2(i),...
                        'interphase',interphase,...
                        'frequency',freq(i));
                    
    waveforms.parameters(i).polarity = pol; % 0 is cathodic first, look at matlab api
    waveforms.parameters(i).amp1 = amp1(i);
    waveforms.parameters(i).amp2 = amp2(i);
    waveforms.parameters(i).pWidth1 = pWidth1(i);
    waveforms.parameters(i).pWidth2 = pWidth2(i);
    waveforms.parameters(i).interphase = interphase;
    waveforms.parameters(i).freq = freq;
    waveforms.parameters(i).interpulse = interpulse;
    waveforms.parameters(i).nPulses = 1;
    waveforms.parameters(i).nPulsesTrain = nPulses(i);
    waveforms.parameters(i).TrainIPI = doublePulseLatency(i);
end


%establish cerebus connection
initializeCerebus();
%loop through channels and log a test file for each one:
for j=1:num_files
    disp(['working on file: ',num2str(j)])

    waveforms.waveSent = [];
    waveforms.chanSent = {};
    
    fName=startcerebusStimRecording(chanList,amp1,amp2,pWidth1(1),pWidth2(1),interpulse,j,folder,prefix,pol);
    for trial = 1:nTests
%         dpl_idx = ceil(rand()*numel(doublePulseLatency));
        dpl_idx = wave_sent_list(wave_counter);
        wave_counter = wave_counter + 1;
        if(doublePulseLatency(dpl_idx) <= 0)
            num_pulses = 1;
        else
            num_pulses = nPulses(dpl_idx);
        end
        
        if(numel(amp1) > 1)
            wave_idx = dpl_idx;
        else
            wave_idx = 1;
        end
        
        chan_idx = ceil(rand()*numel(chanList));
        disp(['Stim chan: ',num2str(chanList(chan_idx))]);
        
        waveforms.waveSent(end+1,1) = wave_idx;
        waveforms.chanSent{end+1,1} = chanList(chan_idx);
        
        % build stim sequence
        stimObj.beginSequence()
        % stimulate once on all channels
            
        stimObj.autoStim(chanList(chan_idx),wave_idx) % only use waveform 1
        stimObj.wait(doublePulseLatency(dpl_idx) + correctionFactor)
        % end sequence
        stimObj.endSequence()

        % deliver our stimuli
        stimObj.play(num_pulses);
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
