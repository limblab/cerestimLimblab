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
stimObj.beginSequence()
%     stimObj.groupStimulus(1,0,1,numel(chanList),chanList,ones(size(chanList)))
%     stimObj.groupStimulus(0,0,1,numel(chanList),chanList,2*ones(size(chanList)))
    stimObj.beginGroup()
        for k=1:numel(chanList)
            stimObj.autoStim(chanList(k),1)
        end
    stimObj.endGroup()
    stimObj.wait(100)
    stimObj.beginGroup()
        for k=1:numel(chanList)
            stimObj.autoStim(chanList(k),2)
        end
    stimObj.endGroup()
stimObj.endSequence()
%establish cerebus connection
cbmex('open')
%start file storeage app, or stop recording if already started
fName='temp';
cbmex('fileconfig',fName,'',0)
pause(1)

    disp(['stimulating'])
    fNum=num2str(1,'%03d');
    fName=[prefix,'_',num2str(amp),'uA-stim_',num2str(nPulses),'pulse_',num2str(nomFreq),'HZ_nominalFreq_',fNum];
    %start recording:
    cbmex('fileconfig',fName,'testing stimulation artifacts',1)
    pause(.5)
    %deliver our stimuli:
    for i=1:2:nTests
    %    x=stimObj.getSequenceStatus();
        stimObj.play(1)%plays the scripted sequence of stimuli
        pause(2/nomFreq+rand/20);%wait a bit to get different timings relative to cerebus clock
    end
    pause(.5)
    %stop recording:
    cbmex('fileconfig',fName,'',0)

cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
