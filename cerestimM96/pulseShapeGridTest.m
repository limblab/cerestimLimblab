%wrapper script for testStim that will set a list of pulse-shapes and
%interpulse intervals for testing the ability of the stim-record system

pulseWidthList=[...
                200,200;...
                ];
            
pulseAmpList=[  ...
                1,1;...
                ];
            

interpulseList = [20000];
% interpulseList = 53;
prefix='testing';
folder='C:\data\Han\testing\';

chanList = 1;
interphase=53;
nPulses=1;

nomFreq=5;
nTests=500;

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
