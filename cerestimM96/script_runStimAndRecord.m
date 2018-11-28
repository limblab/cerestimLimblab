%% Joe stim channel test
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


%% Chips 1
for mm = 1
    disp(['stimulation iteration: ',num2str(mm)])
    clear;

    folder='C:\data\Han\Han_20181126_stimRec\';
    prefix='Han_20181126_FC'; % no underscore after prefix please
    
    % all parameters need to be the same size matrix
    amp1=[40];%in uA
    pWidth1=[200];%in us
    amp2=[40];%in uA
    pWidth2=[200];%in us
    
    interphase=[53];
    interpulse=[53];
    polarities = [0]; % 0 = cathodic first
   
    nPulses=1; % pulses per train
%     freq=200; %frequency of the trains. This may be overridden in runStimAnd Record

    nomFreq=10; %how frequently we deliver a train, if trains are single pulse, this is the stim frequency
    nTests=900; % # of trains

    chanList={55,58,[55,58]}; % pick some channels

    arg = {'interleaveChanList',1};
    saveImpedance=0;
%     if(mm == 1)
%         saveImpedance = 1;
%     else
%         saveImpedance = 0;
%     end

    runStimAndRecord;
end

