%Script to stimulate based on words received on the cerebus digital input
%lines. 
%% this script assumes that wave_mappings and freq_all already exists
% wave_mappings is a cell array that contains information for each pattern.
% Each cell contains a different pattern. This is stored as an array of 
% (chan_num, wave_freq_norm, wave_num). The code below builds 15 waveforms
% (cerestim limit) and then uses the mappings in wave_mappings to deliver
% the stimuli on the channels in chan_num. This code currently handles up
% to 16 channels. 
% freq_all_norm is a 15x1 array containing the normalized frequencies for each waveform.

max_freq = 250;
freq_all_norm = linspace(0,1,16);
freq_all_norm = freq_all_norm(2:end);
freq_all = freq_all_norm*max_freq;

usingStimSwitchToRecord = 0;

stimAmp=30;%different amplitudes of stimulation
pulseWidth=200;%time for each phase of a pulse in uS
trainLength=0.05;%length of the pulse train in s
interpulse = 53;

stimDelay=0;%0.115;%delays start of stim train to coincide with middle of force rise
% configure cbmex parameters:
stimWord=hex2dec('60');
DBMask=hex2dec('f0');
maxWait=400;%maximum interval to wait before exiting
pollInterval=[0.01];%polling interval in s
chan=279;%digital input is CH279

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
        %configure waveform:
        
    
    for i = 1:15
        disp(['setting stim pattern; ',num2str(i)])
        freq = ceil(freq_all(i));
        numPulses=ceil(freq*trainLength);
        stimObj.setStimPattern('waveform',i,...
                                'polarity',0,...
                                'pulses',numPulses,...
                                'amp1',stimAmp,...
                                'amp2',stimAmp,...
                                'width1',pulseWidth,...
                                'width2',pulseWidth,...
                                'interphase',53,...
                                'frequency',freq);
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
                
            if stimCode>numel(wave_mappings) || stimCode<1
                warning('managed to get a bad stimcode, cant assign electrode group')
                continue
            end
            %and re-set the stimStart variable
            stimStart=toc(sessionTimer);
        end
        %if we got here, then we found a stim word. use the code to issue a
        %stim command:
        tic
        % if using stim switch to record
        if(usingStimSwitchToRecord)
            buildStimSequence_biomimetic(stimObj,wave_mappings{stimCode},1000/max_freq); % wait takes in milliseconds
        else
            buildStimSequence_biomimetic(stimObj,wave_mappings{stimCode},10); % wait takes in milliseconds
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

