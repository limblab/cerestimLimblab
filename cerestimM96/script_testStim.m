%amp1           :   amplitude of first pulse phase
%amp2           :   amplitude of second pulse phase
%pWidth1        :   width of first pulse phase
%pWidth2        :   width of second pulse phase
%interphase     :   time between pulses
%interpulse     :   interphase time of the waveform. This is also the time
%                       the sync line is high after the last pulse
%nPulses        :   pulses per waveform
%chanList       :   a vector of channel numbers that will be sequentially
%                       stimulated
%folder         :   name of the folder where data should be saved
%prefix         :   a string that will be appended to the front of every
%                       file name
%nomFreq        :   frequency that matlab will attempt to stimulate at
%nTests         :   number of times the script will issue a cathodal/anodal
%                       stim pair
clear;
folder = 'C:\data\Han\TEST\';
prefix = 'TEST';

amps = [10];
pWidth1 = 200;
pWidth2 = 200;
interphase = 53;
interpulse = 1053;
nPulses = 20;

chanList = [40];
nomFreq = 0.5;
nTests = 2;



for a = 1:numel(amps)
    amp1 = amps(a);
    amp2 = amp1;
    testStim;
    
end