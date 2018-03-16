%test cerestim96 recording during stim:
%test stim is intended to be called within a wrapper script that configures
%the stim parameters. The wrapping script must set the following
%parameters:
%amp1           :   amplitude of first pulse phase
%amp2           :   amplitude of second pulse phase
%pWidth1        :   width of first pulse phase
%pWidth2        :   width of second pulse phase
%interpulse     :   time between pulses
%chanList       :   a vector of channel numbers that will be sequentially
%                       stimulated
%folder         :   name of the folder where data should be saved
%prefix         :   a string that will be appended to the front of every
%                       file name

%configure params
interphase=53;
freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz
nPulses=1;
nomFreq=10;
nTests=20;

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

%establish cerebus connection
initializeCerebus();
%loop through channels and log a test file for each one:
for j=1:numel(chanList)
    disp(['working on chan: ',num2str(chanList(j))])
    startcerebusStimRecording(chanList(j),amp1,amp2,pWidth1,pWidth2,interpulse,j);
    buildStimSequence(stimObj,chanList(j),[1 2],1000/nomFreq);
    %deliver our stimuli:
    stimObj.play(nTests);
    pause(.5)
    %stop recording:
    cbmex('fileconfig',fName,'',0)
end

cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
