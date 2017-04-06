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
    %iteration limit
    iterLimit=10;
%% define asymmetry unit of interest (UOI) and imbalance UOI
    %used to build the pattern of test points
    asymUOI=15;
    imbalUOI=4;
    scaleVec=[asymUOI,imbalUOI];
%% set initial test set
    basePattern=[0,0;...
                1,1;...
                1,-1;...
                -1,1;...
                -1,-1;
                sqrt(2),0;...
                0,sqrt(2);...
                -sqrt(2),0;...
                0,-sqrt(2)];
    testPattern=basePattern.*repmat(scaleVec,[size(basePattern,1),1]);
    currTestPoints=testPattern;        
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
    cbmex('fileconfig',fName,'',0)
    pause(1) 
    cbmex('mask',0,0)%set all to disabled
    %set 30k sampling on neural channels
    for i=1:96
        cbmex('config',i,'smpgroup',5)
        cbmex('config',i,'smpfilter',0)%ensure no filter
        cbmex('mask',i,1)
    end
    %turn on sampling for extra analog input lines:
    ainputLines=[144];
    for i=1:numel(ainputLines)
        cbmex('config',i,'smpgroup',5)
        cbmex('config',i,'smpfilter',0)%ensure no filter
        cbmex('mask',ainputLines(i),1)
    end
    %configur double precision data:
    cbmex('trialconfig',1,'double','noevent','continuous',102400)%note, this flushes current data
%% run tests
    converged=false;
    testPoints=[];
    loopCount=0;
    while ~converged
