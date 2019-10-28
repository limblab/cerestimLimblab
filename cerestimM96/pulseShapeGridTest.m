%wrapper script for testStim that will set a list of pulse-shapes and
%interpulse intervals for testing the ability of the stim-record system


% pulseAmpList = repmat([5;10;15;20;25;30;40;50;60;70;80;90;100],1,2);
% pulseWidthList = repmat([200,200],size(pulseAmpList,1),1);  
% % 
% pulseWidthList = [500,200;pulseWidthList];
% pulseAmpList = [20,50;pulseAmpList];
% % 
% polList = repmat([0],size(pulseAmpList,1),1);
% polList = [0;polList]; % cathodic first is 0

pulseAmpList = [20,20];
pulseWidthList = [200,200];
polList = [0];

chanList = [21];
aux_chan = [55];
aux_chan_wave = [3]; % 1 = cathodic first from pulseAmpList, 2 = anodic first from pulseAmpList, 3 = cathodic first small
use_aux_chan = 1;
nomFreq=10;
nTests=80;

interpulseList = 53;
prefix='Han_chan21stim_auxChan55_'; % no '_' needed;
folder='C:\H_\';

interphase=53;
nPulses=1; % should almost always be 1. nTests sets train lengthand t


% for k = 1:numel(injectedSignalDelayList)
%     signalDelay = injectedSignalDelayList(k);
    for m=1:numel(interpulseList)
        for j=1:size(pulseAmpList,1)
            pol = polList(j);
            pWidth1=pulseWidthList(j,1)%in us
            amp1=pulseAmpList(j,1)%in uA
            pWidth2=pulseWidthList(j,2)%in us
            amp2=pulseAmpList(j,2)%in uA
            interpulse=interpulseList(m)
            testStim_artifactRecovery
        end
    end
% end
