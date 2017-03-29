%Response surface mapping (RSM) search of stimulation waveform space to
%identify optimal stimulation parameters 
%% set basic parameters:
    monkeyName='air'
    baseAmp=50;
    baseWidth=200;
    nPulses=20;
    interphase=53;%in us
    interpulse=300;%sets the duration of the sunc-high line that allows us to use the fast-settle, in us
    Freq=50;%sets the frequency with which pulses are delivered
    syncChanName='ainp16';
    testChannel=35;
%% set limits:
    %asymmetry is change in amplitude of second pulse relative to first
    %pulse. 
    asymLim=40;
    %imbalance is just time difference from first pulse in us
    imbalLim=10;
%% define asymmetry unit of interest (UOI) and imbalance UOI
    asymUOI=15;
    imbalUOI=4;
    scaleVec=[asymUOI,imbalUOI];
%% set initial test set
    testPoints=[0,0;...
                1,1;...
                1,-1;...
                -1,1;...
                -1,-1].*repmat(scaleVec,[5,1]);
%% set range of sample points over which to compute artifact error metrics:
    %[start point, end point] in points after stimulation onset
    errRange=[15,30];%15 points @30khz=500us, 30 points =1ms
%% create a cerestim object:
if ~exist('stimObj','var')
    stimObj=cerestim96;
    stimObj.connect();
elseif ~stimObj.isConnected();
    stimObj.connect();
end
if ~stimObj.isConnected();
    error('testStim:noStimulator','could not establish connection to stimulator')
end
    
%% connect to central and start recording
    %start file storeage app, and start recording:
    cbmex('open')
    fName='temp';
    cbmex('fileconfig',fName,'',1)
    pause(1) 
    cbmex('mask',0,0)%set all to disabled
    for i=1:96
        cbmex('mask',i,1)
    end
    for i=129:144
        cbmex('mask',i,1)
    end
    %configur double precision data:
    cbmex('trialconfig',1,'double','noevent','continuous',102400)%note, this flushes current data
    
    
    
%% test initial points
    for i=1:size(testPoints,1)
        %set stim parameters
        if testPoints(i,2)>=imbalLim ||testPoints(i,1)<=-imbalLim
            warning('findOptimalStim:imbalanceOutsideLimits','the imbalance for this test point is outside the allowed range')
            disp(['skipping test point:',num2str(i)])
            continue
        end
        if testPoints(i,1)>=asymLim ||testPoints(i,1)<=-asymLim
            warning('findOptimalStim:asymmetryOutsideLimits','the asymmetry for this test point is outside the allowed range')
            disp(['skipping test point:',num2str(i)])
            continue
        end
        amp1=baseAmp;
        amp2=baseAmp+testPoints(i,1);
        pWidth1=round(baseWidth*(amp2/baseAmp));
        pWidth2=round(baseWidth+testPoints(i,2));
        
        freq=floor(1/((pWidth1+pWidth2+interphase+interpulse)*10^-6));%hz

        stimObj.setStimPattern('waveform',1,...
                        'polarity',0,...
                        'pulses',nPulses,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq);
                    
        stimObj.setStimPattern('waveform',2,...
                        'polarity',1,...
                        'pulses',nPulses,...
                        'amp1',amp1,...
                        'amp2',amp2,...
                        'width1',pWidth1,...
                        'width2',pWidth2,...
                        'interphase',interphase,...
                        'frequency',freq);   
        %brief pause to ensure stimulator had time to save new params
        pause(.5)
        %flush cerebus cbmex buffer
        [~,~]=cbmex('trialdata',1);
        pause(0.1)
        %issue pulse train
        for j=1:nPulses
            if mod(j,2)
                stimObj.manualStim(testChannel,1);
            else
                stimObj.manualStim(testChannel,2);
            end
            pause(1/Freq);%wait for the next pulse
        end
        %grab central buffer
        [testData{i}.ts,testData{i}.cont]=cbmex('trialdata',1);
    end
%% isolate spikes and compute artifact size metric  
    intrgralErr=zeros(96,errRange(2)-errRange(1));
    slopeErr=zeros(96,errRange(2)-errRange(1));
    for i=1:numel(testData)
        %get the sync data from ainp16:
         syncData=testData{i,1}.cont{cellfun(@(x) x==144,testData{i,1}.cont(:,1)),3};
        %find our stim events in the sync data:
        stimOn=find(diff(syncData-mean(syncData)>3)>0.5);
        stimOff=nan(size(stimOn));
        tmpStimOff=find(diff(syncData-mean(syncData)>-3)>0.5);
        for j=1:numel(stimOn)
            if j<numel(stimOn)
                windowEnd=stimOn(j+1);
            else
                windowEnd=numel(syncData);
            end
            offIdx=stimOff(find((stimOff>stimOn(j)& stimOff<windowEnd),1,'first'));
            if ~isempty(offIdx)
                stimOff(j)=offIdx;
            end
        end

        %remove partial trials
        stimOn=stimOn(~isnan(stimOff));
        stimOff=stimOff(~isnan(stimOff));
        
        %Get arrays of artifact metrics for all channels
        for j=1:numel(stimOff)
            for k=1:96
                
                %error metric1:
                %integral of absolute artifact magnitude within errRange
                %error metric2: 
                %absolute slope of artifact from start to end of errRange
                chMask=cellfun(@(x) x==k,testData{i,1}.cont(:,1));
                [t1,t2]=stimArtifactMetrics(testData{i,1}.cont{chMask,3}(stimOff:stimOff+errRange(2)),errRange);
                integralErr(i,k)=integralErr(i,k)+t1;
                slopeErr(i,k)=slopeErr(i,k)+t2;
            end
        end
    
    end
    
%% get joint error metric for stimulated channel and other channels:
    stimChMask=cellfun(@(x) x==testChannel,testData{i,1}.cont(:,1));
    Err=[mean(integralErr(:,~stimChMask))+integralErr(:,stimChMask),mean(slopeErr(:,~stimChMask))+slopeErr(:,stimChMask)];
    
%% find gradient of planar fit through test points:

%% find local optima along gradient
%     localMinima=
    newErr=localMinima-1;
    while newErr<localMinima
    end
%% compute new test points around gradients local optima:
    %get appropriate scale for test-grid using curvature of fit to test
    %points along gradient, and noise of tests
    
%     scaleVec=
    %assemble list of test points:
    testPoints=[0,0;...
                1,1;...
                1,-1;...
                -1,1;...
                -1,-1;
                sqrt(2),0;...
                0,sqrt(2);...
                sqrt(2),0;...
                0,sqrt(2)]*scaleVec;
    testPoints=ceil(repmat(localOptima,[size(testPoints,1),1])+testPoints);
%% test new points 
    for i=1:size(testPoints,1)
        
    end
%% identify quadratic optima using the results of the tests

%% functions:
