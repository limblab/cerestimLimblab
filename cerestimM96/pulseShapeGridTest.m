% 
% pulseWidthList=[...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 10000,200;...
%                 2000,200;...
%                 1000,200;...
%                 500,200;...
%                 400,200;...
%                 200,10000;...
%                 200,2000;...
%                 200,1000;...
%                 200,500;...
%                 200,400;...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 200,200;...
%                 200,199;...
%                 199,200;...
%                 200,198;...
%                 198,200;...
%                 200,197;...
%                 197,200;...
%                 200,196;...
%                 196,200;...
%                 ];
%             
% pulseAmpList=[  ...
%                 1,1;...
%                 5,5;...
%                 10,10;...
%                 20,20;...
%                 50,50;...
%                 1,50;...
%                 5,50;...
%                 10,50;...
%                 20,50;...
%                 25,50;...
%                 50,1;...
%                 50,5;...
%                 50,10;...
%                 50,20;...
%                 50,25;...
%                 45,50;...
%                 50,45;...
%                 46,50;...
%                 50,46;...
%                 47,50;...
%                 50,47;...
%                 48,50;...
%                 50,48;...
%                 49,50;...
%                 50,49;...
%                 50,50;...
%                 50,50;...
%                 50,50;...
%                 50,50;...
%                 50,50;...
%                 50,50;...
%                 50,50;...
%                 50,50;...
%                 ];

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
%  interpulseList=[53];
% prefix='Saline_parameterGridTesting_FastSettle_';
% folder='C:\data\stimTesting\';
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
% for m=1:numel(interpulseList)
%     for j=10:50
%         pWidth1=200;%in us
%         amp1=j;%in uA
%         pWidth2=200;%in us
%         amp2=j;%in uA
%         interpulse=interpulseList(m);
%         testStim
%     end
% end
