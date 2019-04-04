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
amp1 = 50;
amp2 = 50;
pWidth1 = 200;
pWidth2 = 200;
interpulse = 53;
interphase = 53;
pol = 0; % 0 is cathodic first
doublePulseLatency = [-1,5,10,20,50,10,20,200]; % -1 = single pulse
correctionFactor = 0; % ms correction

nPulses = [1,41,21,11,5,2,2,2];
nomFreq = 2;
nTests = 250;
num_files = 8;
chanList = [21]; % can only handle single channel stim

prefix=['Han_20190403_chan21dukeProjBox_dblPulse_trainExp'];
folder='C:\data\Han\Han_20190403_dblPulse_trains\';

%configure params
freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz

if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end

stimObj.setStimPattern('waveform',1,...
                        'polarity',pol,...
                        'pulses',1,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq);


%establish cerebus connection
initializeCerebus();
%loop through channels and log a test file for each one:
for j=1:num_files
    disp(['working on chan: ',num2str(chanList)])
    fName=startcerebusStimRecording(chanList,amp1,amp2,pWidth1,pWidth2,interpulse,j,folder,prefix,pol);
    for trial = 1:nTests
        dpl_idx = ceil(rand()*numel(doublePulseLatency));
        if(doublePulseLatency(dpl_idx) <= 0)
            num_pulses = 1;
        else
            num_pulses = nPulses(dpl_idx);
        end
        
        % build stim sequence
        stimObj.beginSequence()
        for i=1:num_pulses % cathodal then anodal
            % stimulate once on all channels
            stimObj.autoStim(chanList,1) % only use waveform 1
            % pause for doublePulseLatency
            if(i ~= num_pulses)
                stimObj.wait(doublePulseLatency(dpl_idx) - correctionFactor)
            end
            % wait the nominal frequency
        end
        stimObj.endSequence()

        % deliver our stimuli
        stimObj.play(1);
        pause(1/nomFreq + 0.01) % pause for longer than needed just in case timing is off
        % tell cerestim to stop stimulating (it should be done, but to prevent
        % errors)
        stimObj.stop();
    end
    %stop recording:
    cbmex('fileconfig',fName,'',0)
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
