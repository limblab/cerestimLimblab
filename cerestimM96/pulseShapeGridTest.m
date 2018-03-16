%wrapper script for testStim that will set a list of pulse-shapes and
%interpulse intervals for testing the ability of the stim-record system

pulseWidthList=[...
                200,200;...
                200,200;...
                200,200;...
                ];
            
pulseAmpList=[  ...
                5,5;...
                10,10;...
                50,50;...
                ];
            
interpulseList=[53,100,200,300];
prefix='ResistorNetwork_200k_WorkingAmp_';
folder='C:\data\stimTesting\';
chanList = [1:4 5 7];
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
