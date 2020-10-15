%wrapper script for testStim that will set a list of pulse-shapes and
%interpulse intervals for testing the ability of the stim-record system

%% multielec (16) with different amplitudes
pause(2);

pulseAmpList = [10,10; 20 20; 30 30];

pWidth1 = 200;
pWidth2 = 200;
interpulse = 53;

chanList = {[3,23,64,19,53,67,4,66,24,48,73,81,14,34,41,71],...
    [79,16,70,9,17,11,47,49,84,21,10,89,96,77,57,72],...
    [56,31,40,80,75,38,76,68,2,85,46,13,93,20,36,26]};

nomFreq=1.75;
freq = 330;
nTests = 20;
interpulseList = 53;

interphase=53;
nPulses=15; % number of pulses in a train

for i_chan = 1:numel(chanList) 
    for i_amp=1:size(pulseAmpList,1)
    pause(0.5)
    amp1 = pulseAmpList(i_amp,1);
    amp2 = pulseAmpList(i_amp,2);
    
    stimObj.setStimPattern('waveform',1,...
                        'polarity',0,...
                        'pulses',nPulses,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq);
    
    
        buildStimSequence(stimObj,chanList{i_chan},[1],1000/nomFreq);

        stimObj.play(nTests); % apparently MATLAB is still running while the cerebus is sending stimulation
    % we need to pause long enough for the nTests to be done otherwise
    % we get an error
    %     pause(2*(nTests+3)/nomFreq + nPulses*interpulse/(10^6) + 3) % pause for longer than needed just in case timing is off
        pause(nTests/nomFreq + nPulses*interpulse/(10^6) + 2);
    % tell cerestim to stop stimulating (it should be done, but to prevent
    % errors)
        stimObj.stop();
    end


end

%% single electrodes
pulseAmpList = [100,100;70,70;40,40;10,10];

pWidth1 = 200;
pWidth2 = 200;
interpulse = 53;

chanList = [19,16,32,37,50,79,91,4];
nomFreq=1.75;
nTests = 20;
freq = 330;

interpulseList = 53;

interphase=53;
nPulses=15; % number of pulses in a train

if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end

for i_chan = 1:numel(chanList) 
    
    for i_amp=1:size(pulseAmpList,1)
    pause(0.5)
    amp1 = pulseAmpList(i_amp,1);
    amp2 = pulseAmpList(i_amp,2);
    
    stimObj.setStimPattern('waveform',1,...
                        'polarity',0,...
                        'pulses',nPulses,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq);
    
    
        
        buildStimSequence(stimObj,chanList(i_chan),[1],1000/nomFreq);

        stimObj.play(nTests); % apparently MATLAB is still running while the cerebus is sending stimulation
    % we need to pause long enough for the nTests to be done otherwise
    % we get an error
%     pause(2*(nTests+3)/nomFreq + nPulses*interpulse/(10^6) + 3) % pause for longer than needed just in case timing is off
        pause(nTests/nomFreq + nPulses*interpulse/(10^6) + 2);
% tell cerestim to stop stimulating (it should be done, but to prevent
    % errors)
        stimObj.stop();
    end


end

% %% multielec with different train lengths
% pause(2);
% 
% freq = 330;
% 
% nPulses=33*[1,2,4,8]; % number of pulses in a train
% pulseAmpList = [30,30];
% 
% for i_amp=4:numel(nPulses)
% 
%     amp1 = pulseAmpList(1,1);
%     amp2 = pulseAmpList(1,2);
%     
%     stimObj.setStimPattern('waveform',1,...
%                         'polarity',0,...
%                         'pulses',nPulses(i_amp),...
%                         'amp1',amp1,...
%                         'amp2',amp2,...
%                         'width1',pWidth1,...
%                         'width2',pWidth2,...
%                         'interphase',interphase,...
%                         'frequency',freq);
%     
%     for i_chan = 1%:numel(chanList) 
%         pause(1.5)
%         buildStimSequence(stimObj,chanList{i_chan},[1],1000/nomFreq);
% 
%         stimObj.play(nTests); % apparently MATLAB is still running while the cerebus is sending stimulation
%     % we need to pause long enough for the nTests to be done otherwise
%     % we get an error
%     %     pause(2*(nTests+3)/nomFreq + nPulses*interpulse/(10^6) + 3) % pause for longer than needed just in case timing is off
%         pause(nTests/nomFreq + nPulses*interpulse/(10^6) + 2);
%     % tell cerestim to stop stimulating (it should be done, but to prevent
%     % errors)
%         stimObj.stop();
%     end
% 
% 
% end
% 
% %% 8 electrodes 
% pause(2);
% 
% pulseAmpList = [40, 40];
% 
% pWidth1 = 200;
% pWidth2 = 200;
% interpulse = 53;
% 
% chanList = {[3,23,64,19,53,67,4,66],...
%     [79,16,70,9,17,11,47,49],...
%     [56,31,40,80,75,38,76,68]};
% 
% nomFreq=1;
% freq = 330;
% nTests = 5;
% interpulseList = 53;
% 
% interphase=53;
% nPulses=66; % number of pulses in a train
% 
% for i_amp=1:size(pulseAmpList,1)
%     pause(1);
%     
%     amp1 = pulseAmpList(i_amp,1);
%     amp2 = pulseAmpList(i_amp,2);
%     
%     stimObj.setStimPattern('waveform',1,...
%                         'polarity',0,...
%                         'pulses',nPulses,...
%                         'amp1',amp1,...
%                         'amp2',amp2,...
%                         'width1',pWidth1,...
%                         'width2',pWidth2,...
%                         'interphase',interphase,...
%                         'frequency',freq);
%     
%     for i_chan = 1:numel(chanList) 
%         pause(1.5)
%         buildStimSequence(stimObj,chanList{i_chan},[1],1000/nomFreq);
% 
%         stimObj.play(nTests); % apparently MATLAB is still running while the cerebus is sending stimulation
%     % we need to pause long enough for the nTests to be done otherwise
%     % we get an error
%     %     pause(2*(nTests+3)/nomFreq + nPulses*interpulse/(10^6) + 3) % pause for longer than needed just in case timing is off
%         pause(nTests/nomFreq + nPulses*interpulse/(10^6) + 2);
%     % tell cerestim to stop stimulating (it should be done, but to prevent
%     % errors)
%         stimObj.stop();
%     end
% 
% 
% end
% 
% 
% stimObj.disconnect();
% stimObj.delete()
% clear stimObj
