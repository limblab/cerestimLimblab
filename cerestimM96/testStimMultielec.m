%test cerestim96 recording during stim:

% %configure stim params
% amp=10;%in uA
% pWidth=200;%in us
% interphase=53;
% interpulse=53;
% freq=floor(1/((2*pWidth+interphase+interpulse)*10^-6));%hz
% nPulses=1;
% nomFreq=10;
% nTests=100;
% chanList=[18,29,52,65,89];
% 
% %save params
% prefix='C:\data\Han\Han_20170711_multiElec_CObump_5chanStim-18_29_52_65_89\';
% % prefix='D:\Data\Chips\STIMRECORD\Chips_20161102_CObump_flipPolarity_CS96unmodAmp_5chanStim_';

if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end
%establish waveforms
stimObj.setStimPattern('waveform',1,...
                        'polarity',0,...
                        'pulses',nPulses,...
                        'amp1',amp,...
                        'amp2',amp,...
                        'width1',pWidth,...
                        'width2',pWidth,...
                        'interphase',interphase,...
                        'frequency',freq);
 stimObj.setStimPattern('waveform',2,...
                        'polarity',1,...
                        'pulses',nPulses,...
                        'amp1',amp,...
                        'amp2',amp,...
                        'width1',pWidth,...
                        'width2',pWidth,...
                        'interphase',interphase,...
                        'frequency',freq); 
%build sequence of 2 pulses on all of the listed channels:
buildStimSequence(stimObj,chanList,[1 2],100);

%establish cerebus connection
initializeCerebus();

startcerebusStimRecording(chanList,amp1,amp2,pWidth1,pWidth2,interpulse,1,[folder,prefix]);

disp(['stimulating'])
%deliver our stimuli:
stimObj.play(nTests)%plays the scripted sequence of stimuli
pause(.5)
%stop recording:
cbmex('fileconfig',fName,'',0)

cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
