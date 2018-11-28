%test cerestim96 recording during stim:

% save params
folder='C:\data\Han\Han_20180731_dukeProjBox0718_ampSweep\';
prefix='Han_20180731_dukeProjBox_chan95con'; % no _ needed

%configure params
chanList=[95];
chanList_small = 1;
amp_small = 1;
freq_small = 1500;

minAmp = 1;
maxAmp = 100;
ampStep = 5;
numSweeps = 1;

pWidth1=200;%in us
pWidth2=200;%in us

interphase=53;
interpulse=53; %53, 100, 150, 200, 250, 300, 350, 400, 450

freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz

nPulses=1;
nomFreq=1;
nTests=2;

% make stim object
if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end

% impedanceData=stimObj.testElectrodes();
% save([folder,'impedance0',tStr,'.mat'],'impedanceData','-v7.3')

%establish cerebus connection
initializeCerebus();

% sweep through amplitudes numSweep times
for j = 1:numel(chanList)
    disp(['working on chan: ',num2str(chanList(j))])
    fName=startcerebusStimRecording(chanList(j),0,0,pWidth1,pWidth2,interpulse,j,folder,prefix);
    
    for sweepIdx = 1:numSweeps % sweep through amps
        for amp = minAmp:ampStep:maxAmp
            stimObj.setStimPattern('waveform',1,... % set stim pattern based on amp
                                    'polarity',0,...
                                    'pulses',nPulses,...
                                    'amp1',amp,...
                                    'amp2',amp,...
                                    'width1',pWidth1,...
                                    'width2',pWidth2,...
                                    'interphase',interphase,...
                                    'frequency',freq);
             stimObj.setStimPattern('waveform',2,...
                                    'polarity',1,...
                                    'pulses',nPulses,...
                                    'amp1',amp,...
                                    'amp2',amp,...
                                    'width1',pWidth1,...
                                    'width2',pWidth2,...
                                    'interphase',interphase,...
                                    'frequency',freq);   
                                
            stimObj.setStimPattern('waveform',3,...
                                    'polarity',0,...
                                    'pulses',100,...
                                    'amp1',amp_small,...
                                    'amp2',amp_small,...
                                    'width1',pWidth1,...
                                    'width2',pWidth2,...
                                    'interphase',interphase,...
                                    'frequency',freq_small);   
                                
            %deliver our stimuli:
%             disp('here');
            for i=1:nTests
            %    x=stimObj.getSequenceStatus();
                if mod(i,2)
                    stimObj.beginSequence()
                    stimObj.beginGroup()
                    stimObj.autoStim(chanList(j),1)
%                     stimObj.autoStim(chanList_small,3)
                    stimObj.endGroup()
                    stimObj.endSequence()
%                     stimObj.groupStimulus(1,1,1,2,[chanList(j),chanList_small],[1,3])
                    stimObj.play(1);
%                     stimObj.manualStim(chanList(j),1);
                else
                    stimObj.beginSequence()
                    stimObj.beginGroup()
                    stimObj.autoStim(chanList(j),2)
%                     stimObj.autoStim(chanList_small,3)
                    stimObj.endGroup()
                    stimObj.endSequence()
                    stimObj.play(1);
%                     stimObj.groupStimulus(1,1,1,2,[chanList(j),chanList_small],[2,3])
%                     stimObj.manualStim(chanList(j),2);
                end
                pause(1/nomFreq);
            end

        end %amp for

        pause(1) % pause a bit between sweeps?
    end % sweeps for
    
    pause(0.5) % pause before ending recoring
    cbmex('fileconfig',fName,'',0)    
end % chanList for


cbmex('close')
stimObj.disconnect();
stimObj.delete()
clear stimObj
