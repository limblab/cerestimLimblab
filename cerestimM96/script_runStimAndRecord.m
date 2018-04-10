% Wrapper function for runStimAndRecord. These two files take in a set of
% wave shapes (amplitude, pulsewidth, interphase, interpulse, polarities)
% and stimulates with single pulses randomly at a set frequency. 
% This is used when the order of pulses should be interleaved during an experiment. 
% Stimulation parameters and which waveform/channel is stimulated is stored in  a
% '..._waveformsSent' mat file. 

% Waveform parameters: All array sizes should be the same, the ith waveform
% is built by selecting the ith parameter in each of the following arrays
% amp1: amplitude of the first phase
% amp2: amplitude of the second phase
% pWidth1: pulse width of the first phase
% pWidth2: pulse width of the second phase
% interphase: time between phases (min 53us)
% interpulse: time between pulses (for fast settle circuit, 300us is common)
% polarities: polarity of the waveform (0 cathodal, 1 anodal)

% nPulses: number of pulses in a single train (1 for a single pulse)
% nomFreq: frequency to stimulate
% nTests: number of trains
% chanList: list of channels to stimulate. Channels and waveform are
%           independent
% saveImpedance: run an impedance test?
% folder: folder to save files in
% prefix: prefix for file name

for mm = 1:2
    clear;

    folder='C:\data\Han\Han_20180310_chic201802\';
    prefix='Han_20180310_chic201802'; % no underscore after prefix please
    
    % all parameters need to be the same size matrix
    amp1=[10,10,20,20,30,30];%in uA
    pWidth1=[200,200,200,200,200,200];%in us
    amp2=[10,10,20,20,30,30];%in uA
    pWidth2=[200,200,200,200,200,200];%in us
    
    interphase=[53,53,53,53,53,53,53];
    interpulse=[300,300,300,300,300,300];
    polarities = [0,1,0,1,0,1]; % 0 = cathodic first
   
    
    nPulses=1; % pulses per train
    nomFreq=5;
    nTests=750; % # of trains

    chanList=[25]; % pick some channels

    arg = {'interleaveChanList',1};
    saveImpedance=0;
%     if(mm == 1)
%         saveImpedance = 1;
%     else
%         saveImpedance = 0;
%     end

    runStimAndRecord;
end
