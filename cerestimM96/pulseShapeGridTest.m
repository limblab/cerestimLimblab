%wrapper script for testStim that will set a list of pulse-shapes and
%interpulse intervals for testing the ability of the stim-record system

pulseAmpList = [25,25];
% pulseAmpList = [50,50];
pulseWidthList = [200,200];
polList = [0];
interpulseList = [53];

chanList = [46];
aux_chan = [1];
aux_chan_wave = [10]; % 1 = cathodic first from pulseAmpList, 2 = anodic first from pulseAmpList, 3 = cathodic first small
use_aux_chan = 0;
nomFreq=0.4; % frequency of when each train is sent
nTests=50; % number of trains
pulseWait = 9; % ms, time between each pulse in a train

prefix='Pop_20200930_test'; % no '_' needed;
folder='E:\Data-lab1\18E3-Pop\CerebusData\20200930';

interphase=53;
nPulses=10; % should almost always be 1. nTests sets train lengthand t



for j=1:size(pulseAmpList,1)
    pol = polList(j);
    pWidth1=pulseWidthList(j,1)%in us
    amp1=pulseAmpList(j,1)%in uA
    pWidth2=pulseWidthList(j,2)%in us
    amp2=pulseAmpList(j,2)%in uA
    interpulse=interpulseList(j)
    testStim
end

