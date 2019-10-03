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
%script setup- 
%general setup:

%configure stim parameters

usingStimSwitchToRecord = 0;

stimAmps=[50,60,70,70,80,90];%different amplitudes of stimulation, this is per electrode
% electrodeList{1} = [21];
% electrodeList{2} = [21];

electrodeList = {};
% for i = 1:numel(stimAmps)
%     electrodeList{i} = 44; % 73 for duncan
% end
% electrodeList{1} = [44];
% electrodeList{2} = [44];

electrodeList{1} = [26];
electrodeList{2} = [26];
electrodeList{3} = [26];
electrodeList{4} = [44];

electrodeList{5} = [44];
electrodeList{6} = [44];
% electrodeList{7} = [12,13,22,30];
% electrodeList{8} = [6,25,61,86];

pulseWidth=200;%time for each phase of a pulse in us
freq = 300; % Hz
trainLength=0.4;%length of the pulse train in s
interpulse = 53;
numPulses=freq*trainLength;
stimDelay=0;%0.115;%delays start of stim train to coincide with middle of force rise
% configure cbmex parameters:
stimWord=hex2dec('60');
DBMask=hex2dec('f0');
maxWait=400;%maximum interval to wait before exiting
pollInterval=[0.1];%polling interval in s
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
    for i=1:numel(stimAmps)
        %configure waveform:
        disp(['setting stim pattern; ',num2str(i)])
        if(usingStimSwitchToRecord)
            stimObj.setStimPattern('waveform',i,...
                                'polarity',0,...
                                'pulses',1,...
                                'amp1',stimAmps(i),...
                                'amp2',stimAmps(i),...
                                'width1',pulseWidth,...
                                'width2',pulseWidth,...
                                'interphase',53,...
                                'frequency',nomFreq);
        else
            stimObj.setStimPattern('waveform',i,...
                                    'polarity',0,...
                                    'pulses',numPulses,...
                                    'amp1',stimAmps(i),...
                                    'amp2',stimAmps(i),...
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
    
    pause(0.1);
    
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
%             if ~isempty(words)
%                 unique(words,'stable')
%             end
%             %debug:
%             if ~isempty(words)
%                 for i=1:numel(words)
%                     if words(i)<200
%                         disp(['found word: ',num2str(words(i))])
%                     end
%                 end
%                 wordlog=[ts,words];
%             end
            %disp(['et=',num2str(toc(sessionTimer)),' numWords=',num2str(length(words))]) %debug
            %check if the words we found were stim words:
            idx=find(bitand(words,DBMask)==stimWord);
            %if we found no stim words, continue:
            if isempty(idx)
                if ~isempty(pollInterval)
                    pause(pollInterval)
                end
                continue
            end
            if stimStart+trainLength>=toc(sessionTimer)
                %this is a re-throw of the same word (we usually pull the same word 3 times)
                continue
            end
            %if we got to this point we have a valid stim word; convert it
            %to a code:
            stimCode=words(idx(1))-stimWord+1;
            disp(['stimulating with code: ',num2str(stimCode)])
                
            if stimCode>numel(electrodeList) || stimCode<1
                warning('managed to get a bad stimcode, cant assign electrode group')
                continue
            end
            EL=electrodeList{stimCode}
            %and re-set the stimStart variable
            stimStart=toc(sessionTimer);
        end
        %if we got here, then we found a stim word. use the code to issue a
        %stim command:
        tic
        % if using stim switch to record
        if(usingStimSwitchToRecord)
            buildStimSequence(stimObj,EL,repmat(stimCode,numPulses,1),1000/freq); % wait takes in milliseconds
        else
            buildStimSequence(stimObj,EL,stimCode,10); % wait takes in milliseconds
        end
        
        pause(stimDelay-toc);
        stimObj.play(1)
        pause(trainLength + 0.1);
        
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

