%% Chips 1
for mm = 1:20
    disp(['stimulation iteration: ',num2str(mm)])
    clear;

    folder='C:\data\Han\Han_20180720\';
    prefix='Han_20180720_'; % no underscore after prefix please
    
    % all parameters need to be the same size matrix
    amp1=[50];%in uA
    pWidth1=[200];%in us
    amp2=[50];%in uA
    pWidth2=[200];%in us
    
    interphase=[53];
    interpulse=[300];
    polarities = [0]; % 0 = cathodic first
   
    
    nPulses=1; % pulses per train
%     freq=200; %frequency of the trains. This may be overridden in runStimAnd Record

    nomFreq=10; %how frequently we deliver a train, if trains are single pulse, this is the stim frequency
    nTests=2000; % # of trains

    chanList=[3:3:96]; % pick some channels

    arg = {'interleaveChanList',1};
    saveImpedance=0;
%     if(mm == 1)
%         saveImpedance = 1;
%     else
%         saveImpedance = 0;
%     end

    runStimAndRecord;
end

%% Joe stim channel test
for mm = 1:2
    disp(['stimulation iteration: ',num2str(mm)])
    clear;

    folder='C:\data\Han\Han_20180718_RW_dukeProjBox_asymmetric\';
    prefix='Han_20180718_dukeProjBox0718_chan10con_interpulse150'; % no underscore after prefix please
    
    % all parameters need to be the same size matrix
    amp1=[40,40,10,4];%in uA
    pWidth1=[100,100,400,1000];%in us
    amp2=[40,40,40,40];%in uA
    pWidth2=[100,100,100,100];%in us
    
    interphase=[53,53,53,53];
    interpulse=[150,150,150,150];
    polarities = [0,1,1,1]; % 0 = cathodic first
   
    
    nPulses=1; % pulses per train
%     freq=1; %frequency of the trains. This may be overridden in runStimAnd Record
    clear freq
    
    nomFreq=5; %how frequently we deliver a train, if trains are single pulse, this is the stim frequency
    nTests=750; % # of trains

    chanList=[10]; % pick some channels

    arg = {'interleaveChanList',1};
    saveImpedance=0;
%     if(mm == 1)
%         saveImpedance = 1;
%     else
%         saveImpedance = 0;
%     end

    runStimAndRecord;
end

%% Mihili 2
% for mm = 1:1
%     clear;
% 
%     folder='C:\data\Mihili\Mihili_20170720_stimRecord\';
%     prefix='Mihili_20170720_chan94stim';
% 
%     amp1=[5,10,15];%in uA
%     pWidth1=200;%in us
%     amp2=30;%in uA
%     pWidth2=200;%in us
% 
%     interphase=53;
% 
%     interpulse=250;
% 
%     nPulses=1;
%     nomFreq=10;
%     nTests=1020;
% 
%     chanList=[94];
% 
%     arg = {'interleaveChanList',1};
%     runStimAndRecord;
% end
%% Han 1

% for tt=1:12
%     clear;
% 
%     folder='C:\data\Han\Han_20170718_stimRecord\';
%     prefix='Han_20170718';
% 
%     amp1=[40];%in uA
%     pWidth1=200;%in us
%     amp2=30;%in uA
%     pWidth2=200;%in us
% 
%     interphase=53;
% 
%     interpulse=250;
% 
%     nPulses=1;
%     nomFreq=10;
%     nTests=1050;
% 
%     chanList=[46,56]; % grab the 4 corners
% 
%     arg = {'interleaveChanList',1};
%     runStimAndRecord;
% end
% 
% %% Han 2
% for ttt = 1
%     clear;
% 
%     %configure stim params
%     amp=40;%in uA
%     pWidth=200;%in us
%     interphase=53;
%     interpulse=53;
%     freq=floor(1/((2*pWidth+interphase+interpulse)*10^-6));%hz
%     nPulses=1;
%     nomFreq=10;
%     nTests=1000;
%     chanList=[35,55];
% 
%     %save params
%     prefix='C:\data\Mihili\Mihili_20170728_multiElec_CObump_2chanStim-35_55\';
% 
%     testStimMultielec;
% end
