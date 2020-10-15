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
%% 
for mm = 1:21
    pause(1)
    disp(['stimulation iteration: ',num2str(mm)])

    folder='C:\H\';
    prefix='Han_20191217_leftS1_CObump_'; % no underscore after prefix please

    % all parameters need to be the same size matrix
    amp1=[15,30,60,100];%in uA
    pWidth1=[200,200,200,200];%in us
    amp2=[15,30,60,100];%in uA
    pWidth2=[200,200,200,200];%in us

    interphase=[53,53,53,53];
    interpulse=[53,53,53,53];
    polarities = [0,0,0,0]; % 0 = cathodic first

    nPulses=[1,1,1,1]; % pulses per train
%     freq=1; %frequency of the trains. This may be overridden in runStimAnd Record

    nomFreq=10; %how frequently we deliver a train, if trains are single pulse, this is the stim frequency
    nTests=1500; % # of trains
    chanList = {2,6,7,14,19,22,28,33,35,44,45,50,52,57,60,66,67,73,78,80,84,87,90,91,93};
    
    arg = {'interleaveChanList',1};
        saveImpedance=0;
    %     if(mm == 1)
    %         saveImpedance = 1;
    %     else
    %         saveImpedance = 0;
    %     end

    runStimAndRecord;
end
disp('done')


%% Trains
for mm = 2
    pause(1)
    disp(['stimulation iteration: ',num2str(mm)])

    folder='C:\Han_20190920_stimrec\';
    prefix='Han_20190920_leftS1_CObump_dukeProjBoxchan25_2'; % no underscore after prefix please

    % all parameters need to be the same size matrix
    amp1=[50];%in uA
    pWidth1=[50];%in us
    amp2=[50];%in uA
    pWidth2=[50];%in us

    interphase=[53];
    interpulse=[53];
    polarities = [0]; % 0 = cathodic first

    nPulses=[10]; % pulses per train
    freq=1; %frequency of the trains. This may be overridden in runStimAnd Record

    nomFreq=2; %how frequently we deliver a train, if trains are single pulse, this is the stim frequency
    nTests=320; % # of trains
    chanList = {25};
    
    
    arg = {'interleaveChanList',1};
        saveImpedance=0;
    %     if(mm == 1)
    %         saveImpedance = 1;
    %     else
    %         saveImpedance = 0;
    %     end

    runStimAndRecord;
end

