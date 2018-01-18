%test cerestim96 recording during stim:

%configure params
%     pWidth=200;%in us
%     amp1=40;%in uA
%     pWidth1=200;%in us
%     amp2=amp1;%in uA
%     pWidth2=200;%in us
interphase=53;
% %     % % 
% %     % interpulse=53;
% %     % interpulse=100;
% %     % interpulse=150;
% %     interpulse=200;
%     interpulse=250;
%     % interpulse=300;
% interpulse=350;
% interpulse=400;
% interpulse=450;
% interpulse=500;
%
freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz
nPulses=1;
nomFreq=10;
nTests=20;
%     chanList=[3,5];

%save params
%     folder='C:\data\stimTesting\ArtificialMonkey_20171214\';
%     prefix='ArtificialMonkey_20171214_testBatteries';

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

%test and save impedance:
t=clock;
    t(6)=round(t(6));
    tStr='';
    for k=1:6
        tStr=[tStr,num2str(t(k)),'_'];
    end
    
    
% impedanceData=stimObj.testElectrodes();
% save([folder,'impedance0',tStr,'.mat'],'impedanceData','-v7.3')

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

    t=clock;
    t(6)=round(t(6));
    tStr='';
    for k=1:6
        tStr=[tStr,num2str(t(k)),'_'];
    end
    fName=[folder,prefix,'_chan',num2str(chanList(j)),'stim_A1-',num2str(amp1),'_A2-',num2str(amp2),'_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse',num2str(interpulse),'_',tStr,fNum];

    [~,fstr,ext]=fileparts(fName);
    %start recording:

    ctr=0;
    tmp=dir(folder);
    while isempty(cell2mat(strfind({tmp.name},fstr))) & ctr<10
        cbmex('fileconfig',fName,'',0)
        pause(.5);
        cbmex('fileconfig',fName,'testing stimulation artifacts',1);
        pause(1);
        ctr=ctr+1;
        tmp=dir(folder);
    end
    if ctr==10
       warning('tried to start recording and failed') 
    end
    pause(10)
    %deliver our stimuli:
    for i=1:nTests
    %    x=stimObj.getSequenceStatus();
        if mod(i,2)
            stimObj.manualStim(chanList(j),1);
        else
            stimObj.manualStim(chanList(j),2);
        end
        if(mod(i,100) == 0)
            disp(i)
        end
        pause(1/nomFreq);%+rand/20);%wait a bit to get different timings relative to cerebus clock
    end
    pause(.5)
    %stop recording:
    cbmex('fileconfig',fName,'',0)
%     impedanceData=stimObj.testElectrodes();
%     save([folder,'impedance', tStr,num2str(j),'.mat'],'impedanceData','-v7.3')
%     cbmex('fileconfig',fName,'',0)
end

cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
