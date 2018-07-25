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

%%configure stim parameters
chan_num_all = chan_num;
max_freq = 330;
num_elec = 16:8:32;

chan_num = {};
wave_freq = {};

[freq_all_norm] = unique(biomimetic_freq_norm);
freq_all_norm(freq_all_norm == 0) = [];
freq_all = freq_all_norm*max_freq;

freq_all(freq_all < 16) = 16;

chan_num{3} = chan_num_all;
wave_freq{3} = biomimetic_freq_norm;

keep_idx_24 = [randperm(16,12), randperm(16,12) + 16];
chan_num{2} = chan_num_all(keep_idx_24);
wave_freq{2} = biomimetic_freq_norm(keep_idx_24);
keep_idx_16 = [randperm(12,8), randperm(12,8) + 8];
chan_num{1} = chan_num{2}(keep_idx_16);
wave_freq{1} = biomimetic_freq_norm(keep_idx_16);

%%
wave_mappings = {};

for num_elec_idx = 1:3
    for bio = 1:2
        wave_mappings{end+1} = zeros(num_elec(num_elec_idx)/2,3); % chan_num, wave_freq, wave_num

        if(bio == 1) % biomimetic
            chan_ = chan_num{num_elec_idx}(1:num_elec(num_elec_idx)/2);
            freq_ = wave_freq{num_elec_idx}(1:num_elec(num_elec_idx)/2);
            for freq_idx = 1:numel(freq_)
                freq_all_idx = find(freq_(freq_idx) == freq_all_norm);
                wave_mappings{end}(freq_idx,2) = freq_all(freq_all_idx);
                wave_mappings{end}(freq_idx,3) = freq_all_idx;
                wave_mappings{end}(freq_idx,1) = chan_(freq_idx);
            end
            
        else % nonbiomimetic
            wave_mappings{end}(:,1) = chan_num{num_elec_idx}(randperm(num_elec(num_elec_idx),num_elec(num_elec_idx)/2))';
            wave_mappings{end}(:,2:3) = wave_mappings{end-1}(:,2:3);
        end
    end
end

%%

usingStimSwitchToRecord = 0;

stimAmp=20;%different amplitudes of stimulation
pulseWidth=200;%time for each phase of a pulse in uS
max_freq = 330; % Hz
trainLength=0.12;%length of the pulse train in s
interpulse = 250;

stimDelay=0;%0.115;%delays start of stim train to coincide with middle of force rise
% configure cbmex parameters:
stimWord=hex2dec('60');
DBMask=hex2dec('f0');
maxWait=400;%maximum interval to wait before exiting
pollInterval=[0.01];%polling interval in s
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
        %configure waveform:
        
%     disp(['setting stim pattern; ',num2str(i)])
    for i = 1:15
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
            if ~isempty(words)
%                 unique(words,'stable')
            end
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