% 
% 
% %% Duncan 1 - multichannel stim
% for mm = 1:10
%     pause(1)
%     disp(['stimulation iteration: ',num2str(mm)])
% 
%     folder='C:\data\Duncan\Duncan_20190416_stimrec\';
%     prefix='Duncan_20190416_leftS1_CObump'; % no underscore after prefix please
% 
%     % all parameters need to be the same size matrix
%     amp1=[15,30,60,100];%in uA
%     pWidth1=[200,200,200,200];%in us
%     amp2=[15,30,60,100];%in uA
%     pWidth2=[200,200,200,200];%in us
% 
%     interphase=[53,53,53,53];
%     interpulse=[53,53,53,53];
%     polarities = [0,0,0,0]; % 0 = cathodic first
% 
%     nPulses=[1,1,1,1]; % pulses per train
% %     freq=1; %frequency of the trains. This may be overridden in runStimAnd Record
% 
%     nomFreq=10; %how frequently we deliver a train, if trains are single pulse, this is the stim frequency
%     nTests=1500; % # of trains
% 
% %     chanList=[3,5,12,13,33,37,43]; % pick some channels 4
% %         % all groups of 5 electrodes
% %         chanListAppend = {}; % DO NOT WRITE INTO THIS ONE
% %         chan_list_5 = perms(chanList);
% %         chan_list_5 = unique(sort(chan_list_5(:,1:5),2),'rows');
% %         chan_list_all = chanList;
% %         chanList = {};
% %         for i = 1:numel(chan_list_all)
% %             chanList{i} = chan_list_all(i);
% %         end
% %         for i = 1:size(chan_list_5,1)
% %             chanList{end+1} = chan_list_5(i,:);    
% %         end
%         
% %             % all combinations of those channels
% %       chanList = {29,31,36,50,57,61};
%     chanList = {33,53,68,74,78,90,79};
% %             chanListAppend = {}; % DO NOT USE THIS ONE
% %             for c = 1:numel(chanList)
% %                 for j = c+1:numel(chanList)
% %                     chanListAppend{end+1} = [chanList{c},chanList{j}];
% %                 end
% %             end
% %             chanList = [chanList,chanListAppend];
%     
%     arg = {'interleaveChanList',1};
%         saveImpedance=0;
%     %     if(mm == 1)
%     %         saveImpedance = 1;
%     %     else
%     %         saveImpedance = 0;
%     %     end
% 
%     runStimAndRecord;
% end
% 
% %% Duncan 1 - stim channel record
% for mm = 1:14
%     disp(['stimulation iteration: ',num2str(mm)])
%     clear;
% 
%     folder='C:\data\Duncan\Duncan_20181214_stimRec\';
%     prefix='Duncan_20181214_CObump_dukeProjBoxchan37'; % no underscore after prefix please
%     
%     % all parameters need to be the same size matrix
%     amp1=[5,15,25,60,60,15,15];%in uA
%     pWidth1=[500,500,500,100,100,500,500];%in us
%     amp2=[20,60,100,60,60,60,60];%in uA
%     pWidth2=[100,100,100,500,100,100,100];%in us
%     
%     interphase=[53,53,53,53,53,53,53];
%     interpulse=[53,53,53,53,53,53,53,53];
%     polarities = [1,1,1,0,0,1,1]; % 0 = cathodic first
%    
%     nPulses=[1,1,1,1,1,20,60]; % pulses per train
%     freq=[-1,-1,-1,-1,-1,100,300]; %frequency of the trains. This may be overridden in runStimAnd Record. -1 means override in function
% 
%     nomFreq=2; %how frequently we deliver a train, if trains are single pulse, this is the stim frequency
%     nTests=250; % # of trains
% 
%     chanList = {37};
% 
%     arg = {'interleaveChanList',0};
%     saveImpedance=0;
% %     if(mm == 1)
% %         saveImpedance = 1;
% %     else
% %         saveImpedance = 0;
% %     end
% 
%     runStimAndRecord;
% end
% 
% 
% %% pre LTD 
% for mm = 1:2
%     disp(['stimulation iteration: ',num2str(mm)])
%     clear;
% 
%     folder='C:\data\Duncan\Duncan_20181214_stimRec\';
%     prefix='Duncan_20181214_fastSettle_CObump'; % no underscore after prefix please
%     
%     % all parameters need to be the same size matrix
%     amp1=[50];%in uA
%     pWidth1=[200,200];%in us
%     amp2=[50];%in uA
%     pWidth2=[200,200];%in us
%     
%     interphase=[53,53];
%     interpulse=[53,53];
%     polarities = [0,0]; % 0 = cathodic first
%    
%     nPulses=[1,1]; % pulses per train
%     freq=[-1,-1]; %frequency of the trains. This may be overridden in runStimAnd Record. -1 means override in function
% 
%     nomFreq=1; %how frequently we deliver a train, if trains are single pulse, this is the stim frequency
%     nTests=250; % # of trains
% 
% %     chanList = {21,28,61,64,66,91};
% %     chanList = {40,43,56,57,67,68,76,87}
%     chanList = {44,45,54,70,74,75};
%     for i = 1:6
%         for j = i+1:6
%             chanList{end+1} = [chanList{i},chanList{j}];
%         end
% 
%     end
%     arg = {'interleaveChanList',1};
%     saveImpedance=0;
% %     if(mm == 1)
% %         saveImpedance = 1;
% %     else
% %         saveImpedance = 0;
% %     end
% 
%     runStimAndRecord;
% end
% 
% %% Duncan 1 - magical LTD protocol which doesn't work
% for mm = 1
%     disp(['stimulation iteration: ',num2str(mm)])
%     clear;
% 
%     folder='C:\data\Duncan\Duncan_20181205_stimRec\';
%     prefix='Duncan_20181206_TBS'; % no underscore after prefix please
%     
%     % all parameters need to be the same size matrix
%     amp1=[50];%in uA
%     pWidth1=[200];%in us
%     amp2=[50];%in uA
%     pWidth2=[200];%in us
%     
%     interphase=[53];
%     interpulse=[53];
%     polarities = [1]; % 0 = cathodic first
%    
%     nPulses=[1]; % pulses per train
%     freq=[-1]; %frequency of the trains. This may be overridden in runStimAnd Record. -1 means override in function
% 
%     nomFreq=1; %how frequently we deliver a train, if trains are single pulse, this is the stim frequency
%     nTests=900; % # of trains
% 
%     chanList = {[1,2,33,35,65,66,67,68,69]};
% %     for i = 1:6
% %         for j = i+1:6
% %             chanList{end+1} = [chanList{i},chanList{j}];
% %         end
% % 
% %     end
%     arg = {'interleaveChanList',1};
%     saveImpedance=0;
% %     if(mm == 1)
% %         saveImpedance = 1;
% %     else
% %         saveImpedance = 0;
% %     end
% 
%     runStimAndRecord;
% end
% er