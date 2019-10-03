% %script to handle stimulation for Kramer psychophysical bias task:
% fclose(instrfind)
% clear all
%
% b = Bluetooth('HC-05', 1);
% fopen(b);
goodVibs = [1,2,3,4,5];
maxSessionTime=2*60*60;%max lenght of session in seconds
moveWord=hex2dec('30');
holdWord=hex2dec('A0');
startWord = hex2dec('20');
DBMask=hex2dec('f0');
maxWait=400;%maximum interval to wait before exiting
pollInterval=.01;%polling interval in s
chan=151;%digital input is CH151
newTrial = true;

%configure stim parameters
%initialize timer variables
sessionTimer=tic;
stimStart=0;

%initialize connection to cerebus using cbmex:
% if ~cbmex('open') %try to open a cerebus connection and check that the connection was successful in 1 line
%     error('psychophysicsStim:CerebusConnectionFailed','failed to open a connection with a central instance on this PC')
% end
cbmex('close')
cbmex('open')

%clear the data buffers in central:
cbmex('trialconfig',1);
newTrial = true;
r = randi(2);

try
    
    %initialize cerestim object:
    
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
            word_indices_remove = find(diff(ts)<0.05 & diff(words)==0)+1;
            if ~isempty(word_indices_remove)
                word_indices_keep = setxor(word_indices_remove,1:length(words));
                words = words(word_indices_keep);
            end
            if ~isempty(words)
                words = unique(words,'stable');
                if ~newTrial
                    if ~isempty(find(ismember(bitand(words, DBMask), startWord)));
                        newTrial = true;
                        r = randi(2);

                        disp('new trial')
                    end
                end
                
            end
            if newTrial
                
                if ~isempty(words)
                    if r ==1
                        stimWord =moveWord;
                    else
                        stimWord = holdWord; 
                    end
                    idx=find(ismember(bitand(words,DBMask),stimWord));
                    %if we found no stim words, continue:
                    if isempty(idx)
                        if ~isempty(pollInterval)
                            pause(pollInterval)
                        end
                        continue
                    else
                        newTrial = false;

                    end
                    vibMot = randi(length(goodVibs)+1)-1;
                    if vibMot>0
                    if r == 1
                        disp(['stimulating for movement' , num2str(vibMot)])
                        stimStart=toc(sessionTimer);
                        pause(.2)
                        fwrite(b, num2str(goodVibs(vibMot)))
                        cbmex('comment', 0, 0, ['vibMove',num2str(goodVibs(vibMot))]);
                        pause(.5)
                        fwrite(b, '0')
                        cbmex('comment', 0, 0, ['vibMoveOff', num2str(goodVibs(vibMot))]);
                        cbmex('trialconfig',1);
                    else
                        disp(['stimulating for hold', num2str(vibMot)])
                        stimStart=toc(sessionTimer);
                        pause(.2)
                        fwrite(b, num2str(goodVibs(vibMot)))
                        cbmex('comment', 0, 0, ['vibHold',num2str(goodVibs(vibMot))]);
                        pause(.5)
                        fwrite(b, '0')
                        cbmex('comment', 0, 0, ['vibHoldOff',num2str(goodVibs(vibMot))]);
                        cbmex('trialconfig',1);
                    end
                    else
                        disp(['stimulating for hold 0'])
                        stimStart=toc(sessionTimer);
                        pause(.2)
                        fwrite(b, '0')
                        cbmex('comment', 0, 0, ['vibHold',num2str(vibMot)]);
                        pause(.5)
                        fwrite(b, '0')
                        cbmex('comment', 0, 0, ['vibHoldOff',num2str(vibMot)]);
                        cbmex('trialconfig',1);
                    end
                end
            end
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


