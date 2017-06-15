%script to handle stimulation for Kramer psychophysical bias task:
clear all
%script setup- 
%general setup:
maxSessionTime=2*60*60;%max lenght of session in seconds
stimWord=hex2dec('60');
DBMask=hex2dec('f0');
maxWait=400;%maximum interval to wait before exiting
pollInterval=.01;%polling interval in s
chan=151;%digital input is CH151


%configure stim parameters
electrodeList{1}=[42];
stimFreq=100;%200;%frequency of pulses in Hz

stimDelay=0.200;%0.115;%delays start of stim train to coincide with middle of force rise

pWidth=200;%in us
amp1=30;%in uA
pWidth1=200;%in us
amp2=30;%in uA
pWidth2=200;%in us
interphase=53;
interpulse=250;
%
interpulseDefFreq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz
nPulses=1;
nTests=10;
trainLength=nTests/stimFreq;%length of the pulse train in s



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
    stimObj.setStimPattern('waveform',1,...
                        'polarity',0,...
                        'pulses',nPulses,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',interpulseDefFreq);
    stimObj.setStimPattern('waveform',2,...
                        'polarity',1,...
                        'pulses',nPulses,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',interpulseDefFreq);   
                    
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
                unique(words,'stable')
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
                
            if stimCode>numel(electrodeList) || stimCode<1
                warning('managed to get a bad stimcode, cant assign electrode group')
                continue
            end
            EL=electrodeList{stimCode};
            %and re-set the stimStart variable
            stimStart=toc(sessionTimer);
        end
        %if we got here, then we found a stim word. use the code to issue a
        %stim command:
        pause(stimDelay)%wait to align stim start with middle of force rise
            %construct stim sequence based on word
        
        for pul = 1:nTests
            if mod(pul,2)
                stimObj.manualStim(EL,1);
            else
                stimObj.manualStim(EL,2);
            end
            pause(1/stimFreq);
        end
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
