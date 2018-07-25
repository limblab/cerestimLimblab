%test cerestim96 recording during stim:

% save params
folder='C:\data\Han\Han_20180718_dukeProjBox0718_ampSweep\';
prefix='Han_20180718_dukeProjBox_chan95con'; % no _ needed

%configure params
chanList=[95];

minAmp = 1;
maxAmp = 100;
ampStep = 1;
numSweeps = 4;

pWidth1=200;%in us
pWidth2=200;%in us

interphase=53;

interpulse=250;

freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz

nPulses=1;
nomFreq=5;
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

            %deliver our stimuli:
            for i=1:nTests
            %    x=stimObj.getSequenceStatus();
                if mod(i,2)
                    stimObj.manualStim(chanList(j),1);
                else
                    stimObj.manualStim(chanList(j),2);
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
