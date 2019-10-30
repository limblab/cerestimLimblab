function fName=startcerebusStimRecording(chan,amp1,amp2,pWidth1,pWidth2,interpulse,fileIdx,folder,prefix,pol)
    %handles file name creation and recording initialization for testStim
    %scritpt variants:
    fNum=num2str(fileIdx,'%03d');
    t=clock;
    t(6)=round(t(6));
    tStr='';
    for k=1:6
        tStr=[tStr,num2str(t(k)),'_'];
    end
    if(numel(amp1)>1)
        fName=[prefix,'_chan',num2str(chan),'stim_A1-many','_A2-many','_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse',num2str(interpulse),'_pol',num2str(pol),'_',fNum];
    elseif(numel(chan)>1)
        fName=[prefix,'stim_A1-',num2str(amp1),'_A2-',num2str(amp2),'_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse',num2str(interpulse),'_pol',num2str(pol),'_',fNum];
    else
        fName=[prefix,'_chan',num2str(chan),'stim_A1-',num2str(amp1),'_A2-',num2str(amp2),'_PW1-',num2str(pWidth1),'_PW2-',num2str(pWidth2),'_interpulse',num2str(interpulse),'_pol',num2str(pol),'_',fNum];
 
    end
    %start recording:
    ctr=0;
    tmp=dir(folder);
    while isempty(cell2mat(strfind({tmp.name},fName))) & ctr<10
        cbmex('fileconfig',[folder,fName],'',0)
        pause(.5);
        cbmex('fileconfig',[folder,fName],'testing stimulation artifacts',1);
        pause(1);
        ctr=ctr+1;
        tmp=dir(folder);
    end
    if ctr==10
       warning('tried to start recording and failed') 
    end
    
    %wait for sync:
    pause(8)
end