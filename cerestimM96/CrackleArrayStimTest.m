chanList = 1;

amp = 20;
amp1=[amp];%in uA
pWidth1=[200];%in us
amp2=[amp];%in uA
pWidth2=[200];%in us

interphase=[53];
interpulse=[53];
polarities = [0]; % 0 = cathodic first

nPulses=[1]; % pulses per train

nomFreq=400; %how frequently we deliver a train, if trains are single pulse, this is the stim frequency
nTests=400; % # of trains

pol = 0;

folder         =   'C:\data\Crackle\RightCuneate\';
prefix         =   'Crackle_20190413_stimTest';

%  pause(4)
 
testStim;