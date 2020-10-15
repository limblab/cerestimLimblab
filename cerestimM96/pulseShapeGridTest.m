%wrapper script for testStim that will set a list of pulse-shapes and
%interpulse intervals for testing the ability of the stim-record system


pulseAmpList = repmat([10;20;30;40;50;60;70;80;90;100],1,2);
pulseWidthList = repmat([200,200],size(pulseAmpList,1),1);  
% % 
% pulseWidthList = [500,200;pulseWidthList];
% pulseAmpList = [20,50;pulseAmpList];
% % 
% polList = repmat([0],size(pulseAmpList,1),1);
% polList = [0;polList]; % cathodic first is 0

% pulseAmpList = [70,70];
% pulseWidthList = [200,200];
polList = zeros(size(pulseAmpList,1),1);

chanList = [21];
aux_chan = [70];
aux_chan_wave = [3]; % 1 = cathodic first from pulseAmpList, 2 = anodic first from pulseAmpList, 3 = cathodic first small
use_aux_chan = 0;
nomFreq=2;
nTests=30;
freq = 330;

interpulseList = 53;
prefix='Crackle_20200228_fmastim_330Hz_'; % no '_' needed;
folder='C:\C_\';

interphase=53;
nPulses=11; % should almost always be 1. nTests sets train lengthand t


% for k = 1:numel(injectedSignalDelayList)
%     signalDelay = injectedSignalDelayList(k);
    for m=1:numel(interpulseList)
        for j=1:size(pulseAmpList,1)
            pause(2)
            pol = polList(j);
            pWidth1=pulseWidthList(j,1)%in us
            amp1=pulseAmpList(j,1)%in uA
            pWidth2=pulseWidthList(j,2)%in us
            amp2=pulseAmpList(j,2)%in uA
            interpulse=interpulseList(m)
            testStim
        end
    end
% end
