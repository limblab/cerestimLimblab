%% Chips 1
for mm = 1:1
    clear;

    folder='C:\data\stimTesting\artificialMonkey_20171216\';
    prefix='artMonk_20171216_chan27ainp15_ainp14Input_ainp13green_yellowOscilloscope'; % no underscore after prefix please
    
    % all parameters need to be the same size matrix
    amp1=[100];%in uA
    pWidth1=[200];%in us
    amp2=[100];%in uA
    pWidth2=[200];%in us
    
    interphase=[53];
    interpulse=[250];

   
    
    nPulses=1; % pulses per train
    nomFreq=5;
    nTests=1; % # of trains

    chanList=[27]; % pick some channels

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
