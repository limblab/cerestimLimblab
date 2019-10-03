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
interpulse = 300;
interphase = 53;

nPulses = 50; % number of pulses in a train %% beginSequence can only have 128 commands, 
% which limits us to 31 pulses in a train if we do both cathodal and anodal
% trains

pulseLatency = 1000/100; % lets do 2, 4, 6 ,8, 10, 20, 30 % in ms

nomFreq = 2; % frequency between start of trains
nTests = 5; % n times to do a train (total trains = this*2 because anodal then cathodal trains)

chanList = [96]; % 

prefix=['Butter_20180407_cuneate_',num2str(pulseLatency),'_nPulses',num2str(nPulses)];
folder='C:\data\Butter\Butter_20180407_cuneateStimMapping\';

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
                        'polarity',0,...
                        'pulses',1,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq);
 stimObj.setStimPattern('waveform',2,...
                        'polarity',1,...
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
for j=1:numel(chanList)
    disp(['working on chan: ',num2str(chanList(j))])
    fName=startcerebusStimRecording(chanList(j),amp1,amp2,pWidth1,pWidth2,interpulse,j,folder,prefix);
    % build stim sequence
    stimObj.beginSequence()
    for cathAnod = 1:1 % cathodal then anodal trains
        for np=1:nPulses % train pulses
%             stimObj.beginGroup()
            % stimulate once on all channels
%             for k=1:numel(chanList)
                stimObj.autoStim(chanList(k),cathAnod)
%             end
%             stimObj.endGroup()
            % pause for pulseLatency
            stimObj.wait(pulseLatency)
        end
        stimObj.wait(1000/nomFreq + rand()*20)
    end
    stimObj.endSequence()
    
    % deliver our stimuli
    stimObj.play(nTests);
    pause((nTests+3)/nomFreq + 3) % pause for longer than needed just in case timing is off
    % tell cerestim to stop stimulating (it should be done, but to prevent
    % errors)
    stimObj.stop();
    pause(0.5 + rand()/2) % just in case there is some delay in .stop()
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
