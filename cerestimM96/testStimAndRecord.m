%test cerestim96 recording during stim:

%configure params

amp1=30;%in uA
pWidth1=200;%in us
amp2=30;%in uA
pWidth2=200;%in us

interphase=53;
% 
% % interpulse=53;
% interpulse=100;
% interpulse=150;
%interpulse=200;
interpulse=250;
% interpulse=300;
% interpulse=350;
% interpulse=400;
% interpulse=450;
% interpulse=500;
%
% interpulse = [150,200,250,300,350,400,450,500];

nPulses=1;
nomFreq=10;
nTests=1050;

% chanList = [58];

chanList=[35,82,57,13];
% chanList=9;
% chanList=[1:96];
%chanList=[73];
%save params
folder='C:\data\Han\Han_20170711_stimRecord_interleavedChannels\';
prefix='Han_20170711';

if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end


freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz
waveforms = [];
stimObj.setStimPattern('waveform',1,...
                            'polarity',0,...
                            'pulses',nPulses,...
                            'amp1',amp1,...
                            'amp2',amp1,...
                            'width1',pWidth1,...
                            'width2',pWidth2,...
                            'interphase',interphase,...
                            'frequency',freq);
                        
for pattern = 1:numel(chanList)
    
    waveforms.parameters(pattern).polarity = 0;
    waveforms.parameters(pattern).amp1 = amp1;
    waveforms.parameters(pattern).amp2 = amp1;
    waveforms.parameters(pattern).width1 = pWidth1;
    waveforms.parameters(pattern).width2 = pWidth2;
    waveforms.parameters(pattern).interphase = interphase;
    waveforms.parameters(pattern).freq = freq;
    waveforms.parameters(pattern).interpulse = interpulse;
    waveforms.parameters(pattern).stimChan = chanList(pattern);
  
end 

%  stimObj.setStimPattern('waveform',2,...
%                         'polarity',1,...
%                         'pulses',nPulses,...
%                         'amp1',amp1,...
%                         'amp2',amp2,...
%                         'width1',pWidth1,...
%                         'width2',pWidth2,...
%                         'interphase',interphase,...
%                         'frequency',freq);   
%     
%test and save impedance:
t=clock;
    t(6)=round(t(6));
    tStr='';
    for k=1:6
        tStr=[tStr,num2str(t(k)),'_']
    end
% impedanceData=stimObj.testElectrodes();
% save([folder,'impedance0',tStr,'.mat'],'impedanceData','-v7.3')

%establish cerebus connection
cbmex('open')
%start file storeage app, or stop recording if already started
fName='temp';
cbmex('fileconfig',fName,'',0)
pause(3)

%loop through channels and log a test file for each one:
% for j=1:numel(chanList)
%     disp(['working on chan: ',num2str(chanList(j))])
%     fNum=num2str(j,'%03d');

    t=clock;
    t(6)=round(t(6));
    tStr='';
    for k=1:6
        tStr=[tStr,num2str(t(k)),'_'];
    end
    
    endNumber = 1;
        fName=[folder,prefix,'_chan','stim_A1-',num2str(amp1),'_A2-',num2str(amp2),'_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse-',num2str(interpulse),'_',num2str(endNumber)];
    while exist(strcat(fName,'.nev')) > 0
        endNumber = endNumber + 1;
        fName=[folder,prefix,'_chan','stim_A1-',num2str(amp1),'_A2-',num2str(amp2),'_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse-',num2str(interpulse),'_',num2str(endNumber)];
    end
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
    waveforms.waveSent = [];
    for i=1:nTests
    %    x=stimObj.getSequenceStatus();
        chanNumber = ceil(rand()*numel(chanList));
        waveforms.waveSent(end+1,1) = chanNumber;
        stimObj.manualStim(chanList(chanNumber),1)
%         if mod(i,2)
%             stimObj.manualStim(chanList(j),1);
%         else
%             stimObj.manualStim(chanList(j),2);
%         end
        if(mod(i,100) == 0)
            disp(i)
        end
        pause(1/nomFreq+rand/20);%wait a bit to get different timings relative to cerebus clock
        
%         pause(1/nomFreq);
%         if(mod(i,20)==0) % every 20 pulses, pause for a second
%             pause(1.02+rand/10)
%         end
    end
    pause(5)
    %stop recording:
    cbmex('fileconfig',fName,'',0)
%     impedanceData=stimObj.testElectrodes();
%     save([folder,'impedance', tStr,num2str(j),'.mat'],'impedanceData','-v7.3')
    cbmex('fileconfig',fName,'',0)
    pause(2)
    save(strcat(folder,prefix,'_chan','stim','_waveformsSent_',num2str(endNumber)),'waveforms');
% end

cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj

pause(5);