%% hit current set of test points
        for i=1:size(currTestPoints,1)
            %set stim parameters
            if currTestPoints(i,2)>=imbalLim ||currTestPoints(i,2)<=-imbalLim
                warning('findOptimalStim:imbalanceOutsideLimits','the imbalance for this test point is outside the allowed range')
                disp(['selected imbalance: ',num2str(currTestPoints(i,2))])
                disp(['imbalance limit: ',num2str(imbalLim)])
                disp(['skipping test point:',num2str(i)])
                continue
            end
            if currTestPoints(i,1)>=asymLim ||currTestPoints(i,1)<=-asymLim
                warning('findOptimalStim:asymmetryOutsideLimits','the asymmetry for this test point is outside the allowed range')
                disp(['selected asymmetry: ',num2str(currTestPoints(i,1))])
                disp(['asymmetry limit: ',num2str(asymLim)])
                disp(['skipping test point:',num2str(i)])
                continue
            end
            amp1=baseAmp;
            amp2=baseAmp+currTestPoints(i,1);
            pWidth1=round(baseWidth*(amp2/baseAmp));
            pWidth2=round(baseWidth+currTestPoints(i,2));

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
                    evalc('stimObj.manualStim(testChannel,1)');
                else
                    evalc('stimObj.manualStim(testChannel,2)');
                end
                pause(1/Freq);%wait for the next pulse
            end
            %grab central buffer
            [testData{i}.ts,testData{i}.cont]=cbmex('trialdata',1);
        end
    %% isolate spikes and compute artifact size metric  
        integralErr=zeros(96,numel(testData));
        slopeErr=zeros(96,numel(testData));
        for i=1:numel(testData)
            %get the sync data from ainp16:
             syncData=testData{1,i}.cont{cellfun(@(x) x==144,testData{1,i}.cont(:,1)),3}/2500;
            %find our stim events in the sync data:
            stimOn=find(diff((syncData-mean(syncData))>3)>0.5);
            stimOff=nan(size(stimOn));
            tmpStimOff=find((diff(syncData-mean(syncData))<-3)>0.5);
            for j=1:numel(stimOn)
                if j<numel(stimOn)
                    windowEnd=stimOn(j+1);
                else
                    windowEnd=numel(syncData);
                end
                offIdx=find((tmpStimOff>stimOn(j)& tmpStimOff<windowEnd),1,'first');
                if ~isempty(offIdx)
                    stimOff(j)=tmpStimOff(offIdx);
                end
            end

            %remove partial trials
            stimOn=stimOn(~isnan(stimOn));
            stimOff=stimOff(~isnan(stimOff));

            %Get arrays of artifact metrics for all channels
            for j=1:numel(stimOff)
                for k=1:96

                    %error metric1:
                    %integral of absolute artifact magnitude within errRange
                    %error metric2: 
                    %absolute slope of artifact from start to end of errRange
                    chMask=cellfun(@(x) x==k,testData{1,i}.cont(:,1));
                    [t1,t2]=stimArtifactMetrics(testData{1,i}.cont{chMask,3}(stimOff:stimOff+errRange(2)),errRange);
                    integralErr(k,i)=integralErr(k,i)+t1;
                    slopeErr(k,i)=slopeErr(k,i)+t2;
                end
            end
        end
        
    %% get joint error metric for stimulated channel and other channels:
        neuralMask=cellfun(@(x) x<=96,testData{1,1}.cont(:,1));
        stimChMask=cellfun(@(x) x==testChannel,testData{1,1}.cont(neuralMask,1));
        Err=[mean(integralErr(~stimChMask,:))+integralErr(stimChMask,:)/10;mean(slopeErr(~stimChMask,:))+slopeErr(stimChMask,:)];

    %% find 2nd order response surface through the tested points
        fitAsym=polyfit(currTestPoints(:,1),Err(1,:)',2);
        fitImbal=polyfit(currTestPoints(:,2),Err(1,:)',2);
        rFunc=@(C,x) C(1)*x(:,1).^2 + C(2)*x(:,2).^2 + C(3)*x(:,1).*x(:,2) + C(4)*x(:,1) + C(5)*x(:,2) + C(6);
        C0=[fitAsym(1),fitImbal(1),0,fitAsym(2),fitImbal(2),(fitAsym(3)+fitImbal(3))/2];
        coeffs=lsqcurvefit(rFunc,C0,currTestPoints,Err(1,:)');
        
    %% find minima of the response function:
        A=coeffs(1);B=coeffs(2);C=coeffs(3);D=coeffs(4);E=coeffs(5);
        asymMin=(C*E-2*B*D)/(4*A*B-C*C);
        imbalMin=(C*D-2*A*E)/(4*A*B-C*C);
        disp('estimated minima:')
        disp(['asym minima: ',num2str(asymMin), '   test range: ',num2str(min(currTestPoints(:,1))),' to: ',num2str(max(currTestPoints(:,1)))]);
        disp(['imbal minima: ',num2str(imbalMin),'   test range: ',num2str(min(currTestPoints(:,2))),' to: ',num2str(max(currTestPoints(:,2)))]);
        if asymMin<max(currTestPoints(:,1)) || asymMin>min(currTestPoints(:,1)) || imbalMin<max(currTestPoints(:,2)) || imbalMin>min(currTestPoints(:,2))
            %minima is inside our test pattern
            disp('error minima is within the test window')
            %check that the gradients are small around our test pattern
            %this is a necessary criteria of using a quadratic function as
            %a local approximator for an arbitrary response surface:
            dAsym=2*A*currTestPoints(:,1)+C*currTestPoints(:,2)+D;
            dImbal=2*B*currTestPoints(:,2)+C*currTestPoints(:,1)+E;
            if min(abs(dAsym))>1 || min(abs(dImbal))>1
                disp('local curvature is high')
                disp(['minimum asym slope: ',num2str(min(dAsym))])
                disp(['minimum imbal slope: ',num2str(min(dImbal))])
                disp('getting a tighter window and re-testing')
                
%                 asymRange=[min(currTestPoints(:,1)),max(currTestPoints(:,1))];
%                 imbalRange=[min(currTestPoints(:,2)),max(currTestPoints(:,2))];
%                 asymVec=asymRange(1):diff(asymRange)/10:asymRange(2);
%                 imbalVec=imbalRange(1):diff(imbalRange)/10:imbalRange(2);
%                 [asymMesh,imbalMesh]=meshgrid(asymVec,imbalVec);
% 
%                 errMesh=reshape(rFunc(coeffs,[asymMesh(:)',imbalMesh(:)']),size(asymMesh));
%                 figure; surf(asymMesh,imbalMesh,errMesh)
                
                
                %get a tighter test pattern around the anticipated optima
                scaleVec=scaleVec*0.5;
                testPattern=basePattern.*repmat(scaleVec,[size(basePattern,1),1]);
                currTestPoints=testPattern+repmat([asymMin,imbalMin],[size(testPattern,1),1]);
            else %our local surface is pretty smooth, so we can trust the estiamted minima
                break
            end
            
        else
            %% compute new test points around projected minima:
            currTestPoints=testPattern+repmat([asymMin,imbalMin],[size(testPattern,1),1]);
        end
        loopCount=loopCount+1;
        if loopCount>iterLimit
            warning('did not find optimal stim parameters before exceeding iteration limit')
            disp(['tried ',num2str(loopCount),' test patterns without finding a local minima in the artifact'])
            break
        end
    end

