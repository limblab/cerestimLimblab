%Script to stimulate based on words received on the cerebus digital input
%lines. User must configure the script with a cell array of electrode
%numbers. the code of the stim word selects which electrode(/s) is stimulated.
%user must configure an array of amplitudes. Script will select stimulation
%amplitude based on stim code recieved. number of amplitudes, and number of
%electrode groups must match.
%elaboration: this code can accomplish stimulation with same amplitude on
%multiple electrodes by repeating the electrode definition for each
%amplitude. The code can accomplish stimulatin on multiple electrodes with
%same amplitude by repeating the amplitude definition.
%
%User must also configure pulse parameters
clear all
%script setup- 
%general setup:

%configure stim parameters

usingStimSwitchToRecord = 0;

stimTrainLengths=[0.5,1,2];%different train lengths of stimulation
audioTrainLengths=[0.25,0.7,3];%different train lengths of audio cue
for i = 1:numel(stimTrainLengths)
    electrodeList{i} = [56]; % 56
end
% stim parameters
pulseWidth=200;%time for each phase of a pulse in uS
freq = 50; % Hz
stimAmp = 10; % uA
interpulse = 53;
interphase = 53;
numPulses=freq*stimTrainLengths;
stimDelay=0;%delays start of stim train to coincide with middle of force rise

% audio parameters
audioDelay = 0; % s
audioMaxAmp = [350,350,350,350,350,350,350,350,...
    1500,1500,1500,1500,1500,1500,1500,1500]; % mV
audioFreq = 500; % Hz
audioTrainLengths = [0.25,0.5,0.75,1,1.5,2,2.5,3,...
    0.25,0.5,0.75,1,1.5,2,2.5,3]; % s


% configure cbmex parameters:
stimWord=hex2dec('60');
audioWord=hex2dec('80');
DBMask=hex2dec('f0');
maxWait=400;%maximum interval to wait before exiting
pollInterval=[0.01];%polling interval in s
chan=279;%digital input is CH279 for new cerebus

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
    for i=1:numel(stimTrainLengths)
        %configure waveform:
        disp(['setting stim pattern; ',num2str(i)])
        if(usingStimSwitchToRecord)
            stimObj.setStimPattern('waveform',i,...
                                'polarity',0,...
                                'pulses',1,...
                                'amp1',stimAmp,...
                                'amp2',stimAmp,...
                                'width1',pulseWidth,...
                                'width2',pulseWidth,...
                                'interphase',53,...
                                'frequency',nomFreq);
        else
            stimObj.setStimPattern('waveform',i,...
                                    'polarity',0,...
                                    'pulses',numPulses(i),...
                                    'amp1',stimAmp,...
                                    'amp2',stimAmp,...
                                    'width1',pulseWidth,...
                                    'width2',pulseWidth,...
                                    'interphase',53,...
                                    'frequency',freq);
        end
        
    end
    h=msgbox('Central Connection is open: stimulation is running','CBmex-notifier');
    btnh=findobj(h,'style','pushbutton');
    set(btnh,'String','Close Connection');
    set(btnh,'Position',[15 7 120 17]);
    
    %wait for stim word via cbmex:
    intertrialTimer=tic;
    while(ishandle(h))
        try%see if we can get a chunk of data from the cerebus
            data=cbmex('trialdata',1);
        catch
            %maybe cbmex wasn't set to read mode yet:
            CBInitWordRead(mode);
            data=cbmex('trialdata',1);
        end
        if isempty(data)%if there wasn't anything to read, skip this poll cycle
            if ~isempty(pollInterval)
                pause(pollInterval)
            end
            continue
        else%if we found some data:
        
            %parse raw word data from the digital channel:
            %convert word into single byte that contains the limblab state info
            words=bitshift(bitand(hex2dec('FF00'),data{chan,3}),-8);
            words=words(logical(words));
            ts=data{chan,2}(logical(words));
            % Remove all repeated words (due to encoder data timing)
            word_indices_remove = find(diff(ts)<0.0005 & diff(words)==0)+1;
            if ~isempty(word_indices_remove)
                word_indices_keep = setxor(word_indices_remove,1:length(words));
                words = words(word_indices_keep);
            end
            if ~isempty(words)
%                 unique(words,'stable')
            end

            %check if the words we found were stim words:
            is_stim=0; is_audio=0;
            idx=find(bitand(words,DBMask)==stimWord);
            if(~isempty(idx))
                is_stim = 1;
                stimCode=words(idx(1))-stimWord+1;
                disp(['stimulating with code: ',num2str(stimCode)])
                if stimCode>numel(electrodeList) || stimCode<1
                    warning('managed to get a bad stimcode, cant assign electrode group')
                    continue
                end
                EL=electrodeList{stimCode};
            end
            idx=find(bitand(words,DBMask)==audioWord);
            if(~isempty(idx))
                is_audio=1;
                audioCode=words(idx(1))-audioWord+1;
                disp(['audio code: ', num2str(audioCode)]);
            end
            %if we found no stim words, continue:
            if ~is_stim && ~is_audio
                if ~isempty(pollInterval)
                    pause(pollInterval)
                end
                continue
            end
            if stimStart+stimTrainLengths(end)>=toc(sessionTimer)
                %this is a re-throw of the same word (we usually pull the same word 3 times)
                continue
            end
            %and re-set the stimStart variable
            stimStart=toc(sessionTimer);
        end
        %if we got here, then we found a stim or audio word. use the code to issue a
        %stim command:
        % if using stim switch to record
        maxDelay = 0;
        if(is_stim)
            pause(stimDelay-toc);
            buildStimSequence(stimObj,EL,stimCode,10); % wait takes in milliseconds
            stimObj.play(1)
            maxDelay = stimTrainLengths(stimCode);
        end
        
        if(is_audio)
            pause(audioDelay-toc);
            [audioSequence, audioReps] = buildAudioSequence(audioTrainLengths(audioCode), audioFreq, audioMaxAmp(audioCode));
            cbmex('analogout', 1, 'sequence', audioSequence, 'repeats',audioReps);
            maxDelay = max(audioTrainLengths(audioCode), audioTrainLengths(audioCode));
        end
        
        pause(maxDelay*1.2);
        
        if ~isempty(pollInterval)
            pause(pollInterval)
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
cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj

