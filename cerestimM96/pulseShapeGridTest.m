%wrapper script for testStim that will set a list of pulse-shapes and
%interpulse intervals for testing the ability of the stim-record system

pulseWidthList=[...
                200,200;...
                200,200;...
                ];
            
pulseAmpList=[  ...
                20,20;
                100,100;...
                ];
            

interpulseList = [53,];
% interpulseList = 53;
prefix='Saline_array_20180712_dukeProjBox_chan92con_';
folder='C:\data\Testing\Saline_dukeProjBox_20180712\';

chanList = 96;
interphase=53;
nPulses=1;

nomFreq=5;
nTests=5;

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
