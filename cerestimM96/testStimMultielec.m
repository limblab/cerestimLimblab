%test cerestim96 recording during stim:

%configure stim params
amp=40;%in uA
pWidth=200;%in us
interphase=53;
interpulse=53;
freq=floor(1/((2*pWidth+interphase+interpulse)*10^-6));%hz
nPulses=1;
nomFreq=10;
nTests=100;
% chanList=[18,29,52,65];

% chanList=[13,19,23,25];
% chanList=[13,36,43,52];
chanList=[30,32,78,79];

% 
% %save params
folder='C:\data\Han\Han_20180713_multiElec_RW_4chanStim-30_32_78_79\';
prefix='Han_20180713_';


% prefix='D:\Data\Chips\STIMRECORD\Chips_20161102_CObump_flipPolarity_CS96unmodAmp_5chanStim_';

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

startcerebusStimRecording(chanList,amp1,amp2,pWidth1,pWidth2,interpulse,1,folder,prefix);

disp(['stimulating'])
%deliver our stimuli:
stimObj.play(nTests)%plays the scripted sequence of stimuli
pause(2*nTests/nomFreq + 10);
pause(.5)
%stop recording:
cbmex('fileconfig',fName,'',0)

cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
