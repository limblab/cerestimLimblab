%test cerestim96 recording during stim:
<<<<<<< HEAD
%save parameters:
folder='E:\TestData\stimArtifact\';
filePrefix='Chips_20161025_';
%configure params
=======

%configure stim params
>>>>>>> f140a82eaeb6dbae681f2e28eb5cb90ab6d196f2
amp=20;%in uA
pWidth=200;%in us
interphase=53;
interpulse=53;
freq=floor(1/((2*pWidth+interphase+interpulse)*10^-6));%hz
nPulses=1;
nomFreq=10;
nTests=100;
chanList=[1:96];

%save params
folder='D:\Data\Chips\STIMRECORD\';
prefix='Chips_20161102_CObump_flipPolarity_CS96unmodAmp_';

if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end
<<<<<<< HEAD
    
=======

>>>>>>> f140a82eaeb6dbae681f2e28eb5cb90ab6d196f2
stimObj.setStimPattern('waveform',1,...
                        'polarity',0,...
                        'pulses',nPulses,...
                        'amp1',amp,...
                        'amp2',amp,...
                        'width1',pWidth,...
                        'width2',pWidth,...
                        'interphase',interphase,...
                        'frequency',freq);
<<<<<<< HEAD
    
%quickly test the impedance of the electrodes:
imp=testElectrodes();
impedance=imp.impedance(2:end);
save([folder,filePrefix,'impedance.mat'],impedance)

=======
 stimObj.setStimPattern('waveform',2,...
                        'polarity',1,...
                        'pulses',nPulses,...
                        'amp1',amp,...
                        'amp2',amp,...
                        'width1',pWidth,...
                        'width2',pWidth,...
                        'interphase',interphase,...
                        'frequency',freq);   
%test and save impedance:
impedanceData=stimObj.testElectrodes();
save([folder,'impedance.mat'],'impedanceData','-v7.3')
                    
>>>>>>> f140a82eaeb6dbae681f2e28eb5cb90ab6d196f2
%establish cerebus connection
cbmex('open')
%start file storeage app, or stop recording if already started
fName='temp';
cbmex('fileconfig',fName,'',0)
pause(1)
%loop through channels and log a test file for each one:
for j=1:numel(chanList)
    disp(['working on chan: ',num2str(chanList(j))])
    fNum=num2str(j,'%03d');
<<<<<<< HEAD
    fName=[folder,filePrefix,'CS96ArtifactTest-unmodifiedAmp_ch',num2str(j),'stim_',num2str(nPulses),'pulse_',num2str(nomFreq),'HZ-nomFreq_',fNum];
=======
    fName=[folder,prefix,'_chan',num2str(chanList(j)),'stim_',num2str(amp),'uA_',num2str(nPulses),'pulse_',num2str(nomFreq),'HZ_nominalFreq_',fNum];
>>>>>>> f140a82eaeb6dbae681f2e28eb5cb90ab6d196f2
    %start recording:
    cbmex('fileconfig',fName,'testing stimulation artifacts',1)
    pause(.5)
    %deliver our stimuli:
    for i=1:nTests
    %    x=stimObj.getSequenceStatus();
        if mod(i,2)
            stimObj.manualStim(chanList(j),1);
        else
            stimObj.manualStim(chanList(j),2);
        end
        pause(1/nomFreq+rand/20);%wait a bit to get different timings relative to cerebus clock
    end
    pause(.5)
    %stop recording:
    cbmex('fileconfig',fName,'',0)
    pause(1)%let the file storage app compose itself before we return to the top of the loop
end

cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
