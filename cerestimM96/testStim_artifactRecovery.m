%test cerestim96 recording during stim:
%testStim configures the stimulator with a pair of waveforms, one cathodal
%leading, the other anodal leading. testStim then initiates cerebus
%recording, followed by issuing alternating cathodal and anodal stimuli
%
%test stim is intended to be called within a wrapper script that configures
%the stim parameters. The wrapping script must set the following
%parameters:
%amp1           :   amplitude of first pulse phase
%amp2           :   amplitude of second pulse phase
%pWidth1        :   width of first pulse phase
%pWidth2        :   width of second pulse phase
%interphase     :   time between pulses
%interpulse     :   interphase time of the waveform. This is also the time
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
%configure params


aux_chan

freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6))%hz

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
                        'pulses',nPulses,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq);
                    
 stimObj.setStimPattern('waveform',2,...
                        'polarity',1,...
                        'pulses',nPulses,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq);   
                    
stimObj.setStimPattern('waveform',3,...
                        'polarity',0,...
                        'pulses',35,...
                        'amp1',5,...
                        'amp2',5,...
                        'width1',53,...
                        'width2',53,...
                        'interphase',53,...
                        'frequency',3000);                 

%establish cerebus connection
initializeCerebus();
%loop through channels and log a test file for each one:
for j=1:numel(chanList)
    disp(['working on chan: ',num2str(chanList(j))])
    fName=startcerebusStimRecording(chanList(j),amp1,amp2,pWidth1,pWidth2,interpulse,j,folder,prefix,01);
%     fName = [fName,'_delay',num2str(signalDelay*100)];

%     buildStimSequence(stimObj,chanList(j),[1],1000/nomFreq);
    stimObj.beginSequence()
    stimObj.beginGroup()
    stimObj.autoStim(chanList(j),1)
    if(use_aux_chan)
        for aux_chan_idx = 1:numel(aux_chan)
            stimObj.autoStim(aux_chan(aux_chan_idx),aux_chan_wave(aux_chan_idx))
        end
    end
    stimObj.endGroup()
% 
    stimObj.wait(1000/nomFreq)
% 
%     
    stimObj.beginGroup()
    stimObj.autoStim(chanList(j),2)
    if(use_aux_chan)
        for aux_chan_idx = 1:numel(aux_chan)
            stimObj.autoStim(aux_chan(aux_chan_idx),aux_chan_wave(aux_chan_idx))
        end
    end
    stimObj.endGroup()
%     
    stimObj.wait(1000/nomFreq)
    stimObj.endSequence()
%     %deliver our stimuli:
    stimObj.play(nTests); % apparently MATLAB is still running while the cerebus is sending stimulation
    % we need to pause long enough for the nTests to be done otherwise
    % we get an error
%     pause(2*(nTests+3)/nomFreq + nPulses*interpulse/(10^6) + 3) % pause for longer than needed just in case timing is off
    pause(nTests/nomFreq + nPulses*interpulse/(10^6) + 2);
% tell cerestim to stop stimulating (it should be done, but to prevent
    % errors)
    pause(1); % for extra data
    stimObj.stop();
    pause(3) % just in case there is some delay in .stop()
    %stop recording:
    
    cbmex('fileconfig',fName,'',0)
end

cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
pause(2)


%%
% if ~exist('stimObj','var')
%     stimObj=cerestim96;
%     stimObj.connect();
% elseif ~stimObj.isConnected();
%     stimObj.connect();
% end
% if ~stimObj.isConnected();
%     error('testStim:noStimulator','could not establish connection to stimulator')
% end
% % imp = [];
% %     imp = stimObj.testElectrodes();
% %     pause(0.01)
% 
% stimObj.disconnect();
% stimObj.delete()
% clear stimObj
