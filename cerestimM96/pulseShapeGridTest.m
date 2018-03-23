%wrapper script for testStim that will set a list of pulse-shapes and
%interpulse intervals for testing the ability of the stim-record system

pulseWidthList=[...
                200,200;...
                ];
            
pulseAmpList=[  ...
                10,10;...
                ];
            

interpulseList=[53];
prefix='Han_stimswitchFastsettle_';
folder='C:\data\stimTesting\testData\';
chanList = [33:34];
interphase=53;
nPulses=1;
nomFreq=10;
nTests=100;
for m=1:numel(interpulseList)
    for j=1:size(pulseAmpList,1)
        pWidth1=pulseWidthList(j,1)%in us
        amp1=pulseAmpList(j,1)%in uA
        pWidth2=pulseWidthList(j,2)%in us
        amp2=pulseAmpList(j,2)%in uA
        interpulse=interpulseList(m)
        testStim
    end
end
