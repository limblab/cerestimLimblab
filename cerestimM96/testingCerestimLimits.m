clear all
%script setup- 
%general setup:

%configure stim parameters

usingStimSwitchToRecord = 1;

freq=[20:20:300];%200;%frequency of pulses in Hz
for i = 1:numel(freq)
    electrodeList{i} = [63];
end
% electrodeList{2}=[1];
% electrodeList{3}=[2];
% electrodeList{4}=[22];
% electrodeList{5}=[62];
pulseWidth=100;%time for each phase of a pulse in uS
stimAmps = 60;
trainLength=0.75;%length of the pulse train in s
interpulse = 53;
numPulses=ones(16,1);%freq*trainLength;
stimDelay=0;%0.115;%delays start of stim train to coincide with middle of force rise
% configure cbmex parameters:
stimWord=hex2dec('60');
DBMask=hex2dec('f0');
maxWait=400;%maximum interval to wait before exiting
pollInterval=[];%polling interval in s
chan=151;%digital input is CH151

nomFreq = floor(1/((pulseWidth*2+53+interpulse)*10^-6));

%initialize timer variables
sessionTimer=tic;
stimStart=0;

%initialize connection to cerebus using cbmex:
% if ~cbmex('open') %try to open a cerebus connection and check that the connection was successful in 1 line
%     error('psychophysicsStim:CerebusConnectionFailed','failed to open a connection with a central instance on this PC')
% end
cbmex('close')
cbmex('open')
%set up central to only send the words:
cbmex('mask',0,0)%set all to disabled
cbmex('mask',chan,1)
%clear the data buffers in central:
cbmex('trialconfig',1);

try

    %initialize cerestim object:
    if ~exist('stimObj','var')
        stimObj=cerestim96;
        stimObj.connect();
    elseif ~stimObj.isConnected();
        stimObj.connect();
    end
    if ~stimObj.isConnected();
        error('testStim:noStimulator','could not establish connection to stimulator')
    end

    %establish stimulation waveforms for each stimulation amplitude:
    for i=1:numel(freq)
        %configure waveform:
        disp(['setting stim pattern; ',num2str(i)])
        if(usingStimSwitchToRecord)
            stimObj.setStimPattern('waveform',i,...
                                'polarity',0,...
                                'pulses',1,...
                                'amp1',stimAmps,...
                                'amp2',stimAmps,...
                                'width1',pulseWidth,...
                                'width2',pulseWidth,...
                                'interphase',53,...
                                'frequency',nomFreq);
        else
            stimObj.setStimPattern('waveform',i,...
                                    'polarity',0,...
                                    'pulses',numPulses(i),...
                                    'amp1',stimAmps,...
                                    'amp2',stimAmps,...
                                    'width1',pulseWidth,...
                                    'width2',pulseWidth,...
                                    'interphase',53,...
                                    'frequency',freq(i));
        end
        
    end
    
    catch ME
    %clean up cerebus connection and then error
%     x=cbmex('close');
%     if ~x;
%         warning('psychophysicsStim:failedCentralDisconnect','failed to disconnect from Central while handling error')
%     end
%     if ishandle(h)
%         close(h)
%     end
%     if ~stimObj.disconnect(1);
%         warning('psychophysicsStim:failedStimDisconnect','failed to disconnect from stimulator while handling error')
%     end
    rethrow(ME)
end

%% below sends 16 trains out of module 1

for i = 1:16
    stimObj.manualStim(i,15);
    
end

%% this groups the stimulus so that 16 occur simultaneously
stimObj.groupStimulus(1,1,1,16,[1:16],[1:15 15]);

%% this sends 10 sequential waveforms on 16 simultaneous modules
% some small latency if the freq parameter in set waveform is high (1422
% was tested, ~4ms between pulses
for i = 1:10000
    stimObj.groupStimulus(1,1,1,16,[1:16],[1:15,15]);
end
%%
('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj